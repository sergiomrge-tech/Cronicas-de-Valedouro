extends SceneTree

const Gate = preload("res://tests/cartoon_ui_v021.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")

var output_dir: String

func _initialize() -> void:
	call_deferred("capture")

func settle() -> void:
	for i in range(5): await process_frame

func shot(name: String) -> void:
	await settle()
	var out: String = output_dir+"/"+name+".png"
	assert(root.get_texture().get_image().save_png(out) == OK)
	print("LAYOUT_CAPTURED ",out)

func capture() -> void:
	output_dir = ProjectSettings.globalize_path("user://ci_output_cartoon_layout")
	if not OS.get_cmdline_user_args().is_empty(): output_dir = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output_dir)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	for i in range(Gate.SCENES.size()):
		root.content_scale_size = Vector2i(960,540)
		root.size = Vector2i(960,540)
		var scene = load(Gate.SCENES[i]).instantiate()
		root.add_child(scene)
		await settle()
		scene.camera.position_smoothing_enabled = false
		if i == 0: scene.hero.position = Region.world_from_hub(Vector2(1150,970))
		var layout = scene.get_node("HUD/GameLayout")
		await shot("ato_%d_hud" % (i+1))
		if i == 0:
			layout._toggle_quest()
			await shot("objetivo_expandido")
			layout._toggle_quest()
			layout.open_pause()
			await shot("pausa")
			layout.close_pause()
			scene._toggle_map()
			await shot("mapa")
			scene._toggle_map()
			scene.inventory_ui.open_panel()
			await shot("bolsa")
			scene.inventory_ui.close_panel()
			scene.crafting_ui._toggle()
			await shot("forja")
			scene.crafting_ui.close_panel()
			for dimensions: Vector2i in [Vector2i(640,360),Vector2i(1200,540),Vector2i(1024,768)]:
				root.content_scale_size = dimensions
				root.size = dimensions
				await shot("hud_%dx%d" % [dimensions.x,dimensions.y])
		if i == 7:
			scene._show_choice()
			await shot("escolha_final")
			scene.choice_panel.visible = false
		scene.queue_free()
		await settle()
	state.reset_progress(true)
	print("LAYOUT_CAPTURE: PASS — 17 real screenshots")
	quit(0)
