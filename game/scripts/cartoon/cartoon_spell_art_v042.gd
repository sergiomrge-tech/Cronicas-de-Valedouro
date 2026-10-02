extends RefCounted
## Shared original illustrated spell atlases; gameplay remains in SpellProjectile.
const TEXTURES = {
	"ember":preload("res://assets/cartoon/v042/ember.png"),
	"frost":preload("res://assets/cartoon/v042/frost.png"),
	"arcane":preload("res://assets/cartoon/v042/arcane.png")}
static var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cartoon/v042/art.json"))
static var cache: Dictionary = {}
static func texture(kind: String,frame: int) -> AtlasTexture:
	var key: String = kind+str(frame)
	if not cache.has(key):
		var row: Dictionary = manifest.spells[kind].frames[frame]
		var tex = AtlasTexture.new()
		tex.atlas = TEXTURES[kind]
		tex.region = Rect2(row.region[0],row.region[1],row.region[2],row.region[3])
		tex.filter_clip = true
		cache[key] = tex
	return cache[key] as AtlasTexture
static func scale_factor(kind: String) -> float:
	var row: Array = manifest.spells[kind].frames[0].region
	return 90.0/maxf(row[2],row[3])
