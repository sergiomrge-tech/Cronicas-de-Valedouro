extends Control
const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
const Journal = preload("res://scripts/cartoon/cartoon_mission_journal.gd")
var host
var panel: PanelContainer
var backdrop: ColorRect
var body: Control
var scroll: ScrollContainer
var rows: VBoxContainer
var close_button: Button
var summary: Label
var footer: Label
var tabs: Dictionary = {}
var current_tab: String = "active"
var notice: String = ""
func setup(host_node) -> void:
	host = host_node
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 125
	backdrop = ColorRect.new()
	backdrop.color = Color(0.025,0.055,0.045,0.88)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)
	panel = PanelContainer.new()
	panel.name = "MissionPanel"
	panel.add_theme_stylebox_override("panel",UISkin.box())
	add_child(panel)
	body = Control.new()
	panel.add_child(body)
	var title = UISkin.label("DIÁRIO DE MISSÕES",22,UISkin.GOLD)
	title.position = Vector2(16,12)
	body.add_child(title)
	summary = UISkin.label("",13,UISkin.MUTED)
	summary.position = Vector2(16,46)
	body.add_child(summary)
	close_button = _button("×",Vector2(44,44),close_panel)
	close_button.name = "CloseMissionButton"
	body.add_child(close_button)
	var index: int = 0
	for key in ["active","available","completed"]:
		var button = _button({"active":"ATIVAS","available":"DISPONÍVEIS","completed":"CONCLUÍDAS"}[key],Vector2(136,44),show_tab.bind(key))
		button.position = Vector2(16+index*144,74)
		body.add_child(button)
		tabs[key] = button
		index += 1
	scroll = ScrollContainer.new()
	scroll.name = "MissionScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	scroll.scroll_deadzone = 6
	scroll.follow_focus = true
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.gui_input.connect(_scroll_input)
	body.add_child(scroll)
	rows = VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.mouse_filter = Control.MOUSE_FILTER_PASS
	rows.add_theme_constant_override("separation",8)
	scroll.add_child(rows)
	footer = UISkin.label("",13,UISkin.MUTED)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(footer)
	get_viewport().size_changed.connect(_layout)
	close_panel()
	_layout()
func _scroll_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		scroll.scroll_vertical -= int(event.relative.y)
		scroll.accept_event()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll.scroll_vertical += 72
			scroll.accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll.scroll_vertical -= 72
			scroll.accept_event()

func _state(): return get_node("/root/CartoonPlayerState")
func _button(text: String, dimensions: Vector2, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.size = dimensions
	button.custom_minimum_size = dimensions
	button.add_theme_font_size_override("font_size",13)
	UISkin.button(button)
	button.pressed.connect(callback)
	return button
func is_open() -> bool: return panel != null and panel.visible
func open_panel() -> void:
	if host.get_node("HUD/GameLayout").is_blocked(): return
	panel.visible = true
	backdrop.visible = true
	host.joystick_id = -1
	host.joystick_vector = Vector2.ZERO
	host.hero.set_motion(Vector2.ZERO)
	notice = ""
	current_tab = "active"
	refresh()
	_layout()
func close_panel() -> void:
	if panel != null: panel.visible = false
	if backdrop != null: backdrop.visible = false
func show_tab(tab: String) -> void:
	if not tabs.has(tab): return
	current_tab = tab
	notice = ""
	refresh()
	scroll.scroll_vertical = 0
func refresh() -> void:
	for child in rows.get_children():
		rows.remove_child(child)
		child.queue_free()
	var state = _state()
	state.normalize_tracked_mission()
	var selected: String = "História principal" if state.tracked_mission=="main" else String(Journal.Contracts.row(state.tracked_mission).get("title",""))
	summary.text = "Acompanhando: "+selected
	for key in tabs: tabs[key].disabled = key==current_tab
	var entries: Array[Dictionary] = Journal.entries(host,state,current_tab)
	for item in entries: _card(item)
	if entries.is_empty(): rows.add_child(UISkin.label("Nenhuma missão nesta aba.",16,UISkin.MUTED))
	footer.text = notice if notice!="" else ("Aceite contratos no quadro da Guilda de Valedouro (máximo de 3 ativos)." if current_tab=="available" else "Acompanhe uma missão para exibir seu objetivo no HUD e no mapa.")
func _card(item: Dictionary) -> void:
	var card = PanelContainer.new()
	card.name = String(item.id)
	card.custom_minimum_size.y = 92
	card.add_theme_stylebox_override("panel",UISkin.box(Color("17352d"),UISkin.GOLD if _state().tracked_mission==item.id else Color("426956"),8))
	rows.add_child(card)
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	var margin = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	for side in ["left","top","right","bottom"]: margin.add_theme_constant_override("margin_"+side,9)
	card.add_child(margin)
	var line = HBoxContainer.new()
	line.mouse_filter = Control.MOUSE_FILTER_PASS
	line.add_theme_constant_override("separation",10)
	margin.add_child(line)
	var copy = VBoxContainer.new()
	copy.mouse_filter = Control.MOUSE_FILTER_PASS
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(copy)
	var title = UISkin.label(String(item.title),15,UISkin.GOLD)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_child(title)
	var detail = UISkin.label(String(item.description),12)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_child(detail)
	var meta = UISkin.label(String(item.category)+" • "+String(item.reward),11,UISkin.MUTED)
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_child(meta)
	var selected: bool = _state().tracked_mission==item.id
	var active: bool = item.status=="active"
	var button = _button("SEGUINDO" if selected else ("ACOMPANHAR" if active else ("NA GUILDA" if item.status=="available" else "CONCLUÍDA")),Vector2(118,44),_track.bind(String(item.id)))
	button.name = "TrackMissionButton"
	button.disabled = selected or not active
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(button)
func _track(id: String) -> void:
	if _state().set_tracked_mission(id): notice = "Missão selecionada. Feche o diário para seguir o objetivo."
	refresh()
func _layout() -> void:
	if panel==null: return
	backdrop.size = get_viewport().get_visible_rect().size
	var area: Rect2 = UISkin.usable(get_viewport())
	panel.size = Vector2(minf(880,area.size.x),minf(580,area.size.y))
	panel.position = area.get_center()-panel.size/2
	close_button.position = Vector2(panel.size.x-60,8)
	summary.size = Vector2(panel.size.x-36,22)
	summary.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	scroll.position = Vector2(16,128)
	scroll.size = Vector2(panel.size.x-30,panel.size.y-172)
	footer.position = Vector2(16,panel.size.y-38)
	footer.size = Vector2(panel.size.x-36,28)
