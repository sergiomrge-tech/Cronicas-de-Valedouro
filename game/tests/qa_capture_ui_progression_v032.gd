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
	state.player_gold = 432
	state.add_material("Seiva Ancestral",40)
	for row in state.recipes_for("REG_002_FLORESTA_ANCESTRAL"):
		state.craft_item("REG_002_FLORESTA_ANCESTRAL",String(row.id))

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
	for mob in host.monsters:
		if is_instance_valid(mob):
			mob.set_process(false)
	host.player_gold = state.player_gold

	host.inventory_ui.open_panel("equipment")
	await shot("inventory_paper_doll_desktop")

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	await shot("inventory_paper_doll_mobile")
	host.inventory_ui.close_panel()

	layout.mission_ui.open_panel()
	await settle()
	layout.mission_ui.show_tab("available")
	await shot("missions_scroll_top_mobile")
	var vbar: VScrollBar = layout.mission_ui.scroll.get_v_scroll_bar()
	assert(vbar.visible and vbar.max_value > vbar.page)
	layout.mission_ui.scroll.scroll_vertical = int(vbar.max_value)
	await shot("missions_scroll_bottom_mobile")

	layout.mission_ui.close_panel()
	state.player_level = 1
	layout._process(0.0)
	await shot("single_spell_level_1_mobile")

	state.reset_progress(true)
	print("ui_progression_v032 QA: paper-doll inventory, gold, mission scroll and one-spell start")
	quit()
