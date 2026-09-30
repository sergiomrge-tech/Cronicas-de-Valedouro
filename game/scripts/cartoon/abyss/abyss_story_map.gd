class_name ValedouroCartoonAbyssStoryMap
extends RefCounted

static func locations() -> Array[Dictionary]:
	return [
		{"id":"LOC_LAST_MAP_GATE","label":"Portão do Último Mapa","kind":"last_map_gate","pos":Vector2(9200,17000),"scale":1.28,"quest":"Q_MS08_LAST_MAP_GATE","radius":720.0},
		{"id":"LOC_HALL_LOST_PATHS","label":"Salão dos Caminhos Perdidos","kind":"lost_paths_hall","pos":Vector2(9200,13900),"scale":1.26,"quest":"Q_MS08_LOST_PATHS","radius":850.0},
		{"id":"LOC_VOID_ARCHIVE","label":"Arquivo do Vazio","kind":"void_archive","pos":Vector2(6100,10400),"scale":1.30,"quest":"Q_MS08_CARTOGRAPHER","radius":900.0},
		{"id":"LOC_EMPTY_THRONE_ANTECHAMBER","label":"Antecâmara do Trono Vazio","kind":"empty_throne_antechamber","pos":Vector2(9200,7500),"scale":1.24,"quest":"Q_MS08_FIRST_TRAVELER","radius":760.0},
		{"id":"LOC_EMPTY_THRONE","label":"Trono da Coroa Oca","kind":"empty_throne","pos":Vector2(9200,4300),"scale":1.36,"quest":"Q_MS08_AZHAREL","radius":1050.0},
		{"id":"LOC_EARTH_GATE","label":"Limiar da Terra","kind":"earth_gate","pos":Vector2(12800,1650),"scale":1.32,"quest":"Q_MS08_EARTH_GATE","radius":820.0}
	]

static func route_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(9200,18100),
		Vector2(9200,17000),
		Vector2(9200,13900),
		Vector2(7600,12100),
		Vector2(6100,10400),
		Vector2(7600,9000),
		Vector2(9200,7500),
		Vector2(9200,4300),
		Vector2(10800,2900),
		Vector2(12800,1650)
	])

static func optional_pois() -> Array[Dictionary]:
	return [
		{"id":"POI_ABYSS_FOREST_MEMORY","label":"Eco da Floresta","kind":"memory_tree","pos":Vector2(7200,15100),"scale":0.8},
		{"id":"POI_ABYSS_DESERT_MEMORY","label":"Eco de Edravar","kind":"ruin","pos":Vector2(10900,12400),"scale":0.8},
		{"id":"POI_ABYSS_MARSH_MEMORY","label":"Eco dos Juncos","kind":"shrine","pos":Vector2(5200,11800),"scale":0.8},
		{"id":"POI_ABYSS_FROST_MEMORY","label":"Eco da Geada","kind":"frozen_archive","pos":Vector2(11600,8500),"scale":0.72},
		{"id":"POI_ABYSS_TIDE_MEMORY","label":"Eco das Marés","kind":"tidal_observatory","pos":Vector2(6800,6900),"scale":0.70},
		{"id":"POI_ABYSS_WAR_MEMORY","label":"Eco da Guerra","kind":"war_obelisk","pos":Vector2(11200,5600),"scale":0.72}
	]

static func zones() -> Array[Dictionary]:
	return [
		{"zone_kind":"gate","pos":Vector2(9200,17000),"radius":860.0},
		{"zone_kind":"paths","pos":Vector2(9200,13900),"radius":1020.0},
		{"zone_kind":"archive","pos":Vector2(6100,10400),"radius":1050.0},
		{"zone_kind":"antechamber","pos":Vector2(9200,7500),"radius":900.0},
		{"zone_kind":"throne","pos":Vector2(9200,4300),"radius":1250.0},
		{"zone_kind":"earth","pos":Vector2(12800,1650),"radius":980.0}
	]

static func encounters() -> Array[Dictionary]:
	return [
		{"kind":"guardian","name":"Sentinela dos Caminhos Perdidos","pos":Vector2(8900,14600),"hp":220,"speed":64.0,"damage":26,"scale":1.28},
		{"kind":"slime","name":"Fragmento de Memória","pos":Vector2(7500,12000),"hp":180,"speed":60.0,"damage":23,"scale":1.20},
		{"kind":"void_cartographer","name":"Cartógrafo Vazio","pos":Vector2(6100,10400),"hp":420,"speed":74.0,"damage":31,"scale":1.52,"story_tag":"story_void_cartographer","boss_id":"BOSS_CARTOGRAFO_VAZIO_001"},
		{"kind":"guardian","name":"Sentinela do Trono","pos":Vector2(9200,6400),"hp":250,"speed":66.0,"damage":28,"scale":1.30},
		{"kind":"azharel","name":"Azharel","pos":Vector2(9200,4300),"hp":620,"speed":82.0,"damage":38,"scale":1.62,"story_tag":"story_azharel","boss_id":"BOSS_AZHAREL_001"}
	]
