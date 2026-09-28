extends SceneTree
const CATALOG = preload("res://scripts/asset_catalog.gd")

func _initialize() -> void:
	call_deferred("check")

func check() -> void:
	var data: Dictionary = CATALOG.load_catalog()
	assert(not data.is_empty())
	assert(int(data.get("schema_version", 0)) == 1)
	var entries: Array = CATALOG.entries()
	assert(entries.size() >= 119)
	var index: Dictionary = CATALOG.index_by_id()
	assert(index.size() == entries.size())
	for value in entries:
		assert(value is Dictionary)
		var row: Dictionary = value as Dictionary
		var path: String = str(row.get("path", ""))
		assert(path.begins_with("res://assets/"))
		assert(FileAccess.file_exists(path))
	print("ASSET CATALOG PASS: ", entries.size(), " IDs persistentes e caminhos válidos")
	quit(0)
