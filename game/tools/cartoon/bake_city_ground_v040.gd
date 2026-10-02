extends SceneTree
const GroundScript = preload("res://scripts/cartoon/hub_environment.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(2048,2048)
	root.content_scale_size = root.size
	root.transparent_bg = true
	var scaled = Node2D.new()
	scaled.scale = Vector2(0.5,0.5)
	root.add_child(scaled)
	var ground = GroundScript.new()
	ground.position = -Region.HUB_ORIGIN+Vector2(0,1740)
	# Use procedural source when rebuilding an existing baked atlas.
	if "use_baked_ground" in ground: ground.use_baked_ground = false
	scaled.add_child(ground)
	for i in range(12): await process_frame
	await RenderingServer.frame_post_draw
	var output = OS.get_cmdline_user_args()[0]
	assert(root.get_texture().get_image().save_png(output)==OK)
	var inputs: Dictionary = {}
	for source: String in ["scripts/cartoon/hub_environment.gd","scripts/cartoon/cartoon_terrain_art.gd","scripts/cartoon/cartoon_draw.gd","scripts/cartoon/cartoon_region_config.gd","assets/cartoon/v020/grass.svg","tools/cartoon/bake_city_ground_v040.gd"]:
		inputs[source] = FileAccess.get_sha256("res://"+source)
	var provenance = {"artifact":output.get_file(),"sha256":FileAccess.get_sha256(output),"texture_size":[2048,2048],"world_rect":[0,-1740,4096,4096],"seed":20260930,"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"source_sha256":inputs}
	var file = FileAccess.open(output.get_base_dir().path_join("ground_provenance.json"),FileAccess.WRITE)
	assert(file != null)
	file.store_string(JSON.stringify(provenance,"  ")+"\n")
	print("Baked city floor and royal gardens into a 2048x2048 transparent atlas; provenance saved")
	quit()
