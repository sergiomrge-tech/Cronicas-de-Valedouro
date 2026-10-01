extends SceneTree
const Hero = preload("res://scripts/cartoon/cartoon_hero.gd")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
const FX = preload("res://scripts/cartoon/cartoon_combat_fx.gd")
const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
var output: String
var stage: Node2D
var hero
func _initialize() -> void: call_deferred("run")
func label_at(copy: String, point: Vector2, font_size: int = 22) -> Label:
	var label = Label.new()
	label.text = copy
	label.position = point
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color("eadbb8"))
	stage.add_child(label)
	return label
func shot(key: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(key+".png"))
func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(800,600)
	root.content_scale_size = root.size
	stage = Node2D.new()
	root.add_child(stage)
	var background = Polygon2D.new()
	background.polygon = PackedVector2Array([Vector2.ZERO,Vector2(800,0),Vector2(800,600),Vector2(0,600)])
	background.color = Color("182b43")
	stage.add_child(background)
	for x in range(0,800,40):
		var line = Line2D.new()
		line.points = PackedVector2Array([Vector2(x,150),Vector2(x,570)])
		line.default_color = Color(0.25,0.44,0.60,0.12)
		line.width = 1
		stage.add_child(line)
	label_at("CRÔNICAS DE VALEDOURO",Vector2(32,22),28)
	var title = label_at("Herói • armadura, capa e animações",Vector2(32,70),20)
	label_at("Animação capturada diretamente no Godot",Vector2(32,560),14)
	hero = Hero.new()
	hero.position = Vector2(190,480)
	hero.scale = Vector2(3,3)
	stage.add_child(hero)
	hero.process_mode = Node.PROCESS_MODE_DISABLED
	var wolf = Monster.new()
	wolf.kind = "wolf"
	wolf.position = Vector2(594,470)
	wolf.scale = Vector2(2.5,2.5)
	stage.add_child(wolf)
	wolf.process_mode = Node.PROCESS_MODE_DISABLED
	var traveler_label = label_at("Viajante",Vector2(133,506),19)
	var wolf_label = label_at("Lobo do Vale",Vector2(534,506),19)
	for frame in range(24):
		hero.anim_t = frame/12.0
		hero.move_vector = Vector2.RIGHT
		hero.facing = Vector2.DOWN
		hero.queue_redraw()
		wolf.anim_t = frame/12.0
		wolf.queue_redraw()
		await shot("walk_%02d"%frame)
	wolf.queue_free()
	wolf_label.visible = false
	hero.move_vector = Vector2.ZERO
	for spell in range(3):
		hero.spell_index = spell
		hero.facing = Vector2.RIGHT
		var effect = FX.spawn(stage,Vector2(478,329),hero.SPELLS[spell],Vector2.RIGHT,hero.SPELL_COLORS[spell])
		effect.scale = Vector2(1.8,1.8)
		effect.process_mode = Node.PROCESS_MODE_DISABLED
		title.text = "Magia • "+hero.SPELL_NAMES[spell]+" • luz, partículas e runas"
		for frame in range(24):
			hero.anim_t = frame/24.0
			hero.cast_t = maxf(0.01,0.65-frame/24.0*0.65)
			hero.queue_redraw()
			effect.age = frame/24.0*0.8
			effect.queue_redraw()
			await shot(hero.SPELLS[spell]+"_%02d"%frame)
		effect.queue_free()
		hero.cast_t = 0
	title.text = "Ataque • animação, espada e armadura"
	for frame in range(24):
		hero.attack_t = 0.28-float(frame%8)/8*0.28
		hero.queue_redraw()
		await shot("attack_%02d"%frame)
	traveler_label.visible = false
	for child in stage.get_children():
		if child is ValedouroCartoonHero: child.visible = false
	title.text = "Criaturas • silhuetas, armaduras e cores por região"
	var kinds = ["goblin","slime","guardian","root_beast","ash_general","reed_lady","frost_captain","black_frost_general","tide_general","void_general","void_cartographer","azharel"]
	for i in range(kinds.size()):
		var mob = Monster.new()
		mob.kind = kinds[i]
		mob.position = Vector2(85+(i%6)*124,315+(i/6)*210)
		mob.scale = Vector2(1.05,1.05)
		stage.add_child(mob)
		label_at(kinds[i].replace("_"," "),mob.position+Vector2(-51,15),10)
	await shot("monster_gallery")
	stage.queue_free()
	await process_frame
	root.size = Vector2i(960,540)
	root.content_scale_size = root.size
	var hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	for i in range(10): await process_frame
	hub.hero.position = Vector2(4800,4000)
	hub.hero.facing = Vector2.RIGHT
	hub.camera.reset_smoothing()
	await shot("in_game_hud")
	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	for i in range(5): await process_frame
	await shot("mobile_hud")
	print("combat_v024 QA: real frames captured")
	quit()
