extends SceneTree
const WORLD = preload("res://scripts/world_map.gd")

func _initialize() -> void:
	call_deferred("check_game")

func check_game() -> void:
	# Keep this self-contained across repeated runs.
	if FileAccess.file_exists("user://valedouro_v1.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://valedouro_v1.json"))
	var game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(game.hud != null)
	assert(game.animals.size() >= 60)
	assert(WORLD.biome(Vector2(2700, 1900)) == "deserto")
	assert(WORLD.biome(Vector2(2700, 250)) == "gelo")
	assert(WORLD.biome(Vector2(300, 900)) == "floresta")
	assert(WORLD.biome(Vector2(500, 2000)) == "campos")
	assert(WORLD.biome(Vector2(1400, 2000)) == "vale")
	assert(not game.walkable(Vector2(WORLD.river_x(1700), 1700)))
	for by in WORLD.BRIDGE_YS:
		assert(game.walkable(Vector2(WORLD.river_x(float(by)), float(by))))
	game.zone = "cidade"
	game.player = WORLD.TOWN + Vector2(455, 357)
	game.interact()
	assert(game.zone == "guilda")
	game.player = Vector2(480, 400)
	game.interact()
	assert(game.dialog.visible)
	game.dialog.hide()
	game.quest = 1
	game.change_zone("floresta", Vector2(1000, 750))
	game.kills["Lobo"] = 2
	game.enemies.clear()
	game.enemies.append({"pos": game.player + Vector2(24, 0), "hp": 1, "kind": "Lobo", "cool": 0.0})
	game.facing = Vector2.RIGHT
	game.attack()
	game.update_enemies(.8)
	assert(game.quest == 2)
	assert(game.kills["Lobo"] == 3)
	game.quest = 3
	game.change_zone("masmorra", Vector2(480, 745))
	assert(game.enemies.any(func(e): return e["kind"] == "Guardião"))
	game.enemies.clear()
	game.enemies.append({"pos": game.player + Vector2(24, 0), "hp": 1, "kind": "Guardião", "cool": 0.0})
	game.attack_cooldown = 0
	game.attack()
	game.update_enemies(.8)
	assert(game.quest == 4)
	game.save_game()
	var saved_gold: int = game.gold
	game.gold = 0
	game.load_game()
	assert(game.gold == saved_gold)
	assert(game.quest == 4)
	var legacy: FileAccess = FileAccess.open("user://valedouro_v1.json", FileAccess.WRITE)
	legacy.store_string(JSON.stringify({"version": 1, "zone": "cidade", "px": 480, "py": 560, "level": 4, "gold": 73, "quest": 2}))
	legacy.close()
	game.load_game()
	assert(game.player == WORLD.TOWN + Vector2(884, 696))
	assert(game.level == 4 and game.gold == 73 and game.quest == 2)
	print("SMOKE PASS: 6 biomas, fauna, 3 pontes, animação de morte, guilda, caça, chefe, save/load e migração v1")
	quit(0)
