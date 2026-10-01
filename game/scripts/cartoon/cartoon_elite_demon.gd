extends "res://scripts/cartoon/cartoon_monster.gd"
const DemonArt = preload("res://scripts/cartoon/cartoon_demon_art.gd")
var director
var slot_id: String = ""
var variant: String = "ember"
var tier: int = 0
var home: Vector2
var hex_position: Vector2
var hex_t: float = 0
var hex_cooldown: float = 2
var hex_radius: float = 72
var disengage_t: float = 0
var reward_paid: bool = false
func _ready() -> void: add_to_group("cartoon_elite_demons")
func receive_combat_damage(amount: int) -> bool:
	if reward_paid or hp<=0 or not director.host.monsters.has(self): return false
	if take_damage(amount):
		reward_paid = true
		director.defeated(self)
	return true
func apply_chill(duration: float) -> void:
	if chill_t<=0: chill_base_speed = move_speed
	chill_t = maxf(chill_t,duration)
	move_speed = chill_base_speed*0.8
func _process(delta: float) -> void:
	if director==null or director.blocked(): return
	super._process(delta)
	if hp<=0: return
	var hero = director.host.hero
	if hero.death_t>0:
		hex_t = 0
		return
	if hero.position.distance_to(home)>650:
		disengage_t += delta
		hex_t = 0
		windup_t = 0
		position = position.move_toward(home,move_speed*delta)
		if disengage_t>=5: hp = max_hp
		queue_redraw()
		return
	disengage_t = 0
	# Leash prevents endlessly dragging elites into a town or onto a rescue point.
	if position.distance_to(home)>560 and windup_t<=0:
		position = position.move_toward(home,move_speed*delta)
	hex_cooldown = maxf(0,hex_cooldown-delta)
	if hex_t>0:
		hex_t = maxf(0,hex_t-delta)
		if hex_t<=0:
			var pulse = FX.spawn(get_parent(),hex_position,"enemy_strike",Vector2.UP,Color("fb65dc"))
			if pulse != null: pulse.strike_radius = hex_radius
			if hero.position.distance_to(hex_position)<=hex_radius and not hero.is_evading(): director.hit_player(contact_damage+6,level)
			hex_cooldown = 4.0
	elif hex_cooldown<=0 and position.distance_to(hero.position)<420 and home.distance_to(hero.position)<650:
		hex_position = hero.position
		hex_t = 1.05
	queue_redraw()
func can_chase() -> bool:
	return super.can_chase() and hex_t<=0 and (director==null or director.host.hero.position.distance_to(home)<650)
func advance_contact(hero, delta: float, contact_radius: float) -> bool:
	# Elite contact uses the boss-sized, visible warning without a story boss ID.
	if windup_t<=0 and can_hit() and position.distance_to(hero.position)<=contact_radius:
		windup_duration = 0.75
		windup_t = windup_duration
		strike_radius = contact_radius+36
		strike_direction = (hero.position-position).normalized()
		return false
	return super.advance_contact(hero,delta,contact_radius)
func _draw() -> void:
	if hex_t>0:
		var center: Vector2 = to_local(get_parent().to_global(hex_position))
		draw_set_transform(center,0,Vector2.ONE/scale)
		var progress: float = 1-hex_t/1.05
		draw_circle(Vector2.ZERO,hex_radius,Color(0.82,0.15,0.65,0.12+progress*0.16))
		draw_arc(Vector2.ZERO,hex_radius,0,TAU,64,Color("ff75dd"),2.5,true)
		draw_arc(Vector2.ZERO,hex_radius-6,-PI/2,-PI/2+TAU*progress,64,Color("ffeed1"),3,true)
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	if windup_t>0:
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE/scale)
		draw_arc(Vector2.ZERO,strike_radius,0,TAU,64,Color("ff947c"),3,true)
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	DrawUtil.shadow(self,Vector2(0,8),34,0.38)
	DemonArt.frame(self,variant,int(anim_t*8)%6,Rect2(-64,-133,128,142),Color("ffb7c4") if hit_flash>0 else Color.WHITE)
	DrawUtil.bar(self,Vector2(-40,-148),Vector2(80,7),float(hp)/max_hp,Color("ec5098"))
	var caption: String = "Nv %d • ELITE • " % level+monster_name
	var caption_x: float = -ThemeDB.fallback_font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,11).x/2
	draw_string(ThemeDB.fallback_font,Vector2(caption_x+1,-155),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("182a24"))
	draw_string(ThemeDB.fallback_font,Vector2(caption_x,-156),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Difficulty.level_color(get_node("/root/CartoonPlayerState").player_level,level))
	if chill_t>0: draw_arc(Vector2(0,-45),38,anim_t,anim_t+PI*1.7,32,Color("93edff"),2,true)
	if burn_t>0: DrawUtil.flame(self,Vector2(0,-34),30,10,anim_t)
