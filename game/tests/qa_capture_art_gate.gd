extends SceneTree
# Real Godot 4.7.2 visual capture focused on professional art-gate targets.
# Usage:
# godot --path game --rendering-method gl_compatibility --script tests/qa_capture_art_gate.gd -- <out_dir> [prefix]

const REG = preload("res://scripts/reg001_world.gd")
var game: Node2D

func _initialize() -> void:
	call_deferred("capture_all")

func capture_all() -> void:
	if FileAccess.file_exists("user://valedouro_v1.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://valedouro_v1.json"))
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var out_dir: String = args[0] if args.size() > 0 else ProjectSettings.globalize_path("user://art_gate_captures")
	var only: String = args[1] if args.size() > 1 else ""
	DirAccess.make_dir_recursive_absolute(out_dir)
	game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	var file: FileAccess = FileAccess.open("res://data/reg001_art_capture_spots.json", FileAccess.READ)
	assert(file != null)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary)
	var spots: Array = (parsed as Dictionary).get("spots", [])

	for value in spots:
		var spot: Dictionary = value as Dictionary
		var shot_name: String = str(spot["name"])
		if not only.is_empty() and not shot_name.begins_with(only):
			continue

		REG.clear_progress()
		for id in spot.get("found", []):
			REG.mark("found", str(id))
		for id in spot.get("opened", []):
			REG.mark("opened", str(id))
		for id in spot.get("elites", []):
			REG.mark("elites", str(id))

		game.zone = str(spot["zone"])
		var p: Array = spot["pos"]
		game.player = Vector2(float(p[0]), float(p[1]))
		game.map_visible = false
		game.dialog.hide()
		game.enemies.clear()
		game.hint = ""
		game.hint_timer = 0.0
		game.time_acc = float(spot.get("time", 3.7))
		game.hero_walking = false
		game.refresh_ui()
		game.queue_redraw()
		for i in 5:
			await process_frame

		var image: Image = root.get_texture().get_image()
		var out: String = "%s/%s.png" % [out_dir, shot_name]
		var err: Error = image.save_png(out)
		if err != OK:
			push_error("Failed to save art-gate capture: %s (%s)" % [out, err])
			quit(2)
			return
		print("ART_GATE_CAPTURED ", out)

	quit(0)
