extends SceneTree

const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	for i in range(8):
		await process_frame

func xp_between(state,from_level: int,to_level: int) -> int:
	var total: int = 0
	for level_value in range(from_level,to_level):
		total += state.xp_to_next(level_value)
	return total

func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	state.player_level = 7
	state.player_xp = 0
	state.save_profile()

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	var hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	hub.hero.set_process(false)
	var layout = hub.get_node("HUD/GameLayout")
	if layout.demon_director != null:
		layout.demon_director.set_process(false)
	for mob in hub.monsters:
		if is_instance_valid(mob):
			mob.set_process(false)
	if hub.wildlife != null:
		hub.wildlife.set_process(false)

	layout._process(0.01)
	assert(layout.last_player_level == 7)
	assert(not layout.level_banner.visible)

	var result8: Dictionary = state.gain_xp(state.xp_to_next(7))
	hub._refresh_stats()
	layout._process(0.01)
	assert(state.player_level == 8)
	assert(bool(result8.get("leveled_up",false)))
	assert((result8.get("unlocks",PackedStringArray()) as PackedStringArray).has("Equipamentos liberados: Floresta Ancestral"))
	assert(layout.level_banner.visible)
	assert(layout.level_banner_label.text.contains("NÍVEL 8"))
	assert(layout.level_banner_label.text.contains("Floresta Ancestral"))
	assert(hub.hud_status.hero_hint.text == "+8 PT")

	var result10: Dictionary = state.gain_xp(xp_between(state,8,10))
	hub._refresh_stats()
	layout._process(0.01)
	assert(state.player_level == 10)
	assert((result10.get("unlocks",PackedStringArray()) as PackedStringArray).has("Magia liberada: Cristal"))
	assert(layout.level_banner_label.text.contains("NÍVEL 10"))
	assert(layout.level_banner_label.text.contains("Cristal"))
	assert(state.spell_unlocked(1))

	var result25: Dictionary = state.gain_xp(xp_between(state,10,25))
	hub._refresh_stats()
	layout._process(0.01)
	assert(state.player_level == 25)
	var unlocks25: PackedStringArray = result25.get("unlocks",PackedStringArray())
	assert(unlocks25.has("Equipamentos liberados: Deserto e Ruínas"))
	assert(unlocks25.has("Magia liberada: Arcana"))
	assert(layout.level_banner_label.text.contains("NÍVEL 25"))
	assert(layout.level_banner_label.text.contains("Arcana"))
	assert(state.spell_unlocked(2))
	assert(hub.hud_status.hero_hint.text == "+25 PT")

	layout.level_banner_timer = 0.0
	layout._process(0.01)
	assert(not layout.level_banner.visible)

	hub.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_levelup_feedback_v035: PASS — compact level banners, spell/tier unlocks and skill point badge")
	quit(0)
