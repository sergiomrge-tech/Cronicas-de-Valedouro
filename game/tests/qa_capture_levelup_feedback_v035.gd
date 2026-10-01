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

func xp_between(state,from_level: int,to_level: int) -> int:
	var total: int = 0
	for level_value in range(from_level,to_level):
		total += state.xp_to_next(level_value)
	return total

func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	state.player_level = 7
	state.player_xp = 0
	state.save_profile()

	root.size = Vector2i(640,360)
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
	if host.wildlife != null:
		host.wildlife.set_process(false)

	layout._process(0.01)
	host._refresh_stats()
	await shot("level7_before_unlock")

	state.gain_xp(state.xp_to_next(7))
	host._refresh_stats()
	layout._process(0.01)
	await shot("level8_equipment_unlock")

	state.gain_xp(xp_between(state,8,10))
	host._refresh_stats()
	layout._process(0.01)
	await shot("level10_crystal_unlock")

	state.gain_xp(xp_between(state,10,25))
	host._refresh_stats()
	layout._process(0.01)
	await shot("level25_arcana_unlock")

	state.reset_progress(true)
	print("levelup_feedback_v035 QA: level 8 tier unlock, level 10 Cristal and level 25 Arcana")
	quit()
