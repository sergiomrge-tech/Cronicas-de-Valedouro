extends SceneTree
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Contracts = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Gate = preload("res://tests/cartoon_ui_v021.gd")
func _initialize() -> void:
	call_deferred("run")
func settle() -> void:
	for i in range(5): await process_frame
func reachable(interior, goal: Vector2) -> bool:
	var start: Vector2i = Vector2i(0,15)
	var todo: Array[Vector2i] = [start]
	var seen: Dictionary = {start:true}
	var cursor: int = 0
	while cursor < todo.size():
		var cell: Vector2i = todo[cursor]
		cursor += 1
		var p: Vector2 = Vector2(cell)*20
		if p.distance_to(goal)<95: return true
		for step: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+step
			if not seen.has(next) and interior.is_walkable(Vector2(next)*20):
				seen[next] = true
				todo.append(next)
	return false
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	var hub = HubScene.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	assert(hub.wildlife.slots.size()>=250)
	var original_story: String = hub.story_runtime.current_id
	for pair in [["tavern",Vector2(1580,855)],["forge",Vector2(720,850)],["guild",Vector2(760,1185)]]:
		hub.hero.position = Region.world_from_hub(pair[1])
		var outside: Vector2 = hub.hero.position
		hub._interact()
		await settle()
		assert(hub.interiors.active and hub.interiors.kind == pair[0],"Door did not enter "+pair[0])
		assert(hub.hero.get_parent() == hub.interiors.room_objects)
		assert(not hub.objects.visible and hub.interiors.visible)
		assert(not hub.interiors.is_walkable(Vector2(700,0)))
		for point in hub.interiors.points: assert(reachable(hub.interiors,point.pos),"Blocked service: "+point.label)
		hub.hero.position = Vector2(0,0)
		Input.action_press("move_right")
		await settle()
		Input.action_release("move_right")
		assert(hub.hero.position.x>0,"Movement failed inside building")
		state.save_profile()
		assert(state.player_position == outside,"Interior coordinates leaked into campaign save")
		state.load_profile()
		assert(state.player_position == outside)
		if pair[0] == "tavern":
			hub.player_hp = 7
			hub.hero.position = Vector2(-300,-80)
			hub._interact()
			assert(hub.player_hp == hub.player_max_hp)
		elif pair[0] == "forge":
			hub.hero.position = Vector2(-90,-20)
			hub._interact()
			assert(hub.crafting_ui.is_open())
			hub.crafting_ui.close_panel()
		else:
			hub.hero.position = Vector2(-320,-95)
			hub._interact()
			assert(hub.guild_board.is_open())
			for dimensions: Vector2i in [Vector2i(640,360),Vector2i(960,540),Vector2i(1024,768)]:
				root.content_scale_size = dimensions
				root.size = dimensions
				await settle()
				assert(root.get_visible_rect().grow(1).encloses(hub.guild_board.panel.get_global_rect()))
				assert(not hub.get_node("HUD/GameLayout").attack_button.visible)
				var button = hub.guild_board.list.get_child(0).find_child("GUILD_RABBITS",true,false)
				assert(button != null and button.get_global_rect().size.y>=44)
			hub.guild_board.close_panel()
		root.content_scale_size = Vector2i(960,540)
		root.size = Vector2i(960,540)
		hub.interiors.leave()
		assert(hub.hero.position == outside and hub.objects.visible)
		assert(hub.hero.get_parent() == hub.objects)
	assert(hub.story_runtime.current_id == original_story)
	assert(hub.story_runtime.try_location("LOC_VAL_GATE"))
	hub.hero.position = Region.world_from_hub(Vector2(760,1185))
	hub._interact()
	assert(hub.story_runtime.current_id == "Q_MS01_WOLVES" and hub.interiors.active)
	hub._toggle_map()
	assert(not hub.interiors.active)
	# Actual combat, materials, cooldown and contracts: no kill credit before acceptance.
	Contracts.register_hunt(state,"rabbit")
	assert(Contracts.accept(state,"GUILD_RABBITS"))
	assert(Contracts.accept(state,"GUILD_VARIETY"))
	assert(Contracts.accept(state,"GUILD_MEAT"))
	assert(not Contracts.accept(state,"GUILD_DEER"))
	assert(not Contracts.accept(state,"unknown"))
	assert(Contracts.progress(state,"GUILD_RABBITS")==0)
	hub.hero.position = Region.world_from_hub(Vector2(670,1710))
	hub.wildlife._sync()
	assert(hub.wildlife.active.size()>0 and hub.wildlife.active.size()<=40)
	var actor = null
	for candidate in hub.wildlife.active.values():
		if candidate.kind == "rabbit":
			actor = candidate
			break
	assert(actor != null)
	var slot_id: String = actor.slot_id
	hub.hero.position = actor.position+Vector2(0,35)
	var initial_distance: float = actor.position.distance_to(hub.hero.position)
	actor._process(0.1)
	assert(actor.position.distance_to(hub.hero.position)>initial_distance,"Rabbit did not flee")
	var meat: int = state.material_count("Carne de caça")
	for i in range(4):
		hub.hero._process(0.4)
		hub._attack()
	assert(actor.dead)
	assert(hub.story_runtime.wolf_kills == 0,"Wildlife advanced main story")
	assert(state.material_count("Carne de caça")==meat+1)
	assert(Contracts.progress(state,"GUILD_RABBITS")==1)
	assert(not hub.wildlife.active.has(slot_id))
	actor.take_damage(100)
	await process_frame
	assert(hub.get_node("HUD/GameLayout").contract_copy.text.contains("1/3"))
	assert(state.material_count("Carne de caça")==meat+1,"Duplicate corpse rewards")
	var boar = null
	for candidate in hub.wildlife.active.values():
		if candidate.kind == "boar":
			boar = candidate
			break
	assert(boar != null)
	hub.hero.position = boar.position+Vector2(0,35)
	boar.take_damage(1)
	var hp_before: int = hub.player_hp
	boar._process(0.1)
	assert(hub.player_hp<hp_before,"Provoked boar did not defend itself")
	hub.get_node("HUD/GameLayout").open_pause()
	var paused_position: Vector2 = boar.position
	boar._process(0.2)
	assert(boar.position == paused_position)
	hub.get_node("HUD/GameLayout").close_pause()
	state.save_profile()
	state.load_profile()
	assert(Contracts.status(state,"GUILD_RABBITS")=="active")
	assert(Contracts.progress(state,"GUILD_RABBITS")==1)
	hub.wildlife._sync()
	assert(not hub.wildlife.active.has(slot_id),"Early wildlife respawn after load")
	Contracts.register_hunt(state,"rabbit")
	Contracts.register_hunt(state,"rabbit")
	var gold: int = hub.player_gold
	assert(Contracts.claim(state,hub,"GUILD_RABBITS"))
	assert(hub.player_gold == gold+25)
	assert(not Contracts.claim(state,hub,"GUILD_RABBITS"),"Duplicate contract payout")
	assert(Contracts.accept(state,"GUILD_DEER"))
	state.materials["Carne de caça"] = 7
	assert(Contracts.claim(state,hub,"GUILD_MEAT"))
	assert(state.material_count("Carne de caça")==2)
	assert(not Contracts.claim(state,hub,"GUILD_MEAT"))
	state.materials["Osso de caça"] = 3
	state.materials["Couro do Vale"] = 3
	assert(state.craft(Region.REGION_ID,"weapon").ok)
	assert(state.attack_bonus()==2)
	assert(state.craft(Region.REGION_ID,"armor").ok)
	assert(state.defense_bonus()==1)
	# Existing field-contract saves migrate without losing progress.
	state.guild_contracts.erase("GUILD_WOLVES")
	state.scene_extras[state.DEFAULT_SCENE] = {"field_quest_active":true,"field_kills":2}
	hub._bind_campaign_save()
	assert(Contracts.progress(state,"GUILD_WOLVES")==2)
	Contracts.register_hunt(state,"wolf")
	assert(Contracts.claim(state,hub,"GUILD_WOLVES"))
	assert(not hub.field_quest_active)
	# Dead slots become available after the persisted timer expires.
	state.wildlife_cooldowns[slot_id] = 0
	hub.wildlife._sync()
	assert(hub.wildlife.active.has(slot_id))
	hub.hero.position = Vector2(1000,1000)
	hub.wildlife._sync()
	assert(hub.wildlife.active.size()<=40)
	hub.queue_free()
	await settle()
	# Regional population and clean scene teardown, independent of canonical monsters.
	for path in Gate.SCENES.slice(1,6):
		var region_scene = load(path).instantiate()
		root.add_child(region_scene)
		await settle()
		assert(region_scene.wildlife.slots.size()>=250)
		for slot in region_scene.wildlife.slots: assert(region_scene.wildlife.walkable(slot.pos),"Animal habitat on water")
		assert(region_scene.wildlife.active.size()>0 and region_scene.wildlife.active.size()<=40)
		region_scene.queue_free()
		await settle()
	state.reset_progress(true)
	var resumed = HubScene.instantiate()
	root.add_child(resumed)
	current_scene = resumed
	await settle()
	resumed.hero.position = Region.world_from_hub(Vector2(1580,855))
	var outside_saved: Vector2 = resumed.hero.position
	resumed.interiors.enter("tavern")
	resumed.get_node("HUD/GameLayout").open_pause()
	assert(paused)
	resumed.get_node("HUD/GameLayout")._return_to_menu()
	await settle()
	assert(not paused and state.player_position == outside_saved)
	assert(current_scene.scene_file_path == "res://scenes/cartoon/CartoonMainMenu.tscn")
	current_scene.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_living_world_v022: PASS — 3 interiors, reachable services, 7 contracts, hunting, cooldowns, save/load, crafting, 6 populated regions and mobile board")
	quit(0)
