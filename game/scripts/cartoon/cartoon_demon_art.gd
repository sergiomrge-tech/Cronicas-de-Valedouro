extends RefCounted
const PATHS = {"ember":"res://assets/cartoon/v029/demon_ember.svg","void":"res://assets/cartoon/v029/demon_void.svg","ruin":"res://assets/cartoon/v029/demon_ruin.svg"}
static var cache: Dictionary = {}
static func frame(node: CanvasItem, kind: String, index: int, rect: Rect2, tint: Color = Color.WHITE) -> void:
	if not cache.has(kind): cache[kind] = load(PATHS.get(kind,PATHS.ember))
	node.draw_texture_rect_region(cache[kind],rect,Rect2(index*144,0,144,160),tint)
