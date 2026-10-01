class_name ValedouroCartoonUITheme
extends RefCounted

const Placement = preload("res://scripts/cartoon/cartoon_ui_placement.gd")
const INK: Color = Color("152620")
const SURFACE: Color = Color("20362f")
const GOLD: Color = Color("bda46c")
const TEXT: Color = Color("eee6cd")
const MUTED: Color = Color("a5b8a7")

static func box(bg: Color = SURFACE, border: Color = GOLD, radius: int = 12) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.03,0.08,0.06,0.24)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0,3)
	return style

static func button(button: Button, bg: Color = SURFACE, border: Color = GOLD, radius: int = 10) -> void:
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size",14)
	button.add_theme_color_override("font_color",TEXT)
	button.add_theme_color_override("font_hover_color",Color.WHITE)
	button.add_theme_color_override("font_pressed_color",Color.WHITE)
	button.add_theme_color_override("font_disabled_color",Color("859187"))
	for state: String in ["normal","hover","pressed","focus","disabled"]:
		var fill: Color = bg
		if state == "hover": fill = bg.lightened(0.08)
		elif state == "pressed": fill = bg.lightened(0.16)
		elif state == "disabled": fill = bg.darkened(0.20)
		var style: StyleBoxFlat = box(fill,border.darkened(0.45) if state == "disabled" else border,radius)
		if state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.border_color = Color("f1d596")
			style.set_border_width_all(2)
		button.add_theme_stylebox_override(state,style)

static func label(text: String, font_size: int = 14, color: Color = TEXT) -> Label:
	var node: Label = Label.new()
	node.text = text
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_font_size_override("font_size",font_size)
	node.add_theme_color_override("font_color",color)
	return node

static func bind(target: Control, design: Vector2, role: String = "center", modal: bool = false) -> void:
	var binder: Node = Placement.new()
	binder.target = target
	binder.design_size = design
	binder.placement = role
	if modal:
		target.z_index = 10
		var dimmer: ColorRect = ColorRect.new()
		dimmer.name = "ModalBackdrop"
		dimmer.color = Color(0.025,0.055,0.045,0.74)
		dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
		target.get_parent().add_child(dimmer)
		dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		target.get_parent().move_child(dimmer,target.get_index())
		binder.dimmer = dimmer
	target.add_child(binder)

static func usable(viewport: Viewport) -> Rect2:
	return Placement.usable(viewport)
