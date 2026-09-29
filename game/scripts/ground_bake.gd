extends RefCounted
# Chão assado (terrain bake): chunks PNG de 512 px do mundo aberto e da instância do Bosque.
# Substitui os tiles de 32 px do v0.6. Transições de bioma, estradas, água, margens e pontes já vêm pintadas.

const MODELED = preload("res://scripts/modeled_assets.gd")
const CHUNK: float = 512.0

static func _draw_chunks(canvas: CanvasItem, prefix: String, rect: Rect2, max_x: int, max_y: int) -> int:
	var x0: int = maxi(0, int(floor(rect.position.x / CHUNK)))
	var y0: int = maxi(0, int(floor(rect.position.y / CHUNK)))
	var x1: int = mini(max_x, int(floor(rect.end.x / CHUNK)))
	var y1: int = mini(max_y, int(floor(rect.end.y / CHUNK)))
	var drawn: int = 0
	for cy in range(y0, y1 + 1):
		for cx in range(x0, x1 + 1):
			var tex: Texture2D = MODELED.texture("%s_%d_%d" % [prefix, cx, cy])
			if tex != null:
				canvas.draw_texture(tex, Vector2(cx * CHUNK, cy * CHUNK))
				drawn += 1
	return drawn

static func draw_world(canvas: CanvasItem, rect: Rect2) -> int:
	return _draw_chunks(canvas, "ter_ground", rect, 5, 4)

static func draw_bosque(canvas: CanvasItem, rect: Rect2) -> int:
	return _draw_chunks(canvas, "ter_bosque", rect, 3, 1)

static func base_color(zone: String) -> Color:
	match zone:
		"masmorra", "cripta":
			return Color(.09, .07, .15)
		"ferreiro":
			return Color(.13, .09, .08)
	return Color(.16, .11, .08)
