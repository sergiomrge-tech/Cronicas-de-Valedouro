class_name ValedouroCartoonClassUI
extends Control
const Classes = preload("res://scripts/cartoon/cartoon_class_catalog.gd")
const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
var host
var panel: PanelContainer
var backdrop: ColorRect
var body: Control
var summary: Label
var scroll: ScrollContainer
var rows: VBoxContainer
var close_button: Button
var classes_tab: Button
var skills_tab: Button
var refund_button: Button
var footer: Label
var current_tab: String = "classes"
var notice: String = ""
func setup(host_node) -> void:
	host = host_node
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 120
	backdrop = ColorRect.new()
	backdrop.name = "ClassBackdrop"
	backdrop.color = Color(0.025,0.055,0.045,0.86)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)
	panel = PanelContainer.new()
	panel.name = "ClassPanel"
	panel.add_theme_stylebox_override("panel",UISkin.box())
	add_child(panel)
	body = Control.new()
	body.name = "ClassContent"
	panel.add_child(body)
	var title = UISkin.label("Herói • Classes e habilidades",20)
	title.position = Vector2(16,10)
	body.add_child(title)
	summary = UISkin.label("",14,UISkin.GOLD)
	summary.position = Vector2(16,42)
	body.add_child(summary)
	close_button = _button("×",Vector2(44,44),close_panel)
	close_button.name = "CloseClassButton"
	body.add_child(close_button)
	classes_tab = _button("CLASSES",Vector2(136,44),show_tab.bind("classes"))
	classes_tab.position = Vector2(16,70)
	body.add_child(classes_tab)
	skills_tab = _button("HABILIDADES",Vector2(144,44),show_tab.bind("skills"))
	skills_tab.position = Vector2(160,70)
	body.add_child(skills_tab)
	scroll = ScrollContainer.new()
	scroll.name = "ClassScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	body.add_child(scroll)
	rows = VBoxContainer.new()
	rows.name = "ClassRows"
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation",10)
	scroll.add_child(rows)
	refund_button = _button("REEMBOLSAR",Vector2(132,44),_refund)
	refund_button.tooltip_text = "Devolver os pontos gastos na classe ativa. As outras classes permanecem intactas."
	body.add_child(refund_button)
	footer = UISkin.label("",12,UISkin.MUTED)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(footer)
	get_viewport().size_changed.connect(_layout)
	close_panel()
	_layout()
func _state(): return get_node("/root/CartoonPlayerState")
func _button(copy: String, dimensions: Vector2, callback: Callable) -> Button:
	var button = Button.new()
	button.text = copy
	button.custom_minimum_size = dimensions
	button.size = dimensions
	UISkin.button(button)
	button.pressed.connect(callback)
	return button
func is_open() -> bool: return panel != null and panel.visible
func open_panel() -> void:
	var layout = host.get_node("HUD/GameLayout")
	if layout.is_blocked(): return
	notice = ""
	panel.visible = true
	backdrop.visible = true
	host.joystick_id = -1
	host.joystick_vector = Vector2.ZERO
	host.hero.set_motion(Vector2.ZERO)
	_refresh()
	_layout()
func close_panel() -> void:
	if panel != null: panel.visible = false
	if backdrop != null: backdrop.visible = false
func show_tab(tab: String) -> void:
	current_tab = tab
	notice = ""
	_refresh()
	scroll.scroll_vertical = 0
func _card(name_copy: String, description: String, action: String, callback: Callable, disabled: bool, color: Color, rank: int = -1) -> void:
	var card = PanelContainer.new()
	card.custom_minimum_size.y = 100 if rank<0 else 116
	card.add_theme_stylebox_override("panel",UISkin.box(Color(0.08,0.17,0.14),color.darkened(0.4),8))
	rows.add_child(card)
	var margin = MarginContainer.new()
	for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,12)
	card.add_child(margin)
	var line = HBoxContainer.new()
	line.add_theme_constant_override("separation",14)
	margin.add_child(line)
	var text = VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(text)
	var title = UISkin.label(name_copy,18,color)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_child(title)
	var detail = UISkin.label(description,13)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_child(detail)
	if rank>=0:
		var progress = ProgressBar.new()
		progress.max_value = Classes.MAX_RANK
		progress.value = rank
		progress.show_percentage = false
		progress.custom_minimum_size.y = 6
		progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
		progress.add_theme_stylebox_override("background",UISkin.box(UISkin.INK,UISkin.INK,2))
		progress.add_theme_stylebox_override("fill",UISkin.box(color,color,2))
		text.add_child(progress)
	var button = _button(action,Vector2(132,52),callback)
	button.name = "ActionButton"
	button.disabled = disabled
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(button)
func _refresh() -> void:
	for child in rows.get_children():
		rows.remove_child(child)
		child.queue_free()
	var state = _state()
	var active: Dictionary = Classes.class_row(state.active_class)
	summary.text = "%s • Nível %d • %d pontos disponíveis" % [active.name,state.player_level,state.available_skill_points()]
	summary.add_theme_color_override("font_color",Color(active.color))
	classes_tab.disabled = current_tab=="classes"
	skills_tab.disabled = current_tab=="skills"
	var spent: int = 0
	for id in active.skills: spent += state.skill_rank(id,false)
	refund_button.disabled = spent==0
	footer.text = notice if notice!="" else ("Troca gratuita. Cada classe mantém suas habilidades; só a classe ativa aplica os bônus." if current_tab=="classes" else "1 ponto inicial +1 por nível ganho. Cada evolução custa 1 ponto e exige o nível indicado.")
	if current_tab=="classes":
		for row in Classes.CLASSES:
			var ranks: int = 0
			for id in row.skills: ranks += state.skill_rank(id,false)
			_card(row.name,row.description+"\n%d graus aprendidos."%ranks,"ATIVA" if row.id==state.active_class else "TROCAR",_switch.bind(row.id),row.id==state.active_class,Color(row.color))
	else:
		for id in active.skills:
			var row: Dictionary = Classes.SKILLS[id]
			var rank: int = state.skill_rank(id,false)
			var error: String = state.skill_upgrade_error(id)
			var requirement: String = "Grau máximo" if rank>=Classes.MAX_RANK else "Próximo grau: nível %d" % Classes.required_level(rank+1)
			var action: String = "EVOLUIR\n1 ponto"
			if rank>=Classes.MAX_RANK: action = "MÁXIMO"
			elif state.player_level<Classes.required_level(rank+1): action = "NÍVEL %d" % Classes.required_level(rank+1)
			elif state.available_skill_points()<=0: action = "SEM PONTOS"
			_card("%s • %d/%d"%[row.name,rank,Classes.MAX_RANK],row.description+"\n"+requirement,action,_upgrade.bind(id),error!="",Color(active.color),rank)
func _switch(id: String) -> void:
	if _state().set_class(id): notice = "Classe alterada. Vida, equipamentos, missões e recargas foram preservados."
	_refresh()
	host._refresh_stats()
func _upgrade(id: String) -> void:
	notice = "Habilidade evoluída!" if _state().upgrade_skill(id) else _state().skill_upgrade_error(id)
	_refresh()
	host._refresh_stats()
func _refund() -> void:
	var count: int = _state().refund_class_skills()
	notice = "%d pontos devolvidos da classe ativa." % count
	_refresh()
	host._refresh_stats()
func _layout() -> void:
	if panel == null: return
	backdrop.position = Vector2.ZERO
	backdrop.size = get_viewport().get_visible_rect().size
	var area: Rect2 = UISkin.usable(get_viewport())
	panel.size = Vector2(minf(880,area.size.x),minf(580,area.size.y))
	panel.position = area.get_center()-panel.size/2
	close_button.position = Vector2(panel.size.x-60,8)
	summary.size = Vector2(panel.size.x-36,22)
	scroll.position = Vector2(16,126)
	scroll.size = Vector2(panel.size.x-36,panel.size.y-188)
	refund_button.position = Vector2(16,panel.size.y-54)
	footer.position = Vector2(160,panel.size.y-54)
	footer.size = Vector2(panel.size.x-182,46)
