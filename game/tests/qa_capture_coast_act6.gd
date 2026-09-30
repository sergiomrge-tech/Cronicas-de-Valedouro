extends SceneTree

const COAST = preload("res://scenes/cartoon/CoastLostIslandsCartoon.tscn")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var region: Node = COAST.instantiate()
	root.add_child(region)
	await process_frame
	await process_frame
	await process_frame
	region.camera.position_smoothing_enabled = false
	var output_dir: String = "user://ci_output_coast"
	if OS.get_cmdline_user_args().size() > 0:
		output_dir = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var shots: Array[Dictionary] = [
		{"name":"01_porto_bruma","pos":Vector2(5200,42500),"quest":"Q_MS06_MIST_PORT"},
		{"name":"02_farol_gemeo","pos":Vector2(12500,35600),"quest":"Q_MS06_LIGHTHOUSE"},
		{"name":"03_templo_submerso","pos":Vector2(22200,28600),"quest":"Q_MS06_SUNKEN_TEMPLE"},
		{"name":"04_estaleiro_ilhas","pos":Vector2(32000,20500),"quest":"Q_MS06_HOLLOW_FLEET"},
		{"name":"05_observatorio_mares","pos":Vector2(39800,9800),"quest":"Q_MS06_GENERAL_TIDE"},
		{"name":"06_rota_maritima","pos":Vector2(26900,24700),"quest":"Q_MS06_HOLLOW_FLEET"},
		{"name":"07_mapa_missoes","pos":Vector2(22200,28600),"quest":"Q_MS06_SUNKEN_TEMPLE","map":true}
	]
	for shot in shots:
		region.story_runtime.current_id = String(shot["quest"])
		region._refresh_objective()
		region.map_open = bool(shot.get("map",false))
		region.map_overlay.visible = region.map_open
		region.map_overlay.set_target(region.story_runtime.current_location())
		region.hero.position = shot["pos"] as Vector2
		region.world_stream._refresh(true)
		await process_frame
		await process_frame
		await process_frame
		await process_frame
		var image: Image = root.get_texture().get_image()
		var out: String = "%s/%s.png" % [output_dir,str(shot["name"])]
		assert(image.save_png(ProjectSettings.globalize_path(out)) == OK)
		print("COAST_CAPTURED ",out)
	quit(0)
