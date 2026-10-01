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

	root.size = Vector2i(960,540)
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
	for monster in host.monsters:
		if is_instance_valid(monster):
			monster.set_process(false)
	if host.wildlife != null:
		host.wildlife.set_process(false)

	state.add_consumable("healing_flask",3)
	state.add_consumable("greater_healing_flask",1)
	state.player_hp = 48
	host.player_hp = 48
	host.inventory_ui.open_panel("consumables")
	await shot("consumables_desktop")

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	await shot("consumables_mobile")

	host.inventory_ui._select_consumable("healing_flask")
	host.inventory_ui._primary_action()
	await shot("healing_used_mobile")

	host.inventory_ui.close_panel()
	var drop: Dictionary = state.award_enemy_loot(
		"REG_001_BERCO_VALEDOURO","wolf",1,false,false,
		{"material":0.0,"consumable":0.0,"gear":0.0,"gear_index":0}
	)
	host._show_toast("Loot obtido\n"+String(drop.get("summary","")))
	await shot("loot_feedback_mobile")

	host.inventory_ui.open_panel("equipment")
	await shot("rare_drop_in_bag")

	state.reset_progress(true)
	print("loot_v031 QA: 5 actual Godot captures for consumables, healing and rare loot")
	quit()
