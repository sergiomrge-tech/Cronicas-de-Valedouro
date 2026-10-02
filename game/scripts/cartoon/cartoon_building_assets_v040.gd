extends RefCounted
## Twelve distinct architectures in one shared texture. Anchors are foundations,
## not image centers: the bottom stone platform touches each prop's Y-sort origin.
const ATLAS = preload("res://assets/cartoon/v040/buildings.png")
const HOUSE_KEYS = ["cottage","townhouse","fisher_home","villa","farmhouse","garden_cabin"]
static var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cartoon/v040/buildings.json"))
static var cache: Dictionary = {}

static func key_for(kind: String, variant: int = 0) -> String:
	if kind == "house": return HOUSE_KEYS[posmod(variant,HOUSE_KEYS.size())]
	return kind if manifest.assets.has(kind) else ""

static func texture(key: String) -> AtlasTexture:
	if not cache.has(key):
		var asset: Dictionary = manifest.assets[key]
		var box: Array = asset.region
		var sprite = AtlasTexture.new()
		sprite.atlas = ATLAS
		sprite.region = Rect2(box[0],box[1],box[2],box[3])
		sprite.filter_clip = true
		cache[key] = sprite
	return cache[key] as AtlasTexture

static func rect_for(key: String) -> Rect2:
	var asset: Dictionary = manifest.assets[key]
	var box: Array = asset.region
	var anchor = Vector2(asset.anchor[0],asset.anchor[1])
	var ratio: float = float(asset.world_width)/float(box[2])
	return Rect2(-anchor*ratio,Vector2(box[2],box[3])*ratio)

static func draw_prop(canvas: CanvasItem, kind: String, variant: int) -> bool:
	var key: String = key_for(kind,variant)
	if key.is_empty(): return false
	canvas.draw_texture_rect(texture(key),rect_for(key),false)
	return true
