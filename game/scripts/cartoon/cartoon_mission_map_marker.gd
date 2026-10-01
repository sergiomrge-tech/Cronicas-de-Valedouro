extends Control
var point: Vector2 = Vector2.ZERO
var enabled: bool = false
var caption: String = ""
func _ready() -> void: mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	if not enabled: return
	var overlay = get_parent()
	var p: Vector2 = overlay._world_to_map(point)
	draw_circle(p,11,Color("102b30"))
	draw_arc(p,11,0,TAU,32,Color("7af0df"),2,true)
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-7),p+Vector2(6,0),p+Vector2(0,7),p+Vector2(-6,0)]),Color("7af0df"))
	var rect: Rect2 = overlay.map_rect
	var label_position: Vector2 = Vector2(clampf(p.x+15,rect.position.x+4,rect.end.x-204),clampf(p.y-12,rect.position.y+17,rect.end.y-8))
	draw_style_box(_label_style(),Rect2(label_position-Vector2(3,14),Vector2(205,21)))
	draw_string(ThemeDB.fallback_font,label_position,caption,HORIZONTAL_ALIGNMENT_LEFT,198,12,Color("acfff1"))
func _label_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.025,0.10,0.12,0.92)
	return style
