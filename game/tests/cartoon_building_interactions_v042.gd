extends SceneTree

const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")

func _initialize() -> void:
	call_deferred("run")

func _poi_pos(hub, id: String) -> Vector2:
	for poi in hub.environment.pois:
		if String(poi.get("id","")) == id:
			return poi.get("pos",Vector2.ZERO)
	return Vector2.INF

func _assert_entered(hub, expected: String) -> void:
	assert(hub.interiors.active)
	assert(hub.interiors.kind == expected)

func run() -> void:
	var hub = HubScene.instantiate()
	root.add_child(hub)
	await process_frame
	await process_frame

	var approaches: Dictionary = {
		"castle": Region.world_from_hub(Region.CASTLE_DOOR) + Vector2(0,120),
		"forge": Region.world_from_hub(Vector2(720,830)),
		"tavern": Region.world_from_hub(Vector2(1580,840)),
		"guild": Region.world_from_hub(Vector2(760,1165))
	}
	for p in approaches.values():
		assert(hub.environment.is_walkable(p))

	# Keyboard E must enter the guild through the explicit desktop input route.
	hub.hero.position = approaches["guild"]
	var layout = hub.get_node("HUD/GameLayout")
	layout.desktop_mode = true
	var e_event: InputEventKey = InputEventKey.new()
	e_event.physical_keycode = KEY_E
	e_event.pressed = true
	layout._unhandled_input(e_event)
	await process_frame
	_assert_entered(hub,"guild")
	hub.interiors.leave()
	await process_frame

	# The visible desktop USAR control must invoke the same interaction.
	hub.hero.position = approaches["forge"]
	var use_button: Button = hub.get_node("HUD/GameLayout/InteractButton")
	assert(use_button != null)
	use_button.emit_signal("pressed")
	await process_frame
	_assert_entered(hub,"forge")
	hub.interiors.leave()
	await process_frame

	# Direct interaction path must work for the remaining authored interiors.
	hub.hero.position = approaches["tavern"]
	hub._interact()
	await process_frame
	_assert_entered(hub,"tavern")
	hub.interiors.leave()
	await process_frame

	hub.hero.position = approaches["castle"]
	hub._interact()
	await process_frame
	_assert_entered(hub,"castle")
	hub.interiors.leave()
	await process_frame

	var source: String = FileAccess.get_file_as_string("res://scripts/cartoon/valedouro_cartoon_hub.gd")
	assert(source.contains("_try_enter_nearby_building(280.0)"))
	assert(source.contains("_nearest_building_poi(280.0)"))
	var layout_source: String = FileAccess.get_file_as_string("res://scripts/cartoon/cartoon_game_layout.gd")
	assert(layout_source.contains('interact_button.text = "E  "+context_action'))
	assert(layout_source.contains("event.physical_keycode == KEY_E"))
	assert(layout_source.contains("interact_button.visible = not blocked"))

	print("cartoon_building_interactions_v042: PASS — E e botão USAR entram em guilda, ferreiro, taverna e castelo")
	quit(0)
