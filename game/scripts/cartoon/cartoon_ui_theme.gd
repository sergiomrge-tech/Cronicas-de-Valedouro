class_name ValedouroCartoonUITheme
extends RefCounted

const FONT_BOLD = preload("res://assets/fonts/RadialBold.ttf")
const Placement = preload("res://scripts/cartoon/cartoon_ui_placement.gd")
const INK: Color = Color("21151b")
const SURFACE: Color = Color("49212b")
const GOLD: Color = Color("e4b85d")
const TEXT: Color = Color("fff0d4")
const MUTED: Color = Color("c8aaa1")

static func box(bg: Color = SURFACE, border: Color = GOLD, radius: int = 12) -> StyleBox:
	if radius<=3:
		var flat = StyleBoxFlat.new()
		flat.bg_color = bg
		flat.set_corner_radius_all(radius)
		return flat
	var style = StyleBoxTexture.new()
	style.texture = preload("res://assets/ui/radial/frame.svg")
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		style.set_texture_margin(side,12)
		style.set_content_margin(side,2)
	style.modulate_color = Color.WHITE.lerp(border,0.10)
	return style

static func button(button: Button, bg: Color = SURFACE, border: Color = GOLD, radius: int = 10) -> void:
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_override("font",FONT_BOLD)
	button.add_theme_font_size_override("font_size",14)
	button.add_theme_color_override("font_color",TEXT)
	button.add_theme_color_override("font_hover_color",Color.WHITE)
	button.add_theme_color_override("font_pressed_color",Color.WHITE)
	button.add_theme_color_override("font_disabled_color",Color("b39a94"))
	for state: String in ["normal","hover","pressed","focus","disabled"]:
		var style: StyleBoxTexture = StyleBoxTexture.new()
		if radius>=28:
			style.texture = preload("res://assets/ui/radial/round.svg")
		else:
			style.texture = preload("res://assets/ui/radial/frame.svg")
			for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: style.set_texture_margin(side,10)
		for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: style.set_content_margin(side,2)
		style.modulate_color = Color(1.20,1.12,0.95) if bg.get_luminance()>0.13 else Color.WHITE
		if state=="hover": style.modulate_color = Color(1.15,1.10,1.0)
		elif state=="pressed": style.modulate_color = Color(0.8,0.7,0.6)
		elif state=="disabled": style.modulate_color = Color(0.6,0.55,0.55)
		elif state=="focus": style.modulate_color = Color(1.25,1.10,0.8)
		button.add_theme_stylebox_override(state,style)

static func label(text: String, font_size: int = 14, color: Color = TEXT) -> Label:
	var node: Label = Label.new()
	node.text = text
	if font_size>=18: node.add_theme_font_override("font",FONT_BOLD)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_font_size_override("font_size",font_size)
	node.add_theme_color_override("font_color",color)
	return node

static func bind(target: Control, design: Vector2, role: String = "center", modal: bool = false) -> void:
	if role == "center" or role == "menu": decorate(target)
	var binder: Node = Placement.new()
	binder.target = target
	binder.design_size = design
	binder.placement = role
	if modal:
		target.z_index = 10
		var dimmer: ColorRect = ColorRect.new()
		dimmer.name = "ModalBackdrop"
		dimmer.color = Color(0.08,0.015,0.03,0.78)
		dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
		target.get_parent().add_child(dimmer)
		dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		target.get_parent().move_child(dimmer,target.get_index())
		binder.dimmer = dimmer
	target.add_child(binder)

static func usable(viewport: Viewport) -> Rect2:
	return Placement.usable(viewport)

static func decorate(target: Control) -> void:
	if target.get_node_or_null("RadialFrame") != null: return
	var frame = preload("res://scripts/cartoon/cartoon_radial_frame.gd").new()
	frame.name = "RadialFrame"
	target.add_child(frame)
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Internal chrome never participates in PanelContainer's content sizing.
	frame.set_as_top_level(false)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.z_index = 1

static func icon(button_node: Button, kind: String, width: int = 24) -> void:
	var art = button_node.get_node_or_null("RadialButtonArt")
	if art == null:
		art = preload("res://scripts/cartoon/cartoon_radial_button_art.gd").new()
		art.name = "RadialButtonArt"
		button_node.add_child(art)
		art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if art.kind==kind and art.icon_width==width: return
	if art.kind != kind:
		art.kind = kind
		art.texture = load("res://assets/ui/radial/"+kind+(".png" if kind in ["fire","ice","arcane"] else ".svg"))
		art.queue_redraw()
	art.icon_width = width
	art.queue_redraw()
	button_node.icon = null
	for state: String in ["font_color","font_hover_color","font_pressed_color","font_disabled_color","font_focus_color"]:
		button_node.add_theme_color_override(state,Color.TRANSPARENT)
