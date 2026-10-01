extends SceneTree
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Contracts = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")
var output: String
var hub
func _initialize() -> void:
	call_deferred("run")
func settle() -> void:
	for i in range(10): await process_frame
func capture(name_v: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(name_v+".png"))
func run() -> void:
	output = OS.get_cmdline_user_args()[0] if not OS.get_cmdline_user_args().is_empty() else "user://living_world_qa"
	DirAccess.make_dir_recursive_absolute(output)
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(960,540)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	hub = HubScene.instantiate()
	root.add_child(hub)
	await settle()
	hub.hero.position = Region.world_from_hub(Vector2(1150,970))
	hub.camera.reset_smoothing()
	await capture("01_cidade_viva")
	for pair in [["tavern",Vector2(1580,855),"02_taverna"],["forge",Vector2(720,850),"03_ferreiro"],["guild",Vector2(760,1185),"04_guilda"]]:
		hub.hero.position = Region.world_from_hub(pair[1])
		hub.interiors.enter(pair[0])
		hub.hero.position = Vector2(0,-55)
		hub.zoom_controls.set_zoom_value(0.70,false)
		hub.camera.reset_smoothing()
		hub.toast_label.text = ""
		hub.toast_timer = 0
		await capture(pair[2])
		hub.ui.visible = false
		await capture(pair[2]+"_panorama")
		hub.ui.visible = true
		if pair[0] == "guild":
			hub.hero.position = Vector2(-320,-95)
			hub.guild_board.open_panel()
			await capture("05_quadro_missoes")
			Contracts.accept(state,"GUILD_RABBITS")
			Contracts.accept(state,"GUILD_BOARS")
			Contracts.accept(state,"GUILD_MEAT")
			for i in range(3): Contracts.register_hunt(state,"rabbit")
			hub.guild_board.refresh()
			await capture("06_contratos_ativos")
			root.content_scale_size = Vector2i(640,360)
			root.size = Vector2i(640,360)
			await capture("07_quadro_mobile")
			root.content_scale_size = Vector2i(960,540)
			root.size = Vector2i(960,540)
			hub.guild_board.close_panel()
		hub.interiors.leave()
		hub.zoom_controls.set_zoom_value(1.0,false)
		hub.camera.reset_smoothing()
		await capture(pair[2]+"_exterior")
	# Stage a reachable habitat view using existing authored spawn slots.
	hub.toast_label.text = ""
	hub.toast_timer = 0
	hub.hero.position = Region.world_from_hub(Vector2(950,1800))
	hub.camera.reset_smoothing()
	hub.wildlife._sync()
	await capture("08_campos_fauna")
	# Actual species and animation assets in a side-by-side habitat, avoiding UI.
	var n: int = 0
	for animal in hub.wildlife.active.values():
		if n >= 6: break
		animal.position = hub.hero.position+Vector2(-220+float(n%3)*190,-95+float(n/3)*145)
		animal.home = animal.position
		animal.destination = animal.position
		animal.wander_time = 30
		n += 1
	await capture("09_fauna_detalhe")
	hub.hero.position = Region.world_from_hub(Vector2(720,850))
	hub.interiors.enter("forge")
	hub.hero.position = Vector2(-90,-20)
	state.materials["Osso de caça"] = 5
	state.materials["Couro do Vale"] = 5
	hub.interiors.interact()
	await capture("10_fabricacao_inicial")
	hub.crafting_ui.close_panel()
	hub.interiors.leave()
	state.reset_progress(true)
	print("living_world_v022 QA: 16 real Godot captures")
	quit(0)
