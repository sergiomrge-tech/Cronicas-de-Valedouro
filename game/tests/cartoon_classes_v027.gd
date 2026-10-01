extends SceneTree
const Classes = preload("res://scripts/cartoon/cartoon_class_catalog.gd")
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(6): await process_frame
func touch(point: Vector2, pressed: bool, index: int = 12) -> void:
	var event = InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()
func inside(control: Control) -> void:
	assert(root.get_visible_rect().grow(0.5).encloses(control.get_global_rect()),"Clipped class control: "+String(control.name)+" "+str(control.get_global_rect()))
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	assert(state.active_class=="warrior" and state.available_skill_points()==1)
	assert(state.upgrade_skill("blade") and state.available_skill_points()==0)
	assert(not state.upgrade_skill("blade") and not state.upgrade_skill("power"))
	assert(not state.set_class("invalid") and state.set_class("mage"))
	assert(state.skill_rank("blade")==0 and state.skill_rank("blade",false)==1)
	assert(not state.upgrade_skill("power"),"Class switching manufactured a skill point")
	state.gain_xp(state.xp_to_next())
	assert(state.player_level==2 and state.available_skill_points()==1)
	assert(state.upgrade_skill("power"))
	assert(not state.upgrade_skill("power"),"Rank ignored level gate")
	assert(state.refund_class_skills()==1 and state.refund_class_skills()==0)
	assert(state.available_skill_points()==1 and state.skill_rank("blade",false)==1)
	state.save_profile()
	state.active_class = "hunter"
	state.skill_ranks.clear()
	state.load_profile()
	assert(state.active_class=="mage" and state.skill_rank("blade",false)==1 and state.available_skill_points()==1)
	# Legacy saves keep campaign, equipment, level and retroactive points.
	var file = FileAccess.open(state.SAVE_PATH,FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	data.erase("active_class")
	data.erase("skill_ranks")
	data.version = 3
	data.player_level = 20
	data.player_gold = 321
	file = FileAccess.open(state.SAVE_PATH,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	state.load_profile()
	assert(state.active_class=="warrior" and state.available_skill_points()==20 and state.player_gold==321)
	state._normalize_class_progress({"blade":999,"guard":-8,"power":999,"reach":"bad","unknown":999})
	assert(state.skill_rank("blade",false)<=Classes.MAX_RANK and state.available_skill_points()>=0 and not state.skill_ranks.has("unknown"))
	state.player_level = 1
	state._normalize_class_progress({"blade":10,"guard":10,"power":10})
	assert(state.available_skill_points()==0 and state.skill_rank("blade",false)==1 and state.skill_rank("guard",false)==0)
	state.reset_progress(true)
	var hub = HubScene.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	hub.hero.set_process(false)
	hub.wildlife.process_mode = Node.PROCESS_MODE_DISABLED
	for animal in hub.wildlife.active.values(): animal.queue_free()
	hub.wildlife.active.clear()
	for mob in hub.monsters: mob.queue_free()
	hub.monsters.clear()
	await settle()
	# Model damage and cooldowns through real hero and projectile entry points.
	hub.hero.position = Vector2(4000,4000)
	state.player_level = 100
	state.skill_ranks = {"blade":10,"guard":10,"footwork":10,"power":10,"focus":10,"elements":10,"hunt":10,"agility":10,"reach":10}
	assert(state.available_skill_points()==10)
	assert(hub.hero.attack_damage(100)==140 and hub.hero.reduce_incoming_damage(100)==80)
	assert(hub.hero.try_dodge(hub) and is_equal_approx(hub.hero.dodge_cooldown,1.6))
	hub.hero.dodge_t = 0
	hub.hero.dodge_cooldown = 0
	hub.hero.spell_cooldowns[hub.hero.spell_index] = 1.1
	hub.player_hp = 73
	var gold: int = hub.player_gold
	assert(state.set_class("mage"))
	assert(hub.player_hp==73 and hub.player_gold==gold and is_equal_approx(hub.hero.spell_cooldown_remaining(),1.1))
	assert(hub.hero.attack_damage(100)==100 and hub.hero.magic_damage(100)==140)
	assert(hub.hero.reduce_incoming_damage(100)==100)
	var mob = Monster.new()
	mob.setup({"kind":"wolf","hp":100,"pos":hub.hero.position+Vector2(190,0)})
	hub.objects.add_child(mob)
	hub.monsters.append(mob)
	mob.set_process(false)
	hub.hero.spell_index = 1
	hub.hero.spell_cooldowns[hub.hero.spell_index] = 0
	assert(hub.hero.cast_spell(hub) and is_equal_approx(hub.hero.spell_cooldown_remaining(),2.2))
	var shot = get_nodes_in_group("cartoon_spell_projectiles")[0]
	shot.set_process(false)
	assert(shot.damage==25 and is_equal_approx(shot.chill_duration,3.5) and is_equal_approx(shot.echo_radius,160))
	assert(state.set_class("hunter"))
	shot._process(0.5)
	assert(mob.hp==75 and is_equal_approx(mob.chill_t,3.5),"Class change rewrote the projectile snapshot")
	hub.hero.spell_mode = true
	assert(hub.hero.combat_range(105)==260)
	hub.hero.spell_mode = false
	assert(hub.hero.hunting_damage(100)==160 and hub.hero.attack_damage(100)==100)
	assert(hub.hero.try_dodge(hub) and hub.hero.dodge_distance==160)
	hub.hero._process(0.25)
	assert(is_equal_approx(hub.hero.position.x,4160))
	# Native touch opens the modal from the portrait. Combat freezes behind it.
	var layout = hub.get_node("HUD/GameLayout")
	var ui = layout.class_ui
	for dimensions: Vector2i in [Vector2i(640,360),Vector2i(800,450),Vector2i(960,540),Vector2i(1024,768)]:
		root.size = dimensions
		root.content_scale_size = dimensions
		await settle()
		var portrait = hub.hud_status.hero_button
		inside(portrait)
		touch(portrait.get_global_rect().get_center(),true)
		touch(portrait.get_global_rect().get_center(),false)
		await settle()
		assert(ui.is_open() and layout.is_blocked() and hub.joystick_id==-1)
		inside(ui.panel)
		inside(ui.close_button)
		inside(ui.classes_tab)
		inside(ui.skills_tab)
		inside(ui.refund_button)
		assert(not ui.scroll.get_global_rect().intersects(ui.footer.get_global_rect()))
		assert(not hub.hero.try_dodge(hub) and not hub.hero.cast_spell(hub))
		var hp: int = hub.player_hp
		mob.position = hub.hero.position+Vector2(40,0)
		hub._update_monsters(1.0)
		assert(hub.player_hp==hp)
		ui.show_tab("skills")
		await settle()
		assert(ui.rows.get_child_count()==3)
		assert(ui.rows.size.x<=ui.scroll.size.x+0.5,"Skill cards overflow mobile viewport")
		var button = ui.rows.get_child(0).find_child("ActionButton",true,false)
		assert(button.size.y>=44 and button.get_global_rect().end.x<=ui.panel.get_global_rect().end.x)
		ui.close_button.pressed.emit()
		assert(not ui.is_open())
		ui.show_tab("classes")
	ui.open_panel()
	ui._switch("warrior")
	assert(state.active_class=="warrior" and state.skill_rank("blade",false)==10)
	ui._refund()
	assert(state.skill_rank("blade",false)==0 and state.available_skill_points()==40)
	ui._refund()
	assert(state.available_skill_points()==40)
	ui.close_panel()
	hub.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_classes_v027: PASS — class switching, levels, points, rank gates, refunds, legacy saves, normalization, combat bonuses, snapshots, native touch and responsive modal")
	quit()
