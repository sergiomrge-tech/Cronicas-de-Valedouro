extends SceneTree

func _initialize() -> void:
	call_deferred("check")

func check() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var sizes: Dictionary = {"wolf_full": Vector2(288, 180), "slime_full": Vector2(288, 180), "spider_full": Vector2(288, 180), "boar_full": Vector2(288, 180), "flower_beast_full": Vector2(288, 180), "scorpion_full": Vector2(288, 180), "amber_beetle_full": Vector2(288, 180), "ice_wolf_full": Vector2(288, 180), "ice_golem_full": Vector2(320, 200), "boss_full": Vector2(512, 320)}
	for key in sizes.keys():
		assert(game.textures[key] != null, "Folha ausente: " + key)
		assert(game.textures[key].get_size() == sizes[key], "Folha 5x8 inválida: " + key)
	for kind in ["Aranha Sombria", "Javali Musgoso", "Flor Voraz", "Escaravelho Âmbar", "Golem de Geada"]:
		var e: Dictionary = game.make_enemy(kind, Vector2(600, 500))
		assert(e["hp"] == game.monster_health(kind))
		game.set_enemy_state(e, "attack")
		assert(e["state"] == "attack")
		e["dead"] = true
		game.set_enemy_state(e, "death")
		assert(e["state"] == "death")
	print("MONSTER PASS: 10 criaturas com 40 quadros (idle/walk/attack/hurt/death) e 5 espécies novas")
	quit()
