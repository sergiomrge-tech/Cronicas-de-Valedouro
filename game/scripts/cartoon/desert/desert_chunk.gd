class_name ValedouroCartoonDesertChunk
extends Node2D

const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const Desert = preload("res://scripts/cartoon/desert/desert_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/desert/desert_story_map.gd")

var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_seed: int = 0
var props_root: Node2D
var generated: bool = false

func setup(coord: Vector2i) -> void:
	chunk_coord = coord
	position = Vector2(coord.x*Desert.CHUNK_SIZE,coord.y*Desert.CHUNK_SIZE)
	chunk_seed = 360921 + coord.x*71549 + coord.y*49123
	props_root = Node2D.new()
	props_root.name = "DesertProps"
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
	var density: int = 22
	var eastness: float = (position.x+Desert.CHUNK_SIZE*0.5)/Desert.REGION_SIZE.x
	if eastness > 0.65:
		density = 30
	for i in range(density):
		var local_pos: Vector2 = Vector2(
			rng.randf_range(45.0,Desert.CHUNK_SIZE-45.0),
			rng.randf_range(55.0,Desert.CHUNK_SIZE-35.0)
		)
		var world_pos: Vector2 = position+local_pos
		if _distance_to_route(world_pos) < 155.0:
			continue
		if _near_landmark(world_pos,420.0):
			continue
		var roll: float = rng.randf()
		var kind: String = "rock"
		if roll < 0.18:
			kind = "bush"
		elif roll < 0.25:
			kind = "ruin"
		elif roll < 0.32:
			kind = "sign"
		var prop: Node2D = PropScript.new()
		prop.setup({
			"kind":kind,
			"pos":local_pos,
			"scale":rng.randf_range(0.58,0.98) if kind != "ruin" else rng.randf_range(0.45,0.72),
			"variant":rng.randi_range(0,3)
		})
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
		var pos: Vector2 = row.get("pos",Vector2.ZERO)
		if world_pos.distance_to(pos) < float(row.get("radius",400.0))+extra:
			return true
	return false

func _draw() -> void:
	var eastness: float = (position.x+Desert.CHUNK_SIZE*0.5)/Desert.REGION_SIZE.x
	var northness: float = 1.0-(position.y+Desert.CHUNK_SIZE*0.5)/Desert.REGION_SIZE.y
	var bg: Color = Color(0.78,0.64,0.36)
	if eastness > 0.48:
		bg = Color(0.72,0.56,0.31)
	if northness > 0.66:
		bg = Color(0.59,0.47,0.34)
	draw_rect(Rect2(Vector2.ZERO,Vector2(Desert.CHUNK_SIZE,Desert.CHUNK_SIZE)),bg)
	_draw_sand_texture()
	_draw_story_route()

func _draw_sand_texture() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed+191
	for i in range(64):
		var p: Vector2 = Vector2(
			rng.randf_range(10.0,Desert.CHUNK_SIZE-10.0),
			rng.randf_range(10.0,Desert.CHUNK_SIZE-10.0)
		)
		var len: float = rng.randf_range(12.0,38.0)
		draw_line(p,p+Vector2(len,rng.randf_range(-3.0,3.0)),Color(0.92,0.78,0.48,0.20),1.5)

func _draw_story_route() -> void:
	var route: PackedVector2Array = StoryMap.route_points()
	for i in range(route.size()-1):
		var a_world: Vector2 = route[i]
		var b_world: Vector2 = route[i+1]
		var segment_rect: Rect2 = Rect2(a_world,b_world-a_world).abs().grow(170.0)
		var chunk_rect: Rect2 = Rect2(position,Vector2(Desert.CHUNK_SIZE,Desert.CHUNK_SIZE))
		if not segment_rect.intersects(chunk_rect):
			continue
		var a: Vector2 = a_world-position
		var b: Vector2 = b_world-position
		draw_line(a,b,Color(0.57,0.43,0.24),130.0,true)
		draw_line(a,b,Color(0.84,0.70,0.43),102.0,true)
		draw_line(a,b,Color(0.98,0.84,0.55,0.28),6.0,true)
