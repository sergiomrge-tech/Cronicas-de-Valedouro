extends SceneTree

func _initialize() -> void:
	call_deferred("check")

func check() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	for key in ["hero_body", "hero_armor_1", "hero_armor_4", "hero_sword_0", "hero_sword_3", "hero_bow_0", "hero_staff_3"]:
		assert(game.textures[key] != null)
		assert(game.textures[key].get_size() == Vector2(864, 448), "Sheet layout changed: " + key)
	game.dialog.hide()
	game.attack_cooldown = 0
	game.attack()
	assert(game.hero_attack_time > .4)
	game._process(.05)
	assert(game.hero_attack_time < .4)
	game.equipped_armor = {"name": "Couro", "kind": "armor", "tier": 1, "req": 1, "chapter": 0, "def": 1}
	game.equipped_weapon = {"name": "Arco", "kind": "bow", "tier": 0, "req": 1, "chapter": 0, "atk": 0}
	game.queue_redraw()
	await process_frame
	print("HERO PASS: 8 direções, 8 quadros de caminhada, 10 de ataque e camadas alinhadas")
	quit()
