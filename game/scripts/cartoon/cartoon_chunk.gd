class_name ValedouroCartoonChunk
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Terrain = preload("res://scripts/cartoon/cartoon_terrain_art.gd")
const Landscape = preload("res://scripts/cartoon/cartoon_landscape_layout.gd")
const StoryMap = preload("res://scripts/cartoon/cartoon_main_story_map.gd")
const Exploration = preload("res://scripts/cartoon/cartoon_exploration_content.gd")

var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_seed: int = 0
var props_root: Node2D
var generated: bool = false
var visual_root: Node2D
var owned_props: Array[Node2D] = []

func setup(coord: Vector2i, sorted_root: Node2D = null) -> void:
	visual_root = sorted_root
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	chunk_coord = coord
	position = Vector2(coord.x * Region.CHUNK_SIZE, coord.y * Region.CHUNK_SIZE)
	chunk_seed = 20260930 + coord.x * 92821 + coord.y * 68917
	props_root = Node2D.new()
	props_root.name = "ChunkProps"
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
	var chunk_world_rect: Rect2 = Rect2(position, Vector2(Region.CHUNK_SIZE, Region.CHUNK_SIZE))
	if chunk_world_rect.intersects(Region.HUB_RECT.grow(120.0)):
		return
	var density: int = 45
	var center_dist: float = chunk_world_rect.get_center().distance_to(Region.REGION_SIZE * 0.5)
	var biome: String = _biome_kind()
	if center_dist > 5200.0:
		density = 58
	if biome == "wind_woods":
		density = 72
	elif biome == "alpha_forest":
		density = 90
	elif biome == "echo_hills":
		density = 54
	elif biome == "archive_highlands":
		density = 46
	var groves: Array[Vector2] = []
	for i in range(7):
		groves.append(Vector2(rng.randf_range(150,Region.CHUNK_SIZE-150),rng.randf_range(150,Region.CHUNK_SIZE-150)))
	for i in range(density):
		var local_pos: Vector2 = groves[i % groves.size()]+Vector2(rng.randf_range(-130,130),rng.randf_range(-110,110))
		var world_pos: Vector2 = position + local_pos
		if _near_main_road(world_pos,125.0) or _reserved_clearing(world_pos):
			continue
		var roll: float = rng.randf()
		var kind: String = _pick_prop_kind(biome,roll)
		var prop: Node2D = PropScript.new()
		prop.setup({
			"kind":kind,
			"pos":local_pos,
			"scale":rng.randf_range(0.62,1.08),
			"variant":rng.randi_range(0,3)
		})
		_add_visual(prop)
	if _is_field_belt():
		for i in range(8):
			var hay: Node2D = PropScript.new()
			hay.setup({
				"kind":"hay",
				"pos":Vector2(rng.randf_range(110.0,Region.CHUNK_SIZE-110.0),rng.randf_range(120.0,Region.CHUNK_SIZE-80.0)),
				"scale":rng.randf_range(0.65,0.9),
				"variant":i
			})
			if not _near_main_road(position+hay.position,125.0) and not _reserved_clearing(position+hay.position):
				_add_visual(hay)
			else:
				hay.free()

func _add_visual(prop: Node2D) -> void:
	if visual_root != null:
		prop.position += position
		visual_root.add_child(prop)
		owned_props.append(prop)
	else:
		props_root.add_child(prop)

func _exit_tree() -> void:
	# Streamed foliage shares the hero's y-sort layer; retire it with its chunk.
	for prop: Node2D in owned_props:
		if is_instance_valid(prop): prop.queue_free()
	owned_props.clear()

func _reserved_clearing(p: Vector2) -> bool:
	if Region.in_authored_hub(p,70.0) or Region.ROYAL_GROUNDS.grow(80).has_point(p): return true
	for zone: Dictionary in StoryMap.act1_zones():
		if p.distance_to(zone["pos"]) < float(zone["radius"])*0.90: return true
	for landmark: Dictionary in Exploration.landmarks():
		if p.distance_to(landmark["pos"]) < 145.0: return true
	return false

func _is_field_belt() -> bool:
	var y0: float = float(chunk_coord.y * Region.CHUNK_SIZE)
	return y0 > Region.HUB_RECT.end.y + 600.0 and y0 < Region.HUB_RECT.end.y + 3300.0 and absf(position.x + Region.CHUNK_SIZE * 0.5 - Region.SOUTH_ROAD_X) < 3600.0

func _biome_kind() -> String:
	var center_y: float = position.y + Region.CHUNK_SIZE * 0.5
	var north_edge: float = Region.HUB_RECT.position.y
	if center_y >= north_edge:
		return "south_or_hub"
	var depth: float = north_edge - center_y
	if depth < 1300.0:
		return "north_fields"
	if depth < 2550.0:
		return "wind_woods"
	if depth < 3650.0:
		return "alpha_forest"
	if depth < 4850.0:
		return "echo_hills"
	return "archive_highlands"

func _pick_prop_kind(biome: String, roll: float) -> String:
	if biome == "alpha_forest":
		if roll < 0.50:
			return "tree"
		if roll < 0.76:
			return "pine"
		if roll < 0.90:
			return "bush"
		return "rock"
	if biome == "echo_hills":
		if roll < 0.36:
			return "rock"
		if roll < 0.58:
			return "pine"
		if roll < 0.77:
			return "tree"
		if roll < 0.91:
			return "bush"
		return "flowers"
	if biome == "archive_highlands":
		if roll < 0.34:
			return "rock"
		if roll < 0.58:
			return "bush"
		if roll < 0.77:
			return "tree"
		return "flowers"
	if biome == "wind_woods":
		if roll < 0.42:
			return "tree"
		if roll < 0.66:
			return "pine"
		if roll < 0.84:
			return "bush"
		if roll < 0.94:
			return "rock"
		return "flowers"
	if roll < 0.28:
		return "pine"
	if roll < 0.47:
		return "bush"
	if roll < 0.63:
		return "rock"
	if roll < 0.76:
		return "flowers"
	return "tree"

func _near_main_road(world_pos: Vector2, margin: float) -> bool:
	return Landscape.near_road(world_pos,margin)

func _draw() -> void:
	var biome: String = _biome_kind()
	# One textured ground family keeps boundaries quieter than flat green blocks.
	var tint: Color = Color.WHITE
	if biome == "alpha_forest": tint = Color(0.80,0.91,0.86)
	elif biome == "wind_woods": tint = Color(0.91,0.98,0.92)
	elif biome == "echo_hills": tint = Color(0.92,0.95,0.95)
	elif biome == "archive_highlands": tint = Color(1.04,1.02,0.97)
	Terrain.grass(self,Rect2(Vector2.ZERO,Vector2(Region.CHUNK_SIZE,Region.CHUNK_SIZE)),tint)
	_draw_grass_texture()
	_draw_roads()
	_draw_field_rows()

func _draw_grass_texture() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed + 991
	for i in range(70):
		var p: Vector2 = Vector2(rng.randf_range(12.0,Region.CHUNK_SIZE-12.0),rng.randf_range(16.0,Region.CHUNK_SIZE-12.0))
		var col: Color = Color(0.32,0.61,0.24,0.32) if i % 2 == 0 else Color(0.56,0.79,0.34,0.22)
		draw_line(p,p+Vector2(rng.randf_range(-2.0,2.0),rng.randf_range(-8.0,-4.0)),col,1.5)

func _draw_roads() -> void:
	for road: Dictionary in Landscape.roads():
		var a: Vector2 = road["a"]-position
		var b: Vector2 = road["b"]-position
		var width: float = float(road["width"])
		if is_equal_approx(a.x,b.x):
			if a.x < -width or a.x > Region.CHUNK_SIZE+width: continue
			var top: float = maxf(0.0,minf(a.y,b.y))
			var bottom: float = minf(Region.CHUNK_SIZE,maxf(a.y,b.y))
			if bottom <= top: continue
			a.y = top; b.y = bottom
		else:
			if a.y < -width or a.y > Region.CHUNK_SIZE+width: continue
			var left: float = maxf(0.0,minf(a.x,b.x))
			var right: float = minf(Region.CHUNK_SIZE,maxf(a.x,b.x))
			if right <= left: continue
			a.x = left; b.x = right
		Terrain.path(self,PackedVector2Array([a,b]),width,false,chunk_seed)

func _draw_field_rows() -> void:
	if not _is_field_belt():
		return
	var left_of_road: bool = position.x + Region.CHUNK_SIZE * 0.5 < Region.SOUTH_ROAD_X
	var x_start: float = 80.0 if left_of_road else 120.0
	var x_end: float = Region.CHUNK_SIZE - 80.0
	for y in range(120,Region.CHUNK_SIZE-80,56):
		draw_line(Vector2(x_start,y),Vector2(x_end,y),Color(0.36,0.50,0.18,0.48),3.0)
