extends SceneTree
const WORLD = preload("res://scripts/world_map.gd")
func _initialize() -> void:
	call_deferred("check_routes")
func check_routes() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.zone = "cidade"
	var start: Vector2i = Vector2i(48, 39)
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = {start: true}
	var heads: int = 0
	while heads < queue.size():
		var p: Vector2i = queue[heads]
		heads += 1
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = p + offset
			if visited.has(next) or next.x < 1 or next.x >= 95 or next.y < 1 or next.y >= 71:
				continue
			if game.walkable(Vector2(next.x * 32 + 16, next.y * 32 + 16)):
				visited[next] = true
				queue.append(next)
	for point in [Vector2i(9, 32), Vector2i(80, 56), Vector2i(80, 12), Vector2i(37, 61)]:
		assert(visited.has(point), "Bioma inacessível no ponto: " + str(point))
	for point in [Vector2i(34, 32), Vector2i(58, 32), Vector2i(47, 23), Vector2i(61, 41)]:
		assert(visited.has(point), "Entrada de Valedouro bloqueada: " + str(point))
	assert(not game.walkable(WORLD.TOWN + Vector2(874, 497)))
	print("ROUTES PASS: quatro biomas, guilda, ferreiro, portão, loja e fonte; ", visited.size(), " células conectadas")
	quit()
