extends SceneTree

const Layout = preload("res://scripts/cartoon/cartoon_game_layout.gd")
const Menu = preload("res://scenes/cartoon/CartoonMainMenu.tscn")
const SCENES: Array[String] = [
	"res://scenes/cartoon/ValedouroCartoonHub.tscn",
	"res://scenes/cartoon/ForestAncientCartoon.tscn",
	"res://scenes/cartoon/DesertEdravarCartoon.tscn",
	"res://scenes/cartoon/MarshDarkCartoon.tscn",
	"res://scenes/cartoon/FrostMountainsCartoon.tscn",
	"res://scenes/cartoon/CoastLostIslandsCartoon.tscn",
	"res://scenes/cartoon/CorruptedLandsCartoon.tscn",
	"res://scenes/cartoon/AbyssHeartCartoon.tscn"]

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	for i in range(4): await process_frame

func inside(control: Control) -> void:
	var bounds: Rect2 = root.get_visible_rect().grow(0.5)
	assert(bounds.encloses(control.get_global_rect()),"Clipped control: "+String(control.name)+" "+str(control.get_global_rect()))

func touch(p: Vector2, pressed: bool, index: int = 0) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.index = index
	event.pressed = pressed
	event.position = p
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	for path: String in SCENES:
		var scene = load(path).instantiate()
		root.add_child(scene)
		await settle()
		var layout = scene.get_node("HUD/GameLayout")
		for dimensions: Vector2i in [Vector2i(640,360),Vector2i(800,450),Vector2i(960,540),Vector2i(1200,540),Vector2i(1024,768)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			await settle()
			for control: Control in [scene.hud_status.panel,layout.quest_panel,layout.map_button,layout.pause_button,layout.attack_button,layout.interact_button,scene.zoom_controls.panel,scene.inventory_ui.toggle_button,scene.crafting_ui.toggle_button]:
				inside(control)
			assert(not layout.attack_button.get_global_rect().intersects(layout.interact_button.get_global_rect()))
			assert(not layout.map_button.get_global_rect().intersects(scene.inventory_ui.toggle_button.get_global_rect()))
			assert(not scene.hud_status.panel.get_global_rect().intersects(layout.quest_panel.get_global_rect()))
			inside(scene.hud_status.hp_bar)
			assert(scene.hud_status.panel.get_global_rect().encloses(scene.hud_status.xp_bar.get_global_rect()),"XP bar spills outside card")
			scene.inventory_ui.open_panel()
			await settle()
			inside(scene.inventory_ui.panel)
			var backdrop: Control = scene.inventory_ui.get_node("ModalBackdrop")
			assert(backdrop.visible and backdrop.get_global_rect().encloses(root.get_visible_rect()))
			assert(not layout.attack_button.visible and not scene.hud_status.visible)
			scene.crafting_ui._toggle()
			await settle()
			assert(not scene.inventory_ui.is_open() and scene.crafting_ui.is_open())
			inside(scene.crafting_ui.panel)
			scene._toggle_map()
			await settle()
			assert(scene.map_open and not scene.crafting_ui.is_open())
			inside(scene.map_overlay)
			inside(scene.map_overlay.get_node("CloseMapButton"))
			scene.map_overlay.get_node("CloseMapButton").pressed.emit()
			await settle()
			assert(not scene.map_open and layout.attack_button.visible)
			layout._toggle_quest()
			await settle()
			inside(layout.quest_panel)
			assert(scene.objective_label.max_lines_visible == 6)
			layout._toggle_quest()
		# A toolbar button overlaps the movement zone on a small landscape screen.
		# Verify real GUI routing, not a direct call to the joystick method.
		root.content_scale_size = Vector2i(640,360)
		root.size = Vector2i(640,360)
		await settle()
		var p: Vector2 = layout.map_button.get_global_rect().get_center()
		touch(p,true)
		touch(p,false)
		await settle()
		assert(scene.map_open and scene.joystick_id == -1,"UI press became a movement gesture")
		scene._toggle_map()
		await settle()
		var origin: Vector2 = Layout.movement_zone(scene).position+Vector2(40,80)
		touch(origin,true,3)
		assert(scene.joystick_id == 3)
		var drag: InputEventScreenDrag = InputEventScreenDrag.new()
		drag.index = 3
		drag.position = origin+Vector2(400,0)
		Input.parse_input_event(drag)
		Input.flush_buffered_events()
		assert(scene.joystick_vector.x > 0.9)
		touch(drag.position,false,3)
		assert(scene.joystick_id == -1 and scene.joystick_vector == Vector2.ZERO,"Finger release outside joystick left movement stuck")
		layout.open_pause()
		assert(paused and layout.pause_panel.visible)
		var old_position: Vector2 = scene.hero.position
		await settle()
		assert(scene.hero.position == old_position)
		inside(layout.pause_panel)
		layout.pause_panel.get_node("PauseContent/ResumeButton").pressed.emit()
		assert(not paused and not layout.pause_panel.visible)
		if path == SCENES[7]:
			scene._show_choice()
			await settle()
			inside(scene.choice_panel)
			var body: Node = scene.choice_panel.get_node("EndingChoiceContent")
			inside(body.get_node("ReturnToEarthButton"))
			inside(body.get_node("StayInElyndorButton"))
			scene.choice_panel.visible = false
		print("UI021_REGION_PASS ",path)
		scene.queue_free()
		await settle()
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(960,540)
	var menu = Menu.instantiate()
	root.add_child(menu)
	await settle()
	for dimensions: Vector2i in [Vector2i(640,360),Vector2i(800,450),Vector2i(960,540),Vector2i(1200,540),Vector2i(1024,768)]:
		root.content_scale_size = dimensions
		root.size = dimensions
		await settle()
		inside(menu.menu_panel)
		assert(not menu.ui.get_node("MenuTitle").get_global_rect().intersects(menu.ui.get_node("MenuSubtitle").get_global_rect()))
		menu._open_options()
		await settle()
		inside(menu.options_panel)
		inside(menu.delete_button)
		menu.options_panel.visible = false
		menu._show_confirmation("delete","Excluir o progresso salvo?")
		await settle()
		inside(menu.confirmation_panel)
		menu._cancel_confirmation()
	menu.queue_free()
	await settle()
	# Exercise the actual paused transition and campaign binding, not only styles.
	state.start_new_game()
	var hub = load(SCENES[0]).instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	var saved_position: Vector2 = Vector2(4321,3456)
	hub.hero.position = saved_position
	var game_layout = hub.get_node("HUD/GameLayout")
	game_layout.open_pause()
	game_layout._return_to_menu()
	await settle()
	assert(not paused and current_scene != null)
	assert(state.player_position == saved_position and state.has_campaign_save(),"Pause/menu transition lost campaign position")
	assert(not current_scene.continue_button.disabled)
	current_scene.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_ui_v021: PASS — 8 regions, 5 sizes, modals, touch routing, pause/save/resume, ending and menu")
	quit(0)
