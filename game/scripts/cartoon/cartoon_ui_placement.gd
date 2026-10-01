extends Node
## Repositions a fixed-design panel in logical viewport coordinates.
## Bound methods disconnect automatically when their owner is freed.

var target: Control
var design_size: Vector2
var placement: String
var dimmer: ColorRect

static func usable(viewport: Viewport) -> Rect2:
	var rect: Rect2 = viewport.get_visible_rect()
	if OS.get_name() in ["Android","iOS"]:
		var safe: Rect2i = DisplayServer.get_display_safe_area()
		var window_size: Vector2 = Vector2(viewport.get_window().size)
		if safe.size.x > 0 and safe.size.y > 0 and window_size.x > 0 and window_size.y > 0:
			var ratio: Vector2 = rect.size/window_size
			rect = Rect2(Vector2(safe.position)*ratio,Vector2(safe.size)*ratio).intersection(rect)
	return rect.grow(-16.0)

static func toolbar_rect(viewport: Viewport, index: int) -> Rect2:
	var area: Rect2 = usable(viewport)
	return Rect2(area.position+Vector2(0,52+float(index)*52.0),Vector2(68,48))

func _ready() -> void:
	get_viewport().size_changed.connect(_layout)
	if dimmer != null:
		target.visibility_changed.connect(_sync_dimmer)
		_sync_dimmer()
	_layout()

func _sync_dimmer() -> void:
	if is_instance_valid(dimmer): dimmer.visible = target.visible

func _layout() -> void:
	if not is_instance_valid(target): return
	if is_instance_valid(dimmer):
		# CanvasLayer children can have a zero-size parent Control. Explicit bounds
		# keep the backdrop full-screen and block world input at every aspect ratio.
		dimmer.set_anchors_preset(Control.PRESET_TOP_LEFT)
		dimmer.position = Vector2.ZERO
		dimmer.size = get_viewport().get_visible_rect().size
	var area: Rect2 = usable(get_viewport())
	match placement:
		"center":
			var factor: float = minf(1.0,minf(area.size.x/design_size.x,area.size.y/design_size.y))
			target.scale = Vector2.ONE*factor
			target.size = design_size
			target.position = area.get_center()-design_size*factor*0.5
		"status": target.position = area.position+Vector2(76,0)
		"pause_zoom": target.position = Vector2(100,276)
		"pause_forge": target.position = Vector2(24,276)
		"zoom": target.position = Vector2(area.get_center().x-design_size.x*0.5,area.end.y-design_size.y)
		"forge", "bag": target.position = toolbar_rect(get_viewport(),0 if placement == "bag" else 2).position
		"menu":
			var factor: float = minf(1.0,area.size.y/design_size.y)
			target.scale = Vector2.ONE*factor
			target.position = Vector2(area.end.x-design_size.x*factor,area.get_center().y-design_size.y*factor*0.5)
		"footer":
			target.position = Vector2(area.position.x,area.end.y-22.0)
			target.size.x = area.size.x

func _exit_tree() -> void:
	if is_instance_valid(dimmer): dimmer.queue_free()
