class_name ValedouroCartoonZoomControls
extends Control

const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")

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
	panel.size = Vector2(216,48)
	panel.add_theme_stylebox_override("panel",UISkin.box(Color(0.07,0.13,0.10,0.86),UISkin.GOLD.darkened(0.35)))
	add_child(panel)
	var body: Control = Control.new()
	body.name = "ZoomContent"
	body.custom_minimum_size = Vector2(212,44)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(body)
	var minus: Button = _make_button("−",Vector2(2,0),Vector2(44,44))
	minus.tooltip_text = "Afastar"
	minus.pressed.connect(zoom_out)
	body.add_child(minus)
	percent_label = UISkin.label("",12)
	percent_label.position = Vector2(48,10)
	percent_label.size = Vector2(48,24)
	percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(percent_label)
	var plus: Button = _make_button("+",Vector2(98,0),Vector2(44,44))
	plus.tooltip_text = "Aproximar"
	plus.pressed.connect(zoom_in)
	body.add_child(plus)
	var reset: Button = _make_button("1:1",Vector2(148,0),Vector2(60,44))
	reset.tooltip_text = "Zoom padrão"
	reset.pressed.connect(reset_zoom)
	body.add_child(reset)
	UISkin.bind(panel,Vector2(216,48),"zoom")

func _make_button(text_value: String, pos: Vector2, button_size: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.position = pos
	button.size = button_size
	UISkin.button(button)
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
