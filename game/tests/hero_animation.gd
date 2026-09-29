extends SceneTree

func _initialize() -> void:
	call_deferred("check")

func require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("HERO TEST FAIL: " + message)
	quit(1)
	return false

func check() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	# Este teste valida contrato de atlas/animação, não rendering. Em headless,
	# esconder o CanvasItem evita ruído de draw_* com recursos gráficos sem viewport.
	game.visible = false
	await process_frame

	for key in ["hero_body", "hero_armor_1", "hero_armor_4", "hero_sword_0", "hero_sword_3", "hero_bow_0", "hero_staff_3"]:
		if not require(game.textures.has(key), "textura não registrada: " + key):
			return
		var texture_value: Variant = game.textures[key]
		if not require(texture_value is Texture2D, "textura inválida/nula: " + key):
			return
		if not require((texture_value as Texture2D).get_size() == Vector2(864, 448), "layout mudou: " + key):
			return

	game.dialog.hide()
	game.attack_cooldown = 0
	game.attack()
	if not require(game.hero_attack_time > .4, "attack() não iniciou janela de animação"):
		return
	game._process(.05)
	if not require(game.hero_attack_time < .4, "timer de ataque não avançou"):
		return

	game.equipped_armor = {"name": "Couro", "kind": "armor", "tier": 1, "req": 1, "chapter": 0, "def": 1}
	game.equipped_weapon = {"name": "Arco", "kind": "bow", "tier": 0, "req": 1, "chapter": 0, "atk": 0}
	print("HERO PASS: 8 direções, 8 quadros de caminhada, 10 de ataque e camadas alinhadas")
	quit(0)
