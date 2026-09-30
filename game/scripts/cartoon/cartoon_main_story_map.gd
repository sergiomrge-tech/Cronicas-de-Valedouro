class_name ValedouroCartoonMainStoryMap
extends RefCounted

const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")

# Regra: toda localização da missão principal deve existir fisicamente no mapa.
# Este arquivo é a ponte entre o cânone da campanha e a reconstrução cartoon.

static func act1_locations() -> Array[Dictionary]:
	var cx: float = Region.SOUTH_ROAD_X
	var north_edge: float = Region.HUB_RECT.position.y
	return [
		{
			"id":"LOC_VAL_GATE",
			"label":"Portão de Valedouro",
			"kind":"gate",
			"pos":Region.world_from_hub(Vector2(1150,320)),
			"scale":1.18,
			"quest":"Q_MS01_ARRIVAL"
		},
		{
			"id":"LOC_VAL_GUILD",
			"label":"Guilda dos Aventureiros",
			"kind":"guild",
			"pos":Region.world_from_hub(Vector2(760,1125)),
			"scale":1.22,
			"quest":"Q_MS01_GUILD"
		},
		{
			"id":"LOC_VAL_NORTH_ROAD",
			"label":"Estrada Norte",
			"kind":"sign",
			"pos":Vector2(cx,north_edge-650.0),
			"scale":1.0,
			"quest":"Q_MS01_WOLVES"
		},
		{
			"id":"LOC_FIRST_WIND_RUINS",
			"label":"Ruínas do Primeiro Vento",
			"kind":"ruin",
			"pos":Vector2(cx-620.0,north_edge-1800.0),
			"scale":1.45,
			"quest":"Q_MS01_FIRST_WIND"
		},
		{
			"id":"LOC_ALPHA_CLEARING",
			"label":"Clareira do Alfa",
			"kind":"arena",
			"pos":Vector2(cx+760.0,north_edge-2950.0),
			"scale":1.25,
			"quest":"Q_MS01_ALPHA"
		},
		{
			"id":"LOC_ECHO_MINE",
			"label":"Mina do Eco",
			"kind":"mine",
			"pos":Vector2(cx-980.0,north_edge-4100.0),
			"scale":1.35,
			"quest":"Q_MS01_MINE"
		},
		{
			"id":"LOC_ECHO_MINE_CORE",
			"label":"Câmara do Guardião",
			"kind":"boss_gate",
			"pos":Vector2(cx-980.0,north_edge-4460.0),
			"scale":1.15,
			"quest":"Q_MS01_GUARDIAN",
			"instanced":true
		},
		{
			"id":"LOC_SIX_CROWNS_ARCHIVE",
			"label":"Arquivo das Seis Coroas",
			"kind":"archive",
			"pos":Vector2(cx+940.0,north_edge-5350.0),
			"scale":1.30,
			"quest":"Q_MS01_ARCHIVE"
		}
	]

static func required_ids_by_act() -> Dictionary:
	return {
		1:["LOC_VAL_GATE","LOC_VAL_GUILD","LOC_VAL_NORTH_ROAD","LOC_FIRST_WIND_RUINS","LOC_ALPHA_CLEARING","LOC_ECHO_MINE","LOC_ECHO_MINE_CORE","LOC_SIX_CROWNS_ARCHIVE"],
		2:["LOC_FOREST_STONE_BRIDGE","LOC_FOREST_RANGER_LODGE","LOC_FOREST_ROOT_SHRINES","LOC_MEMORY_TREE","LOC_HOLLOW_ROOT_ARENA","LOC_FOREST_CARTOGRAPHER_SHRINE"],
		3:["LOC_AMBER_CARAVAN","LOC_AMBER_POST","LOC_EDRAVAR_OCCUPIED_CITY","LOC_EDRAVAR_RESISTANCE_CISTERN","LOC_ASH_OBSERVATORY","LOC_ASH_CITADEL"],
		4:["LOC_MARSH_STILT_VILLAGE","LOC_DROWNED_BELL_TOWER","LOC_FLOODED_MONASTERY","LOC_REED_SANCTUM","LOC_REED_THRONE","LOC_MARSH_ECHO_SLICE"],
		5:["LOC_FROST_REST","LOC_FROZEN_EXPEDITION_STATION","LOC_FROZEN_COMMAND_POST","LOC_FROZEN_ARCHIVE","LOC_BLACK_FROST_CITADEL","LOC_VAL_GATE"],
		6:["LOC_MIST_PORT","LOC_TWIN_LIGHTHOUSE","LOC_SUNKEN_TEMPLE","LOC_LOST_ISLAND_SHIPYARD","LOC_TIDAL_OBSERVATORY"],
		7:["LOC_LAST_BASTION","LOC_WAR_OBELISKS","LOC_BROKEN_CATHEDRAL","LOC_ALLIANCE_WAR_COUNCIL","LOC_HOLLOW_CROWN_CITADEL"],
		8:["LOC_LAST_MAP_GATE","LOC_HALL_LOST_PATHS","LOC_VOID_ARCHIVE","LOC_EMPTY_THRONE_ANTECHAMBER","LOC_EMPTY_THRONE","LOC_EARTH_GATE"]
	}


static func act1_zones() -> Array[Dictionary]:
	var cx: float = Region.SOUTH_ROAD_X
	var north_edge: float = Region.HUB_RECT.position.y
	return [
		{"zone_kind":"north_road","label":"Estrada Norte","pos":Vector2(cx,north_edge-650.0),"radius":250.0},
		{"zone_kind":"first_wind","label":"Ruínas do Primeiro Vento","pos":Vector2(cx-620.0,north_edge-1800.0),"radius":280.0},
		{"zone_kind":"alpha","label":"Clareira do Alfa","pos":Vector2(cx+760.0,north_edge-2950.0),"radius":300.0},
		{"zone_kind":"mine","label":"Mina do Eco","pos":Vector2(cx-980.0,north_edge-4100.0),"radius":310.0},
		{"zone_kind":"archive","label":"Arquivo das Seis Coroas","pos":Vector2(cx+940.0,north_edge-5350.0),"radius":300.0}
	]


static func act1_encounters() -> Array[Dictionary]:
	var cx: float = Region.SOUTH_ROAD_X
	var north_edge: float = Region.HUB_RECT.position.y
	return [
		{"kind":"wolf","name":"Lobo do Eco","pos":Vector2(cx-145.0,north_edge-760.0),"hp":38,"speed":92.0,"damage":8,"scale":1.02,"story_tag":"story_wolf"},
		{"kind":"wolf","name":"Lobo do Eco","pos":Vector2(cx+125.0,north_edge-930.0),"hp":38,"speed":92.0,"damage":8,"scale":1.02,"story_tag":"story_wolf"},
		{"kind":"wolf","name":"Lobo do Eco","pos":Vector2(cx-60.0,north_edge-1130.0),"hp":40,"speed":94.0,"damage":8,"scale":1.05,"story_tag":"story_wolf"},
		{"kind":"wolf","name":"Alfa da Matilha","pos":Vector2(cx+760.0,north_edge-2950.0),"hp":105,"speed":102.0,"damage":15,"scale":1.32,"story_tag":"story_alpha","boss_id":"BOSS_ALPHA_MATILHA_001"},
		{"kind":"guardian","name":"Guardião do Eco","pos":Vector2(cx-980.0,north_edge-4460.0),"hp":175,"speed":58.0,"damage":18,"scale":1.25,"story_tag":"story_guardian","boss_id":"BOSS_GUARDIAO_PEDRA_001"}
	]


static func region_transitions() -> Array[Dictionary]:
	return [
		{
			"id":"TRANSITION_FOREST_ANCESTRAL",
			"label":"Passagem para a Floresta Ancestral",
			"kind":"gate",
			"pos":Vector2(Region.SOUTH_ROAD_X,700.0),
			"scale":1.05,
			"quest":"Q_MS02_BORDER",
			"next_scene":"res://scenes/cartoon/ForestAncientCartoon.tscn"
		}
	]
