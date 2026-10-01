class_name ValedouroCartoonHUDStatus
extends Control

const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
const Assets = preload("res://scripts/cartoon/cartoon_visual_assets.gd")

var panel: PanelContainer
var region_label: Label
var level_label: Label
var gold_label: Label
var hp_bar: ProgressBar
var hp_text: Label
var xp_bar: ProgressBar
var xp_text: Label
var hero_button: Button
var hero_hint: Label
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
	panel.custom_minimum_size = Vector2(228,100)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	add_child(panel)
	var body = Control.new()
	body.custom_minimum_size = Vector2(228,100)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(body)
	var backing = Panel.new()
	backing.position = Vector2(52,22)
	backing.size = Vector2(174,60)
	backing.add_theme_stylebox_override("panel",UISkin.box())
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(backing)
	level_label = UISkin.label("",14,UISkin.TEXT)
	level_label.position = Vector2(72,2)
	level_label.size = Vector2(65,22)
	body.add_child(level_label)
	region_label = UISkin.label(region_name,11,UISkin.GOLD)
	region_label.position = Vector2(137,4)
	region_label.size = Vector2(89,18)
	region_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	body.add_child(region_label)
	hp_bar = _make_bar(Vector2(65,29),Vector2(151,23),Color("e83741"))
	body.add_child(hp_bar)
	hp_text = _bar_text(Vector2(70,29),Vector2(140,23))
	hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_text.add_theme_font_size_override("font_size",13)
	body.add_child(hp_text)
	xp_bar = _make_bar(Vector2(65,57),Vector2(151,17),Color("24a8ed"))
	body.add_child(xp_bar)
	xp_text = _bar_text(Vector2(70,55),Vector2(140,20))
	xp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(xp_text)
	gold_label = UISkin.label("",11,UISkin.GOLD)
	gold_label.position = Vector2(80,82)
	gold_label.size = Vector2(134,18)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	body.add_child(gold_label)
	hero_button = Button.new()
	hero_button.name = "HeroClassButton"
	hero_button.size = Vector2(72,96)
	hero_button.tooltip_text = "HERÓI • trocar classe e evoluir habilidades (C)"
	for key in ["normal","hover","pressed","disabled"]:
		var style = StyleBoxTexture.new()
		style.texture = preload("res://assets/ui/radial/portrait_frame.svg")
		hero_button.add_theme_stylebox_override(key,style)
	hero_button.pressed.connect(func():
		var layout = get_parent().get_node_or_null("GameLayout")
		if layout != null: layout.class_ui.open_panel())
	body.add_child(hero_button)
	var portrait = TextureRect.new()
	portrait.name = "TravelerPortrait"
	var atlas = AtlasTexture.new()
	atlas.atlas = load("res://assets/cartoon/v028/hero_front_idle.svg")
	atlas.region = Rect2(30,5,68,84)
	portrait.texture = atlas
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.position = Vector2(9,8)
	portrait.size = Vector2(54,76)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_button.add_child(portrait)
	UISkin.bind(panel,Vector2(228,100),"status")
	hero_hint = UISkin.label("HERÓI",8,UISkin.GOLD)
	hero_hint.position = Vector2(8,79)
	hero_hint.size = Vector2(56,10)
	hero_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_button.add_child(hero_hint)

func _make_bar(pos: Vector2,bar_size: Vector2,fill_color: Color) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.position = pos
	bar.size = bar_size
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.add_theme_font_size_override("font_size",1)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color(0.08,0.09,0.13,0.95)
	background.border_color = UISkin.GOLD
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
	hp_text.text = "%d / %d" % [hp,safe_max]
	hp_text.add_theme_color_override("font_color",Color("ffcebe") if hp <= safe_max/5 else Color.WHITE)
	level_label.text = "Nv %d" % clampi(level,1,100)
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		var row: Dictionary = state.Classes.class_row(state.active_class)
		region_label.text = "%s • %s" % [region_name,row.name]
		region_label.tooltip_text = region_name+" • "+row.name
		var points: int = state.available_skill_points()
		hero_button.tooltip_text = "%s • %d pontos de habilidade • toque para evoluir (C)" % [row.name,points]
		hero_hint.text = "+%d PT" % points if points > 0 else "HERÓI"
		hero_hint.add_theme_color_override("font_color",Color("ffe07a") if points > 0 else UISkin.GOLD)
	gold_label.text = "%d ouro" % maxi(0,gold)
	if level >= 100 or xp_next <= 0:
		xp_bar.value = 100.0
		xp_text.text = "XP  NÍVEL MÁXIMO"
	else:
		xp_bar.value = clampf(float(xp) / float(maxi(1,xp_next)) * 100.0,0.0,100.0)
		xp_text.text = "XP  %d / %d" % [maxi(0,xp),xp_next]
