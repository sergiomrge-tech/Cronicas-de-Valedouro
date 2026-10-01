class_name ValedouroCartoonHeroArtV028
extends RefCounted
const ROOT = "res://assets/cartoon/v028/"
const FRAMES = {"idle":8,"walk":12,"attack":6,"cast":8,"hurt":4,"death":8,"shoot":8,"evade":6}
# The sheet's boot sole is at y=148 in a 160px cell.
const GROUND_RECT = Rect2(-40,-92.5,80,100)
static var cache: Dictionary = {}

static func ground_offset(state: String, frame: int) -> float:
	if state=="death": return 0.0
	var count: int = int(FRAMES[state])
	var phase: float = float(posmod(frame,count))/count
	var wave: float = sin(phase*TAU)
	var bob: float = absf(wave)*2.0 if state=="walk" else wave*1.2
	if state=="evade": bob = 8.0*sin(phase*PI)
	# The lower boot plants; the other boot still lifts during the stride.
	var planted_stride: float = absf(snappedf(wave*10.0,0.1)) if state=="walk" else 0.0
	return (snappedf(bob,0.01)-planted_stride)*GROUND_RECT.size.y/160.0

static func hero_frame(node: CanvasItem, direction: String, state: String, frame: int, rect: Rect2, tint: Color = Color.WHITE) -> void:
	var key: String = "hero_"+direction+"_"+state
	if not cache.has(key): cache[key] = load(ROOT+key+".svg")
	var texture: Texture2D = cache[key]
	if texture != null: node.draw_texture_rect_region(texture,rect,Rect2((frame%int(FRAMES[state]))*128,0,128,160),tint)
