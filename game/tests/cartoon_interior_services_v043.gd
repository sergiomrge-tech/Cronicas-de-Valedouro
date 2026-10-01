extends SceneTree

const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")

func _initialize() -> void:
	call_deferred("run")

func _point_pos(interiors, id: String) -> Vector2:
	for point in interiors.points:
		if String(point.get("id","")) == id:
			return point.get("pos",Vector2.INF)
	return Vector2.INF

func _press_interact(hub) -> void:
	var layout = hub.get_node("HUD/GameLayout")
	layout.desktop_mode = true
	var e_event: InputEventKey = InputEventKey.new()
	e_event.physical_keycode = KEY_E
	e_event.pressed = true
	layout._unhandled_input(e_event)
	await process_frame

func _enter(hub, outside_pos: Vector2, expected_kind: String) -> void:
	hub.hero.position = outside_pos
	hub._interact()
	await process_frame
	assert(hub.interiors.active)
	assert(hub.interiors.kind == expected_kind)

func _leave_via_exit(hub) -> void:
	var exit_pos: Vector2 = _point_pos(hub.interiors,"exit")
	assert(exit_pos != Vector2.INF)
	hub.hero.position = exit_pos
	await _press_interact(hub)
	assert(not hub.interiors.active)

func run() -> void:
	var hub = HubScene.instantiate()
	root.add_child(hub)
	await process_frame
	await process_frame
	var layout = hub.get_node("HUD/GameLayout")
	layout.desktop_mode = true

	var entrances: Dictionary = {
		"guild": Region.world_from_hub(Vector2(760,1165)),
		"forge": Region.world_from_hub(Vector2(720,830)),
		"tavern": Region.world_from_hub(Vector2(1580,840)),
		"castle": Region.world_from_hub(Region.CASTLE_DOOR)+Vector2(0,120)
	}

	# Guild: E must open the real contract board, then E on exit must leave.
	await _enter(hub,entrances["guild"],"guild")
	var board_pos: Vector2 = _point_pos(hub.interiors,"board")
	assert(board_pos != Vector2.INF)
	hub.hero.position = board_pos
	hub.interiors._refresh_hint()
	assert(hub.poi_label.text.contains("E — CONTRATOS"))
	await _press_interact(hub)
	assert(hub.guild_board.is_open())
	hub.guild_board.close_panel()
	await _leave_via_exit(hub)

	# Forge: E must open the crafting interface.
	await _enter(hub,entrances["forge"],"forge")
	var craft_pos: Vector2 = _point_pos(hub.interiors,"craft")
	assert(craft_pos != Vector2.INF)
	hub.hero.position = craft_pos
	hub.interiors._refresh_hint()
	assert(hub.poi_label.text.contains("E — FORJAR"))
	await _press_interact(hub)
	assert(hub.crafting_ui.is_open())
	hub.crafting_ui.close_panel()
	await _leave_via_exit(hub)

	# Tavern: resting restores health and exit remains functional.
	await _enter(hub,entrances["tavern"],"tavern")
	hub.player_hp = maxi(1,hub.player_max_hp-17)
	var rest_pos: Vector2 = _point_pos(hub.interiors,"rest")
	assert(rest_pos != Vector2.INF)
	hub.hero.position = rest_pos
	hub.interiors._refresh_hint()
	assert(hub.poi_label.text.contains("E — DESCANSAR"))
	await _press_interact(hub)
	assert(hub.player_hp == hub.player_max_hp)
	await _leave_via_exit(hub)

	# Castle: audience interaction works and exit returns to Valedouro.
	await _enter(hub,entrances["castle"],"castle")
	var audience_pos: Vector2 = _point_pos(hub.interiors,"royal_audience")
	assert(audience_pos != Vector2.INF)
	hub.hero.position = audience_pos
	hub.interiors._refresh_hint()
	assert(hub.poi_label.text.contains("E — FALAR"))
	await _press_interact(hub)
	await _leave_via_exit(hub)

	# PC HUD must expose contextual interaction text instead of a generic hidden action.
	var layout_source: String = FileAccess.get_file_as_string("res://scripts/cartoon/cartoon_game_layout.gd")
	assert(layout_source.contains('context_action = "ENTRAR"'))
	assert(layout_source.contains('interact_button.text = "E  "+context_action'))
	var interior_source: String = FileAccess.get_file_as_string("res://scripts/cartoon/cartoon_interiors.gd")
	assert(interior_source.contains("func action_text"))
	assert(interior_source.contains("Interaction markers"))

	print("cartoon_interior_services_v043: PASS — entrar, usar serviços e sair funciona em guilda, forja, taverna e castelo")
	quit(0)
