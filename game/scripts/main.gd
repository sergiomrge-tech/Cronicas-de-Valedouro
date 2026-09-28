extends Node2D

const TILE: float = 32.0
const SIZE: Vector2 = Vector2(960, 896)
const VIEW_SIZE: Vector2 = Vector2(960, 540)
const FOREST_SIZE: Vector2 = Vector2(1825, 862)
const FORGE_SIZE: Vector2 = Vector2(1512, 1040)
const MAP = preload("res://scripts/world_map.gd")
const LOOT = preload("res://scripts/loot_system.gd")
const SAVE_PATH: String = "user://valedouro_v1.json"
const RANGES: Dictionary = {"cidade": 0, "floresta": 1, "masmorra": 2, "ferreiro": 3, "loja": 4, "alquimia": 5, "guilda": 6}
var zone: String = "cidade"
var player: Vector2 = MAP.TOWN + Vector2(884, 696)
var facing: Vector2 = Vector2.DOWN
var hp: int = 40
var max_hp: int = 40
var level: int = 1
var xp: int = 0
var gold: int = 35
var potions: int = 2
var weapon: int = 0
var armor: int = 0
var kills: Dictionary = {"Lobo": 0, "Limo": 0, "Aranha Sombria": 0, "Javali Musgoso": 0, "Flor Voraz": 0, "Escorpião": 0, "Escaravelho Âmbar": 0, "Lobo de Gelo": 0, "Golem de Geada": 0, "Guardião": 0}
var materials: Dictionary = {}
var stored_items: Array = []
var equipped_weapon: Dictionary = {"name": "Espada de Aprendiz", "kind": "sword", "tier": 0, "req": 1, "chapter": 0, "atk": 0}
var equipped_armor: Dictionary = {"name": "Roupa de Aprendiz", "kind": "armor", "tier": 0, "req": 1, "chapter": 0, "def": 0}
var inventory_page: int = 0
var quest: int = 0 # 0 disponível, 1 caçada, 2 pronta, 3 masmorra, 4 pronta, 5 concluída
var enemies: Array = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var time_acc: float = 0.0
var invulnerable: float = 0.0
var attack_cooldown: float = 0.0
var swing: float = 0.0
var hero_attack_time: float = 0.0
var hero_walk_time: float = 0.0
var hero_walking: bool = false
var swing_target: Vector2 = Vector2.ZERO
var spawn_timer: float = 0.0
var hint: String = "Visite a guilda para aceitar uma missão."
var hint_timer: float = 5.0
var joystick_id: int = -1
var joystick_origin: Vector2 = Vector2.ZERO
var joystick_vector: Vector2 = Vector2.ZERO
var hud: Label
var objective: Label
var toast_label: Label
var dialog: PanelContainer
var dialog_title: Label
var dialog_body: Label
var dialog_choices: VBoxContainer
var controller: Control
var hero: Texture2D
var textures: Dictionary = {}
var animals: Array = []
var map_visible: bool = false
var ui_font: Font
var panel_box: StyleBoxTexture
var floaters: Array = []   # números de dano e efeitos rápidos
const ENEMY_SHEETS: Dictionary = {"Lobo": "wolf", "Limo": "slime", "Aranha Sombria": "spider", "Javali Musgoso": "boar", "Flor Voraz": "flower_beast", "Escorpião": "scorpion", "Escaravelho Âmbar": "amber_beetle", "Lobo de Gelo": "ice_wolf", "Golem de Geada": "ice_golem", "Guardião": "boss"}
const ENEMY_FRAME_SIZE: Dictionary = {"Golem de Geada": 40.0, "Guardião": 64.0}
const ENEMY_STATE_ROW: Dictionary = {"idle": 0, "walk": 1, "attack": 2, "hurt": 3, "death": 4}
const ENEMY_DEATH_TIME: float = .72

func _ready() -> void:
	rng.seed = 27109
	for name in ["grass", "grass2", "path", "stone", "water", "shallow_water", "riverbank", "valley_grass", "desert_dune", "plank", "tree", "bush", "wall", "roof", "hero", "wolf", "slime", "boss", "meadow", "sand", "sand2", "snow", "snow2", "bridge", "river", "pine", "frost_tree", "cactus", "ice_rock", "sand_rock", "valley_rock", "reed", "dead_bush", "ice_crystal", "flower", "deer", "fox", "hare", "goat", "camel", "bird", "fish", "valedouro_art", "valedouro_blended", "outskirts_ground", "path_ground", "forest_art", "forge_art", "ui_wood_panel", "ui_wood_button", "scorpion", "ice_wolf", "hero_body", "wolf_anim", "slime_anim", "scorpion_anim", "ice_wolf_anim", "boss_anim", "wolf_full", "slime_full", "spider_full", "boar_full", "flower_beast_full", "scorpion_full", "amber_beetle_full", "ice_wolf_full", "ice_golem_full", "boss_full", "watchtower", "windmill", "desert_outpost", "ice_lodge", "shrine", "ruin_arch", "bird_anim", "ui_round_button", "ui_portrait", "icon_heart", "icon_coin", "icon_potion", "icon_xp", "btn_attack", "btn_interact", "btn_map", "btn_bag", "btn_potion"]:
		textures[name] = load("res://assets/%s.png" % name)
	for family in ["sword", "bow", "staff"]:
		for tier in 4:
			var key: String = "equip_%s_%d" % [family, tier]
			textures[key] = load("res://assets/%s.png" % key)
	for tier in range(1, 5):
		var key: String = "equip_armor_%d" % tier
		textures[key] = load("res://assets/%s.png" % key)
		textures["hero_armor_%d" % tier] = load("res://assets/hero_armor_%d.png" % tier)
	for family in ["sword", "bow", "staff"]:
		for tier in 4:
			textures["hero_%s_%d" % [family, tier]] = load("res://assets/hero_%s_%d.png" % [family, tier])
	hero = textures["hero"]
	ui_font = load("res://assets/fonts/PixelifySans.ttf")
	if ui_font is FontFile:
		# Fonte pixel nítida: sem suavização nem subpixel, como nos RPGs de 16 bits.
		ui_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		ui_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		ui_font.hinting = TextServer.HINTING_NONE
	panel_box = wood_style("ui_wood_panel", 12)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	load_game()
	make_ui()
	populate()
	queue_redraw()

func make_ui() -> void:
	controller = Control.new()
	controller.set_anchors_preset(Control.PRESET_FULL_RECT)
	controller.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ui_theme: Theme = Theme.new()
	ui_theme.default_font = ui_font
	ui_theme.default_font_size = 16
	controller.theme = ui_theme
	add_child(controller)
	hud = Label.new()
	hud.position = Vector2(12, 8)
	hud.visible = false # o HUD agora é desenhado com barras e ícones em _draw()
	hud.add_theme_font_size_override("font_size", 15)
	hud.add_theme_color_override("font_shadow_color", Color.BLACK)
	hud.add_theme_constant_override("shadow_offset_x", 1)
	hud.add_theme_constant_override("shadow_offset_y", 2)
	controller.add_child(hud)
	objective = Label.new()
	objective.position = Vector2(16, 84)
	objective.size = Vector2(430, 24)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective.add_theme_font_size_override("font_size", 13)
	objective.add_theme_color_override("font_color", Color(1, .95, .8))
	objective.add_theme_color_override("font_shadow_color", Color.BLACK)
	controller.add_child(objective)
	toast_label = Label.new()
	toast_label.position = Vector2(290, 122)
	toast_label.size = Vector2(380, 40)
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_color_override("font_color", Color(1, .89, .56))
	toast_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	controller.add_child(toast_label)
	add_button("btn_attack", Vector2(856, 360), 80, func(): attack())
	add_button("btn_interact", Vector2(776, 440), 60, func(): interact())
	add_button("btn_potion", Vector2(880, 458), 60, func(): use_potion())
	add_button("btn_bag", Vector2(896, 8), 56, func(): inventory())
	add_button("btn_map", Vector2(834, 8), 56, func(): map_visible = not map_visible)
	dialog = PanelContainer.new()
	dialog.position = Vector2(218, 89)
	dialog.custom_minimum_size = Vector2(524, 0)
	dialog.add_theme_stylebox_override("panel", wood_style("ui_wood_panel", 16))
	controller.add_child(dialog)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	dialog.add_child(column)
	dialog_title = Label.new()
	dialog_title.add_theme_font_size_override("font_size", 20)
	dialog_title.add_theme_color_override("font_color", Color(1, .9, .62))
	dialog_title.add_theme_color_override("font_shadow_color", Color(.08, .04, .14))
	dialog_title.add_theme_constant_override("shadow_offset_y", 2)
	column.add_child(dialog_title)
	dialog_body = Label.new()
	dialog_body.custom_minimum_size = Vector2(490, 0)
	dialog_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_body.add_theme_color_override("font_color", Color(1, .95, .83))
	dialog_body.add_theme_color_override("font_shadow_color", Color(.08, .04, .14))
	column.add_child(dialog_body)
	dialog_choices = VBoxContainer.new()
	column.add_child(dialog_choices)
	dialog.hide()
	refresh_ui()

func add_button(icon_name: String, pos: Vector2, size: float, callback: Callable) -> void:
	# Botões redondos dourados com ícone em pixel art (não dependem de símbolos da fonte).
	var button: Button = Button.new()
	button.icon = textures[icon_name]
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.position = pos
	button.custom_minimum_size = Vector2(size, size)
	button.size = Vector2(size, size)
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var pad: float = size * .27
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style: StyleBoxTexture = StyleBoxTexture.new()
		style.texture = textures["ui_round_button"]
		style.content_margin_left = pad
		style.content_margin_right = pad
		style.content_margin_top = pad
		style.content_margin_bottom = pad
		if state == "pressed":
			style.modulate_color = Color(.78, .72, .95)
		button.add_theme_stylebox_override(state, style)
	button.pressed.connect(callback)
	controller.add_child(button)

func wood_style(which: String, edge: float) -> StyleBoxTexture:
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = textures[which]
	style.texture_margin_left = edge
	style.texture_margin_right = edge
	style.texture_margin_top = edge
	style.texture_margin_bottom = edge
	style.content_margin_left = edge
	style.content_margin_right = edge
	style.content_margin_top = maxf(10.0, edge * .8)
	style.content_margin_bottom = maxf(10.0, edge * .8)
	return style

func decorate_button(button: Button) -> void:
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, wood_style("ui_wood_button", 11))
	button.add_theme_color_override("font_color", Color(1, .95, .8))
	button.add_theme_color_override("font_hover_color", Color(1, .9, .5))
	button.add_theme_color_override("font_pressed_color", Color(1, .8, .4))
	button.add_theme_color_override("font_focus_color", Color(1, .95, .8))
	button.add_theme_color_override("font_shadow_color", Color(.08, .04, .14))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 1)

func show_dialog(title: String, body: String, choices: Array) -> void:
	dialog_title.text = title
	dialog_body.text = body
	for child in dialog_choices.get_children():
		child.queue_free()
	for choice in choices:
		var button: Button = Button.new()
		button.text = choice[0]
		button.custom_minimum_size.y = 39
		decorate_button(button)
		button.pressed.connect(choice[1])
		dialog_choices.add_child(button)
	var close: Button = Button.new()
	close.text = "Fechar"
	decorate_button(close)
	close.pressed.connect(func(): dialog.hide())
	dialog_choices.add_child(close)
	dialog.show()

func refresh_ui() -> void:
	if hud == null:
		return
	hud.text = "LV %d  ♥ %d/%d  ✦ %d  🧪 %d" % [level, hp, max_hp, gold, potions]
	var tasks: Array[String] = ["Guilda: procure uma missão", "Caçada: lobos %d/3" % mini(kills["Lobo"], 3), "Guilda: resgate a recompensa", "Masmorra: derrote o Guardião", "Guilda: entregue o relatório", "Região protegida! Explore e evolua"]
	objective.text = "%s  •  %s" % [(MAP.biome(player).capitalize() if zone == "cidade" else zone.capitalize()), tasks[quest]]
	toast_label.text = hint if hint_timer > 0 else ""

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < 235 and event.position.y > 290 and not dialog.visible and joystick_id < 0:
			joystick_id = event.index
			joystick_origin = event.position
		if not event.pressed and event.index == joystick_id:
			joystick_id = -1
			joystick_vector = Vector2.ZERO
	elif event is InputEventScreenDrag and event.index == joystick_id:
		joystick_vector = (event.position - joystick_origin).limit_length(55) / 55.0

func _process(delta: float) -> void:
	time_acc += delta
	invulnerable = maxf(0, invulnerable - delta)
	attack_cooldown = maxf(0, attack_cooldown - delta)
	swing = maxf(0, swing - delta)
	hero_attack_time = maxf(0, hero_attack_time - delta)
	hint_timer = maxf(0, hint_timer - delta)
	for i in range(floaters.size() - 1, -1, -1):
		floaters[i]["t"] -= delta
		if floaters[i]["t"] <= 0:
			floaters.remove_at(i)
	for enemy in enemies:
		enemy["flash"] = maxf(0.0, float(enemy.get("flash", 0.0)) - delta)
	hero_walking = false
	if zone == "cidade":
		update_animals(delta)
	if not dialog.visible:
		var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if joystick_vector.length() > .1:
			direction = joystick_vector
		if direction.length() > .15:
			facing = direction.normalized()
			var next: Vector2 = player + direction.normalized() * 118.0 * delta
			if walkable(next):
				player = next
				hero_walking = true
		if Input.is_action_just_pressed("attack"):
			attack()
		if Input.is_action_just_pressed("interact"):
			interact()
		update_enemies(delta)
		if zone == "cidade" and MAP.town_area(player):
			enemies.clear()
		if zone in ["cidade", "floresta", "masmorra"]:
			spawn_timer -= delta
			if spawn_timer <= 0 and enemies.size() < 6 and (zone != "cidade" or not MAP.town_area(player)):
				spawn_enemy()
				spawn_timer = 5.0 if zone == "cidade" else 7.0
	if hero_walking:
		hero_walk_time += delta
	else:
		hero_walk_time = 0.0
	refresh_ui()
	queue_redraw()

func walkable(p: Vector2) -> bool:
	var bounds: Vector2 = MAP.SIZE if zone == "cidade" else FOREST_SIZE if zone == "floresta" else FORGE_SIZE if zone == "ferreiro" else SIZE
	if p.x < 32 or p.x > bounds.x - 32 or p.y < 40 or p.y > bounds.y - 34:
		return false
	if zone == "cidade":
		if MAP.obstacle_at(p):
			return false
		if MAP.town_area(p):
			var town_point: Vector2 = p - MAP.TOWN
			if town_point.distance_to(Vector2(874, 497)) < 85:
				return false
			if town_point.x > 1700 and town_point.y > 535:
				return false # visible water beside the eastern quay
			if not MAP.bridge_at(p) and town_point.y < 149 and town_point.x > 170 and town_point.x < 1570 and (town_point.x < 793 or town_point.x > 1008):
				return false # northern wall; the center gate stays open
			for rect in [Rect2(330, 36, 305, 294), Rect2(1085, 145, 325, 193), Rect2(292, 390, 335, 214), Rect2(1110, 390, 340, 224)]:
				if rect.grow(7).has_point(town_point):
					return false
	if zone == "floresta":
		# Grass and clearings remain freely explorable; only visible trunks, rocks and brook block.
		for obstacle in [[Vector2(166, 178), 66], [Vector2(495, 87), 63], [Vector2(739, 52), 63], [Vector2(1397, 127), 57], [Vector2(1735, 128), 63], [Vector2(398, 487), 44], [Vector2(660, 252), 42], [Vector2(1106, 290), 30]]:
			if p.distance_to(obstacle[0]) < obstacle[1]:
				return false
		if p.x > 1430 and p.x < 1610 and p.y > 55 and p.y < 660 and absf(p.x - (1515.0 + sin(p.y * .012) * 38.0)) < 54.0:
			return false
	elif zone == "ferreiro":
		if Rect2(415, 323, 633, 315).has_point(p) or Rect2(1280, 47, 227, 690).has_point(p):
			return false
	elif zone == "masmorra":
		for x in [6, 11, 18, 24]:
			for y in [8, 13, 19]:
				if Rect2(x * 32 - 8, y * 32 - 8, 48, 48).has_point(p):
					return false
	return true

func populate() -> void:
	enemies.clear()
	spawn_timer = 3.0
	if zone == "cidade" and animals.is_empty():
		populate_animals()
	if zone == "floresta":
		for i in 4:
			spawn_enemy()
	if zone == "masmorra":
		for i in 3:
			spawn_enemy()
		if quest >= 3 and kills["Guardião"] == 0:
			enemies.append(make_enemy("Guardião", Vector2(485, 240)))

func populate_animals() -> void:
	# The same seed gives a stable local ecosystem without adding animals to saves.
	var rr: RandomNumberGenerator = RandomNumberGenerator.new()
	rr.seed = 69279
	for region in [
		{"bounds": Rect2(100, 190, 860, 1150), "types": ["deer", "fox", "hare"], "count": 17},
		{"bounds": Rect2(890, 1640, 1050, 530), "types": ["deer", "hare", "bird"], "count": 14},
		{"bounds": Rect2(2390, 1460, 540, 650), "types": ["camel", "hare"], "count": 9},
		{"bounds": Rect2(2350, 150, 560, 620), "types": ["goat", "bird"], "count": 10}
	]:
		for index in region["count"]:
			for trial in 24:
				var box: Rect2 = region["bounds"]
				var p: Vector2 = Vector2(rr.randf_range(box.position.x, box.end.x), rr.randf_range(box.position.y, box.end.y))
				if not MAP.obstacle_at(p) and not MAP.path_at(p):
					animals.append({"pos": p, "home": p, "kind": region["types"][index % region["types"].size()], "angle": rr.randf_range(0, TAU), "phase": rr.randf_range(0, TAU), "timer": rr.randf_range(0, 4.0)})
					break
	for index in 12:
		var y: float = 330.0 + index * 143.0
		var p: Vector2 = Vector2(MAP.river_x(y), y)
		animals.append({"pos": p, "home": p, "kind": "fish", "angle": 0.0, "phase": float(index), "timer": 4.0})
	for index in 12:
		var p: Vector2 = MAP.TOWN + Vector2(720 + (index * 67) % 350, 385 + (index * 113) % 320)
		animals.append({"pos": p, "home": p, "kind": "bird" if index % 3 else "hare", "angle": rr.randf_range(0, TAU), "phase": float(index), "timer": rr.randf_range(1, 4)})

func update_animals(delta: float) -> void:
	for creature in animals:
		var p: Vector2 = creature["pos"]
		if p.distance_to(player) > 720:
			continue
		creature["phase"] += delta * (5.0 if creature["kind"] == "bird" else 2.1)
		creature["timer"] -= delta
		if creature["timer"] <= 0:
			creature["angle"] += rng.randf_range(-1.7, 1.7)
			creature["timer"] = rng.randf_range(1.5, 4.0)
		var away: Vector2 = (p - player).normalized() if p.distance_to(player) < 94 else Vector2.ZERO
		var direction: Vector2 = Vector2.RIGHT.rotated(float(creature["angle"]))
		var kind: String = creature["kind"]
		var speed: float = 20.0 if kind == "fish" else 31.0 if kind == "bird" else 17.0
		var next: Vector2 = p + (direction * speed + away * 80.0) * delta
		if next.distance_to(creature["home"]) > 150:
			creature["angle"] = (creature["home"] - p).angle()
		if kind == "fish":
			if MAP.river_at(next) and not MAP.bridge_at(next):
				creature["pos"] = next
		elif kind == "bird" or (MAP.biome(next) == MAP.biome(creature["home"]) and walkable(next)):
			creature["pos"] = next

func enemy_pool_for_biome(which: String) -> Array:
	var pool: Array = []
	match which:
		"floresta":
			pool = ["Lobo"]
			if level >= 2: pool.append("Aranha Sombria")
			if level >= 4: pool.append("Javali Musgoso")
		"campos", "pradaria":
			pool = ["Limo"]
			if level >= 4: pool.append("Flor Voraz")
		"vale":
			pool = ["Limo"]
			if level >= 4: pool.append("Javali Musgoso")
			if level >= 6: pool.append("Flor Voraz")
		"deserto":
			pool = ["Escorpião"]
			if level >= 8: pool.append("Escaravelho Âmbar")
		"gelo":
			pool = ["Lobo de Gelo"]
			if level >= 11: pool.append("Golem de Geada")
	return pool

func make_enemy(kind: String, p: Vector2) -> Dictionary:
	var life: int = monster_health(kind)
	return {"pos": p, "hp": life, "max_hp": life, "kind": kind, "cool": 0.0, "flash": 0.0, "state": "idle", "state_time": 0.0, "action_time": 0.0, "dead": false, "special_cool": 1.8 if kind == "Guardião" else 0.0, "boss_pattern": -1, "boss_action": "", "boss_hit_done": false}

func set_enemy_state(enemy: Dictionary, state: String) -> void:
	if str(enemy.get("state", "idle")) != state:
		enemy["state"] = state
		enemy["state_time"] = 0.0

func spawn_enemy() -> void:
	var current_biome: String = "floresta" if zone == "floresta" else "pradaria"
	if zone == "cidade":
		current_biome = MAP.biome(player)
	elif zone == "masmorra":
		current_biome = "pradaria"
	var pool: Array = enemy_pool_for_biome(current_biome)
	if zone == "masmorra":
		pool = ["Limo", "Aranha Sombria"] if level >= 2 else ["Limo"]
	if pool.is_empty():
		return
	var kind: String = str(pool[rng.randi_range(0, pool.size() - 1)])
	for attempt in 55:
		var p: Vector2
		if zone == "cidade":
			p = player + Vector2.RIGHT.rotated(rng.randf_range(0, TAU)) * rng.randf_range(220, 400)
			if MAP.town_area(p) or MAP.biome(p) != current_biome:
				continue
		elif zone == "floresta":
			p = Vector2(rng.randi_range(2, 54) * 32, rng.randi_range(3, 25) * 32)
		else:
			p = Vector2(rng.randi_range(2, 27) * 32, rng.randi_range(3, 25) * 32)
		if p.distance_to(player) > 145 and walkable(p):
			enemies.append(make_enemy(kind, p))
			return

func monster_health(kind: String) -> int:
	match kind:
		"Lobo": return 19
		"Limo": return 29
		"Aranha Sombria": return 27
		"Javali Musgoso": return 42
		"Flor Voraz": return 51
		"Escorpião": return 65
		"Escaravelho Âmbar": return 78
		"Lobo de Gelo": return 82
		"Golem de Geada": return 118
		"Guardião": return 70
	return 20

func monster_damage(kind: String) -> int:
	match kind:
		"Lobo": return 4
		"Limo": return 4
		"Aranha Sombria": return 5
		"Javali Musgoso": return 7
		"Flor Voraz": return 7
		"Escorpião": return 8
		"Escaravelho Âmbar": return 10
		"Lobo de Gelo": return 12
		"Golem de Geada": return 14
		"Guardião": return 9
	return 4

func monster_speed(kind: String) -> float:
	match kind:
		"Guardião": return 30.0
		"Golem de Geada": return 25.0
		"Flor Voraz": return 22.0
		"Escaravelho Âmbar": return 38.0
		"Javali Musgoso": return 47.0
		"Aranha Sombria": return 50.0
	return 43.0

func monster_gold(kind: String) -> int:
	match kind:
		"Lobo": return 4
		"Limo": return 7
		"Aranha Sombria": return 6
		"Javali Musgoso": return 9
		"Flor Voraz": return 10
		"Escorpião": return 13
		"Escaravelho Âmbar": return 16
		"Lobo de Gelo": return 19
		"Golem de Geada": return 25
		"Guardião": return 55
	return 4

func monster_xp(kind: String) -> int:
	match kind:
		"Lobo": return 12
		"Limo": return 18
		"Aranha Sombria": return 15
		"Javali Musgoso": return 21
		"Flor Voraz": return 23
		"Escorpião": return 27
		"Escaravelho Âmbar": return 31
		"Lobo de Gelo": return 34
		"Golem de Geada": return 42
		"Guardião": return 85
	return 10

func finish_enemy(index: int) -> void:
	if index < 0 or index >= enemies.size():
		return
	var enemy: Dictionary = enemies[index]
	var kind: String = enemy["kind"]
	var p: Vector2 = enemy["pos"]
	floaters.append({"pos": p, "text": "", "t": .45, "color": Color(1, 1, 1), "puff": true})
	enemies.remove_at(index)
	kills[kind] = int(kills.get(kind, 0)) + 1
	gold += monster_gold(kind)
	gain_xp(monster_xp(kind))
	var reward: Dictionary = LOOT.roll(kind, rng)
	if not reward.is_empty():
		var material_name: String = reward["material"]
		if not material_name.is_empty():
			materials[material_name] = int(materials.get(material_name, 0)) + 1
		var item: Dictionary = reward["item"]
		if not item.is_empty() and stored_items.size() < 30:
			stored_items.append(item)
			message("Equipamento raro encontrado: %s!" % item["name"])
	if rng.randf() < .17:
		potions += 1
		if hint_timer <= 0: message("Você encontrou uma poção!")
	if quest == 1 and int(kills.get("Lobo", 0)) >= 3:
		quest = 2
		message("Caçada concluída. Volte à guilda!")
	if quest == 3 and kind == "Guardião":
		quest = 4
		message("O Guardião caiu! Volte à guilda.")
	save_game()

func update_enemies(delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		enemy["state_time"] = float(enemy.get("state_time", 0.0)) + delta
		enemy["action_time"] = maxf(0.0, float(enemy.get("action_time", 0.0)) - delta)
		enemy["cool"] = maxf(0.0, float(enemy.get("cool", 0.0)) - delta)
		if bool(enemy.get("dead", false)):
			set_enemy_state(enemy, "death")
			if float(enemy.get("state_time", 0.0)) >= ENEMY_DEATH_TIME:
				finish_enemy(i)
			continue
		if zone == "cidade" and (enemy["pos"] as Vector2).distance_to(player) > 800:
			set_enemy_state(enemy, "idle")
			continue
		var dist: float = (enemy["pos"] as Vector2).distance_to(player)
		var moved: bool = false
		if str(enemy["kind"]) == "Guardião":
			enemy["special_cool"] = maxf(0.0, float(enemy.get("special_cool", 0.0)) - delta)
			var boss_action: String = str(enemy.get("boss_action", ""))
			if boss_action == "charge" and float(enemy.get("action_time", 0.0)) > 0:
				var charge_dir: Vector2 = (player - (enemy["pos"] as Vector2)).normalized()
				var charge_next: Vector2 = (enemy["pos"] as Vector2) + charge_dir * 132.0 * delta
				if walkable(charge_next):
					enemy["pos"] = charge_next
					moved = true
				set_enemy_state(enemy, "attack")
			elif boss_action == "shockwave" and float(enemy.get("action_time", 0.0)) > 0:
				set_enemy_state(enemy, "attack")
				if float(enemy.get("action_time", 0.0)) < .28 and not bool(enemy.get("boss_hit_done", false)):
					enemy["boss_hit_done"] = true
					if dist < 118.0 and invulnerable <= 0:
						var wave_taken: int = maxi(1, 12 - armor - int(equipped_armor.get("def", 0)))
						hp = maxi(0, hp - wave_taken)
						invulnerable = .8
						floaters.append({"pos": player + Vector2(0, -52), "text": "-%d" % wave_taken, "t": .7, "color": Color(1, .48, .72)})
						if hp <= 0:
							gold = maxi(0, gold - 8)
							hp = max_hp
							change_zone("cidade", MAP.TOWN + Vector2(884, 696))
							message("Você desmaiou diante do Guardião. A guilda o resgatou.")
							return
			elif float(enemy.get("action_time", 0.0)) <= 0:
				enemy["boss_action"] = ""
				if float(enemy.get("special_cool", 0.0)) <= 0 and dist < 260.0:
					var next_pattern: int = (int(enemy.get("boss_pattern", -1)) + 1) % 2
					enemy["boss_pattern"] = next_pattern
					enemy["special_cool"] = 3.0
					enemy["action_time"] = .74 if next_pattern == 0 else .62
					enemy["boss_action"] = "charge" if next_pattern == 0 else "shockwave"
					enemy["boss_hit_done"] = false
					set_enemy_state(enemy, "attack")
					continue
		if float(enemy.get("action_time", 0.0)) <= 0 and dist < 180 and dist > 23:
			var movement: Vector2 = (player - enemy["pos"]).normalized() * monster_speed(str(enemy["kind"])) * delta
			var next: Vector2 = enemy["pos"] + movement
			if walkable(next):
				enemy["pos"] = next
				moved = true
		if dist < 27 and float(enemy.get("cool", 0.0)) <= 0 and float(enemy.get("action_time", 0.0)) <= 0 and invulnerable <= 0:
			var taken: int = maxi(1, monster_damage(str(enemy["kind"])) - armor - int(equipped_armor.get("def", 0)))
			hp = maxi(0, hp - taken)
			floaters.append({"pos": player + Vector2(0, -52), "text": "-%d" % taken, "t": .7, "color": Color(1, .38, .42)})
			invulnerable = .75
			enemy["cool"] = 1.2
			enemy["action_time"] = .42
			set_enemy_state(enemy, "attack")
			if hp <= 0:
				gold = maxi(0, gold - 8)
				hp = max_hp
				change_zone("cidade", MAP.TOWN + Vector2(884, 696))
				message("Você desmaiou. A guilda o resgatou; perdeu 8 moedas.")
				return
		elif float(enemy.get("action_time", 0.0)) <= 0:
			set_enemy_state(enemy, "walk" if moved else "idle")

func attack() -> void:
	if dialog.visible or attack_cooldown > 0:
		return
	attack_cooldown = .37
	swing = .18
	hero_attack_time = .42
	swing_target = Vector2.ZERO
	var family: String = equipped_weapon.get("kind", "sword")
	var reach: float = 58.0 if family == "sword" else 185.0 if family == "bow" else 135.0
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		if bool(enemy.get("dead", false)):
			continue
		var offset: Vector2 = enemy["pos"] - player
		if offset.length() < reach and (offset.normalized().dot(facing) > (.42 if family != "sword" else .15) or offset.length() < 27):
			if family != "sword":
				swing_target = enemy["pos"]
			var forge_bonus: int = weapon * 5 if family == "sword" else 0
			var damage: int = 9 + forge_bonus + int(equipped_weapon.get("atk", 0)) + level * 2
			enemy["hp"] = int(enemy.get("hp", monster_health(str(enemy["kind"])))) - damage
			enemy["flash"] = .14
			enemy["action_time"] = .24
			set_enemy_state(enemy, "hurt")
			floaters.append({"pos": enemy["pos"] + Vector2(rng.randf_range(-6, 6), -30), "text": str(damage), "t": .7, "color": Color(1, .92, .45)})
			if offset.length() > 0:
				enemy["pos"] += offset.normalized() * 14
			if int(enemy["hp"]) <= 0:
				enemy["hp"] = 0
				enemy["dead"] = true
				enemy["action_time"] = ENEMY_DEATH_TIME
				set_enemy_state(enemy, "death")
			if family != "sword":
				break

func gain_xp(amount: int) -> void:
	xp += amount
	while xp >= level * 35 and level < level_cap():
		xp -= level * 35
		level += 1
		max_hp += 6
		hp = max_hp
		message("Novo nível %d! Vida e dano aumentaram." % level)
	if level >= level_cap():
		xp = mini(xp, level * 35 - 1)

func level_cap() -> int:
	if quest < 3: return 8
	if quest < 5: return 16
	return 20 # Prototype cap; full five-chapter campaign raises it to 50.

func message(value: String) -> void:
	hint = value
	hint_timer = 4.0

func use_potion() -> void:
	if potions > 0 and hp < max_hp:
		potions -= 1
		hp = mini(max_hp, hp + 25)
		message("Você recuperou vida.")
		save_game()

func change_zone(new_zone: String, entry: Vector2) -> void:
	zone = new_zone
	player = entry
	populate()
	save_game()

func interact() -> void:
	if dialog.visible:
		return
	if zone == "cidade":
		var local_pos: Vector2 = player - MAP.TOWN
		if local_pos.distance_to(Vector2(455, 357)) < 82:
			change_zone("guilda", Vector2(480, 719))
		elif local_pos.distance_to(Vector2(1235, 358)) < 82:
			change_zone("ferreiro", Vector2(754, 895))
		elif local_pos.distance_to(Vector2(1305, 650)) < 82:
			change_zone("loja", Vector2(480, 719))
		elif local_pos.distance_to(Vector2(464, 645)) < 82:
			change_zone("alquimia", Vector2(480, 719))
		elif local_pos.distance_to(Vector2(955, 795)) < 95:
			show_dialog("Portão da masmorra", "Desça às ruínas antigas. O Guardião aguarda no fundo.", [["Entrar", func(): dialog.hide(); change_zone("masmorra", Vector2(476, 745))]])
		elif player.distance_to(MAP.TOWN + Vector2(883, 65)) < 103:
			change_zone("floresta", Vector2(1000, 760))
		else:
			message("%s • Aproxime-se de uma porta, ruína ou do portal ao norte." % MAP.biome(player).capitalize())
	elif zone == "floresta":
		if player.distance_to(Vector2(1000, 790)) < 135:
			change_zone("cidade", MAP.TOWN + Vector2(884, 188))
		else:
			message("Explore os gramados livremente; a saída fica ao sul da trilha central.")
	elif zone == "masmorra":
		if player.y > 720:
			change_zone("cidade", MAP.TOWN + Vector2(955, 748))
		else:
			message("A saída fica ao sul.")
	else:
		if player.y > (845 if zone == "ferreiro" else 680):
			var outside: Vector2 = Vector2(1235, 365) if zone == "ferreiro" else Vector2(455, 365) if zone == "guilda" else Vector2(464, 660) if zone == "alquimia" else Vector2(1305, 664)
			change_zone("cidade", MAP.TOWN + outside)
		else:
			match zone:
				"guilda": guild_menu()
				"ferreiro": forge_menu()
				"loja": shop_menu()
				"alquimia": potion_menu()

func guild_menu() -> void:
	match quest:
		0: show_dialog("Guilda dos Exploradores", "Contrato: afaste três lobos da floresta. Recompensa: 60 moedas e 45 XP.", [["Aceitar contrato", func(): quest = 1; dialog.hide(); save_game(); message("Contrato aceito. Saia pelo norte da cidade.")]])
		1: show_dialog("Guilda dos Exploradores", "Lobos derrotados: %d/3. A floresta fica ao norte." % mini(kills["Lobo"], 3), [])
		2: show_dialog("Guilda dos Exploradores", "Excelente caçada! Seu próximo contrato é derrotar o Guardião da masmorra.", [["Receber 60 moedas + 45 XP", func(): claim_hunt_reward()]])
		3: show_dialog("Guilda dos Exploradores", "O Guardião ocupa a sala central da masmorra. Prepare suas poções e equipamentos.", [])
		4: show_dialog("Guilda dos Exploradores", "As ruínas estão seguras. Recompensa: 140 moedas, 120 XP e espada reforçada.", [["Receber recompensa", func(): claim_boss_reward()]])
		_: show_dialog("Guilda dos Exploradores", "Você salvou Valedouro. A floresta e as ruínas continuam abertas para evoluir.", [])

func claim_hunt_reward() -> void:
	gold += 60
	quest = 3
	gain_xp(45)
	dialog.hide()
	message("Novo contrato: explore as ruínas a sudeste.")
	save_game()

func claim_boss_reward() -> void:
	gold += 140
	quest = 5
	gain_xp(120)
	weapon = maxi(weapon, 2)
	equipped_weapon = {"name": "Espada dos Ecos", "kind": "sword", "tier": 2, "req": 1, "chapter": 0, "atk": 8}
	dialog.hide()
	message("Espada dos Ecos equipada. Seu visual mudou!")
	save_game()

func forge_menu() -> void:
	show_dialog("Ferreiro • Mestre Borin", "Uma forja acesa ilumina espadas e armaduras expostas. Arma +%d, armadura +%d. Próxima melhoria: %d moedas." % [weapon, armor, 30 + (weapon + armor) * 25], [["Aprimorar espada", func(): buy_upgrade(true)], ["Aprimorar armadura", func(): buy_upgrade(false)]])

func buy_upgrade(is_weapon: bool) -> void:
	var cost: int = 30 + (weapon + armor) * 25
	if gold < cost:
		message("Moedas insuficientes para a melhoria.")
		return
	if (weapon if is_weapon else armor) >= 5:
		message("Este equipamento já atingiu o limite.")
		return
	gold -= cost
	if is_weapon:
		weapon += 1
	else:
		armor += 1
		max_hp += 8
		hp += 8
	dialog.hide()
	message("Equipamento aprimorado!")
	save_game()

func shop_menu() -> void:
	show_dialog("Loja do Mercador", "Armas leves, capas e provisões para viajantes. Ouro: %d." % gold, [["Comprar poção • 15 moedas", func(): buy_potion(15)], ["Comprar armadura • 55 moedas", func(): buy_armor()]])

func potion_menu() -> void:
	show_dialog("Alquimista • Elara", "Frascos de ervas curativas. Uma poção restaura 25 pontos de vida.", [["Comprar poção • 12 moedas", func(): buy_potion(12)], ["Descansar • 8 moedas", func(): rest()]])

func buy_potion(cost: int) -> void:
	if gold < cost:
		message("Moedas insuficientes.")
		return
	gold -= cost
	potions += 1
	dialog.hide()
	message("Poção adicionada à bolsa.")
	save_game()

func buy_armor() -> void:
	if gold < 55 or armor >= 1:
		message("Exige 55 moedas e espaço para a armadura inicial.")
		return
	gold -= 55
	armor = 1
	max_hp += 8
	hp += 8
	dialog.hide()
	save_game()

func rest() -> void:
	if gold < 8:
		message("São necessárias 8 moedas.")
		return
	gold -= 8
	hp = max_hp
	dialog.hide()
	save_game()

func inventory() -> void:
	if dialog.visible:
		dialog.hide()
		return
	show_inventory()

func show_inventory() -> void:
	var first: int = inventory_page * 4
	var choices: Array = []
	for i in range(first, mini(first + 4, stored_items.size())):
		var index: int = i
		var item: Dictionary = stored_items[index]
		choices.append(["Equipar %s (Nv %d)" % [item["name"], item["req"]], func(): equip_item(index)])
	if first + 4 < stored_items.size():
		choices.append(["Próxima página", func(): inventory_page += 1; show_inventory()])
	if first > 0:
		choices.append(["Página anterior", func(): inventory_page -= 1; show_inventory()])
	choices.append(["Ver materiais", func(): show_materials()])
	var body: String = "Vida %d/%d  •  XP %d/%d  •  %d moedas\nArma: %s (+%d)\nArmadura: %s (+%d)\nBolsa: %d/30  •  Poções: %d  •  Teto: Lv %d" % [hp, max_hp, xp, level * 35, gold, equipped_weapon["name"], equipped_weapon.get("atk", 0), equipped_armor["name"], equipped_armor.get("def", 0), stored_items.size(), potions, level_cap()]
	show_dialog("Aventureiro • Nível %d" % level, body, choices)

func show_materials() -> void:
	var lines: String = "Materiais coletados:\n"
	if materials.is_empty():
		lines += "Ainda não há materiais na bolsa."
	else:
		for key in materials.keys():
			lines += "%s × %d\n" % [key, int(materials[key])]
	show_dialog("Bolsa de materiais", lines, [["Voltar aos equipamentos", func(): show_inventory()]])

func equip_item(index: int) -> void:
	if index < 0 or index >= stored_items.size():
		return
	var item: Dictionary = stored_items[index]
	if level < int(item.get("req", 1)) or quest < int(item.get("chapter", 0)):
		message("Exige nível %d e progresso da guilda %d." % [item.get("req", 1), item.get("chapter", 0)])
		return
	var armor_item: bool = item.get("kind", "") == "armor"
	var old: Dictionary = equipped_armor if armor_item else equipped_weapon
	stored_items.remove_at(index)
	if old.get("tier", 0) > 0:
		stored_items.append(old)
	if armor_item:
		equipped_armor = item
	else:
		equipped_weapon = item
	inventory_page = mini(inventory_page, maxi(0, (stored_items.size() - 1) / 4))
	show_inventory()
	message("%s agora aparece no aventureiro." % item["name"])
	save_game()

func save_game() -> void:
	var state: Dictionary = {"version": 4, "zone": zone, "px": player.x, "py": player.y, "hp": hp, "max_hp": max_hp, "level": level, "xp": xp, "gold": gold, "potions": potions, "weapon": weapon, "armor": armor, "kills": kills, "quest": quest, "materials": materials, "items": stored_items, "equipped_weapon": equipped_weapon, "equipped_armor": equipped_armor}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed as Dictionary
	if int(data.get("version", 0)) not in [1, 2, 3, 4]:
		return
	zone = str(data.get("zone", "cidade"))
	if not RANGES.has(zone):
		zone = "cidade"
	var old_pos: Vector2 = Vector2(float(data.get("px", 1534)), float(data.get("py", 1195)))
	if int(data.get("version", 0)) < 3:
		if zone == "cidade": old_pos = MAP.TOWN + Vector2(884, 696)
		elif zone == "floresta": old_pos = Vector2(1000, 760)
		elif zone == "ferreiro": old_pos = Vector2(754, 895)
	var world_bounds: Vector2 = MAP.SIZE if zone == "cidade" else FOREST_SIZE if zone == "floresta" else FORGE_SIZE if zone == "ferreiro" else SIZE
	player = old_pos.clamp(Vector2(40, 40), world_bounds - Vector2(40, 46))
	level = maxi(1, int(data.get("level", 1)))
	max_hp = maxi(40, int(data.get("max_hp", 40)))
	hp = clampi(int(data.get("hp", 40)), 1, max_hp)
	xp = maxi(0, int(data.get("xp", 0)))
	gold = maxi(0, int(data.get("gold", 35)))
	potions = maxi(0, int(data.get("potions", 2)))
	weapon = clampi(int(data.get("weapon", 0)), 0, 5)
	armor = clampi(int(data.get("armor", 0)), 0, 5)
	quest = clampi(int(data.get("quest", 0)), 0, 5)
	var saved_kills_value: Variant = data.get("kills", {})
	var saved_kills: Dictionary = saved_kills_value as Dictionary if saved_kills_value is Dictionary else {}
	for key in kills.keys():
		kills[key] = maxi(0, int(saved_kills.get(key, 0)))
	if int(data.get("version", 0)) >= 4:
		var saved_materials: Variant = data.get("materials", {})
		if saved_materials is Dictionary:
			materials = saved_materials
		var saved_items: Variant = data.get("items", [])
		if saved_items is Array:
			stored_items = saved_items.slice(0, 30)
		var saved_weapon: Variant = data.get("equipped_weapon", {})
		var saved_armor: Variant = data.get("equipped_armor", {})
		if saved_weapon is Dictionary and ["sword", "bow", "staff"].has(saved_weapon.get("kind", "")):
			equipped_weapon = saved_weapon
		if saved_armor is Dictionary and saved_armor.get("kind", "") == "armor":
			equipped_armor = saved_armor

func _draw() -> void:
	var world_bounds: Vector2 = MAP.SIZE if zone == "cidade" else FOREST_SIZE if zone == "floresta" else FORGE_SIZE if zone == "ferreiro" else SIZE
	var camera: Vector2 = (player - VIEW_SIZE * .5).clamp(Vector2.ZERO, world_bounds - VIEW_SIZE)
	draw_set_transform(-camera)
	var x_start: int = maxi(0, int(camera.x / TILE) - 2)
	var y_start: int = maxi(0, int(camera.y / TILE) - 2)
	var x_end: int = mini(int(ceil(world_bounds.x / TILE)), x_start + 36)
	var y_end: int = mini(int(ceil(world_bounds.y / TILE)), y_start + 23)
	if zone == "floresta":
		draw_texture(textures["forest_art"], Vector2.ZERO)
	elif zone == "ferreiro":
		draw_texture(textures["forge_art"], Vector2.ZERO)
	else:
		if zone == "cidade":
			# Repeated painterly ground replaces the flat 32px grass around Valedouro.
			draw_texture_rect(textures["outskirts_ground"], Rect2(Vector2.ZERO, MAP.SIZE), true)
		for y in range(y_start, y_end):
			for x in range(x_start, x_end):
				var index: int = x * 71 + y * 139
				var tex: Texture2D
				if zone == "cidade":
					var name: String = MAP.ground_at(Vector2(x * TILE + 16, y * TILE + 16))
					if name in ["grass", "grass2", "meadow"]:
						continue
					if name == "path":
						var tile_source: Rect2 = Rect2(Vector2((x * 32) % 512, (y * 32) % 512), Vector2(32, 32))
						draw_texture_rect_region(textures["path_ground"], Rect2(x * TILE, y * TILE, TILE, TILE), tile_source)
						continue
					tex = textures[name]
				elif zone in ["loja", "alquimia", "guilda"]:
					tex = textures["plank"]
				elif zone == "masmorra":
					tex = textures["stone"]
				else:
					tex = textures["grass2"] if index % 7 == 0 else textures["grass"]
				draw_texture_rect(tex, Rect2(x * TILE, y * TILE, TILE, TILE), false)
	if zone == "cidade":
		draw_overworld(camera, x_start, x_end, y_start, y_end)
		if Rect2(camera, VIEW_SIZE).intersects(MAP.TOWN_BOUNDS.grow(150.0)):
			draw_town_transition(camera)
		if Rect2(camera, VIEW_SIZE).intersects(MAP.TOWN_BOUNDS):
			draw_texture(textures["valedouro_blended"], MAP.TOWN)
			draw_town_life(camera)
			var gate: Vector2 = MAP.TOWN + Vector2(883, 65)
			draw_arc(gate, 28, 0, TAU, 26, Color(.71, .94, .56, .86), 4)
			draw_label("BOSQUE • E", gate + Vector2(-88, -42))
		var ruins: Vector2 = MAP.TOWN + Vector2(955, 795)
		if camera.distance_to(ruins) < 670:
			draw_circle(ruins, 29, Color(.26, .12, .52, .55))
			draw_arc(ruins, 30, 0, TAU, 25, Color(.64, .48, .99), 4)
			draw_label("RUÍNAS • E", ruins + Vector2(-76, -42))
		draw_animals(camera)
		draw_ambient_life(camera)
		draw_region_story_props(camera)
	elif zone == "masmorra":
		draw_dungeon()
	elif zone in ["loja", "alquimia", "guilda"]:
		draw_interior()
	for enemy in enemies:
		draw_enemy(enemy, camera)
	draw_shadow_oval(player + Vector2(0, 3), Vector2(15, 5), Color(0, 0, 0, .4))
	if invulnerable == 0 or int(time_acc * 15) % 2 == 0:
		var avatar_rect: Rect2 = Rect2(player - Vector2(24, 53), Vector2(48, 56))
		var direction_index: int = wrapi(roundi(atan2(facing.x, facing.y) / (PI / 4.0)), 0, 8)
		var column: int = 8 + mini(9, int((.42 - hero_attack_time) / .42 * 10.0)) if hero_attack_time > 0 else int(hero_walk_time * 12.0) % 8 if hero_walking else 0
		var source: Rect2 = Rect2(Vector2(column * 48, direction_index * 56), Vector2(48, 56))
		draw_texture_rect_region(textures["hero_body"], avatar_rect, source)
		var armor_tier: int = clampi(maxi(int(equipped_armor.get("tier", 0)), armor), 0, 4)
		if armor_tier > 0:
			draw_texture_rect_region(textures["hero_armor_%d" % armor_tier], avatar_rect, source)
		var family: String = equipped_weapon.get("kind", "sword")
		var weapon_tier: int = clampi(maxi(int(equipped_weapon.get("tier", 0)), weapon if family == "sword" else 0), 0, 3)
		draw_texture_rect_region(textures["hero_%s_%d" % [family, weapon_tier]], avatar_rect, source)
	if swing > 0:
		if swing_target != Vector2.ZERO:
			var projectile_color: Color = Color(.7, .93, 1) if equipped_weapon.get("kind", "") == "staff" else Color(1, .8, .46)
			draw_line(player + facing * 19, swing_target, projectile_color, 4)
			draw_circle(swing_target, 5, projectile_color)
		else:
			draw_arc(player + facing * 25, 22, facing.angle() - 1, facing.angle() + 1, 12, Color(1, .9, .48, swing * 5), 5)
	draw_floaters()
	draw_set_transform(Vector2.ZERO)
	draw_hud()
	if zone == "cidade" and map_visible:
		draw_world_minimap()

func draw_overworld(camera: Vector2, x_start: int, x_end: int, y_start: int, y_end: int) -> void:
	for y in range(y_start, y_end):
		for x in range(x_start, x_end):
			var p: Vector2 = Vector2(x * 32 + 16, y * 32 + 16)
			var name: String = MAP.ground_at(p)
			if name == "water" and (x + y) % 3 == 0:
				var current: float = sin(time_acc * 2.5 + x * 1.4 + y) * 6.0
				draw_line(p + Vector2(-9 + current, -3), p + Vector2(6 + current, -3), Color(.72, .93, .95, .62), 2)
			elif name == "shallow_water" and (x + y) % 2 == 0:
				var shimmer: float = sin(time_acc * 3.1 + x + y * .7) * 3.0
				draw_line(p + Vector2(-10 + shimmer, 2), p + Vector2(7 + shimmer, 2), Color(.84, 1, .93, .58), 1)
			elif name == "bridge":
				draw_line(p + Vector2(-14, -12), p + Vector2(14, -12), Color(.48, .34, .25), 2)
				draw_line(p + Vector2(-14, 10), p + Vector2(14, 10), Color(.48, .34, .25), 2)
			draw_biome_transition_detail(p, x, y)
			# Decorative vegetation layer: procedural but deterministic, and never over roads or water.
			var detail_seed: int = MAP.cell_hash(x + 91, y + 47)
			if not MAP.path_at(p) and not MAP.river_at(p) and not MAP.shallow_at(p) and not MAP.bridge_at(p) and not MAP.town_area(p):
				var biome_name: String = MAP.biome(p)
				if biome_name in ["floresta", "pradaria", "campos", "vale"]:
					if detail_seed % 5 == 0:
						draw_line(p + Vector2(-3, 6), p + Vector2(-1, -2), Color(.26, .46, .22, .7), 1)
						draw_line(p + Vector2(1, 6), p + Vector2(2, -1), Color(.34, .56, .27, .7), 1)
						draw_line(p + Vector2(4, 5), p + Vector2(6, 0), Color(.46, .68, .31, .7), 1)
					if detail_seed % 19 == 0:
						draw_circle(p + Vector2(-2, 4), 1.1, Color(.98, .95, .8, .95))
						draw_circle(p + Vector2(2, 3), 1.1, Color(.95, .74, .88, .95))
				elif biome_name == "deserto" and detail_seed % 17 == 0:
					draw_line(p + Vector2(-1, 5), p + Vector2(0, -2), Color(.71, .79, .45, .6), 1)
			var prop: String = MAP.prop_at(x, y)
			if prop.is_empty():
				continue
			var visual_seed: int = MAP.cell_hash(x + 113, y + 197)
			var jitter_x: float = float((visual_seed % 7) - 3)
			var jitter_y: float = float((int(visual_seed / 7) % 5) - 2)
			var pp: Vector2 = p + Vector2(jitter_x, jitter_y)
			if prop == "flower":
				draw_texture_rect(textures["flower"], Rect2(pp - Vector2(16, 16), Vector2(32, 32)), false)
			elif prop in ["pine", "tree", "frost_tree"]:
				var shadow_w: float = 18.0 + float(visual_seed % 5)
				draw_shadow_oval(pp + Vector2(5, 13), Vector2(shadow_w, 7), Color(0, 0, 0, .13))
				draw_shadow_oval(pp + Vector2(2, 15), Vector2(14, 5), Color(0, 0, 0, .29))
				var tone: Color = Color.WHITE
				if visual_seed % 3 == 1:
					tone = Color(.95, 1.0, .95, 1.0)
				elif visual_seed % 3 == 2:
					tone = Color(1.0, .96, .91, 1.0)
				draw_texture_rect(textures[prop], Rect2(pp - Vector2(32, 52), Vector2(64, 64)), false, tone)
			elif prop == "bush":
				draw_shadow_oval(pp + Vector2(2, 8), Vector2(11, 4), Color(0, 0, 0, .19))
				draw_texture_rect(textures[prop], Rect2(pp - Vector2(16, 16), Vector2(32, 32)), false)
			elif prop == "cactus":
				draw_shadow_oval(pp + Vector2(2, 13), Vector2(9, 3), Color(0, 0, 0, .16))
				draw_texture_rect(textures[prop], Rect2(pp - Vector2(16, 32), Vector2(32, 48)), false)
			elif prop == "ice_crystal":
				draw_shadow_oval(pp + Vector2(2, 10), Vector2(9, 3), Color(.1, .25, .35, .16))
				draw_texture_rect(textures[prop], Rect2(pp - Vector2(16, 28), Vector2(32, 40)), false)
			else:
				draw_texture_rect(textures[prop], Rect2(pp - Vector2(16, 16), Vector2(32, 32)), false)

	# Três travessias reutilizam a mesma linguagem de madeira/pedra, mas com silhuetas próprias.
	for index in range(MAP.BRIDGE_YS.size()):
		var by: float = float(MAP.BRIDGE_YS[index])
		var bridge_center: Vector2 = Vector2(MAP.river_x(float(by)), float(by))
		if camera.distance_to(bridge_center) < 700:
			draw_bridge_details(bridge_center, index)

	# Cascata: agora nasce entre rochas e se integra às margens refinadas.
	var falls: Vector2 = Vector2(MAP.river_x(471.0), 471.0)
	if camera.distance_to(falls) < 820:
		draw_rect(Rect2(falls + Vector2(-88, -43), Vector2(176, 42)), Color(.27, .35, .39))
		for rock_x in [-70, -52, 55, 72]:
			draw_circle(falls + Vector2(rock_x, -18), 15, Color(.38, .42, .48))
		for i in 10:
			var fx: float = falls.x - 50.0 + i * 11.0
			var drift: float = fposmod(time_acc * 41.0 + i * 9.0, 35.0)
			draw_line(Vector2(fx, falls.y - 8 + drift), Vector2(fx - 3, falls.y + 29 + drift), Color(.78, .94, .99, .9), 3)
		draw_shadow_oval(falls + Vector2(0, 76), Vector2(73, 18), Color(.86, .97, 1, .67))

	# Marcos e construções repetem escala, contorno e sombras da cidade v0.5.
	for entry in MAP.STRUCTURES:
		var center: Vector2 = entry["pos"] as Vector2
		if camera.distance_to(center) < 720:
			draw_world_structure(entry)
	for landmark in [[Vector2(230, 1240), "BOSQUE DO PRIMEIRO VENTO"], [Vector2(2520, 1700), "DUNAS DE ÂMBAR"], [Vector2(2460, 230), "PICOS DE GELO"], [Vector2(1250, 2020), "VALE DOS LÍRIOS"], [Vector2(2160, 510), "CASCATA DA AURORA"]]:
		if camera.distance_to(landmark[0]) < 480:
			draw_label(landmark[1], landmark[0], Color(.97, .92, .75))
	for settlement in [[Vector2(535, 1880), "VILA DOS CAMPOS", Color(.39, .53, .39)], [Vector2(1430, 1760), "ALDEIA DO VALE", Color(.46, .52, .34)], [Vector2(2520, 1580), "CARAVANA DE ÂMBAR", Color(.62, .43, .24)], [Vector2(2460, 560), "POUSO DA GEADA", Color(.48, .58, .69)]]:
		if camera.distance_to(settlement[0]) < 580:
			draw_settlement(settlement[0], settlement[1], settlement[2])

func draw_biome_transition_detail(p: Vector2, x: int, y: int) -> void:
	# Borda orgânica barata entre biomas: nunca cobre estrada, água ou cidade.
	if MAP.path_at(p) or MAP.river_at(p) or MAP.shallow_at(p) or MAP.bridge_at(p) or MAP.town_area(p):
		return
	var here: String = MAP.biome(p)
	var neighbors: Array[Vector2] = [Vector2(32, 0), Vector2(-32, 0), Vector2(0, 32), Vector2(0, -32)]
	var edge: bool = false
	for delta: Vector2 in neighbors:
		if MAP.biome(p + delta) != here:
			edge = true
			break
	if not edge:
		return
	var seed: int = MAP.cell_hash(x + 211, y + 307)
	var base_color: Color = Color(.36, .58, .30, .26)
	match here:
		"gelo": base_color = Color(.82, .94, .95, .34)
		"deserto": base_color = Color(.78, .62, .34, .28)
		"campos": base_color = Color(.58, .72, .35, .25)
		"vale": base_color = Color(.45, .64, .31, .26)
		"floresta": base_color = Color(.18, .39, .22, .28)
	for dot_index in 5:
		var dx: float = float((seed >> (dot_index * 2)) % 23) - 11.0
		var dy: float = float((seed >> (dot_index * 3 + 1)) % 19) - 9.0
		var rr: float = 2.0 + float((seed + dot_index * 7) % 4)
		draw_circle(p + Vector2(dx, dy), rr, base_color)
	if here in ["floresta", "campos", "vale"]:
		draw_line(p + Vector2(-9, 10), p + Vector2(-6, 1), Color(.31, .5, .24, .5), 1)
		draw_line(p + Vector2(7, 9), p + Vector2(5, 2), Color(.43, .62, .29, .45), 1)

func draw_town_transition(camera: Vector2) -> void:
	# Cinturão verde/pedra entre a pintura da vila e o mundo procedural.
	var bounds: Rect2 = MAP.TOWN_BOUNDS
	var points: Array[Vector2] = []
	for i in 18:
		var t: float = float(i) / 17.0
		points.append(Vector2(bounds.position.x + t * bounds.size.x, bounds.position.y - 28.0 - sin(i * 1.7) * 10.0))
		points.append(Vector2(bounds.position.x + t * bounds.size.x, bounds.end.y + 26.0 + cos(i * 1.3) * 10.0))
	for i in 9:
		var t2: float = float(i) / 8.0
		points.append(Vector2(bounds.position.x - 28.0 - sin(i * 1.4) * 9.0, bounds.position.y + t2 * bounds.size.y))
		points.append(Vector2(bounds.end.x + 28.0 + cos(i * 1.1) * 9.0, bounds.position.y + t2 * bounds.size.y))
	for index in range(points.size()):
		var p: Vector2 = points[index]
		if not Rect2(camera - Vector2(64, 64), VIEW_SIZE + Vector2(128, 128)).has_point(p):
			continue
		# abre clareiras nos quatro acessos principais.
		var local: Vector2 = p - MAP.TOWN
		if absf(local.x - 890.0) < 125.0 or absf(local.y - 478.0) < 105.0:
			continue
		var seed: int = MAP.cell_hash(index * 13 + 7, index * 29 + 3)
		if index % 3 == 0:
			draw_shadow_oval(p + Vector2(3, 7), Vector2(15, 5), Color(0, 0, 0, .12))
			draw_texture_rect(textures["bush"], Rect2(p - Vector2(16, 16), Vector2(32, 32)), false, Color(.94, 1, .92, 1))
		elif index % 3 == 1:
			draw_texture_rect(textures["flower"], Rect2(p - Vector2(16, 16), Vector2(32, 32)), false)
		else:
			var stone: Color = Color(.46, .45, .4)
			draw_shadow_oval(p + Vector2(2, 6), Vector2(12, 4), Color(0, 0, 0, .12))
			draw_circle(p, 7.0 + float(seed % 4), stone)
			draw_circle(p + Vector2(-2, -2), 3.0, stone.lightened(.22))
	# marcos baixos de pedra nas entradas dão continuidade à muralha.
	for gate in [MAP.TOWN + Vector2(890, -18), MAP.TOWN + Vector2(890, 905), MAP.TOWN + Vector2(-18, 478), MAP.TOWN + Vector2(1792, 478)]:
		if Rect2(camera - Vector2(60, 60), VIEW_SIZE + Vector2(120, 120)).has_point(gate):
			for side in [-1.0, 1.0]:
				var offset: Vector2 = Vector2(54.0 * side, 0) if absf(gate.y - (MAP.TOWN.y + 478.0)) > 100.0 else Vector2(0, 54.0 * side)
				var marker: Vector2 = gate + offset
				draw_rect(Rect2(marker - Vector2(7, 13), Vector2(14, 26)), Color(.38, .37, .35))
				draw_rect(Rect2(marker - Vector2(5, 11), Vector2(10, 20)), Color(.57, .55, .49))
				draw_circle(marker + Vector2(0, -13), 8, Color(.67, .64, .55))

func draw_bridge_details(center: Vector2, variant: int) -> void:
	var rail: Color = Color(.38, .25, .18) if variant != 0 else Color(.42, .43, .48)
	var glow: Color = Color(1, .75, .28, .82)
	for side in [-1.0, 1.0]:
		var y: float = center.y + side * 37.0
		draw_line(Vector2(center.x - 86, y), Vector2(center.x + 86, y), rail, 4)
		for xoff in [-74.0, -34.0, 34.0, 74.0]:
			draw_line(Vector2(center.x + xoff, y - 3), Vector2(center.x + xoff, y + 15 * side), rail, 3)
	if variant == 1:
		for xoff in [-76.0, 76.0]:
			draw_circle(center + Vector2(xoff, -48), 5, Color(.32, .2, .15))
			draw_circle(center + Vector2(xoff, -50), 3 + sin(time_acc * 6.0 + xoff) * .5, glow)
	elif variant == 0:
		for xoff in [-70.0, 70.0]:
			draw_rect(Rect2(center + Vector2(xoff - 5, -49), Vector2(10, 20)), Color(.45, .47, .55))

func draw_world_structure(entry: Dictionary) -> void:
	var center: Vector2 = entry["pos"] as Vector2
	var kind: String = entry["kind"]
	var tex: Texture2D = textures[kind] as Texture2D
	var sz: Vector2 = tex.get_size()
	draw_shadow_oval(center + Vector2(0, 12), Vector2(maxf(24.0, sz.x * .34), 10), Color(0, 0, 0, .24))
	draw_texture(tex, center - Vector2(sz.x * .5, sz.y - 18.0))
	draw_label(str(entry["label"]), center + Vector2(-90, -sz.y + 1), Color(1, .9, .65))

func draw_settlement(center: Vector2, label: String, roof_color: Color) -> void:
	# Pequenos assentamentos agora têm casas, cercas, poço e jardim em vez de três blocos simples.
	var house_positions: Array[Vector2] = [Vector2(-118, 14), Vector2(0, -26), Vector2(118, 20)]
	for index in range(house_positions.size()):
		var p: Vector2 = center + house_positions[index]
		draw_shadow_oval(p + Vector2(10, 31), Vector2(42, 13), Color(0, 0, 0, .24))
		draw_rect(Rect2(p - Vector2(31, 17), Vector2(62, 48)), Color(.67, .54, .38))
		draw_rect(Rect2(p - Vector2(31, 17), Vector2(62, 5)), Color(.45, .31, .22))
		draw_line(p + Vector2(-22, -12), p + Vector2(-22, 25), Color(.38, .25, .18), 3)
		draw_line(p + Vector2(22, -12), p + Vector2(22, 25), Color(.38, .25, .18), 3)
		draw_colored_polygon(PackedVector2Array([p + Vector2(-41, -14), p + Vector2(0, -55), p + Vector2(41, -14)]), roof_color.darkened(.22))
		draw_colored_polygon(PackedVector2Array([p + Vector2(-36, -16), p + Vector2(0, -50), p + Vector2(36, -16)]), roof_color)
		draw_line(p + Vector2(-25, -22), p + Vector2(0, -47), roof_color.lightened(.28), 2)
		draw_rect(Rect2(p + Vector2(-8, 2), Vector2(16, 29)), Color(.3, .2, .15))
		draw_rect(Rect2(p + Vector2(-25, -3), Vector2(12, 10)), Color(.31, .68, .76))
		draw_line(p + Vector2(-19, -2), p + Vector2(-19, 6), Color(.9, .86, .62), 1)
		if index != 1:
			draw_rect(Rect2(p + Vector2(21, -43), Vector2(8, 20)), Color(.43, .3, .25))
	# Cerca baixa e jardim deixam o assentamento integrado ao terreno.
	for side in [-1.0, 1.0]:
		var fx: float = center.x + side * 176.0
		draw_line(Vector2(fx, center.y + 16), Vector2(fx, center.y + 94), Color(.46, .31, .19), 3)
		for fy in range(24, 95, 18):
			draw_line(Vector2(fx - 7, center.y + fy), Vector2(fx + 7, center.y + fy), Color(.66, .46, .26), 2)
	var well: Vector2 = center + Vector2(0, 75)
	draw_shadow_oval(well + Vector2(2, 6), Vector2(20, 7), Color(0, 0, 0, .18))
	draw_circle(well, 17, Color(.38, .34, .32))
	draw_circle(well, 12, Color(.52, .49, .43))
	draw_circle(well, 8, Color(.18, .43, .55))
	for flower_index in 10:
		var angle: float = TAU * float(flower_index) / 10.0
		var fp: Vector2 = center + Vector2(cos(angle) * 82.0, 70.0 + sin(angle) * 23.0)
		draw_circle(fp, 2.0, Color(1, .8 if flower_index % 2 == 0 else .55, .72))
	draw_label(label, center + Vector2(-90, -100))

func draw_animals(camera: Vector2) -> void:
	for creature in animals:
		var p: Vector2 = creature["pos"]
		if not Rect2(camera - Vector2(40, 40), VIEW_SIZE + Vector2(80, 80)).has_point(p):
			continue
		var kind: String = creature["kind"]
		if kind != "fish" and kind != "bird":
			draw_shadow_oval(p + Vector2(0, 8), Vector2(12, 4), Color(0, 0, 0, .22))
		var bob: float = sin(float(creature["phase"])) * (3.0 if kind == "bird" else 1.5)
		var flip: float = -1.0 if cos(float(creature["angle"])) < 0 else 1.0
		draw_set_transform(p - camera, 0, Vector2(flip, 1))
		if kind == "bird":
			var frame: int = int(float(creature["phase"]) * 1.3) % 4
			draw_texture_rect_region(textures["bird_anim"], Rect2(Vector2(-16, -16 - bob), Vector2(32, 32)), Rect2(frame * 32, 0, 32, 32))
		else:
			draw_texture_rect(textures[kind], Rect2(Vector2(-16, -16 - bob), Vector2(32, 32)), false)
		draw_set_transform(-camera)


func draw_ambient_life(camera: Vector2) -> void:
	# Partículas ambientais baratas reforçam a identidade de cada bioma sem nós extras.
	var biome_name: String = MAP.biome(player)
	for i in 12:
		var seed: int = MAP.cell_hash(i + int(camera.x / 64.0) * 3, i * 11 + int(camera.y / 64.0) * 5)
		var lx: float = fposmod(float(seed % 941) + time_acc * float(8 + seed % 9), VIEW_SIZE.x)
		var ly: float = fposmod(float((seed / 13) % 521) + sin(time_acc * .8 + i) * 18.0, VIEW_SIZE.y)
		var wp: Vector2 = camera + Vector2(lx, ly)
		if biome_name in ["floresta", "campos", "vale", "pradaria"]:
			var wing: float = sin(time_acc * 7.0 + i) * 2.0
			var c: Color = Color(1, .88, .42, .72) if i % 3 else Color(.66, .9, 1, .7)
			draw_circle(wp + Vector2(-2 - wing, 0), 1.5, c)
			draw_circle(wp + Vector2(2 + wing, 0), 1.5, c)
			draw_circle(wp, .8, Color(.24, .18, .16, .85))
		elif biome_name == "gelo":
			var snow: float = fposmod(ly + time_acc * 22.0 + i * 9.0, VIEW_SIZE.y)
			draw_circle(camera + Vector2(lx, snow), 1.4 + float(i % 2), Color(.94, .99, 1, .72))
		elif biome_name == "deserto":
			var drift: float = fposmod(lx + time_acc * 32.0, VIEW_SIZE.x)
			draw_line(camera + Vector2(drift, ly), camera + Vector2(drift + 13, ly - 2), Color(.94, .82, .55, .24), 1)

func draw_town_life(camera: Vector2) -> void:
	# Pessoas, banca de mercado, iluminação e pequenos props tornam a cidade habitada.
	var npc_local: Array[Vector2] = [
		Vector2(705, 310), Vector2(1010, 315), Vector2(600, 520), Vector2(1165, 525),
		Vector2(760, 675), Vector2(1035, 650), Vector2(520, 735), Vector2(1290, 730),
		Vector2(835, 430), Vector2(980, 470)
	]
	for i in range(npc_local.size()):
		var base: Vector2 = MAP.TOWN + npc_local[i]
		var walk: Vector2 = Vector2(sin(time_acc * (.45 + i * .03) + i) * 18.0, cos(time_acc * (.31 + i * .02) + i * .7) * 8.0)
		var p: Vector2 = base + walk
		if not Rect2(camera - Vector2(48, 64), VIEW_SIZE + Vector2(96, 128)).has_point(p):
			continue
		draw_shadow_oval(p + Vector2(0, 4), Vector2(11, 4), Color(0, 0, 0, .28))
		var frame: int = int(time_acc * 5.0 + i * 2) % 8
		var direction: int = 2 if sin(time_acc + i) > 0 else 6
		var src: Rect2 = Rect2(Vector2(frame * 48, direction * 56), Vector2(48, 56))
		var tint: Color = [Color(.9, .75, .65), Color(.68, .86, .76), Color(.76, .72, .95), Color(.95, .8, .55)][i % 4]
		draw_texture_rect_region(textures["hero_body"], Rect2(p - Vector2(17, 37), Vector2(34, 40)), src, tint)
	# Mercado pequeno junto ao eixo principal.
	for stall_data in [
		[MAP.TOWN + Vector2(735, 570), Color(.62, .24, .3)],
		[MAP.TOWN + Vector2(1070, 570), Color(.23, .42, .62)]
	]:
		var stall: Vector2 = stall_data[0] as Vector2
		var cloth: Color = stall_data[1] as Color
		draw_shadow_oval(stall + Vector2(0, 19), Vector2(38, 10), Color(0, 0, 0, .22))
		draw_rect(Rect2(stall + Vector2(-34, -2), Vector2(68, 30)), Color(.48, .3, .18))
		draw_colored_polygon(PackedVector2Array([stall + Vector2(-42, -2), stall + Vector2(-31, -27), stall + Vector2(31, -27), stall + Vector2(42, -2)]), cloth)
		for item_index in 4:
			draw_circle(stall + Vector2(-24 + item_index * 16, 5), 4, Color(1, .72 if item_index % 2 else .4, .28))
	# Lampiões na avenida.
	for local_y in [220.0, 390.0, 610.0, 770.0]:
		for local_x in [810.0, 970.0]:
			var lamp: Vector2 = MAP.TOWN + Vector2(local_x, local_y)
			draw_line(lamp, lamp + Vector2(0, 24), Color(.28, .2, .16), 3)
			draw_circle(lamp, 8, Color(1, .72, .25, .15))
			draw_circle(lamp, 4, Color(1, .78, .3, .85))

func draw_region_story_props(camera: Vector2) -> void:
	var biome_name: String = MAP.biome(player)
	if biome_name in ["campos", "vale"]:
		for bale in [Vector2(430, 1910), Vector2(615, 2035), Vector2(1510, 1950), Vector2(1750, 2110)]:
			if Rect2(camera - Vector2(30, 30), VIEW_SIZE + Vector2(60, 60)).has_point(bale):
				draw_shadow_oval(bale + Vector2(2, 7), Vector2(15, 5), Color(0, 0, 0, .16))
				draw_rect(Rect2(bale - Vector2(15, 9), Vector2(30, 18)), Color(.75, .58, .24))
				draw_line(bale + Vector2(-13, -3), bale + Vector2(13, -3), Color(.96, .78, .34), 2)
		for cart in [Vector2(760, 1870), Vector2(1320, 2100)]:
			if Rect2(camera - Vector2(60, 40), VIEW_SIZE + Vector2(120, 80)).has_point(cart):
				draw_rect(Rect2(cart - Vector2(28, 13), Vector2(56, 24)), Color(.45, .28, .16))
				draw_circle(cart + Vector2(-20, 16), 9, Color(.22, .16, .13))
				draw_circle(cart + Vector2(20, 16), 9, Color(.22, .16, .13))
				draw_line(cart + Vector2(28, 0), cart + Vector2(54, -10), Color(.45, .28, .16), 4)
	elif biome_name == "gelo":
		for drift in [Vector2(2500, 330), Vector2(2780, 430), Vector2(2460, 690)]:
			if Rect2(camera - Vector2(40, 40), VIEW_SIZE + Vector2(80, 80)).has_point(drift):
				draw_colored_polygon(PackedVector2Array([drift + Vector2(-28, 9), drift + Vector2(-7, -8), drift + Vector2(15, -3), drift + Vector2(31, 9)]), Color(.9, .97, 1, .8))
		var camp: Vector2 = Vector2(2685, 690)
		if Rect2(camera - Vector2(60, 60), VIEW_SIZE + Vector2(120, 120)).has_point(camp):
			draw_circle(camp, 14, Color(.98, .33, .08, .12))
			draw_line(camp + Vector2(-10, 7), camp + Vector2(10, -7), Color(.35, .23, .16), 4)
			draw_line(camp + Vector2(-10, -7), camp + Vector2(10, 7), Color(.35, .23, .16), 4)
			draw_circle(camp + Vector2(0, -5), 7 + sin(time_acc * 7.0), Color(1, .55, .16, .85))
	elif biome_name == "deserto":
		for bones in [Vector2(2520, 1750), Vector2(2830, 2010), Vector2(2380, 1920)]:
			if Rect2(camera - Vector2(50, 50), VIEW_SIZE + Vector2(100, 100)).has_point(bones):
				draw_line(bones + Vector2(-12, -3), bones + Vector2(12, 3), Color(.85, .78, .61), 3)
				draw_line(bones + Vector2(-8, 7), bones + Vector2(9, -8), Color(.85, .78, .61), 3)
		var camp2: Vector2 = Vector2(2760, 1690)
		if Rect2(camera - Vector2(80, 80), VIEW_SIZE + Vector2(160, 160)).has_point(camp2):
			draw_colored_polygon(PackedVector2Array([camp2 + Vector2(-50, 25), camp2 + Vector2(0, -32), camp2 + Vector2(50, 25)]), Color(.7, .29, .27))
			draw_colored_polygon(PackedVector2Array([camp2 + Vector2(-36, 21), camp2 + Vector2(0, -20), camp2 + Vector2(36, 21)]), Color(.92, .63, .35))
	elif biome_name == "floresta":
		for log in [Vector2(250, 620), Vector2(630, 920), Vector2(470, 1180)]:
			if Rect2(camera - Vector2(60, 60), VIEW_SIZE + Vector2(120, 120)).has_point(log):
				draw_shadow_oval(log + Vector2(3, 8), Vector2(28, 7), Color(0, 0, 0, .16))
				draw_line(log + Vector2(-26, 2), log + Vector2(27, -4), Color(.37, .23, .15), 11)
				draw_circle(log + Vector2(-26, 2), 7, Color(.59, .38, .2))

func draw_world_minimap() -> void:
	var origin: Vector2 = Vector2(353, 145)
	var scale: Vector2 = Vector2(240.0 / MAP.SIZE.x, 179.0 / MAP.SIZE.y)
	draw_style_box(panel_box, Rect2(origin - Vector2(18, 38), Vector2(276, 262)))
	draw_string_outline(ui_font, origin + Vector2(0, -10), "MAPA DE VALEDOURO", HORIZONTAL_ALIGNMENT_LEFT, 240, 16, 4, Color(.1, .05, .16))
	draw_string(ui_font, origin + Vector2(0, -10), "MAPA DE VALEDOURO", HORIZONTAL_ALIGNMENT_LEFT, 240, 16, Color(1, .86, .45))
	for my in 24:
		for mx in 32:
			var p: Vector2 = Vector2((mx + .5) * MAP.SIZE.x / 32, (my + .5) * MAP.SIZE.y / 24)
			var biome_name: String = MAP.biome(p)
			var color: Color = Color(.22, .49, .3)
			match biome_name:
				"cidade": color = Color(.67, .47, .32)
				"gelo": color = Color(.72, .85, .88)
				"deserto": color = Color(.83, .69, .42)
				"campos": color = Color(.56, .7, .36)
				"vale": color = Color(.45, .62, .3)
				"floresta": color = Color(.13, .36, .23)
			if MAP.river_at(p):
				color = Color(.31, .69, .79)
			draw_rect(Rect2(origin + Vector2(mx * 7.5, my * 7.46), Vector2(8, 8)), color)
	var pulse: float = 4.0 + sin(time_acc * 6.0) * 1.5
	draw_circle(origin + player * scale, pulse + 2, Color(.1, .05, .16))
	draw_circle(origin + player * scale, pulse, Color(1, .3, .35))
	draw_string(ui_font, origin + Vector2(0, 200), "Ponto vermelho: você  •  mapa fecha no botão", HORIZONTAL_ALIGNMENT_LEFT, 248, 12, Color(1, .95, .8))

func draw_shadow_oval(center: Vector2, radii: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for step in 20:
		var angle: float = TAU * step / 20.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)

func draw_label(text: String, p: Vector2, color: Color = Color(1, .88, .64)) -> void:
	draw_string_outline(ui_font, p, text, HORIZONTAL_ALIGNMENT_CENTER, 180, 16, 4, Color(.1, .05, .16))
	draw_string(ui_font, p, text, HORIZONTAL_ALIGNMENT_CENTER, 180, 16, color)

func draw_dungeon() -> void:
	# Ruínas compactas, com arena central legível e iluminação ritual.
	# Faixas de sombra e piso quebrado retiram o aspecto de um único tile repetido.
	draw_rect(Rect2(64, 96, 832, 690), Color(.12, .09, .18, .13))
	for stripe_y in range(124, 760, 96):
		draw_rect(Rect2(72, stripe_y, 816, 18), Color(.08, .06, .14, .11))
	for patch in [Rect2(90, 260, 115, 70), Rect2(710, 260, 120, 80), Rect2(300, 540, 150, 75), Rect2(565, 555, 135, 72)]:
		draw_rect(patch, Color(.08, .06, .13, .16))
		for crack_index in 4:
			var cp: Vector2 = patch.position + Vector2(18 + crack_index * 27, 18 + (crack_index % 2) * 16)
			draw_line(cp, cp + Vector2(12, 7), Color(.55, .48, .66, .30), 1)
	for x in range(0, 30):
		for y in [0, 1, 26, 27]:
			draw_texture_rect(textures["wall"], Rect2(x * 32, y * 32, 32, 32), false)
	for y in 28:
		for x in [0, 1, 28, 29]:
			draw_texture_rect(textures["wall"], Rect2(x * 32, y * 32, 32, 32), false)
	for x in [6, 11, 18, 24]:
		for y in [8, 13, 19]:
			var pillar: Vector2 = Vector2(x * 32 + 16, y * 32 + 16)
			draw_shadow_oval(pillar + Vector2(4, 13), Vector2(20, 6), Color(0, 0, 0, .25))
			draw_texture_rect(textures["wall"], Rect2(x * 32, y * 32, 32, 32), false)
			draw_rect(Rect2(pillar + Vector2(-11, -18), Vector2(22, 5)), Color(.49, .45, .58))
	# Fissuras e pedras quebradas no piso.
	for crack in [Vector2(123, 310), Vector2(330, 610), Vector2(650, 360), Vector2(784, 690), Vector2(515, 530), Vector2(260, 450)]:
		draw_line(crack, crack + Vector2(17, 8), Color(.18, .16, .24, .7), 2)
		draw_line(crack + Vector2(9, 4), crack + Vector2(5, 17), Color(.18, .16, .24, .6), 1)
	# Arena do Guardião.
	var arena: Vector2 = Vector2(485, 240)
	draw_circle(arena, 112, Color(.18, .12, .28, .34))
	draw_arc(arena, 112, 0, TAU, 56, Color(.52, .38, .72, .75), 4)
	draw_arc(arena, 86, 0, TAU, 48, Color(.34, .24, .52, .65), 2)
	for rune_index in 8:
		var angle: float = TAU * float(rune_index) / 8.0
		var rp: Vector2 = arena + Vector2(cos(angle), sin(angle)) * 96.0
		draw_colored_polygon(PackedVector2Array([rp + Vector2(0, -6), rp + Vector2(5, 4), rp + Vector2(-5, 4)]), Color(.72, .5, 1, .72))
	# Tochas com flicker e luz local.
	for p in [Vector2(225, 185), Vector2(745, 185), Vector2(225, 629), Vector2(745, 629)]:
		draw_circle(p, 22, Color(.95, .32, .08, .08))
		draw_rect(Rect2(p + Vector2(-2, 5), Vector2(4, 15)), Color(.37, .23, .15))
		var flame: float = 6.0 + sin(time_acc * 8.0 + p.x) * 1.5
		draw_circle(p, flame + 5, Color(.92, .38, .12, .58))
		draw_circle(p + Vector2(0, -2), flame, Color(1, .82, .31, .9))
		draw_circle(p + Vector2(-1, -4), 3, Color(1, .96, .66))
	# Alcovas laterais com relíquias e ossadas criam narrativa ambiental.
	for alcove in [Vector2(100, 420), Vector2(860, 420)]:
		draw_rect(Rect2(alcove + Vector2(-42, -55), Vector2(84, 108)), Color(.10, .08, .16, .45))
		draw_arc(alcove + Vector2(0, -18), 37, PI, TAU, 24, Color(.46, .40, .57, .8), 4)
		draw_rect(Rect2(alcove + Vector2(-31, -18), Vector2(62, 63)), Color(.17, .14, .23, .65))
		draw_circle(alcove + Vector2(0, 18), 8, Color(.66, .58, .45))
		draw_line(alcove + Vector2(-18, 28), alcove + Vector2(17, 7), Color(.73, .68, .56), 3)
		draw_line(alcove + Vector2(-14, 6), alcove + Vector2(18, 30), Color(.73, .68, .56), 3)
	# Colunas quebradas, estátuas e portão ritual fecham os vazios da sala.
	for rubble in [Vector2(120, 250), Vector2(350, 350), Vector2(635, 510), Vector2(820, 315), Vector2(155, 690), Vector2(730, 700)]:
		draw_shadow_oval(rubble + Vector2(3, 5), Vector2(20, 6), Color(0, 0, 0, .2))
		for r in 4:
			var rp: Vector2 = rubble + Vector2((r - 2) * 9, (r % 2) * 6)
			draw_circle(rp, 6 + float(r % 2) * 2.0, Color(.38, .35, .48))
			draw_circle(rp + Vector2(-2, -2), 3, Color(.55, .52, .65))
	for statue in [Vector2(120, 115), Vector2(850, 115)]:
		draw_rect(Rect2(statue + Vector2(-15, 10), Vector2(30, 45)), Color(.34, .32, .42))
		draw_circle(statue, 16, Color(.48, .45, .58))
		draw_circle(statue + Vector2(-5, -4), 3, Color(.72, .55, 1, .65))
		draw_circle(statue + Vector2(5, -4), 3, Color(.72, .55, 1, .65))
	var gate_top: Vector2 = Vector2(485, 72)
	draw_rect(Rect2(gate_top + Vector2(-76, -22), Vector2(152, 34)), Color(.21, .18, .29))
	for bar_x in range(-60, 61, 20):
		draw_line(gate_top + Vector2(bar_x, -20), gate_top + Vector2(bar_x, 12), Color(.49, .44, .59), 4)
	for crystal in [Vector2(340, 205), Vector2(630, 205), Vector2(350, 645), Vector2(620, 645)]:
		draw_colored_polygon(PackedVector2Array([crystal + Vector2(0, -16), crystal + Vector2(9, 7), crystal + Vector2(0, 13), crystal + Vector2(-9, 7)]), Color(.58, .35, .9, .8))
		draw_circle(crystal, 15, Color(.56, .28, .88, .08))
	draw_label("CÂMARA DO GUARDIÃO", Vector2(395, 92), Color(.86, .7, 1))
	draw_label("↓ SAÍDA", Vector2(409, 805))

func draw_interior() -> void:
	for x in 30:
		for y in [0, 1, 2, 25, 26, 27]:
			draw_texture_rect(textures["wall"], Rect2(x * 32, y * 32, 32, 32), false)
	for y in 28:
		for x in [0, 1, 28, 29]:
			draw_texture_rect(textures["wall"], Rect2(x * 32, y * 32, 32, 32), false)
	for x in 30:
		for y in 25:
			if (x + y) % 5 == 0:
				draw_line(Vector2(x * 32 + 5, y * 32 + 29), Vector2(x * 32 + 23, y * 32 + 29), Color(.26, .16, .12, .4), 1)
	# Iluminação quente, tapete central e rodapés conectam os interiores à linguagem do HUD de madeira.
	for light in [Vector2(220, 145), Vector2(480, 145), Vector2(740, 145)]:
		draw_circle(light, 34, Color(1, .72, .28, .04))
		draw_circle(light, 17, Color(1, .76, .3, .07))
		draw_line(light, light + Vector2(0, 24), Color(.27, .18, .13), 3)
		draw_circle(light, 5, Color(1, .8, .34, .85))
	draw_rect(Rect2(250, 650, 460, 54), Color(.25, .12, .18, .65))
	draw_rect(Rect2(262, 659, 436, 36), Color(.49, .22, .29, .72))
	for rug_x in range(280, 690, 38):
		draw_line(Vector2(rug_x, 662), Vector2(rug_x + 18, 692), Color(.73, .45, .32, .42), 2)
	for shelf_x in [88.0, 815.0]:
		draw_rect(Rect2(shelf_x, 320, 58, 230), Color(.24, .14, .10))
		for shelf_y in [342.0, 402.0, 462.0, 522.0]:
			draw_rect(Rect2(shelf_x + 5, shelf_y, 48, 6), Color(.52, .31, .17))
	if zone == "ferreiro":
		for p in [Vector2(150, 165), Vector2(480, 165), Vector2(770, 165)]:
			draw_rect(Rect2(p, Vector2(155, 58)), Color(.19, .13, .1))
			for n in 3:
				draw_line(p + Vector2(23 + n * 44, 9), p + Vector2(27 + n * 44, 43), Color(.7, .77, .77), 5)
		draw_rect(Rect2(312, 362, 340, 120), Color(.26, .16, .11))
		for n in 5:
			draw_line(Vector2(335, 383 + n * 20), Vector2(625, 383 + n * 20), Color(.52, .35, .22), 3)
		for n in 4:
			draw_line(Vector2(355, 400 + n * 17), Vector2(566, 394 + n * 17), Color(.74, .78, .75), 4)
		draw_circle(Vector2(805, 425), 72, Color(.98, .33, .08, .08))
		draw_circle(Vector2(805, 425), 65, Color(.18, .19, .20))
		draw_circle(Vector2(805, 425), 33, Color(.97, .4, .10))
		draw_circle(Vector2(805, 425), 16, Color(1, .8, .26))
	elif zone == "guilda":
		# Mesa de mapas, quadro de contratos, troféus e estandartes.
		draw_rect(Rect2(322, 294, 316, 166), Color(.31, .19, .12))
		draw_rect(Rect2(340, 310, 280, 130), Color(.73, .58, .35))
		draw_line(Vector2(362, 335), Vector2(590, 400), Color(.35, .55, .6), 4)
		draw_line(Vector2(410, 420), Vector2(565, 330), Color(.57, .38, .23), 3)
		draw_rect(Rect2(102, 135, 185, 160), Color(.25, .16, .12))
		for row in 4:
			draw_rect(Rect2(120, 153 + row * 32, 148, 22), Color(.82, .73, .53))
			draw_line(Vector2(132, 165 + row * 32), Vector2(245, 165 + row * 32), Color(.4, .28, .2), 2)
		for bx in [690.0, 790.0]:
			draw_colored_polygon(PackedVector2Array([Vector2(bx, 130), Vector2(bx + 55, 130), Vector2(bx + 48, 245), Vector2(bx + 27, 224), Vector2(bx + 7, 245)]), Color(.42, .23, .58))
		draw_interior_person(Vector2(176, 350), Color(.78, .68, .9), 4)
		draw_interior_person(Vector2(760, 350), Color(.65, .82, .7), 4)
		for trophy_x in [360.0, 450.0, 540.0]:
			draw_circle(Vector2(trophy_x, 150), 13, Color(.62, .55, .39))
			draw_line(Vector2(trophy_x, 163), Vector2(trophy_x, 185), Color(.38, .27, .19), 3)
	elif zone == "loja":
		for shelf_y in [170.0, 300.0]:
			draw_rect(Rect2(120, shelf_y, 710, 24), Color(.35, .21, .13))
			for item_index in 9:
				var ix: float = 145.0 + item_index * 76.0
				draw_rect(Rect2(ix, shelf_y - 35, 34, 34), Color(.58, .42, .27))
				draw_circle(Vector2(ix + 17, shelf_y - 18), 8, Color(.8, .64, .38))
		for crate in [Vector2(145, 525), Vector2(215, 545), Vector2(710, 535)]:
			draw_rect(Rect2(crate, Vector2(58, 48)), Color(.49, .31, .18))
			draw_line(crate + Vector2(5, 5), crate + Vector2(53, 43), Color(.68, .46, .25), 2)
		draw_rect(Rect2(330, 465, 300, 68), Color(.34, .21, .13))
		draw_interior_person(Vector2(480, 448), Color(.9, .72, .52), 0)
	elif zone == "alquimia":
		for table_x in [145.0, 560.0]:
			draw_rect(Rect2(table_x, 350, 255, 58), Color(.33, .2, .14))
			for bottle_index in 5:
				var bp: Vector2 = Vector2(table_x + 34 + bottle_index * 43, 338 - (bottle_index % 2) * 7)
				draw_circle(bp, 11, Color(.82 if bottle_index % 2 else .46, .35, .8, .82))
				draw_rect(Rect2(bp + Vector2(-3, -18), Vector2(6, 8)), Color(.75, .82, .8))
		for herb_index in 7:
			var hp2: Vector2 = Vector2(150 + herb_index * 103, 190 + (herb_index % 2) * 35)
			draw_line(hp2, hp2 + Vector2(0, 30), Color(.31, .53, .27), 3)
			draw_circle(hp2 + Vector2(-6, 8), 6, Color(.38, .68, .33))
			draw_circle(hp2 + Vector2(7, 16), 6, Color(.48, .76, .39))
		# Caldeirão, tapete e alquimista.
		draw_circle(Vector2(480, 500), 46, Color(.23, .12, .29, .35))
		draw_circle(Vector2(480, 500), 25, Color(.18, .2, .22))
		draw_circle(Vector2(480, 494), 19, Color(.43, .78, .62, .78))
		for bubble_index in 5:
			var bubble: Vector2 = Vector2(462 + bubble_index * 9, 487 - (bubble_index % 2) * 7)
			draw_circle(bubble, 3 + float(bubble_index % 2), Color(.72, 1, .76, .76))
		draw_interior_person(Vector2(480, 440), Color(.64, .52, .86), 0)
		draw_rect(Rect2(330, 560, 300, 84), Color(.36, .18, .42, .35))
	draw_label(zone.to_upper(), Vector2(400, 113))
	draw_label("E conversar  •  ↓ sair", Vector2(386, 637), Color.WHITE)

func draw_interior_person(p: Vector2, tint: Color, facing_index: int = 0) -> void:
	draw_shadow_oval(p + Vector2(0, 4), Vector2(11, 4), Color(0, 0, 0, .28))
	var frame: int = int(time_acc * 4.0 + p.x * .01) % 8
	var src: Rect2 = Rect2(Vector2(frame * 48, facing_index * 56), Vector2(48, 56))
	draw_texture_rect_region(textures["hero_body"], Rect2(p - Vector2(18, 38), Vector2(36, 42)), src, tint)

func draw_enemy(enemy: Dictionary, camera: Vector2) -> void:
	# v0.6: folha completa de 40 quadros = idle, caminhada, ataque, dano e morte.
	var p: Vector2 = enemy["pos"]
	var kind: String = enemy["kind"]
	var size: float = float(ENEMY_FRAME_SIZE.get(kind, 36.0))
	var boss: bool = kind == "Guardião"
	var dead: bool = bool(enemy.get("dead", false))
	var state: String = "death" if dead else str(enemy.get("state", "idle"))
	if not ENEMY_STATE_ROW.has(state):
		state = "idle"
	draw_shadow_oval(p + Vector2(0, 11), Vector2(24, 7) if boss else Vector2(15, 5), Color(0, 0, 0, .35 if not dead else .18))
	if boss and not dead:
		var boss_action: String = str(enemy.get("boss_action", ""))
		if boss_action == "shockwave":
			var pulse: float = 86.0 + sin(time_acc * 9.0) * 10.0
			draw_arc(p, pulse, 0, TAU, 40, Color(.85, .32, .92, .72), 4)
			draw_arc(p, 118.0, 0, TAU, 48, Color(.55, .24, .72, .36), 2)
		elif boss_action == "charge":
			var dir: Vector2 = (player - p).normalized()
			draw_line(p + dir * 24.0, p + dir * 92.0, Color(1, .42, .3, .75), 4)
			draw_circle(p + dir * 100.0, 6, Color(1, .72, .34, .78))
	var state_time: float = float(enemy.get("state_time", 0.0))
	var frame: int = 0
	if state == "death":
		frame = clampi(int(state_time / ENEMY_DEATH_TIME * 8.0), 0, 7)
	else:
		var fps: float = 8.0 if state == "walk" else 11.0 if state == "attack" else 9.0 if state == "hurt" else 5.0
		frame = int(state_time * fps + p.x * .006) % 8
	var flip: float = -1.0 if player.x < p.x else 1.0
	var tint: Color = Color(2.8, 2.8, 2.8) if float(enemy.get("flash", 0.0)) > 0 else Color.WHITE
	draw_set_transform(p - camera, 0, Vector2(flip, 1))
	var anchor: Vector2 = Vector2(-32, -52) if boss else Vector2(-size * .5, -size * .68)
	var sheet_name: String = str(ENEMY_SHEETS.get(kind, "slime")) + "_full"
	var row: int = int(ENEMY_STATE_ROW[state])
	draw_texture_rect_region(textures[sheet_name], Rect2(anchor, Vector2(size, size)), Rect2(frame * size, row * size, size, size), tint)
	draw_set_transform(-camera)
	var max_life: int = maxi(1, int(enemy.get("max_hp", monster_health(kind))))
	if not dead and (int(enemy.get("hp", max_life)) < max_life or boss):
		var w: float = 48.0 if boss else 32.0
		var top: Vector2 = p + Vector2(-w * .5, -58.0 if boss else -32.0)
		draw_rect(Rect2(top - Vector2(1, 1), Vector2(w + 2, 6)), Color(.1, .05, .16))
		draw_rect(Rect2(top, Vector2(w, 4)), Color(.3, .1, .16))
		var life_ratio: float = clampf(float(enemy.get("hp", max_life)) / float(max_life), 0.0, 1.0)
		draw_rect(Rect2(top, Vector2(life_ratio * w, 4)), Color(1, .3, .35))
		draw_rect(Rect2(top, Vector2(life_ratio * w, 1)), Color(1, .7, .7))

func draw_floaters() -> void:
	for f in floaters:
		var t: float = f["t"]
		var p: Vector2 = f["pos"]
		if f.get("puff", false):
			# nuvem de poeira quando o monstro cai
			var k: float = 1.0 - t / .45
			for i in 6:
				var dir: Vector2 = Vector2.RIGHT.rotated(i * TAU / 6.0)
				draw_circle(p + dir * (6.0 + k * 18.0) - Vector2(0, 8), 5.0 * (1.0 - k) + 1.0, Color(1, 1, 1, .8 * (1.0 - k)))
			continue
		var rise: float = (1.0 - t / .7) * 18.0
		var color: Color = f["color"]
		color.a = clampf(t / .25, 0, 1)
		draw_string_outline(ui_font, p - Vector2(30, rise), f["text"], HORIZONTAL_ALIGNMENT_CENTER, 60, 18, 4, Color(.1, .05, .16, color.a))
		draw_string(ui_font, p - Vector2(30, rise), f["text"], HORIZONTAL_ALIGNMENT_CENTER, 60, 18, color)

func draw_bar(rect: Rect2, ratio: float, fill: Color, empty: Color) -> void:
	draw_rect(rect.grow(2), Color(.1, .05, .16))
	draw_rect(rect, empty)
	var filled: Rect2 = Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0.0, 1.0), rect.size.y))
	draw_rect(filled, fill)
	draw_rect(Rect2(filled.position, Vector2(filled.size.x, 2)), fill.lightened(.45))
	draw_rect(Rect2(filled.position + Vector2(0, filled.size.y - 2), Vector2(filled.size.x, 2)), fill.darkened(.3))

func hud_text(p: Vector2, text: String, size: int, color: Color, width: float = 120) -> void:
	draw_string_outline(ui_font, p, text, HORIZONTAL_ALIGNMENT_LEFT, width, size, 4, Color(.1, .05, .16))
	draw_string(ui_font, p, text, HORIZONTAL_ALIGNMENT_LEFT, width, size, color)

func draw_hud() -> void:
	# Retrato + barras de vida/XP + moedas/poções, no estilo de RPG de 16 bits.
	draw_style_box(panel_box, Rect2(4, 4, 300, 74))
	draw_texture_rect(textures["ui_round_button"], Rect2(10, 8, 66, 66), false)
	draw_texture_rect(textures["ui_portrait"], Rect2(17, 15, 52, 52), false)
	if invulnerable > 0:
		draw_circle(Vector2(43, 41), 26, Color(1, .2, .25, invulnerable * .5))
	draw_style_box(panel_box, Rect2(18, 60, 50, 22))
	hud_text(Vector2(24, 77), "Nv %d" % level, 13, Color(1, .86, .45), 44)
	draw_texture_rect(textures["icon_heart"], Rect2(84, 13, 16, 16), false)
	draw_bar(Rect2(104, 16, 130, 10), float(hp) / max_hp, Color(.9, .2, .3), Color(.25, .08, .14))
	hud_text(Vector2(240, 27), "%d/%d" % [hp, max_hp], 13, Color(1, .95, .85), 60)
	draw_texture_rect(textures["icon_xp"], Rect2(84, 33, 16, 16), false)
	var xp_ratio: float = float(xp) / float(level * 35)
	draw_bar(Rect2(104, 37, 130, 7), xp_ratio, Color(.3, .85, 1), Color(.1, .15, .3))
	hud_text(Vector2(240, 46), "%d%%" % roundi(xp_ratio * 100.0), 12, Color(.75, .95, 1), 60)
	draw_texture_rect(textures["icon_coin"], Rect2(84, 52, 16, 16), false)
	hud_text(Vector2(104, 66), str(gold), 15, Color(1, .86, .45), 70)
	draw_texture_rect(textures["icon_potion"], Rect2(168, 52, 16, 16), false)
	hud_text(Vector2(188, 66), "× %d" % potions, 15, Color(1, .75, .9), 60)
	draw_style_box(panel_box, Rect2(4, 76, 450, 34))
	if hint_timer > 0:
		draw_style_box(panel_box, Rect2(280, 118, 400, 48))
	# joystick virtual
	var stick: Vector2 = Vector2(104, 442)
	draw_circle(stick, 58, Color(.1, .05, .16, .55))
	draw_arc(stick, 56, 0, TAU, 40, Color(.95, .76, .3, .9), 3)
	draw_arc(stick, 51, 0, TAU, 40, Color(.66, .44, .17, .7), 2)
	for i in 4:
		var dir: Vector2 = Vector2.RIGHT.rotated(i * PI / 2.0)
		draw_colored_polygon(PackedVector2Array([stick + dir * 46, stick + dir * 38 + dir.orthogonal() * 5, stick + dir * 38 - dir.orthogonal() * 5]), Color(.95, .76, .3, .8))
	var knob: Vector2 = stick + joystick_vector * 34.0
	draw_circle(knob, 24, Color(.66, .44, .17))
	draw_circle(knob, 22, Color(.95, .76, .3))
	draw_circle(knob, 17, Color(.27, .21, .43))
	draw_circle(knob - Vector2(4, 4), 6, Color(.45, .38, .68))
