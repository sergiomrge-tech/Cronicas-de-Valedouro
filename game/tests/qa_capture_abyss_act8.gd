extends SceneTree

const REGION = preload("res://scenes/cartoon/AbyssHeartCartoon.tscn")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var region: Node = REGION.instantiate()
	root.add_child(region)
	await process_frame
	await process_frame
	await process_frame
	region.camera.position_smoothing_enabled = false
	var output_dir: String = "user://ci_output_abyss"
	if OS.get_cmdline_user_args().size() > 0:
		output_dir = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var shots: Array[Dictionary] = [
		{"name":"01_portao_ultimo_mapa","pos":Vector2(9200,17000),"quest":"Q_MS08_LAST_MAP_GATE"},
		{"name":"02_caminhos_perdidos","pos":Vector2(9200,13900),"quest":"Q_MS08_LOST_PATHS"},
		{"name":"03_arquivo_vazio","pos":Vector2(6100,10400),"quest":"Q_MS08_CARTOGRAPHER"},
		{"name":"04_antecamara_adrian","pos":Vector2(9200,7500),"quest":"Q_MS08_FIRST_TRAVELER"},
		{"name":"05_trono_azharel","pos":Vector2(9200,4300),"quest":"Q_MS08_AZHAREL"},
		{"name":"06_limiar_terra","pos":Vector2(12800,1650),"quest":"Q_MS08_EARTH_GATE"},
		{"name":"07_mapa_final","pos":Vector2(9200,7500),"quest":"Q_MS08_FIRST_TRAVELER","map":true},
		{"name":"08_escolha_final","pos":Vector2(12800,1650),"quest":"Q_MS08_CHOICE","choice":true}
	]
	for shot in shots:
		region.story_runtime.current_id = String(shot["quest"])
		region._refresh_objective()
		region.map_open = bool(shot.get("map",false))
		region.map_overlay.visible = region.map_open
		region.map_overlay.set_target(region.story_runtime.current_location())
		region.choice_panel.visible = bool(shot.get("choice",false))
		region.hero.position = shot["pos"] as Vector2
		region.world_stream._refresh(true)
		await process_frame
		await process_frame
		await process_frame
		await process_frame
		var image: Image = root.get_texture().get_image()
		var out: String = "%s/%s.png" % [output_dir,str(shot["name"])]
		assert(image.save_png(ProjectSettings.globalize_path(out)) == OK)
		print("ABYSS_CAPTURED ",out)
	quit(0)
