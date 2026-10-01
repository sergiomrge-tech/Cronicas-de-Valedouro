extends SceneTree
const Hero = preload("res://scripts/cartoon/cartoon_hero.gd")
const Art = preload("res://scripts/cartoon/cartoon_hero_art_v028.gd")
const Visual = preload("res://scripts/cartoon/cartoon_visual_assets.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
class FrameProbe extends Node2D:
	const Art = preload("res://scripts/cartoon/cartoon_hero_art_v028.gd")
	var direction: String
	var animation: String
	var frame: int
	func _draw() -> void:
		draw_set_transform(Vector2(0,Art.ground_offset(animation,frame)))
		Art.hero_frame(self,direction,animation,frame,Art.GROUND_RECT)
var output: String
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
	root.size = Vector2i(128,128)
	root.content_scale_size = root.size
	root.transparent_bg = true
	var probe = FrameProbe.new()
	probe.position = Vector2(64,110)
	root.add_child(probe)
	var checked: int = 0
	for direction in ["front","back","left","right"]:
		for animation in Art.FRAMES:
			if animation=="death": continue
			for frame in range(Art.FRAMES[animation]):
				probe.direction = direction
				probe.animation = animation
				probe.frame = frame
				probe.queue_redraw()
				await process_frame
				await RenderingServer.frame_post_draw
				var picture = root.get_texture().get_image()
				var lowest: int = -1
				for y in range(127,-1,-1):
					for x in range(128):
						if picture.get_pixel(x,y).a>0.20:
							lowest = y
							break
					if lowest>=0: break
				assert(absi(lowest-110)<=2,"Floating frame: %s/%s/%d bottom=%d"%[direction,animation,frame,lowest])
				checked += 1
	probe.queue_free()
	await settle()
	root.transparent_bg = false
	root.size = Vector2i(960,540)
	root.content_scale_size = root.size
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	var hub = load("res://scenes/cartoon/ValedouroCartoonHub.tscn").instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	hub.hero.set_process(false)
	hub.get_node("HUD/GameLayout").demon_director.set_process(false)
	for mob in hub.monsters: mob.set_process(false)
	hub.camera.position_smoothing_enabled = false
	for entry in [{"name":"hero_idle","pos":Vector2(1150,1500)},{"name":"city_houses","pos":Vector2(600,650)},{"name":"farm_house","pos":Vector2(900,2100)}]:
		hub.hero.position = Region.world_from_hub(entry.pos)
		hub.world_stream._refresh(true)
		hub.camera.reset_smoothing()
		await shot(entry.name)
		hub.hero.set_motion(Vector2.DOWN)
		hub.hero.anim_t = 0.375
		await shot(entry.name+"_walking")
		hub.hero.set_motion(Vector2.ZERO)
	var rect: Rect2 = Visual.building_rect()
	assert(absf((rect.position+Vector2(132,208)*rect.size/Vector2(210,225)).y)<0.001)
	state.reset_progress(true)
	print("grounding_v039: PASS — %d rendered standing frames touch ground; house foundation anchors and six real world captures"%checked)
	quit()
