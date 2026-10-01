extends SceneTree
const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Forest = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
const Arrow = preload("res://scripts/cartoon/cartoon_arrow_projectile.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(6): await process_frame
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	var regions = ["REG_001_BERCO_VALEDOURO","REG_002_FLORESTA_ANCESTRAL","REG_003_DESERTO_RUINAS","REG_004_PANTANOS_SOMBRIOS","REG_005_MONTANHAS_NEVADAS","REG_006_COSTAS_ILHAS_PERDIDAS","REG_007_TERRAS_CORROMPIDAS","REG_008_CORACAO_ABISSAL"]
	var unique: Dictionary = {}
	for region in regions:
		var recipes = state.recipes_for(region)
		assert(recipes.size()==8)
		for row in recipes:
			assert(not unique.has(row.id))
			unique[row.id] = true
	assert(unique.size()==64)
	var forest: String = regions[1]
	var rows = state.recipes_for(forest)
	state.player_level = 8
	assert(not state.craft_item(forest,rows[2].id).ok)
	assert(state.crafted.is_empty() and state.material_total()==0)
	state.add_material("Seiva Ancestral",40)
	for row in rows: assert(state.craft_item(forest,row.id).ok)
	assert(state.owned_equipment().size()==10 and state.set_progress().complete)
	assert(state.defense_bonus()==10 and state.attack_bonus()==6)
	var before: int = state.material_total()
	assert(state.craft_item(forest,rows[2].id).ok and state.material_total()==before)
	assert(state.equipped_weapon.weapon_kind=="bow")
	state.player_level = 18
	state.add_material("Âmbar Negro",10)
	var desert = state.recipes_for(regions[2])
	assert(state.craft_item(regions[2],desert[3].id).ok)
	assert(not state.set_progress().complete)
	assert(state.equip_item(rows[3].id).ok and state.set_progress().complete)
	state.save_profile()
	state.equipped_pieces.clear()
	state.equipped_weapon = state.starter_equipment()[0]
	state.load_profile()
	assert(state.set_progress().complete and state.equipped_weapon.weapon_kind=="bow")
	# Version 4 migration enriches original chest, preserves materials/class/story.
	var file = FileAccess.open(state.SAVE_PATH,FileAccess.READ)
	var saved: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	saved.version = 4
	saved.erase("equipped_pieces")
	file = FileAccess.open(state.SAVE_PATH,FileAccess.WRITE)
	file.store_string(JSON.stringify(saved))
	file.close()
	state.load_profile()
	assert(state.equipped_pieces.is_empty() and state.equipped_armor.id==rows[1].id and state.material_total()==before+8)
	state.player_gold = 10
	var materials_before: int = state.material_total()
	assert(state.buy_crafting_material(forest).ok and state.player_gold==0 and state.material_total()==materials_before+1)
	assert(not state.buy_crafting_material(forest).ok and state.player_gold==0)
	state.reset_progress(true)
	var hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.hero.position = Region.world_from_hub(Vector2(1150,1850))
	state.add_material("Osso de caça",3)
	var bow = state.recipes_for(regions[0])[2]
	assert(state.craft_item(regions[0],bow.id).ok)
	hub.hero.apply_equipment_from_state()
	assert(hub.hero.bow_equipped and hub.hero.combat_range(105)==300)
	var target = Monster.new()
	target.kind = "slime"
	target.hp = 100
	target.max_hp = 100
	hub.objects.add_child(target)
	target.position = hub.hero.position+Vector2(230,0)
	target.set_process(false)
	hub.monsters.append(target)
	var arrow = hub.hero.launch_arrow(hub,target,18)
	assert(arrow != null and target.hp==100)
	assert(hub.hero.launch_arrow(hub,target,18)==null,"Bow ignored cooldown")
	arrow.set_process(false)
	hub.inventory_ui.open_panel()
	var start: Vector2 = arrow.global_position
	arrow._process(0.2)
	assert(arrow.global_position==start and target.hp==100,"Arrow advanced through modal")
	hub.inventory_ui.close_panel()
	state.equip_item("starter_blade")
	hub.hero.apply_equipment_from_state()
	assert(not hub.hero.bow_equipped and hub.hero.combat_range(105)==105)
	for i in range(6):
		if is_instance_valid(arrow) and not arrow.is_queued_for_deletion(): arrow._process(0.1)
	assert(target.hp==80,"Flight lost snapshotted bow damage")
	await settle()
	assert(Arrow.active_count==0)
	assert(hub.hero.launch_arrow(hub,target,18)==null,"Sword created an arrow")
	state.equip_item(bow.id)
	hub.hero.apply_equipment_from_state()
	hub.hero.bow_cooldown = 0
	target.position = hub.hero.position+Vector2(500,0)
	assert(hub.hero.launch_arrow(hub,target,18)==null,"Bow ignored range")
	# City walls reject shots before the cooldown is consumed.
	hub.hero.position = Region.world_from_hub(Vector2(610,740))
	target.position = Region.world_from_hub(Vector2(710,640))
	hub.hero.bow_cooldown = 0
	assert(hub.hero.launch_arrow(hub,target,18)==null and hub.hero.bow_cooldown==0)

	# Full inventory and all eight recipe controls are usable.
	var gold: int = hub.player_gold
	assert(state.buy_crafting_material(regions[0]).ok and hub.player_gold==gold-10 and state.player_gold==gold-10)
	state.load_profile()
	assert(state.player_gold==gold-10)
	hub.crafting_ui._toggle()
	assert(hub.crafting_ui.recipe_list.get_child_count()==8)
	hub.crafting_ui.close_panel()
	hub.queue_free()
	await settle()
	state.reset_progress(true)
	var forest_scene = Forest.instantiate()
	root.add_child(forest_scene)
	current_scene = forest_scene
	await settle()
	state.player_level = 8
	state.add_material("Seiva Ancestral",3)
	assert(state.craft_item(forest,rows[2].id).ok)
	forest_scene.hero.apply_equipment_from_state()
	var locked = Monster.new()
	locked.kind = "slime"
	locked.story_tag = "forest_defense"
	locked.hp = 100
	locked.max_hp = 100
	forest_scene.objects.add_child(locked)
	locked.position = forest_scene.hero.position+Vector2(180,0)
	locked.set_process(false)
	forest_scene.monsters.append(locked)
	assert(not forest_scene._can_damage_monster(locked,false))
	var guarded = forest_scene.hero.launch_arrow(forest_scene,locked,20)
	assert(guarded!=null)
	guarded.set_process(false)
	guarded._process(0.4)
	assert(locked.hp==100,"Arrow bypassed story gate on impact")
	forest_scene.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_equipment_v028: PASS — 64 recipes, complete sets, migration, bow flight/cooldown/modal/snapshot")
	quit()
