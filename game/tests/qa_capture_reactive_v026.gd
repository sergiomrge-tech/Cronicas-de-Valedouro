extends SceneTree
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
var hub
var output: String
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(5): await process_frame
func shot(key: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(key+".png"))
func advance(delta: float) -> void:
	hub._update_monsters(delta)
	hub.hero._process(delta)
	for mob in hub.monsters: mob._process(delta)
	for effect in get_nodes_in_group("cartoon_combat_fx"):
		if not effect.is_queued_for_deletion():
			effect.set_process(false)
			effect._process(delta)
func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(960,540)
	root.content_scale_size = root.size
	root.get_node("CartoonPlayerState").reset_progress(true)
	hub = HubScene.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	hub.hero.set_process(false)
	hub.wildlife.process_mode = Node.PROCESS_MODE_DISABLED
	for animal in hub.wildlife.active.values(): animal.queue_free()
	hub.wildlife.active.clear()
	for mob in hub.monsters: mob.queue_free()
	hub.monsters.clear()
	await settle()
	var origin: Vector2 = Region.world_from_hub(Vector2(1150,1850))
	for scenario in ["dodge","boss"]:
		hub.hero.position = origin
		hub.hero.facing = Vector2.RIGHT
		hub.hero.move_vector = Vector2.ZERO
		hub.hero.dodge_cooldown = 0
		hub.hero.dodge_t = 0
		hub.zoom_controls.set_zoom_value(1.15,false)
		hub.camera.offset = Vector2(70,-20)
		hub.camera.reset_smoothing()
		var mob = Monster.new()
		mob.setup({"kind":"wolf" if scenario=="dodge" else "goblin","hp":100,"damage":7,"pos":origin+Vector2(45,0),"boss_id":"QA_BOSS" if scenario=="boss" else ""})
		hub.objects.add_child(mob)
		hub.monsters.append(mob)
		mob.set_process(false)
		hub._show_toast("Saia do círculo antes do golpe • Shift ou ESQUIVA")
		for frame in range(40):
			if frame==(10 if scenario=="dodge" else 20):
				hub.hero.move_vector = Vector2.LEFT
				assert(hub.hero.try_dodge(hub))
			advance(0.025)
			await shot("%s_%02d"%[scenario,frame])
		mob.queue_free()
		hub.monsters.clear()
		await settle()
	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	await settle()
	await shot("mobile_hud")
	print("reactive_v026 QA: real warning, dodge and mobile frames captured")
	quit()
