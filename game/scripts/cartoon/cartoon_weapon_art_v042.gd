extends RefCounted
const TEXTURES = {"weapons":preload("res://assets/cartoon/v042/weapons.png"),"quiver":preload("res://assets/cartoon/v042/quiver.png")}
static var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cartoon/v042/art.json"))
static func draw_weapon(canvas: CanvasItem,key: String,factor: float,tint: Color=Color.WHITE) -> void:
	var data: Dictionary = manifest.weapons[key]
	var region: Rect2 = Rect2(data.region[0],data.region[1],data.region[2],data.region[3])
	canvas.draw_texture_rect_region(TEXTURES[data.get("texture","weapons")],Rect2(-Vector2(data.anchor[0],data.anchor[1])*factor,region.size*factor),region,tint)
static func sword_factor(length: float) -> float: return length/650.0
static func bow_factor() -> float: return 54.0/970.0
static func bow_tips() -> Array[Vector2]:
	var row: Dictionary = manifest.weapons.bow
	var points: Array[Vector2] = []
	for tip: Array in row.tips: points.append((Vector2(tip[0],tip[1])-Vector2(row.anchor[0],row.anchor[1]))*bow_factor())
	return points

static func quiver_factor() -> float: return 36.0/float(manifest.weapons.quiver.height_pixels)
