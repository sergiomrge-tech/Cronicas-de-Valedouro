extends SceneTree
# Gate REG_001: integridade dos dados, IDs, obstáculos, navegação (BFS) para todos os POIs, transições e performance.
const WORLD = preload("res://scripts/world_map.gd")
const REG = preload("res://scripts/reg001_world.gd")
const PROC = preload("res://scripts/reg001_procedural.gd")
const MODELED = preload("res://scripts/modeled_assets.gd")
const APPROVED_KEYS: Array[String] = ["city_house_door", "city_house_window", "city_roof_blue", "city_roof_red", "city_roof_wood", "city_wall", "city_wall_vegetation", "city_gate", "city_store", "city_water_edge", "city_floor_clean", "city_floor_worn", "city_floor_moss", "city_tree_green", "city_tree_autumn", "dungeon_floor_stone", "dungeon_floor_broken", "dungeon_wall", "dungeon_corner", "dungeon_arch", "dungeon_door", "dungeon_rail", "dungeon_crystal_blue", "dungeon_crystal_purple", "dungeon_torch", "dungeon_emissive_crystal", "dungeon_spikes", "dungeon_corridor"]

var game: Node2D

func _initialize() -> void:
	call_deferred("check")

func reachable_cells() -> Dictionary:
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
	return visited

func nearest_cell_distance(visited: Dictionary, target: Vector2) -> float:
	var best: float = 1.0e9
	var cx: int = int(target.x / 32.0)
	var cy: int = int(target.y / 32.0)
	for dy in range(-8, 9):
		for dx in range(-8, 9):
			var cell: Vector2i = Vector2i(cx + dx, cy + dy)
			if visited.has(cell):
				var d: float = Vector2(cell.x * 32 + 16, cell.y * 32 + 16).distance_to(target)
				best = minf(best, d)
	return best

func check() -> void:
	if FileAccess.file_exists("user://valedouro_v1.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://valedouro_v1.json"))
	REG.ensure_loaded()
	# ---- dados e IDs persistentes
	assert(REG.pois.size() >= 55, "POIs insuficientes: %d" % REG.pois.size())
	assert(REG.objects.size() >= 450, "objetos insuficientes: %d" % REG.objects.size())
	var seen: Dictionary = {}
	for o_value in REG.objects:
		var o: Dictionary = o_value
		var oid: String = str(o["id"])
		assert(oid.begins_with("REG001_OBJ_"), "ID de objeto inválido: " + oid)
		assert(not seen.has(oid), "ID duplicado: " + oid)
		seen[oid] = true
		var asset: String = str(o["asset"])
		if asset.begins_with("APP:"):
			assert(asset.substr(4) in APPROVED_KEYS, "APPROVED não previsto: " + asset)
		else:
			assert(MODELED.has(asset), "asset modelado ausente/bloqueado no manifesto: " + asset + " em " + oid)
	for poi_value in REG.pois:
		var poi: Dictionary = poi_value
		var pid: String = str(poi["id"])
		assert(pid.begins_with("REG001_POI_"), "ID de POI inválido: " + pid)
		assert(not seen.has(pid), "ID duplicado: " + pid)
		seen[pid] = true
		var pdata: Dictionary = poi["data"] as Dictionary
		for key in ["requires_elite", "requires_secret", "chest"]:
			if pdata.has(key):
				assert(REG.poi_by_id.has(str(pdata[key])), "referência quebrada %s em %s" % [key, pid])
		if pdata.has("lore"):
			assert(REG.lore.has(str(pdata["lore"])), "lore inexistente em " + pid)
		if pdata.has("passage"):
			var found_pass: bool = false
			for pass_value in REG.passages:
				if str((pass_value as Dictionary)["id"]) == str(pdata["passage"]):
					found_pass = true
			assert(found_pass, "passagem inexistente em " + pid)
	for o_value in REG.objects:
		var od: Dictionary = o_value
		if od.has("poi"):
			assert(REG.poi_by_id.has(str(od["poi"])), "objeto com POI inexistente: " + str(od["id"]))
		if od.has("hide_when"):
			assert(str(od["hide_when"]).begins_with("lore:") or REG.poi_by_id.has(str(od["hide_when"]).split(":")[-1]), "hide_when inexistente: " + str(od["id"]))
		if od.has("show_when"):
			assert(str(od["show_when"]).begins_with("lore:") or REG.poi_by_id.has(str(od["show_when"]).split(":")[-1]), "show_when inexistente: " + str(od["id"]))
	# ---- conteúdo exigido pela Etapa 1
	var kinds: Dictionary = {}
	for poi_value in REG.pois:
		var kd: String = str((poi_value as Dictionary)["kind"])
		kinds[kd] = int(kinds.get(kd, 0)) + 1
	for needed in ["elite", "chest", "secret", "gate", "resource", "camp", "settlement", "viewpoint", "lore", "npc", "entrance", "trap", "checkpoint", "shrine"]:
		assert(kinds.has(needed), "tipo de POI ausente: " + needed)
	assert(int(kinds["elite"]) >= 6 and int(kinds["chest"]) >= 12 and int(kinds["secret"]) >= 3)
	var pairs: Array[String] = []
	for t_value in REG.transitions:
		var pair: Array = (t_value as Dictionary)["between"]
		pairs.append("%s|%s" % [pair[0], pair[1]])
	for needed_pair in ["cidade|campos", "campos|floresta", "floresta|vale", "pradaria|gelo", "vale|deserto", "pradaria|deserto"]:
		assert(pairs.has(needed_pair), "transição ausente: " + needed_pair)
	assert(REG.passages.size() >= 3 and REG.trails.size() >= 12)
	# ---- obstáculos manuais nunca em água/ponte/estrada principal
	game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.zone = "cidade"
	for o_value in REG.objects:
		var ob: Dictionary = o_value
		if str(ob["zone"]) != "cidade" or float(ob.get("solid", 0.0)) <= 0.0:
			continue
		var p: Vector2 = ob["pos"]
		if WORLD.town_area(p):
			continue
		assert(not WORLD.river_at(p) and not WORLD.bridge_at(p), "obstáculo sobre rio/ponte: " + str(ob["id"]))
	# ---- navegação: todos os POIs alcançáveis (segredos fechados)
	REG.clear_progress()
	var visited: Dictionary = reachable_cells()
	assert(visited.size() > 4500, "malha conectada pequena: %d" % visited.size())
	for poi_value in REG.pois_in_zone("cidade"):
		var poi2: Dictionary = poi_value
		var d2: Dictionary = poi2["data"] as Dictionary
		if d2.has("requires_secret") or str(poi2["kind"]) == "trap":
			continue
		var reach: float = nearest_cell_distance(visited, poi2["pos"])
		assert(reach <= float(poi2["radius"]) * .95, "POI inalcançável: %s (dist %.0f > raio %.0f)" % [str(poi2["id"]), reach, float(poi2["radius"])])
	# vaus permitem atravessar o rio sem ponte
	for pass_value in REG.passages:
		var ps: Dictionary = pass_value
		if str(ps["kind"]) == "ford":
			var rect: Rect2 = ps["rect"]
			assert(game.walkable(rect.get_center()), "vau bloqueado: " + str(ps["id"]))
			var c: Vector2i = Vector2i(int(rect.get_center().x / 32.0), int(rect.get_center().y / 32.0))
			assert(visited.has(c), "vau fora da malha conectada: " + str(ps["id"]))
			assert(visited.has(Vector2i(int((rect.position.x - 20.0) / 32.0), c.y)) or visited.has(Vector2i(int((rect.end.x + 20.0) / 32.0), c.y)), "vau sem margem alcançável: " + str(ps["id"]))
	# ---- segredos e atalhos abertos: baús secretos passam a ser alcançáveis
	for poi_value in REG.pois:
		var sp: Dictionary = poi_value
		if str(sp["kind"]) in ["secret", "gate"]:
			REG.mark("found", str(sp["id"]))
	var visited_open: Dictionary = reachable_cells()
	assert(visited_open.size() >= visited.size(), "abrir segredos não pode reduzir a malha")
	for poi_value in REG.pois_in_zone("cidade"):
		var poi3: Dictionary = poi_value
		if (poi3["data"] as Dictionary).has("requires_secret"):
			var reach2: float = nearest_cell_distance(visited_open, poi3["pos"])
			assert(reach2 <= float(poi3["radius"]) * .95, "baú secreto inalcançável após revelar: " + str(poi3["id"]))
	# ---- exclusão: vegetação procedural não invade POIs, estradas ou trilhas
	REG.clear_progress()
	var bad: int = 0
	for poi_value in REG.pois_in_zone("cidade"):
		var poi4: Dictionary = poi_value
		var base_cell: Vector2 = poi4["pos"]
		for dx in range(-3, 4):
			for dy in range(-3, 4):
				var cx: int = int(base_cell.x / 32.0) + dx
				var cy: int = int(base_cell.y / 32.0) + dy
				var cp: Vector2 = Vector2(cx * 32 + 16, cy * 32 + 16)
				if cp.distance_to(base_cell) < float(poi4["radius"]) * .6 and WORLD.prop_at(cx, cy) != "":
					bad += 1
	assert(bad == 0, "vegetação procedural invadiu %d células de POIs" % bad)
	# ---- Bosque (instância): spawn conectado às trilhas e ao elite
	game.zone = "floresta"
	var forest_start: Vector2i = Vector2i(31, 24)
	var forest_queue: Array[Vector2i] = [forest_start]
	var forest_seen: Dictionary = {forest_start: true}
	var fh: int = 0
	while fh < forest_queue.size():
		var fp: Vector2i = forest_queue[fh]
		fh += 1
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var nx: Vector2i = fp + offset
			if forest_seen.has(nx) or nx.x < 1 or nx.x >= 57 or nx.y < 1 or nx.y >= 26:
				continue
			if game.walkable(Vector2(nx.x * 32 + 16, nx.y * 32 + 16)):
				forest_seen[nx] = true
				forest_queue.append(nx)
	assert(forest_seen.size() > 600, "Bosque com malha pequena: %d" % forest_seen.size())
	for fid in ["REG001_POI_BOSQUE_ELITE", "REG001_POI_BOSQUE_CAMP"]:
		var fpos: Vector2 = (REG.poi_by_id[fid] as Dictionary)["pos"]
		var fbest: float = 1.0e9
		for cell in forest_seen.keys():
			var fv: Vector2i = cell
			fbest = minf(fbest, Vector2(fv.x * 32 + 16, fv.y * 32 + 16).distance_to(fpos))
		assert(fbest <= 90.0, "Bosque: POI inalcançável " + fid)
	game.zone = "cidade"
	# ---- performance: chunks, culling e cache
	var t0: int = Time.get_ticks_msec()
	var total_items: int = 0
	var max_view: int = 0
	for cy in range(0, 5):
		for cx in range(0, 6):
			var chunk: Dictionary = PROC.build_chunk(Vector2i(cx, cy))
			total_items += (chunk["objs"] as Array).size() + (chunk["ground"] as Array).size()
	var build_ms: int = Time.get_ticks_msec() - t0
	assert(build_ms < 6000, "construção dos 30 chunks lenta: %d ms" % build_ms)
	for spot in [Vector2(1534, 1376), Vector2(300, 900), Vector2(500, 2000), Vector2(2700, 250), Vector2(2700, 1900), Vector2(1200, 2180)]:
		var cam: Vector2 = (spot - Vector2(480, 270)).clamp(Vector2.ZERO, WORLD.SIZE - Vector2(960, 540))
		var view: Dictionary = PROC.view(Rect2(cam, Vector2(960, 540)))
		var ys: PackedFloat32Array = view["ys"]
		var lo: int = PROC.first_index(ys, cam.y - 20.0)
		var hi: int = PROC.first_index(ys, cam.y + 540.0 + 320.0)
		max_view = maxi(max_view, hi - lo)
		assert(int(view["chunks"]) <= 12, "janela toca chunks demais: %d" % int(view["chunks"]))
	assert(max_view <= 900, "objetos visíveis demais para mobile: %d" % max_view)
	# chunk cache: segunda construção é gratuita
	var stats_before: int = int(PROC.stats["chunks_built"])
	PROC.build_chunk(Vector2i(2, 2))
	assert(int(PROC.stats["chunks_built"]) == stats_before, "cache de chunk não reutilizado")
	print("REG001 WORLD PASS: %d objetos, %d POIs, %d trilhas, %d passagens, %d células conectadas, %d itens em 30 chunks (%d ms), pico visível %d" % [REG.objects.size(), REG.pois.size(), REG.trails.size(), REG.passages.size(), visited.size(), total_items, build_ms, max_view])
	quit(0)
