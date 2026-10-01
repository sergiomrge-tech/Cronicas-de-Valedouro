extends SceneTree

const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")

var output: String
var hub
var layout
var boss

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

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	hub.hero.set_process(false)
	if hub.wildlife != null:
		hub.wildlife.set_process(false)
	layout = hub.get_node("HUD/GameLayout")
	if layout.demon_director != null:
		layout.demon_director.set_process(false)
	for mob in hub.monsters:
		if is_instance_valid(mob):
			mob.set_process(false)

	boss = Monster.new()
	boss.setup({
		"kind":"ash_general",
		"name":"General da Cinza",
		"boss_id":"BOSS_GENERAL_CINZA_001",
		"level":24,
		"hp":100,
		"damage":20,
		"speed":80.0,
		"pos":hub.hero.position+Vector2(110,0),
		"scale":1.22
	})
	hub.objects.add_child(boss)
	hub.monsters.append(boss)
	boss.set_process(false)
	layout._process(0.01)
	await shot("boss_phase1_mobile")

	boss.take_damage(40)
	layout._process(0.01)
	await shot("boss_phase2_hud")

	boss.position = hub.hero.position+Vector2(30,0)
	boss.attack_cooldown = 0.0
	boss.lunge_t = 0.0
	boss.boss_attack_index = 2
	boss.advance_contact(hub.hero,0.0,52.0)
	layout._process(0.01)
	await shot("boss_phase2_special_telegraph")

	boss.windup_t = 0.0
	boss.attack_cooldown = 0.0
	boss.lunge_t = 0.0
	boss.hp = 30
	boss._update_boss_phase()
	boss.boss_attack_index = 1
	boss.advance_contact(hub.hero,0.0,52.0)
	layout._process(0.01)
	await shot("boss_phase3_rupture")

	state.reset_progress(true)
	print("boss_combat_v037 QA: boss bar, phase II, special telegraph and phase III rupture")
	quit()
