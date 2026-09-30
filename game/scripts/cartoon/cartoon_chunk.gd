class_name ValedouroCartoonChunk
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")

var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_seed: int = 0
var props_root: Node2D
var generated: bool = false

func setup(coord: Vector2i) -> void:
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
	var density: int = 25
	var center_dist: float = chunk_world_rect.get_center().distance_to(Region.REGION_SIZE * 0.5)
	if center_dist > 5200.0:
		density = 34
	for i in range(density):
		var local_pos: Vector2 = Vector2(rng.randf_range(48.0,Region.CHUNK_SIZE-48.0),rng.randf_range(62.0,Region.CHUNK_SIZE-36.0))
		var world_pos: Vector2 = position + local_pos
		if _near_main_road(world_pos,115.0):
			continue
		var roll: float = rng.randf()
		var kind: String = "tree"
		var radius: float = 28.0
		if roll < 0.28:
			kind = "pine"
		elif roll < 0.47:
			kind = "bush"
			radius = 17.0
		elif roll < 0.63:
			kind = "rock"
			radius = 16.0
		elif roll < 0.76:
			kind = "flowers"
			radius = 0.0
		var prop: Node2D = PropScript.new()
		prop.setup({
			"kind":kind,
			"pos":local_pos,
			"scale":rng.randf_range(0.62,1.08),
			"variant":rng.randi_range(0,3)
		})
		props_root.add_child(prop)
	if _is_field_belt():
		for i in range(8):
			var hay: Node2D = PropScript.new()
			hay.setup({
				"kind":"hay",
				"pos":Vector2(rng.randf_range(110.0,Region.CHUNK_SIZE-110.0),rng.randf_range(120.0,Region.CHUNK_SIZE-80.0)),
				"scale":rng.randf_range(0.65,0.9),
				"variant":i
			})
			props_root.add_child(hay)

func _is_field_belt() -> bool:
	var y0: float = float(chunk_coord.y * Region.CHUNK_SIZE)
	return y0 > Region.HUB_RECT.end.y + 600.0 and y0 < Region.HUB_RECT.end.y + 3300.0 and absf(position.x + Region.CHUNK_SIZE * 0.5 - Region.SOUTH_ROAD_X) < 3600.0

func _near_main_road(world_pos: Vector2, margin: float) -> bool:
	if world_pos.y >= Region.HUB_RECT.end.y - 80.0:
		if absf(world_pos.x - Region.SOUTH_ROAD_X) < margin:
			return true
	var west_branch_y: float = Region.HUB_RECT.end.y + 2100.0
	if absf(world_pos.y - west_branch_y) < margin and world_pos.x > Region.SOUTH_ROAD_X - 3200.0 and world_pos.x < Region.SOUTH_ROAD_X:
		return true
	var east_branch_y: float = Region.HUB_RECT.end.y + 4200.0
	if absf(world_pos.y - east_branch_y) < margin and world_pos.x > Region.SOUTH_ROAD_X and world_pos.x < Region.SOUTH_ROAD_X + 3500.0:
		return true
	return false

func _draw() -> void:
	var bg: Color = Color(0.42,0.71,0.30)
	if _is_field_belt():
		bg = Color(0.48,0.70,0.29)
	draw_rect(Rect2(Vector2.ZERO,Vector2(Region.CHUNK_SIZE,Region.CHUNK_SIZE)),bg)
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
	var global_x0: float = position.x
	var global_y0: float = position.y
	if global_y0 + Region.CHUNK_SIZE >= Region.HUB_RECT.end.y - 80.0 and global_y0 <= Region.REGION_SIZE.y:
		var local_x: float = Region.SOUTH_ROAD_X - global_x0
		if local_x > -90.0 and local_x < Region.CHUNK_SIZE + 90.0:
			draw_rect(Rect2(local_x-72.0,0.0,144.0,Region.CHUNK_SIZE),Color(0.50,0.57,0.26))
			draw_rect(Rect2(local_x-58.0,0.0,116.0,Region.CHUNK_SIZE),Color(0.78,0.64,0.42))
			draw_line(Vector2(local_x-58.0,0.0),Vector2(local_x-58.0,Region.CHUNK_SIZE),Color(0.38,0.31,0.22,0.35),3.0)
			draw_line(Vector2(local_x+58.0,0.0),Vector2(local_x+58.0,Region.CHUNK_SIZE),Color(0.38,0.31,0.22,0.35),3.0)
	var west_branch_y: float = Region.HUB_RECT.end.y + 2100.0
	var local_west_y: float = west_branch_y - global_y0
	if local_west_y > -90.0 and local_west_y < Region.CHUNK_SIZE + 90.0 and global_x0 < Region.SOUTH_ROAD_X and global_x0 + Region.CHUNK_SIZE > Region.SOUTH_ROAD_X - 3300.0:
		draw_rect(Rect2(0.0,local_west_y-54.0,Region.CHUNK_SIZE,108.0),Color(0.78,0.64,0.42))
	var east_branch_y: float = Region.HUB_RECT.end.y + 4200.0
	var local_east_y: float = east_branch_y - global_y0
	if local_east_y > -90.0 and local_east_y < Region.CHUNK_SIZE + 90.0 and global_x0 + Region.CHUNK_SIZE > Region.SOUTH_ROAD_X and global_x0 < Region.SOUTH_ROAD_X + 3600.0:
		draw_rect(Rect2(0.0,local_east_y-54.0,Region.CHUNK_SIZE,108.0),Color(0.78,0.64,0.42))

func _draw_field_rows() -> void:
	if not _is_field_belt():
		return
	var left_of_road: bool = position.x + Region.CHUNK_SIZE * 0.5 < Region.SOUTH_ROAD_X
	var x_start: float = 80.0 if left_of_road else 120.0
	var x_end: float = Region.CHUNK_SIZE - 80.0
	for y in range(120,Region.CHUNK_SIZE-80,56):
		draw_line(Vector2(x_start,y),Vector2(x_end,y),Color(0.36,0.50,0.18,0.48),3.0)
