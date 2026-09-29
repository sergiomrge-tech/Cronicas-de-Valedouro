extends SceneTree
# Gate visual REG_001: manifesto de assets modelados (IDs, arquivos, hashes, quadros) e política REWORKED/HOLD.
const MODELED = preload("res://scripts/modeled_assets.gd")
const ALLOWED_STATUSES: Array[String] = ["APPROVED", "MODELED_PENDING_GATE", "REJECTED", "HOLD"]

func _initialize() -> void:
	call_deferred("check")

func scan_scripts_for(needle: String) -> Array[String]:
	var hits: Array[String] = []
	var dir: DirAccess = DirAccess.open("res://scripts")
	if dir == null:
		return hits
	for file_name in dir.get_files():
		if not file_name.ends_with(".gd"):
			continue
		var text: String = FileAccess.get_file_as_string("res://scripts/" + file_name)
		if text.find(needle) >= 0:
			hits.append(file_name)
	return hits

func check() -> void:
	var entries: Dictionary = MODELED.entries()
	assert(entries.size() >= 140, "manifesto pequeno: %d" % entries.size())
	var groups: Dictionary = {}
	var checked: int = 0
	for id_value in entries.keys():
		var e: Dictionary = entries[id_value] as Dictionary
		var id: String = str(id_value)
		var known_prefix: bool = false
		for prefix in ["nat_", "city_", "dg_", "int_", "ter_", "str_", "npc_", "fau_", "fx_", "val_"]:
			if id.begins_with(prefix):
				known_prefix = true
		assert(known_prefix, "prefixo inválido: " + id)
		assert(ALLOWED_STATUSES.has(str(e["status"])), "status inválido em " + id)
		assert(str(e["status"]) != "REWORKED", "REWORKED não pode entrar: " + id)
		var path: String = str(e["path"])
		assert(ResourceLoader.exists(path), "PNG ausente: " + path)
		var tex: Texture2D = load(path) as Texture2D
		assert(tex != null, "PNG inválido: " + path)
		var fs: Array = e["frame_size"]
		assert(tex.get_width() == int(fs[0]) * int(e["frames"]) and tex.get_height() == int(fs[1]) * int(e.get("rows", 1)), "dimensões divergem do manifesto: " + id)
		var foot: Array = e["foot"]
		assert(float(foot[0]) >= 0 and float(foot[0]) <= float(fs[0]) and float(foot[1]) >= 0 and float(foot[1]) <= float(fs[1]), "âncora fora do quadro: " + id)
		var abs_path: String = ProjectSettings.globalize_path(path)
		assert(FileAccess.get_sha256(abs_path) == str(e["sha256"]), "hash divergente (PNG mudou sem regenerar manifesto): " + id)
		var group: String = str(e["group"])
		groups[group] = int(groups.get(group, 0)) + 1
		checked += 1
	for group_name in ["nature", "city", "dungeon", "interior"]:
		assert(int(groups.get(group_name, 0)) >= 10, "grupo com poucos assets: " + group_name)
	# nenhum caminho do renderer aponta para conteúdo REWORKED/HOLD
	for needle in ["/rework", "/REWORKED", "/hold/", "/HOLD"]:
		assert(scan_scripts_for(needle).is_empty(), "referência proibida no renderer: " + needle)
	print("MODELED ASSETS PASS: %d assets (nature %d, city %d, dungeon %d, interior %d) com arquivos, quadros e hashes íntegros" % [checked, int(groups["nature"]), int(groups["city"]), int(groups["dungeon"]), int(groups["interior"])])
	quit(0)
