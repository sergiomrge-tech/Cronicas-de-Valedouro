extends SceneTree
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const SCENES = ["ValedouroCartoonHub","ForestAncientCartoon","DesertEdravarCartoon","MarshDarkCartoon","FrostMountainsCartoon","CoastLostIslandsCartoon","CorruptedLandsCartoon","AbyssHeartCartoon"]
var output: String
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(10): await process_frame
func shot(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png"))==OK)
func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	state.player_level = 25
	state.player_gold = 432
	state.player_xp = 720
	state.add_material("Seiva Ancestral",40)
	for row in state.recipes_for("REG_002_FLORESTA_ANCESTRAL"):
		state.craft_item("REG_002_FLORESTA_ANCESTRAL",String(row.id))
	state.equip_item("starter_blade")
	for scene in SCENES:
		root.size = Vector2i(960,540)
		root.content_scale_size = root.size
		var host = load("res://scenes/cartoon/%s.tscn"%scene).instantiate()
		root.add_child(host)
		current_scene = host
		await settle()
		host.set_process(false)
		host.hero.set_process(false)
		var layout = host.get_node("HUD/GameLayout")
		layout.demon_director.set_process(false)
		for mob in host.monsters: mob.set_process(false)
		if scene==SCENES[0]:
			host.hero.position = Region.world_from_hub(Vector2(1150,1500))
			host.camera.position_smoothing_enabled = false
			host.camera.reset_smoothing()
			host.world_stream._refresh(true)
		host.hero.spell_cooldowns.assign([0.0,1.3,2.7])
		host._refresh_stats()
		host.toast_label.text = ""
		host.poi_label.text = ""
		await shot("hud_"+scene)
		if scene==SCENES[0]:
			root.size = Vector2i(640,360)
			root.content_scale_size = root.size
			await shot("hud_mobile")
			for dimensions in [Vector2i(640,360),Vector2i(960,540)]:
				root.size = dimensions
				root.content_scale_size = dimensions
				var suffix: String = "_mobile" if dimensions.x==640 else "_desktop"
				host.inventory_ui.open_panel()
				await shot("inventory"+suffix)
				host.inventory_ui._set_tab("consumables")
				await shot("consumables"+suffix)
				host.inventory_ui.close_panel()
				layout.mission_ui.open_panel()
				layout.mission_ui.show_tab("available")
				await shot("missions"+suffix)
				layout.mission_ui.close_panel()
				layout.class_ui.open_panel()
				await shot("classes"+suffix)
				layout.class_ui.show_tab("skills")
				await shot("skills"+suffix)
				layout.class_ui.close_panel()
				host.guild_board.open_panel()
				await shot("guild"+suffix)
				host.guild_board.close_panel()
				host.crafting_ui._toggle()
				await shot("forge"+suffix)
				host.crafting_ui.close_panel()
				host._toggle_map()
				await shot("map"+suffix)
				host._toggle_map()
				layout.open_pause()
				await shot("pause"+suffix)
				layout.close_pause()
		host.queue_free()
		await settle()
	var menu = load("res://scenes/cartoon/CartoonMainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	await shot("menu_mobile")
	menu._open_options()
	await shot("options_mobile")
	menu.options_panel.visible = false
	menu._show_confirmation("delete","Excluir o progresso salvo?")
	await shot("confirmation_mobile")
	menu._cancel_confirmation()
	state.reset_progress(true)
	print("radial_v038 QA: eight regions and every major interface in the reference style")
	quit()
