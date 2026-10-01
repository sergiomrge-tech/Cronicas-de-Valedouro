extends SceneTree

const BossCrafting = preload("res://scripts/cartoon/cartoon_boss_crafting.gd")
const Forest = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")

const REGION_SCRIPTS: Array[String] = [
	"res://scripts/cartoon/valedouro_cartoon_hub.gd",
	"res://scripts/cartoon/forest/forest_region.gd",
	"res://scripts/cartoon/desert/desert_region.gd",
	"res://scripts/cartoon/marsh/marsh_region.gd",
	"res://scripts/cartoon/frost/frost_region.gd",
	"res://scripts/cartoon/coast/coast_region.gd",
	"res://scripts/cartoon/corrupted/corrupted_region.gd",
	"res://scripts/cartoon/abyss/abyss_region.gd"
]

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	for i in range(8):
		await process_frame

func _recipe(rows: Array[Dictionary],id: String) -> Dictionary:
	for row in rows:
		if String(row.get("id","")) == id:
			return row
	return {}

func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()

	assert(BossCrafting.ROWS.size() == 11)
	var boss_ids: Dictionary = {}
	var recipe_ids: Dictionary = {}
	for row in BossCrafting.ROWS:
		var boss_id: String = String(row.get("boss_id",""))
		var recipe: Dictionary = row.get("recipe",{})
		var recipe_id: String = String(recipe.get("id",""))
		assert(boss_id != "" and not boss_ids.has(boss_id))
		assert(recipe_id != "" and not recipe_ids.has(recipe_id))
		assert(String(row.get("material","")) == String(recipe.get("material","")))
		assert(int(recipe.get("cost",0)) == 1)
		boss_ids[boss_id] = true
		recipe_ids[recipe_id] = true

	for script_path in REGION_SCRIPTS:
		var file := FileAccess.open(script_path,FileAccess.READ)
		assert(file != null,"Missing region source "+script_path)
		assert(file.get_as_text().contains("award_boss_trophy(boss_id)"),"Boss trophy hook missing in "+script_path)

	state.player_level = 8
	assert(_recipe(state.recipes_for("REG_002_FLORESTA_ANCESTRAL"),"BOSS_HELM_ROOT_001").is_empty())

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	var forest = Forest.instantiate()
	root.add_child(forest)
	current_scene = forest
	await settle()
	forest.set_process(false)
	forest.hero.set_process(false)
	if forest.wildlife != null:
		forest.wildlife.set_process(false)
	if forest.get_node_or_null("HUD/GameLayout") != null:
		var layout = forest.get_node("HUD/GameLayout")
		if layout.demon_director != null:
			layout.demon_director.set_process(false)

	assert(forest.crafting_ui.recipe_list.get_node_or_null("BOSS_HELM_ROOT_001") == null)
	var boss_loot: String = forest._award_combat_loot("boss","BOSS_RAIZ_OCA_001",14)
	assert(boss_loot.contains("TROFÉU DE CHEFE"))
	assert(boss_loot.contains("Cerne da Raiz Oca"))
	assert(state.material_count("Cerne da Raiz Oca") == 1)

	var unlocked: Dictionary = _recipe(state.recipes_for("REG_002_FLORESTA_ANCESTRAL"),"BOSS_HELM_ROOT_001")
	assert(not unlocked.is_empty())
	assert(bool(unlocked.get("boss_unique",false)))
	assert(String(unlocked.get("boss_name","")) == "Raiz Oca")

	forest.crafting_ui._refresh()
	var boss_button: Button = forest.crafting_ui.recipe_list.get_node_or_null("BOSS_HELM_ROOT_001")
	assert(boss_button != null)
	assert(boss_button.text.contains("CHEFE"))
	assert(not boss_button.disabled)

	var crafted_result: Dictionary = state.craft_item("REG_002_FLORESTA_ANCESTRAL","BOSS_HELM_ROOT_001")
	assert(bool(crafted_result.get("ok",false)))
	assert(state.material_count("Cerne da Raiz Oca") == 0)
	assert(state.crafted.has("BOSS_HELM_ROOT_001"))
	assert(String(state.equipped_pieces.get("helmet",{}).get("id","")) == "BOSS_HELM_ROOT_001")
	assert(not _recipe(state.recipes_for("REG_002_FLORESTA_ANCESTRAL"),"BOSS_HELM_ROOT_001").is_empty())

	# Boss recipes stay exclusive to crafting even after their trophy unlocked them.
	state.player_level = 18
	var ash: Dictionary = state.award_boss_trophy("BOSS_GENERAL_CINZA_001")
	assert(bool(ash.get("ok",false)))
	var forced_drop: Dictionary = state.award_enemy_loot(
		"REG_003_DESERTO_RUINAS","goblin",18,false,false,
		{"material":1.0,"consumable":1.0,"gear":0.0,"gear_index":999}
	)
	assert(String(forced_drop.get("gear_id","")) != "")
	assert(String(forced_drop.get("gear_id","")) != "BOSS_WPN_ASH_001")

	state.save_profile()
	var saved_helmet: String = String(state.equipped_pieces.get("helmet",{}).get("id",""))
	state.crafted.clear()
	state.equipped_pieces.clear()
	state.materials.clear()
	state.load_profile()
	assert(state.crafted.has("BOSS_HELM_ROOT_001"))
	assert(String(state.equipped_pieces.get("helmet",{}).get("id","")) == saved_helmet)
	assert(not _recipe(state.recipes_for("REG_002_FLORESTA_ANCESTRAL"),"BOSS_HELM_ROOT_001").is_empty())

	forest.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_boss_crafting_v036: PASS — 11 boss trophies, hidden recipes, forge unlock, exclusive drop guard, visual item data and save persistence")
	quit(0)
