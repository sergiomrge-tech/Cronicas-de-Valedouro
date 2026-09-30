extends SceneTree

const ZoomControlsScript = preload("res://scripts/cartoon/cartoon_zoom_controls.gd")
const ForestScene = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var state = root.get_node_or_null("CartoonPlayerState")
	assert(state != null)
	state.reset_progress(true)
	assert(is_equal_approx(state.camera_zoom,1.0))

	var camera: Camera2D = Camera2D.new()
	root.add_child(camera)
	var ui: Control = ZoomControlsScript.new()
	root.add_child(ui)
	ui.setup(camera)
	await process_frame

	assert(is_equal_approx(ui.zoom_value(),1.0))
	assert(ui.percent_label.text == "100%")

	ui.zoom_in()
	assert(is_equal_approx(ui.zoom_value(),1.15))
	assert(is_equal_approx(state.camera_zoom,1.15))
	assert(ui.percent_label.text == "115%")

	for i in range(8):
		ui.zoom_out()
	assert(is_equal_approx(ui.zoom_value(),0.70))
	assert(is_equal_approx(state.camera_zoom,0.70))

	for i in range(10):
		ui.zoom_in()
	assert(is_equal_approx(ui.zoom_value(),1.50))
	assert(is_equal_approx(state.camera_zoom,1.50))

	ui.reset_zoom()
	assert(is_equal_approx(ui.zoom_value(),1.0))
	assert(ui.percent_label.text == "100%")

	state.set_camera_zoom(1.30)
	var forest: Node = ForestScene.instantiate()
	root.add_child(forest)
	await process_frame
	await process_frame
	assert(forest.zoom_controls != null)
	assert(is_equal_approx(forest.camera.zoom.x,1.30))
	forest.zoom_controls.zoom_out()
	assert(is_equal_approx(forest.camera.zoom.x,1.15))
	assert(is_equal_approx(state.camera_zoom,1.15))

	state.reset_progress(true)
	print("zoom_controls: PASS — botões +/−/1:1, limites 70–150% e persistência")
	quit(0)
