extends SceneTree
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Layout = preload("res://scripts/cartoon/cartoon_game_layout.gd")
const SCENES = ["ValedouroCartoonHub","ForestAncientCartoon","DesertEdravarCartoon","MarshDarkCartoon","FrostMountainsCartoon","CoastLostIslandsCartoon","CorruptedLandsCartoon","AbyssHeartCartoon"]
var host
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(5): await process_frame
func target(offset: Vector2, boss: bool = false):
	var mob = Monster.new()
	mob.setup({"kind":"wolf","hp":100,"damage":7,"pos":host.hero.position+offset,"boss_id":"TEST_BOSS" if boss else ""})
	host.objects.add_child(mob)
	host.monsters.append(mob)
	mob.set_process(false)
	return mob
func clear_mobs() -> void:
	for mob in host.monsters:
		if is_instance_valid(mob): mob.queue_free()
	host.monsters.clear()
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	for scene_name in SCENES:
		host = load("res://scenes/cartoon/"+scene_name+".tscn").instantiate()
		root.add_child(host)
		current_scene = host
		await settle()
		host.set_process(false)
		host.hero.set_process(false)
		if host.get("wildlife") != null: host.wildlife.process_mode = Node.PROCESS_MODE_DISABLED
		clear_mobs()
		await settle()
		var origin: Vector2 = Vector2(4000,4000)
		host.hero.position = origin
		var mob = target(Vector2(40,0))
		var hp: int = host.player_hp
		host._update_monsters(0.01)
		assert(host.player_hp==hp and mob.windup_t>0,"Contact dealt damage before warning in "+scene_name)
		var stand: Vector2 = mob.position
		host._update_monsters(0.20)
		assert(host.player_hp==hp and mob.position==stand,"Enemy moved while preparing attack")
		host._update_monsters(0.30)
		assert(host.player_hp==hp-7,"Telegraphed attack failed to resolve in "+scene_name)
		host._update_monsters(0.10)
		assert(host.player_hp==hp-7,"Enemy ignored recovery")
		# Walking outside the committed area makes the attack miss.
		mob.attack_cooldown = 0
		mob.lunge_t = 0
		host._update_monsters(0.01)
		host.hero.position = origin-Vector2(100,0)
		host._update_monsters(0.50)
		assert(host.player_hp==hp-7,"Enemy hit outside its warning circle")
		# Dodge covers the whole distance once, with a short evasion window.
		host.hero.position = origin
		host.hero.move_vector = Vector2.LEFT
		host.hero.dodge_cooldown = 0
		assert(host.hero.try_dodge(host))
		assert(not host.hero.try_dodge(host) and not host.hero.cast_spell(host))
		mob.position = origin+Vector2(40,0)
		mob.windup_t = 0.01
		host._update_monsters(0.02)
		assert(host.player_hp==hp-7,"Attack hit during evasion window")
		if host.get("wildlife") != null:
			host.wildlife.damage_player(8)
			assert(host.player_hp==hp-7,"Boar contact bypassed evasion window")
		host.hero._process(0.10)
		assert(host.hero.is_evading())
		host.hero._process(0.07)
		assert(not host.hero.is_evading(),"Evasion window lasted the entire dodge")
		host.hero._process(0.10)
		assert(is_equal_approx(host.hero.position.x,origin.x-120) and host.hero.dodge_t==0)
		assert(not host.hero.try_dodge(host),"Dodge ignored cooldown")
		host.hero._process(2.3)
		# Bosses give a longer warning; pause and modals freeze the committed attack.
		clear_mobs()
		await settle()
		host.hero.position = origin
		mob = target(Vector2(40,0),true)
		host._update_monsters(0.01)
		assert(mob.windup_t>=0.8 and mob.strike_radius>=94)
		var layout = host.get_node("HUD/GameLayout")
		var wait: float = mob.windup_t
		layout.open_pause()
		host._update_monsters(2.0)
		assert(mob.windup_t==wait and not host.hero.try_dodge(host))
		layout.close_pause()
		host.inventory_ui.open_panel()
		host._update_monsters(2.0)
		assert(mob.windup_t==wait and not host.hero.try_dodge(host))
		host.inventory_ui.close_panel()
		# Cancel a dodge when opening a modal, without moving behind it.
		host.hero.move_vector = Vector2.LEFT
		assert(host.hero.try_dodge(host))
		var before: Vector2 = host.hero.position
		host.inventory_ui.open_panel()
		host.hero._process(0.2)
		assert(host.hero.position==before and host.hero.dodge_t==0)
		host.inventory_ui.close_panel()
		# An enemy defeated during its warning cannot finish the hit.
		mob.hp = 0
		host._update_monsters(1.0)
		assert(host.player_hp==hp-7 and mob.windup_t==0)
		# Death/rescue cannot leave an active dodge.
		host.hero.dodge_cooldown = 0
		assert(host.hero.try_dodge(host))
		host.hero.trigger_fall()
		host.hero._process(0.05)
		assert(host.hero.dodge_t==0 and not host.hero.try_dodge(host))
		host.hero.death_t = 0
		for dimensions: Vector2i in [Vector2i(640,360),Vector2i(800,450),Vector2i(960,540),Vector2i(1024,768)]:
			root.size = dimensions
			root.content_scale_size = dimensions
			await settle()
			layout._layout()
			var rect: Rect2 = layout.dodge_button.get_global_rect()
			assert(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(rect) and rect.size.y>=44)
			for other in layout.spell_buttons+[layout.attack_button,layout.interact_button,layout.map_button,layout.pause_button,layout.quest_panel,host.zoom_controls.panel,host.inventory_ui.toggle_button,host.crafting_ui.toggle_button]:
				if other.is_visible_in_tree(): assert(not rect.intersects(other.get_global_rect()),"Dodge "+str(rect)+" overlaps "+String(other.name)+" "+str(other.get_global_rect())+" at "+str(dimensions))
			assert(not Layout.can_start_movement(host,rect.get_center()))
			if dimensions.y==360:
				for message in [host.toast_label,host.poi_label]:
					for control in layout.spell_buttons+[layout.quest_panel,layout.dodge_button,layout.map_button,layout.pause_button]:
						assert(not message.get_global_rect().intersects(control.get_global_rect()),"Compact combat message overlaps HUD")
				assert(not host.toast_label.get_global_rect().intersects(host.poi_label.get_global_rect()))
			layout._toggle_quest()
			await settle()
			for button in layout.spell_buttons+[layout.dodge_button]:
				assert(not button.visible or not button.get_global_rect().intersects(layout.quest_panel.get_global_rect()))
			layout._toggle_quest()
		# Exercise native GUI touch routing, including touch-to-mouse emulation.
		root.size = Vector2i(640,360)
		root.content_scale_size = root.size
		host.hero.dodge_cooldown = 0
		await settle()
		var press = InputEventScreenTouch.new()
		press.index = 11
		press.position = layout.dodge_button.get_global_rect().get_center()
		press.pressed = true
		Input.parse_input_event(press)
		Input.flush_buffered_events()
		var release = InputEventScreenTouch.new()
		release.index = 11
		release.position = press.position
		release.pressed = false
		Input.parse_input_event(release)
		Input.flush_buffered_events()
		assert(host.hero.dodge_t>0 and host.joystick_id==-1,"Dodge touch failed or became movement input")
		host.hero.dodge_t = 0
		if scene_name==SCENES[0]:
			# Existing forge collision stops a fast dodge without tunnelling.
			host.hero.position = Region.world_from_hub(Vector2(600,690))
			assert(host._hero_can_move(host.hero.position))
			host.hero.move_vector = Vector2.RIGHT
			host.hero.dodge_cooldown = 0
			var wall_start: Vector2 = host.hero.position
			assert(host.hero.try_dodge(host))
			host.hero._process(0.3)
			assert(host._hero_can_move(host.hero.position) and host.hero.position.x<wall_start.x+120,"Dodge crossed forge wall")
			host.interiors.active = true
			host.hero.dodge_cooldown = 0
			assert(not host.hero.try_dodge(host))
			host.interiors.active = false
		host.queue_free()
		await settle()
	state.reset_progress(true)
	print("cartoon_reactive_v026: PASS — eight regions, warning, committed area, dodge, evasion window, walls, cooldown, pause, modals, dead actors, rescue and mobile HUD")
	quit()
