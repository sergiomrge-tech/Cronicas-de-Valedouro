class_name ValedouroCartoonFrostChunk
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const Frost = preload("res://scripts/cartoon/frost/frost_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/frost/frost_story_map.gd")

var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_seed: int = 0
var props_root: Node2D
var generated: bool = false

func setup(coord: Vector2i) -> void:
	chunk_coord = coord
	position = Vector2(coord.x*Frost.CHUNK_SIZE,coord.y*Frost.CHUNK_SIZE)
	chunk_seed = 510717 + coord.x*63839 + coord.y*88469
	props_root = Node2D.new()
	props_root.name = "FrostProps"
	props_root.y_sort_enabled = true
	add_child(props_root)
	_generate()
	queue_redraw()

func _generate() -> void:
	if generated:
		return
	generated = true
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed
	var density: int = 27
	var northness: float = 1.0-(position.y+Frost.CHUNK_SIZE*0.5)/Frost.REGION_SIZE.y
	if northness > 0.55:
		density = 34
	for i in range(density):
		var local_pos: Vector2 = Vector2(rng.randf_range(45.0,Frost.CHUNK_SIZE-45.0),rng.randf_range(58.0,Frost.CHUNK_SIZE-35.0))
		var world_pos: Vector2 = position+local_pos
		if _distance_to_route(world_pos) < 170.0:
			continue
		if _near_landmark(world_pos,430.0):
			continue
		var roll: float = rng.randf()
		var kind: String = "pine"
		if roll < 0.26:
			kind = "rock"
		elif roll < 0.38:
			kind = "bush"
		elif roll < 0.45:
			kind = "ruin"
		var prop: Node2D = PropScript.new()
		prop.setup({"kind":kind,"pos":local_pos,"scale":rng.randf_range(0.60,1.02) if kind!="ruin" else rng.randf_range(0.42,0.68),"variant":rng.randi_range(0,3)})
		props_root.add_child(prop)

func _distance_to_route(world_pos: Vector2) -> float:
	var route: PackedVector2Array = StoryMap.route_points()
	var best: float = 999999.0
	for i in range(route.size()-1):
		var a: Vector2 = route[i]
		var b: Vector2 = route[i+1]
		var ab: Vector2 = b-a
		var t: float = clampf((world_pos-a).dot(ab)/maxf(ab.length_squared(),0.001),0.0,1.0)
		best = minf(best,world_pos.distance_to(a+ab*t))
	return best

func _near_landmark(world_pos: Vector2, extra: float) -> bool:
	for row in StoryMap.locations():
		if world_pos.distance_to(row.get("pos",Vector2.ZERO)) < float(row.get("radius",400.0))+extra:
			return true
	return false

func _draw() -> void:
	var northness: float = 1.0-(position.y+Frost.CHUNK_SIZE*0.5)/Frost.REGION_SIZE.y
	var bg: Color = Color(0.78,0.86,0.91)
	if northness > 0.45:
		bg = Color(0.69,0.80,0.87)
	if northness > 0.72:
		bg = Color(0.57,0.69,0.78)
	draw_rect(Rect2(Vector2.ZERO,Vector2(Frost.CHUNK_SIZE,Frost.CHUNK_SIZE)),bg)
	_draw_snow_texture()
	_draw_story_route()

func _draw_snow_texture() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed+313
	for i in range(68):
		var p: Vector2 = Vector2(rng.randf_range(8.0,Frost.CHUNK_SIZE-8.0),rng.randf_range(8.0,Frost.CHUNK_SIZE-8.0))
		draw_line(p,p+Vector2(rng.randf_range(6.0,22.0),rng.randf_range(-2.0,2.0)),Color(1.0,1.0,1.0,0.22),1.5)

func _draw_story_route() -> void:
	var route: PackedVector2Array = StoryMap.route_points()
	for i in range(route.size()-1):
		var a_world: Vector2 = route[i]
		var b_world: Vector2 = route[i+1]
		var segment_rect: Rect2 = Rect2(a_world,b_world-a_world).abs().grow(180.0)
		var chunk_rect: Rect2 = Rect2(position,Vector2(Frost.CHUNK_SIZE,Frost.CHUNK_SIZE))
		if not segment_rect.intersects(chunk_rect):
			continue
		var a: Vector2 = a_world-position
		var b: Vector2 = b_world-position
		draw_line(a,b,Color(0.47,0.58,0.65),136.0,true)
		draw_line(a,b,Color(0.83,0.87,0.87),104.0,true)
		draw_line(a,b,Color(1.0,1.0,1.0,0.35),7.0,true)
