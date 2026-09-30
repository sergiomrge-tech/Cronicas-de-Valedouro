extends SceneTree
# Mosaico REAL (Godot 4.7.2) do mapa inteiro da REG_001: percorre a câmera em blocos, esconde a HUD e costura as capturas.
# Uso: godot --path game --script tests/qa_capture_mosaic.gd -- <arquivo_saida.png> [escala]
const WORLD = preload("res://scripts/world_map.gd")
const REG = preload("res://scripts/reg001_world.gd")

func _initialize() -> void:
	call_deferred("run")

func _hide_ui(n: Node) -> void:
	for c in n.get_children():
		if c is CanvasLayer:
			(c as CanvasLayer).visible = false
		elif c is Control:
			(c as Control).visible = false
		_hide_ui(c)

func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else ProjectSettings.globalize_path("user://mosaic.png")
	var scale: float = float(args[1]) if args.size() > 1 else 0.5
	var game: Node2D = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	REG.clear_progress()
	game.zone = "cidade"
	_hide_ui(game)
	game.qa_hide_hud = true
	var view: Vector2 = Vector2(960, 540)
	var world: Vector2 = WORLD.SIZE
	var mosaic: Image = Image.create(int(world.x * scale), int(world.y * scale), false, Image.FORMAT_RGBA8)
	var cols: int = int(ceil(world.x / view.x))
	var rows: int = int(ceil(world.y / view.y))
	for j in rows:
		for i in cols:
			var cam: Vector2 = Vector2(minf(i * view.x, world.x - view.x), minf(j * view.y, world.y - view.y))
			game.player = cam + view * .5
			game.enemies.clear()
			game.map_visible = false
			game.dialog.hide()
			game.hint = ""
			game.time_acc = 3.7
			game.hero_walking = false
			game.queue_redraw()
			for k in 4:
				await process_frame
			var shot: Image = root.get_texture().get_image()
			shot.convert(Image.FORMAT_RGBA8)
			var c: Vector2 = (game.player - view * .5).clamp(Vector2.ZERO, world - view)   # mesma fórmula de main.gd
			shot.resize(int(shot.get_width() * scale * view.x / shot.get_width()), int(shot.get_height() * scale * view.y / shot.get_height()), Image.INTERPOLATE_BILINEAR)
			mosaic.blit_rect(shot, Rect2i(Vector2i.ZERO, shot.get_size()), Vector2i(int(c.x * scale), int(c.y * scale)))
	assert(mosaic.save_png(out) == OK)
	print("MOSAIC ", out)
	quit(0)
