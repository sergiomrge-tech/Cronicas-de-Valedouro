extends SceneTree

const BLUEPRINT_PATH: String = "res://data/cartoon_campaign_map_blueprint_v1.json"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var file: FileAccess = FileAccess.open(BLUEPRINT_PATH,FileAccess.READ)
	assert(file != null)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary)
	var regions: Array = (parsed as Dictionary).get("regions",[])
	assert(regions.size() == 8)

	var quest_total: int = 0
	var expected_scenes: Dictionary = {
		1:"res://scenes/cartoon/ValedouroCartoonHub.tscn",
		2:"res://scenes/cartoon/ForestAncientCartoon.tscn",
		3:"res://scenes/cartoon/DesertEdravarCartoon.tscn",
		4:"res://scenes/cartoon/MarshDarkCartoon.tscn",
		5:"res://scenes/cartoon/FrostMountainsCartoon.tscn",
		6:"res://scenes/cartoon/CoastLostIslandsCartoon.tscn",
		7:"res://scenes/cartoon/CorruptedLandsCartoon.tscn",
		8:"res://scenes/cartoon/AbyssHeartCartoon.tscn"
	}

	for region in regions:
		var act: int = int(region.get("act",0))
		assert(act >= 1 and act <= 8)
		assert(String(region.get("build_status","")) == "IN_PROGRESS_PHYSICAL")
		quest_total += (region.get("mandatory_route",[]) as Array).size()
		var scene_path: String = String((region.get("implementation",{}) as Dictionary).get("scene",""))
		assert(scene_path == String(expected_scenes[act]))
		assert(ResourceLoader.exists(scene_path))

	assert(quest_total == 49)
	assert(ResourceLoader.exists("res://scenes/cartoon/ValedouroSiegeCartoon.tscn"))
	print("campaign_world: PASS — 8 regiões físicas, 49 missões e rota jogável da campanha")
	quit(0)
