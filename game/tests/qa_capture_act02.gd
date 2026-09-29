extends SceneTree
# Capturas REAIS do Godot para o Lote 2 (Ato II). Uso: godot --path . --script tests/qa_capture_act02.gd -- OUTDIR [PREFIXO]
const STAGE = preload("res://tests/act02_stage.gd")

func _initialize() -> void:
	call_deferred("run_capture")

func run_capture() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var out_dir: String = args[0] if args.size() > 0 else ProjectSettings.globalize_path("user://act02_captures")
	var only: String = args[1] if args.size() > 1 else ""
	DirAccess.make_dir_recursive_absolute(out_dir)
	var stage: Node2D = STAGE.new()
	root.add_child(stage)
	var comps: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/act02_compositions.json")) as Array
	await process_frame
	for comp_value in comps:
		var comp: Dictionary = comp_value
		for shot_value in comp["captures"]:
			var shot: Dictionary = shot_value
			var shot_name: String = str(shot["name"])
			if not only.is_empty() and not shot_name.begins_with(only):
				continue
			stage.set_scene(comp, shot.get("flags", []))
			for i in 3:
				await process_frame
			var image: Image = root.get_texture().get_image()
			assert(image.save_png("%s/%s.png" % [out_dir, shot_name]) == OK)
			print("CAPTURED ", shot_name)
	quit(0)
