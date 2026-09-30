class_name ValedouroCartoonAbyssStream
extends Node2D

const Abyss = preload("res://scripts/cartoon/abyss/abyss_region_config.gd")
const ChunkScript = preload("res://scripts/cartoon/abyss/abyss_chunk.gd")

var hero: Node2D
var active_chunks: Dictionary = {}
var last_chunk: Vector2i = Vector2i(99999,99999)
var elapsed: float = 0.0

func setup(player: Node2D) -> void:
	z_index = -30
	hero = player
	_refresh(true)

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed < 0.18:
		return
	elapsed = 0.0
	_refresh(false)

func _refresh(force: bool) -> void:
	if hero == null:
		return
	var current: Vector2i = Abyss.chunk_of(hero.position)
	if not force and current == last_chunk:
		return
	last_chunk = current
	var wanted: Dictionary = {}
	for cy in range(current.y-Abyss.ACTIVE_RADIUS,current.y+Abyss.ACTIVE_RADIUS+1):
		for cx in range(current.x-Abyss.ACTIVE_RADIUS,current.x+Abyss.ACTIVE_RADIUS+1):
			if cx < 0 or cy < 0:
				continue
			var world_pos: Vector2 = Vector2(cx*Abyss.CHUNK_SIZE,cy*Abyss.CHUNK_SIZE)
			if world_pos.x >= Abyss.REGION_SIZE.x or world_pos.y >= Abyss.REGION_SIZE.y:
				continue
			var coord: Vector2i = Vector2i(cx,cy)
			wanted[coord] = true
			if not active_chunks.has(coord):
				_activate(coord)
	var stale: Array = []
	for coord in active_chunks.keys():
		if not wanted.has(coord):
			stale.append(coord)
	for coord in stale:
		var node: Node = active_chunks[coord]
		active_chunks.erase(coord)
		if is_instance_valid(node):
			node.queue_free()

func _activate(coord: Vector2i) -> void:
	var chunk: Node2D = ChunkScript.new()
	chunk.name = "AbyssChunk_%d_%d" % [coord.x,coord.y]
	chunk.setup(coord)
	add_child(chunk)
	active_chunks[coord] = chunk

func active_count() -> int:
	return active_chunks.size()
