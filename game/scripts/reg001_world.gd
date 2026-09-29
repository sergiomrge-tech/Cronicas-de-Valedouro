extends RefCounted
# REG_001 — dados do mundo manual (POIs, objetos, passagens, trilhas), colisão e exclusões por hash espacial,
# e estado persistente (baús, elites, segredos). Fonte: data/reg001_world.json (gerado por tools/reg001).
# Não depende de world_map.gd (world_map.gd é que consulta este script).

const DATA_PATH: String = "res://data/reg001_world.json"
const MODELED = preload("res://scripts/modeled_assets.gd")
const CHUNK: int = 512
const CELL: float = 96.0

static var loaded: bool = false
static var data: Dictionary = {}
static var objects: Array = []
static var pois: Array = []
static var poi_by_id: Dictionary = {}
static var passages: Array = []
static var trails: Array = []
static var emitters: Array = []
static var lore: Dictionary = {}
static var transitions: Array = []
static var biome_style: Dictionary = {}
static var zone_objects: Dictionary = {}   # zona -> objetos ordenados por sort_y
static var chunk_objects: Dictionary = {}  # Vector2i -> índices de objetos da zona "cidade"
static var solid_grid: Dictionary = {}     # "zona:cx:cy" -> Array[Dictionary]
static var clear_grid: Dictionary = {}
static var trail_grid: Dictionary = {}
static var ford_rects: Array = []
static var crypt_walls: Array = []
static var state: Dictionary = {}

const ZONE_IDS: Dictionary = {"cidade": 0, "floresta": 1, "masmorra": 2, "ferreiro": 3, "loja": 4, "alquimia": 5, "guilda": 6, "cripta": 7}

static func _key(zone: String, cx: int, cy: int) -> int:
	# chave inteira (barata de hashear): zona * 2^22 + (cx+512) * 2^11 + (cy+512)
	return int(ZONE_IDS.get(zone, 15)) * 4194304 + (cx + 512) * 2048 + (cy + 512)

const STATE_SECTIONS: Array[String] = ["opened", "elites", "found", "gathered", "lore", "visited"]

static func clear_progress() -> void:
	# Construído por seção: um literal constante seria compartilhado entre chamadas e vazaria estado.
	state.clear()
	for section in STATE_SECTIONS:
		var bucket: Dictionary = {}
		state[section] = bucket

static func export_state() -> Dictionary:
	ensure_loaded()
	return state.duplicate(true)

static func import_state(value: Variant) -> void:
	ensure_loaded()
	clear_progress()
	if not value is Dictionary:
		return
	var incoming: Dictionary = value as Dictionary
	for section in state.keys():
		var part: Variant = incoming.get(section, {})
		if part is Dictionary:
			for id_value in (part as Dictionary).keys():
				var id: String = str(id_value)
				if poi_by_id.has(id) or lore.has(id):
					(state[section] as Dictionary)[id] = true

static func ensure_loaded() -> void:
	if loaded:
		return
	loaded = true
	clear_progress()
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	data = parsed as Dictionary
	lore = data.get("lore", {}) as Dictionary
	transitions = data.get("transitions", []) as Array
	biome_style = data.get("biome_style", {}) as Dictionary
	for value in data.get("pois", []):
		var poi: Dictionary = (value as Dictionary).duplicate(true)
		var pos_a: Array = poi["pos"]
		poi["pos"] = Vector2(float(pos_a[0]), float(pos_a[1]))
		pois.append(poi)
		poi_by_id[str(poi["id"])] = poi
	for value in data.get("passages", []):
		var passage: Dictionary = (value as Dictionary).duplicate(true)
		var r: Array = passage["rect"]
		passage["rect"] = Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3]))
		passages.append(passage)
		if str(passage["kind"]) == "ford":
			ford_rects.append(passage["rect"])
	for value in data.get("emitters", []):
		var em: Dictionary = (value as Dictionary).duplicate(true)
		var ep: Array = em["pos"]
		em["pos"] = Vector2(float(ep[0]), float(ep[1]))
		emitters.append(em)
	var crypt: Dictionary = data.get("mini_dungeon", {}) as Dictionary
	for wall_value in crypt.get("walls", []):
		var wr: Array = (wall_value as Dictionary)["rect"]
		crypt_walls.append(Rect2(float(wr[0]), float(wr[1]), float(wr[2]), float(wr[3])))
	_index_objects()
	_index_colliders()
	_index_clear_zones()
	_index_trails()

static func _index_objects() -> void:
	var index: int = 0
	for value in data.get("objects", []):
		var o: Dictionary = (value as Dictionary).duplicate(true)
		var pa: Array = o["pos"]
		o["pos"] = Vector2(float(pa[0]), float(pa[1]))
		o["sort_y"] = float(o.get("sy", o["pos"].y))
		o["i"] = index
		index += 1
		objects.append(o)
		var zone: String = str(o["zone"])
		if not zone_objects.has(zone):
			zone_objects[zone] = []
		(zone_objects[zone] as Array).append(o)
		if zone == "cidade":
			var ck: Vector2i = chunk_of(o["pos"])
			if not chunk_objects.has(ck):
				chunk_objects[ck] = []
			(chunk_objects[ck] as Array).append(o)
		var r: float = float(o.get("solid", 0.0))
		if r > 0.0:
			_add_circle(zone, o["pos"], r, o)
	for zone in zone_objects.keys():
		(zone_objects[zone] as Array).sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["sort_y"]) < float(b["sort_y"]))

static func _add_circle(zone: String, c: Vector2, r: float, owner: Dictionary) -> void:
	var entry: Dictionary = {"c": c, "r": r, "o": owner}
	var x0: int = int(floor((c.x - r) / CELL))
	var x1: int = int(floor((c.x + r) / CELL))
	var y0: int = int(floor((c.y - r) / CELL))
	var y1: int = int(floor((c.y + r) / CELL))
	for gy in range(y0, y1 + 1):
		for gx in range(x0, x1 + 1):
			var k: int = _key(zone, gx, gy)
			if not solid_grid.has(k):
				solid_grid[k] = []
			(solid_grid[k] as Array).append(entry)

static func _index_colliders() -> void:
	for value in data.get("colliders", []):
		var col: Dictionary = value as Dictionary
		var zone: String = str(col.get("zone", "cidade"))
		var owner: Dictionary = {"hide_when": str(col.get("hide_when", "")), "id": "collider"}
		if str(col["kind"]) == "circle":
			var pa: Array = col["pos"]
			_add_circle(zone, Vector2(float(pa[0]), float(pa[1])), float(col["r"]), owner)
		else:
			var ra: Array = col["rect"]
			var rect: Rect2 = Rect2(float(ra[0]), float(ra[1]), float(ra[2]), float(ra[3]))
			var entry: Dictionary = {"rect": rect, "o": owner}
			for gy in range(int(floor(rect.position.y / CELL)), int(floor(rect.end.y / CELL)) + 1):
				for gx in range(int(floor(rect.position.x / CELL)), int(floor(rect.end.x / CELL)) + 1):
					var k: int = _key(zone, gx, gy)
					if not solid_grid.has(k):
						solid_grid[k] = []
					(solid_grid[k] as Array).append(entry)

static func _add_clear(c: Vector2, r: float) -> void:
	var entry: Array = [c, r]
	for gy in range(int(floor((c.y - r) / CELL)), int(floor((c.y + r) / CELL)) + 1):
		for gx in range(int(floor((c.x - r) / CELL)), int(floor((c.x + r) / CELL)) + 1):
			var k: int = _key("cidade", gx, gy)
			if not clear_grid.has(k):
				clear_grid[k] = []
			(clear_grid[k] as Array).append(entry)

static func _index_clear_zones() -> void:
	for value in data.get("clear_zones", []):
		var a: Array = value
		_add_clear(Vector2(float(a[0]), float(a[1])), float(a[2]))
	for o in zone_objects.get("cidade", []):
		var od: Dictionary = o
		var asset: String = str(od["asset"])
		var fp: float = MODELED.footprint(asset) if not asset.begins_with("APP:") else 46.0
		if asset.begins_with("nat_decal") or fp <= 0.0:
			fp = 22.0
		_add_clear(od["pos"], fp + 16.0)

static func _index_trails() -> void:
	for value in data.get("trails", []):
		var t: Dictionary = value as Dictionary
		var pts: Array = t["pts"]
		var half: float = float(t["half"])
		for i in range(pts.size() - 1):
			var a: Vector2 = Vector2(float(pts[i][0]), float(pts[i][1]))
			var b: Vector2 = Vector2(float(pts[i + 1][0]), float(pts[i + 1][1]))
			var seg: Dictionary = {"a": a, "b": b, "half": half}
			var mn: Vector2 = Vector2(minf(a.x, b.x), minf(a.y, b.y)) - Vector2(half, half)
			var mx: Vector2 = Vector2(maxf(a.x, b.x), maxf(a.y, b.y)) + Vector2(half, half)
			for gy in range(int(floor(mn.y / CELL)), int(floor(mx.y / CELL)) + 1):
				for gx in range(int(floor(mn.x / CELL)), int(floor(mx.x / CELL)) + 1):
					var k: int = _key("cidade", gx, gy)
					if not trail_grid.has(k):
						trail_grid[k] = []
					(trail_grid[k] as Array).append(seg)
		trails.append(t)

# ------------------------------------------------------------------ consultas
static func chunk_of(p: Vector2) -> Vector2i:
	return Vector2i(int(floor(p.x / CHUNK)), int(floor(p.y / CHUNK)))

static func is_hidden(o: Dictionary) -> bool:
	var poi_id: String = str(o.get("poi", ""))
	if not poi_id.is_empty() and (state["gathered"] as Dictionary).has(poi_id):
		return true # recurso já colhido
	var found: Dictionary = state["found"] as Dictionary
	var hide_when: String = str(o.get("hide_when", ""))
	if not hide_when.is_empty() and found.has(hide_when):
		return true
	var show_when: String = str(o.get("show_when", ""))
	if not show_when.is_empty() and not found.has(show_when):
		return true
	return false

static func blocked_at(p: Vector2, zone: String = "cidade") -> bool:
	ensure_loaded()
	var gx: int = int(floor(p.x / CELL))
	var gy: int = int(floor(p.y / CELL))
	var list_value: Variant = solid_grid.get(_key(zone, gx, gy), null)
	if list_value == null:
		return false
	for entry_value in list_value as Array:
		var entry: Dictionary = entry_value
		if is_hidden(entry["o"]):
			continue
		if entry.has("rect"):
			if (entry["rect"] as Rect2).has_point(p):
				return true
		elif (entry["c"] as Vector2).distance_to(p) < float(entry["r"]):
			return true
	return false

static func clear_at(p: Vector2) -> bool:
	ensure_loaded()
	var list_value: Variant = clear_grid.get(_key("cidade", int(floor(p.x / CELL)), int(floor(p.y / CELL))), null)
	if list_value == null:
		return false
	for entry_value in list_value as Array:
		var entry: Array = entry_value
		if (entry[0] as Vector2).distance_to(p) < float(entry[1]):
			return true
	return false

static func trail_at(p: Vector2) -> bool:
	ensure_loaded()
	var list_value: Variant = trail_grid.get(_key("cidade", int(floor(p.x / CELL)), int(floor(p.y / CELL))), null)
	if list_value == null:
		return false
	for seg_value in list_value as Array:
		var seg: Dictionary = seg_value
		var a: Vector2 = seg["a"]
		var b: Vector2 = seg["b"]
		var ab: Vector2 = b - a
		var len2: float = maxf(ab.length_squared(), 0.001)
		var t: float = clampf((p - a).dot(ab) / len2, 0.0, 1.0)
		if (a + ab * t).distance_to(p) < float(seg["half"]):
			return true
	return false

static func ford_at(p: Vector2) -> bool:
	ensure_loaded()
	for rect_value in ford_rects:
		if (rect_value as Rect2).has_point(p):
			return true
	return false

static func pois_in_zone(zone: String) -> Array:
	ensure_loaded()
	var result: Array = []
	for poi_value in pois:
		if str((poi_value as Dictionary)["zone"]) == zone:
			result.append(poi_value)
	return result

static func nearest_poi(p: Vector2, zone: String, kinds: Array = []) -> Dictionary:
	ensure_loaded()
	var best: Dictionary = {}
	var best_d: float = 1.0e9
	for poi_value in pois:
		var poi: Dictionary = poi_value
		if str(poi["zone"]) != zone:
			continue
		if not kinds.is_empty() and not kinds.has(str(poi["kind"])):
			continue
		var d: float = (poi["pos"] as Vector2).distance_to(p)
		if d <= float(poi["radius"]) and d < best_d:
			best = poi
			best_d = d
	return best

# ------------------------------------------------------------------ estado (persistente)
static func mark(section: String, id: String) -> void:
	(state[section] as Dictionary)[id] = true

static func has_mark(section: String, id: String) -> bool:
	return (state[section] as Dictionary).has(id)

static func poi_available(poi: Dictionary) -> bool:
	var d: Dictionary = poi.get("data", {}) as Dictionary
	var req_elite: String = str(d.get("requires_elite", ""))
	if not req_elite.is_empty() and not has_mark("elites", req_elite):
		return false
	var req_secret: String = str(d.get("requires_secret", ""))
	if not req_secret.is_empty() and not has_mark("found", req_secret):
		return false
	return true
