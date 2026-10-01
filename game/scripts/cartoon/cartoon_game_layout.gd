class_name ValedouroCartoonGameLayout
extends Control
## Shared HUD shell for all eight campaign regions.

const GuildContracts = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")
const ClassUI = preload("res://scripts/cartoon/cartoon_class_ui.gd")
const DemonMapMarkers = preload("res://scripts/cartoon/cartoon_demon_map_markers.gd")
const DemonDirector = preload("res://scripts/cartoon/cartoon_demon_director.gd")
var demon_director
const MissionUI = preload("res://scripts/cartoon/cartoon_mission_ui.gd")
const MissionJournal = preload("res://scripts/cartoon/cartoon_mission_journal.gd")
const MissionMarker = preload("res://scripts/cartoon/cartoon_mission_map_marker.gd")
var mission_ui
var mission_button: Button
var mission_marker
var tracking_elapsed: float = 0
var tracked_target: Dictionary = {}
var class_ui

const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
const Placement = preload("res://scripts/cartoon/cartoon_ui_placement.gd")

var host
var quest_panel: PanelContainer
var quest_body: Control
var collapse_button: Button
var attack_button: Button
var spell_buttons: Array[Button] = []
var interact_button: Button
var dodge_button: Button
var heal_button: Button
var map_button: Button
var pause_button: Button
var pause_panel: PanelContainer
var contract_panel: PanelContainer
var contract_copy: Label
var expanded: bool = false
var gameplay_nodes: Array[Control] = []
var joystick_center: Vector2
var last_joystick: Vector2 = Vector2.INF
var last_toast_text: String = ""
var last_unlocked_spells: int = -1

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
	var controls: Array[Control] = [layout.map_button,layout.pause_button,layout.attack_button,layout.interact_button,layout.dodge_button,layout.heal_button,layout.quest_panel]
	controls.append_array(layout.spell_buttons)
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
	contract_body.custom_minimum_size = Vector2(224,24)
	contract_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contract_panel.add_child(contract_body)
	contract_copy = UISkin.label("",12,UISkin.GOLD.lightened(0.25))
	contract_copy.position = Vector2(10,5)
	contract_copy.size = Vector2(204,18)
	contract_copy.max_lines_visible = 1
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
	quest_body.custom_minimum_size = Vector2(252,88)
	quest_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quest_panel.add_child(quest_body)
	mission_button = _button("MISSÕES",Vector2(110,44),_open_missions)
	mission_button.name = "MissionsButton"
	mission_button.position = Vector2(8,0)
	quest_body.add_child(mission_button)
	collapse_button = _button("+",Vector2(44,44),_toggle_quest)
	collapse_button.name = "ExpandQuestButton"
	collapse_button.position = Vector2(207,0)
	quest_body.add_child(collapse_button)
	host.objective_label = UISkin.label("",14)
	host.objective_label.position = Vector2(12,45)
	host.objective_label.size = Vector2(228,26)
	host.objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	host.objective_label.max_lines_visible = 1
	host.objective_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	quest_body.add_child(host.objective_label)
	var navigation: Label = UISkin.label("",12,UISkin.GOLD)
	navigation.name = "ObjectiveNavigation"
	navigation.position = Vector2(12,69)
	navigation.size = Vector2(228,16)
	navigation.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	quest_body.add_child(navigation)
	host.set(navigation_property,navigation)
	host.poi_label = UISkin.label("",14)
	host.poi_label.name = "NearbyInteractionHint"
	host.poi_label.max_lines_visible = 1
	host.poi_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	host.poi_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	host.poi_label.add_theme_color_override("font_shadow_color",UISkin.INK)
	host.poi_label.add_theme_constant_override("shadow_outline_size",3)
	add_child(host.poi_label)
	gameplay_nodes.append(host.poi_label)
	host.toast_label = UISkin.label("",13,UISkin.TEXT)
	host.toast_label.name = "CombatToast"
	host.toast_label.max_lines_visible = 2
	host.toast_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
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
	mission_marker = MissionMarker.new()
	mission_marker.name = "TrackedMissionMarker"
	host.map_overlay.add_child(mission_marker)
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
	var tips = ["Brasa: queimadura em três pulsos","Cristal: lentidão por 2,5 s","Arcana: salta para um inimigo próximo"]
	for i in range(3):
		var button = _button("",Vector2(76,50),_cast_spell.bind(i),14)
		button.name = ["EmberSpellButton","FrostSpellButton","ArcaneSpellButton"][i]
		button.add_theme_font_size_override("font_size",12)
		UISkin.button(button,UISkin.SURFACE,host.hero.SPELL_COLORS[i],14)
		button.tooltip_text = "%d: %s • alcance 220 • recarga própria de 3 s • exige linha de visão" % [i+1,tips[i]]
		add_child(button)
		spell_buttons.append(button)
		gameplay_nodes.append(button)
	dodge_button = _button("ESQUIVA",Vector2(62,50),_dodge,10)
	dodge_button.name = "DodgeButton"
	dodge_button.add_theme_font_size_override("font_size",11)
	dodge_button.tooltip_text = "Shift: esquiva na direção do movimento • recarga 2,2 s"
	add_child(dodge_button)
	gameplay_nodes.append(dodge_button)
	heal_button = _button("CURA",Vector2(62,50),_quick_heal,10)
	heal_button.name = "QuickHealButton"
	heal_button.add_theme_font_size_override("font_size",11)
	heal_button.tooltip_text = "Usa rapidamente um item de cura da Bolsa."
	UISkin.button(heal_button,UISkin.SURFACE,Color("d86f87"),10)
	add_child(heal_button)
	gameplay_nodes.append(heal_button)
	_build_pause()
	class_ui = ClassUI.new()
	class_ui.name = "HeroClasses"
	add_child(class_ui)
	class_ui.setup(host)
	mission_ui = MissionUI.new()
	mission_ui.name = "MissionJournal"
	add_child(mission_ui)
	mission_ui.setup(host)
	call_deferred("_setup_demons")

func _button(text: String, button_size: Vector2, callback: Callable, radius: int = 10) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.size = button_size
	UISkin.button(button,UISkin.SURFACE,UISkin.GOLD,radius)
	button.pressed.connect(callback)
	return button

func _layout() -> void:
	var area: Rect2 = UISkin.usable(get_viewport())
	quest_panel.position = Vector2(area.end.x-256.0,area.position.y)
	quest_panel.size = Vector2(256,186 if expanded else 92)
	map_button.position = Placement.toolbar_rect(get_viewport(),0).position
	pause_button.position = Placement.toolbar_rect(get_viewport(),3).position
	attack_button.position = Vector2(area.end.x-86,area.end.y-94)
	interact_button.position = Vector2(area.end.x-172,area.end.y-78)
	var compact: bool = area.size.x<888
	var state = get_node_or_null("/root/CartoonPlayerState")
	var unlocked_spells: int = state.unlocked_spell_count() if state != null else 1
	unlocked_spells = clampi(unlocked_spells,1,spell_buttons.size())
	var spell_start_x: float = area.end.x-76-82*(unlocked_spells-1)
	for i in range(spell_buttons.size()):
		spell_buttons[i].position = Vector2(spell_start_x+i*82,area.end.y-(204 if compact else 154))
	dodge_button.size = Vector2(62,50)
	dodge_button.position = Vector2(area.end.x-152,area.end.y-142) if compact else Vector2(area.end.x-70,area.end.y-208)
	heal_button.size = Vector2(62,50)
	heal_button.position = Vector2(area.end.x-222,area.end.y-142) if compact else Vector2(area.end.x-140,area.end.y-208)
	contract_panel.position = area.position+Vector2(0,92)
	joystick_center = Vector2(area.position.x+86,area.end.y-80)
	var hint_width: float = minf(480,area.size.x-220)
	host.poi_label.position = Vector2(area.get_center().x-hint_width/2,area.end.y-194)
	host.poi_label.size = Vector2(hint_width,25)
	host.toast_label.position = Vector2(area.get_center().x-170,area.end.y-224)
	host.toast_label.size = Vector2(340,30)
	host.poi_label.position.y = maxf(host.poi_label.position.y,host.toast_label.position.y+32)
	if compact:
		host.toast_label.position.x = area.position.x
		host.toast_label.size.x = area.size.x-260
		host.poi_label.position.x = area.position.x
		host.poi_label.size.x = area.size.x-260
	if area.size.y<380:
		# Keep transient messages below the objective card and above the toolbar.
		host.toast_label.position = area.position+Vector2(0,120)
		host.toast_label.size = Vector2(area.size.x-260,28)
		host.toast_label.add_theme_font_size_override("font_size",12)
		host.poi_label.position = area.position+Vector2(0,152)
		host.poi_label.size = Vector2(area.size.x-260,20)
	else:
		host.toast_label.add_theme_font_size_override("font_size",13)
	# Wrapped text can exceed the requested height; use the actual font minimum.
	host.toast_label.size.y = maxf(28 if area.size.y<380 else 30,host.toast_label.get_combined_minimum_size().y)
	host.poi_label.position.y = maxf(host.poi_label.position.y,host.toast_label.position.y+host.toast_label.size.y+3)
	queue_redraw()

func _toggle_quest() -> void:
	expanded = not expanded
	collapse_button.text = "−" if expanded else "+"
	quest_body.custom_minimum_size.y = 182 if expanded else 88
	host.objective_label.size.y = 116 if expanded else 26
	host.objective_label.max_lines_visible = 6 if expanded else 1
	var nav: Control = quest_body.get_node("ObjectiveNavigation")
	nav.position.y = 154 if expanded else 69
	_layout()

func is_blocked() -> bool:
	if mission_ui != null and mission_ui.is_open(): return true
	if class_ui != null and class_ui.is_open(): return true
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
	host.toast_label.tooltip_text = host.toast_label.text
	if last_toast_text!=host.toast_label.text:
		last_toast_text = host.toast_label.text
		_layout()
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
	contract_copy.text = "GUILDA %d/%d • %s" % [ready_count,count,first]
	contract_copy.tooltip_text = "\n".join(descriptions)
	var current_unlocked_spells: int = state.unlocked_spell_count() if state != null else 1
	if current_unlocked_spells != last_unlocked_spells:
		last_unlocked_spells = current_unlocked_spells
		_layout()
	var inside_building: bool = host.get("interiors") != null and host.interiors.active
	map_button.text = "SAIR" if inside_building else "MAPA"
	for control: Control in gameplay_nodes: control.visible = not blocked
	if host.hero != null:
		var attack_wait: float = host.hero.bow_cooldown if host.hero.bow_equipped else host.hero.melee_cooldown
		attack_button.text = "DISPARAR" if host.hero.bow_equipped else "ATACAR"
		if attack_wait>0: attack_button.text += "\n%.1f s" % attack_wait
		attack_button.disabled = attack_wait>0 or host.hero.death_t>0
		for i in range(spell_buttons.size()):
			var unlocked: bool = state == null or state.spell_unlocked(i)
			var remaining: float = host.hero.spell_cooldown_remaining(i)
			spell_buttons[i].visible = not blocked and unlocked
			spell_buttons[i].text = "%s\n%.1f s" % [host.hero.SPELL_NAMES[i],remaining] if remaining>0 else host.hero.SPELL_NAMES[i]
			spell_buttons[i].disabled = not unlocked or remaining>0 or host.hero.death_t>0 or host.hero.dodge_t>0
		dodge_button.text = "ESQUIVA\n%.1f s" % host.hero.dodge_cooldown if host.hero.dodge_cooldown>0 else "ESQUIVA"
		dodge_button.disabled = host.hero.dodge_cooldown>0 or host.hero.death_t>0
		var heal_count: int = state.healing_consumables_total() if state != null else 0
		var current_hp: int = int(host.get("player_hp")) if host.get("player_hp") != null else (state.player_hp if state != null else 0)
		var max_hp: int = int(host.get("player_max_hp")) if host.get("player_max_hp") != null else (state.player_max_hp if state != null else 0)
		heal_button.text = "CURA\nx%d" % heal_count
		heal_button.disabled = heal_count <= 0 or current_hp >= max_hp or host.hero.death_t>0
	if inside_building:
		attack_button.visible = false
		for button in spell_buttons: button.visible = false
		dodge_button.visible = false
	if expanded:
		for button: Button in spell_buttons+[dodge_button,heal_button,attack_button,interact_button]:
			if quest_panel.get_global_rect().intersects(button.get_global_rect()): button.visible = false
		for label: Label in [host.toast_label,host.poi_label]:
			if quest_panel.get_global_rect().intersects(label.get_global_rect()): label.visible = false
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
	_update_tracking(_delta)
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

func _cast_spell(index: int = -1) -> void:
	if not is_blocked() and host.hero != null: host.hero.cast_spell(host,index)

func _quick_heal() -> void:
	if is_blocked():
		return
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null:
		return
	var result: Dictionary = state.quick_heal()
	if host != null and host.has_method("_refresh_stats"):
		host.call("_refresh_stats")
	if host != null and host.has_method("_show_toast"):
		host.call("_show_toast",String(result.get("message","Cura atualizada.")))

func _dodge() -> void:
	if not is_blocked() and host.hero != null: host.hero.try_dodge(host)

func _cycle_spell() -> void:
	if not is_blocked() and host.hero != null:
		host.hero.cycle_spell()
		var tips = ["Brasa • queimadura em três pulsos","Cristal • lentidão por 2,5 s","Arcana • salta para um inimigo próximo"]
		host._show_toast(tips[host.hero.spell_index])

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_J:
		if mission_ui.is_open(): mission_ui.close_panel()
		elif not is_blocked(): _open_missions()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_C:
		if class_ui.is_open(): class_ui.close_panel()
		elif not is_blocked(): class_ui.open_panel()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and not is_blocked():
		if event.physical_keycode == KEY_SHIFT:
			_dodge()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode in [KEY_1,KEY_2,KEY_3]:
			_cast_spell(event.physical_keycode-KEY_1)
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_Q:
			_cast_spell()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_R:
			_cycle_spell()
			get_viewport().set_input_as_handled()
			return
	if not event.is_action_pressed("ui_cancel"): return
	if mission_ui.is_open(): mission_ui.close_panel()
	elif class_ui.is_open(): class_ui.close_panel()
	elif host.get("guild_board") != null and host.guild_board.is_open(): host.guild_board.close_panel()
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

func _open_missions() -> void:
	tracking_elapsed = 0
	mission_ui.open_panel()

func _update_tracking(delta: float) -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state==null or host.story_runtime==null: return
	state.normalize_tracked_mission()
	if state.tracked_mission=="main":
		if tracked_target.has("id"):
			tracked_target.clear()
			if host.has_method("_update_objective_navigation"): host._update_objective_navigation()
			elif host.has_method("_update_navigation"): host._update_navigation()
		mission_marker.enabled = false
		mission_marker.queue_redraw()
		if host.map_open: host.map_overlay.set_target(host.story_runtime.current_location())
		return
	var id: String = state.tracked_mission
	var row: Dictionary = GuildContracts.row(id)
	var progress: int = GuildContracts.progress(state,id)
	host.objective_label.text = "%s • %d/%d\n%s" % [String(row.title),progress,int(row.count),"Volte à guilda para receber" if progress>=int(row.count) else String(row.description)]
	host.objective_label.tooltip_text = host.objective_label.text
	tracking_elapsed -= delta
	# Habitats can number hundreds; refresh only twice per second or on selection.
	if tracking_elapsed<=0 or tracked_target.get("id","")!=id or tracked_target.get("progress",-1)!=progress:
		tracked_target = MissionJournal.target(host,state,id)
		tracked_target.id = id
		tracked_target.progress = progress
		tracking_elapsed = 0.5
	var nav: Label = quest_body.get_node("ObjectiveNavigation")
	nav.text = String(tracked_target.get("hint",""))
	if tracked_target.get("valid",false):
		var diff: Vector2 = tracked_target.position-host.hero.position
		var direction: String = "◆" if diff.length()<35 else ["→","↘","↓","↙","←","↖","↑","↗"][posmod(roundi(diff.angle()/(PI/4)),8)]
		nav.text = "%s %dm • %s" % [direction,int(diff.length()),String(tracked_target.hint)]
	mission_marker.enabled = bool(tracked_target.get("valid",false))
	mission_marker.point = tracked_target.get("position",Vector2.ZERO)
	mission_marker.caption = String(row.title)
	mission_marker.queue_redraw()
	if host.map_open: host.map_overlay.set_target("")

func _setup_demons() -> void:
	demon_director = DemonDirector.new()
	demon_director.name = "EliteDemonDirector"
	add_child(demon_director)
	demon_director.setup(host)
	var markers = DemonMapMarkers.new()
	markers.name = "EliteDemonMapMarkers"
	markers.director = demon_director
	host.map_overlay.add_child(markers)
