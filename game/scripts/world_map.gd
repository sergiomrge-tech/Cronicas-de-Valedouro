extends RefCounted
# Geografia determinística compartilhada entre desenho, colisões e spawns.
# v0.6: três travessias de rio, margens rasas, vale sul, dunas e marcos por bioma.
const SIZE: Vector2 = Vector2(3072, 2304)
const TOWN: Vector2 = Vector2(650, 680)
const TOWN_BOUNDS: Rect2 = Rect2(TOWN, Vector2(1774, 887))
const BRIDGE_Y: float = 1250.0 # compatibilidade com testes/saves antigos
const BRIDGE_YS: Array[float] = [760.0, 1250.0, 1840.0]
const REG = preload("res://scripts/reg001_world.gd")

const STRUCTURES: Array[Dictionary] = [
	{"pos": Vector2(360, 1110), "kind": "watchtower", "label": "TORRE DO OESTE", "radius": 42.0},
	{"pos": Vector2(1320, 345), "kind": "watchtower", "label": "TORRE DO NORTE", "radius": 42.0},
	{"pos": Vector2(1110, 1880), "kind": "windmill", "label": "MOINHO DO VALE", "radius": 50.0},
	{"pos": Vector2(1660, 2010), "kind": "shrine", "label": "SANTUÁRIO DO VALE", "radius": 38.0},
	{"pos": Vector2(2690, 1820), "kind": "desert_outpost", "label": "POSTO DE ÂMBAR", "radius": 54.0},
	{"pos": Vector2(2700, 600), "kind": "ice_lodge", "label": "ABRIGO DA GEADA", "radius": 54.0}
]

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
	return TOWN_BOUNDS.has_point(p)

static func biome(p: Vector2) -> String:
	if town_area(p):
		return "cidade"
	if p.x > 2010 and p.y < 860:
		return "gelo"
	if p.x > 1980 and p.y > 1370:
		return "deserto"
	if p.y > 1570:
		return "campos" if p.x < 760 else "vale"
	if p.x < 1040 or p.y < 680:
		return "floresta"
	return "pradaria"

static func path_at(p: Vector2) -> bool:
	# Estradas principais da cidade + ramificações para as três pontes.
	if town_area(p):
		var q: Vector2 = p - TOWN
		return absf(q.x - 890.0) < 80.0 or absf(q.y - 478.0) < 65.0 or (q.y < 478.0 and absf(q.x - 448.0) < 47.0) or (q.y > 478.0 and absf(q.x - 1300.0) < 46.0)
	if p.x < 650 and absf(p.y - 1160.0) < 49:
		return true
	if p.y < 680 and absf(p.x - 1536.0) < 46:
		return true
	if p.y > 1567 and absf(p.x - 1536.0) < 48:
		return true
	# Via central para a ponte mercantil.
	if p.x > 2320 and absf(p.y - BRIDGE_YS[1]) < 49:
		return true
	if p.x > 2280 and absf(p.x - 2560.0) < 43 and p.y < 1280:
		return true
	# Ramal alto: cidade -> gelo, cruza a ponte do norte.
	if p.y > 700 and p.y < 820 and p.x > 1700:
		return true
	if p.x > 2470 and p.x < 2550 and p.y < 820:
		return true
	# Ramal baixo: vale -> dunas, cruza a ponte sul.
	if p.y > 1790 and p.y < 1890 and p.x > 1450:
		return true
	# Rotas secundárias e atalhos da REG_001 (dados em reg001_world.json).
	return REG.trail_at(p)

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
	match biome(p):
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
