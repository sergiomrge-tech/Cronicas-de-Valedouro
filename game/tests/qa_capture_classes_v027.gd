extends SceneTree
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
var hub
var ui
var output: String
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func shot(key: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(key+".png"))
func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	root.size = Vector2i(960,640)
	root.content_scale_size = root.size
	hub = HubScene.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.hero.position = Region.world_from_hub(Vector2(1150,1850))
	hub.camera.reset_smoothing()
	ui = hub.get_node("HUD/GameLayout").class_ui
	hub.hud_status.hero_button.pressed.emit()
	await shot("classes_desktop")
	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	ui._switch("mage")
	ui.show_tab("skills")
	ui._upgrade("power")
	await shot("first_evolution_mobile")
	ui.show_tab("classes")
	await shot("classes_mobile")
	ui.scroll.scroll_vertical = 200
	await shot("classes_mobile_scrolled")
	root.size = Vector2i(960,640)
	root.content_scale_size = root.size
	while state.player_level<20: state.gain_xp(state.xp_to_next())
	state.skill_ranks = {"blade":3,"guard":2,"footwork":1,"power":3,"focus":2,"elements":1,"hunt":3,"agility":2,"reach":1}
	for id in ["warrior","mage","hunter"]:
		ui._switch(id)
		ui.show_tab("skills")
		await shot("skills_"+id)
	ui.show_tab("classes")
	ui._switch("mage")
	ui.close_panel()
	hub._refresh_stats()
	await shot("class_hud")
	print("classes_v027 QA: real class selection, evolution, scroll and HUD captured")
	quit()
