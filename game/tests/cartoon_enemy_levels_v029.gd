extends SceneTree
const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
const Spell = preload("res://scripts/cartoon/cartoon_spell_projectile.gd")
const Animal = preload("res://scripts/cartoon/cartoon_wildlife_animal.gd")
const Difficulty = preload("res://scripts/cartoon/cartoon_difficulty.gd")
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	assert(Difficulty.outgoing(40,10,10)==40 and Difficulty.incoming(10,10,10)==10)
	assert(Difficulty.outgoing(40,1,6)<=12 and Difficulty.incoming(10,1,6)>=20)
	assert(Difficulty.outgoing(40,1,11)<=5 and Difficulty.incoming(10,1,11)>=40)
	assert(Difficulty.outgoing(1,1,100)==1 and Difficulty.incoming(10,100,1)==10)
	var normal = Difficulty.monster_data({"hp":40,"name":"Wolf","pos":Vector2(100,200)},"REG_002_FLORESTA_ANCESTRAL")
	assert(normal.level>=8 and normal.level<=10)
	var boss = Difficulty.monster_data({"hp":100,"boss_id":"TEST_BOSS"},"REG_002_FLORESTA_ANCESTRAL")
	assert(boss.level==14)
	var siege = Difficulty.monster_data({"hp":40,"name":"Siege invader"},"REG_005_SIEGE_VALEDOURO")
	assert(siege.level>=45 and siege.level<=47)
	var hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	hub.hero.set_process(false)
	var director = hub.get_node("HUD/GameLayout").demon_director
	director.set_process(false)
	for mob in hub.monsters: mob.set_process(false)
	assert(director.active.values()[0].level==9)
	var fixed_level: int = director.active.values()[0].level
	state.player_level = 80
	assert(director.active.values()[0].level==fixed_level,"Enemy auto-scaled to hero instead of its region")
	state.player_level = 1
	hub.hero.position = Vector2(4000,4000)
	var target = Monster.new()
	target.setup({"kind":"wolf","hp":200,"level":11,"pos":hub.hero.position+Vector2(190,0)})
	hub.objects.add_child(target)
	hub.monsters.append(target)
	target.set_process(false)
	var before: int = target.hp
	assert(hub._damage_monster(target,40))
	assert(target.hp==before-Difficulty.outgoing(40,1,11),"Melee ignored level gap")
	var shot = Spell.launch(hub,hub.hero,target,40)
	shot.set_process(false)
	before = target.hp
	shot._process(0.5)
	assert(target.hp==before-Difficulty.outgoing(40,1,11),"Magic impact ignored level gap")
	shot.queue_free()
	assert(hub.hero.reduce_incoming_damage(10,11)==Difficulty.incoming(10,1,11))
	var animal = Animal.new()
	animal.setup(hub.wildlife,{"id":"TEST_LEVEL_ANIMAL","kind":"boar","level":11,"pos":hub.hero.position+Vector2(200,0)})
	hub.objects.add_child(animal)
	animal.set_process(false)
	hub.wildlife.active[animal.slot_id] = animal
	before = animal.hp
	animal.take_damage(40)
	assert(animal.hp==before-Difficulty.outgoing(40,1,11),"Wildlife ignored level gap")
	state.player_level = 11
	before = target.hp
	assert(hub._damage_monster(target,40) and target.hp==before-40,"Equal-level combat kept high-level penalty")
	hub.queue_free()
	await settle()
	state.reset_progress(true)
	var siege_scene = load("res://scenes/cartoon/ValedouroSiegeCartoon.tscn").instantiate()
	root.add_child(siege_scene)
	current_scene = siege_scene
	await settle()
	var attackers: Array = siege_scene.hub.monsters.filter(func(m): return not m.is_in_group("cartoon_elite_demons"))
	assert(attackers.size()==6)
	for invader in attackers: assert(invader.level>=45 and invader.level<=47)
	var siege_director = siege_scene.hub.get_node("HUD/GameLayout").demon_director
	assert(siege_director.active.size()==6)
	for elite in siege_director.active.values(): assert(is_instance_valid(elite) and not elite.is_queued_for_deletion() and siege_scene.hub.monsters.has(elite))
	siege_scene.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_enemy_levels_v029: PASS — fixed region/boss/elite/fauna levels, level-gap melee/magic/incoming, minimum chip, equal-level recovery")
	quit()
