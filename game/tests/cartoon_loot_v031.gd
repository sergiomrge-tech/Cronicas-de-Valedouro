extends SceneTree

const Loot = preload("res://scripts/cartoon/cartoon_loot_catalog.gd")
const InventoryUI = preload("res://scripts/cartoon/cartoon_inventory_ui.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var state = root.get_node_or_null("CartoonPlayerState")
	assert(state != null)
	state.reset_progress(true)
	state.start_new_game()

	var forced: Dictionary = {"material":0.0,"consumable":0.0,"gear":0.0,"gear_index":0}
	var first: Dictionary = state.award_enemy_loot(
		"REG_001_BERCO_VALEDOURO","wolf",1,false,false,forced
	)
	assert(int(first.get("material_qty",0)) == 1)
	assert(String(first.get("consumable_id","")) == "healing_flask")
	assert(String(first.get("gear_id","")) != "")
	assert(state.material_count("Osso de caça") == 1)
	assert(state.consumable_count("healing_flask") == 1)
	assert(state.loot_pity == 0)

	state.player_max_hp = 120
	state.player_hp = 40
	var used: Dictionary = state.use_consumable("healing_flask")
	assert(bool(used.get("ok",false)))
	assert(int(used.get("healed",0)) == 42)
	assert(state.player_hp == 82)
	assert(state.consumable_count("healing_flask") == 0)

	state.player_hp = state.player_max_hp
	state.add_consumable("healing_flask",1)
	var blocked: Dictionary = state.use_consumable("healing_flask")
	assert(not bool(blocked.get("ok",true)))
	assert(state.consumable_count("healing_flask") == 1)

	state.loot_pity = 49
	var guaranteed: Dictionary = state.award_enemy_loot(
		"REG_002_FLORESTA_ANCESTRAL","wolf",8,false,false,
		{"material":1.0,"consumable":1.0,"gear":0.99,"gear_index":0}
	)
	assert(String(guaranteed.get("gear_id","")) != "")
	assert(state.loot_pity == 0)

	var boss_roll: Dictionary = Loot.roll(
		"REG_006_COSTAS_ILHAS_PERDIDAS",1,true,false,
		{"material":0.0,"consumable":0.0,"gear":1.0}
	)
	assert(int(boss_roll.get("material_qty",0)) == 3)
	assert(String(boss_roll.get("consumable_id","")) == "greater_healing_flask")
	assert(not bool(boss_roll.get("gear",true)))

	state.add_consumable("greater_healing_flask",2)
	state.loot_pity = 17
	state.save_profile()
	state.consumables.clear()
	state.loot_pity = 0
	state.load_profile()
	assert(state.consumable_count("healing_flask") == 1)
	assert(state.consumable_count("greater_healing_flask") == 2)
	assert(state.loot_pity == 17)

	state.player_hp = 30
	var inventory: Control = InventoryUI.new()
	root.add_child(inventory)
	inventory.setup(null,null,false)
	inventory.open_panel("consumables")
	await process_frame
	assert(inventory.current_tab == "consumables")
	assert(inventory.consumables_tab != null)
	assert(inventory.list_box.get_child_count() >= 2)
	assert(inventory.selected_consumable != "")
	assert(inventory.detail_action.text == "USAR")
	assert(not inventory.detail_action.disabled)

	var before_count: int = state.consumables_total()
	inventory._primary_action()
	assert(state.consumables_total() == before_count-1)
	assert(state.player_hp > 30)

	state.reset_progress(true)
	print("cartoon_loot_v031: PASS — loot cadenciado, pity, consumíveis, save v7 e bolsa")
	quit(0)
