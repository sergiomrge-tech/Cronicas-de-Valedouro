extends Node
## Bounded REG001 encounter stream: stable camps, pooled actors, persistent defeat cooldowns.
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
const Difficulty = preload("res://scripts/cartoon/cartoon_difficulty.gd")
const Story = preload("res://scripts/cartoon/cartoon_main_story_map.gd")
const ACTIVE_LIMIT: int = 18
const POOL_SIZE: int = 24
const RESPAWN_SECONDS: float = 300.0
const SPAWN_RADIUS: float = 1150.0
const DESPAWN_RADIUS: float = 1500.0
var host
var layout
var slots: Array[Dictionary] = []
var active: Dictionary = {}
var pool: Array[Node2D] = []
var memory: Dictionary = {}
var elapsed: float = 0
var epoch: int = 0
func safe(p: Vector2) -> bool:
	return Region.ROYAL_GROUNDS.grow(80).has_point(p) or (Region.HUB_RECT.grow(100).has_point(p) and Region.hub_from_world(p).y<1610)
func setup(owner_node) -> void:
	host = owner_node
	layout = host.get_node("HUD/GameLayout")
	_build_slots()
	for i in range(POOL_SIZE):
		var actor = Monster.new()
		host.objects.add_child(actor)
		actor.hide()
		actor.set_process(false)
		actor.hp = 0
		pool.append(actor)
	_sync()
func _build_slots() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 4102026
	var zones: Array = Story.act1_zones()
	for y in range(1,24):
		for x in range(1,23):
			var center = Vector2(x*680+130,y*680+130)+Vector2(rng.randf_range(-110,110),rng.randf_range(-110,110))
			for j in range(2):
				var p: Vector2 = center+Vector2((j*2-1)*64,j*50)
				if safe(p) or not host.environment.is_walkable(p): continue
				var reserved: bool = false
				for poi: Dictionary in host.environment.pois:
					if p.distance_to(poi.pos)<190: reserved = true; break
				for zone: Dictionary in zones:
					if p.distance_to(zone.pos)<float(zone.radius)*0.85: reserved = true; break
				if reserved: continue
				var distance: float = p.distance_to(Region.HUB_RECT.get_center())
				var level: int = clampi(1+floori(distance/1450)+j,1,8)
				var kind: String = "wolf" if (x+y+j)%3!=0 else "slime"
				slots.append({"id":"ENCOUNTER_REG001_%d_%d_%d"%[x,y,j],"pos":p,"level":level,"kind":kind,"name":"Lobo dos arredores" if kind=="wolf" else "Gosma do bosque","hp":34 if kind=="wolf" else 30,"speed":86 if kind=="wolf" else 62,"damage":7 if kind=="wolf" else 6})
func blocked() -> bool:
	if host.interiors.active: return true
	return layout.is_blocked()
func _process(delta: float) -> void:
	if blocked(): return
	elapsed += delta
	if elapsed>=0.6:
		elapsed = 0
		_sync()
	for actor in active.values():
		if not is_instance_valid(actor) or actor.is_queued_for_deletion(): continue
		if not actor.can_chase() or actor.position.distance_to(host.hero.position)<320: continue
		var home: Vector2 = actor.get_meta("camp_home")
		var angle: float = actor.anim_t*0.15+float(actor.get_meta("spawn_epoch"))
		var next: Vector2 = actor.position.move_toward(home+Vector2(cos(angle),sin(angle))*60,18*delta)
		if not safe(next) and host.environment.is_walkable(next): actor.position = next
func _sync() -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	var now: float = Time.get_unix_time_from_system()
	for id in active.keys():
		var actor = active[id]
		if not is_instance_valid(actor) or actor.is_queued_for_deletion():
			active.erase(id)
			continue
		if actor.position.distance_to(host.hero.position)>DESPAWN_RADIUS:
			memory[id] = actor.hp
			_release(actor)
	if safe(host.hero.position): return
	var candidates: Array[Dictionary] = []
	for data in slots:
		if active.has(data.id) or data.pos.distance_to(host.hero.position)>SPAWN_RADIUS: continue
		if state!=null and float(state.wildlife_cooldowns.get(data.id,0))>now: continue
		candidates.append(data)
	candidates.sort_custom(func(a,b): return a.pos.distance_squared_to(host.hero.position)<b.pos.distance_squared_to(host.hero.position))
	var spawned: int = 0
	for data in candidates:
		if active.size()>=ACTIVE_LIMIT or pool.is_empty() or spawned>=4: break
		var actor: Node2D = pool.pop_back()
		epoch += 1
		var painted_data: Dictionary = data.duplicate()
		painted_data["pilot_art"] = true
		actor.setup(Difficulty.monster_data(painted_data,Region.REGION_ID))
		actor.chill_t = 0; actor.burn_t = 0; actor.chill_base_speed = actor.move_speed
		actor.attack_cooldown = 0; actor.windup_t = 0; actor.lunge_t = 0; actor.hit_flash = 0; actor.anim_t = 0
		actor.boss_phase = 1; actor.boss_attack_index = 0; actor.strike_special = false; actor.strike_damage_multiplier = 1
		actor.set_meta("spawn_epoch",epoch)
		actor.set_meta("ambient_slot",data.id)
		actor.set_meta("camp_home",data.pos)
		if memory.has(data.id): actor.hp = mini(actor.max_hp,int(memory[data.id]))
		actor.show()
		actor.set_process(true)
		host.monsters.append(actor)
		active[data.id] = actor
		spawned += 1
func _release(actor: Node2D) -> void:
	active.erase(actor.get_meta("ambient_slot"))
	host.monsters.erase(actor)
	if actor.has_meta("valedouro_burn"):
		var burn = actor.get_meta("valedouro_burn").get_ref()
		if is_instance_valid(burn): burn.cancel()
		actor.remove_meta("valedouro_burn")
	actor.hp = 0
	actor.burn_t = 0
	actor.hide()
	actor.set_process(false)
	pool.append(actor)
func defeated(actor: Node2D) -> void:
	var id: String = actor.get_meta("ambient_slot")
	memory.erase(id)
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state!=null:
		# Namespaced keys keep the existing save-v8 schema and animal cooldowns intact.
		state.wildlife_cooldowns[id] = Time.get_unix_time_from_system()+RESPAWN_SECONDS
		state.save_profile()
	_release(actor)
