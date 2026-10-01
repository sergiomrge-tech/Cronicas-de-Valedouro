extends Node2D
const Assets = preload("res://scripts/cartoon/cartoon_living_assets.gd")
const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
var director
var slot_id: String
var kind: String
var home: Vector2
var hp: int
var max_hp: int
var dead: bool = false
var provoked: bool = false
var direction: Vector2 = Vector2.ZERO
var destination: Vector2
var clock: float = 0.0
var cooldown: float = 0.0
var wander_time: float = 0.0
var chill_t: float = 0.0
var burn_t: float = 0.0
var hit_flash: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
func setup(manager, data: Dictionary) -> void:
	director = manager
	slot_id = data.id
	kind = data.kind
	home = data.pos
	position = home
	destination = home
	max_hp = 22 if kind == "rabbit" else (38 if kind == "deer" else 58)
	hp = max_hp
	rng.seed = hash(slot_id)
	clock = rng.randf_range(0,10)
func apply_chill(duration: float) -> void:
	chill_t = maxf(chill_t,duration)
	queue_redraw()

func _process(delta: float) -> void:
	if dead or director.blocked():
		direction = Vector2.ZERO
		return
	chill_t = maxf(0,chill_t-delta)
	clock += delta
	cooldown = maxf(0,cooldown-delta)
	hit_flash = maxf(0,hit_flash-delta)
	wander_time -= delta
	var hero = director.host.hero
	var distance: float = position.distance_to(hero.position)
	var speed: float = 35.0 if kind == "rabbit" else 42.0
	if kind == "boar" and provoked and distance < 320:
		direction = (hero.position-position).normalized()
		speed = 115
		if distance < 48 and cooldown <= 0:
			cooldown = 1.0
			director.damage_player(8)
	elif distance < (200.0 if provoked else 110.0):
		direction = (position-hero.position).normalized()
		speed = 185 if kind == "rabbit" else 170
	else:
		if wander_time <= 0:
			wander_time = rng.randf_range(2.5,5)
			destination = home+Vector2(rng.randf_range(-140,140),rng.randf_range(-140,140))
		direction = (destination-position).normalized() if position.distance_to(destination)>12 else Vector2.ZERO
	if chill_t>0: speed *= 0.55
	var next: Vector2 = position+direction*speed*delta
	if director.walkable(next): position = next
	else:
		direction = Vector2.ZERO
		wander_time = 0
	queue_redraw()
func take_damage(amount: int) -> bool:
	if dead: return false
	preload("res://scripts/cartoon/cartoon_combat_fx.gd").spawn(get_parent(),position+Vector2(0,-22),"hit",Vector2.UP,Color("ffd79a"),mini(amount,hp))
	provoked = true
	hit_flash = 0.15
	hp = maxi(0,hp-amount)
	if hp <= 0:
		dead = true
		director.harvest(self)
		return true
	queue_redraw()
	return false
func _draw() -> void:
	var moving: bool = direction.length()>0.1
	var key: String = "animal_"+kind+("_walk" if moving and sin(clock*9)>0 else "")
	var bob: float = absf(sin(clock*9))*2 if moving else sin(clock*2)*0.7
	var size_v: Vector2 = Vector2(54,42) if kind == "rabbit" else (Vector2(100,77) if kind == "deer" else Vector2(105,81))
	draw_set_transform(Vector2(0,-bob),0,Vector2(-1,1) if direction.x < -0.1 else Vector2.ONE)
	draw_texture_rect(Assets.texture(key),Rect2(Vector2(-size_v.x/2,-size_v.y+10),size_v),false)
	draw_set_transform(Vector2.ZERO)
	if burn_t>0: DrawUtil.flame(self,Vector2(0,-18),15,6,clock)
	if chill_t>0: draw_arc(Vector2(0,-15),20,clock,clock+PI*1.7,32,Color("a3f0ff"),1.5,true)
	if hp < max_hp: DrawUtil.bar(self,Vector2(-24,-size_v.y-3),Vector2(48,5),float(hp)/max_hp,Color("b97b5a"))
	if hit_flash > 0: draw_circle(Vector2(0,-25),23,Color(1,0.95,0.8,0.28))
