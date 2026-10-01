extends SceneTree
const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
var output: String
var host
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func shot(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png"))==OK)
func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	root.size = Vector2i(960,640)
	root.content_scale_size = root.size
	host = Hub.instantiate()
	root.add_child(host)
	current_scene = host
	await settle()
	host.set_process(false)
	host.hero.set_process(false)
	host.get_node("HUD/GameLayout").demon_director.set_process(false)
	for m in host.monsters:
		m.set_process(false)
		m.position = Vector2(-9000,-9000)
	host.wildlife.set_process(false)
	for a in host.wildlife.active.values():
		a.set_process(false)
		a.position = Vector2(-9000,-9000)
	host.hero.position = Vector2(4000,4000)
	host.camera.position_smoothing_enabled = false
	host.camera.zoom = Vector2.ONE
	host.camera.reset_smoothing()
	host.world_stream._refresh(true)
	host.poi_label.text = ""
	host.toast_label.text = ""
	var target = Monster.new()
	target.setup({"kind":"wolf","name":"Lobo","level":1,"hp":500,"pos":host.hero.position+Vector2(150,0)})
	host.objects.add_child(target)
	host.monsters.append(target)
	target.set_process(false)
	await shot("three_spells_desktop")
	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	await shot("three_spells_mobile_ready")
	assert(host.hero.cast_spell(host,0))
	for p in get_nodes_in_group("cartoon_spell_projectiles"): p.set_process(false)
	host.hero._process(0.8)
	await shot("mobile_ember_cooldown_others_ready")
	assert(host.hero.cast_spell(host,1))
	for p in get_nodes_in_group("cartoon_spell_projectiles"): p.set_process(false)
	await shot("mobile_ember_frost_cooldowns_arcane_ready")
	assert(host.hero.cast_spell(host,2))
	for p in get_nodes_in_group("cartoon_spell_projectiles"):
		p.set_process(false)
		p._process(0.18)
	await shot("mobile_all_three_projectiles")
	for p in get_nodes_in_group("cartoon_spell_projectiles"): p._process(0.2)
	await shot("mobile_three_impacts")
	host.hero._process(2.3)
	await shot("mobile_ember_ready_others_cooling")
	root.size = Vector2i(1280,720)
	root.content_scale_size = root.size
	await shot("three_spells_wide")
	print("spell_slots_v030 QA: 8 actual Godot captures, 3 spell buttons and separate cooldown states")
	quit()
