extends SceneTree

const DESERT = preload("res://scenes/cartoon/DesertEdravarCartoon.tscn")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var region: Node = DESERT.instantiate()
	root.add_child(region)
	await process_frame
	await process_frame
	await process_frame
	region.camera.position_smoothing_enabled = false

	var output_dir: String = "user://ci_output_desert"
	if OS.get_cmdline_user_args().size() > 0:
		output_dir = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

	var shots: Array[Dictionary] = [
		{"name":"01_caravana_ambar","pos":Vector2(3600,31500),"quest":"Q_MS03_CARAVAN"},
		{"name":"02_posto_ambar","pos":Vector2(8200,27800),"quest":"Q_MS03_AMBER_POST"},
		{"name":"03_edravar_ocupada","pos":Vector2(16800,22200),"quest":"Q_MS03_EDRAVAR"},
		{"name":"04_cisterna_resistencia","pos":Vector2(15100,18700),"quest":"Q_MS03_CISTERN"},
		{"name":"05_observatorio_cinzas","pos":Vector2(24400,13800),"quest":"Q_MS03_OBSERVATORY"},
		{"name":"06_cidadela_cinza","pos":Vector2(30100,6500),"quest":"Q_MS03_GENERAL_ASH"},
		{"name":"07_rota_deserto","pos":Vector2(18800,16600),"quest":"Q_MS03_OBSERVATORY"}
	]

	for shot in shots:
		region.story_runtime.current_id = String(shot["quest"])
		region._refresh_objective()
		region.hero.position = shot["pos"] as Vector2
		region.world_stream._refresh(true)
		await process_frame
		await process_frame
		await process_frame
		await process_frame
		var image: Image = root.get_texture().get_image()
		var out: String = "%s/%s.png" % [output_dir,str(shot["name"])]
		var err: Error = image.save_png(ProjectSettings.globalize_path(out))
		assert(err == OK)
		print("DESERT_CAPTURED ",out)
	quit(0)
