class_name ValedouroCartoonCoastStoryMap
extends RefCounted

static func locations() -> Array[Dictionary]:
	return [
		{"id":"LOC_MIST_PORT","label":"Porto das Brumas","kind":"mist_port","pos":Vector2(5200,42500),"scale":1.25,"quest":"Q_MS06_MIST_PORT","radius":760.0},
		{"id":"LOC_TWIN_LIGHTHOUSE","label":"Farol Gêmeo","kind":"twin_lighthouse","pos":Vector2(12500,35600),"scale":1.28,"quest":"Q_MS06_LIGHTHOUSE","radius":720.0},
		{"id":"LOC_SUNKEN_TEMPLE","label":"Templo Submerso","kind":"sunken_temple","pos":Vector2(22200,28600),"scale":1.30,"quest":"Q_MS06_SUNKEN_TEMPLE","radius":900.0},
		{"id":"LOC_LOST_ISLAND_SHIPYARD","label":"Estaleiro das Ilhas Perdidas","kind":"lost_shipyard","pos":Vector2(32000,20500),"scale":1.28,"quest":"Q_MS06_HOLLOW_FLEET","radius":900.0},
		{"id":"LOC_TIDAL_OBSERVATORY","label":"Observatório das Marés","kind":"tidal_observatory","pos":Vector2(39800,9800),"scale":1.34,"quest":"Q_MS06_GENERAL_TIDE","radius":980.0}
	]

static func route_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(2600,44700),
		Vector2(5200,42500),
		Vector2(8700,39200),
		Vector2(12500,35600),
		Vector2(16900,32500),
		Vector2(22200,28600),
		Vector2(26900,24700),
		Vector2(32000,20500),
		Vector2(35500,15800),
		Vector2(39800,9800),
		Vector2(42900,5700)
	])

static func optional_pois() -> Array[Dictionary]:
	return [
		{"id":"POI_COAST_FISHER_CAMP","label":"Acampamento dos Pescadores","kind":"campfire","pos":Vector2(7900,40200),"scale":1.0},
		{"id":"POI_COAST_WRECK","label":"Naufrágio das Brumas","kind":"ruin","pos":Vector2(15600,33900),"scale":1.10},
		{"id":"POI_COAST_TIDE_POOL","label":"Poço de Maré","kind":"shrine","pos":Vector2(19700,30500),"scale":0.95},
		{"id":"POI_COAST_CORAL_GATE","label":"Arco de Coral","kind":"ruin","pos":Vector2(25300,26300),"scale":1.05},
		{"id":"POI_COAST_HOLLOW_BEACON","label":"Sinal da Frota Oca","kind":"shrine","pos":Vector2(29500,22600),"scale":0.95},
		{"id":"POI_COAST_SEA_CAVE","label":"Caverna da Maré","kind":"mine","pos":Vector2(34700,17400),"scale":0.95},
		{"id":"POI_COAST_CORRUPTED_ROUTE","label":"Rota para as Terras Corrompidas","kind":"sign","pos":Vector2(42900,5700),"scale":1.0}
	]

static func zones() -> Array[Dictionary]:
	return [
		{"zone_kind":"port","pos":Vector2(5200,42500),"radius":900.0},
		{"zone_kind":"lighthouse","pos":Vector2(12500,35600),"radius":860.0},
		{"zone_kind":"temple","pos":Vector2(22200,28600),"radius":1080.0},
		{"zone_kind":"shipyard","pos":Vector2(32000,20500),"radius":1080.0},
		{"zone_kind":"observatory","pos":Vector2(39800,9800),"radius":1180.0}
	]

static func encounters() -> Array[Dictionary]:
	return [
		{"kind":"slime","name":"Gosma de Sal","pos":Vector2(9300,38400),"hp":118,"speed":62.0,"damage":17,"scale":1.18},
		{"kind":"goblin","name":"Saqueador da Costa","pos":Vector2(14800,34400),"hp":126,"speed":84.0,"damage":18,"scale":1.16},
		{"kind":"guardian","name":"Guardião do Templo","pos":Vector2(21900,29400),"hp":180,"speed":62.0,"damage":21,"scale":1.24},
		{"kind":"goblin","name":"Corsário Oco","pos":Vector2(31200,21600),"hp":142,"speed":88.0,"damage":20,"scale":1.18,"story_tag":"hollow_fleet"},
		{"kind":"goblin","name":"Corsário Oco","pos":Vector2(32900,21500),"hp":142,"speed":88.0,"damage":20,"scale":1.18,"story_tag":"hollow_fleet"},
		{"kind":"wolf","name":"Fera Marinha Oca","pos":Vector2(32100,19300),"hp":150,"speed":98.0,"damage":21,"scale":1.20,"story_tag":"hollow_fleet"},
		{"kind":"guardian","name":"Quebrador de Casco","pos":Vector2(33500,19800),"hp":190,"speed":64.0,"damage":23,"scale":1.24,"story_tag":"hollow_fleet"},
		{"kind":"tide_general","name":"General da Maré Oca","pos":Vector2(39800,9800),"hp":410,"speed":76.0,"damage":30,"scale":1.54,"story_tag":"story_tide_general","boss_id":"BOSS_GENERAL_MARE_OCA_001"}
	]
