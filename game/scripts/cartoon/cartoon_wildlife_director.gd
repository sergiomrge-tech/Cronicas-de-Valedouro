extends Node
const HabitatWater = preload("res://scripts/cartoon/cartoon_habitat_water.gd")
const Animal = preload("res://scripts/cartoon/cartoon_wildlife_animal.gd")
const Contracts = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")
const HubRegion = preload("res://scripts/cartoon/cartoon_region_config.gd")
const RESPAWN_SECONDS: float = 180.0
const ACTIVE_LIMIT: int = 40
var host
var region
var region_id: String
var slots: Array[Dictionary] = []
var active: Dictionary = {}
var elapsed: float = 0.0
var rescue_position: Vector2
func setup(owner_node, config) -> void:
	host = owner_node
	rescue_position = owner_node.hero.position
	region = config
	region_id = region.REGION_ID
	_build_habitats()
	_sync()
func walkable(p: Vector2) -> bool:
	if region_id == HubRegion.REGION_ID: return host.environment.is_walkable(p) and not HubRegion.ROYAL_GROUNDS.has_point(p)
	return region.in_region(p,100) and not HabitatWater.is_water(p,region_id)
func _add_pack(center: Vector2, index: int, species: Array, size_v: int = 3) -> void:
	for j in range(size_v):
		var p: Vector2 = center+Vector2(float(j-1)*85,float(j%2)*60)
		if not walkable(p): continue
		if region_id == HubRegion.REGION_ID and HubRegion.in_authored_hub(p) and HubRegion.hub_from_world(p).y < 1610: continue
		slots.append({"id":region_id+"_%d_%d" % [index,j],"kind":species[(index+j)%species.size()],"pos":p})
func _build_habitats() -> void:
	# Reproducible packs dispersed over exploration land; no animals inside city.
	var species: Array = ["rabbit","deer","boar"]
	if "DESERTO" in region_id: species = ["rabbit"]
	elif "PANTANOS" in region_id: species = ["boar","rabbit"]
	elif "MONTANHAS" in region_id: species = ["deer","rabbit"]
	elif "COSTAS" in region_id: species = ["rabbit","boar"]
	# Corrupted/abyssal regions keep their existing supernatural encounters.
	if "CORROMPIDAS" in region_id or "ABISSAL" in region_id: return
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 220930+hash(region_id)
	var world: Vector2 = region.REGION_SIZE
	for y in range(10):
		for x in range(10):
			var center: Vector2 = Vector2((x+0.5)*world.x/10,(y+0.5)*world.y/10)
			center += Vector2(rng.randf_range(-150,150),rng.randf_range(-150,150))
			_add_pack(center,y*10+x,species)
	if region_id == HubRegion.REGION_ID:
		for i in range(8):
			var local: Vector2 = Vector2(670+float(i%4)*280,1710+float(i/4)*430)
			_add_pack(HubRegion.world_from_hub(local),100+i,["rabbit","deer","boar"],2)
	else:
		var approaches: Array[Vector2] = [Vector2(380,240),Vector2(600,-180),Vector2(-430,280),Vector2(-500,-400)]
		for i in range(approaches.size()): _add_pack(host.hero.position+approaches[i],101+i,species)
func blocked() -> bool:
	if host == null or host.hero == null: return true
	if host.get("interiors") != null and host.interiors.active: return true
	var layout = host.get_node_or_null("HUD/GameLayout")
	return layout != null and layout.is_blocked()
func _process(delta: float) -> void:
	if host == null or blocked(): return
	elapsed += delta
	if elapsed >= 0.5:
		elapsed = 0
		_sync()
func _sync() -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	var now: float = Time.get_unix_time_from_system()
	for id in active.keys():
		var animal = active[id]
		if not is_instance_valid(animal): active.erase(id)
		elif animal.position.distance_to(host.hero.position)>1900:
			animal.queue_free()
			active.erase(id)
	for data in slots:
		if active.size() >= ACTIVE_LIMIT: break
		if active.has(data.id) or data.pos.distance_to(host.hero.position)>1500: continue
		if state != null and float(state.wildlife_cooldowns.get(data.id,0))>now: continue
		var animal = Animal.new()
		animal.name = "Wildlife_"+data.id
		animal.setup(self,data)
		host.objects.add_child(animal)
		active[data.id] = animal
func attack() -> bool:
	if blocked(): return false
	var nearest = null
	var distance: float = host.hero.combat_range(105)
	for animal in active.values():
		if not is_instance_valid(animal) or animal.dead: continue
		var d: float = animal.position.distance_to(host.hero.position)
		if d < distance:
			distance = d
			nearest = animal
	if nearest == null: return false
	var monster = host._nearest_monster(host.hero.combat_range(105))
	if monster != null and monster.position.distance_to(host.hero.position) <= distance: return false
	host.hero.trigger_attack()
	if host.hero.spell_mode: host.hero.launch_magic(host,nearest,18,self)
	elif host.hero.bow_equipped: host.hero.launch_arrow(host,nearest,18,self)
	else: nearest.take_damage(host.hero.hunting_damage(18))
	return true
func harvest(animal) -> void:
	# A dead actor is removed immediately; its slot cooldown survives scene/load.
	active.erase(animal.slot_id)
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		state.wildlife_cooldowns[animal.slot_id] = Time.get_unix_time_from_system()+RESPAWN_SECONDS
		state.materials["Carne de caça"] = state.material_count("Carne de caça")+1
		state.materials["Osso de caça"] = state.material_count("Osso de caça")+1
		if animal.kind != "rabbit": state.materials["Couro do Vale"] = state.material_count("Couro do Vale")+(2 if animal.kind == "boar" else 1)
		Contracts.register_hunt(state,animal.kind)
		state.gain_xp(7 if animal.kind == "rabbit" else 12)
		state.save_profile()
	host._show_toast("Caça recolhida: carne, osso"+(" e couro." if animal.kind != "rabbit" else "."))
	host._refresh_stats()
	animal.queue_free()

func damage_player(amount: int) -> void:
	if host.hero.is_evading(): return
	host.hero.trigger_hurt()
	host.player_hp = maxi(0,host.player_hp-host.hero.reduce_incoming_damage(amount))
	if host.player_hp <= 0:
		host.hero.trigger_fall()
		host.player_hp = host.player_max_hp
		host.hero.position = HubRegion.world_from_hub(Vector2(1150,970)) if region_id == HubRegion.REGION_ID else rescue_position
		host._show_toast("Você foi resgatado após o encontro com um javali.")
	host._refresh_stats()
