extends SceneTree
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const ForestScene = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")
const Hero = preload("res://scripts/cartoon/cartoon_hero.gd")
const Art = preload("res://scripts/cartoon/cartoon_combat_art.gd")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
const FX = preload("res://scripts/cartoon/cartoon_combat_fx.gd")
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(5): await process_frame
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	for direction in ["front","back","left","right"]:
		for animation in Art.FRAMES:
			var texture = Art.texture("hero_"+direction+"_"+animation)
			assert(texture != null and texture.get_width()==128*int(Art.FRAMES[animation]))
	var hub = HubScene.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	# A controlled target beyond sword range; preserve the region's kill/reward path.
	hub.wildlife.process_mode = Node.PROCESS_MODE_DISABLED
	for a in hub.wildlife.active.values(): a.position = Vector2(-9000,-9000)
	for m in hub.monsters: m.position = Vector2(-8000,-8000)
	hub.hero.position = Vector2(4000,4000)
	var target = Monster.new()
	target.setup({"kind":"wolf","hp":20,"pos":hub.hero.position+Vector2(190,0)})
	hub.add_child(target)
	hub.monsters.append(target)
	var gold: int = hub.player_gold
	assert(hub.hero.combat_range(105)==105)
	hub._attack()
	assert(target.hp==20,"Sword unexpectedly gained magic reach")
	assert(hub.hero.cast_spell(hub))
	assert(target.hp==0,"Spell did not damage ranged target")
	assert(hub.player_gold==gold+6,"Region reward path bypassed")
	assert(not hub.hero.spell_mode and hub.hero.spell_cooldown>0)
	assert(not hub.hero.cast_spell(hub),"Spell ignored cooldown")
	for i in range(3): hub.hero.cycle_spell()
	assert(hub.hero.spell_index==0)
	hub.hero.trigger_hurt()
	assert(hub.hero.hurt_t>0)
	var layout = hub.get_node("HUD/GameLayout")
	for dimensions: Vector2i in [Vector2i(640,360),Vector2i(960,540),Vector2i(1024,768)]:
		root.size = dimensions
		root.content_scale_size = dimensions
		await settle()
		layout._layout()
		for button in [layout.spell_button,layout.spell_cycle_button]:
			assert(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(button.get_global_rect()))
			assert(not button.get_global_rect().intersects(layout.attack_button.get_global_rect()))
			assert(not button.get_global_rect().intersects(layout.interact_button.get_global_rect()))
			for other in [layout.map_button,layout.pause_button,layout.quest_panel,hub.zoom_controls.panel,hub.inventory_ui.toggle_button,hub.crafting_ui.toggle_button]:
				assert(not button.get_global_rect().intersects(other.get_global_rect()),"Spell HUD overlaps existing controls")
	layout.open_pause()
	hub.hero.spell_cooldown = 0
	assert(not hub.hero.cast_spell(hub),"Spell during pause")
	layout.close_pause()
	# Effects are bounded and clean up independently of defeated actors.
	for i in range(60): FX.spawn(hub,hub.hero.position,"arcane")
	assert(FX.active_count<=48 and FX.light_count<=8)
	for child in get_nodes_in_group("cartoon_combat_fx"):
		if child is ValedouroCartoonCombatFX: child._process(2)
	await settle()
	assert(FX.active_count==0 and FX.light_count==0)
	hub.queue_free()
	await settle()
	var forest = ForestScene.instantiate()
	root.add_child(forest)
	current_scene = forest
	await settle()
	var boss = null
	for m in forest.monsters:
		if m.boss_id=="BOSS_RAIZ_OCA_001": boss=m
	assert(boss != null)
	forest.hero.position = boss.position+Vector2(190,0)
	forest.wildlife.process_mode = Node.PROCESS_MODE_DISABLED
	for a in forest.wildlife.active.values(): a.position = Vector2(-9000,-9000)
	var hp: int = boss.hp
	forest.hero.cast_spell(forest)
	assert(boss.hp==hp,"Spell bypassed campaign gate")
	forest.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_combat_v024: PASS — 152 hero frames, ranged spells, cooldown, rewards, campaign locks, responsive buttons and bounded FX cleanup")
	quit()
