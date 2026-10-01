extends SceneTree

const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Forest = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")
const Director = preload("res://scripts/cartoon/cartoon_exploration_director.gd")

var output: String

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	for i in range(8):
		await process_frame

func shot(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	assert(image.save_png(output.path_join(name+".png")) == OK)

func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	var hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	hub.hero.set_process(false)
	if hub.wildlife != null:
		hub.wildlife.set_process(false)

	var vale_site: Dictionary = Director.gathering_sites_for("REG_001_BERCO_VALEDOURO")[0]
	hub.hero.position = vale_site.pos
	hub._update_poi_hint()
	await shot("vale_resource_ready_mobile")
	assert(hub.poi_label.text.contains("COLETAR"))

	assert(hub.exploration_director.try_interact(220))
	hub._update_poi_hint()
	await shot("vale_resource_collected_mobile")

	hub.inventory_ui.open_panel("materials")
	await shot("materials_inventory_after_gather")
	hub.inventory_ui.close_panel()

	hub.queue_free()
	await settle()

	var forest = Forest.instantiate()
	root.add_child(forest)
	current_scene = forest
	await settle()
	forest.set_process(false)
	forest.hero.set_process(false)
	if forest.wildlife != null:
		forest.wildlife.set_process(false)
	var forest_site: Dictionary = Director.gathering_sites_for("REG_002_FLORESTA_ANCESTRAL")[0]
	forest.hero.position = forest_site.pos
	forest._update_poi_hint()
	await shot("forest_resource_ready_mobile")
	assert(forest.poi_label.text.contains("COLETAR"))

	state.reset_progress(true)
	print("gathering_v034 QA: visible resource, collection feedback, materials inventory and forest node")
	quit()
