class_name ValedouroCartoonZoomControls
extends Control

const MIN_ZOOM: float = 0.70
const MAX_ZOOM: float = 1.50
const ZOOM_STEP: float = 0.15
const DEFAULT_ZOOM: float = 1.0

var camera: Camera2D
var percent_label: Label
var panel: PanelContainer

func setup(camera_node: Camera2D) -> void:
	camera = camera_node
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	var state = _state()
	var saved_zoom: float = DEFAULT_ZOOM
	if state != null:
		saved_zoom = float(state.camera_zoom)
	_apply_zoom(saved_zoom,false)

func _state():
	return get_node_or_null("/root/CartoonPlayerState")

func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "ZoomPanel"
	panel.position = Vector2(878,128)
	panel.size = Vector2(68,198)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.04,0.05,0.08,0.82)
	panel_style.border_color = Color(0.73,0.72,0.66,0.72)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 15
	panel_style.corner_radius_top_right = 15
	panel_style.corner_radius_bottom_left = 15
	panel_style.corner_radius_bottom_right = 15
	panel.add_theme_stylebox_override("panel",panel_style)
	add_child(panel)

	var plus: Button = _make_button("+",Vector2(8,8),Vector2(52,48))
	plus.tooltip_text = "Aproximar"
	plus.pressed.connect(zoom_in)
	panel.add_child(plus)

	percent_label = Label.new()
	percent_label.position = Vector2(5,58)
	percent_label.size = Vector2(58,26)
	percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percent_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	percent_label.add_theme_font_size_override("font_size",13)
	percent_label.add_theme_color_override("font_color",Color(0.96,0.94,0.84))
	panel.add_child(percent_label)

	var minus: Button = _make_button("−",Vector2(8,86),Vector2(52,48))
	minus.tooltip_text = "Afastar"
	minus.pressed.connect(zoom_out)
	panel.add_child(minus)

	var reset: Button = _make_button("1:1",Vector2(8,142),Vector2(52,42))
	reset.tooltip_text = "Zoom padrão"
	reset.add_theme_font_size_override("font_size",13)
	reset.pressed.connect(reset_zoom)
	panel.add_child(reset)

func _make_button(text_value: String, pos: Vector2, button_size: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.position = pos
	button.size = button_size
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size",24)
	for state in ["normal","hover","pressed","focus"]:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color(0.10,0.12,0.17,0.95) if state != "pressed" else Color(0.22,0.25,0.32,0.98)
		style.border_color = Color(0.83,0.68,0.28)
		style.set_border_width_all(2)
		style.corner_radius_top_left = 11
		style.corner_radius_top_right = 11
		style.corner_radius_bottom_left = 11
		style.corner_radius_bottom_right = 11
		button.add_theme_stylebox_override(state,style)
	return button

func zoom_in() -> void:
	if camera == null:
		return
	_apply_zoom(camera.zoom.x+ZOOM_STEP,true)

func zoom_out() -> void:
	if camera == null:
		return
	_apply_zoom(camera.zoom.x-ZOOM_STEP,true)

func reset_zoom() -> void:
	_apply_zoom(DEFAULT_ZOOM,true)

func set_zoom_value(value: float, persist: bool = true) -> void:
	_apply_zoom(value,persist)

func zoom_value() -> float:
	return camera.zoom.x if camera != null else DEFAULT_ZOOM

func _apply_zoom(value: float, persist: bool) -> void:
	var clamped: float = clampf(value,MIN_ZOOM,MAX_ZOOM)
	if camera != null:
		camera.zoom = Vector2(clamped,clamped)
	if percent_label != null:
		percent_label.text = "%d%%" % int(round(clamped*100.0))
	if persist:
		var state = _state()
		if state != null:
			state.set_camera_zoom(clamped)
