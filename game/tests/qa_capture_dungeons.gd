extends SceneTree
# Capturas REAIS (Godot 4.7.2) da Etapa 4: Mina do Eco (3 zonas), Galeria Antiga (cripta), Ruínas e ambiente aéreo
# (fogo OGA, folhas, poeira). HUD oculto para ler o cenário. Uso: godot --path game --script tests/qa_capture_dungeons.gd -- <dir>
const REG = preload("res://scripts/reg001_world.gd")
var game: Node2D
var out_dir: String

func _initialize() -> void:
	call_deferred("run")

func shot(zone: String, pos: Vector2, name: String, t: float = 2.3) -> void:
	REG.clear_progress()
	if game.zone != zone:
		game.change_zone(zone, pos)
	game.zone = zone
	game.player = pos
	game.enemies.clear()
	game.dialog.hide()
	game.hint_timer = 0.0
	game.time_acc = t
	game.queue_redraw()
	for i in 3:
		await process_frame
	root.get_texture().get_image().save_png("%s/%s.png" % [out_dir, name])
	print("CAPTURED ", name)

func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	out_dir = args[0] if args.size() > 0 else ProjectSettings.globalize_path("user://dungeon_captures")
	DirAccess.make_dir_recursive_absolute(out_dir)
	game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.qa_hide_hud = true
	await shot("cidade", Vector2(1225, 2130), "01_entrada_mina_do_eco")
	await shot("masmorra", Vector2(480, 700), "02_mina_zona1_galeria")
	await shot("masmorra", Vector2(480, 500), "03_mina_zona2_nichos_gargulas")
	await shot("masmorra", Vector2(480, 330), "04_mina_zona3_arena_nucleo")
	await shot("cidade", Vector2(1400, 2160), "05_entrada_galeria_antiga")
	await shot("cripta", Vector2(480, 700), "06_cripta_armadilhas")
	await shot("cripta", Vector2(480, 470), "07_cripta_ossuario")
	await shot("cripta", Vector2(480, 250), "08_cripta_altar_gargulas")
	await shot("cidade", Vector2(790, 390), "09_ruinas_primeiro_vento")
	await shot("cidade", Vector2(2420, 2060), "10_ruinas_das_dunas")
	await shot("cidade", Vector2(1760, 420), "11_acampamento_fogo_ambiente")
	await shot("cidade", Vector2(560, 700), "12_floresta_folhas")
	quit(0)
