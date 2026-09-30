extends SceneTree

const MenuScene = preload("res://scenes/cartoon/CartoonMainMenu.tscn")
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var output_dir: String = "user://ci_output_cartoon_ui"
	if OS.get_cmdline_user_args().size() > 0:
		output_dir = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

	var state = root.get_node_or_null("CartoonPlayerState")
	assert(state != null)
	state.reset_progress(true)

	var menu: Node = MenuScene.instantiate()
	root.add_child(menu)
	await _settle()
	await _shot(output_dir,"01_menu_novo_jogo")

	state.start_new_game()
	state.add_material("Seiva Ancestral",5)
	state.craft("REG_002_FLORESTA_ANCESTRAL","weapon")
	state.craft("REG_002_FLORESTA_ANCESTRAL","armor")
	menu._refresh_profile()
	await _settle()
	await _shot(output_dir,"02_menu_com_save")

	menu._open_options()
	await _settle()
	await _shot(output_dir,"03_menu_opcoes")
	menu.options_panel.visible = false

	menu._delete_save()
	await _settle()
	await _shot(output_dir,"04_confirmacao_excluir")
	menu._cancel_confirmation()

	menu.inventory_ui.open_panel("equipment")
	await _settle()
	await _shot(output_dir,"05_inventario_menu")
	menu.inventory_ui.close_panel()

	menu.queue_free()
	await process_frame
	await process_frame

	state.reset_progress(true)
	state.start_new_game()
	state.add_material("Seiva Ancestral",5)

	var hub: Node = HubScene.instantiate()
	root.add_child(hub)
	await _settle()
	await _shot(output_dir,"06_hud_zoom")

	hub.inventory_ui.open_panel("equipment")
	await _settle()
	await _shot(output_dir,"07_inventario_jogo")
	hub.inventory_ui.close_panel()

	hub.crafting_ui._toggle()
	await _settle()
	await _shot(output_dir,"08_forja_jogo")

	state.reset_progress(true)
	print("CARTOON_UI_CAPTURE: PASS")
	quit(0)

func _settle() -> void:
	for i in 4:
		await process_frame

func _shot(output_dir: String,name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var out: String = "%s/%s.png" % [output_dir,name]
	var err: Error = image.save_png(ProjectSettings.globalize_path(out))
	assert(err == OK)
	print("CARTOON_UI_CAPTURED ",out)
