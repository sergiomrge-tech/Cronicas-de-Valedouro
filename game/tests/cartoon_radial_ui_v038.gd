extends SceneTree
const Layout = preload("res://scripts/cartoon/cartoon_game_layout.gd")
const SCENES = ["ValedouroCartoonHub","ForestAncientCartoon","DesertEdravarCartoon","MarshDarkCartoon","FrostMountainsCartoon","CoastLostIslandsCartoon","CorruptedLandsCartoon","AbyssHeartCartoon"]
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	state.player_level = 25
	for scene in SCENES:
		var host = load("res://scenes/cartoon/%s.tscn" % scene).instantiate()
		root.add_child(host)
		current_scene = host
		await settle()
		host.set_process(false)
		host.hero.set_process(false)
		var layout = host.get_node("HUD/GameLayout")
		layout.demon_director.set_process(false)
		for mob in host.monsters: mob.set_process(false)
		for dimensions in [Vector2i(640,360),Vector2i(800,450),Vector2i(960,540),Vector2i(1200,540),Vector2i(1024,768)]:
			root.size = dimensions
			root.content_scale_size = dimensions
			await settle()
			layout._process(0)
			var controls: Array = layout.spell_buttons+[layout.attack_button,layout.heal_button,layout.dodge_button,layout.interact_button,layout.map_button,layout.mission_button,layout.pause_button,layout.minimap,layout.quest_panel,host.inventory_ui.toggle_button,host.hud_status.panel]
			for a in controls:
				assert(a.is_visible_in_tree())
				assert(root.get_visible_rect().encloses(a.get_global_rect()),"Off-screen: "+str(a.name))
				for b in controls:
					if a!=b: assert(not a.get_global_rect().intersects(b.get_global_rect()),"Radial controls overlap: %s/%s at %s"%[a.name,b.name,dimensions])
			for button in layout.spell_buttons+[layout.attack_button,layout.heal_button,layout.dodge_button,layout.mission_button,layout.map_button,host.inventory_ui.toggle_button]:
				assert(button.get_global_rect().size.x>=44 and button.get_global_rect().size.y>=44)
				assert(not Layout.can_start_movement(host,button.get_global_rect().get_center()))
			assert(layout.minimap.world_view.world_2d==host.get_world_2d())
			host.inventory_ui.open_panel()
			await settle()
			for button in [host.inventory_ui.weapon_slot,host.inventory_ui.armor_slot]+host.inventory_ui.piece_buttons.values():
				assert(button.get_global_rect().size.x>=44 and button.get_global_rect().size.y>=44,"Equipment touch target too small")
			assert(not host.inventory_ui.detail_meta.get_global_rect().intersects(host.inventory_ui.detail_compare.get_global_rect()),"Item details overlap")
			host.inventory_ui.close_panel()
			layout.open_pause()
			await settle()
			assert(host.zoom_controls.panel.is_visible_in_tree() and host.crafting_ui.toggle_button.is_visible_in_tree())
			assert(layout.pause_panel.get_global_rect().encloses(host.zoom_controls.panel.get_global_rect()))
			host.crafting_ui.toggle_button.pressed.emit()
			await settle()
			assert(not paused and not layout.pause_panel.visible and host.crafting_ui.is_open(),"Opening forge must leave pause")
			host.crafting_ui.close_panel()
		host.queue_free()
		await settle()
	state.reset_progress(true)
	print("cartoon_radial_ui_v038: PASS — eight regions, five sizes, independent touch targets, real minimap, inventory and pause/forge routing")
	quit()
