extends Node2D
## Rich wall strips retain natural proportions; the authored room limits/services are untouched.
const TEXTURE = preload("res://assets/cartoon/v042/walls.png")
static var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cartoon/v042/art.json"))
var kind: String
func _draw() -> void:
	var row: Dictionary = manifest.walls[kind]
	var source: Rect2 = Rect2(row.region[0],row.region[1],row.region[2],row.region[3])
	var factor: float = 122.0/source.size.y
	var cursor: float = -720.0
	while cursor<720:
		var width: float = minf(source.size.x*factor,720.0-cursor)
		draw_texture_rect_region(TEXTURE,Rect2(cursor,-500,width,122),Rect2(source.position,Vector2(width/factor,source.size.y)))
		cursor += width
