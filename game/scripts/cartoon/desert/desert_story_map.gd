class_name ValedouroCartoonDesertStoryMap
extends RefCounted

static func locations() -> Array[Dictionary]:
	return [
		{"id":"LOC_AMBER_CARAVAN","label":"Caravana de Âmbar","kind":"amber_caravan","pos":Vector2(3600,31500),"scale":1.18,"quest":"Q_MS03_CARAVAN","radius":420.0},
		{"id":"LOC_AMBER_POST","label":"Posto de Âmbar","kind":"amber_post","pos":Vector2(8200,27800),"scale":1.22,"quest":"Q_MS03_AMBER_POST","radius":500.0},
		{"id":"LOC_EDRAVAR_OCCUPIED_CITY","label":"Edravar Ocupada","kind":"edravar_city","pos":Vector2(16800,22200),"scale":1.28,"quest":"Q_MS03_EDRAVAR","radius":860.0},
		{"id":"LOC_EDRAVAR_RESISTANCE_CISTERN","label":"Cisterna da Resistência","kind":"resistance_cistern","pos":Vector2(15100,18700),"scale":1.10,"quest":"Q_MS03_CISTERN","radius":440.0},
		{"id":"LOC_ASH_OBSERVATORY","label":"Observatório de Cinzas","kind":"ash_observatory","pos":Vector2(24400,13800),"scale":1.24,"quest":"Q_MS03_OBSERVATORY","radius":620.0},
		{"id":"LOC_ASH_CITADEL","label":"Cidadela da Cinza","kind":"ash_citadel","pos":Vector2(30100,6500),"scale":1.32,"quest":"Q_MS03_GENERAL_ASH","radius":820.0}
	]

static func route_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(1500,33400),
		Vector2(3600,31500),
		Vector2(5900,29600),
		Vector2(8200,27800),
		Vector2(11500,25200),
		Vector2(16800,22200),
		Vector2(15100,18700),
		Vector2(18800,16600),
		Vector2(24400,13800),
		Vector2(27000,10200),
		Vector2(30100,6500),
		Vector2(32900,4200)
	])

static func optional_pois() -> Array[Dictionary]:
	return [
		{"id":"POI_DESERT_WATER_CACHE","label":"Poço da Rota Âmbar","kind":"well","pos":Vector2(5700,30500),"scale":0.95},
		{"id":"POI_DESERT_BROKEN_ARCH","label":"Arco Partido","kind":"ruin","pos":Vector2(10900,26800),"scale":1.15},
		{"id":"POI_DESERT_SCAVENGER_CAMP","label":"Acampamento de Catadores","kind":"campfire","pos":Vector2(12800,23700),"scale":1.0},
		{"id":"POI_EDRAVAR_MARKET_RUINS","label":"Mercado em Ruínas","kind":"market","pos":Vector2(17900,22900),"scale":1.05},
		{"id":"POI_EDRAVAR_SECRET_STEPS","label":"Escadaria Selada","kind":"ruin","pos":Vector2(14200,20300),"scale":1.0},
		{"id":"POI_DESERT_GLASS_FIELD","label":"Campo de Vidro","kind":"rock","pos":Vector2(21100,15400),"scale":1.35},
		{"id":"POI_ASH_WATCHTOWER","label":"Torre de Vigia da Cinza","kind":"ruin","pos":Vector2(27300,9200),"scale":1.20},
		{"id":"POI_DESERT_MARSH_ROUTE","label":"Rota para os Pântanos","kind":"sign","pos":Vector2(32900,4200),"scale":1.0}
	]

static func zones() -> Array[Dictionary]:
	return [
		{"zone_kind":"caravan","label":"Rota da Caravana","pos":Vector2(3600,31500),"radius":520.0},
		{"zone_kind":"outpost","label":"Posto de Âmbar","pos":Vector2(8200,27800),"radius":650.0},
		{"zone_kind":"city","label":"Edravar Ocupada","pos":Vector2(16800,22200),"radius":980.0},
		{"zone_kind":"cistern","label":"Cisterna da Resistência","pos":Vector2(15100,18700),"radius":560.0},
		{"zone_kind":"observatory","label":"Observatório de Cinzas","pos":Vector2(24400,13800),"radius":760.0},
		{"zone_kind":"citadel","label":"Cidadela da Cinza","pos":Vector2(30100,6500),"radius":980.0}
	]

static func encounters() -> Array[Dictionary]:
	return [
		{"kind":"goblin","name":"Saqueador da Areia","pos":Vector2(6500,29200),"hp":78,"speed":86.0,"damage":13,"scale":1.10},
		{"kind":"slime","name":"Gosma de Vidro","pos":Vector2(11300,25000),"hp":68,"speed":62.0,"damage":11,"scale":1.14},
		{"kind":"goblin","name":"Soldado de Ocupação","pos":Vector2(16300,23000),"hp":88,"speed":82.0,"damage":14,"scale":1.12,"story_tag":"edravar_guard"},
		{"kind":"goblin","name":"Soldado de Ocupação","pos":Vector2(17400,21700),"hp":88,"speed":82.0,"damage":14,"scale":1.12,"story_tag":"edravar_guard"},
		{"kind":"guardian","name":"Sentinela do Observatório","pos":Vector2(23900,14400),"hp":120,"speed":66.0,"damage":16,"scale":1.18,"story_tag":"ash_observatory_guard"},
		{"kind":"ash_general","name":"General da Cinza","pos":Vector2(30100,6500),"hp":280,"speed":72.0,"damage":24,"scale":1.48,"story_tag":"story_ash_general","boss_id":"BOSS_GENERAL_CINZA_001"}
	]
