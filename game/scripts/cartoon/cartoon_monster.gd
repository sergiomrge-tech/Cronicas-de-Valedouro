class_name ValedouroCartoonMonster
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const CombatArt = preload("res://scripts/cartoon/cartoon_combat_art.gd")
const FX = preload("res://scripts/cartoon/cartoon_combat_fx.gd")
const Assets = preload("res://scripts/cartoon/cartoon_visual_assets.gd")

const Difficulty = preload("res://scripts/cartoon/cartoon_difficulty.gd")
var level: int = 1
var kind: String = "wolf"
var monster_name: String = "Lobo do Vale"
var hp: int = 34
var max_hp: int = 34
var move_speed: float = 86.0
var chill_t: float = 0.0
var burn_t: float = 0.0
var chill_base_speed: float = 86.0
var contact_damage: int = 7
var attack_cooldown: float = 0.0
var hit_flash: float = 0.0
var story_tag: String = ""
var boss_id: String = ""
var lunge_t: float = 0.0
var anim_t: float = 0.0
var windup_t: float = 0.0
var windup_duration: float = 0.45
var strike_radius: float = 64.0
var strike_direction: Vector2 = Vector2.DOWN

func setup(data: Dictionary) -> void:
	level = clampi(int(data.get("level",1)),1,100)
	kind = String(data.get("kind","wolf"))
	monster_name = String(data.get("name","Lobo do Vale"))
	hp = int(data.get("hp",34))
	max_hp = hp
	move_speed = float(data.get("speed",86.0))
	contact_damage = int(data.get("damage",7))
	story_tag = String(data.get("story_tag",""))
	boss_id = String(data.get("boss_id",""))
	position = data.get("pos",Vector2.ZERO)
	scale = Vector2.ONE * float(data.get("scale",1.0))
	queue_redraw()

func apply_chill(duration: float) -> void:
	if chill_t<=0: chill_base_speed = move_speed
	chill_t = maxf(chill_t,duration)
	move_speed = chill_base_speed*(0.8 if boss_id!="" else 0.55)
	queue_redraw()

func _process(delta: float) -> void:
	if chill_t>0:
		var host = get_parent()
		while host != null and not host.has_method("_damage_monster"): host = host.get_parent()
		var blocked: bool = false
		if host != null:
			var layout = host.get_node_or_null("HUD/GameLayout")
			blocked = layout != null and layout.is_blocked()
		if not blocked:
			chill_t = maxf(0,chill_t-delta)
			if chill_t<=0: move_speed = chill_base_speed
	lunge_t = maxf(0,lunge_t-delta)
	anim_t += delta
	attack_cooldown = maxf(0.0,attack_cooldown-delta)
	hit_flash = maxf(0.0,hit_flash-delta)
	queue_redraw()

func take_damage(amount: int) -> bool:
	if hp <= 0: return true
	FX.spawn(get_parent(),position+Vector2(0,-30),"hit",Vector2.UP,Color("ffdb82"),mini(amount,hp))
	hp = maxi(0,hp-amount)
	hit_flash = 0.12
	queue_redraw()
	if hp <= 0:
		var death = FX.spawn(get_parent(),position,"death",Vector2.UP,Color("91dce3"))
		if death != null:
			death.corpse_texture = CombatArt.texture("mob_"+kind)
			death.corpse_region = Rect2((int(anim_t*8)%6)*144,0,144,160)
	return hp <= 0

func can_hit() -> bool:
	return hp>0 and attack_cooldown <= 0.0 and windup_t<=0

func can_chase() -> bool:
	return hp>0 and windup_t<=0 and lunge_t<=0

func advance_contact(hero, delta: float, contact_radius: float) -> bool:
	if hp<=0 or hero.death_t>0:
		windup_t = 0
		return false
	if windup_t>0:
		windup_t = maxf(0,windup_t-delta)
		queue_redraw()
		if windup_t>0: return false
		mark_hit()
		var pulse = FX.spawn(get_parent(),position,"enemy_strike",strike_direction,Color("ff654f") if boss_id!="" else Color("ffb45e"))
		if pulse != null: pulse.strike_radius = strike_radius
		return position.distance_to(hero.position)<=strike_radius and not hero.is_evading()
	if position.distance_to(hero.position)<=contact_radius and can_hit():
		windup_duration = 0.8 if boss_id!="" else 0.45
		windup_t = windup_duration
		strike_radius = contact_radius+(42 if boss_id!="" else 12)
		strike_direction = (hero.position-position).normalized()
		queue_redraw()
	return false

func mark_hit() -> void:
	attack_cooldown = 0.9
	lunge_t = 0.20
	FX.spawn(get_parent(),position+Vector2(0,-22),"slash",strike_direction,Color("ff965c"))

func _draw() -> void:
	if windup_t>0:
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE/scale)
		var progress: float = 1-windup_t/windup_duration
		var warning: Color = Color("ff654f") if boss_id!="" else Color("ffb45e")
		draw_circle(Vector2.ZERO,strike_radius,Color(warning,0.10+progress*0.12))
		draw_arc(Vector2.ZERO,strike_radius,0,TAU,64,Color(warning,0.8),2.5,true)
		draw_arc(Vector2.ZERO,strike_radius-5,-PI/2,-PI/2+TAU*progress,64,Color("ffe4b4"),3.5,true)
		var tip: Vector2 = strike_direction*(strike_radius-12)
		draw_line(tip-strike_direction.rotated(-0.65)*10,tip,warning,3,true)
		draw_line(tip-strike_direction.rotated(0.65)*10,tip,warning,3,true)
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	var bob: float = absf(sin(anim_t*7.0))*2.0
	DrawUtil.shadow(self,Vector2(0,10),24,0.26)
	draw_set_transform(Vector2(sin(lunge_t*PI/0.2)*5,-bob),sin(lunge_t*PI/0.2)*0.10,Vector2.ONE)
	var dimensions: Vector2 = Vector2(88,98) if kind in ["wolf","goblin","slime"] else Vector2(106,118)
	CombatArt.monster_frame(self,kind,int(anim_t*8)%6,Rect2(-dimensions.x/2,-dimensions.y+10,dimensions.x,dimensions.y),Color(1,0.8,0.65) if hit_flash>0 else Color.WHITE)
	if kind not in ["wolf","goblin","slime"]:
		var rune_color: Color = Color("9ceccf")
		if "frost" in kind: rune_color = Color("86daff")
		elif "void" in kind or kind == "azharel": rune_color = Color("e5a1ff")
		elif kind == "ash_general": rune_color = Color("ffad56")
		draw_arc(Vector2(0,4),32,anim_t,anim_t+TAU*0.8,48,Color(rune_color,0.40),1.5,true)
		for i in range(6): draw_circle(Vector2.from_angle(anim_t+i*TAU/6)*27+Vector2(0,-25),1.6,Color(rune_color,0.75))
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
	if burn_t>0:
		for point in [Vector2(-15,-12),Vector2(12,-34)]: DrawUtil.flame(self,point,20,7,anim_t)
	if chill_t>0:
		for i in range(6):
			var center: Vector2 = Vector2.from_angle(anim_t+i*TAU/6)*26+Vector2(0,-27)
			draw_line(center-Vector2(3,0),center+Vector2(3,0),Color("a3f0ff"),1.4,true)
			draw_line(center-Vector2(0,3),center+Vector2(0,3),Color("a3f0ff"),1.4,true)
	var state = get_node_or_null("/root/CartoonPlayerState")
	var level_color: Color = Difficulty.level_color(state.player_level if state!=null else 1,level)
	draw_string(ThemeDB.fallback_font,Vector2(-22,-dimensions.y-14),"Nv %d" % level,HORIZONTAL_ALIGNMENT_LEFT,70,12,Color("142b2b"))
	draw_string(ThemeDB.fallback_font,Vector2(-23,-dimensions.y-15),"Nv %d" % level,HORIZONTAL_ALIGNMENT_LEFT,70,12,level_color)
	if hp < max_hp:
		DrawUtil.bar(self,Vector2(-25,-dimensions.y-1),Vector2(50,6),float(hp)/float(max_hp),Color(0.82,0.18,0.18))
	if hit_flash > 0.0:
		DrawUtil.ellipse(self,Vector2.ZERO,30,36,Color(1,1,1,0.25))

func _draw_wolf() -> void:
	draw_texture_rect(Assets.texture("wolf"),Rect2(-47,-64,94,75),false)

func _draw_goblin() -> void:
	var skin: Color = Color(0.36,0.68,0.24)
	DrawUtil.ellipse_outlined(self,Vector2(0,-21),18,22,Color(0.44,0.24,0.14),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(0,-45),15,skin,DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-11,-49),Vector2(-28,-54),Vector2(-12,-40)]),skin,DrawUtil.OUTLINE,2.5)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(11,-49),Vector2(28,-54),Vector2(12,-40)]),skin,DrawUtil.OUTLINE,2.5)
	draw_circle(Vector2(-5,-46),2,Color(0.08,0.06,0.05))
	draw_circle(Vector2(5,-46),2,Color(0.08,0.06,0.05))
	DrawUtil.capsule_outlined(self,Vector2(15,-22),Vector2(27,-12),5,skin,DrawUtil.OUTLINE,2)
	draw_line(Vector2(26,-13),Vector2(36,-36),DrawUtil.OUTLINE,5)
	draw_line(Vector2(26,-13),Vector2(36,-36),Color(0.45,0.28,0.12),2.5)

func _draw_slime() -> void:
	var col: Color = Color(0.28,0.72,0.42,0.92)
	var pts: PackedVector2Array = PackedVector2Array([Vector2(-27,2),Vector2(-24,-19),Vector2(-14,-34),Vector2(0,-42),Vector2(16,-33),Vector2(25,-18),Vector2(28,2)])
	DrawUtil.poly_outlined(self,pts,col,DrawUtil.OUTLINE,3)
	DrawUtil.ellipse(self,Vector2(0,2),28,9,col.darkened(0.06))
	draw_circle(Vector2(-8,-20),3,Color(0.05,0.08,0.05))
	draw_circle(Vector2(8,-20),3,Color(0.05,0.08,0.05))
	DrawUtil.ellipse(self,Vector2(-10,-31),7,4,Color(0.85,1.0,0.88,0.35))

func _draw_guardian() -> void:
	draw_texture_rect(Assets.texture("guardian"),Rect2(-53,-105,106,117),false)

func _draw_root_beast() -> void:
	var bark: Color = Color(0.33,0.24,0.13)
	var moss: Color = Color(0.24,0.52,0.22)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),34,27,bark,DrawUtil.OUTLINE,4)
	DrawUtil.circle_outlined(self,Vector2(0,-58),24,bark.lightened(0.04),DrawUtil.OUTLINE,4)
	for x in [-30.0,30.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-35),Vector2(x*1.28,1),9,bark.darkened(0.06),DrawUtil.OUTLINE,3)
	for x in [-14.0,14.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-2),Vector2(x*1.22,19),11,bark.darkened(0.08),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-15,-72),Vector2(-27,-96),Vector2(-8,-82)]),bark,DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(15,-72),Vector2(27,-96),Vector2(8,-82)]),bark,DrawUtil.OUTLINE,3)
	for p in [Vector2(-18,-48),Vector2(18,-48),Vector2(0,-77),Vector2(-27,-16),Vector2(28,-17)]:
		DrawUtil.circle_outlined(self,p,10,moss,DrawUtil.OUTLINE,2)
	draw_circle(Vector2(-8,-59),3,Color(0.52,0.94,0.54))
	draw_circle(Vector2(8,-59),3,Color(0.52,0.94,0.54))
	DrawUtil.circle_outlined(self,Vector2(0,-34),8,Color(0.36,0.76,0.31),DrawUtil.OUTLINE,2)


func _draw_ash_general() -> void:
	var armor: Color = Color(0.29,0.27,0.27)
	var ember: Color = Color(0.92,0.28,0.10)
	DrawUtil.shadow(self,Vector2(0,13),38,0.28)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),34,28,armor,DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-25,-65,50,48),armor.lightened(0.04),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-24,-62),Vector2(-34,-84),Vector2(-14,-76),Vector2(0,-92),Vector2(14,-76),Vector2(34,-84),Vector2(24,-62)]),Color(0.38,0.31,0.28),DrawUtil.OUTLINE,3)
	for x in [-30.0,30.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-38),Vector2(x*1.25,-4),10,armor.darkened(0.05),DrawUtil.OUTLINE,3)
	for x in [-14.0,14.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-3),Vector2(x,18),11,armor.darkened(0.08),DrawUtil.OUTLINE,3)
	draw_circle(Vector2(-8,-51),3,ember)
	draw_circle(Vector2(8,-51),3,ember)
	DrawUtil.circle_outlined(self,Vector2(0,-28),9,ember,DrawUtil.OUTLINE,2)
	DrawUtil.flame(self,Vector2(-39,-17),23,8,anim_t)
	DrawUtil.flame(self,Vector2(39,-17),23,8,anim_t+0.7)


func _draw_reed_lady() -> void:
	var robe: Color = Color(0.24,0.42,0.24)
	var pale: Color = Color(0.68,0.78,0.61)
	DrawUtil.shadow(self,Vector2(0,12),38,0.26)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),30,30,robe,DrawUtil.OUTLINE,4)
	DrawUtil.circle_outlined(self,Vector2(0,-61),20,pale,DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-22,-68),Vector2(-38,-95),Vector2(-12,-79),Vector2(0,-103),Vector2(12,-79),Vector2(38,-95),Vector2(22,-68)]),Color(0.34,0.49,0.18),DrawUtil.OUTLINE,3)
	for x in [-27.0,27.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-37),Vector2(x*1.25,-4),9,robe.darkened(0.05),DrawUtil.OUTLINE,3)
	draw_circle(Vector2(-7,-62),3,Color(0.48,0.95,0.62))
	draw_circle(Vector2(7,-62),3,Color(0.48,0.95,0.62))
	DrawUtil.circle_outlined(self,Vector2(0,-31),8,Color(0.52,0.19,0.34),DrawUtil.OUTLINE,2)
	for p in [Vector2(-38,-18),Vector2(38,-18)]:
		DrawUtil.flame(self,p,18,7,anim_t)


func _draw_frost_captain() -> void:
	var armor: Color = Color(0.43,0.55,0.65)
	var ice: Color = Color(0.45,0.83,1.0)
	DrawUtil.shadow(self,Vector2(0,12),37,0.26)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),32,29,armor,DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-24,-67,48,50),armor.lightened(0.04),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-22,-64),Vector2(-13,-88),Vector2(0,-78),Vector2(13,-88),Vector2(22,-64)]),Color(0.28,0.39,0.50),DrawUtil.OUTLINE,3)
	for x in [-29.0,29.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-39),Vector2(x*1.22,-5),10,armor.darkened(0.05),DrawUtil.OUTLINE,3)
	draw_circle(Vector2(-7,-53),3,ice)
	draw_circle(Vector2(7,-53),3,ice)
	DrawUtil.circle_outlined(self,Vector2(0,-30),8,ice,DrawUtil.OUTLINE,2)

func _draw_black_frost_general() -> void:
	var armor: Color = Color(0.20,0.29,0.39)
	var frost: Color = Color(0.28,0.66,0.95)
	DrawUtil.shadow(self,Vector2(0,13),40,0.30)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),35,30,armor,DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-27,-70,54,53),armor.lightened(0.03),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-27,-67),Vector2(-38,-94),Vector2(-15,-82),Vector2(0,-104),Vector2(15,-82),Vector2(38,-94),Vector2(27,-67)]),Color(0.15,0.23,0.34),DrawUtil.OUTLINE,3)
	for x in [-32.0,32.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-41),Vector2(x*1.24,-4),10,armor.darkened(0.05),DrawUtil.OUTLINE,3)
	for x in [-14.0,14.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-2),Vector2(x,20),11,armor.darkened(0.08),DrawUtil.OUTLINE,3)
	draw_circle(Vector2(-8,-56),3,frost)
	draw_circle(Vector2(8,-56),3,frost)
	DrawUtil.circle_outlined(self,Vector2(0,-31),9,frost,DrawUtil.OUTLINE,2)
	for p in [Vector2(-40,-18),Vector2(40,-18)]:
		DrawUtil.flame(self,p,20,8,anim_t)


func _draw_tide_general() -> void:
	var armor: Color = Color(0.19,0.39,0.48)
	var tide: Color = Color(0.24,0.79,0.91)
	DrawUtil.shadow(self,Vector2(0,13),41,0.29)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),36,31,armor,DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-28,-71,56,54),armor.lightened(0.04),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-28,-69),Vector2(-42,-96),Vector2(-16,-83),Vector2(0,-107),Vector2(16,-83),Vector2(42,-96),Vector2(28,-69)]),Color(0.14,0.31,0.40),DrawUtil.OUTLINE,3)
	for x in [-33.0,33.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-42),Vector2(x*1.24,-4),10,armor.darkened(0.05),DrawUtil.OUTLINE,3)
	for x in [-14.0,14.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-2),Vector2(x,20),11,armor.darkened(0.08),DrawUtil.OUTLINE,3)
	draw_circle(Vector2(-8,-57),3,tide)
	draw_circle(Vector2(8,-57),3,tide)
	DrawUtil.circle_outlined(self,Vector2(0,-31),9,tide,DrawUtil.OUTLINE,2)
	for p in [Vector2(-42,-17),Vector2(42,-17)]:
		DrawUtil.circle_outlined(self,p,10,Color(0.27,0.68,0.82),DrawUtil.OUTLINE,2)


func _draw_void_general() -> void:
	var armor: Color = Color(0.22,0.18,0.25)
	var void_col: Color = Color(0.73,0.17,0.46)
	DrawUtil.shadow(self,Vector2(0,13),42,0.31)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),37,32,armor,DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-29,-73,58,56),armor.lightened(0.04),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-29,-70),Vector2(-44,-99),Vector2(-16,-86),Vector2(0,-111),Vector2(16,-86),Vector2(44,-99),Vector2(29,-70)]),Color(0.16,0.12,0.19),DrawUtil.OUTLINE,3)
	for x in [-34.0,34.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-43),Vector2(x*1.25,-4),11,armor.darkened(0.06),DrawUtil.OUTLINE,3)
	for x in [-14.0,14.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-2),Vector2(x,21),11,armor.darkened(0.08),DrawUtil.OUTLINE,3)
	draw_circle(Vector2(-8,-59),3,void_col)
	draw_circle(Vector2(8,-59),3,void_col)
	DrawUtil.circle_outlined(self,Vector2(0,-32),10,void_col,DrawUtil.OUTLINE,2)
	for p in [Vector2(-43,-18),Vector2(43,-18)]:
		DrawUtil.circle_outlined(self,p,11,Color(0.56,0.12,0.39),DrawUtil.OUTLINE,2)


func _draw_void_cartographer() -> void:
	var robe: Color = Color(0.25,0.18,0.32)
	var glyph: Color = Color(0.64,0.34,0.86)
	DrawUtil.shadow(self,Vector2(0,12),39,0.28)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),33,31,robe,DrawUtil.OUTLINE,4)
	DrawUtil.circle_outlined(self,Vector2(0,-61),20,Color(0.49,0.44,0.52),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-24,-68),Vector2(-38,-96),Vector2(-10,-82),Vector2(0,-106),Vector2(10,-82),Vector2(38,-96),Vector2(24,-68)]),robe.darkened(0.08),DrawUtil.OUTLINE,3)
	draw_circle(Vector2(-7,-61),3,glyph)
	draw_circle(Vector2(7,-61),3,glyph)
	DrawUtil.circle_outlined(self,Vector2(0,-31),9,glyph,DrawUtil.OUTLINE,2)
	for p in [Vector2(-40,-18),Vector2(40,-18)]:
		DrawUtil.circle_outlined(self,p,10,Color(0.55,0.23,0.78),DrawUtil.OUTLINE,2)

func _draw_azharel() -> void:
	var armor: Color = Color(0.16,0.10,0.18)
	var crown: Color = Color(0.73,0.12,0.40)
	DrawUtil.shadow(self,Vector2(0,14),46,0.34)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),40,34,armor,DrawUtil.OUTLINE,5)
	DrawUtil.rect_outlined(self,Rect2(-31,-79,62,61),armor.lightened(0.03),DrawUtil.OUTLINE,5)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-33,-76),Vector2(-50,-112),Vector2(-20,-96),Vector2(0,-128),Vector2(20,-96),Vector2(50,-112),Vector2(33,-76)]),crown.darkened(0.12),DrawUtil.OUTLINE,4)
	for x in [-37.0,37.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-46),Vector2(x*1.24,-4),12,armor.darkened(0.05),DrawUtil.OUTLINE,4)
	for x in [-16.0,16.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-2),Vector2(x,23),12,armor.darkened(0.08),DrawUtil.OUTLINE,4)
	draw_circle(Vector2(-9,-63),3,crown)
	draw_circle(Vector2(9,-63),3,crown)
	DrawUtil.circle_outlined(self,Vector2(0,-34),11,crown,DrawUtil.OUTLINE,3)
	for p in [Vector2(-47,-18),Vector2(47,-18)]:
		DrawUtil.flame(self,p,25,10,anim_t)
