class_name ValedouroCartoonInventoryUI
extends Control

const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
const HeroPreview = preload("res://scripts/cartoon/cartoon_hero.gd")

const EQUIPMENT_CAPACITY: int = 66

var host
var hero: Node2D
var panel: PanelContainer
var content: Control
var list_box: Container
var title_label: Label
var equipment_label: Label
var count_label: Label
var gold_label: Label
var preview_container: SubViewportContainer
var preview_viewport: SubViewport
var preview_hero: Node2D
var equipment_tab: Button
var materials_tab: Button
var consumables_tab: Button
var weapons_tab: Button
var armor_tab: Button
var current_tab: String = "equipment"
var equipment_filter: String = "all"
var toggle_button: Button

var weapon_slot: Button
var piece_buttons: Dictionary = {}
var armor_slot: Button
var detail_name: Label
var detail_meta: Label
var detail_compare: Label
var detail_action: Button
var selected_item_id: String = ""
var selected_material: String = ""
var selected_consumable: String = ""

func setup(host_node = null, hero_node: Node2D = null, show_toggle: bool = true) -> void:
	host = host_node
	hero = hero_node
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 100
	_build(show_toggle)
	_refresh()

func _state():
	return get_node_or_null("/root/CartoonPlayerState")

func is_open() -> bool:
	return panel != null and panel.visible

func open_panel(tab: String = "equipment") -> void:
	if tab == "materials":
		current_tab = "materials"
	elif tab == "consumables":
		current_tab = "consumables"
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
	if host.get("map_open") == true:
		host.call("_toggle_map")
	var forge = host.get("crafting_ui")
	if forge != null and forge.has_method("close_panel"):
		forge.call("close_panel")

func _build(show_toggle: bool) -> void:
	if show_toggle:
		toggle_button = Button.new()
		toggle_button.name = "InventoryButton"
		toggle_button.text = "BOLSA"
		toggle_button.position = Vector2(574,18)
		toggle_button.size = Vector2(68,48)
		toggle_button.mouse_filter = Control.MOUSE_FILTER_STOP
		toggle_button.add_theme_font_size_override("font_size",15)
		_style_button(toggle_button,Color(0.22,0.18,0.32),Color(0.78,0.62,0.93))
		toggle_button.pressed.connect(_toggle)
		add_child(toggle_button)
		UISkin.bind(toggle_button,Vector2(68,48),"bag")

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
	panel.add_theme_stylebox_override("panel",UISkin.box(UISkin.INK,UISkin.GOLD))
	add_child(panel)
	UISkin.bind(panel,Vector2(830,456),"center",true)

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
	count_label.position = Vector2(300,18)
	count_label.size = Vector2(330,26)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.add_theme_font_size_override("font_size",12)
	count_label.add_theme_color_override("font_color",Color(0.73,0.81,0.88))
	content.add_child(count_label)

	gold_label = Label.new()
	gold_label.name = "InventoryGold"
	gold_label.position = Vector2(640,16)
	gold_label.size = Vector2(100,28)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	gold_label.add_theme_font_size_override("font_size",14)
	gold_label.add_theme_color_override("font_color",UISkin.GOLD)
	content.add_child(gold_label)

	var close: Button = Button.new()
	close.text = "×"
	close.position = Vector2(750,6)
	close.size = Vector2(48,48)
	close.mouse_filter = Control.MOUSE_FILTER_STOP
	close.add_theme_font_size_override("font_size",22)
	_style_button(close,Color(0.23,0.10,0.13),Color(0.74,0.34,0.37))
	close.pressed.connect(close_panel)
	content.add_child(close)

	var equipped_title: Label = Label.new()
	equipped_title.position = Vector2(24,58)
	equipped_title.size = Vector2(236,26)
	equipped_title.text = "PERSONAGEM"
	equipped_title.add_theme_font_size_override("font_size",16)
	equipped_title.add_theme_color_override("font_color",Color(0.95,0.78,0.36))
	content.add_child(equipped_title)

	var preview_frame: PanelContainer = PanelContainer.new()
	preview_frame.name = "CharacterPreviewFrame"
	preview_frame.position = Vector2(66,104)
	preview_frame.size = Vector2(128,214)
	preview_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_frame.add_theme_stylebox_override("panel",UISkin.box(Color(0.055,0.07,0.09,0.95),Color("596f60"),14))
	content.add_child(preview_frame)

	preview_container = SubViewportContainer.new()
	preview_container.name = "CharacterPreview"
	preview_container.custom_minimum_size = Vector2(120,206)
	preview_container.stretch = true
	preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_frame.add_child(preview_container)

	preview_viewport = SubViewport.new()
	preview_viewport.name = "CharacterViewport"
	preview_viewport.size = Vector2i(120,206)
	preview_viewport.transparent_bg = true
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	preview_container.add_child(preview_viewport)

	preview_hero = HeroPreview.new()
	preview_hero.name = "PreviewHero"
	preview_hero.position = Vector2(60,148)
	preview_hero.scale = Vector2(1.55,1.55)
	preview_viewport.add_child(preview_hero)

	weapon_slot = Button.new()
	weapon_slot.name = "WeaponSlot"
	weapon_slot.position = Vector2(8,126)
	weapon_slot.size = Vector2(82,44)
	weapon_slot.alignment = HORIZONTAL_ALIGNMENT_LEFT
	weapon_slot.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(weapon_slot,Color(0.10,0.14,0.21),Color(0.78,0.58,0.24))
	weapon_slot.pressed.connect(_select_equipped_slot.bind("weapon"))
	content.add_child(weapon_slot)

	armor_slot = Button.new()
	armor_slot.name = "ArmorSlot"
	armor_slot.position = Vector2(8,180)
	armor_slot.size = Vector2(82,44)
	armor_slot.alignment = HORIZONTAL_ALIGNMENT_LEFT
	armor_slot.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(armor_slot,Color(0.10,0.14,0.21),Color(0.49,0.69,0.90))
	armor_slot.pressed.connect(_select_equipped_slot.bind("armor"))
	content.add_child(armor_slot)

	equipment_label = Label.new()
	equipment_label.position = Vector2(14,342)
	equipment_label.size = Vector2(230,58)
	equipment_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	equipment_label.add_theme_font_size_override("font_size",13)
	equipment_label.add_theme_color_override("font_color",Color(0.86,0.88,0.86))
	content.add_child(equipment_label)

	var hint: Label = Label.new()
	hint.position = Vector2(14,406)
	hint.size = Vector2(230,20)
	hint.text = "Toque em uma peça para comparar"
	hint.add_theme_font_size_override("font_size",11)
	hint.add_theme_color_override("font_color",Color(0.57,0.64,0.70))
	content.add_child(hint)

	equipment_tab = _tab_button("TODOS",Vector2(274,58),72)
	equipment_tab.name = "AllItemsTab"
	equipment_tab.pressed.connect(func(): _set_tab("equipment"))
	content.add_child(equipment_tab)

	weapons_tab = _tab_button("ARMAS",Vector2(352,58),70)
	weapons_tab.name = "WeaponsTab"
	weapons_tab.pressed.connect(func(): _set_tab("weapon"))
	content.add_child(weapons_tab)

	armor_tab = _tab_button("ARMADURAS",Vector2(428,58),92)
	armor_tab.name = "ArmorTab"
	armor_tab.pressed.connect(func(): _set_tab("armor"))
	content.add_child(armor_tab)

	materials_tab = _tab_button("MATERIAIS",Vector2(526,58),90)
	materials_tab.name = "MaterialsTab"
	materials_tab.pressed.connect(func(): _set_tab("materials"))
	content.add_child(materials_tab)

	consumables_tab = _tab_button("ITENS",Vector2(622,58),68)
	consumables_tab.name = "ConsumablesTab"
	consumables_tab.pressed.connect(func(): _set_tab("consumables"))
	content.add_child(consumables_tab)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.position = Vector2(274,116)
	scroll.size = Vector2(334,306)
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	content.add_child(scroll)

	var grid: GridContainer = GridContainer.new()
	grid.name = "InventoryGrid"
	grid.columns = 2
	grid.custom_minimum_size = Vector2(314,0)
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	scroll.add_child(grid)
	list_box = grid

	var details: PanelContainer = PanelContainer.new()
	details.position = Vector2(614,108)
	details.size = Vector2(184,314)
	var dstyle: StyleBoxFlat = StyleBoxFlat.new()
	dstyle.bg_color = Color(0.055,0.067,0.09,0.97)
	dstyle.border_color = Color(0.34,0.43,0.56)
	dstyle.set_border_width_all(2)
	dstyle.corner_radius_top_left = 14
	dstyle.corner_radius_top_right = 14
	dstyle.corner_radius_bottom_left = 14
	dstyle.corner_radius_bottom_right = 14
	details.add_theme_stylebox_override("panel",UISkin.box(UISkin.SURFACE,Color("4b6254")))
	content.add_child(details)

	var detail_content: Control = Control.new()
	detail_content.custom_minimum_size = Vector2(176,306)
	details.add_child(detail_content)

	var detail_title: Label = Label.new()
	detail_title.position = Vector2(14,12)
	detail_title.size = Vector2(148,24)
	detail_title.text = "DETALHES"
	detail_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_title.add_theme_font_size_override("font_size",14)
	detail_title.add_theme_color_override("font_color",Color(0.77,0.84,0.91))
	detail_content.add_child(detail_title)

	detail_name = Label.new()
	detail_name.position = Vector2(14,46)
	detail_name.size = Vector2(148,58)
	detail_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	detail_name.add_theme_font_size_override("font_size",16)
	detail_name.add_theme_color_override("font_color",Color(1.0,0.84,0.39))
	detail_content.add_child(detail_name)

	detail_meta = Label.new()
	detail_meta.position = Vector2(14,112)
	detail_meta.size = Vector2(148,64)
	detail_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_meta.add_theme_font_size_override("font_size",13)
	detail_meta.add_theme_color_override("font_color",Color(0.88,0.91,0.92))
	detail_content.add_child(detail_meta)

	detail_compare = Label.new()
	detail_compare.position = Vector2(14,180)
	detail_compare.size = Vector2(148,58)
	detail_compare.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_compare.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_compare.add_theme_font_size_override("font_size",12)
	detail_content.add_child(detail_compare)

	detail_action = Button.new()
	detail_action.name = "EquipSelectedButton"
	detail_action.text = "EQUIPAR"
	detail_action.position = Vector2(16,250)
	detail_action.size = Vector2(144,44)
	detail_action.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(detail_action,Color(0.15,0.29,0.20),Color(0.45,0.82,0.50))
	detail_action.pressed.connect(_primary_action)
	detail_content.add_child(detail_action)

func _tab_button(text_value: String,pos: Vector2,width: float) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.position = pos
	button.size = Vector2(width,44)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size",12)
	_style_button(button,Color(0.10,0.13,0.19),Color(0.38,0.49,0.62))
	return button

func _set_tab(tab: String) -> void:
	selected_material = ""
	selected_consumable = ""
	if tab == "materials":
		current_tab = "materials"
	elif tab == "consumables":
		current_tab = "consumables"
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
	count_label.text = "Equip. %d/%d • Mat. %d • Itens %d" % [items.size(),EQUIPMENT_CAPACITY,state.material_total(),state.consumables_total()]
	gold_label.text = "◉ %d" % state.player_gold
	if preview_hero != null:
		preview_hero.apply_equipment_from_state()
		preview_hero.apply_class_from_state()
	for entry: Array in [[equipment_tab,current_tab == "equipment" and equipment_filter == "all"],[weapons_tab,current_tab == "equipment" and equipment_filter == "weapon"],[armor_tab,current_tab == "equipment" and equipment_filter == "armor"],[materials_tab,current_tab == "materials"],[consumables_tab,current_tab == "consumables"]]:
		UISkin.button(entry[0],Color("355344") if entry[1] else UISkin.SURFACE,UISkin.GOLD if entry[1] else Color("596f60"))
		entry[0].add_theme_font_size_override("font_size",13)
	_refresh_equipped_slots(state)
	for child in list_box.get_children():
		list_box.remove_child(child)
		child.queue_free()
	if current_tab == "materials":
		_fill_materials(state)
	elif current_tab == "consumables":
		_fill_consumables(state)
	else:
		_fill_equipment(state)
	_refresh_detail(state)

func _refresh_equipped_slots(state) -> void:
	var layout: Dictionary = {
		"weapon":{"pos":Vector2(8,126),"size":Vector2(82,44),"short":"ARMA"},
		"armor":{"pos":Vector2(8,180),"size":Vector2(82,44),"short":"PEITO"},
		"helmet":{"pos":Vector2(78,68),"size":Vector2(104,38),"short":"ELMO"},
		"gloves":{"pos":Vector2(170,126),"size":Vector2(82,44),"short":"LUVAS"},
		"cape":{"pos":Vector2(170,180),"size":Vector2(82,44),"short":"CAPA"},
		"legs":{"pos":Vector2(8,250),"size":Vector2(82,44),"short":"CALÇAS"},
		"boots":{"pos":Vector2(170,250),"size":Vector2(82,44),"short":"BOTAS"}
	}
	weapon_slot.position = layout.weapon.pos
	weapon_slot.size = layout.weapon.size
	armor_slot.position = layout.armor.pos
	armor_slot.size = layout.armor.size
	weapon_slot.text = _paper_doll_text("ARMA",state.equipped_weapon)
	armor_slot.text = _paper_doll_text("PEITO",state.equipped_armor)
	weapon_slot.tooltip_text = String(state.equipped_weapon.get("label","Espada de Viagem"))
	armor_slot.tooltip_text = String(state.equipped_armor.get("label","Túnica de Viagem"))
	for slot: String in ["helmet","gloves","cape","legs","boots"]:
		if not piece_buttons.has(slot):
			var button: Button = Button.new()
			button.name = String(state.SLOT_NAMES[slot])+"Slot"
			_style_button(button,UISkin.SURFACE,UISkin.GOLD)
			button.add_theme_font_size_override("font_size",10)
			button.alignment = HORIZONTAL_ALIGNMENT_CENTER
			button.pressed.connect(_select_equipped_slot.bind(slot))
			content.add_child(button)
			piece_buttons[slot] = button
		var button: Button = piece_buttons[slot]
		button.position = layout[slot].pos
		button.size = layout[slot].size
		var item: Dictionary = state.equipped_in_slot(slot)
		button.text = _paper_doll_text(String(layout[slot].short),item)
		button.tooltip_text = String(item.get("label","Vazio"))
	equipment_label.visible = true
	equipment_label.position = Vector2(14,342)
	equipment_label.size = Vector2(238,58)
	equipment_label.add_theme_font_size_override("font_size",11)
	var progress: Dictionary = state.set_progress()
	equipment_label.text = "Conjunto %d/6  •  ATQ +%d  •  DEF +%d%s" % [int(progress.count),state.attack_bonus(),state.defense_bonus(),"\nBônus de conjunto ativo" if progress.complete else ""]

func _paper_doll_text(slot_name: String,item: Dictionary) -> String:
	if item.is_empty():
		return slot_name+"\nVAZIO"
	var stat: int = int(item.get("attack",0)) if String(item.get("slot",""))=="weapon" else int(item.get("defense",0))
	var suffix: String = "ATQ" if String(item.get("slot",""))=="weapon" else "DEF"
	return "%s\n+%d %s" % [slot_name,stat,suffix]

func _select_equipped_slot(slot: String) -> void:
	var state = _state()
	if state == null:
		return
	var item: Dictionary = state.equipped_in_slot(slot)
	equipment_filter = "weapon" if slot=="weapon" else "armor"
	_select_item(String(item.get("id","")))

func _fill_equipment(state) -> void:
	var items: Array[Dictionary] = state.owned_equipment()
	var visible_ids: Array[String] = []
	var visible_items: Array[Dictionary] = []
	for item in items:
		var slot: String = String(item.get("slot",""))
		if equipment_filter == "weapon" and slot != "weapon" or equipment_filter == "armor" and slot == "weapon":
			continue
		visible_items.append(item)
		visible_ids.append(String(item.get("id","")))
	if visible_items.is_empty():
		_add_empty("Nenhum equipamento\nneste filtro.")
		selected_item_id = ""
		return
	if selected_item_id not in visible_ids:
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
		button.tooltip_text = button.text
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		_style_button(button,Color(0.085,0.105,0.15),_rarity_color(tier))
		if id == selected_item_id: UISkin.button(button,Color("355344"),UISkin.GOLD)
		button.add_theme_font_size_override("font_size",12)
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
		button.tooltip_text = button.text
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		_style_button(button,Color(0.08,0.14,0.12),Color(0.40,0.73,0.52))
		if key == selected_material: UISkin.button(button,Color("355344"),UISkin.GOLD)
		button.add_theme_font_size_override("font_size",12)
		button.pressed.connect(_select_material.bind(key))
		list_box.add_child(button)

func _fill_consumables(state) -> void:
	var active: Array[String] = []
	for key_value in state.consumables.keys():
		var key: String = String(key_value)
		if state.consumable_count(key) > 0:
			active.append(key)
	active.sort()
	if active.is_empty():
		_add_empty("Nenhum consumível.\nAlguns inimigos podem derrubar itens.")
		selected_consumable = ""
		return
	if selected_consumable == "" or selected_consumable not in active:
		selected_consumable = active[0]
	for id in active:
		var row: Dictionary = state.Loot.consumable(id)
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(160,72)
		button.text = "%s%s\nQuantidade: %d" % [
			"◆ " if id == selected_consumable else "",
			String(row.get("label","Consumível")),
			state.consumable_count(id)
		]
		button.tooltip_text = String(row.get("description",""))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		_style_button(button,Color(0.12,0.10,0.16),Color(0.72,0.48,0.84))
		if id == selected_consumable:
			UISkin.button(button,Color("355344"),UISkin.GOLD)
		button.add_theme_font_size_override("font_size",12)
		button.pressed.connect(_select_consumable.bind(id))
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
	selected_consumable = ""
	current_tab = "equipment"
	_refresh()

func _select_material(material_name: String) -> void:
	selected_material = material_name
	selected_item_id = ""
	selected_consumable = ""
	current_tab = "materials"
	_refresh()

func _select_consumable(id: String) -> void:
	selected_consumable = id
	selected_item_id = ""
	selected_material = ""
	current_tab = "consumables"
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

	if current_tab == "consumables":
		detail_action.visible = true
		if selected_consumable == "":
			detail_name.text = "Consumíveis"
			detail_meta.text = "Nenhum item selecionado."
			detail_compare.text = ""
			detail_action.disabled = true
			detail_action.text = "USAR"
			return
		var row: Dictionary = state.Loot.consumable(selected_consumable)
		detail_name.text = String(row.get("label","Consumível"))
		detail_meta.text = "%s\nQuantidade: %d" % [String(row.get("rarity","Comum")),state.consumable_count(selected_consumable)]
		detail_compare.text = String(row.get("description",""))
		detail_compare.add_theme_color_override("font_color",Color(0.72,0.82,0.95))
		detail_action.text = "USAR"
		detail_action.disabled = state.player_hp >= state.player_max_hp or state.consumable_count(selected_consumable) <= 0
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
	var equipped_item: Dictionary = state.equipped_in_slot(slot)
	var equipped_stat: int = _item_stat(equipped_item)
	var diff: int = stat-equipped_stat
	var stat_name: String = "ATQ" if slot == "weapon" else "DEF"
	var equipped: bool = state.is_equipped(String(item.get("id","")))
	var required_level: int = state.equipment_required_level(item)
	var locked: bool = state.player_level < required_level
	detail_name.text = String(item.get("label","Equipamento"))
	var progress: Dictionary = state.set_progress(item)
	detail_meta.text = "%s • Tier %d • Requer Nv %d\n%s +%d %s\n%s" % [_rarity_name(tier),tier,required_level,String(state.SLOT_NAMES.get(slot,slot)),stat,stat_name,("Conjunto %d/6 • bônus +%d ATQ/DEF" % [int(progress.count),int(progress.bonus)]) if item.has("set_id") else ("Arco • alcance 300 • flechas livres" if item.get("weapon_kind","")=="bow" else "Espada • corpo a corpo")]
	if locked:
		detail_compare.text = "Disponível ao atingir o nível %d." % required_level
		detail_compare.add_theme_color_override("font_color",Color(0.95,0.68,0.36))
	elif equipped:
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
	detail_action.disabled = equipped or locked
	detail_action.text = "EQUIPADO" if equipped else ("NÍVEL %d" % required_level if locked else "EQUIPAR")

func _primary_action() -> void:
	if current_tab == "consumables":
		_use_selected_consumable()
	else:
		_equip_selected()

func _use_selected_consumable() -> void:
	if selected_consumable == "":
		return
	var state = _state()
	if state == null:
		return
	var result: Dictionary = state.use_consumable(selected_consumable)
	if host != null and host.has_method("_refresh_stats"):
		host.call("_refresh_stats")
	if host != null and host.has_method("_show_toast"):
		host.call("_show_toast",String(result.get("message","Consumível atualizado.")))
	_refresh()

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
	UISkin.button(button,UISkin.SURFACE.lerp(bg,0.18),border.darkened(0.15))
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
