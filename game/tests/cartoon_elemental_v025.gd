extends SceneTree
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const ForestScene = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
const Animal = preload("res://scripts/cartoon/cartoon_wildlife_animal.gd")
const Spell = preload("res://scripts/cartoon/cartoon_spell_projectile.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
var hub
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(5): await process_frame
func dummy(hp: int, offset: Vector2, boss_id: String = ""):
	var actor = Monster.new()
	actor.setup({"kind":"wolf","hp":hp,"speed":100,"pos":hub.hero.position+offset,"boss_id":boss_id})
	hub.objects.add_child(actor)
	hub.monsters.append(actor)
	actor.process_mode = Node.PROCESS_MODE_DISABLED
	return actor
func clear_actors() -> void:
	for shot in get_nodes_in_group("cartoon_spell_projectiles"): shot.queue_free()
	for monster in hub.monsters.duplicate():
		if is_instance_valid(monster): monster.queue_free()
	hub.monsters.clear()
func cast(index: int):
	hub.hero.spell_index = index
	hub.hero.spell_cooldowns[hub.hero.spell_index] = 0
	assert(hub.hero.cast_spell(hub))
	var shots = get_nodes_in_group("cartoon_spell_projectiles")
	assert(shots.size()==1)
	shots[0].process_mode = Node.PROCESS_MODE_DISABLED
	return shots[0]
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	hub = HubScene.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	state.player_level = 25 # Teste técnico: todas as magias já desbloqueadas.
	hub.set_process(false)
	hub.wildlife.process_mode = Node.PROCESS_MODE_DISABLED
	for animal in hub.wildlife.active.values(): animal.queue_free()
	hub.wildlife.active.clear()
	clear_actors()
	await settle()
	hub.hero.position = Vector2(4000,4000)
	# Flight, snapshot, burn and reward exactly once, including a lethal final tick.
	var target = dummy(22,Vector2(190,0))
	var gold: int = hub.player_gold
	var shot = cast(0)
	assert(target.hp==22)
	shot._process(0.10)
	assert(target.hp==22)
	target.position += Vector2(20,0)
	hub.hero.spell_index = 1
	shot._process(0.40)
	assert(target.hp==4 and target.burn_t>0,"Projectile must keep original element after selection changes")
	shot._process(0.6)
	assert(target.hp==2)
	shot._process(0.6)
	assert(target.hp==0 and hub.player_gold==gold+6)
	assert(not hub._damage_monster(target,999) and hub.player_gold==gold+6,"Dead target paid twice")
	await settle()
	assert(Spell.active_count==0)
	# Cold restores original speed, and bosses have reduced slowdown.
	target = dummy(100,Vector2(190,0))
	shot = cast(1)
	shot._process(0.6)
	assert(target.hp==82 and is_equal_approx(target.move_speed,55))
	target._process(2.6)
	assert(is_equal_approx(target.move_speed,100) and target.chill_t==0)
	clear_actors()
	await settle()
	target = dummy(100,Vector2(190,0),"TEST_BOSS")
	shot = cast(1)
	shot._process(0.6)
	assert(is_equal_approx(target.move_speed,80),"Boss slowdown must be reduced")
	clear_actors()
	await settle()
	# Arcana has one secondary hit, never a recursive chain.
	var first = dummy(100,Vector2(160,0))
	var second = dummy(100,Vector2(235,0))
	var third = dummy(100,Vector2(300,0))
	shot = cast(2)
	shot._process(0.5)
	assert(first.hp==77 and second.hp==100)
	await settle()
	var echo_shots = get_nodes_in_group("cartoon_spell_projectiles")
	assert(echo_shots.size()==1 and echo_shots[0].is_echo)
	echo_shots[0]._process(0.5)
	assert(second.hp==88 and third.hp==100)
	await settle()
	assert(Spell.active_count==0)
	clear_actors()
	await settle()
	# An actual city building blocks spells, without treating open water as a wall.
	var from: Vector2 = Region.world_from_hub(Vector2(610,740))
	var to: Vector2 = Region.world_from_hub(Vector2(710,640))
	assert(hub.environment.is_walkable(from) and hub.environment.is_walkable(to))
	assert(not Spell.line_clear(hub,from,to),"Forge footprint must block line of sight")
	assert(Spell.line_clear(hub,Vector2(4000,4000),Vector2(4210,4000)))
	var open_water: bool = false
	for river in hub.environment.river_polylines:
		for i in range(river.size()-1):
			var water: Vector2 = Region.world_from_hub((river[i]+river[i+1])*0.5)
			if not hub.environment.is_walkable(water) and not hub.environment.blocks_spell(water):
				assert(Spell.line_clear(hub,water-Vector2(0,4),water+Vector2(0,4)))
				open_water = true
	assert(open_water,"Open water must not become a projectile wall")
	# Pause freezes flight and burn; entering a building cancels pending hits.
	target = dummy(100,Vector2(190,0))
	shot = cast(0)
	var start: Vector2 = shot.global_position
	var layout = hub.get_node("HUD/GameLayout")
	layout.open_pause()
	shot._process(0.7)
	assert(shot.global_position==start and target.hp==100)
	layout.close_pause()
	shot._process(0.6)
	assert(target.hp==82)
	layout.open_pause()
	shot._process(0.7)
	assert(target.hp==82)
	layout.close_pause()
	shot._process(0.6)
	assert(target.hp==80)
	hub.interiors.active = true
	shot._process(0.6)
	assert(target.hp==80 and shot.is_queued_for_deletion())
	hub.interiors.active = false
	clear_actors()
	await settle()
	# Wildlife goes through harvest, material, contract and saved cooldown logic.
	var animal = Animal.new()
	animal.setup(hub.wildlife,{"id":"TEST_BURN_HUNT","kind":"rabbit","pos":hub.hero.position+Vector2(190,0)})
	animal.hp = 22 # Wounded animal isolates lethal burn/harvest from the new full-health balance.
	hub.objects.add_child(animal)
	hub.wildlife.active[animal.slot_id] = animal
	animal.process_mode = Node.PROCESS_MODE_DISABLED
	var meat: int = state.material_count("Carne de caça")
	shot = cast(0)
	shot._process(0.6)
	assert(animal.hp==4)
	shot._process(1.21)
	assert(animal.dead and state.material_count("Carne de caça")==meat+1)
	assert(state.wildlife_cooldowns.has("TEST_BURN_HUNT"))
	await settle()
	# Lost targets and scene changes cannot leave live projectiles or references.
	target = dummy(100,Vector2(190,0))
	shot = cast(2)
	target.queue_free()
	await settle()
	shot._process(0.2)
	await settle()
	assert(Spell.active_count==0)
	clear_actors()
	await settle()
	target = dummy(100,Vector2(190,0))
	for i in range(Spell.LIMIT):
		var limited = Spell.launch(hub,hub.hero,target,18)
		assert(limited != null)
		limited.process_mode = Node.PROCESS_MODE_DISABLED
	assert(Spell.launch(hub,hub.hero,target,18)==null,"Projectile budget was exceeded")
	clear_actors()
	await settle()
	assert(Spell.active_count==0)
	hub.queue_free()
	await settle()
	var forest = ForestScene.instantiate()
	root.add_child(forest)
	current_scene = forest
	await settle()
	var locked = null
	for m in forest.monsters:
		if m.boss_id=="BOSS_RAIZ_OCA_001": locked=m
	assert(locked != null)
	var old_hp: int = locked.hp
	assert(not forest._damage_monster(locked,99999) and locked.hp==old_hp,"Delayed or burn damage bypassed story gate")
	forest.queue_free()
	await settle()
	assert(Spell.active_count==0)
	state.reset_progress(true)
	print("cartoon_elemental_v025: PASS — timed impact, elemental snapshot, burn rewards, slow restoration, boss resistance, one echo, walls, pause, interior cancellation, hunt and story gates")
	quit()
