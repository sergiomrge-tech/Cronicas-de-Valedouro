class_name ValedouroCartoonVisualAssets
extends RefCounted
## Shared rasterized SVG textures: original Cartoon art, pending visual review.

const RoyalAssets = preload("res://scripts/cartoon/cartoon_royal_assets.gd")
const ROOT: String = "res://assets/cartoon/v020/"
static var textures: Dictionary = {}

static func texture(name: String) -> Texture2D:
	if not textures.has(name):
		textures[name] = load(ROOT + name + ".svg")
	return textures[name] as Texture2D

static func draw_prop(canvas: CanvasItem, kind: String, variant: int) -> bool:
	var name: String = kind
	var rect: Rect2
	match kind:
		"tree":
			name = "tree_%d" % posmod(variant,3)
			rect = Rect2(-72,-174,144,189)
		"pine": rect = Rect2(-55,-171,110,182)
		"bush": rect = Rect2(-42,-48,84,59)
		"rock": rect = Rect2(-32,-41,64,51)
		"house", "forge", "tavern", "guild", "alchemist", "archive":
			if kind == "house": name = "house_%d" % posmod(variant,3)
			rect = Rect2(-76,-147,152,163)
		"castle":
			canvas.draw_texture_rect(RoyalAssets.texture("royal_castle"),Rect2(-820,-1120,1640,1180),false)
			return true
		"royal_statue", "royal_banner", "royal_guard", "royal_vase":
			var royal_key: String = kind.trim_prefix("royal_") if kind == "royal_statue" else kind
			var dimensions: Vector2 = Vector2(150,205) if kind == "royal_statue" else (Vector2(70,95) if kind == "royal_guard" else Vector2(90,130))
			canvas.draw_texture_rect(RoyalAssets.texture(royal_key),Rect2(Vector2(-dimensions.x/2,-dimensions.y+10),dimensions),false)
			return true
		"fountain": rect = Rect2(-72,-108,144,123)
		"market": rect = Rect2(-63,-101,126,110)
		"ruin": rect = Rect2(-105,-155,210,168)
		"mine": rect = Rect2(-115,-178,230,193)
		"barrel": rect = Rect2(-20,-30,40,37)
		"lamp": rect = Rect2(-31,-84,62,94)
		"bench": rect = Rect2(-56,-48,112,64)
		"well": rect = Rect2(-49,-94,98,102)
		"bridge": rect = Rect2(-104,-72,208,95)
		"shrine": rect = Rect2(-50,-99,100,104)
		"windmill": rect = Rect2(-94,-187,188,199)
		"hay": rect = Rect2(-34,-44,68,52)
		"chest": rect = Rect2(-40,-53,80,59)
		"fence": rect = Rect2(-38,-31,76,37)
		_: return false
	canvas.draw_texture_rect(texture(name),rect,false)
	return true
