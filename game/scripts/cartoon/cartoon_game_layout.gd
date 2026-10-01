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
var desktop_mode: bool = false
var minimap: Control
var rail_style: StyleBox
var screen_frame: StyleBoxTexture
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
var spell_bar: PanelContainer
var fullscreen_pause_button: Button
var exit_game_button: Button
var contract_panel: PanelContainer
var contract_copy: Label
var expanded: bool = false
var gameplay_nodes: Array[Control] = []
var joystick_center: Vector2
var last_joystick: Vector2 = Vector2.INF
var last_toast_text: String = ""
var last_unlocked_spells: int = -1
var last_player_level: int = -1
var level_banner: PanelContainer
var level_banner_label: Label
var level_banner_timer: float = 0.0
var boss_panel: PanelContainer
var boss_name_label: Label
var boss_phase_label: Label
var boss_bar: ProgressBar
var last_boss_phase: int = 0

static func build(host_node, map_script, navigation_property: String) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "HUD"
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	host_node.add_child(layer)
	host_node.ui = layer
	var layout = ValedouroCartoonGameLayout.new()
	layout.name = "GameLayout"
	layout.host = host_node
	layout.desktop_mode = OS.get_name() == "Windows"
	layer.add_child(layout)
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout._build(map_script,navigation_property)
	layout.get_viewport().size_changed.connect(layout._layout)
	layout._layout()

static func movement_zone(node: Node) -> Rect2:
	var area: Rect2 = UISkin.usable(node.get_viewport())
	return Rect2(Vector2(area.position.x+76,area.end.y-190.0),Vector2(220,190))

static func can_start_movement(node: Node, p: Vector2) -> bool:
	if not movement_zone(node).has_point(p): return false
	var layout = node.get_node_or_null("HUD/GameLayout")
	if layout == null or layout.is_blocked(): return false
	# Native touch-to-mouse emulation may deliver the touch before the GUI mouse
	# event. Never claim a finger over a toolbar/zoom hitbox in that interval.
	var controls: Array[Control] = [layout.map_button,layout.pause_button,layout.attack_button,layout.interact_button,layout.dodge_button,layout.heal_button,layout.quest_panel,layout.minimap,layout.mission_button]
	controls.append_array(layout.spell_buttons)
	for key: String in ["inventory_ui","crafting_ui"]:
		var ui = node.get(key)
		if ui != null and ui.toggle_button != null: controls.append(ui.toggle_button)
	if node.get("zoom_controls") != null: controls.append(node.zoom_controls.panel)
	for control: Control in controls:
		if control.is_visible_in_tree() and control.get_global_rect().has_point(p): return false
	return true

func _build(map_script, navigation_property: String) -> void:
	rail_style = UISkin.box()
	screen_frame = UISkin.box() as StyleBoxTexture
	screen_frame.draw_center = false
	contract_panel = PanelContainer.new()
	contract_panel.name = "ActiveGuildContracts"
	contract_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contract_panel.add_theme_stylebox_override("panel",UISkin.box(UISkin.INK,UISkin.GOLD.darkened(0.4),8))
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
	quest_panel.add_theme_stylebox_override("panel",UISkin.box(UISkin.INK,UISkin.GOLD.darkened(0.30)))
	add_child(quest_panel)
	gameplay_nodes.append(quest_panel)
	quest_body = Control.new()
	quest_body.custom_minimum_size = Vector2(184,54)
	quest_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quest_panel.add_child(quest_body)
	mission_button = _button("MISSÕES",Vector2(110,44),_open_missions)
	mission_button.name = "MissionsButton"
	mission_button.size = Vector2(68,48)
	add_child(mission_button)
	gameplay_nodes.append(mission_button)
	UISkin.icon(mission_button,"quest",26)
	collapse_button = _button("+",Vector2(44,44),_toggle_quest)
	collapse_button.name = "ExpandQuestButton"
	collapse_button.position = Vector2(136,10)
	quest_body.add_child(collapse_button)
	host.objective_label = UISkin.label("",12)
	host.objective_label.position = Vector2(12,12)
	host.objective_label.size = Vector2(120,26)
	host.objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	host.objective_label.max_lines_visible = 1
	host.objective_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	quest_body.add_child(host.objective_label)
	var navigation: Label = UISkin.label("",12,UISkin.GOLD)
	navigation.name = "ObjectiveNavigation"
	navigation.position = Vector2(12,35)
	navigation.size = Vector2(160,16)
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

	level_banner = PanelContainer.new()
	level_banner.name = "LevelUpBanner"
	level_banner.visible = false
	level_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_banner.add_theme_stylebox_override("panel",UISkin.box(Color(0.08,0.16,0.12,0.96),UISkin.GOLD,10))
	add_child(level_banner)
	level_banner_label = UISkin.label("",13,UISkin.GOLD)
	level_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	level_banner_label.max_lines_visible = 2
	level_banner_label.custom_minimum_size = Vector2(236,42)
	level_banner.add_child(level_banner_label)

	boss_panel = PanelContainer.new()
	boss_panel.name = "BossHealthPanel"
	boss_panel.visible = false
	boss_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_panel.add_theme_stylebox_override("panel",UISkin.box(Color(0.10,0.045,0.065,0.95),Color("c85d77"),10))
	add_child(boss_panel)
	var boss_body: Control = Control.new()
	boss_body.custom_minimum_size = Vector2(286,58)
	boss_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_panel.add_child(boss_body)
	boss_name_label = UISkin.label("",13,Color("ffe6c2"))
	boss_name_label.position = Vector2(10,5)
	boss_name_label.size = Vector2(266,18)
	boss_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	boss_body.add_child(boss_name_label)
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(12,26)
	boss_bar.size = Vector2(262,12)
	boss_bar.min_value = 0
	boss_bar.max_value = 100
	boss_bar.value = 100
	boss_bar.show_percentage = false
	boss_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_bar.add_theme_stylebox_override("background",UISkin.box(Color(0.08,0.03,0.04,0.95),Color("5b2734"),3))
	boss_bar.add_theme_stylebox_override("fill",UISkin.box(Color("d86a78"),Color("ffb3b8"),3))
	boss_bar.add_theme_font_size_override("font_size",1)
	boss_bar.size = Vector2(262,12)
	boss_body.add_child(boss_bar)
	boss_phase_label = UISkin.label("",10,Color("ffd27f"))
	boss_phase_label.position = Vector2(10,40)
	boss_phase_label.size = Vector2(266,14)
	boss_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_body.add_child(boss_phase_label)
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
	pause_button = _button("MENU",Vector2(68,48),open_pause)
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
	spell_bar = PanelContainer.new()
	spell_bar.name = "PCSpellBar"
	spell_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spell_bar.visible = desktop_mode
	spell_bar.add_theme_stylebox_override("panel",UISkin.box(Color(0.035,0.045,0.065,0.92),UISkin.GOLD.darkened(0.25),12))
	add_child(spell_bar)
	gameplay_nodes.append(spell_bar)
	var spell_bar_body: Control = Control.new()
	spell_bar_body.custom_minimum_size = Vector2(330,70)
	spell_bar_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spell_bar.add_child(spell_bar_body)
	var tips = ["Brasa: queimadura em três pulsos","Cristal: lentidão por 2,5 s","Arcana: salta para um inimigo próximo"]
	for i in range(3):
		var button = _button("",Vector2(76,50),_cast_spell.bind(i),14)
		button.name = ["EmberSpellButton","FrostSpellButton","ArcaneSpellButton"][i]
		button.add_theme_font_size_override("font_size",12)
		UISkin.button(button,UISkin.INK,host.hero.SPELL_COLORS[i],28)
		UISkin.icon(button,["fire","ice","arcane"][i],36)
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button.add_theme_font_size_override("font_size",10)
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
	UISkin.button(attack_button,Color("712c30"),UISkin.GOLD,42)
	UISkin.icon(attack_button,"sword",52)
	UISkin.button(dodge_button,UISkin.SURFACE,UISkin.GOLD,28)
	UISkin.icon(dodge_button,"dodge",30)
	UISkin.icon(interact_button,"hand",18)
	UISkin.icon(map_button,"map",26)
	UISkin.icon(pause_button,"menu",26)
	for rail_button in [map_button,pause_button,mission_button]:
		for key in ["normal","disabled"]: rail_button.add_theme_stylebox_override(key,StyleBoxEmpty.new())
	minimap = preload("res://scripts/cartoon/cartoon_radial_minimap.gd").new()
	minimap.name = "RadialMinimap"
	minimap.host = host
	minimap.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT: host._toggle_map())
	add_child(minimap)
	gameplay_nodes.append(minimap)
	_build_pause()
	call_deferred("_move_zoom_into_pause")
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
	var compact: bool = area.size.x < 888.0
	quest_panel.position = Vector2((area.position.x+304+area.end.x-116-188)*0.5,area.position.y)
	quest_panel.size = Vector2(188,186 if expanded else 58)
	map_button.position = Placement.toolbar_rect(get_viewport(),1).position
	pause_button.position = Placement.toolbar_rect(get_viewport(),3).position
	mission_button.position = Placement.toolbar_rect(get_viewport(),2).position
	minimap.position = Vector2(area.end.x-104,area.position.y)
	minimap.size = Vector2(104,104)
	var attack_center: Vector2 = Vector2(area.end.x-128,area.end.y-54)
	attack_button.size = Vector2(104,104)
	attack_button.position = attack_center-attack_button.size*0.5
	interact_button.size = Vector2(64,48)
	interact_button.position = Vector2(area.end.x-258,area.end.y-182)
	# Mobile keeps the radial cluster; Windows gets a fixed bottom action bar.
	if desktop_mode:
		spell_bar.size = Vector2(330,70)
		spell_bar.position = Vector2(area.get_center().x-165,area.end.y-78)
		for i in range(spell_buttons.size()):
			spell_buttons[i].size = Vector2(96,58)
			spell_buttons[i].position = Vector2(spell_bar.position.x+12+float(i)*105.0,spell_bar.position.y+6)
	else:
		var angles = [-102.0,-57.0,-9.0]
		for i in range(spell_buttons.size()):
			spell_buttons[i].size = Vector2(58,58)
			spell_buttons[i].position = attack_center+Vector2.from_angle(deg_to_rad(angles[i]))*100-spell_buttons[i].size*0.5
	dodge_button.size = Vector2(64,64)
	dodge_button.position = Vector2(area.end.x-248,area.end.y-64)
	contract_panel.position = area.position+Vector2(76,106)
	joystick_center = Vector2(area.position.x+142,area.end.y-66)
	var message_width: float = minf(300,area.size.x-366)
	host.toast_label.position = area.position+Vector2(78,158)
	host.toast_label.size = Vector2(message_width,36)
	host.toast_label.add_theme_font_size_override("font_size",12)
	host.toast_label.size.y = maxf(36,host.toast_label.get_combined_minimum_size().y)
	host.poi_label.position = area.position+Vector2(78,202)
	host.poi_label.size = Vector2(message_width,20)
	host.poi_label.add_theme_font_size_override("font_size",12)
	host.poi_label.position.y = maxf(host.poi_label.position.y,host.toast_label.position.y+host.toast_label.size.y+4)
	heal_button.size = Vector2(64,58)
	heal_button.position = Vector2(area.end.x-320,area.end.y-64)
	level_banner.size = Vector2(244,46)
	level_banner.position = area.position+Vector2(78,106)
	boss_panel.size = Vector2(286,58)
	boss_panel.position = Vector2(area.end.x-296,area.position.y+8) if compact else Vector2(area.get_center().x-143,area.position.y+8)
	queue_redraw()

func _toggle_quest() -> void:
	expanded = not expanded
	collapse_button.text = "−" if expanded else "+"
	quest_body.custom_minimum_size.y = 182 if expanded else 54
	host.objective_label.size.y = 126 if expanded else 26
	host.objective_label.max_lines_visible = 6 if expanded else 1
	var nav: Control = quest_body.get_node("ObjectiveNavigation")
	nav.position.y = 154 if expanded else 35
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
	if level_banner_timer > 0.0:
		level_banner_timer = maxf(0.0,level_banner_timer-_delta)
		level_banner.visible = level_banner_timer > 0.0
	elif level_banner != null:
		level_banner.visible = false
	if last_toast_text!=host.toast_label.text:
		last_toast_text = host.toast_label.text
		_layout()
	var state = get_node_or_null("/root/CartoonPlayerState")
	_update_boss_panel(blocked)
	if state != null:
		var current_level: int = int(state.player_level)
		if last_player_level < 0:
			last_player_level = current_level
		elif current_level > last_player_level:
			_show_level_up(last_player_level,current_level,state)
			last_player_level = current_level
		elif current_level < last_player_level:
			last_player_level = current_level
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
	contract_panel.visible = count > 0 and not blocked and level_banner_timer <= 0.0
	contract_copy.text = "GUILDA %d/%d • %s" % [ready_count,count,first]
	contract_copy.tooltip_text = "\n".join(descriptions)
	var current_unlocked_spells: int = state.unlocked_spell_count() if state != null else 1
	if current_unlocked_spells != last_unlocked_spells:
		last_unlocked_spells = current_unlocked_spells
		_layout()
	var inside_building: bool = host.get("interiors") != null and host.interiors.active
	map_button.text = "SAIR" if inside_building else "MAPA"
	for control: Control in gameplay_nodes: control.visible = not blocked
	if boss_panel.visible:
		quest_panel.visible = false
	if host.hero != null:
		var attack_wait: float = host.hero.bow_cooldown if host.hero.bow_equipped else host.hero.melee_cooldown
		UISkin.icon(attack_button,"bow" if host.hero.bow_equipped else "sword",52)
		attack_button.text = "DISPARAR" if host.hero.bow_equipped else "ATACAR"
		if attack_wait>0: attack_button.text += "\n%.1f s" % attack_wait
		attack_button.disabled = attack_wait>0 or host.hero.death_t>0
		for i in range(spell_buttons.size()):
			var unlocked: bool = state == null or state.spell_unlocked(i)
			var remaining: float = host.hero.spell_cooldown_remaining(i)
			spell_buttons[i].visible = not blocked and unlocked
			var spell_name: String = String(host.hero.SPELL_NAMES[i])
			if desktop_mode:
				spell_name = "%d  %s" % [i+1,spell_name]
			spell_buttons[i].text = "%s\n%.1f s" % [spell_name,remaining] if remaining>0 else spell_name
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
	if desktop_mode:
		attack_button.visible = false
		interact_button.visible = false
		dodge_button.visible = false
		heal_button.visible = false
		spell_bar.visible = not blocked and not inside_building
		for i in range(spell_buttons.size()):
			var state_for_spell = get_node_or_null("/root/CartoonPlayerState")
			var unlocked_for_pc: bool = state_for_spell == null or state_for_spell.spell_unlocked(i)
			spell_buttons[i].visible = not blocked and not inside_building and unlocked_for_pc
	else:
		spell_bar.visible = false
	var toolbar_clear: bool = not expanded or not quest_panel.get_global_rect().intersects(Placement.toolbar_rect(get_viewport(),3))
	map_button.visible = not blocked and toolbar_clear
	pause_button.visible = not blocked and toolbar_clear
	minimap.visible = not blocked and not (boss_panel.visible and UISkin.usable(get_viewport()).size.x < 888.0) and not (expanded and quest_panel.get_global_rect().intersects(minimap.get_global_rect()))
	for key: String in ["hud_status"]:
		var control = host.get(key)
		if control != null: control.visible = not blocked
	for key: String in ["inventory_ui"]:
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

func _active_boss():
	if host == null or host.hero == null:
		return null
	var best = null
	var best_distance: float = INF
	var monsters_value = host.get("monsters")
	if not (monsters_value is Array):
		return null
	for monster in monsters_value:
		if not is_instance_valid(monster) or monster.is_queued_for_deletion():
			continue
		var boss_id_value = monster.get("boss_id")
		if boss_id_value == null or String(boss_id_value) == "":
			continue
		var hp_value = monster.get("hp")
		var max_hp_value = monster.get("max_hp")
		if hp_value == null or max_hp_value == null or int(hp_value) <= 0:
			continue
		var distance: float = host.hero.position.distance_to(monster.position)
		var engaged: bool = int(hp_value) < int(max_hp_value)
		if distance > 650.0 and not engaged:
			continue
		if distance < best_distance:
			best = monster
			best_distance = distance
	return best

func _update_boss_panel(blocked: bool) -> void:
	if boss_panel == null:
		return
	var boss = _active_boss()
	if boss == null or blocked:
		boss_panel.visible = false
		last_boss_phase = 0
		return
	boss_panel.visible = true
	var hp_value: int = maxi(0,int(boss.hp))
	var max_hp_value: int = maxi(1,int(boss.max_hp))
	var phase_value: int = clampi(int(boss.boss_phase),1,3)
	boss_name_label.text = "%s • Nv %d" % [String(boss.monster_name),int(boss.level)]
	boss_bar.max_value = max_hp_value
	boss_bar.value = hp_value
	boss_phase_label.text = "%s • %d/%d" % [String(boss.boss_phase_label()),hp_value,max_hp_value]
	if phase_value != last_boss_phase:
		last_boss_phase = phase_value
		var fill_color: Color = Color("d86a78")
		if phase_value == 2:
			fill_color = Color("e67b4f")
		elif phase_value >= 3:
			fill_color = Color("db3f78")
		boss_bar.add_theme_stylebox_override("fill",UISkin.box(fill_color,fill_color.lightened(0.25),3))
	# Theme minimum sizes settle after construction; restore the compact geometry.
	boss_bar.size = Vector2(262,12)
	boss_phase_label.size = Vector2(266,14)
	boss_name_label.size = Vector2(266,18)
	boss_panel.tooltip_text = "%s\n%s" % [boss_name_label.text,boss_phase_label.text]

func _show_level_up(from_level: int,to_level: int,state) -> void:
	if level_banner == null or level_banner_label == null:
		return
	var gained: int = maxi(1,to_level-from_level)
	var first_line: String = "NÍVEL %d • +%d %s" % [to_level,gained,"ponto" if gained==1 else "pontos"]
	var unlocks: PackedStringArray = state.progression_unlocks(from_level,to_level)
	var second_line: String = ""
	if not unlocks.is_empty():
		second_line = String(unlocks[unlocks.size()-1])
		if unlocks.size() > 1:
			second_line += " • +%d desbloqueio%s" % [unlocks.size()-1,"s" if unlocks.size()>2 else ""]
	level_banner_label.text = first_line+("\n"+second_line if second_line!="" else "\nHabilidade pronta para evoluir")
	level_banner.tooltip_text = "\n".join(unlocks) if not unlocks.is_empty() else "Você ganhou pontos de habilidade."
	level_banner_timer = 4.0
	level_banner.visible = true
	_layout()

func _draw() -> void:
	if host == null or quest_panel == null or is_blocked(): return
	var center: Vector2 = joystick_center if host.joystick_id < 0 else host.joystick_origin
	var area: Rect2 = UISkin.usable(get_viewport())
	draw_style_box(screen_frame,get_viewport().get_visible_rect().grow(-3))
	draw_style_box(rail_style,Rect2(area.position+Vector2(-2,50),Vector2(68,212)))
	if desktop_mode:
		return
	draw_circle(center,65,Color(0.05,0.16,0.15,0.57))
	draw_arc(center,65,0,TAU,64,Color("c8c79b"),2,true)
	var thumb: Vector2 = center+host.joystick_vector*34
	draw_circle(thumb,23,Color("173d40"))
	draw_arc(thumb,23,0,TAU,40,Color("d9d4a5"),2,true)
	for d: Vector2 in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		var c: Vector2 = center+d*51
		var side: Vector2 = d.orthogonal()*4
		draw_colored_polygon(PackedVector2Array([c+d*4,c-d*4+side,c-d*4-side]),Color("d9d4a5"))
	if host.get("interiors") == null or not host.interiors.active:
		var c: Vector2 = attack_button.position+attack_button.size*0.5
		var wedge = PackedVector2Array([c])
		for i in range(33): wedge.append(c+Vector2.from_angle(deg_to_rad(-125+140.0*i/32))*130)
		draw_colored_polygon(wedge,Color(0.26,0.035,0.03,0.83))
		draw_arc(c,130,deg_to_rad(-125),deg_to_rad(15),48,UISkin.GOLD,2,true)
		draw_arc(c,122,deg_to_rad(-125),deg_to_rad(15),48,Color("b5522d"),1,true)
		for angle in [-125.0,-81.0,-32.0,15.0]:
			var d: Vector2 = Vector2.from_angle(deg_to_rad(angle))
			draw_line(c+d*61,c+d*130,Color("a57535"),1.5,true)
			var p: Vector2 = c+d*130
			draw_colored_polygon(PackedVector2Array([p+Vector2(0,-3),p+Vector2(3,0),p+Vector2(0,3),p+Vector2(-3,0)]),UISkin.GOLD)

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
	if desktop_mode and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F11:
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	if desktop_mode and event is InputEventMouseButton and event.pressed and not is_blocked():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				host._attack()
				get_viewport().set_input_as_handled()
				return
			MOUSE_BUTTON_RIGHT:
				_dodge()
				get_viewport().set_input_as_handled()
				return
			MOUSE_BUTTON_WHEEL_UP:
				if host.get("zoom_controls") != null: host.zoom_controls.zoom_in()
				get_viewport().set_input_as_handled()
				return
			MOUSE_BUTTON_WHEEL_DOWN:
				if host.get("zoom_controls") != null: host.zoom_controls.zoom_out()
				get_viewport().set_input_as_handled()
				return
	if desktop_mode and event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_M:
			if host.map_open: host._toggle_map()
			elif not is_blocked(): host._toggle_map()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_I:
			var bag = host.get("inventory_ui")
			if bag != null:
				if bag.is_open(): bag.close_panel()
				elif not is_blocked(): bag.open_panel()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_F:
			var forge = host.get("crafting_ui")
			if forge != null:
				if forge.is_open(): forge.close_panel()
				elif not is_blocked(): forge._toggle()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_H and not is_blocked():
			_quick_heal()
			get_viewport().set_input_as_handled()
			return
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
	pause_panel.custom_minimum_size = Vector2(350,440)
	pause_panel.visible = false
	pause_panel.z_index = 100
	pause_panel.add_theme_stylebox_override("panel",UISkin.box())
	add_child(pause_panel)
	var body: Control = Control.new()
	body.name = "PauseContent"
	body.custom_minimum_size = Vector2(346,436)
	pause_panel.add_child(body)
	var title: Label = UISkin.label("Uma pausa na jornada",22)
	title.position = Vector2(24,16)
	body.add_child(title)
	var resume: Button = _button("CONTINUAR",Vector2(298,46),close_pause)
	resume.name = "ResumeButton"
	resume.position = Vector2(24,54)
	body.add_child(resume)
	var menu: Button = _button("SALVAR E VOLTAR AO MENU",Vector2(298,46),_return_to_menu)
	menu.name = "SaveAndMenuButton"
	menu.position = Vector2(24,108)
	body.add_child(menu)
	fullscreen_pause_button = _button("TELA INTEIRA",Vector2(298,46),_toggle_fullscreen)
	fullscreen_pause_button.name = "FullscreenButton"
	fullscreen_pause_button.position = Vector2(24,162)
	body.add_child(fullscreen_pause_button)
	exit_game_button = _button("SAIR DO JOGO",Vector2(298,46),_quit_game)
	exit_game_button.name = "ExitGameButton"
	exit_game_button.position = Vector2(24,216)
	UISkin.button(exit_game_button,Color("4b2028"),Color("d86a78"),10)
	body.add_child(exit_game_button)
	var note_text: String = "PC: WASD mover • Mouse/Space atacar • E usar/entrar • Shift esquiva • 1/2/3 magias • I bolsa • M mapa • J missões • F11 tela cheia" if desktop_mode else "Seu progresso fica salvo neste aparelho."
	var note: Label = UISkin.label(note_text,11,UISkin.MUTED)
	note.position = Vector2(24,350)
	note.size = Vector2(298,70)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(note)
	fullscreen_pause_button.visible = desktop_mode
	exit_game_button.visible = desktop_mode
	UISkin.bind(pause_panel,Vector2(350,440),"center",true)

func open_pause() -> void:
	if is_blocked(): return
	_refresh_fullscreen_button()
	pause_panel.visible = true
	get_tree().paused = true

func close_pause() -> void:
	pause_panel.visible = false
	get_tree().paused = false

func _toggle_fullscreen() -> void:
	if not desktop_mode: return
	var current_mode := DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
	call_deferred("_refresh_fullscreen_button")

func _refresh_fullscreen_button() -> void:
	if fullscreen_pause_button == null: return
	var fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_pause_button.text = "TELA INTEIRA: LIGADA" if fullscreen else "TELA INTEIRA: DESLIGADA"

func _quit_game() -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null: state.save_profile()
	if get_tree() != null:
		get_tree().paused = false
		get_tree().quit()

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

func _move_zoom_into_pause() -> void:
	var zoom = host.get("zoom_controls")
	if zoom == null: return
	zoom.reparent(pause_panel.get_node("PauseContent"))
	zoom.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	for child in zoom.panel.get_children():
		if child.get_script() == Placement:
			child.placement = "pause_zoom"
			child._layout()
	zoom.visible = true
	var forge = host.get("crafting_ui")
	if forge != null and forge.toggle_button != null:
		forge.toggle_button.pressed.disconnect(forge._toggle)
		forge.toggle_button.pressed.connect(func():
			close_pause()
			forge._toggle())
		forge.toggle_button.reparent(pause_panel.get_node("PauseContent"))
		for child in forge.toggle_button.get_children():
			if child.get_script() == Placement:
				child.placement = "pause_forge"
				child._layout()
