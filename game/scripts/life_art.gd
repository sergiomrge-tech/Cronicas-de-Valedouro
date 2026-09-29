extends RefCounted
# Desenho de NPCs e fauna com as folhas de sprites do pipeline profissional (assets modelados npc_*/fau_*).
# NPC: 5 direções (S, SE, E, NE, N; oeste = espelho) x 12 colunas (4 idle + 8 caminhada).
# Fauna quadrúpede: 10 colunas (4 idle + 6 caminhada) voltada para a direita/frente; ave e peixe: 6 quadros.
const MODELED = preload("res://scripts/modeled_assets.gd")
const IDLE_FRAMES: int = 4
const WALK_FRAMES: int = 8
const FAMILY_BY_NPC: Dictionary = {"traveler": "traveler", "farmer": "farmer", "miller": "miller", "hunter": "hunter", "merchant": "merchant"}

static func has_family(family: String) -> bool:
	return MODELED.has("npc_" + family)

static func draw_npc(canvas: CanvasItem, family: String, foot: Vector2, facing: Vector2, moving: bool, t: float, seed_value: float, tint: Color = Color.WHITE) -> bool:
	var id: String = "npc_" + family
	var tex: Texture2D = MODELED.texture(id)
	if tex == null:
		return false
	var entry: Dictionary = MODELED.entry(id)
	var fs: Array = entry["frame_size"]
	var fw: float = float(fs[0])
	var fh: float = float(fs[1])
	var anchor: Array = entry["foot"]
	var ds: float = float(entry.get("draw_scale", .5))
	var angle: float = atan2(facing.x, facing.y) if facing.length() > .01 else 0.0
	var row: int = clampi(int(round(absf(angle) / (PI / 4.0))), 0, 4)
	var mirror: bool = angle < 0.0 and row > 0 and row < 4
	var column: int = IDLE_FRAMES + int(t * 9.0 + seed_value * 3.0) % WALK_FRAMES if moving else int(t * 2.4 + seed_value * 5.0) % IDLE_FRAMES
	var dest: Rect2 = Rect2(foot - Vector2(float(anchor[0]), float(anchor[1])) * ds, Vector2(fw, fh) * ds)
	var src: Rect2 = Rect2(Vector2(column * fw, row * fh), Vector2(fw, fh))
	if mirror:
		dest = Rect2(foot - Vector2(fw - float(anchor[0]), float(anchor[1])) * ds, Vector2(fw, fh) * ds)
		src = Rect2(Vector2(column * fw + fw, row * fh), Vector2(-fw, fh))
	canvas.draw_texture_rect_region(tex, dest, src, tint)
	return true

static func draw_animal(canvas: CanvasItem, kind: String, foot: Vector2, facing_right: bool, t_phase: float, moving: bool) -> bool:
	var id: String = "fau_" + kind
	var tex: Texture2D = MODELED.texture(id)
	if tex == null:
		return false
	var entry: Dictionary = MODELED.entry(id)
	var fs: Array = entry["frame_size"]
	var fw: float = float(fs[0])
	var fh: float = float(fs[1])
	var anchor: Array = entry["foot"]
	var ds: float = float(entry.get("draw_scale", .5))
	var frames: int = int(entry["frames"])
	var column: int = int(t_phase * 1.3) % frames
	if frames >= 10:
		column = 4 + int(t_phase * 1.4) % (frames - 4) if moving else int(t_phase * .5) % 4
	var dest: Rect2 = Rect2(foot - Vector2(float(anchor[0]), float(anchor[1])) * ds, Vector2(fw, fh) * ds)
	var src: Rect2 = Rect2(Vector2(column * fw, 0), Vector2(fw, fh))
	if not facing_right:
		dest = Rect2(foot - Vector2(fw - float(anchor[0]), float(anchor[1])) * ds, Vector2(fw, fh) * ds)
		src = Rect2(Vector2(column * fw + fw, 0), Vector2(-fw, fh))
	canvas.draw_texture_rect_region(tex, dest, src)
	return true
