extends Node2D
## Painted texture layer preserves authored room geometry and collision boundaries.
const WOOD = preload("res://assets/cartoon/v042/wood.png")
const STONE = preload("res://assets/cartoon/v041/stone.png")
var kind: String
func _ready() -> void:
	texture_repeat = CanvasItem.TEXTURE_REPEAT_MIRROR
func _draw() -> void:
	var texture: Texture2D = STONE if kind=="forge" else WOOD
	var rect: Rect2 = Rect2(-665,-384,1330,808)
	var tile_size: float = 256.0 if kind=="forge" else 520.0
	draw_texture_rect_region(texture,rect,Rect2(Vector2.ZERO,rect.size*texture.get_width()/tile_size))
