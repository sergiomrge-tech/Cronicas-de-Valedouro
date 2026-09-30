extends SceneTree

const FROST = preload("res://scenes/cartoon/FrostMountainsCartoon.tscn")
const SIEGE = preload("res://scenes/cartoon/ValedouroSiegeCartoon.tscn")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var output_dir: String = "user://ci_output_frost"
	if OS.get_cmdline_user_args().size() > 0:
		output_dir = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

	var region: Node = FROST.instantiate()
	root.add_child(region)
	await process_frame
	await process_frame
	await process_frame
	region.camera.position_smoothing_enabled = false

	var shots: Array[Dictionary] = [
		{"name":"01_pouso_geada","pos":Vector2(4200,31400),"quest":"Q_MS05_FROST_REST"},
		{"name":"02_estacao_expedicao","pos":Vector2(9500,26800),"quest":"Q_MS05_EXPEDITION"},
		{"name":"03_posto_capitao","pos":Vector2(14500,21900),"quest":"Q_MS05_CAPTAIN"},
		{"name":"04_arquivo_congelado","pos":Vector2(19800,16900),"quest":"Q_MS05_ARCHIVE"},
		{"name":"05_cidadela_geada_negra","pos":Vector2(26600,10400),"quest":"Q_MS05_BLACK_FROST"},
		{"name":"06_rota_retorno","pos":Vector2(31600,4200),"quest":"Q_MS05_SIEGE"},
		{"name":"07_trilha_nevada","pos":Vector2(16900,19300),"quest":"Q_MS05_ARCHIVE"},
		{"name":"08_mapa_missoes","pos":Vector2(19800,16900),"quest":"Q_MS05_ARCHIVE","map":true}
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
		print("FROST_CAPTURED ",out)

	region.queue_free()
	await process_frame
	var siege: Node = SIEGE.instantiate()
	root.add_child(siege)
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	siege.hub.camera.position_smoothing_enabled = false
	siege.hub.hero.position = siege.hub.hero.position
	await process_frame
	var siege_image: Image = root.get_texture().get_image()
	var siege_out: String = "%s/09_cerco_valedouro.png" % output_dir
	assert(siege_image.save_png(ProjectSettings.globalize_path(siege_out)) == OK)
	print("FROST_CAPTURED ",siege_out)
	quit(0)
