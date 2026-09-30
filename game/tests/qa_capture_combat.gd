extends SceneTree
# Capturas REAIS (Godot 4.7.2) de mobs/bosses animados e skills/VFX EM EXECUÇÃO (assets gratuitos adaptados).
# Uso: godot --path game --script tests/qa_capture_combat.gd -- <dir_saida>
const WORLD = preload("res://scripts/world_map.gd")
const REG = preload("res://scripts/reg001_world.gd")
var game: Node2D
var out_dir: String

func _initialize() -> void:
	call_deferred("run")

func snap(name: String, frames: int = 3) -> void:
	game.queue_redraw()
	for i in frames:
		await process_frame
	var image: Image = root.get_texture().get_image()
	image.save_png("%s/%s.png" % [out_dir, name])
	print("CAPTURED ", name)

func step(t: float, dt: float = 1.0 / 30.0) -> void:
	var n: int = int(t / dt)
	for i in n:
		game.time_acc += dt
		game.update_enemies(dt)
		game.resolve_fx(dt)

func setup(zone: String, pos: Vector2) -> void:
	game.set_process(false)             # o tempo avança só por step(): quadros determinísticos (o xvfb é lento e expiraria os VFX)
	REG.clear_progress()
	if game.zone != zone:
		game.change_zone(zone, pos)
	game.zone = zone
	game.player = pos
	game.enemies.clear()
	game.dialog.hide()
	game.hint = ""
	game.hint_timer = 0.0
	game.invulnerable = 0.0
	game.hp = game.max_hp * 5          # captura: o herói não pode desmaiar entre quadros
	game.fx.active.clear()
	game.fx.projectiles.clear()
	game.fx.strikes.clear()

func lineup(kinds: Array, center: Vector2, state: String, t: float) -> void:
	game.enemies.clear()
	for i in kinds.size():
		var e: Dictionary = game.make_enemy(str(kinds[i]), center + Vector2(-300 + i * 120, 40 + (i % 2) * 60))
		e["state"] = state
		e["state_time"] = t
		game.enemies.append(e)

func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	out_dir = args[0] if args.size() > 0 else ProjectSettings.globalize_path("user://combat_captures")
	DirAccess.make_dir_recursive_absolute(out_dir)
	game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	# 1) facções Foozle adaptadas em cada estado (mesma cena real do jogo, vale aberto junto ao ramal da ponte sul)
	var kinds: Array = ["Goblin Saqueador", "Goblin Fundeiro", "Esqueleto do Eco", "Arqueiro Ossudo", "Cultista da Coroa Oca", "Possesso do Eco"]
	setup("cidade", Vector2(1900, 1790))
	for st in ["idle", "walk", "attack", "hurt", "death"]:
		lineup(kinds, game.player, st, .25 if st != "death" else .45)
		game.time_acc = 3.7
		await snap("mobs_%s" % st)
	# 2) elite Brutamontes no acampamento dos saqueadores
	setup("cidade", Vector2(1700, 330))
	game.reg_game.elite_timer = 0.0
	game.reg_game.update_elites()
	for e in game.enemies:
		e["state"] = "attack"
		e["state_time"] = .3
	await snap("elite_brutamontes_ataque")
	# 3) Guardião do Eco (Skeleton King adaptado): preparação -> especial (raios + ondas) na Mina do Eco
	setup("masmorra", Vector2(470, 330))
	var g: Dictionary = game.make_enemy("Guardião", game.GUARDIAN_SPOT)
	game.enemies.append(g)
	g["boss_action"] = "shockwave"
	g["action_time"] = .6
	g["state"] = "attack"
	g["state_time"] = .1
	await snap("boss_guardiao_preparacao")
	g["special_cool"] = 99.0
	step(.40)
	g["state"] = "attack"
	await snap("boss_guardiao_especial_impacto")
	# 4) skills do herói: cajado (cast -> projétil -> impacto/área -> dissipação) e arco
	setup("cidade", Vector2(1900, 1790))
	var alvo: Dictionary = game.make_enemy("Goblin Saqueador", game.player + Vector2(120, 0))
	game.enemies.append(alvo)
	var alvo2: Dictionary = game.make_enemy("Goblin Fundeiro", game.player + Vector2(150, 30))
	game.enemies.append(alvo2)
	game.equipped_weapon = {"name": "Cajado", "kind": "staff", "tier": 2, "req": 1, "chapter": 0, "atk": 3}
	game.facing = Vector2.RIGHT
	game.attack_cooldown = 0.0
	game.attack()
	step(.06)
	await snap("skill_cajado_1_cast_projetil")
	step(.2)
	await snap("skill_cajado_2_impacto_area")
	step(.35)
	await snap("skill_cajado_3_dissipacao")
	game.equipped_weapon = {"name": "Arco", "kind": "bow", "tier": 1, "req": 1, "chapter": 0, "atk": 2}
	game.enemies.clear()
	game.enemies.append(game.make_enemy("Esqueleto do Eco", game.player + Vector2(170, 0)))
	game.attack_cooldown = 0.0
	game.attack()
	step(.1)
	await snap("skill_arco_flecha")
	# 5) espada: golpe com crescente embutido + impacto
	game.equipped_weapon = {}
	game.enemies.clear()
	game.enemies.append(game.make_enemy("Possesso do Eco", game.player + Vector2(30, 0)))
	game.attack_cooldown = 0.0
	game.attack()
	game.hero_attack_time = .25
	step(.03)
	await snap("skill_espada_golpe")
	# 6) feitiço do Cultista: marca no chão (telegraph) -> raio sombrio
	game.enemies.clear()
	var c: Dictionary = game.make_enemy("Cultista da Coroa Oca", game.player + Vector2(150, -20))
	game.enemies.append(c)
	step(.1)
	await snap("inimigo_cultista_telegraph")
	step(.7)
	await snap("inimigo_cultista_raio")
	quit(0)
