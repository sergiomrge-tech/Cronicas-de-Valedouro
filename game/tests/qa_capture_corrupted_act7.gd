extends SceneTree

const REGION = preload("res://scenes/cartoon/CorruptedLandsCartoon.tscn")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var region: Node = REGION.instantiate()
	root.add_child(region)
	await process_frame
	await process_frame
	await process_frame
	region.camera.position_smoothing_enabled = false
	var output_dir: String = "user://ci_output_corrupted"
	if OS.get_cmdline_user_args().size() > 0:
		output_dir = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var shots: Array[Dictionary] = [
		{"name":"01_ultimo_bastiao","pos":Vector2(5200,42000),"quest":"Q_MS07_LAST_BASTION"},
		{"name":"02_obeliscos_guerra","pos":Vector2(14500,34300),"quest":"Q_MS07_OBELISKS"},
		{"name":"03_catedral_partida","pos":Vector2(23200,27000),"quest":"Q_MS07_CATHEDRAL"},
		{"name":"04_conselho_seis_coroas","pos":Vector2(31500,19000),"quest":"Q_MS07_COUNCIL"},
		{"name":"05_cidadela_coroa_oca","pos":Vector2(39800,9500),"quest":"Q_MS07_GENERAL_VOID"},
		{"name":"06_frente_guerra","pos":Vector2(27500,22900),"quest":"Q_MS07_COUNCIL"},
		{"name":"07_mapa_missoes","pos":Vector2(23200,27000),"quest":"Q_MS07_CATHEDRAL","map":true}
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
		print("CORRUPTED_CAPTURED ",out)
	quit(0)
