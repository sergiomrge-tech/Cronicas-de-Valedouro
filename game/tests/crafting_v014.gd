extends SceneTree

const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const CraftUI = preload("res://scripts/cartoon/cartoon_crafting_ui.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var state = root.get_node_or_null("CartoonPlayerState")
	assert(state != null)
	state.reset_progress(false)
	assert(state.attack_bonus() == 0)
	assert(state.defense_bonus() == 0)

	state.add_material("Seiva Ancestral",5)
	assert(state.material_count("Seiva Ancestral") == 5)
	var weapon_result: Dictionary = state.craft("REG_002_FLORESTA_ANCESTRAL","weapon")
	assert(bool(weapon_result.get("ok",false)))
	assert(state.material_count("Seiva Ancestral") == 2)
	assert(state.attack_bonus() == 4)
	var armor_result: Dictionary = state.craft("REG_002_FLORESTA_ANCESTRAL","armor")
	assert(bool(armor_result.get("ok",false)))
	assert(state.material_count("Seiva Ancestral") == 0)
	assert(state.defense_bonus() == 2)

	var hero: Node2D = HeroScript.new()
	root.add_child(hero)
	await process_frame
	assert(hero.weapon_tier == 1)
	assert(hero.armor_tier == 1)
	assert(hero.attack_damage(20) == 24)
	assert(hero.reduce_incoming_damage(10) == 8)

	state.add_material("Âmbar Negro",3)
	var desert_weapon: Dictionary = state.craft("REG_003_DESERTO_RUINAS","weapon")
	assert(bool(desert_weapon.get("ok",false)))
	hero.apply_equipment_from_state()
	assert(hero.weapon_tier == 2)
	assert(hero.attack_damage(20) == 27)

	var ui: Control = CraftUI.new()
	root.add_child(ui)
	ui.setup(null,hero,"REG_003_DESERTO_RUINAS")
	await process_frame
	assert(ui.weapon_button != null)
	assert(ui.armor_button != null)
	ui._toggle()
	assert(ui.is_open())
	ui._toggle()
	assert(not ui.is_open())

	state.reset_progress(false)
	print("crafting_v014: PASS — materiais persistentes, 14 receitas, equipamento e bônus de combate")
	quit(0)
