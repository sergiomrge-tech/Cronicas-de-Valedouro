extends SceneTree

const MenuScene = preload("res://scenes/cartoon/CartoonMainMenu.tscn")
const InventoryUI = preload("res://scripts/cartoon/cartoon_inventory_ui.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var state = root.get_node_or_null("CartoonPlayerState")
	assert(state != null)
	state.reset_progress(true)
	assert(state.owned_equipment().size() == 2)
	assert(state.profile_summary().contains("2 equipamentos"))
	state.player_level = 8

	state.add_material("Seiva Ancestral",5)
	assert(bool(state.craft("REG_002_FLORESTA_ANCESTRAL","weapon").get("ok",false)))
	assert(bool(state.craft("REG_002_FLORESTA_ANCESTRAL","armor").get("ok",false)))
	assert(state.owned_equipment().size() == 4)
	assert(state.is_equipped("WPN_FOREST_01"))
	assert(bool(state.equip_item("starter_blade").get("ok",false)))
	assert(state.is_equipped("starter_blade"))

	var inv: Control = InventoryUI.new()
	root.add_child(inv)
	inv.setup(null,null,false)
	inv.open_panel()
	await process_frame
	assert(inv.is_open())
	assert(inv.list_box.get_child_count() >= 4)
	inv._set_tab("materials")
	await process_frame
	assert(inv.current_tab == "materials")
	inv.close_panel()
	assert(not inv.is_open())

	var menu: Node = MenuScene.instantiate()
	root.add_child(menu)
	await process_frame
	assert(menu.menu_panel != null)
	assert(menu.inventory_ui != null)
	assert(menu.options_panel != null)
	assert(menu.profile_label.text.contains("equipamentos"))

	state.reset_progress(true)
	print("menu_inventory_layout: PASS — menu inicial, inventário persistente e navegação de equipamento")
	quit(0)
