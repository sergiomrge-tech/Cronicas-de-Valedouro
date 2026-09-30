class_name ValedouroCartoonForestStoryMap
extends RefCounted

const Forest = preload("res://scripts/cartoon/forest/forest_region_config.gd")

static func locations() -> Array[Dictionary]:
	return [
		{
			"id":"LOC_FOREST_STONE_BRIDGE",
			"label":"Ponte de Pedra da Fronteira",
			"kind":"stone_bridge",
			"pos":Vector2(23000,43800),
			"scale":1.25,
			"quest":"Q_MS02_BORDER",
			"radius":360.0
		},
		{
			"id":"LOC_FOREST_RANGER_LODGE",
			"label":"Casa dos Guardas Verdes",
			"kind":"ranger_lodge",
			"pos":Vector2(25800,37400),
			"scale":1.25,
			"quest":"Q_MS02_RANGERS",
			"radius":460.0
		},
		{
			"id":"LOC_FOREST_ROOT_SHRINES",
			"label":"Santuários de Raiz",
			"kind":"root_shrine",
			"pos":Vector2(24000,30200),
			"scale":1.20,
			"quest":"Q_MS02_ROOTS",
			"radius":520.0
		},
		{
			"id":"LOC_MEMORY_TREE",
			"label":"Árvore-Memória",
			"kind":"memory_tree",
			"pos":Vector2(23000,23500),
			"scale":1.35,
			"quest":"Q_MS02_MEMORY_TREE",
			"radius":620.0
		},
		{
			"id":"LOC_HOLLOW_ROOT_ARENA",
			"label":"Coração da Raiz Oca",
			"kind":"hollow_root_arena",
			"pos":Vector2(17500,17500),
			"scale":1.30,
			"quest":"Q_MS02_HOLLOW_ROOT",
			"radius":680.0
		},
		{
			"id":"LOC_FOREST_CARTOGRAPHER_SHRINE",
			"label":"Santuário dos Cartógrafos",
			"kind":"cartographer_shrine",
			"pos":Vector2(29200,11400),
			"scale":1.25,
			"quest":"Q_MS02_VEIL_SHRINE",
			"radius":500.0
		}
	]

static func root_subshrines() -> Array[Dictionary]:
	return [
		{"id":"LOC_FOREST_ROOT_SHRINE_W","label":"Raiz Oeste","kind":"root_shrine","pos":Vector2(19000,32300),"scale":1.0,"parent":"LOC_FOREST_ROOT_SHRINES"},
		{"id":"LOC_FOREST_ROOT_SHRINE_C","label":"Raiz Central","kind":"root_shrine","pos":Vector2(24000,30200),"scale":1.0,"parent":"LOC_FOREST_ROOT_SHRINES"},
		{"id":"LOC_FOREST_ROOT_SHRINE_E","label":"Raiz Leste","kind":"root_shrine","pos":Vector2(29000,31900),"scale":1.0,"parent":"LOC_FOREST_ROOT_SHRINES"}
	]

static func route_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(23000,45800),
		Vector2(23000,43800),
		Vector2(24400,40700),
		Vector2(25800,37400),
		Vector2(24800,34400),
		Vector2(24000,30200),
		Vector2(23600,27000),
		Vector2(23000,23500),
		Vector2(21000,20800),
		Vector2(17500,17500),
		Vector2(20500,14800),
		Vector2(24500,13200),
		Vector2(29200,11400),
		Vector2(31800,9600)
	])

static func optional_pois() -> Array[Dictionary]:
	return [
		{"id":"POI_FOREST_MOSS_CAMP","label":"Acampamento Musgoso","kind":"campfire","pos":Vector2(21500,39700),"scale":1.0},
		{"id":"POI_FOREST_FALLEN_TOWER","label":"Torre Tomada por Raízes","kind":"ruin","pos":Vector2(27800,35000),"scale":1.25},
		{"id":"POI_FOREST_SILVER_POOL","label":"Lago Prateado","kind":"shrine","pos":Vector2(20500,27900),"scale":0.95},
		{"id":"POI_FOREST_HUNTER_CACHE","label":"Esconderijo dos Guardas","kind":"chest","pos":Vector2(26700,25500),"scale":0.9},
		{"id":"POI_FOREST_OLD_WATCH","label":"Vigia Antiga","kind":"ruin","pos":Vector2(15500,21400),"scale":1.15},
		{"id":"POI_FOREST_GREEN_ALTAR","label":"Altar Verde","kind":"shrine","pos":Vector2(25000,17100),"scale":1.0},
		{"id":"POI_FOREST_VEIL_MARK","label":"Marco do Véu","kind":"sign","pos":Vector2(31800,9600),"scale":1.0}
	]

static func encounters() -> Array[Dictionary]:
	return [
		{"kind":"wolf","name":"Lobo de Musgo","pos":Vector2(23800,40500),"hp":58,"speed":96.0,"damage":10,"scale":1.05},
		{"kind":"goblin","name":"Saqueador Verde","pos":Vector2(25100,38800),"hp":62,"speed":82.0,"damage":11,"scale":1.05},
		{"kind":"slime","name":"Gosma de Esporo","pos":Vector2(22800,33300),"hp":48,"speed":60.0,"damage":8,"scale":1.10},
		{"kind":"wolf","name":"Lobo da Memória","pos":Vector2(21900,25700),"hp":70,"speed":100.0,"damage":12,"scale":1.10},
		{"kind":"guardian","name":"Arauto da Raiz Oca","pos":Vector2(17500,17500),"hp":220,"speed":64.0,"damage":20,"scale":1.45,"story_tag":"story_hollow_root","boss_id":"BOSS_RAIZ_OCA_001"}
	]
