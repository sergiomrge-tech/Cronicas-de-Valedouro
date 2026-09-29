extends SceneTree
# Captura visual REAL (Godot 4.7.2, renderer gl_compatibility) das principais regiões da REG_001.
# Uso: godot --path game --script tests/qa_capture_reg001.gd -- <dir_saida> [prefixo_de_nome]
const WORLD = preload("res://scripts/world_map.gd")
const REG = preload("res://scripts/reg001_world.gd")
var game: Node2D

func _initialize() -> void:
	call_deferred("capture_all")

func capture_all() -> void:
	if FileAccess.file_exists("user://valedouro_v1.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://valedouro_v1.json"))
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var out_dir: String = args[0] if args.size() > 0 else ProjectSettings.globalize_path("user://reg001_captures")
	var only: String = args[1] if args.size() > 1 else ""
	DirAccess.make_dir_recursive_absolute(out_dir)
	game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	var spots: Array = []
	var file: FileAccess = FileAccess.open("res://data/reg001_capture_spots.json", FileAccess.READ)
	if file != null:
		spots = JSON.parse_string(file.get_as_text())
	for spot_value in spots:
		var spot: Dictionary = spot_value
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
		for id in spot.get("lore", []):
			REG.mark("lore", str(id))
		game.zone = str(spot["zone"])
		var pos: Array = spot["pos"]
		game.player = Vector2(float(pos[0]), float(pos[1]))
		game.map_visible = false
		game.dialog.hide()
		game.end_guardian_rematch()
		game.enemies.clear()
		game.hint_timer = 0.0
		game.hint = ""
		game.time_acc = float(spot.get("time", 3.7))
		if spot.has("elite"):
			game.reg_game.elite_timer = 0.0
			game.reg_game.update_elites()
			for enemy in game.enemies:
				enemy["hp"] = int(float(enemy["hp"]) * .55)
		if spot.has("rematch"):
			# revanche real: ativa (Guardião presente, Núcleo pulsando) ou concluída (Guardião morto pelo fluxo normal de combate)
			game.start_guardian_rematch()
			if str(spot["rematch"]) == "after":
				for enemy in game.enemies:
					if str(enemy["kind"]) == "Guardião":
						enemy["hp"] = 1
				game.player = Vector2(485, 300)
				game.facing = Vector2.RIGHT
				game.attack_cooldown = 0.0
				game.enemies[0]["pos"] = game.player + Vector2(24, 0)
				game.attack()
				game.update_enemies(.8)
				assert(not game.rematch_active)
				game.enemies.clear()
		game.hero_walking = false
		game.refresh_ui()
		game.queue_redraw()
		for i in 4:
			await process_frame
		var image: Image = root.get_texture().get_image()
		var out: String = "%s/%s.png" % [out_dir, shot_name]
		assert(image.save_png(out) == OK)
		print("CAPTURED ", out)
	quit(0)
