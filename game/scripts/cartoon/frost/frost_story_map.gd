class_name ValedouroCartoonFrostStoryMap
extends RefCounted

static func locations() -> Array[Dictionary]:
	return [
		{"id":"LOC_FROST_REST","label":"Pouso da Geada","kind":"frost_rest","pos":Vector2(4200,31400),"scale":1.22,"quest":"Q_MS05_FROST_REST","radius":620.0},
		{"id":"LOC_FROZEN_EXPEDITION_STATION","label":"Estação da Expedição","kind":"frozen_station","pos":Vector2(9500,26800),"scale":1.24,"quest":"Q_MS05_EXPEDITION","radius":650.0},
		{"id":"LOC_FROZEN_COMMAND_POST","label":"Posto do Capitão","kind":"frozen_command","pos":Vector2(14500,21900),"scale":1.28,"quest":"Q_MS05_CAPTAIN","radius":720.0},
		{"id":"LOC_FROZEN_ARCHIVE","label":"Arquivo Congelado","kind":"frozen_archive","pos":Vector2(19800,16900),"scale":1.22,"quest":"Q_MS05_ARCHIVE","radius":620.0},
		{"id":"LOC_BLACK_FROST_CITADEL","label":"Cidadela da Geada Negra","kind":"black_frost_citadel","pos":Vector2(26600,10400),"scale":1.34,"quest":"Q_MS05_BLACK_FROST","radius":900.0},
		{"id":"LOC_VAL_GATE","label":"Retorno às Muralhas de Valedouro","kind":"return_gate","pos":Vector2(31600,4200),"scale":1.12,"quest":"Q_MS05_SIEGE","radius":600.0}
	]

static func route_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(2100,33400),
		Vector2(4200,31400),
		Vector2(6800,29100),
		Vector2(9500,26800),
		Vector2(11900,24500),
		Vector2(14500,21900),
		Vector2(16900,19300),
		Vector2(19800,16900),
		Vector2(23100,13700),
		Vector2(26600,10400),
		Vector2(29000,7600),
		Vector2(31600,4200)
	])

static func optional_pois() -> Array[Dictionary]:
	return [
		{"id":"POI_FROST_HUNTER_FIRE","label":"Fogueira dos Caçadores","kind":"campfire","pos":Vector2(6500,29900),"scale":1.0},
		{"id":"POI_FROST_STONE_MARKER","label":"Marco Proibido","kind":"shrine","pos":Vector2(8300,28100),"scale":0.95},
		{"id":"POI_FROST_LOST_SLED","label":"Trenó Abandonado","kind":"chest","pos":Vector2(11700,23800),"scale":0.9},
		{"id":"POI_FROST_ICE_CAVE","label":"Gruta de Gelo","kind":"mine","pos":Vector2(16900,18400),"scale":0.9},
		{"id":"POI_FROST_FROZEN_WATCH","label":"Vigia Congelada","kind":"ruin","pos":Vector2(22400,14800),"scale":1.0},
		{"id":"POI_FROST_BLACK_ICE_FIELD","label":"Campo de Gelo Negro","kind":"rock","pos":Vector2(24800,11900),"scale":1.35},
		{"id":"POI_FROST_RETURN_ROUTE","label":"Rota de Retorno a Valedouro","kind":"sign","pos":Vector2(31600,4200),"scale":1.0}
	]

static func zones() -> Array[Dictionary]:
	return [
		{"zone_kind":"rest","pos":Vector2(4200,31400),"radius":760.0},
		{"zone_kind":"station","pos":Vector2(9500,26800),"radius":780.0},
		{"zone_kind":"captain","pos":Vector2(14500,21900),"radius":850.0},
		{"zone_kind":"archive","pos":Vector2(19800,16900),"radius":760.0},
		{"zone_kind":"citadel","pos":Vector2(26600,10400),"radius":1020.0},
		{"zone_kind":"return","pos":Vector2(31600,4200),"radius":700.0}
	]

static func encounters() -> Array[Dictionary]:
	return [
		{"kind":"wolf","name":"Lobo da Geada","pos":Vector2(7200,28600),"hp":116,"speed":102.0,"damage":17,"scale":1.18},
		{"kind":"guardian","name":"Sentinela Congelada","pos":Vector2(10100,25800),"hp":148,"speed":60.0,"damage":19,"scale":1.20},
		{"kind":"frost_captain","name":"Último Capitão","pos":Vector2(14500,21900),"hp":260,"speed":76.0,"damage":24,"scale":1.42,"story_tag":"story_frost_captain","boss_id":"BOSS_CAPITAO_GELO_001"},
		{"kind":"slime","name":"Eco Congelado","pos":Vector2(21000,15800),"hp":98,"speed":58.0,"damage":15,"scale":1.18},
		{"kind":"black_frost_general","name":"General da Geada Negra","pos":Vector2(26600,10400),"hp":360,"speed":74.0,"damage":28,"scale":1.52,"story_tag":"story_black_frost","boss_id":"BOSS_GENERAL_GEADA_NEGRA_001"}
	]
