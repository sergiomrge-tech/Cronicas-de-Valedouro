extends SceneTree

const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	for i in range(8):
		await process_frame

func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()

	assert(state.equipment_required_level({"tier":0}) == 1)
	assert(state.equipment_required_level({"tier":1}) == 8)
	assert(state.equipment_required_level({"tier":2}) == 18)
	assert(state.equipment_required_level({"tier":3}) == 28)
	assert(state.equipment_required_level({"tier":4}) == 40)
	assert(state.equipment_required_level({"tier":5}) == 55)
	assert(state.equipment_required_level({"tier":6}) == 70)
	assert(state.equipment_required_level({"tier":7}) == 85)

	state.add_material("Seiva Ancestral",20)
	var locked_craft: Dictionary = state.craft_item("REG_002_FLORESTA_ANCESTRAL","WPN_FOREST_01")
	assert(not bool(locked_craft.get("ok",true)))
	assert(String(locked_craft.get("message","")).contains("nível 8"))
	assert(not state.crafted.has("WPN_FOREST_01"))

	var drop: Dictionary = state.award_enemy_loot(
		"REG_002_FLORESTA_ANCESTRAL","wolf",8,false,false,
		{"material":1.0,"consumable":1.0,"gear":0.0,"gear_index":0}
	)
	var dropped_id: String = String(drop.get("gear_id",""))
	assert(dropped_id != "")
	assert(state.crafted.has(dropped_id))
	var locked_equip: Dictionary = state.equip_item(dropped_id)
	assert(not bool(locked_equip.get("ok",true)))
	assert(int(locked_equip.get("required_level",0)) == 8)

	state.player_level = 8
	var equipped: Dictionary = state.equip_item(dropped_id)
	assert(bool(equipped.get("ok",false)))
	assert(state.is_equipped(dropped_id))
	assert(bool(state.equip_item("starter_blade").get("ok",false)))

	state.player_level = 1
	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	var hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	hub.hero.set_process(false)
	var layout = hub.get_node("HUD/GameLayout")
	if layout.demon_director != null:
		layout.demon_director.set_process(false)
	for mob in hub.monsters:
		if is_instance_valid(mob):
			mob.set_process(false)

	state.add_consumable("healing_flask",2)
	state.add_consumable("greater_healing_flask",1)
	hub.player_max_hp = 100
	hub.player_hp = 30
	state.player_max_hp = 100
	state.player_hp = 30
	layout._process(0.0)
	assert(layout.heal_button != null)
	assert(layout.heal_button.visible)
	assert(not layout.heal_button.disabled)
	assert(layout.heal_button.text.contains("x3"))
	for other in layout.spell_buttons+[layout.dodge_button,layout.attack_button,layout.interact_button]:
		if other.visible:
			assert(not layout.heal_button.get_global_rect().intersects(other.get_global_rect()),"Quick heal overlaps "+String(other.name))

	layout._quick_heal()
	await settle()
	assert(hub.player_hp == 100)
	assert(state.consumable_count("greater_healing_flask") == 0)
	assert(state.consumable_count("healing_flask") == 2)

	hub.player_hp = 60
	state.player_hp = 60
	layout._quick_heal()
	await settle()
	assert(hub.player_hp == 95)
	assert(state.consumable_count("healing_flask") == 1)
	layout._process(0.0)
	assert(layout.heal_button.text.contains("x1"))

	hub.player_hp = 100
	state.player_hp = 100
	layout._process(0.0)
	assert(layout.heal_button.disabled)

	hub.inventory_ui.open_panel("equipment")
	await settle()
	hub.inventory_ui._select_item(dropped_id)
	await settle()
	assert(hub.inventory_ui.detail_action.disabled)
	assert(hub.inventory_ui.detail_action.text == "NÍVEL 8")
	assert(hub.inventory_ui.detail_meta.text.contains("Requer Nv 8"))
	hub.inventory_ui.close_panel()

	hub.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_rpg_progression_v033: PASS — quick heal, smart flask choice, regional equipment level gates and locked inventory state")
	quit(0)
