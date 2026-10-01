extends SceneTree
const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Journal = preload("res://scripts/cartoon/cartoon_mission_journal.gd")
const Contracts = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func touch(point: Vector2, pressed: bool) -> void:
	var event = InputEventScreenTouch.new()
	event.index = 17
	event.position = point
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	var hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	var layout = hub.get_node("HUD/GameLayout")
	assert(Journal.entries(hub,state).size()==1 and Journal.entries(hub,state,"available").size()==7)
	assert(not state.set_tracked_mission("GUILD_RABBITS") and not state.set_tracked_mission("Q_MS01_GUARDIAN"))
	assert(Contracts.accept(state,"GUILD_RABBITS"))
	var before: String = hub.story_runtime.current_id
	assert(state.set_tracked_mission("GUILD_RABBITS"))
	layout._update_tracking(1)
	assert(hub.objective_label.text.contains("0/3") and layout.mission_marker.enabled)
	var point = Journal.target(hub,state,"GUILD_RABBITS")
	assert(point.valid)
	hub._toggle_map()
	layout._update_tracking(1)
	assert(hub.map_overlay.target_id=="" and layout.mission_marker.enabled)
	hub._toggle_map()
	state.save_profile()
	state.tracked_mission = "main"
	state.load_profile()
	assert(state.tracked_mission=="GUILD_RABBITS")
	assert(hub.story_runtime.current_id==before)
	Contracts.register_hunt(state,"rabbit")
	Contracts.register_hunt(state,"rabbit")
	Contracts.register_hunt(state,"rabbit")
	layout._update_tracking(1)
	assert(hub.objective_label.text.contains("3/3") and layout.tracked_target.hint.contains("Guilda"))
	assert(Contracts.claim(state,hub,"GUILD_RABBITS"))
	assert(state.tracked_mission=="main" and not state.set_tracked_mission("GUILD_RABBITS"))
	assert(Journal.entries(hub,state,"completed").size()==1)
	hub.story_runtime.try_location(hub.story_runtime.current_location())
	assert(Journal.entries(hub,state,"completed").size()==2,"Completed story absent from journal")
	assert(Contracts.accept(state,"GUILD_MEAT"))
	state.materials["Carne de caça"] = 5
	assert(state.set_tracked_mission("GUILD_MEAT"))
	assert(Journal.target(hub,state,"GUILD_MEAT").hint.contains("Guilda"))
	for size_v in [Vector2i(640,360),Vector2i(800,450),Vector2i(960,640),Vector2i(1200,540)]:
		root.size = size_v
		root.content_scale_size = size_v
		await settle()
		touch(layout.mission_button.get_global_rect().get_center(),true)
		touch(layout.mission_button.get_global_rect().get_center(),false)
		await settle()
		assert(layout.mission_ui.is_open() and layout.is_blocked())
		assert(root.get_visible_rect().encloses(layout.mission_ui.panel.get_global_rect()))
		layout.mission_ui.show_tab("available")
		assert(layout.mission_ui.rows.get_child_count()==5)
		layout.mission_ui.show_tab("active")
		layout.mission_ui._track("main")
		assert(state.tracked_mission=="main")
		layout.mission_ui.close_panel()
		await settle()
		assert(not layout.is_blocked())
	# Invalid and legacy selections fall back without granting progress or rewards.
	state.tracked_mission = "unknown"
	state.save_profile()
	state.load_profile()
	assert(state.tracked_mission=="main")
	hub.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_missions_v029: PASS — journal, selection, persistence, HUD/map, claims, history, touch and 4 sizes")
	quit()
