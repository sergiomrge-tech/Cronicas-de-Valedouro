class_name ValedouroCartoonCoastChunk
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const Coast = preload("res://scripts/cartoon/coast/coast_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/coast/coast_story_map.gd")

var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_seed: int = 0
var props_root: Node2D
var generated: bool = false

func setup(coord: Vector2i) -> void:
	chunk_coord = coord
	position = Vector2(coord.x*Coast.CHUNK_SIZE,coord.y*Coast.CHUNK_SIZE)
	chunk_seed = 660811 + coord.x*73973 + coord.y*55763
	props_root = Node2D.new()
	props_root.name = "CoastProps"
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
	var density: int = 25
	var northness: float = 1.0-(position.y+Coast.CHUNK_SIZE*0.5)/Coast.REGION_SIZE.y
	if northness > 0.52:
		density = 31
	for i in range(density):
		var local_pos: Vector2 = Vector2(rng.randf_range(45.0,Coast.CHUNK_SIZE-45.0),rng.randf_range(58.0,Coast.CHUNK_SIZE-35.0))
		var world_pos: Vector2 = position+local_pos
		if _distance_to_route(world_pos) < 175.0:
			continue
		if _near_landmark(world_pos,450.0):
			continue
		var roll: float = rng.randf()
		var kind: String = "rock"
		if roll < 0.30:
			kind = "tree"
		elif roll < 0.48:
			kind = "bush"
		elif roll < 0.58:
			kind = "flowers"
		elif roll < 0.68:
			kind = "ruin"
		var prop: Node2D = PropScript.new()
		prop.setup({"kind":kind,"pos":local_pos,"scale":rng.randf_range(0.58,1.0) if kind!="ruin" else rng.randf_range(0.42,0.68),"variant":rng.randi_range(0,3)})
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
	var northness: float = 1.0-(position.y+Coast.CHUNK_SIZE*0.5)/Coast.REGION_SIZE.y
	var bg: Color = Color(0.35,0.66,0.55)
	if northness > 0.45:
		bg = Color(0.29,0.58,0.55)
	if northness > 0.70:
		bg = Color(0.25,0.50,0.55)
	draw_rect(Rect2(Vector2.ZERO,Vector2(Coast.CHUNK_SIZE,Coast.CHUNK_SIZE)),bg)
	_draw_water_patches()
	_draw_ground_texture()
	_draw_story_route()

func _draw_water_patches() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed+517
	for i in range(6):
		var p: Vector2 = Vector2(rng.randf_range(80.0,Coast.CHUNK_SIZE-80.0),rng.randf_range(80.0,Coast.CHUNK_SIZE-80.0))
		DrawUtil.ellipse(self,p,rng.randf_range(70.0,150.0),rng.randf_range(32.0,80.0),Color(0.20,0.53,0.66,0.42),24)

func _draw_ground_texture() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed+917
	for i in range(62):
		var p: Vector2 = Vector2(rng.randf_range(8.0,Coast.CHUNK_SIZE-8.0),rng.randf_range(8.0,Coast.CHUNK_SIZE-8.0))
		draw_line(p,p+Vector2(rng.randf_range(-3.0,3.0),rng.randf_range(-10.0,-4.0)),Color(0.19,0.44,0.35,0.27),1.5)

func _draw_story_route() -> void:
	var route: PackedVector2Array = StoryMap.route_points()
	for i in range(route.size()-1):
		var a_world: Vector2 = route[i]
		var b_world: Vector2 = route[i+1]
		var segment_rect: Rect2 = Rect2(a_world,b_world-a_world).abs().grow(180.0)
		var chunk_rect: Rect2 = Rect2(position,Vector2(Coast.CHUNK_SIZE,Coast.CHUNK_SIZE))
		if not segment_rect.intersects(chunk_rect):
			continue
		var a: Vector2 = a_world-position
		var b: Vector2 = b_world-position
		draw_line(a,b,Color(0.28,0.43,0.33),138.0,true)
		draw_line(a,b,Color(0.66,0.59,0.38),106.0,true)
		draw_line(a,b,Color(0.84,0.78,0.52,0.28),7.0,true)
