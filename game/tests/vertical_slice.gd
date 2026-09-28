extends SceneTree
const WORLD = preload("res://scripts/world_map.gd")
const LOOT = preload("res://scripts/loot_system.gd")

func _initialize() -> void:
	call_deferred("run_gate")

func first_button(game: Node2D) -> Button:
	assert(game.dialog.visible)
	assert(game.dialog_choices.get_child_count() > 0)
	return game.dialog_choices.get_child(0) as Button

func kill_nearby(game: Node2D, kind: String) -> void:
	game.enemies.clear()
	var enemy: Dictionary = game.make_enemy(kind, game.player + Vector2(24, 0))
	enemy["hp"] = 1
	enemy["max_hp"] = 1
	game.enemies.append(enemy)
	game.facing = Vector2.RIGHT
	game.attack_cooldown = 0.0
	game.attack()
	game.update_enemies(.8)

func run_gate() -> void:
	if FileAccess.file_exists("user://valedouro_v1.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://valedouro_v1.json"))
	var game: Node2D = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(game.zone == "cidade")
	assert(game.walkable(game.player + Vector2(16, 0)))

	# Cidade -> guilda -> contrato.
	game.player = WORLD.TOWN + Vector2(455, 357)
	game.interact()
	assert(game.zone == "guilda")
	game.player = Vector2(480, 400)
	game.interact()
	await process_frame
	first_button(game).pressed.emit()
	await process_frame
	assert(game.quest == 1)

	# Guilda -> cidade -> bosque.
	game.player = Vector2(480, 700)
	game.interact()
	assert(game.zone == "cidade")
	game.player = WORLD.TOWN + Vector2(883, 65)
	game.interact()
	assert(game.zone == "floresta")

	# Combate real suficiente para completar a primeira caçada.
	for n in 3:
		kill_nearby(game, "Lobo")
	assert(game.quest == 2)
	assert(int(game.kills["Lobo"]) >= 3)

	# Loot real + equipamento.
	var loot_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	loot_rng.seed = 92813
	var found_item: Dictionary = {}
	for roll_index in 20000:
		var reward: Dictionary = LOOT.roll("Lobo", loot_rng)
		var item: Dictionary = reward["item"] as Dictionary
		if not item.is_empty():
			found_item = item
			break
	assert(not found_item.is_empty())
	game.stored_items.append(found_item)
	game.level = maxi(game.level, int(found_item.get("req", 1)))
	game.equip_item(game.stored_items.size() - 1)
	assert(str(game.equipped_weapon.get("name", "")) == str(found_item.get("name", "")) or str(game.equipped_armor.get("name", "")) == str(found_item.get("name", "")))
	game.dialog.hide()

	# Retorno à guilda e desbloqueio da dungeon.
	game.player = Vector2(1000, 790)
	game.interact()
	assert(game.zone == "cidade")
	game.player = WORLD.TOWN + Vector2(455, 357)
	game.interact()
	game.player = Vector2(480, 400)
	game.interact()
	await process_frame
	first_button(game).pressed.emit()
	await process_frame
	assert(game.quest == 3)
	game.player = Vector2(480, 700)
	game.interact()
	assert(game.zone == "cidade")

	# Dungeon -> Guardião -> segunda mecânica de boss -> recompensa.
	game.player = WORLD.TOWN + Vector2(955, 795)
	game.interact()
	await process_frame
	first_button(game).pressed.emit()
	await process_frame
	assert(game.zone == "masmorra")
	var guardian_found: bool = false
	for enemy_value in game.enemies:
		var enemy: Dictionary = enemy_value as Dictionary
		if str(enemy.get("kind", "")) == "Guardião":
			guardian_found = true
			assert(enemy.has("boss_pattern"))
			assert(enemy.has("special_cool"))
	assert(guardian_found)
	kill_nearby(game, "Guardião")
	assert(game.quest == 4)
	assert(int(game.materials.get("Fragmento de Eco", 0)) >= 1)

	# Save/load do estado do slice.
	game.save_game()
	var saved_gold: int = game.gold
	var saved_weapon: Dictionary = game.equipped_weapon.duplicate(true)
	game.gold = 0
	game.equipped_weapon = {}
	game.load_game()
	assert(game.gold == saved_gold)
	assert(game.quest == 4)
	assert(str(game.equipped_weapon.get("name", "")) == str(saved_weapon.get("name", "")))

	print("PLAYABLE GATE PASS: cidade -> missão -> bosque -> combate -> loot -> equipar -> dungeon -> Guardião -> save/load")
	quit(0)
