extends SceneTree
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Art = preload("res://scripts/cartoon/cartoon_pilot_art_v041.gd")
const Person = preload("res://scripts/cartoon/cartoon_town_person_v041.gd")
class NatureProbe extends Node2D:
	const Art = preload("res://scripts/cartoon/cartoon_pilot_art_v041.gd")
	var key: String
	var creature: bool = false
	var pose: int = 0
	func _draw() -> void:
		if creature: Art.draw_creature(self,key,pose)
		else: draw_texture_rect(Art.nature_texture(key),Art.nature_rect(key),false)
var output: String
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(12): await process_frame
func shot(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png"))==OK)
func foundation(label: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	var bottom: int = -1
	for y in range(image.get_height()-1,-1,-1):
		for x in range(image.get_width()):
			if image.get_pixel(x,y).a>0.20: bottom = y; break
		if bottom>=0: break
	assert(absi(bottom-220)<=3,"Floating pilot sprite %s: %d"%[label,bottom])
func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(256,256)
	root.content_scale_size = root.size
	root.transparent_bg = true
	var nature = NatureProbe.new(); nature.position = Vector2(128,220); root.add_child(nature)
	for key: String in Art.manifest.nature:
		nature.key = key; nature.queue_redraw()
		await foundation(key)
	nature.queue_free(); await settle()
	for role: String in Art.manifest.people:
		var person = Person.new(); person.setup(role); person.position = Vector2(128,220); root.add_child(person)
		person.play("walk"); person.pause()
		for i in range(4):
			person.frame = i%person.sprite_frames.get_frame_count("walk")
			person._align_boots()
			await foundation(role+str(i))
		person.flip_h = true; person._align_boots(); await foundation(role+" flipped")
		person.queue_free(); await settle()
	for kind: String in Art.manifest.creatures:
		var actor = NatureProbe.new(); actor.creature = true; actor.key = kind; actor.position = Vector2(128,220); root.add_child(actor)
		for pose in range(3):
			actor.pose = pose
			for flip in [false,true]:
				actor.scale.x = -1 if flip else 1; actor.queue_redraw()
				await foundation(kind+str(pose)+str(flip))
		actor.queue_free(); await settle()
	root.transparent_bg = false
	root.size = Vector2i(1120,600); root.content_scale_size = root.size
	var gallery = Node2D.new(); root.add_child(gallery)
	var index: int = 0
	for key: String in Art.manifest.nature:
		var prop = NatureProbe.new(); prop.key = key
		prop.position = Vector2(140+280*(index%4),240+270*(index/4)); gallery.add_child(prop)
		var label = Label.new(); label.text = key; label.position = prop.position+Vector2(-45,12); gallery.add_child(label)
		index += 1
	await shot("nature_gallery")
	gallery.queue_free(); await settle()
	gallery = Node2D.new(); root.add_child(gallery); index = 0
	root.size = Vector2i(1120,780); root.content_scale_size = root.size
	for role: String in Art.manifest.people:
		for i in range(3):
			var person = Person.new(); person.setup(role); person.play("walk"); person.pause()
			person.frame = [0,1,3][i]%person.sprite_frames.get_frame_count("walk"); person._align_boots()
			person.position = Vector2(90+185*(index%6),230+230*(index/6)); gallery.add_child(person)
			var label = Label.new(); label.text = role+" "+str(i); label.position = person.position+Vector2(-50,12); gallery.add_child(label)
			index += 1
	await shot("people_gallery")
	gallery.queue_free(); await settle()
	root.size = Vector2i(1120,780); root.content_scale_size = root.size
	gallery = Node2D.new(); root.add_child(gallery); index = 0
	for kind: String in Art.manifest.creatures:
		for pose in range(3):
			var actor = NatureProbe.new(); actor.creature = true; actor.key = kind; actor.pose = pose
			actor.position = Vector2(90+185*(index%6),210+230*(index/6)); gallery.add_child(actor)
			var label = Label.new(); label.text = kind+" "+str(pose); label.position = actor.position+Vector2(-45,12); gallery.add_child(label)
			index += 1
	await shot("creatures_gallery")
	gallery.queue_free(); await settle()
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
	hub.camera.position_smoothing_enabled = false
	hub.get_node("HUD/GameLayout").demon_director.set_process(false)
	hub.wildlife.set_process(false)
	hub.ambient_encounters.set_process(false)
	for mob in hub.monsters: mob.set_process(false)
	for entry in [{"name":"plaza","pos":Vector2(1150,970)},{"name":"street","pos":Vector2(600,650)},{"name":"north_exit","pos":Vector2(1150,-450)},{"name":"west_edge","pos":Vector2(-300,630)},{"name":"fields","pos":Vector2(1150,2080)}]:
		hub.hero.position = Region.world_from_hub(entry.pos)
		hub.camera.reset_smoothing()
		hub.world_stream._refresh(true)
		hub.wildlife._sync()
		if hub.get("ambient_encounters") != null:
			for i in range(5): hub.ambient_encounters._sync()
			for mob in hub.ambient_encounters.active.values(): mob.set_process(false)
		await shot(entry.name)
		var calls: float = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		assert(calls>0 and calls<2000,"Pilot render budget regressed: %s %d"%[entry.name,calls])
	for key: String in ["tavern","forge","guild"]:
		hub.interiors.enter(key)
		hub.hero.position = Vector2(0,-55)
		hub.zoom_controls.set_zoom_value(0.70,false)
		hub.camera.reset_smoothing()
		await shot("interior_"+key)
		hub.interiors.leave()
	state.reset_progress(true)
	print("pilot_v041: PASS — 8 foliage contacts, 30 NPC pose/flip contacts, 36 creature pose/flip contacts, galleries, five pilot views, three interiors and <2000 draw calls")
	quit()
