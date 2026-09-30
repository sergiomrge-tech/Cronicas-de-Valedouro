extends SceneTree

const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const MenuScene = preload("res://scenes/cartoon/CartoonMainMenu.tscn")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var state = root.get_node_or_null("CartoonPlayerState")
	assert(state != null)

	state.reset_progress(true)
	assert(not state.has_campaign_save())
	state.start_new_game()
	assert(state.has_campaign_save())
	assert(state.continue_scene_path() == state.DEFAULT_SCENE)
	assert(state.player_level == 1)
	assert(state.player_gold == 35)

	var hub: Node = HubScene.instantiate()
	root.add_child(hub)
	await process_frame
	await process_frame
	state.bind_scene(
		state.DEFAULT_SCENE,
		hub,
		hub.hero,
		hub.story_runtime,
		1,120,35,
		["field_quest_active","field_kills"]
	)
	hub.hero.position = Vector2(4321,3456)
	hub.player_hp = 77
	hub.player_max_hp = 140
	hub.player_gold = 123
	hub.field_quest_active = true
	hub.field_kills = 2
	hub.story_runtime.current_id = "Q_MS01_WOLVES"
	hub.story_runtime.wolf_kills = 2
	state.player_level = 7
	state.player_xp = 91
	state.save_profile()
	assert(state.player_position == Vector2(4321,3456))
	assert(state.player_hp == 77)
	assert(state.player_gold == 123)

	state._clear_active_binding()
	state.player_position = Vector2.ZERO
	state.player_hp = 1
	state.player_gold = 0
	state.player_level = 1
	state.player_xp = 0
	state.story_progress.clear()
	state.scene_extras.clear()
	state.load_profile()
	assert(state.player_position == Vector2(4321,3456))
	assert(state.player_hp == 77)
	assert(state.player_max_hp == 140)
	assert(state.player_gold == 123)
	assert(state.player_level == 7)
	assert(state.player_xp == 91)

	var restored_hub: Node = HubScene.instantiate()
	root.add_child(restored_hub)
	await process_frame
	await process_frame
	state.bind_scene(
		state.DEFAULT_SCENE,
		restored_hub,
		restored_hub.hero,
		restored_hub.story_runtime,
		1,120,35,
		["field_quest_active","field_kills"]
	)
	assert(restored_hub.hero.position == Vector2(4321,3456))
	assert(restored_hub.player_hp == 77)
	assert(restored_hub.player_max_hp == 140)
	assert(restored_hub.player_gold == 123)
	assert(restored_hub.field_quest_active)
	assert(restored_hub.field_kills == 2)
	assert(restored_hub.story_runtime.current_id == "Q_MS01_WOLVES")
	assert(restored_hub.story_runtime.wolf_kills == 2)

	state.prepare_transition("res://scenes/cartoon/ForestAncientCartoon.tscn")
	assert(state.continue_scene_path() == "res://scenes/cartoon/ForestAncientCartoon.tscn")
	assert(state.player_position == Vector2.ZERO)
	assert(state.has_campaign_save())

	var menu: Node = MenuScene.instantiate()
	root.add_child(menu)
	await process_frame
	assert(menu.continue_button != null)
	assert(menu.delete_button != null)
	assert(not menu.continue_button.disabled)
	assert(not menu.delete_button.disabled)
	menu._delete_save()
	assert(menu.confirmation_panel.visible)
	assert(menu.confirmation_mode == "delete")
	menu._confirm_action()
	assert(not state.has_campaign_save())
	assert(menu.continue_button.disabled)
	assert(menu.delete_button.disabled)

	state.reset_progress(true)
	print("save_menu_v016: PASS — Novo Jogo, Continuar, Excluir e save global de campanha")
	quit(0)
