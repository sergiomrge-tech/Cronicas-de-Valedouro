class_name ValedouroCartoonInventoryUI
extends Control

const EQUIPMENT_CAPACITY: int = 30

var host
var hero: Node2D
var panel: PanelContainer
var content: Control
var list_box: Container
var title_label: Label
var equipment_label: Label
var count_label: Label
var equipment_tab: Button
var materials_tab: Button
var weapons_tab: Button
var armor_tab: Button
var current_tab: String = "equipment"
var equipment_filter: String = "all"
var toggle_button: Button

var weapon_slot: Button
var armor_slot: Button
var detail_name: Label
var detail_meta: Label
var detail_compare: Label
var detail_action: Button
var selected_item_id: String = ""
var selected_material: String = ""

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
	if tab == "materials":
		current_tab = "materials"
	elif tab in ["weapon","armor"]:
		current_tab = "equipment"
		equipment_filter = tab
	else:
		current_tab = "equipment"
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
	panel.position = Vector2(65,42)
	panel.size = Vector2(830,456)
	panel.custom_minimum_size = Vector2(830,456)
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var pstyle: StyleBoxFlat = StyleBoxFlat.new()
	pstyle.bg_color = Color(0.025,0.032,0.052,0.992)
	pstyle.border_color = Color(0.91,0.69,0.27)
	pstyle.set_border_width_all(4)
	pstyle.corner_radius_top_left = 22
	pstyle.corner_radius_top_right = 22
	pstyle.corner_radius_bottom_left = 22
	pstyle.corner_radius_bottom_right = 22
	panel.add_theme_stylebox_override("panel",pstyle)
	add_child(panel)

	content = Control.new()
	content.name = "InventoryContent"
	content.custom_minimum_size = Vector2(814,440)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(content)

	title_label = Label.new()
	title_label.position = Vector2(24,14)
	title_label.size = Vector2(430,34)
	title_label.text = "INVENTÁRIO DO VIAJANTE"
	title_label.add_theme_font_size_override("font_size",22)
	title_label.add_theme_color_override("font_color",Color(1.0,0.85,0.42))
	content.add_child(title_label)

	count_label = Label.new()
	count_label.position = Vector2(438,18)
	count_label.size = Vector2(310,26)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.add_theme_font_size_override("font_size",12)
	count_label.add_theme_color_override("font_color",Color(0.73,0.81,0.88))
	content.add_child(count_label)

	var close: Button = Button.new()
	close.text = "×"
	close.position = Vector2(756,8)
	close.size = Vector2(42,42)
	close.mouse_filter = Control.MOUSE_FILTER_STOP
	close.add_theme_font_size_override("font_size",22)
	_style_button(close,Color(0.23,0.10,0.13),Color(0.74,0.34,0.37))
	close.pressed.connect(close_panel)
	content.add_child(close)

	var equipped_title: Label = Label.new()
	equipped_title.position = Vector2(24,58)
	equipped_title.size = Vector2(190,26)
	equipped_title.text = "EQUIPADO"
	equipped_title.add_theme_font_size_override("font_size",16)
	equipped_title.add_theme_color_override("font_color",Color(0.95,0.78,0.36))
	content.add_child(equipped_title)

	weapon_slot = Button.new()
	weapon_slot.name = "WeaponSlot"
	weapon_slot.position = Vector2(24,90)
	weapon_slot.size = Vector2(194,88)
	weapon_slot.alignment = HORIZONTAL_ALIGNMENT_LEFT
	weapon_slot.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(weapon_slot,Color(0.10,0.14,0.21),Color(0.78,0.58,0.24))
	weapon_slot.pressed.connect(_select_equipped_slot.bind("weapon"))
	content.add_child(weapon_slot)

	armor_slot = Button.new()
	armor_slot.name = "ArmorSlot"
	armor_slot.position = Vector2(24,188)
	armor_slot.size = Vector2(194,88)
	armor_slot.alignment = HORIZONTAL_ALIGNMENT_LEFT
	armor_slot.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(armor_slot,Color(0.10,0.14,0.21),Color(0.49,0.69,0.90))
	armor_slot.pressed.connect(_select_equipped_slot.bind("armor"))
	content.add_child(armor_slot)

	equipment_label = Label.new()
	equipment_label.position = Vector2(24,292)
	equipment_label.size = Vector2(194,78)
	equipment_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	equipment_label.add_theme_font_size_override("font_size",13)
	equipment_label.add_theme_color_override("font_color",Color(0.86,0.88,0.86))
	content.add_child(equipment_label)

	var hint: Label = Label.new()
	hint.position = Vector2(24,382)
	hint.size = Vector2(194,40)
	hint.text = "Toque em um item para ver\ndetalhes e comparar."
	hint.add_theme_font_size_override("font_size",11)
	hint.add_theme_color_override("font_color",Color(0.57,0.64,0.70))
	content.add_child(hint)

	equipment_tab = _tab_button("TODOS",Vector2(240,58),94)
	equipment_tab.name = "AllItemsTab"
	equipment_tab.pressed.connect(func(): _set_tab("equipment"))
	content.add_child(equipment_tab)

	weapons_tab = _tab_button("ARMAS",Vector2(340,58),92)
	weapons_tab.name = "WeaponsTab"
	weapons_tab.pressed.connect(func(): _set_tab("weapon"))
	content.add_child(weapons_tab)

	armor_tab = _tab_button("ARMADURAS",Vector2(438,58),112)
	armor_tab.name = "ArmorTab"
	armor_tab.pressed.connect(func(): _set_tab("armor"))
	content.add_child(armor_tab)

	materials_tab = _tab_button("MATERIAIS",Vector2(556,58),112)
	materials_tab.name = "MaterialsTab"
	materials_tab.pressed.connect(func(): _set_tab("materials"))
	content.add_child(materials_tab)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.position = Vector2(240,108)
	scroll.size = Vector2(354,314)
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	content.add_child(scroll)

	var grid: GridContainer = GridContainer.new()
	grid.name = "InventoryGrid"
	grid.columns = 2
	grid.custom_minimum_size = Vector2(334,0)
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	scroll.add_child(grid)
	list_box = grid

	var details: PanelContainer = PanelContainer.new()
	details.position = Vector2(608,108)
	details.size = Vector2(190,314)
	var dstyle: StyleBoxFlat = StyleBoxFlat.new()
	dstyle.bg_color = Color(0.055,0.067,0.09,0.97)
	dstyle.border_color = Color(0.34,0.43,0.56)
	dstyle.set_border_width_all(2)
	dstyle.corner_radius_top_left = 14
	dstyle.corner_radius_top_right = 14
	dstyle.corner_radius_bottom_left = 14
	dstyle.corner_radius_bottom_right = 14
	details.add_theme_stylebox_override("panel",dstyle)
	content.add_child(details)

	var detail_content: Control = Control.new()
	detail_content.custom_minimum_size = Vector2(182,306)
	details.add_child(detail_content)

	var detail_title: Label = Label.new()
	detail_title.position = Vector2(14,12)
	detail_title.size = Vector2(154,24)
	detail_title.text = "DETALHES"
	detail_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_title.add_theme_font_size_override("font_size",14)
	detail_title.add_theme_color_override("font_color",Color(0.77,0.84,0.91))
	detail_content.add_child(detail_title)

	detail_name = Label.new()
	detail_name.position = Vector2(14,46)
	detail_name.size = Vector2(154,58)
	detail_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	detail_name.add_theme_font_size_override("font_size",16)
	detail_name.add_theme_color_override("font_color",Color(1.0,0.84,0.39))
	detail_content.add_child(detail_name)

	detail_meta = Label.new()
	detail_meta.position = Vector2(14,112)
	detail_meta.size = Vector2(154,64)
	detail_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_meta.add_theme_font_size_override("font_size",13)
	detail_meta.add_theme_color_override("font_color",Color(0.88,0.91,0.92))
	detail_content.add_child(detail_meta)

	detail_compare = Label.new()
	detail_compare.position = Vector2(14,180)
	detail_compare.size = Vector2(154,58)
	detail_compare.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_compare.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_compare.add_theme_font_size_override("font_size",12)
	detail_content.add_child(detail_compare)

	detail_action = Button.new()
	detail_action.name = "EquipSelectedButton"
	detail_action.text = "EQUIPAR"
	detail_action.position = Vector2(16,250)
	detail_action.size = Vector2(150,44)
	detail_action.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(detail_action,Color(0.15,0.29,0.20),Color(0.45,0.82,0.50))
	detail_action.pressed.connect(_equip_selected)
	detail_content.add_child(detail_action)

func _tab_button(text_value: String,pos: Vector2,width: float) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.position = pos
	button.size = Vector2(width,38)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size",12)
	_style_button(button,Color(0.10,0.13,0.19),Color(0.38,0.49,0.62))
	return button

func _set_tab(tab: String) -> void:
	selected_material = ""
	if tab == "materials":
		current_tab = "materials"
	elif tab == "weapon":
		current_tab = "equipment"
		equipment_filter = "weapon"
	elif tab == "armor":
		current_tab = "equipment"
		equipment_filter = "armor"
	else:
		current_tab = "equipment"
		equipment_filter = "all"
	_refresh()

func _refresh() -> void:
	var state = _state()
	if state == null or panel == null:
		return
	var items: Array[Dictionary] = state.owned_equipment()
	equipment_label.text = state.equipment_summary()
	count_label.text = "Equipamentos %d/%d   •   Materiais %d" % [items.size(),EQUIPMENT_CAPACITY,state.material_total()]
	_refresh_equipped_slots(state)
	for child in list_box.get_children():
		child.queue_free()
	if current_tab == "materials":
		_fill_materials(state)
	else:
		_fill_equipment(state)
	_refresh_detail(state)

func _refresh_equipped_slots(state) -> void:
	var weapon: Dictionary = state.equipped_weapon
	var armor: Dictionary = state.equipped_armor
	weapon_slot.text = "ARMA\n%s\n+%d ATQ" % [String(weapon.get("label","Espada de Viagem")),int(weapon.get("attack",0))]
	armor_slot.text = "ARMADURA\n%s\n+%d DEF" % [String(armor.get("label","Túnica de Viagem")),int(armor.get("defense",0))]

func _select_equipped_slot(slot: String) -> void:
	var state = _state()
	if state == null:
		return
	var item: Dictionary = state.equipped_weapon if slot == "weapon" else state.equipped_armor
	_select_item(String(item.get("id","")))

func _fill_equipment(state) -> void:
	var items: Array[Dictionary] = state.owned_equipment()
	var visible_items: Array[Dictionary] = []
	for item in items:
		var slot: String = String(item.get("slot",""))
		if equipment_filter != "all" and slot != equipment_filter:
			continue
		visible_items.append(item)
	if visible_items.is_empty():
		_add_empty("Nenhum equipamento\nneste filtro.")
		selected_item_id = ""
		return
	if selected_item_id == "" or _item_by_id(state,selected_item_id).is_empty():
		selected_item_id = String(visible_items[0].get("id",""))
	for item in visible_items:
		var id: String = String(item.get("id",""))
		var slot: String = String(item.get("slot",""))
		var stat_value: int = _item_stat(item)
		var stat_name: String = "ATQ" if slot == "weapon" else "DEF"
		var equipped: bool = state.is_equipped(id)
		var tier: int = int(item.get("tier",0))
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(160,82)
		button.text = "%s%s\n%s • Tier %d\n+%d %s%s" % [
			"◆ " if id == selected_item_id else "",
			String(item.get("label","Equipamento")),
			_rarity_name(tier),
			tier,
			stat_value,
			stat_name,
			" • EQUIPADO" if equipped else ""
		]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		_style_button(button,Color(0.085,0.105,0.15),_rarity_color(tier))
		button.pressed.connect(_select_item.bind(id))
		list_box.add_child(button)

func _fill_materials(state) -> void:
	var keys: Array = state.materials.keys()
	keys.sort()
	var active: Array[String] = []
	for key_value in keys:
		var key: String = String(key_value)
		if int(state.materials[key]) > 0:
			active.append(key)
	if active.is_empty():
		_add_empty("Nenhum material.\nExplore as regiões.")
		selected_material = ""
		return
	if selected_material == "" or selected_material not in active:
		selected_material = active[0]
	for key in active:
		var amount: int = int(state.materials[key])
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(160,72)
		button.text = "%s%s\nQuantidade: %d" % ["◆ " if key == selected_material else "",key,amount]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		_style_button(button,Color(0.08,0.14,0.12),Color(0.40,0.73,0.52))
		button.pressed.connect(_select_material.bind(key))
		list_box.add_child(button)

func _add_empty(text_value: String) -> void:
	var label: Label = Label.new()
	label.custom_minimum_size = Vector2(330,100)
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color",Color(0.66,0.70,0.76))
	list_box.add_child(label)

func _select_item(item_id: String) -> void:
	selected_item_id = item_id
	selected_material = ""
	current_tab = "equipment"
	_refresh()

func _select_material(material_name: String) -> void:
	selected_material = material_name
	selected_item_id = ""
	current_tab = "materials"
	_refresh()

func _refresh_detail(state) -> void:
	if current_tab == "materials":
		detail_action.visible = false
		if selected_material == "":
			detail_name.text = "Materiais"
			detail_meta.text = "Nenhum material selecionado."
			detail_compare.text = ""
			return
		detail_name.text = selected_material
		detail_meta.text = "Quantidade: %d\nMaterial de fabricação" % int(state.materials.get(selected_material,0))
		detail_compare.text = "Usado na Forja para criar equipamentos das regiões de Elyndor."
		detail_compare.add_theme_color_override("font_color",Color(0.56,0.82,0.64))
		return

	detail_action.visible = true
	var item: Dictionary = _item_by_id(state,selected_item_id)
	if item.is_empty():
		detail_name.text = "Selecione um item"
		detail_meta.text = ""
		detail_compare.text = ""
		detail_action.disabled = true
		return
	var slot: String = String(item.get("slot",""))
	var tier: int = int(item.get("tier",0))
	var stat: int = _item_stat(item)
	var equipped_item: Dictionary = state.equipped_weapon if slot == "weapon" else state.equipped_armor
	var equipped_stat: int = _item_stat(equipped_item)
	var diff: int = stat-equipped_stat
	var stat_name: String = "ATQ" if slot == "weapon" else "DEF"
	var equipped: bool = state.is_equipped(String(item.get("id","")))
	detail_name.text = String(item.get("label","Equipamento"))
	detail_meta.text = "%s • Tier %d\n%s  +%d %s" % [_rarity_name(tier),tier,"ARMA" if slot=="weapon" else "ARMADURA",stat,stat_name]
	if equipped:
		detail_compare.text = "Item equipado atualmente."
		detail_compare.add_theme_color_override("font_color",Color(0.50,0.85,0.55))
	elif diff > 0:
		detail_compare.text = "+%d %s em relação ao equipado." % [diff,stat_name]
		detail_compare.add_theme_color_override("font_color",Color(0.50,0.85,0.55))
	elif diff < 0:
		detail_compare.text = "%d %s em relação ao equipado." % [diff,stat_name]
		detail_compare.add_theme_color_override("font_color",Color(0.90,0.55,0.48))
	else:
		detail_compare.text = "Mesmo valor de %s do equipado." % stat_name
		detail_compare.add_theme_color_override("font_color",Color(0.78,0.78,0.74))
	detail_action.disabled = equipped
	detail_action.text = "EQUIPADO" if equipped else "EQUIPAR"

func _equip_selected() -> void:
	if selected_item_id == "":
		return
	var state = _state()
	if state == null:
		return
	var result: Dictionary = state.equip_item(selected_item_id)
	if hero != null and hero.has_method("apply_equipment_from_state"):
		hero.call("apply_equipment_from_state")
	_refresh()
	if host != null and host.has_method("_show_toast"):
		host.call("_show_toast",String(result.get("message","Inventário atualizado.")))

func _equip(item_id: String) -> void:
	# Compatibilidade com a API v0.15.
	selected_item_id = item_id
	_equip_selected()

func _item_by_id(state,item_id: String) -> Dictionary:
	for item in state.owned_equipment():
		if String(item.get("id","")) == item_id:
			return item
	return {}

func _item_stat(item: Dictionary) -> int:
	return int(item.get("attack",0)) if String(item.get("slot","")) == "weapon" else int(item.get("defense",0))

func _rarity_name(tier: int) -> String:
	if tier >= 7:
		return "Lendário"
	if tier >= 5:
		return "Épico"
	if tier >= 3:
		return "Raro"
	if tier >= 1:
		return "Incomum"
	return "Comum"

func _rarity_color(tier: int) -> Color:
	if tier >= 7:
		return Color(0.96,0.72,0.22)
	if tier >= 5:
		return Color(0.71,0.43,0.91)
	if tier >= 3:
		return Color(0.32,0.62,0.96)
	if tier >= 1:
		return Color(0.35,0.78,0.48)
	return Color(0.52,0.58,0.64)

func _style_button(button: Button, bg: Color, border: Color) -> void:
	for state_name in ["normal","hover","pressed","focus","disabled"]:
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = bg.lightened(0.06) if state_name == "hover" else (bg.darkened(0.08) if state_name == "pressed" else (bg.darkened(0.22) if state_name == "disabled" else bg))
		box.border_color = border
		box.set_border_width_all(2)
		box.corner_radius_top_left = 11
		box.corner_radius_top_right = 11
		box.corner_radius_bottom_left = 11
		box.corner_radius_bottom_right = 11
		button.add_theme_stylebox_override(state_name,box)
