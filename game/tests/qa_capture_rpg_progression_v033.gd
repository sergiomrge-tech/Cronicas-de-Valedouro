extends SceneTree

const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")

var output: String
var host

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	for i in range(8):
		await process_frame

func shot(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	assert(image.save_png(output.path_join(name+".png")) == OK)

func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	state.add_consumable("healing_flask",3)
	state.add_consumable("greater_healing_flask",1)

	var drop: Dictionary = state.award_enemy_loot(
		"REG_002_FLORESTA_ANCESTRAL","wolf",8,false,false,
		{"material":1.0,"consumable":1.0,"gear":0.0,"gear_index":0}
	)
	var dropped_id: String = String(drop.get("gear_id",""))
	assert(dropped_id != "")

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	host = Hub.instantiate()
	root.add_child(host)
	current_scene = host
	await settle()

	host.set_process(false)
	host.hero.set_process(false)
	var layout = host.get_node("HUD/GameLayout")
	if layout.demon_director != null:
		layout.demon_director.set_process(false)
	for mob in host.monsters:
		if is_instance_valid(mob):
			mob.set_process(false)

	host.player_max_hp = 100
	host.player_hp = 48
	state.player_max_hp = 100
	state.player_hp = 48
	layout._process(0.0)
	await shot("quick_heal_mobile")

	host.inventory_ui.open_panel("equipment")
	host.inventory_ui._select_item(dropped_id)
	await shot("locked_region_gear_level1")

	host.inventory_ui.close_panel()
	state.player_level = 8
	host.inventory_ui.open_panel("equipment")
	host.inventory_ui._select_item(dropped_id)
	await shot("unlocked_region_gear_level8")

	host.inventory_ui.close_panel()
	host.player_hp = 25
	state.player_hp = 25
	layout._quick_heal()
	layout._process(0.0)
	await shot("quick_heal_after_use")

	state.reset_progress(true)
	print("rpg_progression_v033 QA: quick-heal HUD and equipment level lock/unlock")
	quit()
