extends SceneTree

const MenuScene = preload("res://scenes/cartoon/CartoonMainMenu.tscn")
const ZoomControls = preload("res://scripts/cartoon/cartoon_zoom_controls.gd")
const CraftingUI = preload("res://scripts/cartoon/cartoon_crafting_ui.gd")
const InventoryUI = preload("res://scripts/cartoon/cartoon_inventory_ui.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var state = root.get_node_or_null("CartoonPlayerState")
	assert(state != null)
	state.reset_progress(true)

	var menu: Node = MenuScene.instantiate()
	root.add_child(menu)
	await process_frame
	assert(menu.menu_panel.get_node_or_null("MenuContent") != null)
	assert(menu.options_panel.get_node_or_null("OptionsContent") != null)
	assert(menu.confirmation_panel.get_node_or_null("ConfirmationContent") != null)
	assert(menu.continue_button.disabled)
	assert(menu.delete_button.disabled)

	state.start_new_game()
	menu._refresh_profile()
	assert(not menu.continue_button.disabled)
	assert(not menu.delete_button.disabled)

	var camera: Camera2D = Camera2D.new()
	root.add_child(camera)
	var zoom: Control = ZoomControls.new()
	root.add_child(zoom)
	zoom.setup(camera)
	await process_frame
	var zoom_content: Node = zoom.panel.get_node_or_null("ZoomContent")
	assert(zoom_content != null)
	assert(zoom_content.get_child_count() == 4)

	var forge: Control = CraftingUI.new()
	root.add_child(forge)
	forge.setup(null,null,"REG_001_BERCO_VALEDOURO")
	await process_frame
	assert(forge.panel.get_node_or_null("CraftingContent") != null)

	var inventory: Control = InventoryUI.new()
	root.add_child(inventory)
	inventory.setup(null,null,false)
	await process_frame
	assert(inventory.panel.get_node_or_null("InventoryContent") != null)

	state.reset_progress(true)
	print("ui_layout_v019: PASS — containers internos preservam layout de menu, zoom, forja e inventário")
	quit(0)
