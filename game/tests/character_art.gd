extends SceneTree

const ART = preload("res://scripts/character_art.gd")

func _initialize() -> void:
	assert(ART.candidate_id("npc_villager", "walk") == "char_npc_villager_walk")
	assert(ART.candidate_id("fauna_deer", "walk") == "char_fauna_deer_walk")

	# Convenção direcional idêntica à do herói: 0 baixo, 2 direita, 4 cima, 6 esquerda.
	assert(ART.direction_from_angle(PI / 2.0) == 0)
	assert(ART.direction_from_angle(0.0) == 2)
	assert(ART.direction_from_angle(PI * 1.5) == 4)
	assert(ART.direction_from_angle(PI) == 6)

	assert(ART.town_family(0) == "npc_villager")
	assert(ART.town_family(1) == "npc_merchant")
	assert(ART.interior_family("ferreiro") == "npc_blacksmith")
	assert(ART.interior_family("alquimia") == "npc_alchemist")
	assert(ART.fauna_subject("deer") == "fauna_deer")
	assert(ART.fauna_animation("bird") == "fly")
	assert(ART.fauna_animation("fish") == "swim")
	assert(ART.fauna_animation("deer") == "walk")

	var source_data: Dictionary = {
		"frame_size": Vector2i(48, 56),
		"frames": 8,
		"rows": 8
	}
	assert(ART.source_rect(source_data, 9, 9) == Rect2(48, 56, 48, 56))
	assert(ART.frame_size(source_data) == Vector2(48, 56))

	# Um candidato inexistente precisa resultar em Dictionary vazio para ativar o
	# fallback legado do renderer sem referência quebrada.
	var missing: Dictionary = ART.candidate("__qa_missing_character__", "walk")
	assert(missing.is_empty())

	print("CHARACTER_ART_PASS")
	quit(0)
