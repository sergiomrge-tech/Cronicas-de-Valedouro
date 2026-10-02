extends Node2D
const Person = preload("res://scripts/cartoon/cartoon_town_person_v041.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
var host
var layout
var people: Array[Dictionary] = []
var clock: float = 0
const DOORS: Array[Vector2] = [Vector2(720,812),Vector2(1580,822),Vector2(760,1150)]
func setup(owner_node) -> void:
	host = owner_node
	layout = host.get_node("HUD/GameLayout")
	z_index = 0
	var routes: Array = [
		[Vector2(950,900),Vector2(990,1020),"patron"],
		[Vector2(1210,1090),Vector2(1380,1020),"ranger"],
		[Vector2(1660,910),Vector2(1510,980),"innkeeper"],
		[Vector2(640,960),Vector2(735,950),"smith"],
		[Vector2(875,1130),Vector2(975,1200),"clerk"],
		[Vector2(520,610),Vector2(660,625),"patron"],
		[Vector2(1630,615),Vector2(1780,665),"ranger"],
		[Vector2(984,745),Vector2(984,745),"merchant"]]
	for row in routes:
		var sprite = Person.new()
		sprite.setup(String(row[2]))
		sprite.position = Region.world_from_hub(row[0])
		host.objects.add_child(sprite)
		people.append({"sprite":sprite,"a":Region.world_from_hub(row[0]),"b":Region.world_from_hub(row[1]),"to_b":true,"wait":0.0})
func _process(delta: float) -> void:
	if host == null: return
	var blocked: bool = host.interiors.active or layout.is_blocked()
	for person in people:
		var sprite = person.sprite
		if blocked:
			sprite.pause()
			continue
		if not sprite.is_playing(): sprite.play()
		person.wait = maxf(0,float(person.wait)-delta)
		var target: Vector2 = person.b if person.to_b else person.a
		var next: Vector2 = sprite.position.move_toward(target,26*delta)
		var moving: bool = person.wait<=0 and sprite.position.distance_to(next)>0.01 and host.environment.is_walkable(next)
		sprite.set_walking(moving,target.x<sprite.position.x)
		if moving: sprite.position = next
		if person.wait<=0 and (sprite.position.distance_to(target)<5 or not moving):
			person.to_b = not person.to_b
			person.wait = 1.5
	if blocked: return
	clock += delta
	queue_redraw()
func _draw() -> void:
	if host == null: return
	draw_set_transform(Region.HUB_ORIGIN)
	# Warm service windows, rising forge smoke and the guild's hanging pennant.
	for p in DOORS:
		for radius in range(4): draw_circle(p+Vector2(0,-75),float(35-radius*8),Color(1,0.75,0.32,0.018))
		var shimmer: float = sin(clock*2+p.x)*2
		draw_polyline(PackedVector2Array([p+Vector2(-7,-3+shimmer),p+Vector2(0,-9+shimmer),p+Vector2(7,-3+shimmer)]),Color("e9c882"),2,true)
	for i in range(7):
		var phase: float = fmod(clock*0.18+float(i)/7,1)
		var p: Vector2 = Vector2(759+sin(phase*7+i)*13,640-phase*105)
		draw_circle(p,7+phase*11,Color(0.74,0.76,0.65,(1-phase)*0.085))
	var flag: Vector2 = Vector2(826,1050)
	var sway: float = sin(clock*2)*3
	draw_line(flag,flag+Vector2(0,55),Color("403c32"),3)
	draw_colored_polygon(PackedVector2Array([flag+Vector2(2,2),flag+Vector2(29+sway,4),flag+Vector2(25+sway,31),flag+Vector2(15,38),flag+Vector2(2,29)]),Color("4f7689"))
	draw_circle(flag+Vector2(14,16),4,Color("d8b96c"))
	draw_set_transform(Vector2.ZERO)
