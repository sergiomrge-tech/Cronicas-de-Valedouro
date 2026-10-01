extends Control
const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
const Contracts = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")
var host
var panel: PanelContainer
var list: VBoxContainer
var note: Label
func setup(owner_node) -> void:
	host = owner_node
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 120
	panel = PanelContainer.new()
	panel.name = "GuildBoardPanel"
	panel.visible = false
	panel.add_theme_stylebox_override("panel",UISkin.box(UISkin.INK,UISkin.GOLD))
	add_child(panel)
	var body: Control = Control.new()
	body.custom_minimum_size = Vector2(786,456)
	panel.add_child(body)
	var title: Label = UISkin.label("QUADRO DE CONTRATOS",23,Color("efc873"))
	title.position = Vector2(22,17)
	body.add_child(title)
	var close: Button = Button.new()
	close.text = "×"
	close.position = Vector2(714,6)
	close.size = Vector2(64,58)
	UISkin.button(close)
	close.pressed.connect(close_panel)
	body.add_child(close)
	note = UISkin.label("",13,UISkin.MUTED)
	note.position = Vector2(22,55)
	note.size = Vector2(685,30)
	note.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	body.add_child(note)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.position = Vector2(20,89)
	scroll.size = Vector2(746,352)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation",10)
	scroll.add_child(list)
	UISkin.bind(panel,Vector2(790,460),"center",true)
func is_open() -> bool:
	return panel != null and panel.visible
func open_panel() -> void:
	host.inventory_ui.close_panel()
	host.crafting_ui.close_panel()
	if host.map_open: host._toggle_map()
	panel.visible = true
	host.joystick_id = -1
	host.joystick_vector = Vector2.ZERO
	refresh()
func close_panel() -> void:
	panel.visible = false
func refresh() -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	var state = get_node("/root/CartoonPlayerState")
	note.text = "Até 3 contratos ativos • Carne %d • Couro %d • Recompensas na guilda" % [state.material_count("Carne de caça"),state.material_count("Couro do Vale")]
	var active_count: int = 0
	for value in state.guild_contracts.values():
		if value.get("status","") == "active": active_count += 1
	for item in Contracts.ROWS:
		var card: PanelContainer = PanelContainer.new()
		card.custom_minimum_size.y = 126
		card.add_theme_stylebox_override("panel",UISkin.box(UISkin.SURFACE,UISkin.GOLD.darkened(0.5),8))
		list.add_child(card)
		var body: HBoxContainer = HBoxContainer.new()
		body.add_theme_constant_override("separation",12)
		card.add_child(body)
		var margin: MarginContainer = MarginContainer.new()
		for key in ["margin_left","margin_top","margin_bottom"]: margin.add_theme_constant_override(key,12)
		margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		body.add_child(margin)
		var copy: VBoxContainer = VBoxContainer.new()
		margin.add_child(copy)
		var title: Label = UISkin.label(item.title,16,UISkin.GOLD.lightened(0.25))
		copy.add_child(title)
		var desc: Label = UISkin.label(item.description,13)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.custom_minimum_size.x = 460
		copy.add_child(desc)
		var p: int = Contracts.progress(state,item.id)
		copy.add_child(UISkin.label("%d/%d • %d ouro + %d XP" % [p,item.count,item.gold,item.xp],13,UISkin.MUTED))
		var action_margin: MarginContainer = MarginContainer.new()
		action_margin.add_theme_constant_override("margin_right",12)
		action_margin.add_theme_constant_override("margin_top",24)
		action_margin.add_theme_constant_override("margin_bottom",24)
		body.add_child(action_margin)
		var action: Button = Button.new()
		action.custom_minimum_size = Vector2(150,64)
		action.name = item.id
		var status: String = Contracts.status(state,item.id)
		action.text = "ACEITAR" if status == "available" else ("CONCLUÍDO" if status == "claimed" else ("RECEBER" if p >= item.count else "EM ANDAMENTO"))
		action.disabled = status == "claimed" or (status == "active" and p < item.count) or (status == "available" and active_count >= Contracts.MAX_ACTIVE)
		if status == "available" and active_count >= Contracts.MAX_ACTIVE:
			action.text = "LIMITE: 3 ATIVOS"
			action.tooltip_text = "Entregue um contrato concluído antes de aceitar outro."
		UISkin.button(action)
		action.pressed.connect(_action.bind(String(item.id)))
		action_margin.add_child(action)
func _action(id: String) -> void:
	var state = get_node("/root/CartoonPlayerState")
	var message: String = ""
	if Contracts.status(state,id) == "available":
		if not Contracts.accept(state,id): message = "Você já tem 3 contratos ativos. Conclua um para aceitar outro."
		else: message = "Contrato aceito: "+String(Contracts.row(id).title)
	else:
		if Contracts.claim(state,host,id): message = "Contrato entregue. Ouro e XP recebidos!"
	refresh()
	note.text = message
	note.tooltip_text = message
