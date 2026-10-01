class_name ValedouroCartoonCombatArt
extends RefCounted
const ROOT = "res://assets/cartoon/v024/"
const FRAMES = {"idle":4,"walk":8,"attack":6,"cast":8,"hurt":4,"death":8}
static var cache: Dictionary = {}
static func texture(key: String) -> Texture2D:
	if not cache.has(key): cache[key] = load(ROOT+key+".svg")
	return cache[key]
static func hero_frame(canvas: CanvasItem, direction: String, state: String, frame: int, rect: Rect2, tint: Color = Color.WHITE) -> void:
	canvas.draw_texture_rect_region(texture("hero_"+direction+"_"+state),rect,Rect2((frame%int(FRAMES[state]))*128,0,128,160),tint)
static func monster_frame(canvas: CanvasItem, kind: String, frame: int, rect: Rect2, tint: Color = Color.WHITE) -> void:
	canvas.draw_texture_rect_region(texture("mob_"+kind),rect,Rect2((frame%6)*144,0,144,160),tint)
