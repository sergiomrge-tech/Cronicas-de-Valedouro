extends RefCounted
# REG_001 — camada procedural determinística em chunks de 512 px: vegetação/props naturais (via world_map.prop_at),
# transições suaves entre biomas (decalques) e união com os objetos manuais. Tudo é gerado uma única vez por chunk
# e reutilizado (culling por faixa de chunks visíveis + busca binária por Y).

const MAP = preload("res://scripts/world_map.gd")
const REG = preload("res://scripts/reg001_world.gd")

# Índices do item de desenho: [sort_y, asset, x, y, anim, scale, flip, owner, layer]
const IT_SY: int = 0
const IT_ASSET: int = 1
const IT_X: int = 2
const IT_Y: int = 3
const IT_ANIM: int = 4
const IT_SCALE: int = 5
const IT_FLIP: int = 6
const IT_OWNER: int = 7
const IT_KIND: int = 8

const DIRS: Array[Vector2] = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(.7, .7), Vector2(-.7, .7), Vector2(.7, -.7), Vector2(-.7, -.7)]

static var _chunks: Dictionary = {}
static var _view_key: String = ""
static var _view: Dictionary = {}
static var _zone_views: Dictionary = {}
static var stats: Dictionary = {"chunks_built": 0, "view_rebuilds": 0}

static func item(sy: float, asset: String, x: float, y: float, anim: float, scale: float, flip: bool, owner: Variant, kind: String) -> Array:
	return [sy, asset, x, y, anim, scale, flip, owner, kind]

static func asset_for(kind: String, biome_name: String, seed: int) -> String:
	match kind:
		"tree":
			if biome_name in ["campos", "vale", "pradaria"] and seed % 10 < 3:
				return "nat_tree_birch"
			return "APP:city_tree_autumn" if seed % 9 == 0 else "APP:city_tree_green"
		"pine":
			return "nat_tree_pine"
		"frost_tree":
			return "nat_tree_pine_snow"
		"bush":
			if biome_name == "gelo":
				return "nat_bush_frost"
			if biome_name == "floresta":
				return "nat_bush_berry" if seed % 3 == 0 else "nat_bush_green"
			return "nat_bush_flowering" if seed % 2 == 0 else "nat_bush_green"
		"flower":
			if biome_name == "floresta":
				return "nat_flowers_red"
			return "nat_flowers_blue" if biome_name == "vale" else "nat_flowers_meadow"
		"valley_rock":
			if biome_name in ["floresta", "vale"]:
				return "nat_rock_mossy"
			return "nat_rock_medium" if seed % 3 == 0 else "nat_rock_small"
		"reed":
			return "nat_reeds"
		"ice_rock":
			return "nat_rock_ice" if seed % 2 == 0 else "nat_rock_snow"
		"ice_crystal":
			return "nat_ice_spire"
		"cactus":
			return "nat_cactus_tall" if seed % 3 != 0 else "nat_cactus_round"
		"sand_rock":
			return "nat_rock_sand"
		"dead_bush":
			return "nat_bush_dry"
		"mushroom":
			return "nat_mushrooms"
		"log":
			return "nat_log_fallen"
		"stump":
			return "nat_stump"
		"snow_mound":
			return "nat_snow_mound"
		"dune":
			return "nat_dune_small"
		"bones":
			return "nat_bones_desert"
		"grass_tall":
			return "nat_grass_dry" if biome_name == "deserto" else "nat_grass_tall"
		"boulder":
			return "nat_rock_boulder"
	return ""

static func _pair_width(a: String, b: String) -> float:
	for t_value in REG.transitions:
		var t: Dictionary = t_value
		var pair: Array = t["between"]
		if (pair[0] == a and pair[1] == b) or (pair[0] == b and pair[1] == a):
			return float(t["width"])
	return 110.0

static func transition_at(p: Vector2, biome_name: String) -> Dictionary:
	# Retorna {"other": bioma vizinho, "w": peso 0..1} quando p está perto de uma fronteira de bioma.
	for dist in [32.0, 64.0, 96.0, 128.0, 160.0]:
		for dir in DIRS:
			var q: Vector2 = p + dir * dist
			if q.x < 0 or q.y < 0 or q.x >= MAP.SIZE.x or q.y >= MAP.SIZE.y:
				continue
			var other: String = MAP.biome(q)
			if other != biome_name:
				var width: float = _pair_width(biome_name, other)
				if dist > width:
					return {}
				return {"other": other, "w": clampf(1.0 - (dist - 16.0) / width, 0.0, 1.0)}
	return {}

static func build_chunk(ck: Vector2i) -> Dictionary:
	if _chunks.has(ck):
		return _chunks[ck] as Dictionary
	REG.ensure_loaded()
	stats["chunks_built"] = int(stats["chunks_built"]) + 1
	var ground: Array = []
	var objs: Array = []
	var cells: int = REG.CHUNK / 32
	for cy in range(ck.y * cells, ck.y * cells + cells):
		for cx in range(ck.x * cells, ck.x * cells + cells):
			if cx < 0 or cy < 0 or cx * 32 >= int(MAP.SIZE.x) or cy * 32 >= int(MAP.SIZE.y):
				continue
			var p: Vector2 = Vector2(cx * 32 + 16, cy * 32 + 16)
			var biome_name: String = MAP.biome(p)
			var prop: String = MAP.prop_at(cx, cy)
			var visual_seed: int = MAP.cell_hash(cx + 113, cy + 197)
			if not prop.is_empty():
				var jitter: Vector2 = Vector2(float((visual_seed % 7) - 3), float((int(visual_seed / 7) % 5) - 2))
				var foot: Vector2 = p + jitter + Vector2(0, 14)
				var asset: String = asset_for(prop, MAP.veg_biome(cx, cy), visual_seed)
				if not asset.is_empty():
					objs.append(item(foot.y, asset, foot.x, foot.y, float(visual_seed % 97) * .11, 1.0, visual_seed % 2 == 1 and not asset.begins_with("APP:"), null, prop))
			# água: brilhos, ondulações e espuma são sprites animados sobre o chão assado
			var wh: int = MAP.cell_hash(cx + 71, cy + 131)
			var in_deep: bool = (MAP.river_at(p) and not MAP.bridge_at(p)) or (REG.ford_at(p) and wh % 2 == 0)
			if in_deep:
				var jx: float = float((visual_seed % 25) - 12)
				var jy: float = float((int(visual_seed / 25) % 21) - 10)
				if wh % 5 < 2:
					ground.append(item(p.y, "ter_water_glint", p.x + jx, p.y + jy, float(wh % 89) * .09, 1.0, false, null, "water"))
				if wh % 13 == 0:
					ground.append(item(p.y, "ter_water_ripple", p.x + jx, p.y + jy, float(wh % 71) * .13, 1.0, false, null, "water"))
				continue
			if MAP.shallow_at(p):
				if wh % 3 == 0:
					ground.append(item(p.y, "ter_water_foam", p.x + float((visual_seed % 17) - 8), p.y + float((int(visual_seed / 17) % 9) - 4), float(wh % 53) * .17, 1.0, false, null, "water"))
				elif wh % 4 == 1:
					ground.append(item(p.y, "ter_water_glint", p.x, p.y, float(wh % 89) * .09, 1.0, false, null, "water"))
				continue
			if MAP.town_area(p) or MAP.path_at(p) or MAP.bridge_at(p):
				continue
			# transições de bioma: o chão assado já mistura os terrenos; aqui entram só props de borda
			var tr: Dictionary = transition_at(p, biome_name)
			if tr.is_empty():
				continue
			var other: String = str(tr["other"])
			var w: float = float(tr["w"])
			var roll: float = float(MAP.cell_hash(cx + 331, cy + 71) % 1000) / 1000.0
			var style_other: Dictionary = REG.biome_style.get(other, {}) as Dictionary
			var style_here: Dictionary = REG.biome_style.get(biome_name, {}) as Dictionary
			if roll > 1.0 - .10 * w and not REG.clear_at(p):
				var pool: Array = []
				pool.append_array(style_other.get("edge", []) as Array)
				pool.append_array(style_here.get("edge", []) as Array)
				if not pool.is_empty():
					var foot2: Vector2 = p + Vector2(float((visual_seed % 15) - 7), 14.0 + float((int(visual_seed / 15) % 9) - 4))
					objs.append(item(foot2.y, str(pool[visual_seed % pool.size()]), foot2.x, foot2.y, float(visual_seed % 89) * .1, 1.0, visual_seed % 2 == 0, null, "edge"))
	for o_value in REG.chunk_objects.get(ck, []):
		var o: Dictionary = o_value
		var entry: Array = item(float(o["sort_y"]), str(o["asset"]), (o["pos"] as Vector2).x, (o["pos"] as Vector2).y, float(o.get("anim", 0.0)), float(o.get("scale", 1.0)), bool(o.get("flip", false)), o, str(o.get("layer", "decor")))
		if str(o.get("layer", "")) == "ground":
			ground.append(entry)
		else:
			objs.append(entry)
	var chunk: Dictionary = {"ground": ground, "objs": objs}
	_chunks[ck] = chunk
	return chunk

static func _finish(ground: Array, objs: Array) -> Dictionary:
	objs.sort_custom(func(a: Array, b: Array) -> bool: return float(a[IT_SY]) < float(b[IT_SY]))
	var ys: PackedFloat32Array = PackedFloat32Array()
	for entry in objs:
		ys.append(float((entry as Array)[IT_SY]))
	return {"ground": ground, "objs": objs, "ys": ys}

static func view(rect: Rect2) -> Dictionary:
	# Lista unificada (ordenada por Y) dos chunks que tocam a janela visível; reconstruída só ao trocar de chunk.
	# Sprites crescem para cima a partir do pé: margem grande embaixo, pequena em cima.
	var c0: Vector2i = REG.chunk_of(rect.position - Vector2(200, 40))
	var c1: Vector2i = REG.chunk_of(rect.end + Vector2(200, 340))
	var key: String = "%d,%d,%d,%d" % [c0.x, c0.y, c1.x, c1.y]
	if key == _view_key:
		return _view
	var ground: Array = []
	var objs: Array = []
	for cy in range(c0.y, c1.y + 1):
		for cx in range(c0.x, c1.x + 1):
			var chunk: Dictionary = build_chunk(Vector2i(cx, cy))
			ground.append_array(chunk["ground"] as Array)
			objs.append_array(chunk["objs"] as Array)
	_view = _finish(ground, objs)
	_view["chunks"] = (c1.x - c0.x + 1) * (c1.y - c0.y + 1)
	_view_key = key
	stats["view_rebuilds"] = int(stats["view_rebuilds"]) + 1
	return _view

static func zone_view(zone: String) -> Dictionary:
	if _zone_views.has(zone):
		return _zone_views[zone] as Dictionary
	REG.ensure_loaded()
	var ground: Array = []
	var objs: Array = []
	for o_value in REG.zone_objects.get(zone, []):
		var o: Dictionary = o_value
		var entry: Array = item(float(o["sort_y"]), str(o["asset"]), (o["pos"] as Vector2).x, (o["pos"] as Vector2).y, float(o.get("anim", 0.0)), float(o.get("scale", 1.0)), bool(o.get("flip", false)), o, str(o.get("layer", "decor")))
		if str(o.get("layer", "")) == "ground":
			ground.append(entry)
		else:
			objs.append(entry)
	var result: Dictionary = _finish(ground, objs)
	_zone_views[zone] = result
	return result

static func first_index(ys: PackedFloat32Array, y: float) -> int:
	var lo: int = 0
	var hi: int = ys.size()
	while lo < hi:
		var mid: int = (lo + hi) >> 1
		if ys[mid] < y:
			lo = mid + 1
		else:
			hi = mid
	return lo
