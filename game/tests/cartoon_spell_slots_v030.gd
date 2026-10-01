extends SceneTree
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
const Layout = preload("res://scripts/cartoon/cartoon_game_layout.gd")
const SCENES = ["ValedouroCartoonHub","ForestAncientCartoon","DesertEdravarCartoon","MarshDarkCartoon","FrostMountainsCartoon","CoastLostIslandsCartoon","CorruptedLandsCartoon","AbyssHeartCartoon"]
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func touch(button: Button, index: int) -> void:
	var event = InputEventScreenTouch.new()
	event.index = index
	event.position = button.get_global_rect().get_center()
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	event = InputEventScreenTouch.new()
	event.index = index
	event.position = button.get_global_rect().get_center()
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await settle()
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	for scene in SCENES:
		root.size = Vector2i(640,360)
		root.content_scale_size = root.size
		var host = load("res://scenes/cartoon/%s.tscn" % scene).instantiate()
		root.add_child(host)
		current_scene = host
		await settle()
		host.set_process(false)
		host.hero.set_process(false)
		var layout = host.get_node("HUD/GameLayout")
		layout.demon_director.set_process(false)
		for mob in host.monsters:
			mob.set_process(false)
			mob.position = Vector2(-9000,-9000)
		if host.get("wildlife")!=null:
			host.wildlife.set_process(false)
			for a in host.wildlife.active.values():
				a.set_process(false)
				a.position = Vector2(-9000,-9000)
		host.hero.position = Vector2(2000,2000)
		var target = Monster.new()
		target.setup({"kind":"wolf","hp":500,"level":1,"pos":host.hero.position+Vector2(140,0)})
		host.objects.add_child(target)
		host.monsters.append(target)
		target.set_process(false)
		assert(layout.spell_buttons.size()==3)
		layout._process(0)
		for i in range(3):
			assert(layout.spell_buttons[i].visible == state.spell_unlocked(i))
			if not state.spell_unlocked(i):
				assert(not host.hero.cast_spell(host,i),"Locked spell cast before level requirement")
		# Independent cooldown regression is still verified after all three unlock.
		state.player_level = 25
		layout._process(0)
		for i in range(3):
			assert(layout.spell_buttons[i].visible and not layout.spell_buttons[i].disabled)
			await touch(layout.spell_buttons[i],10+i)
			assert(host.hero.spell_cooldowns[i]>0,"Touch did not cast slot %d in %s" % [i,scene])
			for next in range(i+1,3): assert(host.hero.spell_cooldowns[next]==0 and not layout.spell_buttons[next].disabled)
			assert(host.joystick_id==-1)
		var kinds: Array = []
		for shot in get_nodes_in_group("cartoon_spell_projectiles"):
			kinds.append(shot.spell_kind)
			shot.set_process(false)
		assert(kinds.size()==3 and "ember" in kinds and "frost" in kinds and "arcane" in kinds)
		for i in range(3): assert(not host.hero.cast_spell(host,i))
		assert(not host.hero.cast_spell(host,9))
		host.hero.spell_cooldowns[0] = 0.1
		host.hero._process(0.2)
		layout._process(0)
		assert(host.hero.spell_cooldowns[0]==0 and host.hero.spell_cooldowns[1]>0 and host.hero.spell_cooldowns[2]>0)
		assert(not layout.spell_buttons[0].disabled and layout.spell_buttons[1].disabled and layout.spell_buttons[2].disabled)
		assert(host.hero.cast_spell(host,0),"Ready Brasa blocked by other spell cooldowns")
		for shot in get_nodes_in_group("cartoon_spell_projectiles"): shot.queue_free()
		await settle()
		for dimensions: Vector2i in [Vector2i(640,360),Vector2i(800,450),Vector2i(960,540),Vector2i(1280,720)]:
			root.size = dimensions
			root.content_scale_size = dimensions
			await settle()
			layout._layout()
			for button in layout.spell_buttons:
				var rect: Rect2 = button.get_global_rect()
				assert(button.visible and rect.size.x>=44 and rect.size.y>=44)
				assert(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(rect))
				for other in layout.spell_buttons+[layout.quest_panel,layout.attack_button,layout.interact_button,layout.dodge_button,layout.map_button,layout.pause_button,host.zoom_controls.panel,host.inventory_ui.toggle_button,host.crafting_ui.toggle_button,host.poi_label,host.toast_label]:
					if other!=button: assert(not rect.intersects(other.get_global_rect()),"Spell overlaps %s in %s" % [other.name,str(dimensions)])
				assert(not Layout.can_start_movement(host,rect.get_center()))
		host.hero.spell_cooldowns.fill(0.0)
		layout.open_pause()
		for i in range(3): assert(not host.hero.cast_spell(host,i) and host.hero.spell_cooldowns[i]==0)
		layout.close_pause()
		layout.mission_ui.open_panel()
		for i in range(3): assert(not host.hero.cast_spell(host,i))
		layout.mission_ui.close_panel()
		host.hero.death_t = 0.5
		for i in range(3): assert(not host.hero.cast_spell(host,i))
		host.hero.death_t = 0
		host.hero.dodge_t = 0.1
		for i in range(3): assert(not host.hero.cast_spell(host,i))
		host.hero.dodge_t = 0
		host.queue_free()
		await settle()
	state.reset_progress(true)
	print("cartoon_spell_slots_v030: PASS — 3 native touch buttons, independent cooldowns, projectile kinds, repeat guard, pause/journal/death/dodge, 4 sizes in 8 regions")
	quit()
