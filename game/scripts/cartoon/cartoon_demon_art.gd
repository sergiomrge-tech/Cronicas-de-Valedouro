extends RefCounted
static var cache: Dictionary = {}
static func frame(node: CanvasItem, kind: String, index: int, rect: Rect2, tint: Color = Color.WHITE) -> void:
	if not cache.has(kind): cache[kind] = load("res://assets/cartoon/v029/demon_"+kind+".svg")
	node.draw_texture_rect_region(cache[kind],rect,Rect2(index*144,0,144,160),tint)
