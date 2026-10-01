extends Node
const Difficulty = preload("res://scripts/cartoon/cartoon_difficulty.gd")
const Demon = preload("res://scripts/cartoon/cartoon_elite_demon.gd")
const Water = preload("res://scripts/cartoon/cartoon_habitat_water.gd")
const Hub = preload("res://scripts/cartoon/cartoon_region_config.gd")
const RESPAWN_SECONDS: float = 600
const COUNT: int = 6
var host
var region_id: String
var tier: int
var slots: Array[Dictionary] = []
var active: Dictionary = {}
var elapsed: float = 0
var rescue_position: Vector2
func setup(owner_node) -> void:
	host = owner_node
	region_id = host.crafting_ui.region_id
	tier = int(region_id.substr(4,3))-1
	rescue_position = host.hero.position
	var region = host.wildlife.region if host.get("wildlife")!=null else (preload("res://scripts/cartoon/abyss/abyss_region_config.gd") if tier==7 else preload("res://scripts/cartoon/corrupted/corrupted_region_config.gd"))
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(region_id)+290929
	for i in range(COUNT):
		for attempt in range(100):
			var point: Vector2 = Vector2(rng.randf_range(0.12,0.88)*region.REGION_SIZE.x,rng.randf_range(0.16,0.86)*region.REGION_SIZE.y)
			if not host._hero_can_move(point) or Water.is_water(point,region_id): continue
			if point.distance_to(rescue_position)<950: continue
			if region_id==Hub.REGION_ID and Hub.in_authored_hub(point): continue
			var clear: bool = true
			var pois: Array = host.environment.pois if region_id==Hub.REGION_ID else host.pois
			for poi in pois:
				if point.distance_to(poi.get("pos",Vector2.ZERO))<650: clear = false
			for previous in slots:
				if point.distance_to(previous.pos)<1000: clear = false
			if not clear: continue
			slots.append({"id":region_id+"_DEMON_%d"%i,"pos":point,"variant":["ember","void","ruin"][i%3]})
			break
	_sync()
func blocked() -> bool:
	return get_tree().paused or host.get_node("HUD/GameLayout").is_blocked() or (host.get("interiors")!=null and host.interiors.active)
func _process(delta: float) -> void:
	if host==null or blocked(): return
	elapsed += delta
	if elapsed>=2:
		elapsed = 0
		_sync()
func _sync() -> void:
	var state = get_node("/root/CartoonPlayerState")
	for row in slots:
		if active.has(row.id): continue
		if float(state.demon_cooldowns.get(row.id,0))>Time.get_unix_time_from_system(): continue
		# Never respawn an elite on top of the player.
		if host.hero.position.distance_to(row.pos)<450: continue
		var actor = Demon.new()
		actor.director = self
		actor.slot_id = row.id
		actor.variant = row.variant
		actor.tier = tier
		actor.home = row.pos
		actor.setup({"elite":true,"level":clampi(Difficulty.region_level(region_id)+8,1,100),"kind":"void_general","name":{"ember":"Carrasco Rubro","void":"Devorador Abissal","ruin":"Sentinela da Ruína"}[row.variant],"hp":220+tier*105,"damage":24+tier*8,"speed":115+tier*4,"pos":row.pos,"scale":1.1})
		actor.hex_radius = 72+tier*2
		host.objects.add_child(actor)
		host.monsters.append(actor)
		active[row.id] = actor
func defeated(actor) -> void:
	var state = get_node("/root/CartoonPlayerState")
	active.erase(actor.slot_id)
	host.monsters.erase(actor)
	state.demon_cooldowns[actor.slot_id] = Time.get_unix_time_from_system()+RESPAWN_SECONDS
	host.player_gold += 35+tier*8
	state.gain_xp(80+tier*30+actor.level*10)
	state.save_profile()
	host._refresh_stats()
	host._show_toast("Demônio de elite derrotado • +%d XP • +%d ouro" % [80+tier*30+actor.level*10,35+tier*8])
	actor.queue_free()
func hit_player(amount: int, enemy_level: int) -> void:
	if host.hero.is_evading() or host.hero.death_t>0: return
	host.hero.trigger_hurt()
	host.player_hp = maxi(0,host.player_hp-host.hero.reduce_incoming_damage(amount,enemy_level))
	if host.player_hp<=0:
		host.hero.trigger_fall()
		host.player_hp = host.player_max_hp
		host.hero.position = rescue_position
		host._show_toast("Você foi resgatado após enfrentar um demônio de elite.")
	host._refresh_stats()
