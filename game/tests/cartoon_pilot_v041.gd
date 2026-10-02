extends SceneTree
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Chunk = preload("res://scripts/cartoon/cartoon_chunk.gd")
const Art = preload("res://scripts/cartoon/cartoon_pilot_art_v041.gd")
const Person = preload("res://scripts/cartoon/cartoon_town_person_v041.gd")
const Spell = preload("res://scripts/cartoon/cartoon_spell_projectile.gd")
const Arrow = preload("res://scripts/cartoon/cartoon_arrow_projectile.gd")
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func run() -> void:
	for key: String in Art.manifest.nature:
		var tex = Art.nature_texture(key)
		assert(Rect2(Vector2.ZERO,Art.FOLIAGE.get_size()).encloses(tex.region))
		var rect = Art.nature_rect(key)
		var data: Dictionary = Art.manifest.nature[key]
		assert((rect.position+Vector2(data.anchor[0],data.anchor[1])*rect.size/tex.region.size).length()<0.001)
	for role: String in Art.manifest.people:
		var a = Person.new(); a.setup(role); root.add_child(a)
		var b = Person.new(); b.setup(role); root.add_child(b)
		assert(a.sprite_frames==b.sprite_frames,"NPCs must share animation resources")
		for i in range(Art.manifest.people[role].frames.size()):
			var texture = Art.people_texture(role,i)
			assert(Rect2(Vector2.ZERO,Art.PEOPLE.get_size()).encloses(texture.region))
			var anchor = Art.people_anchor(role,i)
			assert(anchor.y>texture.region.size.y-8)
		a.queue_free(); b.queue_free()
	var edge = Chunk.new(); edge.setup(Vector2i(6,7)); root.add_child(edge)
	assert(edge.props_root.get_child_count()>0,"City edge must retain countryside vegetation")
	for prop in edge.props_root.get_children():
		assert(not edge._reserved_clearing(edge.position+prop.position))
		assert(not edge._near_main_road(edge.position+prop.position,125))
	edge.queue_free()
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true); state.start_new_game()
	var hub = load("res://scenes/cartoon/ValedouroCartoonHub.tscn").instantiate()
	root.add_child(hub); current_scene = hub
	await settle()
	hub.set_process(false)
	var director = hub.ambient_encounters
	director.set_process(false)
	assert(director.active.is_empty(),"Starting city must remain peaceful")
	assert(director.slots.size()>500)
	var original: Array = director.slots.duplicate(true)
	director.slots.clear(); director._build_slots()
	assert(director.slots==original,"Procedural camp layout must be reproducible")
	for slot: Dictionary in director.slots:
		assert(not director.safe(slot.pos) and hub.environment.is_walkable(slot.pos))
		assert(slot.level>=1 and slot.level<=8)
	hub.hero.position = Region.world_from_hub(Vector2(-300,630))
	for i in range(8): director._sync()
	assert(director.active.size()>0 and director.active.size()<=director.ACTIVE_LIMIT)
	assert(director.pool.size()+director.active.size()==director.POOL_SIZE)
	var actor = director.active.values()[0]
	var id: String = actor.get_meta("ambient_slot")
	actor.hp -= 7
	var remembered_hp: int = actor.hp
	var home: Vector2 = actor.get_meta("camp_home")
	hub.hero.position = Vector2(13000,13000)
	director._sync()
	assert(not director.active.has(id) and director.memory[id]==remembered_hp)
	hub.hero.position = home
	for i in range(8): director._sync()
	assert(director.active[id].hp==remembered_hp,"Unloading must not heal an encounter")
	actor = director.active[id]
	# Old projectiles must not hit a recycled object representing a new life.
	for projectile in [Arrow.new(),Spell.new()]:
		projectile.host_ref = weakref(hub); projectile.target_ref = weakref(actor)
		projectile.target_epoch = int(actor.get_meta("spawn_epoch"))
		hub.add_child(projectile); projectile.set_process(false)
		actor.set_meta("spawn_epoch",int(actor.get_meta("spawn_epoch"))+1)
		projectile._process(0.1)
		assert(projectile.is_queued_for_deletion())
		assert(actor.hp==remembered_hp)
	var gold: int = hub.player_gold
	var xp: int = state.player_xp
	assert(hub._damage_monster(actor,100000))
	assert(hub.player_gold==gold+6 and state.player_xp>xp)
	assert(not director.active.has(id) and not director.memory.has(id))
	assert(not hub._damage_monster(actor,100000) and hub.player_gold==gold+6)
	var now: float = Time.get_unix_time_from_system()
	assert(float(state.wildlife_cooldowns[id])>=now+295)
	for i in range(8): director._sync()
	assert(not director.active.has(id),"Defeated camp respawned before cooldown")
	state.save_profile()
	state.wildlife_cooldowns.clear()
	state.load_profile()
	assert(float(state.wildlife_cooldowns[id])>now,"Defeat cooldown must survive save/load")
	state.wildlife_cooldowns[id] = now-1
	for i in range(8): director._sync()
	assert(director.active.has(id) and director.active[id].hp==director.active[id].max_hp)
	assert(director.pool.size()+director.active.size()==director.POOL_SIZE)
	# Safe boundary cancels telegraphed strikes, even after the player retreats.
	actor = director.active[id]
	hub.hero.position = Region.world_from_hub(Vector2(1150,970))
	actor.position = hub.hero.position; actor.windup_t = 0.01
	var health: int = hub.player_hp
	hub._update_monsters(0.1)
	assert(hub.player_hp==health and actor.windup_t==0)
	# Other scene systems may retire an actor before the next stream tick.
	actor.queue_free(); await settle()
	director._sync(); director._process(0.61)
	assert(not director.active.has(id))
	hub.queue_free(); await settle()
	state.reset_progress(true)
	print("cartoon_pilot_v041: PASS — edge vegetation, shared atlases, deterministic encounters, bounded pool, HP retention, canonical rewards, save-v8 respawn, stale projectiles and city safety")
	quit()
