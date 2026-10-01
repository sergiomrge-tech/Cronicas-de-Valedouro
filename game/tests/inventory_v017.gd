extends SceneTree

const InventoryUI = preload("res://scripts/cartoon/cartoon_inventory_ui.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var state = root.get_node_or_null("CartoonPlayerState")
	assert(state != null)
	state.reset_progress(true)
	state.player_level = 8

	state.add_material("Seiva Ancestral",5)
	assert(bool(state.craft("REG_002_FLORESTA_ANCESTRAL","weapon").get("ok",false)))
	assert(bool(state.craft("REG_002_FLORESTA_ANCESTRAL","armor").get("ok",false)))
	state.player_level = 18
	state.add_material("Âmbar Negro",5)
	assert(bool(state.craft("REG_003_DESERTO_RUINAS","weapon").get("ok",false)))
	assert(bool(state.craft("REG_003_DESERTO_RUINAS","armor").get("ok",false)))
	assert(state.owned_equipment().size() == 6)

	var inv: Control = InventoryUI.new()
	root.add_child(inv)
	inv.setup(null,null,false)
	inv.open_panel()
	await process_frame

	assert(inv.is_open())
	assert(inv.weapon_slot != null)
	assert(inv.armor_slot != null)
	assert(inv.detail_action != null)
	assert(inv.count_label.text.contains("/66"))
	assert(inv.list_box.get_child_count() == 6)

	inv._set_tab("weapon")
	await process_frame
	assert(inv.current_tab == "equipment")
	assert(inv.equipment_filter == "weapon")
	assert(inv.list_box.get_child_count() == 3)

	inv._select_item("starter_blade")
	await process_frame
	assert(inv.detail_name.text == "Espada de Viagem")
	assert(not inv.detail_action.disabled)
	inv._equip_selected()
	assert(state.is_equipped("starter_blade"))
	assert(inv.detail_action.disabled)

	inv._set_tab("armor")
	await process_frame
	assert(inv.equipment_filter == "armor")
	assert(inv.list_box.get_child_count() == 3)

	state.add_material("Fibra de Junco",2)
	inv._set_tab("materials")
	await process_frame
	assert(inv.current_tab == "materials")
	assert(inv.selected_material == "Fibra de Junco")
	assert(inv.list_box.get_child_count() == 1)
	assert(not inv.detail_action.visible)
	assert(inv.detail_name.text == "Fibra de Junco")

	inv.close_panel()
	assert(not inv.is_open())
	state.reset_progress(true)
	print("inventory_v017: PASS — slots, grade, filtros, comparação e materiais")
	quit(0)
