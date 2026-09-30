class_name ValedouroCartoonCraftingUI
extends Control

var host
var hero: Node2D
var region_id: String = ""
var panel: PanelContainer
var summary_label: Label
var material_label: Label
var weapon_button: Button
var armor_button: Button
var title_label: Label

func setup(host_node, hero_node: Node2D, target_region_id: String) -> void:
	host = host_node
	hero = hero_node
	region_id = target_region_id
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	_refresh()

func is_open() -> bool:
	return panel != null and panel.visible

func _state():
	return get_node_or_null("/root/CartoonPlayerState")

func _build() -> void:
	var toggle: Button = Button.new()
	toggle.text = "FORJA"
	toggle.position = Vector2(480,18)
	toggle.size = Vector2(92,46)
	toggle.mouse_filter = Control.MOUSE_FILTER_STOP
	toggle.add_theme_font_size_override("font_size",15)
	_style_button(toggle,Color(0.50,0.30,0.13),Color(0.91,0.67,0.24))
	toggle.pressed.connect(_toggle)
	add_child(toggle)

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
	panel.add_theme_stylebox_override("panel",st)
	add_child(panel)

	title_label = Label.new()
	title_label.position = Vector2(20,16)
	title_label.size = Vector2(430,34)
	title_label.text = "FORJA DE VALEDOURO"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size",22)
	title_label.add_theme_color_override("font_color",Color(1.0,0.82,0.36))
	panel.add_child(title_label)

	summary_label = Label.new()
	summary_label.position = Vector2(24,58)
	summary_label.size = Vector2(422,60)
	summary_label.add_theme_font_size_override("font_size",15)
	summary_label.add_theme_color_override("font_color",Color(0.93,0.91,0.87))
	panel.add_child(summary_label)

	material_label = Label.new()
	material_label.position = Vector2(24,122)
	material_label.size = Vector2(422,58)
	material_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	material_label.add_theme_font_size_override("font_size",13)
	material_label.add_theme_color_override("font_color",Color(0.77,0.91,0.88))
	panel.add_child(material_label)

	weapon_button = Button.new()
	weapon_button.position = Vector2(28,196)
	weapon_button.size = Vector2(198,86)
	weapon_button.mouse_filter = Control.MOUSE_FILTER_STOP
	weapon_button.add_theme_font_size_override("font_size",14)
	_style_button(weapon_button,Color(0.16,0.27,0.42),Color(0.39,0.72,0.96))
	weapon_button.pressed.connect(func(): _craft("weapon"))
	panel.add_child(weapon_button)

	armor_button = Button.new()
	armor_button.position = Vector2(244,196)
	armor_button.size = Vector2(198,86)
	armor_button.mouse_filter = Control.MOUSE_FILTER_STOP
	armor_button.add_theme_font_size_override("font_size",14)
	_style_button(armor_button,Color(0.29,0.20,0.36),Color(0.74,0.52,0.92))
	armor_button.pressed.connect(func(): _craft("armor"))
	panel.add_child(armor_button)

	var close: Button = Button.new()
	close.text = "FECHAR"
	close.position = Vector2(145,299)
	close.size = Vector2(180,42)
	close.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(close,Color(0.18,0.16,0.19),Color(0.63,0.60,0.63))
	close.pressed.connect(func(): panel.visible=false)
	panel.add_child(close)

func _style_button(button: Button, bg: Color, border: Color) -> void:
	for state in ["normal","hover","pressed","focus"]:
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = bg.lightened(0.08) if state == "hover" else (bg.darkened(0.08) if state == "pressed" else bg)
		box.border_color = border
		box.set_border_width_all(3)
		box.corner_radius_top_left = 12
		box.corner_radius_top_right = 12
		box.corner_radius_bottom_left = 12
		box.corner_radius_bottom_right = 12
		button.add_theme_stylebox_override(state,box)

func _toggle() -> void:
	panel.visible = not panel.visible
	_refresh()

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

func _refresh() -> void:
	var state = _state()
	if state == null:
		return
	summary_label.text = state.equipment_summary()
	material_label.text = "MATERIAIS\n"+state.materials_summary()
	var recipes: Array[Dictionary] = state.recipes_for(region_id)
	if recipes.is_empty():
		weapon_button.text = "ARMA\nReceitas encontradas a partir da Floresta Ancestral"
		armor_button.text = "ARMADURA\nExplore as regiões para obter materiais"
		weapon_button.disabled = true
		armor_button.disabled = true
		return
	weapon_button.disabled = false
	armor_button.disabled = false
	for recipe in recipes:
		var slot: String = String(recipe.get("slot",""))
		var label: String = String(recipe.get("label","Equipamento"))
		var material: String = String(recipe.get("material",""))
		var cost: int = int(recipe.get("cost",0))
		var have: int = state.material_count(material)
		var crafted: bool = state.crafted.has(String(recipe.get("id","")))
		var text_value: String = "%s\n%s" % [label,("EQUIPAR" if crafted else "%d/%d %s" % [have,cost,material])]
		if slot == "weapon":
			weapon_button.text = text_value+"\n+%d ATQ" % int(recipe.get("attack",0))
		else:
			armor_button.text = text_value+"\n+%d DEF" % int(recipe.get("defense",0))
