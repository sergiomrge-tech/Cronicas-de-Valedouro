class_name ValedouroCartoonCraftingUI
extends Control

const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")

var host
var hero: Node2D
var region_id: String = ""
var panel: PanelContainer
var summary_label: Label
var material_label: Label
var weapon_button: Button
var armor_button: Button
var toggle_button: Button
var recipe_list: VBoxContainer
var supply_button: Button
var title_label: Label

func setup(host_node, hero_node: Node2D, target_region_id: String) -> void:
	host = host_node
	hero = hero_node
	region_id = target_region_id
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 100
	_build()
	_refresh()

func is_open() -> bool:
	return panel != null and panel.visible

func close_panel() -> void:
	if panel != null:
		panel.visible = false

func _state():
	return get_node_or_null("/root/CartoonPlayerState")

func _build() -> void:
	var toggle: Button = Button.new()
	toggle.text = "FORJA"
	toggle.position = Vector2(462,18)
	toggle.size = Vector2(68,48)
	toggle.mouse_filter = Control.MOUSE_FILTER_STOP
	toggle.add_theme_font_size_override("font_size",15)
	_style_button(toggle,Color(0.50,0.30,0.13),Color(0.91,0.67,0.24))
	toggle.pressed.connect(_toggle)
	add_child(toggle)
	toggle_button = toggle
	UISkin.bind(toggle,Vector2(68,48),"forge")

	panel = PanelContainer.new()
	panel.position = Vector2(245,88)
	panel.size = Vector2(470,355)
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var st: StyleBoxFlat = StyleBoxFlat.new()
	st.bg_color = Color(0.055,0.045,0.07,0.985)
	st.border_color = Color(0.89,0.63,0.22)
	st.set_border_width_all(4)
	st.corner_radius_top_left = 18
	st.corner_radius_top_right = 18
	st.corner_radius_bottom_left = 18
	st.corner_radius_bottom_right = 18
	panel.add_theme_stylebox_override("panel",UISkin.box(UISkin.INK,UISkin.GOLD))
	add_child(panel)
	UISkin.bind(panel,Vector2(470,355),"center",true)

	var body: Control = Control.new()
	body.name = "CraftingContent"
	body.custom_minimum_size = Vector2(462,347)
	body.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(body)

	title_label = Label.new()
	title_label.position = Vector2(20,16)
	title_label.size = Vector2(430,34)
	title_label.text = "FORJA DO VIAJANTE"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size",22)
	title_label.add_theme_color_override("font_color",Color(1.0,0.82,0.36))
	body.add_child(title_label)

	summary_label = Label.new()
	summary_label.position = Vector2(24,54)
	summary_label.size = Vector2(422,60)
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.add_theme_font_size_override("font_size",13)
	summary_label.add_theme_color_override("font_color",Color(0.93,0.91,0.87))
	body.add_child(summary_label)

	material_label = Label.new()
	material_label.position = Vector2(24,122)
	material_label.size = Vector2(422,58)
	material_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	material_label.max_lines_visible = 3
	material_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	material_label.add_theme_font_size_override("font_size",13)
	material_label.add_theme_color_override("font_color",Color(0.77,0.91,0.88))
	body.add_child(material_label)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.position = Vector2(24,132)
	scroll.size = Vector2(422,154)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	recipe_list = VBoxContainer.new()
	recipe_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recipe_list.add_theme_constant_override("separation",6)
	scroll.add_child(recipe_list)
	for recipe in _state().recipes_for(region_id):
		var button: Button = Button.new()
		button.name = String(recipe.id)
		button.custom_minimum_size = Vector2(390,64)
		button.add_theme_font_size_override("font_size",14)
		_style_button(button,UISkin.SURFACE,UISkin.GOLD)
		button.pressed.connect(_craft_id.bind(String(recipe.id)))
		recipe_list.add_child(button)
		if recipe.slot=="weapon" and recipe.get("weapon_kind","")=="sword": weapon_button = button
		if recipe.slot=="armor": armor_button = button
	material_label.visible = false

	supply_button = Button.new()
	supply_button.text = "MATERIAL • 10 OURO"
	supply_button.position = Vector2(24,299)
	supply_button.size = Vector2(240,44)
	supply_button.add_theme_font_size_override("font_size",14)
	_style_button(supply_button,UISkin.SURFACE,UISkin.GOLD)
	supply_button.pressed.connect(_buy_material)
	body.add_child(supply_button)

	var close: Button = Button.new()
	close.text = "FECHAR"
	close.position = Vector2(278,299)
	close.size = Vector2(164,44)
	close.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(close,Color(0.18,0.16,0.19),Color(0.63,0.60,0.63))
	close.pressed.connect(close_panel)
	body.add_child(close)

func _ensure_recipe_buttons(rows: Array[Dictionary]) -> void:
	for recipe in rows:
		var id: String = String(recipe.get("id",""))
		if id == "" or recipe_list.get_node_or_null(NodePath(id)) != null:
			continue
		var button: Button = Button.new()
		button.name = id
		button.custom_minimum_size = Vector2(390,64)
		button.add_theme_font_size_override("font_size",14)
		var border: Color = Color("e59a45") if bool(recipe.get("boss_unique",false)) else UISkin.GOLD
		_style_button(button,UISkin.SURFACE,border)
		button.pressed.connect(_craft_id.bind(id))
		recipe_list.add_child(button)
		if String(recipe.get("slot",""))=="weapon" and String(recipe.get("weapon_kind",""))=="sword" and weapon_button==null:
			weapon_button = button
		if String(recipe.get("slot",""))=="armor" and armor_button==null:
			armor_button = button

func _style_button(button: Button, bg: Color, border: Color) -> void:
	UISkin.button(button,UISkin.SURFACE.lerp(bg,0.18),border.darkened(0.15))
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func _toggle() -> void:
	panel.visible = not panel.visible
	if panel.visible:
		_close_inventory()
	_refresh()

func _close_inventory() -> void:
	if host == null:
		return
	if host.get("map_open") == true:
		host.call("_toggle_map")
	var bag = host.get("inventory_ui")
	if bag != null and bag.has_method("close_panel"):
		bag.call("close_panel")

func _craft(slot: String) -> void:
	var state = _state()
	if state == null:
		return
	var result: Dictionary = state.craft(region_id,slot)
	if hero != null and hero.has_method("apply_equipment_from_state"):
		hero.call("apply_equipment_from_state")
	_refresh()
	if host != null and host.has_method("_show_toast"):
		host.call("_show_toast",String(result.get("message","Forja atualizada.")))

func _craft_id(id: String) -> void:
	var result: Dictionary = _state().craft_item(region_id,id)
	if hero != null: hero.apply_equipment_from_state()
	_refresh()
	if host != null and host.has_method("_show_toast"): host._show_toast(String(result.message))

func _buy_material() -> void:
	var result: Dictionary = _state().buy_crafting_material(region_id)
	_refresh()
	if host != null and host.has_method("_refresh_stats"): host._refresh_stats()
	if host != null and host.has_method("_show_toast"): host._show_toast(String(result.message))

func _refresh() -> void:
	var state = _state()
	if state == null: return
	summary_label.text = state.equipment_summary()+"\nOuro: %d • Material extra: 10 ouro/unidade" % state.player_gold
	var rows: Array[Dictionary] = state.recipes_for(region_id)
	_ensure_recipe_buttons(rows)
	if not rows.is_empty(): supply_button.tooltip_text = "Comprar 1 "+String(rows[1].material)+" por 10 de ouro"
	for row in rows:
		var button: Button = recipe_list.get_node_or_null(NodePath(String(row.id)))
		if button == null: continue
		var owned: bool = state.crafted.has(String(row.id))
		var have: int = state.material_count(String(row.material))
		var required_level: int = state.equipment_required_level(row)
		var locked: bool = state.player_level < required_level
		var action_text: String = "EQUIPAR • já criado" if owned else "%d/%d %s • CRIAR" % [have,int(row.cost),String(row.material)]
		if locked:
			action_text = "REQUER NÍVEL %d" % required_level
		var prefix: String = "CHEFE • " if bool(row.get("boss_unique",false)) else ""
		button.text = "%s%s • +%d %s • Nv %d\n%s" % [prefix,String(row.label),int(row.get("attack",row.get("defense",0))),"ATQ" if row.slot=="weapon" else "DEF",required_level,action_text]
		button.disabled = state.is_equipped(String(row.id)) or locked or (not owned and have<int(row.cost))
		if bool(row.get("boss_unique",false)):
			button.tooltip_text = "%s\nMaterial exclusivo de %s." % [button.text,String(row.get("boss_name","chefe"))]
		else:
			button.tooltip_text = "Disponível no nível %d." % required_level if locked else button.text
