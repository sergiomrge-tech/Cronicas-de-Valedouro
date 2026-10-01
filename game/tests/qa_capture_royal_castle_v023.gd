extends SceneTree
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Palace = preload("res://scripts/cartoon/cartoon_royal_palace.gd")
var output: String
var hub
func _initialize() -> void:
	call_deferred("run")
func settle() -> void:
	for i in range(10): await process_frame
func capture(key: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(key+".png"))
func size_to(dimensions: Vector2i) -> void:
	root.content_scale_size = dimensions
	root.size = dimensions
func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	size_to(Vector2i(1600,1080))
	hub = HubScene.instantiate()
	root.add_child(hub)
	await settle()
	hub.hero.position = Region.world_from_hub(Region.CASTLE_DOOR)
	hub.camera.position = Vector2(0,-580)
	hub.camera.zoom = Vector2(0.85,0.85)
	hub.camera.reset_smoothing()
	hub.ui.visible = false
	await capture("01_castelo_monumental")
	hub.camera.position = Vector2.ZERO
	hub.ui.visible = true
	size_to(Vector2i(960,540))
	hub.zoom_controls.set_zoom_value(0.70,false)
	hub.camera.reset_smoothing()
	await capture("02_portao_e_jardins")
	hub._interact()
	await settle()
	hub.toast_label.text = ""
	hub.toast_timer = 0
	size_to(Vector2i(1600,1400))
	hub.camera.zoom = Vector2(0.38,0.38)
	hub.camera.position = Palace.BOUNDS.get_center()-hub.hero.position
	hub.camera.reset_smoothing()
	hub.ui.visible = false
	await capture("03_planta_palacio")
	hub.camera.position = Vector2.ZERO
	hub.camera.zoom = Vector2(0.70,0.70)
	size_to(Vector2i(1200,800))
	var spots: Dictionary = {"vestibule":Vector2(0,1100),"throne":Vector2(0,-270),"banquet":Vector2(-1420,600),"library":Vector2(1400,80),"bedroom":Vector2(1420,1160),"gallery":Vector2(-1430,-420),"council":Vector2(1390,-1190),"honor":Vector2(0,-1410)}
	for room in Palace.ROOMS:
		hub.hero.position = spots[room.id]
		hub.camera.position = room.rect.get_center()-hub.hero.position
		hub.camera.reset_smoothing()
		await capture("ala_"+String(room.id))
	hub.ui.visible = true
	hub.camera.position = Vector2.ZERO
	size_to(Vector2i(960,540))
	hub.hero.position = Vector2(0,-270)
	hub.camera.position = Vector2(0,-120)
	hub.camera.reset_smoothing()
	hub._interact()
	await capture("04_trono_e_rei")
	hub.ui.visible = false
	await capture("04_trono_panorama")
	hub.ui.visible = true
	hub.camera.position = Vector2.ZERO
	hub.toast_label.text = ""
	hub.toast_timer = 0
	hub.hero.position = Vector2(1420,1160)
	hub.player_hp = 4
	hub._interact()
	hub.camera.reset_smoothing()
	await capture("05_aposentos_jogaveis")
	hub.toast_label.text = ""
	hub.toast_timer = 0
	hub.hero.position = Vector2(0,-270)
	size_to(Vector2i(640,360))
	hub.camera.reset_smoothing()
	await capture("06_castelo_mobile")
	size_to(Vector2i(960,540))
	hub._toggle_map()
	hub.camera.reset_smoothing()
	hub._toggle_map()
	await capture("07_mapa_castelo")
	hub._toggle_map()
	state.reset_progress(true)
	print("royal_castle_v023 QA: 16 real Godot renders")
	quit(0)
