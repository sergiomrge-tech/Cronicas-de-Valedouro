extends SceneTree
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	Engine.max_fps = 0
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	root.size = Vector2i(960,540)
	root.content_scale_size = root.size
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	var hub = load("res://scenes/cartoon/ValedouroCartoonHub.tscn").instantiate()
	root.add_child(hub)
	current_scene = hub
	for i in range(30): await process_frame
	hub.camera.position_smoothing_enabled = false
	var results: Array = []
	for sample in [{"name":"plaza","pos":Vector2(1150,970)},{"name":"residential","pos":Vector2(600,650)},{"name":"castle","pos":Vector2(2500,-150)}]:
		hub.hero.position = Region.world_from_hub(sample.pos)
		hub.camera.reset_smoothing()
		hub.world_stream._refresh(true)
		for i in range(40): await process_frame
		var frames: Array[float] = []
		var cpu: Array[float] = []
		var calls: Array[float] = []
		var primitives: Array[float] = []
		var last: int = Time.get_ticks_usec()
		for i in range(160):
			await process_frame
			var now: int = Time.get_ticks_usec()
			frames.append(float(now-last)/1000.0)
			last = now
			cpu.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000)
			calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			primitives.append(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
		frames.sort()
		cpu.sort()
		calls.sort()
		primitives.sort()
		results.append({"name":sample.name,"frame_median_ms":frames[80],"frame_p95_ms":frames[152],"cpu_median_ms":cpu[80],"draw_calls_median":calls[80],"primitives_median":primitives[80],"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),"video_memory":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)})
	var out: String = OS.get_cmdline_user_args()[0]
	var file = FileAccess.open(out,FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"viewport":"960x540","samples":results},"  "))
	print(JSON.stringify(results))
	state.reset_progress(true)
	quit()
