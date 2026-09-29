extends RefCounted
# Fachada de arte de personagens/fauna para migração visual sem quebrar o runtime.
# Regra: candidato modelado quando disponível; caso contrário o chamador mantém
# exatamente o fallback LEGACY_BASELINE atual.
#
# Nenhum status é promovido aqui. MODELED respeita a política do manifesto.

const MODELED = preload("res://scripts/modeled_assets.gd")

const TOWN_NPC_FAMILIES: Array = [
	"npc_villager",
	"npc_merchant",
	"npc_traveler",
	"npc_guard",
	"npc_villager",
	"npc_guild",
	"npc_villager",
	"npc_merchant",
	"npc_traveler",
	"npc_guard"
]

const INTERIOR_FAMILIES: Dictionary = {
	"loja": "npc_merchant",
	"guilda_left": "npc_guild",
	"guilda_right": "npc_traveler",
	"ferreiro": "npc_blacksmith",
	"alquimia": "npc_alchemist"
}

static func candidate_id(subject_id: String, animation: String) -> String:
	return "char_%s_%s" % [subject_id, animation]


static func candidate(subject_id: String, animation: String) -> Dictionary:
	var asset_id: String = candidate_id(subject_id, animation)
	if not MODELED.has(asset_id):
		return {}
	var info: Dictionary = MODELED.entry(asset_id)
	var texture: Texture2D = MODELED.texture(asset_id)
	if texture == null:
		return {}

	var frame_value: Variant = info.get("frame_size", [])
	if not frame_value is Array:
		return {}
	var frame_array: Array = frame_value as Array
	if frame_array.size() < 2:
		return {}

	var frame_width: int = int(frame_array[0])
	var frame_height: int = int(frame_array[1])
	var frames: int = maxi(1, int(info.get("frames", 1)))
	var rows: int = maxi(1, int(info.get("rows", 1)))
	if frame_width <= 0 or frame_height <= 0:
		return {}

	return {
		"id": asset_id,
		"texture": texture,
		"frame_size": Vector2i(frame_width, frame_height),
		"frames": frames,
		"rows": rows,
		"status": str(info.get("status", ""))
	}


static func source_rect(data: Dictionary, frame: int, direction: int) -> Rect2:
	var size_value: Variant = data.get("frame_size", Vector2i(1, 1))
	var frame_size: Vector2i = size_value as Vector2i
	var frames: int = maxi(1, int(data.get("frames", 1)))
	var rows: int = maxi(1, int(data.get("rows", 1)))
	var column: int = wrapi(frame, 0, frames)
	var row: int = wrapi(direction, 0, rows)
	return Rect2(
		Vector2(float(column * frame_size.x), float(row * frame_size.y)),
		Vector2(float(frame_size.x), float(frame_size.y))
	)


static func frame_size(data: Dictionary) -> Vector2:
	var size_value: Variant = data.get("frame_size", Vector2i(1, 1))
	var value: Vector2i = size_value as Vector2i
	return Vector2(float(value.x), float(value.y))


static func direction_from_angle(angle: float) -> int:
	var movement: Vector2 = Vector2.RIGHT.rotated(angle)
	return wrapi(roundi(atan2(movement.x, movement.y) / (PI / 4.0)), 0, 8)


static func town_family(index: int) -> String:
	if TOWN_NPC_FAMILIES.is_empty():
		return "npc_villager"
	return str(TOWN_NPC_FAMILIES[wrapi(index, 0, TOWN_NPC_FAMILIES.size())])


static func interior_family(key: String) -> String:
	return str(INTERIOR_FAMILIES.get(key, "npc_villager"))


static func fauna_subject(kind: String) -> String:
	return "fauna_%s" % kind


static func fauna_animation(kind: String) -> String:
	if kind == "bird":
		return "fly"
	if kind == "fish":
		return "swim"
	return "walk"


static func fauna_frame(kind: String, phase: float, frame_count: int) -> int:
	var multiplier: float = 1.6 if kind == "bird" else 3.8 if kind == "fish" else 4.2
	return wrapi(int(floor(phase * multiplier)), 0, maxi(1, frame_count))
