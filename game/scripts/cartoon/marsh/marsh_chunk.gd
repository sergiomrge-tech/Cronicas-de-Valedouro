class_name ValedouroCartoonMarshChunk
extends Node2D

const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const Marsh = preload("res://scripts/cartoon/marsh/marsh_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/marsh/marsh_story_map.gd")

var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_seed: int = 0
var props_root: Node2D
var generated: bool = false

func setup(coord: Vector2i) -> void:
	chunk_coord = coord
	position = Vector2(coord.x*Marsh.CHUNK_SIZE,coord.y*Marsh.CHUNK_SIZE)
	chunk_seed = 470113 + coord.x*79133 + coord.y*53831
	props_root = Node2D.new()
	props_root.name = "MarshProps"
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
	var density: int = 30
	var northness: float = 1.0-(position.y+Marsh.CHUNK_SIZE*0.5)/Marsh.REGION_SIZE.y
	if northness > 0.55:
		density = 38
	for i in range(density):
		var local_pos: Vector2 = Vector2(
			rng.randf_range(45.0,Marsh.CHUNK_SIZE-45.0),
			rng.randf_range(58.0,Marsh.CHUNK_SIZE-35.0)
		)
		var world_pos: Vector2 = position+local_pos
		if _distance_to_route(world_pos) < 165.0:
			continue
		if _near_landmark(world_pos,430.0):
			continue
		var roll: float = rng.randf()
		var kind: String = "bush"
		if roll < 0.34:
			kind = "tree"
		elif roll < 0.48:
			kind = "rock"
		elif roll < 0.60:
			kind = "flowers"
		elif roll < 0.72:
			kind = "ruin"
		var prop: Node2D = PropScript.new()
		prop.setup({
			"kind":kind,
			"pos":local_pos,
			"scale":rng.randf_range(0.62,1.02) if kind != "ruin" else rng.randf_range(0.42,0.68),
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
	var northness: float = 1.0-(position.y+Marsh.CHUNK_SIZE*0.5)/Marsh.REGION_SIZE.y
	var bg: Color = Color(0.25,0.48,0.29)
	if northness > 0.45:
		bg = Color(0.20,0.40,0.27)
	if northness > 0.72:
		bg = Color(0.18,0.34,0.29)
	draw_rect(Rect2(Vector2.ZERO,Vector2(Marsh.CHUNK_SIZE,Marsh.CHUNK_SIZE)),bg)
	_draw_water_patches()
	_draw_ground_texture()
	_draw_story_route()

func _draw_water_patches() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed+311
	for i in range(8):
		var p: Vector2 = Vector2(
			rng.randf_range(70.0,Marsh.CHUNK_SIZE-70.0),
			rng.randf_range(70.0,Marsh.CHUNK_SIZE-70.0)
		)
		var rx: float = rng.randf_range(55.0,130.0)
		var ry: float = rng.randf_range(28.0,72.0)
		var col: Color = Color(0.18,0.40,0.44,0.50)
		DrawUtil.ellipse(self,p,rx,ry,col,24)

func _draw_ground_texture() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed+977
	for i in range(72):
		var p: Vector2 = Vector2(
			rng.randf_range(8.0,Marsh.CHUNK_SIZE-8.0),
			rng.randf_range(8.0,Marsh.CHUNK_SIZE-8.0)
		)
		var col: Color = Color(0.16,0.35,0.19,0.34) if i%2==0 else Color(0.42,0.63,0.30,0.18)
		draw_line(p,p+Vector2(rng.randf_range(-3.0,3.0),rng.randf_range(-12.0,-4.0)),col,1.5)

func _draw_story_route() -> void:
	var route: PackedVector2Array = StoryMap.route_points()
	for i in range(route.size()-1):
		var a_world: Vector2 = route[i]
		var b_world: Vector2 = route[i+1]
		var segment_rect: Rect2 = Rect2(a_world,b_world-a_world).abs().grow(180.0)
		var chunk_rect: Rect2 = Rect2(position,Vector2(Marsh.CHUNK_SIZE,Marsh.CHUNK_SIZE))
		if not segment_rect.intersects(chunk_rect):
			continue
		var a: Vector2 = a_world-position
		var b: Vector2 = b_world-position
		draw_line(a,b,Color(0.24,0.34,0.20),138.0,true)
		draw_line(a,b,Color(0.47,0.44,0.29),106.0,true)
		draw_line(a,b,Color(0.63,0.61,0.39,0.24),7.0,true)
