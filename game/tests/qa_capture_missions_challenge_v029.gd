extends SceneTree
const Contracts = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")
const HubRegion = preload("res://scripts/cartoon/cartoon_region_config.gd")
var output: String
var host
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func shot(key: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(key+".png"))
func freeze() -> void:
	host.set_process(false)
	host.hero.set_process(false)
	var director = host.get_node("HUD/GameLayout").demon_director
	director.set_process(false)
	for monster in host.monsters: monster.set_process(false)
	if host.get("wildlife")!=null:
		host.wildlife.set_process(false)
		for animal in host.wildlife.active.values(): animal.set_process(false)
func load_region(name: String) -> void:
	if is_instance_valid(host):
		host.queue_free()
		await settle()
	host = load("res://scenes/cartoon/"+name+".tscn").instantiate()
	root.add_child(host)
	current_scene = host
	await settle()
	freeze()
func view_actor(actor) -> void:
	host.camera.position_smoothing_enabled = false
	host.camera.zoom = Vector2.ONE
	host.hero.position = actor.home+Vector2(0,65)
	host.camera.reset_smoothing()
	host.world_stream._refresh(true)
	actor.anim_t = 0.4
	actor.queue_redraw()
func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	root.size = Vector2i(960,640)
	root.content_scale_size = root.size
	await load_region("ValedouroCartoonHub")
	host.hero.position = HubRegion.world_from_hub(Vector2(1150,1850))
	host.camera.reset_smoothing()
	host.story_runtime.try_location("LOC_VAL_GATE")
	host.story_runtime.try_location("LOC_VAL_GUILD")
	for id in ["GUILD_RABBITS","GUILD_DEER","GUILD_VARIETY"]: Contracts.accept(state,id)
	var layout = host.get_node("HUD/GameLayout")
	layout.mission_button.pressed.emit()
	await shot("missions_desktop")
	layout.mission_ui._track("GUILD_RABBITS")
	await shot("selected_contract")
	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	await shot("missions_mobile")
	layout.mission_ui.scroll.scroll_vertical = 250
	await shot("missions_mobile_scrolled")
	layout.mission_ui.show_tab("available")
	await shot("available_mobile")
	layout.mission_ui.show_tab("completed")
	await shot("completed_mobile")
	layout.mission_ui.close_panel()
	layout._update_tracking(1)
	await shot("tracking_hud_mobile")
	host._toggle_map()
	layout._update_tracking(1)
	await shot("tracking_map_mobile")
	host._toggle_map()
	root.size = Vector2i(960,640)
	root.content_scale_size = root.size
	await shot("tracking_hud_desktop")
	state.set_tracked_mission("main")
	var director = layout.demon_director
	var actor
	for kind in ["ember","void","ruin"]:
		for candidate in director.active.values():
			if candidate.variant==kind:
				actor = candidate
				break
		view_actor(actor)
		await shot("elite_"+kind)
	view_actor(actor)
	actor.hex_cooldown = 0
	actor._process(0.01)
	for frame in range(4):
		actor._process(0.18)
		await shot("elite_warning_%02d" % frame)
	host.hero.dodge_cooldown = 0
	assert(host.hero.try_dodge(host))
	host.hero._process(0.09)
	host.camera.reset_smoothing()
	await shot("elite_dodge")
	host.hero.dodge_t = 0
	host._damage_monster(actor,99999)
	await shot("elite_reward_progress")
	for scene in ["ForestAncientCartoon","FrostMountainsCartoon","AbyssHeartCartoon"]:
		await load_region(scene)
		var demon = host.get_node("HUD/GameLayout").demon_director.active.values()[0]
		view_actor(demon)
		await shot("elite_region_"+scene)
	print("missions_challenge_v029 QA: actual journal/touch layout, tracking HUD/map, 3 elite demons, warnings, dodge and regions")
	quit()
