extends SceneTree
const MODELED = preload("res://scripts/modeled_assets.gd")

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var comps: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/act02_compositions.json")) as Array
	var story: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/main_story_v1.json")) as Dictionary
	var locs_raw: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/story_locations_v1.json"))
	var loc_ids: Dictionary = {}
	var loc_list: Array = locs_raw as Array if locs_raw is Array else (locs_raw as Dictionary).get("locations", []) as Array
	for l_value in loc_list:
		loc_ids[str((l_value as Dictionary)["id"])] = str((l_value as Dictionary).get("region", ""))
	var quest_ids: Dictionary = {}
	for q_value in story["quests"]:
		quest_ids[str((q_value as Dictionary)["id"])] = true
	assert(comps.size() >= 2)
	var objects_total: int = 0
	for c_value in comps:
		var comp: Dictionary = c_value
		var cid: String = str(comp["id"])
		assert(loc_ids.has(cid), "LOC canônico inexistente: " + cid)
		assert(loc_ids[cid] == "floresta_ancestral", "região fora do Ato II: " + cid)
		assert((comp["captures"] as Array).size() >= 2, "sem estados capturáveis: " + cid)
		for o_value in comp["objects"]:
			var o: Dictionary = o_value
			var asset: String = str(o["asset"])
			assert(MODELED.has(asset), "asset inexistente na composição: " + asset)
			assert(str(MODELED.entry(asset).get("status", "")) != "REWORKED" and str(MODELED.entry(asset).get("status", "")) != "HOLD", "asset bloqueado: " + asset)
			for key in ["show_when", "hide_when"]:
				if o.has(key):
					var flag: String = str(o[key]).trim_prefix("!")
					var parts: PackedStringArray = flag.split(":")
					assert(parts[0] == "quest" and quest_ids.has(parts[1]), "flag de estado fora do canon: " + flag)
			objects_total += 1
		for shot_value in comp["captures"]:
			for f_value in (shot_value as Dictionary).get("flags", []):
				var fp: PackedStringArray = str(f_value).split(":")
				assert(quest_ids.has(fp[1]), "captura com flag fora do canon: " + str(f_value))
	print("ACT02 COMPOSITIONS PASS: ", comps.size(), " locais canônicos, ", objects_total, " objetos, estados por quest canônica, sem REWORKED/HOLD")
	quit(0)
