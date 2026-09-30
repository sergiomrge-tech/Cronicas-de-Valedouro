class_name ValedouroCartoonForestChunk
extends Node2D

const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const Forest = preload("res://scripts/cartoon/forest/forest_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/forest/forest_story_map.gd")

var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_seed: int = 0
var props_root: Node2D
var generated: bool = false

func setup(coord: Vector2i) -> void:
	chunk_coord = coord
	position = Vector2(coord.x*Forest.CHUNK_SIZE,coord.y*Forest.CHUNK_SIZE)
	chunk_seed = 260902 + coord.x*61583 + coord.y*92761
	props_root = Node2D.new()
	props_root.name = "ForestProps"
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
	var density: int = _density_for_band()
	for i in range(density):
		var local_pos: Vector2 = Vector2(
			rng.randf_range(42.0,Forest.CHUNK_SIZE-42.0),
			rng.randf_range(58.0,Forest.CHUNK_SIZE-30.0)
		)
		var world_pos: Vector2 = position+local_pos
		if _distance_to_story_route(world_pos) < 175.0:
			continue
		if _near_landmark(world_pos,420.0):
			continue
		var kind: String = _pick_kind(rng.randf())
		var prop: Node2D = PropScript.new()
		prop.setup({
			"kind":kind,
			"pos":local_pos,
			"scale":rng.randf_range(0.72,1.18),
			"variant":rng.randi_range(0,3)
		})
		props_root.add_child(prop)

func _density_for_band() -> int:
	var center: Vector2 = position+Vector2(Forest.CHUNK_SIZE*0.5,Forest.CHUNK_SIZE*0.5)
	var t: float = 1.0-center.y/Forest.REGION_SIZE.y
	if t < 0.18:
		return 28
	if t < 0.42:
		return 39
	if t < 0.68:
		return 48
	if t < 0.86:
		return 42
	return 34

func _pick_kind(roll: float) -> String:
	var center_y: float = position.y+Forest.CHUNK_SIZE*0.5
	var t: float = 1.0-center_y/Forest.REGION_SIZE.y
	if t > 0.60:
		if roll < 0.40:
			return "pine"
		if roll < 0.72:
			return "tree"
		if roll < 0.86:
			return "rock"
		if roll < 0.95:
			return "bush"
		return "flowers"
	if roll < 0.51:
		return "tree"
	if roll < 0.69:
		return "pine"
	if roll < 0.84:
		return "bush"
	if roll < 0.94:
		return "rock"
	return "flowers"

func _distance_to_story_route(world_pos: Vector2) -> float:
	var route: PackedVector2Array = StoryMap.route_points()
	var best: float = 999999.0
	for i in range(route.size()-1):
		var a: Vector2 = route[i]
		var b: Vector2 = route[i+1]
		var ab: Vector2 = b-a
		var denom: float = maxf(ab.length_squared(),0.001)
		var t: float = clampf((world_pos-a).dot(ab)/denom,0.0,1.0)
		best = minf(best,world_pos.distance_to(a+ab*t))
	return best

func _near_landmark(world_pos: Vector2, extra: float) -> bool:
	for row in StoryMap.locations():
		var pos: Vector2 = row.get("pos",Vector2.ZERO)
		var radius: float = float(row.get("radius",300.0))+extra
		if world_pos.distance_to(pos) < radius:
			return true
	for row in StoryMap.root_subshrines():
		var pos: Vector2 = row.get("pos",Vector2.ZERO)
		if world_pos.distance_to(pos) < 360.0+extra:
			return true
	return false

func _draw() -> void:
	var center_y: float = position.y+Forest.CHUNK_SIZE*0.5
	var t: float = 1.0-center_y/Forest.REGION_SIZE.y
	var bg: Color = Color(0.31,0.61,0.25)
	if t > 0.42:
		bg = Color(0.25,0.53,0.24)
	if t > 0.70:
		bg = Color(0.23,0.47,0.27)
	draw_rect(Rect2(Vector2.ZERO,Vector2(Forest.CHUNK_SIZE,Forest.CHUNK_SIZE)),bg)
	_draw_ground_texture()
	_draw_story_route()

func _draw_ground_texture() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed+777
	for i in range(90):
		var p: Vector2 = Vector2(
			rng.randf_range(8.0,Forest.CHUNK_SIZE-8.0),
			rng.randf_range(8.0,Forest.CHUNK_SIZE-8.0)
		)
		var col: Color = Color(0.17,0.43,0.21,0.30) if i%2==0 else Color(0.54,0.76,0.32,0.18)
		draw_line(p,p+Vector2(rng.randf_range(-2.0,2.0),rng.randf_range(-10.0,-4.0)),col,1.5)

func _draw_story_route() -> void:
	var route: PackedVector2Array = StoryMap.route_points()
	for i in range(route.size()-1):
		var a_world: Vector2 = route[i]
		var b_world: Vector2 = route[i+1]
		var segment_rect: Rect2 = Rect2(a_world,b_world-a_world).abs().grow(180.0)
		var chunk_rect: Rect2 = Rect2(position,Vector2(Forest.CHUNK_SIZE,Forest.CHUNK_SIZE))
		if not segment_rect.intersects(chunk_rect):
			continue
		var a: Vector2 = a_world-position
		var b: Vector2 = b_world-position
		draw_line(a,b,Color(0.36,0.48,0.22),132.0,true)
		draw_line(a,b,Color(0.66,0.57,0.37),102.0,true)
		draw_line(a,b,Color(0.78,0.70,0.48,0.32),7.0,true)
