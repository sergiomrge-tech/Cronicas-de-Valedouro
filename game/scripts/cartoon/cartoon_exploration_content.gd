class_name ValedouroCartoonExplorationContent
extends RefCounted

const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")

static func landmarks() -> Array[Dictionary]:
	var x: float = Region.SOUTH_ROAD_X
	var y0: float = Region.HUB_RECT.end.y
	return [
		{"id":"POI_REG001_ROADSIDE_POST","label":"Posto da Estrada","kind":"house","pos":Vector2(x-330.0,y0+1350.0),"scale":1.0},
		{"id":"POI_REG001_PILGRIM_MARK","label":"Marco dos Peregrinos","kind":"sign","pos":Vector2(x+180.0,y0+2850.0),"scale":1.05},
		{"id":"POI_REG001_WEST_CAMP","label":"Acampamento do Vale","kind":"market","pos":Vector2(x-2050.0,y0+2150.0),"scale":1.05},
		{"id":"POI_REG001_OLD_RUINS","label":"Ruínas do Caminho Antigo","kind":"ruin","pos":Vector2(x+1950.0,y0+4100.0),"scale":1.25},
		{"id":"POI_REG001_SOUTH_WAYSHRINE","label":"Santuário da Estrada Sul","kind":"shrine","pos":Vector2(x-220.0,y0+6100.0),"scale":1.10},
		{"id":"POI_REG001_HUNTER_CAMP","label":"Acampamento dos Caçadores","kind":"campfire","pos":Vector2(x-2650.0,y0+4550.0),"scale":1.0},
		{"id":"POI_REG001_EAST_QUARRY","label":"Pedreira Abandonada","kind":"rock","pos":Vector2(x+2850.0,y0+5050.0),"scale":1.45}
	]

static func encounters() -> Array[Dictionary]:
	var x: float = Region.SOUTH_ROAD_X
	var y0: float = Region.HUB_RECT.end.y
	return [
		{"kind":"wolf","name":"Lobo Cinzento","pos":Vector2(x-180.0,y0+1100.0),"hp":42,"speed":92.0,"damage":8,"scale":1.05},
		{"kind":"wolf","name":"Lobo Cinzento","pos":Vector2(x+260.0,y0+1650.0),"hp":42,"speed":92.0,"damage":8,"scale":1.05},
		{"kind":"goblin","name":"Saqueador da Estrada","pos":Vector2(x-900.0,y0+2600.0),"hp":52,"speed":80.0,"damage":10,"scale":1.05},
		{"kind":"goblin","name":"Saqueador da Estrada","pos":Vector2(x-760.0,y0+2740.0),"hp":52,"speed":80.0,"damage":10,"scale":1.05},
		{"kind":"slime","name":"Gosma do Brejo","pos":Vector2(x+1500.0,y0+3900.0),"hp":38,"speed":56.0,"damage":7,"scale":1.1},
		{"kind":"wolf","name":"Lobo Alfa","pos":Vector2(x-2200.0,y0+4400.0),"hp":74,"speed":102.0,"damage":13,"scale":1.18},
		{"kind":"goblin","name":"Batedor Goblin","pos":Vector2(x+700.0,y0+5900.0),"hp":62,"speed":86.0,"damage":11,"scale":1.08}
	]
