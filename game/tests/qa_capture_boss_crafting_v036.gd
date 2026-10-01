extends SceneTree

const Forest = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")

var output: String
var forest

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
	state.player_level = 8
	state.save_profile()

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	forest = Forest.instantiate()
	root.add_child(forest)
	current_scene = forest
	await settle()
	forest.set_process(false)
	forest.hero.set_process(false)
	if forest.wildlife != null:
		forest.wildlife.set_process(false)
	var layout = forest.get_node("HUD/GameLayout")
	if layout.demon_director != null:
		layout.demon_director.set_process(false)

	var boss_loot: String = forest._award_combat_loot("boss","BOSS_RAIZ_OCA_001",14)
	forest._show_toast(boss_loot)
	await shot("boss_trophy_feedback_mobile")

	forest.crafting_ui._toggle()
	forest.crafting_ui._refresh()
	await shot("boss_recipe_unlocked_forge")

	forest.crafting_ui._craft_id("BOSS_HELM_ROOT_001")
	forest.crafting_ui.close_panel()
	forest.inventory_ui.open_panel("equipment")
	forest.inventory_ui._select_item("BOSS_HELM_ROOT_001")
	await shot("boss_item_inventory_paper_doll")

	forest.inventory_ui.close_panel()
	forest.hero.apply_equipment_from_state()
	await shot("boss_item_equipped_world")

	state.reset_progress(true)
	print("boss_crafting_v036 QA: trophy feedback, unlocked forge recipe, paper-doll and equipped boss visual")
	quit()
