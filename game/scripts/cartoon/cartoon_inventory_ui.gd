class_name ValedouroCartoonInventoryUI
extends Control

var host
var hero: Node2D
var panel: PanelContainer
var list_box: VBoxContainer
var title_label: Label
var equipment_label: Label
var count_label: Label
var equipment_tab: Button
var materials_tab: Button
var current_tab: String = "equipment"
var toggle_button: Button

func setup(host_node = null, hero_node: Node2D = null, show_toggle: bool = true) -> void:
	host = host_node
	hero = hero_node
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build(show_toggle)
	_refresh()

func _state():
	return get_node_or_null("/root/CartoonPlayerState")

func is_open() -> bool:
	return panel != null and panel.visible

func open_panel(tab: String = "equipment") -> void:
	current_tab = tab
	panel.visible = true
	_close_other_panels()
	_refresh()

func close_panel() -> void:
	if panel != null:
		panel.visible = false

func _toggle() -> void:
	if panel.visible:
		close_panel()
	else:
		open_panel(current_tab)

func _close_other_panels() -> void:
	if host == null:
		return
	var forge = host.get("crafting_ui")
	if forge != null and forge.has_method("close_panel"):
		forge.call("close_panel")

func _build(show_toggle: bool) -> void:
	if show_toggle:
		toggle_button = Button.new()
		toggle_button.name = "InventoryButton"
		toggle_button.text = "BOLSA"
		toggle_button.position = Vector2(574,18)
		toggle_button.size = Vector2(104,46)
		toggle_button.mouse_filter = Control.MOUSE_FILTER_STOP
		toggle_button.add_theme_font_size_override("font_size",15)
		_style_button(toggle_button,Color(0.22,0.18,0.32),Color(0.78,0.62,0.93))
		toggle_button.pressed.connect(_toggle)
		add_child(toggle_button)

	panel = PanelContainer.new()
	panel.name = "InventoryPanel"
	panel.position = Vector2(128,64)
	panel.size = Vector2(704,420)
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var pstyle: StyleBoxFlat = StyleBoxFlat.new()
	pstyle.bg_color = Color(0.035,0.045,0.07,0.985)
	pstyle.border_color = Color(0.91,0.69,0.27)
	pstyle.set_border_width_all(4)
	pstyle.corner_radius_top_left = 20
	pstyle.corner_radius_top_right = 20
	pstyle.corner_radius_bottom_left = 20
	pstyle.corner_radius_bottom_right = 20
	panel.add_theme_stylebox_override("panel",pstyle)
	add_child(panel)

	title_label = Label.new()
	title_label.position = Vector2(28,18)
	title_label.size = Vector2(480,34)
	title_label.text = "INVENTÁRIO DO VIAJANTE"
	title_label.add_theme_font_size_override("font_size",22)
	title_label.add_theme_color_override("font_color",Color(1.0,0.85,0.42))
	panel.add_child(title_label)

	count_label = Label.new()
	count_label.position = Vector2(500,22)
	count_label.size = Vector2(145,28)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.add_theme_font_size_override("font_size",13)
	count_label.add_theme_color_override("font_color",Color(0.74,0.81,0.88))
	panel.add_child(count_label)

	var close: Button = Button.new()
	close.text = "×"
	close.position = Vector2(650,12)
	close.size = Vector2(40,40)
	close.mouse_filter = Control.MOUSE_FILTER_STOP
	close.add_theme_font_size_override("font_size",22)
	_style_button(close,Color(0.23,0.10,0.13),Color(0.74,0.34,0.37))
	close.pressed.connect(close_panel)
	panel.add_child(close)

	equipment_label = Label.new()
	equipment_label.position = Vector2(28,60)
	equipment_label.size = Vector2(646,56)
	equipment_label.add_theme_font_size_override("font_size",14)
	equipment_label.add_theme_color_override("font_color",Color(0.94,0.93,0.88))
	panel.add_child(equipment_label)

	equipment_tab = Button.new()
	equipment_tab.text = "EQUIPAMENTOS"
	equipment_tab.position = Vector2(28,122)
	equipment_tab.size = Vector2(190,42)
	equipment_tab.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(equipment_tab,Color(0.15,0.25,0.38),Color(0.37,0.68,0.94))
	equipment_tab.pressed.connect(func(): _set_tab("equipment"))
	panel.add_child(equipment_tab)

	materials_tab = Button.new()
	materials_tab.text = "MATERIAIS"
	materials_tab.position = Vector2(226,122)
	materials_tab.size = Vector2(170,42)
	materials_tab.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(materials_tab,Color(0.18,0.31,0.24),Color(0.42,0.79,0.52))
	materials_tab.pressed.connect(func(): _set_tab("materials"))
	panel.add_child(materials_tab)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.position = Vector2(28,174)
	scroll.size = Vector2(648,220)
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(scroll)

	list_box = VBoxContainer.new()
	list_box.custom_minimum_size = Vector2(625,0)
	list_box.add_theme_constant_override("separation",8)
	scroll.add_child(list_box)

func _set_tab(tab: String) -> void:
	current_tab = tab
	_refresh()

func _refresh() -> void:
	var state = _state()
	if state == null or panel == null:
		return
	equipment_label.text = state.equipment_summary()
	count_label.text = state.profile_summary()
	for child in list_box.get_children():
		child.queue_free()
	if current_tab == "materials":
		_fill_materials(state)
	else:
		_fill_equipment(state)

func _fill_equipment(state) -> void:
	var items: Array[Dictionary] = state.owned_equipment()
	if items.is_empty():
		_add_empty("Nenhum equipamento encontrado.")
		return
	for item in items:
		var id: String = String(item.get("id",""))
		var slot: String = String(item.get("slot",""))
		var stat_value: int = int(item.get("attack",0) if slot == "weapon" else item.get("defense",0))
		var stat_name: String = "ATQ" if slot == "weapon" else "DEF"
		var equipped: bool = state.is_equipped(id)
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(620,54)
		button.text = "%s%s   •   Tier %d   •   +%d %s\n%s" % [
			"✓ " if equipped else "",
			String(item.get("label","Equipamento")),
			int(item.get("tier",0)),
			stat_value,
			stat_name,
			"EQUIPADO" if equipped else "Toque para equipar"
		]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		_style_button(button,
			Color(0.18,0.30,0.22) if equipped else Color(0.10,0.12,0.18),
			Color(0.48,0.82,0.50) if equipped else Color(0.43,0.53,0.68))
		button.pressed.connect(func(): _equip(id))
		list_box.add_child(button)

func _fill_materials(state) -> void:
	var keys: Array = state.materials.keys()
	keys.sort()
	var any: bool = false
	for key in keys:
		var amount: int = int(state.materials[key])
		if amount <= 0:
			continue
		any = true
		var row: Label = Label.new()
		row.custom_minimum_size = Vector2(620,42)
		row.text = "◆  %-36s  × %d" % [String(key),amount]
		row.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_theme_font_size_override("font_size",16)
		row.add_theme_color_override("font_color",Color(0.82,0.92,0.84))
		list_box.add_child(row)
	if not any:
		_add_empty("Explore o mundo para encontrar materiais de fabricação.")

func _add_empty(text_value: String) -> void:
	var label: Label = Label.new()
	label.custom_minimum_size = Vector2(620,80)
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color",Color(0.68,0.70,0.75))
	list_box.add_child(label)

func _equip(item_id: String) -> void:
	var state = _state()
	if state == null:
		return
	var result: Dictionary = state.equip_item(item_id)
	if hero != null and hero.has_method("apply_equipment_from_state"):
		hero.call("apply_equipment_from_state")
	_refresh()
	if host != null and host.has_method("_show_toast"):
		host.call("_show_toast",String(result.get("message","Inventário atualizado.")))

func _style_button(button: Button, bg: Color, border: Color) -> void:
	for state_name in ["normal","hover","pressed","focus","disabled"]:
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = bg.lightened(0.06) if state_name == "hover" else (bg.darkened(0.08) if state_name == "pressed" else bg)
		box.border_color = border
		box.set_border_width_all(2)
		box.corner_radius_top_left = 11
		box.corner_radius_top_right = 11
		box.corner_radius_bottom_left = 11
		box.corner_radius_bottom_right = 11
		button.add_theme_stylebox_override(state_name,box)
