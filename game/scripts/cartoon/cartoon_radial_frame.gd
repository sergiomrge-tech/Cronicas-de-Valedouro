extends Control
## Lightweight vector trim shared by every modal; no input or game state.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
func _draw() -> void:
	if size.x<80 or size.y<60: return
	var gold: Color = Color("e4b85d")
	var inset: Rect2 = Rect2(Vector2(6,6),size-Vector2(12,12))
	draw_rect(inset,Color(0.89,0.72,0.36,0.24),false,1)
	for corner: Vector2 in [Vector2(9,9),Vector2(size.x-9,9),Vector2(9,size.y-9),size-Vector2(9,9)]:
		draw_colored_polygon(PackedVector2Array([corner+Vector2(0,-4),corner+Vector2(4,0),corner+Vector2(0,4),corner+Vector2(-4,0)]),gold)
