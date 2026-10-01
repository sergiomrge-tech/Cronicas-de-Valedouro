extends SceneTree
const Difficulty = preload("res://scripts/cartoon/cartoon_difficulty.gd")
const SCENES = ["ValedouroCartoonHub","ForestAncientCartoon","DesertEdravarCartoon","MarshDarkCartoon","FrostMountainsCartoon","CoastLostIslandsCartoon","CorruptedLandsCartoon","AbyssHeartCartoon"]
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func total_xp(state) -> int:
	var total: int = state.player_xp
	for level in range(1,state.player_level): total += state.xp_to_next(level)
	return total
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	assert(state.xp_to_next(1)==188 and state.xp_to_next(10)==1520 and state.xp_to_next(50)==23120)
	assert(not state.gain_xp(10).leveled_up)
	var data = Difficulty.monster_data({"hp":50,"damage":10,"speed":100,"story_tag":"story_wolf"},"REG_001_BERCO_VALEDOURO")
	assert(data.hp==80 and data.damage==14 and data.speed==108 and data.story_tag=="story_wolf")
	var total: int = 0
	var old_max: int = state.player_max_hp
	for name in SCENES:
		var host = load("res://scenes/cartoon/"+name+".tscn").instantiate()
		root.add_child(host)
		current_scene = host
		await settle()
		host.set_process(false)
		var layout = host.get_node("HUD/GameLayout")
		var director = layout.demon_director
		director.set_process(false)
		assert(director.slots.size()==6 and director.active.size()==6,"Missing demons in "+name)
		assert(state.player_level==1 and state.player_xp==10 and state.player_max_hp==old_max,"Region travel awarded free progression")
		for demon in director.active.values():
			assert(host._hero_can_move(demon.home) and demon.home.distance_to(director.rescue_position)>950)
			assert(demon.max_hp>=220 and demon.contact_damage>=24)
			demon.set_process(false)
		total += director.active.size()
		var actor = director.active.values()[0]
		var origin: Vector2 = actor.home
		host.hero.position = origin+Vector2(150,0)
		actor.hex_cooldown = 0
		var hp: int = host.player_hp
		actor._process(0.01)
		assert(actor.hex_t>0 and host.player_hp==hp,"Elite hit before area warning")
		host.hero.position += Vector2(150,0)
		actor._process(1.05)
		assert(host.player_hp==hp,"Elite hex followed player instead of locked target")
		actor.hex_cooldown = 0
		actor._process(0.01)
		actor._process(1.05)
		assert(host.player_hp<hp or host.hero.death_t>0,"Elite warning did not resolve")
		host.hero.death_t = 0
		host.player_hp = host.player_max_hp
		actor.hex_cooldown = 0
		actor._process(0.01)
		var evasion_hp: int = host.player_hp
		host.hero.dodge_cooldown = 0
		assert(host.hero.try_dodge(host))
		actor._process(1.05)
		assert(host.player_hp==evasion_hp,"Elite hex ignored dodge invulnerability")
		host.hero.dodge_t = 0
		actor.hex_cooldown = 0
		host.inventory_ui.open_panel()
		actor._process(1)
		assert(actor.hex_t==0,"Elite attacked through modal")
		host.inventory_ui.close_panel()
		actor.hp -= 1
		host.hero.position = actor.home+Vector2(800,0)
		actor._process(5.1)
		assert(actor.hp==actor.max_hp,"Disengaged elite never recovered")
		host.hero.position = actor.position+Vector2(85,0)
		host.hero.melee_cooldown = 0
		host._attack()
		var melee_hp: int = actor.hp
		host._attack()
		assert(actor.hp==melee_hp and host.hero.melee_cooldown>0,"Repeated input bypassed melee recovery")
		var xp: int = total_xp(state)
		var gold: int = host.player_gold
		var id: String = actor.slot_id
		assert(host._damage_monster(actor,99999))
		assert(total_xp(state)==xp+80+director.tier*30+actor.level*10 and host.player_gold==gold+35+director.tier*8,"Wrong elite rewards in "+name)
		assert(not host._damage_monster(actor,99999) and not director.active.has(id))
		assert(state.demon_cooldowns.has(id))
		state.load_profile()
		assert(state.demon_cooldowns.has(id))
		director._sync()
		assert(not director.active.has(id),"Reload respawned defeated demon early")
		# Reset stats between region trials; existing campaigns retain earned levels.
		host.queue_free()
		await settle()
		state.player_level = 1
		state.player_xp = 10
		state.player_max_hp = old_max
		state.player_hp = old_max
		state.player_position = Vector2.ZERO
	assert(total==48)
	state.reset_progress(true)
	print("cartoon_challenge_v029: PASS — 48 elites, warning/miss/impact/modal, rewards, cooldown saves, harder XP and no free travel levels")
	quit()
