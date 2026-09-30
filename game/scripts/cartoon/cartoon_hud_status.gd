class_name ValedouroCartoonHUDStatus
extends Control

var panel: PanelContainer
var region_label: Label
var level_label: Label
var gold_label: Label
var hp_bar: ProgressBar
var hp_text: Label
var xp_bar: ProgressBar
var xp_text: Label
var region_name: String = "VALEDOURO"
var accent: Color = Color(0.91,0.69,0.27)

func setup(label: String,accent_color: Color = Color(0.91,0.69,0.27)) -> void:
	region_name = label
	accent = accent_color
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()

func _build() -> void:
	panel = PanelContainer.new()
	panel.name = "PlayerStatusPanel"
	panel.position = Vector2(14,12)
	panel.size = Vector2(326,90)
	panel.custom_minimum_size = Vector2(326,90)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.025,0.033,0.052,0.94)
	style.border_color = accent
	style.set_border_width_all(3)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	panel.add_theme_stylebox_override("panel",style)
	add_child(panel)

	var body: Control = Control.new()
	body.custom_minimum_size = Vector2(316,80)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(body)

	region_label = Label.new()
	region_label.position = Vector2(12,6)
	region_label.size = Vector2(205,22)
	region_label.text = region_name
	region_label.add_theme_font_size_override("font_size",14)
	region_label.add_theme_color_override("font_color",Color(0.96,0.92,0.78))
	body.add_child(region_label)

	level_label = Label.new()
	level_label.position = Vector2(220,5)
	level_label.size = Vector2(84,24)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	level_label.add_theme_font_size_override("font_size",15)
	level_label.add_theme_color_override("font_color",Color(1.0,0.82,0.35))
	body.add_child(level_label)

	hp_bar = _make_bar(Vector2(12,31),Vector2(202,18),Color(0.78,0.18,0.24))
	body.add_child(hp_bar)
	hp_text = _bar_text(Vector2(18,29),Vector2(190,20))
	body.add_child(hp_text)

	xp_bar = _make_bar(Vector2(12,56),Vector2(202,14),Color(0.20,0.62,0.91))
	body.add_child(xp_bar)
	xp_text = _bar_text(Vector2(18,53),Vector2(190,20))
	xp_text.add_theme_font_size_override("font_size",10)
	body.add_child(xp_text)

	gold_label = Label.new()
	gold_label.position = Vector2(222,35)
	gold_label.size = Vector2(82,38)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gold_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	gold_label.add_theme_font_size_override("font_size",14)
	gold_label.add_theme_color_override("font_color",Color(1.0,0.79,0.30))
	body.add_child(gold_label)

func _make_bar(pos: Vector2,bar_size: Vector2,fill_color: Color) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.position = pos
	bar.size = bar_size
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color(0.08,0.09,0.13,0.95)
	background.border_color = Color(0.24,0.26,0.32,0.9)
	background.set_border_width_all(1)
	background.corner_radius_top_left = 7
	background.corner_radius_top_right = 7
	background.corner_radius_bottom_left = 7
	background.corner_radius_bottom_right = 7
	bar.add_theme_stylebox_override("background",background)
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 6
	fill.corner_radius_top_right = 6
	fill.corner_radius_bottom_left = 6
	fill.corner_radius_bottom_right = 6
	bar.add_theme_stylebox_override("fill",fill)
	return bar

func _bar_text(pos: Vector2,text_size: Vector2) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.size = text_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",11)
	label.add_theme_color_override("font_color",Color.WHITE)
	label.add_theme_color_override("font_shadow_color",Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x",1)
	label.add_theme_constant_override("shadow_offset_y",1)
	return label

func refresh(hp: int,max_hp: int,gold: int,level: int,xp: int,xp_next: int) -> void:
	if panel == null:
		return
	var safe_max: int = maxi(1,max_hp)
	hp_bar.value = clampf(float(hp) / float(safe_max) * 100.0,0.0,100.0)
	hp_text.text = "VIDA  %d / %d" % [hp,safe_max]
	level_label.text = "Nv %d" % clampi(level,1,100)
	gold_label.text = "OURO\n%d" % maxi(0,gold)
	if level >= 100 or xp_next <= 0:
		xp_bar.value = 100.0
		xp_text.text = "XP  NÍVEL MÁXIMO"
	else:
		xp_bar.value = clampf(float(xp) / float(maxi(1,xp_next)) * 100.0,0.0,100.0)
		xp_text.text = "XP  %d / %d" % [maxi(0,xp),xp_next]
