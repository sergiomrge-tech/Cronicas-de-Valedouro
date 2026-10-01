class_name ValedouroCartoonHeroArtV028
extends RefCounted
const ROOT = "res://assets/cartoon/v028/"
const FRAMES = {"idle":8,"walk":12,"attack":6,"cast":8,"hurt":4,"death":8,"shoot":8,"evade":6}
static var cache: Dictionary = {}
static func hero_frame(node: CanvasItem, direction: String, state: String, frame: int, rect: Rect2, tint: Color = Color.WHITE) -> void:
	var key: String = "hero_"+direction+"_"+state
	if not cache.has(key): cache[key] = load(ROOT+key+".svg")
	var texture: Texture2D = cache[key]
	if texture != null: node.draw_texture_rect_region(texture,rect,Rect2((frame%int(FRAMES[state]))*128,0,128,160),tint)
