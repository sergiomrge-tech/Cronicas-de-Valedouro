extends SceneTree
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Palace = preload("res://scripts/cartoon/cartoon_royal_palace.gd")
const StoryMap = preload("res://scripts/cartoon/cartoon_main_story_map.gd")
const Assets = preload("res://scripts/cartoon/cartoon_royal_assets.gd")
func _initialize() -> void:
	call_deferred("run")
func settle() -> void:
	for i in range(5): await process_frame
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	var hub = HubScene.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	assert(Assets.texture("royal_castle").get_width()>=1600)
	assert(hub.environment.is_walkable(Region.world_from_hub(Vector2(1150,330))))
	assert(hub.environment.is_walkable(Region.world_from_hub(Region.CASTLE_DOOR)))
	assert(not hub.environment.is_walkable(Region.world_from_hub(Region.CASTLE_ANCHOR-Vector2(0,100))))
	# Actual outdoor route from city arrival to the new palace entrance.
	for x in range(1150,2501,20): assert(hub.environment.is_walkable(Region.world_from_hub(Vector2(x,120))),"Royal avenue blocked")
	for y in range(-280,121,20): assert(hub.environment.is_walkable(Region.world_from_hub(Vector2(2500,y))),"Royal approach blocked")
	for y in range(-1700,331,20): assert(hub.environment.is_walkable(Region.world_from_hub(Vector2(1150,y))),"Northern campaign road blocked")
	for row in StoryMap.act1_locations():
		if row.id == "LOC_VAL_NORTH_ROAD": assert(hub.environment.is_walkable(row.pos),"Canonical story location blocked by castle")
	for slot in hub.wildlife.slots: assert(not Region.ROYAL_GROUNDS.has_point(slot.pos),"Wildlife inside palace estate")
	hub.hero.position = Region.world_from_hub(Region.CASTLE_DOOR)
	var outside: Vector2 = hub.hero.position
	var story_id: String = hub.story_runtime.current_id
	hub._interact()
	await settle()
	assert(hub.interiors.active and hub.interiors.kind == "castle")
	assert(hub.hero.position == Palace.SPAWN)
	assert(hub.camera.limit_left == int(Palace.BOUNDS.position.x))
	assert(hub.interiors.room_objects.get_child_count()>100,"Castle is insufficiently furnished")
	assert(not hub.get_node("HUD/GameLayout").attack_button.visible)
	assert(hub.get_node("HUD/GameLayout").map_button.text == "SAIR")
	for corridor in Palace.CORRIDORS:
		var connections: int = 0
		for room in Palace.ROOMS:
			if corridor.grow(-16).intersection(room.rect.grow(-26)).has_area(): connections += 1
		assert(connections>=2,"Corridor does not overlap two rooms")
	# Flood-fill the full multi-wing palace with its furniture collision.
	var start: Vector2i = Vector2i(0,65)
	var todo: Array[Vector2i] = [start]
	var visited: Dictionary = {start:true}
	var cursor: int = 0
	while cursor < todo.size():
		var cell: Vector2i = todo[cursor]
		cursor += 1
		for direction: Vector2i in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
			var next: Vector2i = cell+direction
			if visited.has(next) or not hub.interiors.is_walkable(Vector2(next)*20): continue
			visited[next] = true
			todo.append(next)
	assert(visited.size()>16000,"Palace exploration area too small")
	for room in Palace.ROOMS:
		var reached: bool = false
		for cell in todo:
			if room.rect.grow(-60).has_point(Vector2(cell)*20):
				reached = true
				break
		assert(reached,"Disconnected palace wing: "+String(room.title))
	for point in hub.interiors.points:
		var reached: bool = false
		for cell in todo:
			if (Vector2(cell)*20).distance_to(point.pos)<90:
				reached = true
				break
		assert(reached,"Blocked palace service: "+String(point.label))
	assert(not hub.interiors.is_walkable(Vector2(-740,800)),"Walls can be crossed")
	hub.hero.position = Vector2(0,-270)
	hub._interact()
	assert(hub.toast_label.text.contains("Rei de Valedouro"))
	assert(hub.story_runtime.current_id == story_id,"Royal visit modified campaign")
	hub.hero.position = Vector2(1420,1160)
	hub.player_hp = 1
	hub._interact()
	assert(hub.player_hp == hub.player_max_hp)
	state.save_profile()
	assert(state.player_position == outside)
	state.load_profile()
	assert(state.player_position == outside)
	for size_v: Vector2i in [Vector2i(640,360),Vector2i(960,540),Vector2i(1024,768)]:
		root.content_scale_size = size_v
		root.size = size_v
		await settle()
		assert(root.get_visible_rect().encloses(hub.get_node("HUD/GameLayout").quest_panel.get_global_rect()))
		assert(hub.get_node("HUD/GameLayout").map_button.is_visible_in_tree())
	hub._toggle_map()
	assert(not hub.interiors.active and hub.hero.position == outside)
	assert(hub.objects.visible and hub.world_stream.process_mode == Node.PROCESS_MODE_INHERIT)
	hub._interact()
	assert(hub.interiors.active)
	hub.get_node("HUD/GameLayout").open_pause()
	hub.get_node("HUD/GameLayout")._return_to_menu()
	await settle()
	assert(not paused and state.player_position == outside)
	assert(current_scene.scene_file_path == "res://scenes/cartoon/CartoonMainMenu.tscn")
	current_scene.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_royal_castle_v023: PASS — monumental exterior, 8 connected wings, furniture collision, king/rest, city and campaign access, save/load and mobile HUD")
	quit(0)
