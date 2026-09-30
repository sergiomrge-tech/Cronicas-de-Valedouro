class_name ValedouroCartoonCorruptedStoryMap
extends RefCounted

static func locations() -> Array[Dictionary]:
	return [
		{"id":"LOC_LAST_BASTION","label":"Último Bastião","kind":"last_bastion","pos":Vector2(5200,42000),"scale":1.28,"quest":"Q_MS07_LAST_BASTION","radius":900.0},
		{"id":"LOC_WAR_OBELISKS","label":"Três Obeliscos de Guerra","kind":"war_obelisk","pos":Vector2(14500,34300),"scale":1.15,"quest":"Q_MS07_OBELISKS","radius":1100.0},
		{"id":"LOC_BROKEN_CATHEDRAL","label":"Catedral Partida","kind":"broken_cathedral","pos":Vector2(23200,27000),"scale":1.30,"quest":"Q_MS07_CATHEDRAL","radius":1050.0},
		{"id":"LOC_ALLIANCE_WAR_COUNCIL","label":"Conselho de Guerra das Seis Coroas","kind":"alliance_council","pos":Vector2(31500,19000),"scale":1.28,"quest":"Q_MS07_COUNCIL","radius":1000.0},
		{"id":"LOC_HOLLOW_CROWN_CITADEL","label":"Cidadela da Coroa Oca","kind":"hollow_crown_citadel","pos":Vector2(39800,9500),"scale":1.38,"quest":"Q_MS07_GENERAL_VOID","radius":1200.0}
	]

static func obelisks() -> Array[Dictionary]:
	return [
		{"id":"LOC_WAR_OBELISK_W","label":"Obelisco Oeste","kind":"war_obelisk","pos":Vector2(12100,35200),"scale":1.0,"parent":"LOC_WAR_OBELISKS"},
		{"id":"LOC_WAR_OBELISK_C","label":"Obelisco Central","kind":"war_obelisk","pos":Vector2(14500,33300),"scale":1.0,"parent":"LOC_WAR_OBELISKS"},
		{"id":"LOC_WAR_OBELISK_E","label":"Obelisco Leste","kind":"war_obelisk","pos":Vector2(16900,35000),"scale":1.0,"parent":"LOC_WAR_OBELISKS"}
	]

static func route_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(2500,44700),
		Vector2(5200,42000),
		Vector2(9200,38200),
		Vector2(14500,34300),
		Vector2(18800,30700),
		Vector2(23200,27000),
		Vector2(27500,22900),
		Vector2(31500,19000),
		Vector2(35500,14300),
		Vector2(39800,9500),
		Vector2(43000,5200)
	])

static func optional_pois() -> Array[Dictionary]:
	return [
		{"id":"POI_CORRUPTED_MEDIC_CAMP","label":"Posto de Socorro","kind":"campfire","pos":Vector2(7600,39800),"scale":1.0},
		{"id":"POI_CORRUPTED_TRENCH","label":"Trincheira Abandonada","kind":"ruin","pos":Vector2(10400,37000),"scale":1.0},
		{"id":"POI_CORRUPTED_ECHO_SCAR","label":"Cicatriz de Eco","kind":"shrine","pos":Vector2(18600,32200),"scale":1.0},
		{"id":"POI_CORRUPTED_FIELD_GRAVE","label":"Campo dos Sem-Nome","kind":"ruin","pos":Vector2(25500,24800),"scale":1.05},
		{"id":"POI_CORRUPTED_SUPPLY","label":"Depósito da Aliança","kind":"chest","pos":Vector2(29200,21100),"scale":0.95},
		{"id":"POI_CORRUPTED_VOID_MARK","label":"Marco do Eco Vazio","kind":"shrine","pos":Vector2(36200,13000),"scale":1.0},
		{"id":"POI_CORRUPTED_ABYSS_ROUTE","label":"Portão do Último Mapa","kind":"sign","pos":Vector2(43000,5200),"scale":1.0}
	]

static func zones() -> Array[Dictionary]:
	return [
		{"zone_kind":"bastion","pos":Vector2(5200,42000),"radius":1050.0},
		{"zone_kind":"obelisks","pos":Vector2(14500,34300),"radius":1350.0},
		{"zone_kind":"cathedral","pos":Vector2(23200,27000),"radius":1250.0},
		{"zone_kind":"council","pos":Vector2(31500,19000),"radius":1180.0},
		{"zone_kind":"citadel","pos":Vector2(39800,9500),"radius":1400.0}
	]

static func encounters() -> Array[Dictionary]:
	return [
		{"kind":"goblin","name":"Soldado Corrompido","pos":Vector2(8500,38900),"hp":160,"speed":88.0,"damage":22,"scale":1.18},
		{"kind":"wolf","name":"Fera da Frente","pos":Vector2(11000,36500),"hp":168,"speed":102.0,"damage":22,"scale":1.22},
		{"kind":"guardian","name":"Guardião do Obelisco","pos":Vector2(14500,34300),"hp":210,"speed":64.0,"damage":25,"scale":1.28},
		{"kind":"guardian","name":"Sentinela da Catedral","pos":Vector2(23200,27800),"hp":220,"speed":66.0,"damage":25,"scale":1.30},
		{"kind":"goblin","name":"Assaltante da Coroa Oca","pos":Vector2(30700,20000),"hp":176,"speed":90.0,"damage":23,"scale":1.20},
		{"kind":"void_general","name":"General do Eco Vazio","pos":Vector2(39800,9500),"hp":480,"speed":78.0,"damage":33,"scale":1.58,"story_tag":"story_void_general","boss_id":"BOSS_GENERAL_ECO_VAZIO_001"}
	]
