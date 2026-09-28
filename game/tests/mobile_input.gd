extends SceneTree

func _initialize() -> void:
	call_deferred("check")

func check() -> void:
	if FileAccess.file_exists("user://valedouro_v1.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://valedouro_v1.json"))
	var game: Node2D = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var button_count: int = 0
	for child in game.controller.get_children():
		if child is Button:
			button_count += 1
	assert(button_count >= 5)

	var touch: InputEventScreenTouch = InputEventScreenTouch.new()
	touch.index = 4
	touch.position = Vector2(105, 430)
	touch.pressed = true
	game._input(touch)
	assert(game.joystick_id == 4)

	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = 4
	drag.position = Vector2(154, 430)
	game._input(drag)
	assert(game.joystick_vector.x > .7)
	var before_vector: Vector2 = game.joystick_vector
	game.attack_cooldown = 0.0
	game.attack()
	assert(game.joystick_vector == before_vector)

	var release: InputEventScreenTouch = InputEventScreenTouch.new()
	release.index = 4
	release.position = Vector2(154, 430)
	release.pressed = false
	game._input(release)
	assert(game.joystick_id == -1)
	assert(game.joystick_vector == Vector2.ZERO)
	print("MOBILE INPUT PASS: 5 botões touch, joystick drag/release e ataque sem cancelar movimento")
	quit(0)
