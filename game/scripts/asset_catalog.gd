extends RefCounted
# Catálogo estável dos assets legados da v0.6. Não integra o lote Claude.

const CATALOG_PATH: String = "res://data/asset_catalog.json"

static func load_catalog() -> Dictionary:
	if not FileAccess.file_exists(CATALOG_PATH):
		return {}
	var file: FileAccess = FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}

static func entries() -> Array:
	var catalog: Dictionary = load_catalog()
	var value: Variant = catalog.get("assets", [])
	if value is Array:
		return value as Array
	return []

static func index_by_id() -> Dictionary:
	var result: Dictionary = {}
	for value in entries():
		if value is Dictionary:
			var entry: Dictionary = value as Dictionary
			var asset_id: String = str(entry.get("id", ""))
			if not asset_id.is_empty():
				result[asset_id] = entry
	return result

static func find(asset_id: String) -> Dictionary:
	var index: Dictionary = index_by_id()
	var value: Variant = index.get(asset_id, {})
	if value is Dictionary:
		return value as Dictionary
	return {}
