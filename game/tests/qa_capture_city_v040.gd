extends SceneTree
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Buildings = preload("res://scripts/cartoon/cartoon_building_assets_v040.gd")
const Prop = preload("res://scripts/cartoon/cartoon_prop.gd")
const Story = preload("res://scripts/cartoon/cartoon_main_story_map.gd")
class FoundationProbe extends Node2D:
	const Buildings = preload("res://scripts/cartoon/cartoon_building_assets_v040.gd")
	var key: String
	func _draw() -> void: draw_texture_rect(Buildings.texture(key),Buildings.rect_for(key),false)
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
	root.size = Vector2i(256,256)
	root.content_scale_size = root.size
	root.transparent_bg = true
	var probe = FoundationProbe.new()
	probe.position = Vector2(128,220)
	root.add_child(probe)
	for key: String in Buildings.manifest.assets:
		probe.key = key
		probe.queue_redraw()
		await settle()
		await RenderingServer.frame_post_draw
		var image: Image = root.get_texture().get_image()
		var bottom: int = -1
		for y in range(255,-1,-1):
			for x in range(256):
				if image.get_pixel(x,y).a>0.20: bottom = y; break
			if bottom>=0: break
		assert(absi(bottom-220)<=3,"Rendered foundation floats: %s bottom=%d"%[key,bottom])
	probe.queue_free()
	await settle()
	root.transparent_bg = false
	root.size = Vector2i(1440,600)
	root.content_scale_size = root.size
	var gallery = Node2D.new()
	root.add_child(gallery)
	var index: int = 0
	for key: String in Buildings.manifest.assets:
		var art = FoundationProbe.new()
		art.key = key
		art.position = Vector2(120+240*(index%6),235+285*(index/6))
		gallery.add_child(art)
		var label = Label.new()
		label.text = key
		label.position = art.position+Vector2(-90,12)
		label.size.x = 180
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gallery.add_child(label)
		index += 1
	await shot("buildings_gallery")
	gallery.queue_free()
	await settle()
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
	var points = [{"name":"plaza","pos":Vector2(1150,970)},{"name":"residential","pos":Vector2(600,650)},
		{"name":"forge","pos":Vector2(720,860)},{"name":"tavern","pos":Vector2(1580,880)},
		{"name":"guild","pos":Vector2(760,1210)},{"name":"alchemist","pos":Vector2(1540,1210)},
		{"name":"farm","pos":Vector2(900,2100)},{"name":"castle","pos":Vector2(2500,-150)}]
	for location: Dictionary in Story.act1_locations():
		if location.id=="LOC_SIX_CROWNS_ARCHIVE": points.append({"name":"archive","pos":Region.hub_from_world(location.pos)+Vector2(0,95)})
	var max_draw_calls: float = 0
	for entry in points:
		hub.hero.position = Region.world_from_hub(entry.pos)
		hub.world_stream._refresh(true)
		hub.camera.reset_smoothing()
		await shot(entry.name)
		var calls: float = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		assert(calls>0 and calls<2000,"Draw budget regressed in %s: %d"%[entry.name,calls])
		max_draw_calls = maxf(max_draw_calls,calls)
		if entry.name=="plaza":
			hub.inventory_ui.open_panel("equipment")
			await shot("inventory")
			hub.inventory_ui.close_panel()
	# Render budget covers both main camera and minimap. Do not gate on FPS,
	# which depends on the runner's GPU; reject the old 25k draw-call regression.
	state.reset_progress(true)
	print("city_v040: PASS — 12 rendered foundations, 11 captures, main/minimap draw budget max %d"%max_draw_calls)
	quit()
