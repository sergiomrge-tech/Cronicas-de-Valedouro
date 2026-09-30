class_name ValedouroCartoonCorruptedChunk
extends Node2D

const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const Corrupted = preload("res://scripts/cartoon/corrupted/corrupted_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/corrupted/corrupted_story_map.gd")

var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_seed: int = 0
var props_root: Node2D
var generated: bool = false

func setup(coord: Vector2i) -> void:
	chunk_coord = coord
	position = Vector2(coord.x*Corrupted.CHUNK_SIZE,coord.y*Corrupted.CHUNK_SIZE)
	chunk_seed = 771019 + coord.x*68543 + coord.y*92347
	props_root = Node2D.new()
	props_root.name = "CorruptedProps"
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
	var density: int = 28
	var northness: float = 1.0-(position.y+Corrupted.CHUNK_SIZE*0.5)/Corrupted.REGION_SIZE.y
	if northness > 0.55:
		density = 36
	for i in range(density):
		var local_pos: Vector2 = Vector2(rng.randf_range(45.0,Corrupted.CHUNK_SIZE-45.0),rng.randf_range(58.0,Corrupted.CHUNK_SIZE-35.0))
		var world_pos: Vector2 = position+local_pos
		if _distance_to_route(world_pos) < 175.0:
			continue
		if _near_landmark(world_pos,470.0):
			continue
		var roll: float = rng.randf()
		var kind: String = "rock"
		if roll < 0.24:
			kind = "tree"
		elif roll < 0.43:
			kind = "ruin"
		elif roll < 0.57:
			kind = "bush"
		elif roll < 0.66:
			kind = "shrine"
		var prop: Node2D = PropScript.new()
		prop.setup({"kind":kind,"pos":local_pos,"scale":rng.randf_range(0.55,0.95) if kind!="ruin" else rng.randf_range(0.42,0.68),"variant":rng.randi_range(0,3)})
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
	for row in StoryMap.obelisks():
		if world_pos.distance_to(row.get("pos",Vector2.ZERO)) < 380.0+extra:
			return true
	return false

func _draw() -> void:
	var northness: float = 1.0-(position.y+Corrupted.CHUNK_SIZE*0.5)/Corrupted.REGION_SIZE.y
	var bg: Color = Color(0.34,0.34,0.29)
	if northness > 0.45:
		bg = Color(0.29,0.27,0.28)
	if northness > 0.70:
		bg = Color(0.23,0.19,0.24)
	draw_rect(Rect2(Vector2.ZERO,Vector2(Corrupted.CHUNK_SIZE,Corrupted.CHUNK_SIZE)),bg)
	_draw_cracks()
	_draw_story_route()

func _draw_cracks() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed+707
	for i in range(40):
		var p: Vector2 = Vector2(rng.randf_range(20.0,Corrupted.CHUNK_SIZE-20.0),rng.randf_range(20.0,Corrupted.CHUNK_SIZE-20.0))
		var q: Vector2 = p+Vector2(rng.randf_range(-28.0,28.0),rng.randf_range(-18.0,18.0))
		draw_line(p,q,Color(0.49,0.15,0.31,0.24),2.0)

func _draw_story_route() -> void:
	var route: PackedVector2Array = StoryMap.route_points()
	for i in range(route.size()-1):
		var a_world: Vector2 = route[i]
		var b_world: Vector2 = route[i+1]
		var segment_rect: Rect2 = Rect2(a_world,b_world-a_world).abs().grow(180.0)
		var chunk_rect: Rect2 = Rect2(position,Vector2(Corrupted.CHUNK_SIZE,Corrupted.CHUNK_SIZE))
		if not segment_rect.intersects(chunk_rect):
			continue
		var a: Vector2 = a_world-position
		var b: Vector2 = b_world-position
		draw_line(a,b,Color(0.23,0.19,0.19),140.0,true)
		draw_line(a,b,Color(0.49,0.42,0.34),106.0,true)
		draw_line(a,b,Color(0.66,0.52,0.42,0.24),7.0,true)
