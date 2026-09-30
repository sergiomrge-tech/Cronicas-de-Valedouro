extends RefCounted
# Geografia determinística compartilhada entre desenho, colisões e spawns.
# v0.6: três travessias de rio, margens rasas, vale sul, dunas e marcos por bioma.
const SIZE: Vector2 = Vector2(3072, 2304)
const TOWN: Vector2 = Vector2(650, 680)
const TOWN_BOUNDS: Rect2 = Rect2(TOWN, Vector2(1774, 887))
const BRIDGE_Y: float = 1250.0 # compatibilidade com testes/saves antigos
const BRIDGE_YS: Array[float] = [760.0, 1250.0, 1840.0]
const REG = preload("res://scripts/reg001_world.gd")

# Remapeamento Etapa 1: posições iguais às de data/reg001_layout.json (e aos objetos str_* reais do mundo).
const STRUCTURES: Array[Dictionary] = [
	{"pos": Vector2(272, 1080), "kind": "watchtower", "label": "TORRE DO OESTE", "radius": 42.0},
	{"pos": Vector2(1320, 345), "kind": "watchtower", "label": "TORRE DO NORTE", "radius": 42.0},
	{"pos": Vector2(1060, 1920), "kind": "windmill", "label": "MOINHO DO VALE", "radius": 50.0},
	{"pos": Vector2(1660, 2010), "kind": "shrine", "label": "SANTUÁRIO DO VALE", "radius": 38.0},
	{"pos": Vector2(2690, 1800), "kind": "desert_outpost", "label": "POSTO DE ÂMBAR", "radius": 54.0},
	{"pos": Vector2(2700, 600), "kind": "ice_lodge", "label": "ABRIGO DA GEADA", "radius": 54.0}
]

# Traçado (estradas por spline, praça, contorno orgânico da cidade e bioma com bordas deformadas) vem de uma grade gerada
# por tools/reg001/layout.py a partir de data/reg001_layout.json — a mesma fonte do chão assado e do gerador de conteúdo.
const LAYOUT_GRID_PATH: String = "res://data/reg001_layout_grid.json"
const BIOME_BY_LETTER: Dictionary = {"T": "cidade", "S": "gelo", "D": "deserto", "C": "campos", "V": "vale", "F": "floresta", "P": "pradaria"}
static var _layout: Dictionary = {}
# grades em bytes (carregadas uma vez): consulta O(1) sem alocar string — prop_at/obstacle_at chamam isto milhares de vezes
static var _grid_ready: bool = false
static var _gw: int = 0
static var _gh: int = 0
static var _gcell: float = 16.0
static var _g_road: PackedByteArray = PackedByteArray()
static var _g_town: PackedByteArray = PackedByteArray()
static var _g_bio: PackedByteArray = PackedByteArray()
static var _bio_names: PackedStringArray = PackedStringArray()

static func layout_grid() -> Dictionary:
	if _layout.is_empty():
		var file: FileAccess = FileAccess.open(LAYOUT_GRID_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_layout = parsed as Dictionary
		if _layout.is_empty():
			_layout = {"cell": 16, "w": 0, "h": 0, "road": [], "town": [], "biome": []}
	return _layout

static func _pack(rows: Array) -> PackedByteArray:
	var out: PackedByteArray = PackedByteArray()
	for row in rows:
		out.append_array(str(row).to_ascii_buffer())
	return out

static func _ensure_grid() -> void:
	if _grid_ready:
		return
	_grid_ready = true
	var g: Dictionary = layout_grid()
	_gw = int(g.get("w", 0))
	_gh = int(g.get("h", 0))
	_gcell = float(g.get("cell", 16))
	_g_road = _pack(g.get("road", []) as Array)
	_g_town = _pack(g.get("town", []) as Array)
	_g_bio = _pack(g.get("biome", []) as Array)
	_bio_names.resize(128)
	for i in 128:
		_bio_names[i] = str(BIOME_BY_LETTER.get(char(i), "pradaria")) if i > 0 else ""

static func _grid_byte(kind: int, p: Vector2) -> int:
	# kind: 0 estrada/trilha, 1 cidade, 2 bioma (o array é escolhido DEPOIS de garantir a carga)
	_ensure_grid()
	var cx: int = int(p.x / _gcell)
	var cy: int = int(p.y / _gcell)
	if p.x < 0.0 or p.y < 0.0 or cx >= _gw or cy >= _gh:
		return 0
	var i: int = cy * _gw + cx
	if kind == 0:
		return _g_road[i]
	if kind == 1:
		return _g_town[i]
	return _g_bio[i]

static func layout_cell(kind: String, p: Vector2) -> String:
	var b: int = _grid_byte(0 if kind == "road" else (1 if kind == "town" else 2), p)
	return "" if b == 0 else char(b)

static func river_x(y: float) -> float:
	# Curva menos uniforme: trechos largos, gargalos e pequenas inflexões.
	return 2220.0 + sin(y * 0.006) * 78.0 + sin(y * 0.017) * 23.0 + sin(y * 0.0024 + 1.3) * 34.0

static func river_half_width(y: float) -> float:
	return 48.0 + sin(y * 0.0041 + .6) * 8.0 + sin(y * 0.013) * 5.0

static func river_at(p: Vector2) -> bool:
	if p.y <= 242 or REG.ford_at(p):
		return false
	return absf(p.x - river_x(p.y)) < river_half_width(p.y)

static func shallow_at(p: Vector2) -> bool:
	if p.y <= 242 or bridge_at(p) or REG.ford_at(p):
		return false
	var d: float = absf(p.x - river_x(p.y))
	return d >= river_half_width(p.y) and d < river_half_width(p.y) + 12.0

static func river_bank_at(p: Vector2) -> bool:
	if p.y <= 242 or bridge_at(p):
		return false
	var d: float = absf(p.x - river_x(p.y))
	return d >= river_half_width(p.y) + 12.0 and d < river_half_width(p.y) + 39.0

static func bridge_index_at(p: Vector2) -> int:
	for i in range(BRIDGE_YS.size()):
		var by: float = float(BRIDGE_YS[i])
		if absf(p.y - by) < 50.0 and absf(p.x - river_x(by)) < river_half_width(by) + 68.0:
			return i
	return -1

static func bridge_at(p: Vector2) -> bool:
	return bridge_index_at(p) >= 0

static func town_area(p: Vector2) -> bool:
	if not _grid_ready:
		_ensure_grid()
	var cx: int = int(p.x / _gcell)
	var cy: int = int(p.y / _gcell)
	if p.x < 0.0 or p.y < 0.0 or cx >= _gw or cy >= _gh:
		return false
	return _g_town[cy * _gw + cx] == 49   # ASCII '1'

static func biome(p: Vector2) -> String:
	if not _grid_ready:
		_ensure_grid()
	var cx: int = int(p.x / _gcell)
	var cy: int = int(p.y / _gcell)
	if p.x < 0.0 or p.y < 0.0 or cx >= _gw or cy >= _gh:
		# fora do mapa: mesma regra topológica, sem deformação
		if p.x > 2010 and p.y < 860:
			return "gelo"
		if p.x > 1980 and p.y > 1370:
			return "deserto"
		if p.y > 1570:
			return "campos" if p.x < 760 else "vale"
		return "floresta" if (p.x < 1040 or p.y < 680) else "pradaria"
	return _bio_names[_g_bio[cy * _gw + cx]]

static func family_biome(letter: String, fallback: String) -> String:
	match letter:
		"F": return "floresta"
		"G": return fallback if fallback in ["campos", "pradaria"] else "pradaria"
		"V": return "vale"
		"D": return "deserto"
		"S": return "gelo"
	return fallback

static func veg_biome(x: int, y: int) -> String:
	# Bioma da vegetação: segue a grade visual do piso e mistura a família vizinha perto da fronteira (ecótono gradual).
	var p: Vector2 = Vector2(x * 32 + 16, y * 32 + 16)
	var base: String = biome(p)
	REG.ensure_loaded()
	var dom: String = REG.grid_cell("dom", x, y)
	if dom == "" or dom == "O" or dom == "T":
		return base
	var here: String = family_biome(dom, base)
	var nb: String = REG.grid_cell("nb", x, y)
	var d_text: String = REG.grid_cell("dist", x, y)
	if nb == "" or d_text == "" or nb == "O" or nb == "T":
		return here
	var d: int = int(d_text)
	if d >= 4:
		return here
	if cell_hash(x + 53, y + 91) % 8 < 4 - d:
		return family_biome(nb, here)
	return here

static func path_at(p: Vector2) -> bool:
	# Estradas por spline, praças e trilhas/atalhos da REG_001 — tudo rasterizado na grade do layout (consulta O(1)).
	if not _grid_ready:
		_ensure_grid()
	var cx: int = int(p.x / _gcell)
	var cy: int = int(p.y / _gcell)
	if p.x < 0.0 or p.y < 0.0 or cx >= _gw or cy >= _gh:
		return false
	return _g_road[cy * _gw + cx] == 49   # ASCII '1'

static func ground_biome(p: Vector2) -> String:
	# Só para o piso: dispersa a fronteira dos biomas (±48 px) e evita a linha reta entre tiles de terreno.
	var here: String = biome(p)
	if here == "cidade":
		return here
	var h: int = cell_hash(int(p.x / 32) + 7, int(p.y / 32) + 13)
	var other: String = biome(p + Vector2(float(h % 97) - 48.0, float((h / 97) % 97) - 48.0))
	return other if other != "cidade" else here

static func ground_at(p: Vector2) -> String:
	if bridge_at(p):
		return "bridge"
	if p.y > 242 and REG.ford_at(p):
		return "shallow_water" # vau: água rasa caminhável entre pedras
	if river_at(p):
		return "water"
	if shallow_at(p):
		return "shallow_water"
	if path_at(p):
		return "path"
	if river_bank_at(p):
		return "riverbank"
	match ground_biome(p):
		"gelo": return "snow" if cell_hash(int(p.x / 32), int(p.y / 32)) % 5 else "snow2"
		"deserto": return "sand" if cell_hash(int(p.x / 32), int(p.y / 32)) % 4 else "desert_dune"
		"campos": return "meadow" if cell_hash(int(p.x / 32), int(p.y / 32)) % 4 else "grass2"
		"vale": return "valley_grass" if cell_hash(int(p.x / 32), int(p.y / 32)) % 3 else "meadow"
		"floresta": return "grass2" if cell_hash(int(p.x / 32), int(p.y / 32)) % 3 else "grass"
		_: return "grass" if cell_hash(int(p.x / 32), int(p.y / 32)) % 4 else "meadow"

static func cell_hash(x: int, y: int) -> int:
	var n: int = x * 733 + y * 3187 + x * y * 23 + 41293
	return absi((n ^ (n >> 7)) * 4057 + (n >> 3))

static func near_structure(p: Vector2, padding: float = 0.0) -> bool:
	for entry in STRUCTURES:
		var center: Vector2 = entry["pos"] as Vector2
		if center.distance_to(p) < float(entry["radius"]) + padding:
			return true
	return false

static func prop_at(x: int, y: int) -> String:
	var p: Vector2 = Vector2(x * 32 + 16, y * 32 + 16)
	if town_area(p) or path_at(p) or river_at(p) or shallow_at(p) or bridge_at(p) or near_structure(p, 36.0) or REG.clear_at(p):
		return ""
	var seed: int = cell_hash(x, y)
	var local_seed: int = cell_hash(x + 17, y + 29)
	# Procedural control: decorate generously, but never block roads, POIs or river crossings.
	if river_bank_at(p):
		if seed % 4 == 0: return "reed"
		if seed % 11 == 0: return "valley_rock"
		if seed % 13 == 0: return "bush"
		return ""
	match veg_biome(x, y):
		"floresta":
			if seed % 7 == 0: return "pine"
			if local_seed % 19 == 0: return "tree"
			if seed % 8 == 0: return "bush"
			if seed % 17 == 0: return "flower"
			if local_seed % 29 == 0: return "valley_rock"
			if seed % 37 == 0: return "mushroom"
			if local_seed % 53 == 0: return "log"
			if seed % 61 == 0: return "stump"
		"gelo":
			if seed % 17 == 0: return "frost_tree"
			if seed % 16 == 0: return "ice_rock"
			if local_seed % 25 == 0: return "ice_crystal"
			if seed % 13 == 0: return "snow_mound"
			if local_seed % 23 == 0: return "bush"
		"deserto":
			if seed % 13 == 0: return "cactus"
			if local_seed % 18 == 0: return "sand_rock"
			if seed % 11 == 0: return "dead_bush"
			if local_seed % 43 == 0: return "dune"
			if seed % 47 == 0: return "bones"
		"campos":
			if seed % 19 == 0: return "tree"
			if local_seed % 9 == 0: return "flower"
			if seed % 15 == 0: return "bush"
			if local_seed % 27 == 0: return "valley_rock"
			if seed % 12 == 0: return "grass_tall"
		"vale":
			if seed % 17 == 0: return "tree"
			if local_seed % 8 == 0: return "flower"
			if seed % 18 == 0: return "valley_rock"
			if local_seed % 13 == 0: return "bush"
			if seed % 11 == 0: return "grass_tall"
		"pradaria":
			if seed % 16 == 0: return "bush"
			if local_seed % 10 == 0: return "flower"
			if seed % 31 == 0: return "tree"
			if local_seed % 59 == 0: return "boulder"
			if seed % 9 == 0: return "grass_tall"
	return ""

static func obstacle_at(p: Vector2) -> bool:
	if REG.blocked_at(p):
		return true
	if town_area(p):
		return false
	if near_structure(p, -7.0):
		return true
	if (river_at(p) or shallow_at(p)) and not bridge_at(p) and not REG.ford_at(p):
		return true
	# Células vizinhas bastam; a colisão fica no tronco/miolo, não na copa inteira.
	var tx: int = int(p.x / 32)
	var ty: int = int(p.y / 32)
	for y in range(ty - 1, ty + 2):
		for x in range(tx - 1, tx + 2):
			var prop: String = prop_at(x, y)
			if prop in ["tree", "pine", "frost_tree", "cactus", "ice_rock", "sand_rock", "ice_crystal", "valley_rock", "log", "boulder"]:
				var center: Vector2 = Vector2(x * 32 + 16, y * 32 + 16)
				var radius: float = 15.0 if prop in ["pine", "tree", "frost_tree", "boulder", "log"] else 11.0
				if center.distance_to(p) < radius:
					return true
	return false
