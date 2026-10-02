extends Node2D
## Original painted furniture; one shared atlas, no per-frame furniture redraw.
const TEXTURES = {"furniture":preload("res://assets/cartoon/v042/furniture.png"),"lantern":preload("res://assets/cartoon/v042/lantern.png"),"guild":preload("res://assets/cartoon/v042/guild.png"),"workbench":preload("res://assets/cartoon/v042/workbench.png")}
static var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cartoon/v042/art.json"))
var key: String
var dimensions: Vector2
var ground: bool = false
func _draw() -> void:
	var row: Dictionary = manifest.furniture[key]
	var region: Rect2 = Rect2(row.region[0],row.region[1],row.region[2],row.region[3])
	var factor: float = minf(dimensions.x/region.size.x,dimensions.y/region.size.y)
	var anchor: Vector2 = Vector2(row.anchor[0],row.anchor[1])
	var rect: Rect2 = Rect2(-anchor*factor+Vector2(0,10),region.size*factor)
	if not ground and key not in ["wall_map","banner","lantern"]:
		var points: PackedVector2Array = PackedVector2Array()
		for i in range(24):
			var a: float = i*TAU/24
			points.append(Vector2(cos(a)*rect.size.x*0.36,sin(a)*5+8))
		draw_colored_polygon(points,Color(0.09,0.06,0.04,0.22))
	draw_texture_rect_region(TEXTURES[row.texture],rect,region)
