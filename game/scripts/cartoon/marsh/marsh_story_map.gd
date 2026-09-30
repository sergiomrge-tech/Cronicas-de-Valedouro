class_name ValedouroCartoonMarshStoryMap
extends RefCounted

static func locations() -> Array[Dictionary]:
	return [
		{"id":"LOC_MARSH_STILT_VILLAGE","label":"Vila das Lanternas","kind":"stilt_village","pos":Vector2(31000,31500),"scale":1.22,"quest":"Q_MS04_STILTS","radius":620.0},
		{"id":"LOC_DROWNED_BELL_TOWER","label":"Torre do Sino Afogado","kind":"drowned_bell","pos":Vector2(25500,27800),"scale":1.24,"quest":"Q_MS04_BELL","radius":560.0},
		{"id":"LOC_FLOODED_MONASTERY","label":"Mosteiro Inundado","kind":"flooded_monastery","pos":Vector2(19500,22800),"scale":1.28,"quest":"Q_MS04_MONASTERY","radius":760.0},
		{"id":"LOC_REED_SANCTUM","label":"Santuário dos Juncos","kind":"reed_sanctum","pos":Vector2(14200,16800),"scale":1.24,"quest":"Q_MS04_REED_SANCTUM","radius":650.0},
		{"id":"LOC_REED_THRONE","label":"Trono dos Juncos","kind":"reed_throne","pos":Vector2(9200,10800),"scale":1.32,"quest":"Q_MS04_LADY_REEDS","radius":820.0},
		{"id":"LOC_MARSH_ECHO_SLICE","label":"Comporta dos Ecos","kind":"echo_sluice","pos":Vector2(4300,5200),"scale":1.28,"quest":"Q_MS04_SLICE_GATE","radius":720.0}
	]

static func route_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(33200,33400),
		Vector2(31000,31500),
		Vector2(28400,29900),
		Vector2(25500,27800),
		Vector2(22600,25000),
		Vector2(19500,22800),
		Vector2(16600,19800),
		Vector2(14200,16800),
		Vector2(11600,13900),
		Vector2(9200,10800),
		Vector2(6800,7900),
		Vector2(4300,5200),
		Vector2(2100,2600)
	])

static func optional_pois() -> Array[Dictionary]:
	return [
		{"id":"POI_MARSH_FERRY","label":"Balsa das Lanternas","kind":"bridge","pos":Vector2(28600,30400),"scale":1.0},
		{"id":"POI_MARSH_MEMORY_POOL","label":"Poça das Memórias","kind":"shrine","pos":Vector2(27100,25700),"scale":0.95},
		{"id":"POI_MARSH_SUNKEN_GRAVE","label":"Cemitério Submerso","kind":"ruin","pos":Vector2(21600,21400),"scale":1.12},
		{"id":"POI_MARSH_REED_CAMP","label":"Acampamento dos Juncos","kind":"campfire","pos":Vector2(15800,18300),"scale":1.0},
		{"id":"POI_MARSH_BROKEN_BOARDWALK","label":"Passarela Partida","kind":"bridge","pos":Vector2(12200,14500),"scale":0.9},
		{"id":"POI_MARSH_WITCH_LIGHTS","label":"Luzes Errantes","kind":"shrine","pos":Vector2(7600,12600),"scale":0.9},
		{"id":"POI_MARSH_FROST_ROUTE","label":"Rota para o Norte Gelado","kind":"sign","pos":Vector2(2100,2600),"scale":1.0}
	]

static func zones() -> Array[Dictionary]:
	return [
		{"zone_kind":"village","pos":Vector2(31000,31500),"radius":760.0},
		{"zone_kind":"bell","pos":Vector2(25500,27800),"radius":660.0},
		{"zone_kind":"monastery","pos":Vector2(19500,22800),"radius":900.0},
		{"zone_kind":"sanctum","pos":Vector2(14200,16800),"radius":780.0},
		{"zone_kind":"throne","pos":Vector2(9200,10800),"radius":950.0},
		{"zone_kind":"sluice","pos":Vector2(4300,5200),"radius":840.0}
	]

static func encounters() -> Array[Dictionary]:
	return [
		{"kind":"slime","name":"Gosma de Água Negra","pos":Vector2(29200,29400),"hp":82,"speed":60.0,"damage":12,"scale":1.15},
		{"kind":"goblin","name":"Catador do Brejo","pos":Vector2(23600,25700),"hp":92,"speed":82.0,"damage":14,"scale":1.12},
		{"kind":"guardian","name":"Sentinela do Mosteiro","pos":Vector2(19900,23500),"hp":132,"speed":62.0,"damage":17,"scale":1.20,"story_tag":"monastery_guard"},
		{"kind":"wolf","name":"Fera dos Juncos","pos":Vector2(13200,15700),"hp":104,"speed":98.0,"damage":16,"scale":1.18},
		{"kind":"reed_lady","name":"Dama dos Juncos","pos":Vector2(9200,10800),"hp":320,"speed":70.0,"damage":26,"scale":1.48,"story_tag":"story_reed_lady","boss_id":"BOSS_DAMA_JUNCOS_001"}
	]
