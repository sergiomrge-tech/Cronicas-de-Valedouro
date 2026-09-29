extends RefCounted
# Assets modelados (Natureza, Cidade, Dungeon, Interiores) servidos por ID persistente.
# Só entram no renderer os status listados em RENDER_STATUSES do manifesto.

const MANIFEST_PATH: String = "res://data/modeled_assets_manifest.json"

static var _loaded: bool = false
static var _entries: Dictionary = {}
static var _textures: Dictionary = {}
static var _statuses: Array = ["APPROVED", "MODELED_PENDING_GATE"]

static func ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	var doc: Dictionary = parsed as Dictionary
	var policy: Variant = doc.get("policy", {})
	if policy is Dictionary and (policy as Dictionary).get("renderer_uses_statuses", null) is Array:
		_statuses = (policy as Dictionary)["renderer_uses_statuses"]
	for value in doc.get("assets", []):
		if value is Dictionary:
			var entry: Dictionary = value as Dictionary
			_entries[str(entry["id"])] = entry

static func entries() -> Dictionary:
	ensure_loaded()
	return _entries

static func has(asset_id: String) -> bool:
	ensure_loaded()
	return _entries.has(asset_id) and _statuses.has(str((_entries[asset_id] as Dictionary).get("status", "")))

static func entry(asset_id: String) -> Dictionary:
	ensure_loaded()
	if _entries.has(asset_id):
		return _entries[asset_id] as Dictionary
	return {}

static func texture(asset_id: String) -> Texture2D:
	if _textures.has(asset_id):
		return _textures[asset_id] as Texture2D
	if not has(asset_id):
		return null
	var path: String = str((_entries[asset_id] as Dictionary)["path"])
	var tex: Texture2D = load(path) as Texture2D
	_textures[asset_id] = tex
	return tex

static func blocks_radius(asset_id: String) -> float:
	return float(entry(asset_id).get("blocks_radius", 0.0))

static func footprint(asset_id: String) -> float:
	return float(entry(asset_id).get("footprint", 0.0))
