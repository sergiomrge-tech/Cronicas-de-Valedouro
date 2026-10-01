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
func dummy(offset: Vector2):
	var actor = Monster.new()
	actor.setup({"kind":"wolf","hp":100,"speed":100,"pos":hub.hero.position+offset})
	hub.objects.add_child(actor)
	hub.monsters.append(actor)
	actor.set_process(false)
	return actor
func advance(delta: float) -> void:
	hub.hero._process(delta)
	for monster in hub.monsters:
		if is_instance_valid(monster) and not monster.is_queued_for_deletion(): monster._process(delta)
	for projectile in get_nodes_in_group("cartoon_spell_projectiles"):
		if not projectile.is_queued_for_deletion():
			projectile.set_process(false)
			projectile._process(delta)
	# FX remain real game nodes. Their time is stepped once per captured frame.
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
	for monster in hub.monsters: monster.queue_free()
	hub.monsters.clear()
	hub.hero.position = Region.world_from_hub(Vector2(1150,1850))
	hub.zoom_controls.set_zoom_value(1.15,false)
	hub.camera.offset = Vector2(70,-20)
	hub.camera.reset_smoothing()
	await settle()
	for spell in range(3):
		dummy(Vector2(175,0))
		if spell==2: dummy(Vector2(245,30))
		hub.hero.spell_index = spell
		hub.hero.spell_cooldowns[hub.hero.spell_index] = 0
		hub._show_toast(["Brasa • impacto e queimadura","Cristal • impacto e lentidão","Arcana • impacto e salto entre alvos"][spell])
		assert(hub.hero.cast_spell(hub))
		for frame in range(40):
			advance(0.05)
			await shot("%s_%02d"%[hub.hero.SPELLS[spell],frame])
		for projectile in get_nodes_in_group("cartoon_spell_projectiles"): projectile.queue_free()
		for monster in hub.monsters: monster.queue_free()
		hub.monsters.clear()
		await settle()
	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	dummy(Vector2(175,0))
	hub.hero.spell_index = 1
	hub.hero.spell_cooldowns[hub.hero.spell_index] = 0
	assert(hub.hero.cast_spell(hub))
	advance(0.45)
	await settle()
	await shot("mobile_hud")
	print("elemental_v025 QA: real in-game frames captured")
	quit()
