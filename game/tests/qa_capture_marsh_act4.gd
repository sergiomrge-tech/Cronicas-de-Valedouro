extends SceneTree

const MARSH = preload("res://scenes/cartoon/MarshDarkCartoon.tscn")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var region: Node = MARSH.instantiate()
	root.add_child(region)
	await process_frame
	await process_frame
	await process_frame
	region.camera.position_smoothing_enabled = false

	var output_dir: String = "user://ci_output_marsh"
	if OS.get_cmdline_user_args().size() > 0:
		output_dir = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

	var shots: Array[Dictionary] = [
		{"name":"01_vila_lanternas","pos":Vector2(31000,31500),"quest":"Q_MS04_STILTS"},
		{"name":"02_sino_afogado","pos":Vector2(25500,27800),"quest":"Q_MS04_BELL"},
		{"name":"03_mosteiro_inundado","pos":Vector2(19500,22800),"quest":"Q_MS04_MONASTERY"},
		{"name":"04_santuario_juncos","pos":Vector2(14200,16800),"quest":"Q_MS04_REED_SANCTUM"},
		{"name":"05_trono_juncos","pos":Vector2(9200,10800),"quest":"Q_MS04_LADY_REEDS"},
		{"name":"06_comporta_ecos","pos":Vector2(4300,5200),"quest":"Q_MS04_SLICE_GATE"},
		{"name":"07_trilha_brejo","pos":Vector2(16600,19800),"quest":"Q_MS04_REED_SANCTUM"},
		{"name":"08_mapa_missoes","pos":Vector2(19500,22800),"quest":"Q_MS04_MONASTERY","map":true}
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
		var err: Error = image.save_png(ProjectSettings.globalize_path(out))
		assert(err == OK)
		print("MARSH_CAPTURED ",out)
	quit(0)
