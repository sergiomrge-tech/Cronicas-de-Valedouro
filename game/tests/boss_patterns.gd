extends SceneTree

func _initialize() -> void:
	call_deferred("check")

func check() -> void:
	if FileAccess.file_exists("user://valedouro_v1.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://valedouro_v1.json"))
	var game: Node2D = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.zone = "masmorra"
	game.player = Vector2(485, 360)
	game.enemies.clear()
	var guardian: Dictionary = game.make_enemy("Guardião", game.GUARDIAN_SPOT)
	guardian["special_cool"] = 0.0
	game.enemies.append(guardian)

	# Primeiro especial: carga.
	game.update_enemies(.01)
	assert(str(guardian.get("boss_action", "")) == "charge")
	assert(int(guardian.get("boss_pattern", -1)) == 0)
	var before: Vector2 = guardian["pos"] as Vector2
	game.update_enemies(.1)
	assert((guardian["pos"] as Vector2).distance_to(before) > 1.0)

	# Segundo especial: onda circular.
	guardian["action_time"] = 0.0
	guardian["boss_action"] = ""
	guardian["special_cool"] = 0.0
	game.update_enemies(.01)
	assert(str(guardian.get("boss_action", "")) == "shockwave")
	assert(int(guardian.get("boss_pattern", -1)) == 1)

	# Onda precisa causar dano quando o jogador está no alcance.
	game.player = (guardian["pos"] as Vector2) + Vector2(0, 60)
	game.hp = game.max_hp
	game.invulnerable = 0.0
	guardian["action_time"] = .22
	guardian["boss_hit_done"] = false
	game.update_enemies(.01)
	assert(game.hp < game.max_hp)
	assert(bool(guardian.get("boss_hit_done", false)))
	print("BOSS PATTERNS PASS: carga, onda circular, telegraph state e dano em alcance")
	quit(0)
