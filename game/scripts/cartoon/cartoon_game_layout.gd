class_name ValedouroCartoonGameLayout
extends Control
## Shared HUD shell for all eight campaign regions.

const GuildContracts = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")

const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
const Placement = preload("res://scripts/cartoon/cartoon_ui_placement.gd")

var host
var quest_panel: PanelContainer
var quest_body: Control
var collapse_button: Button
var attack_button: Button
var spell_button: Button
var spell_cycle_button: Button
var interact_button: Button
var map_button: Button
var pause_button: Button
var pause_panel: PanelContainer
var contract_panel: PanelContainer
var contract_copy: Label
var expanded: bool = false
var gameplay_nodes: Array[Control] = []
var joystick_center: Vector2
var last_joystick: Vector2 = Vector2.INF

static func build(host_node, map_script, navigation_property: String) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "HUD"
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	host_node.add_child(layer)
	host_node.ui = layer
	var layout = ValedouroCartoonGameLayout.new()
	layout.name = "GameLayout"
	layout.host = host_node
	layer.add_child(layout)
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout._build(map_script,navigation_property)
	layout.get_viewport().size_changed.connect(layout._layout)
	layout._layout()

static func movement_zone(node: Node) -> Rect2:
	var area: Rect2 = UISkin.usable(node.get_viewport())
	return Rect2(Vector2(area.position.x,area.end.y-190.0),Vector2(230,190))

static func can_start_movement(node: Node, p: Vector2) -> bool:
	if not movement_zone(node).has_point(p): return false
	var layout = node.get_node_or_null("HUD/GameLayout")
	if layout == null or layout.is_blocked(): return false
	# Native touch-to-mouse emulation may deliver the touch before the GUI mouse
	# event. Never claim a finger over a toolbar/zoom hitbox in that interval.
	var controls: Array[Control] = [layout.map_button,layout.pause_button,layout.attack_button,layout.interact_button,layout.spell_button,layout.spell_cycle_button,layout.quest_panel]
	for key: String in ["inventory_ui","crafting_ui"]:
		var ui = node.get(key)
		if ui != null and ui.toggle_button != null: controls.append(ui.toggle_button)
	if node.get("zoom_controls") != null: controls.append(node.zoom_controls.panel)
	for control: Control in controls:
		if control.is_visible_in_tree() and control.get_global_rect().has_point(p): return false
	return true

func _build(map_script, navigation_property: String) -> void:
	contract_panel = PanelContainer.new()
	contract_panel.name = "ActiveGuildContracts"
	contract_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contract_panel.add_theme_stylebox_override("panel",UISkin.box(Color(0.07,0.13,0.10,0.88),UISkin.GOLD.darkened(0.4),8))
	add_child(contract_panel)
	var contract_body: Control = Control.new()
	contract_body.custom_minimum_size = Vector2(256,54)
	contract_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contract_panel.add_child(contract_body)
	contract_copy = UISkin.label("",12,UISkin.GOLD.lightened(0.25))
	contract_copy.position = Vector2(10,7)
	contract_copy.size = Vector2(238,43)
	contract_copy.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	contract_body.add_child(contract_copy)
	# Existing scene methods can keep refreshing their public label references.
	host.stats_label = UISkin.label("")
	host.stats_label.visible = false
	add_child(host.stats_label)
	quest_panel = PanelContainer.new()
	quest_panel.name = "QuestPanel"
	quest_panel.add_theme_stylebox_override("panel",UISkin.box(Color(0.08,0.14,0.11,0.91),UISkin.GOLD.darkened(0.30)))
	add_child(quest_panel)
	gameplay_nodes.append(quest_panel)
	quest_body = Control.new()
	quest_body.custom_minimum_size = Vector2(284,120)
	quest_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quest_panel.add_child(quest_body)
	var title: Label = UISkin.label("OBJETIVO",11,UISkin.MUTED)
	title.position = Vector2(14,9)
	quest_body.add_child(title)
	collapse_button = _button("+",Vector2(44,44),_toggle_quest)
	collapse_button.name = "ExpandQuestButton"
	collapse_button.position = Vector2(239,0)
	quest_body.add_child(collapse_button)
	host.objective_label = UISkin.label("",14)
	host.objective_label.position = Vector2(14,47)
	host.objective_label.size = Vector2(258,43)
	host.objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	host.objective_label.max_lines_visible = 2
	host.objective_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	quest_body.add_child(host.objective_label)
	var navigation: Label = UISkin.label("",12,UISkin.GOLD)
	navigation.name = "ObjectiveNavigation"
	navigation.position = Vector2(14,98)
	navigation.size = Vector2(258,20)
	navigation.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	quest_body.add_child(navigation)
	host.set(navigation_property,navigation)
	host.poi_label = UISkin.label("",14)
	host.poi_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	host.poi_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	host.poi_label.add_theme_color_override("font_shadow_color",UISkin.INK)
	host.poi_label.add_theme_constant_override("shadow_outline_size",3)
	add_child(host.poi_label)
	gameplay_nodes.append(host.poi_label)
	host.toast_label = UISkin.label("",16,UISkin.TEXT)
	host.toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	host.toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	host.toast_label.add_theme_color_override("font_shadow_color",UISkin.INK)
	host.toast_label.add_theme_constant_override("shadow_outline_size",4)
	add_child(host.toast_label)
	gameplay_nodes.append(host.toast_label)
	host.map_overlay = map_script.new()
	host.map_overlay.size = Vector2(850,460)
	host.map_overlay.visible = false
	add_child(host.map_overlay)
	host.map_overlay.setup(host.hero)
	host.map_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	host.map_overlay.z_index = 80
	UISkin.bind(host.map_overlay,Vector2(850,460),"center",true)
	var close: Button = _button("×",Vector2(48,48),host._toggle_map)
	close.name = "CloseMapButton"
	close.position = Vector2(792,2)
	host.map_overlay.add_child(close)
	map_button = _button("MAPA",Vector2(68,48),host._toggle_map)
	map_button.name = "MapButton"
	add_child(map_button)
	gameplay_nodes.append(map_button)
	pause_button = _button("PAUSA",Vector2(68,48),open_pause)
	pause_button.name = "PauseButton"
	add_child(pause_button)
	gameplay_nodes.append(pause_button)
	attack_button = _button("ATACAR",Vector2(86,86),host._attack,43)
	attack_button.name = "AttackButton"
	attack_button.add_theme_font_size_override("font_size",13)
	add_child(attack_button)
	gameplay_nodes.append(attack_button)
	interact_button = _button("USAR",Vector2(68,68),host._interact,34)
	interact_button.name = "InteractButton"
	add_child(interact_button)
	gameplay_nodes.append(interact_button)
	spell_button = _button("MAGIA",Vector2(76,50),_cast_spell,24)
	spell_button.name = "SpellButton"
	spell_button.add_theme_font_size_override("font_size",12)
	spell_button.tooltip_text = "Q: conjurar • alcance 220 • recarga 3 s • exige linha de visão"
	add_child(spell_button)
	gameplay_nodes.append(spell_button)
	spell_cycle_button = _button("TROCAR",Vector2(76,44),_cycle_spell,12)
	spell_cycle_button.name = "SpellCycleButton"
	spell_cycle_button.add_theme_font_size_override("font_size",10)
	spell_cycle_button.tooltip_text = "R: trocar • Brasa queima • Cristal desacelera • Arcana salta entre inimigos"
	add_child(spell_cycle_button)
	gameplay_nodes.append(spell_cycle_button)
	_build_pause()

func _button(text: String, button_size: Vector2, callback: Callable, radius: int = 10) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.size = button_size
	UISkin.button(button,UISkin.SURFACE,UISkin.GOLD,radius)
	button.pressed.connect(callback)
	return button

func _layout() -> void:
	var area: Rect2 = UISkin.usable(get_viewport())
	quest_panel.position = Vector2(area.end.x-288.0,area.position.y)
	quest_panel.size = Vector2(288,218 if expanded else 124)
	map_button.position = Placement.toolbar_rect(get_viewport(),0).position
	pause_button.position = Placement.toolbar_rect(get_viewport(),3).position
	attack_button.position = Vector2(area.end.x-86,area.end.y-94)
	interact_button.position = Vector2(area.end.x-172,area.end.y-78)
	spell_button.position = Vector2(area.end.x-86,area.end.y-154)
	spell_cycle_button.position = Vector2(area.end.x-86,area.end.y-200)
	contract_panel.position = area.position+Vector2(0,92)
	joystick_center = Vector2(area.position.x+86,area.end.y-80)
	var hint_width: float = minf(480,area.size.x-220)
	host.poi_label.position = Vector2(area.get_center().x-hint_width/2,area.end.y-194)
	host.poi_label.size = Vector2(hint_width,25)
	host.toast_label.position = Vector2(area.get_center().x-225,area.end.y-245)
	host.toast_label.size = Vector2(450,40)
	queue_redraw()

func _toggle_quest() -> void:
	expanded = not expanded
	collapse_button.text = "−" if expanded else "+"
	quest_body.custom_minimum_size.y = 214 if expanded else 120
	host.objective_label.size.y = 136 if expanded else 43
	host.objective_label.max_lines_visible = 6 if expanded else 2
	var nav: Control = quest_body.get_node("ObjectiveNavigation")
	nav.position.y = 186 if expanded else 98
	_layout()

func is_blocked() -> bool:
	if host.map_open or pause_panel.visible: return true
	if host.get("guild_board") != null and host.guild_board.is_open(): return true
	for key: String in ["inventory_ui","crafting_ui"]:
		var panel = host.get(key)
		if panel != null and panel.is_open(): return true
	# Only the final region exposes this property.
	if host.get("choice_panel") != null and host.get("choice_panel").visible: return true
	return false

func _process(_delta: float) -> void:
	var blocked: bool = is_blocked()
	var state = get_node_or_null("/root/CartoonPlayerState")
	var count: int = 0
	var ready_count: int = 0
	var first: String = ""
	var descriptions: PackedStringArray = []
	if state != null:
		for item in GuildContracts.ROWS:
			if GuildContracts.status(state,item.id) != "active": continue
			count += 1
			var p: int = GuildContracts.progress(state,item.id)
			if p >= item.count: ready_count += 1
			var detail: String = "%s  %d/%d" % [item.title,p,item.count]
			if first == "": first = detail
			descriptions.append(detail)
	contract_panel.visible = count > 0 and not blocked
	contract_copy.text = "GUILDA • %d ativos • %d prontos\n%s" % [count,ready_count,first]
	contract_copy.tooltip_text = "\n".join(descriptions)
	var inside_building: bool = host.get("interiors") != null and host.interiors.active
	map_button.text = "SAIR" if inside_building else "MAPA"
	for control: Control in gameplay_nodes: control.visible = not blocked
	if host.hero != null:
		spell_button.text = "%s\n%.1f s" % [host.hero.SPELL_NAMES[host.hero.spell_index],host.hero.spell_cooldown] if host.hero.spell_cooldown>0 else "MAGIA\n"+host.hero.SPELL_NAMES[host.hero.spell_index]
		spell_button.disabled = host.hero.spell_cooldown>0
	if inside_building:
		attack_button.visible = false
		spell_button.visible = false
		spell_cycle_button.visible = false
	var toolbar_clear: bool = not expanded or not quest_panel.get_global_rect().intersects(Placement.toolbar_rect(get_viewport(),3))
	map_button.visible = not blocked and toolbar_clear
	pause_button.visible = not blocked and toolbar_clear
	for key: String in ["hud_status","zoom_controls"]:
		var control = host.get(key)
		if control != null: control.visible = not blocked
	for key: String in ["inventory_ui","crafting_ui"]:
		var control = host.get(key)
		if control != null and control.toggle_button != null: control.toggle_button.visible = not blocked and toolbar_clear
	if blocked:
		host.joystick_id = -1
		host.joystick_vector = Vector2.ZERO
	elif host.story_runtime != null:
		var source: String = host.story_runtime.hud_text()
		host.objective_label.text = source.trim_prefix("HISTÓRIA PRINCIPAL\n")
		host.objective_label.tooltip_text = host.objective_label.text
	if last_joystick != host.joystick_vector:
		last_joystick = host.joystick_vector
	queue_redraw()

func _draw() -> void:
	if host == null or quest_panel == null or is_blocked(): return
	var center: Vector2 = joystick_center if host.joystick_id < 0 else host.joystick_origin
	draw_circle(center,66,Color(0.05,0.12,0.09,0.26))
	draw_arc(center,66,0,TAU,64,Color(0.75,0.69,0.47,0.46),2,true)
	draw_circle(center+host.joystick_vector*42.0,25,Color(0.12,0.24,0.18,0.70))
	draw_arc(center+host.joystick_vector*42.0,25,0,TAU,40,Color(0.80,0.76,0.54,0.65),1.5,true)
	for d: Vector2 in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		draw_line(center+d*48,center+d*56,Color(0.83,0.82,0.66,0.65),2,true)

func _input(event: InputEvent) -> void:
	# Continue an owned finger even when it leaves the movement zone. A second
	# finger remains free to use buttons; GUI presses never begin a joystick drag.
	if host == null or host.joystick_id < 0: return
	if event is InputEventScreenTouch and event.index == host.joystick_id and not event.pressed:
		host.joystick_id = -1
		host.joystick_vector = Vector2.ZERO
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == host.joystick_id:
		host.joystick_vector = (event.position-host.joystick_origin).limit_length(80.0)/80.0
		get_viewport().set_input_as_handled()

func _cast_spell() -> void:
	if not is_blocked() and host.hero != null: host.hero.cast_spell(host)

func _cycle_spell() -> void:
	if not is_blocked() and host.hero != null:
		host.hero.cycle_spell()
		var tips = ["Brasa • queimadura em três pulsos","Cristal • lentidão por 2,5 s","Arcana • salta para um inimigo próximo"]
		host._show_toast(tips[host.hero.spell_index])

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and not is_blocked():
		if event.physical_keycode == KEY_Q:
			_cast_spell()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_R:
			_cycle_spell()
			get_viewport().set_input_as_handled()
			return
	if not event.is_action_pressed("ui_cancel"): return
	if host.get("guild_board") != null and host.guild_board.is_open(): host.guild_board.close_panel()
	elif pause_panel.visible: close_pause()
	elif host.map_open: host._toggle_map()
	elif host.inventory_ui != null and host.inventory_ui.is_open(): host.inventory_ui.close_panel()
	elif host.crafting_ui != null and host.crafting_ui.is_open(): host.crafting_ui.close_panel()
	elif not is_blocked(): open_pause()
	get_viewport().set_input_as_handled()

func _build_pause() -> void:
	pause_panel = PanelContainer.new()
	pause_panel.name = "PausePanel"
	pause_panel.custom_minimum_size = Vector2(350,270)
	pause_panel.visible = false
	pause_panel.z_index = 100
	pause_panel.add_theme_stylebox_override("panel",UISkin.box())
	add_child(pause_panel)
	var body: Control = Control.new()
	body.name = "PauseContent"
	body.custom_minimum_size = Vector2(346,266)
	pause_panel.add_child(body)
	var title: Label = UISkin.label("Uma pausa na jornada",22)
	title.position = Vector2(24,22)
	body.add_child(title)
	var resume: Button = _button("CONTINUAR",Vector2(298,52),close_pause)
	resume.name = "ResumeButton"
	resume.position = Vector2(24,80)
	body.add_child(resume)
	var menu: Button = _button("SALVAR E VOLTAR AO MENU",Vector2(298,52),_return_to_menu)
	menu.name = "SaveAndMenuButton"
	menu.position = Vector2(24,146)
	body.add_child(menu)
	var note: Label = UISkin.label("Seu progresso fica salvo neste aparelho.",12,UISkin.MUTED)
	note.position = Vector2(24,222)
	body.add_child(note)
	UISkin.bind(pause_panel,Vector2(350,270),"center",true)

func open_pause() -> void:
	if is_blocked(): return
	pause_panel.visible = true
	get_tree().paused = true

func close_pause() -> void:
	pause_panel.visible = false
	get_tree().paused = false

func _return_to_menu() -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null: state.save_profile()
	close_pause()
	get_tree().change_scene_to_file("res://scenes/cartoon/CartoonMainMenu.tscn")

func _exit_tree() -> void:
	if get_tree() != null and pause_panel != null and pause_panel.visible:
		get_tree().paused = false
