extends SceneTree

const FOREST = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var region: Node = FOREST.instantiate()
	root.add_child(region)
	await process_frame
	await process_frame
	await process_frame
	region.camera.position_smoothing_enabled = false

	var output_dir: String = "user://ci_output_forest"
	if OS.get_cmdline_user_args().size() > 0:
		output_dir = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

	var shots: Array[Dictionary] = [
		{"name":"01_ponte_de_pedra","pos":Vector2(23000,43800),"quest":"Q_MS02_BORDER"},
		{"name":"02_casa_guardas_verdes","pos":Vector2(25800,37400),"quest":"Q_MS02_RANGERS"},
		{"name":"03_santuario_raiz_oeste","pos":Vector2(19000,32300),"quest":"Q_MS02_ROOTS"},
		{"name":"04_santuarios_de_raiz","pos":Vector2(24000,30200),"quest":"Q_MS02_ROOTS"},
		{"name":"05_arvore_memoria","pos":Vector2(23000,23500),"quest":"Q_MS02_MEMORY_TREE"},
		{"name":"06_coracao_raiz_oca","pos":Vector2(17500,17500),"quest":"Q_MS02_HOLLOW_ROOT"},
		{"name":"07_santuario_cartografos","pos":Vector2(29200,11400),"quest":"Q_MS02_VEIL_SHRINE"},
		{"name":"08_trilha_exploracao","pos":Vector2(20500,14800),"quest":"Q_MS02_HOLLOW_ROOT"}
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
		print("FOREST_CAPTURED ",out)
	quit(0)
