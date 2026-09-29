extends Node2D

const TILE: float = 32.0
const SIZE: Vector2 = Vector2(960, 896)
const VIEW_SIZE: Vector2 = Vector2(960, 540)
const FOREST_SIZE: Vector2 = Vector2(1825, 862)
const FORGE_SIZE: Vector2 = Vector2(1512, 1040)
const MAP = preload("res://scripts/world_map.gd")
const LOOT = preload("res://scripts/loot_system.gd")
const REG = preload("res://scripts/reg001_world.gd")
const PROC = preload("res://scripts/reg001_procedural.gd")
const REGR = preload("res://scripts/reg001_render.gd")
const REGG = preload("res://scripts/reg001_gameplay.gd")
const MODELED = preload("res://scripts/modeled_assets.gd")
const SAVE_PATH: String = "user://valedouro_v1.json"
const RANGES: Dictionary = {"cidade": 0, "floresta": 1, "masmorra": 2, "ferreiro": 3, "loja": 4, "alquimia": 5, "guilda": 6, "cripta": 7}
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
var approved_visuals: Dictionary = {}
var animals: Array = []
var map_visible: bool = false
var ui_font: Font
var panel_box: StyleBoxTexture
var floaters: Array = []   # números de dano e efeitos rápidos
var reg_game: RefCounted
var view_items: Dictionary = {}
var view_rect: Rect2 = Rect2()
const ENEMY_SHEETS: Dictionary = {"Lobo": "wolf", "Limo": "slime", "Aranha Sombria": "spider", "Javali Musgoso": "boar", "Flor Voraz": "flower_beast", "Escorpião": "scorpion", "Escaravelho Âmbar": "amber_beetle", "Lobo de Gelo": "ice_wolf", "Golem de Geada": "ice_golem", "Guardião": "boss"}
const ENEMY_FRAME_SIZE: Dictionary = {"Golem de Geada": 40.0, "Guardião": 64.0}
const ENEMY_STATE_ROW: Dictionary = {"idle": 0, "walk": 1, "attack": 2, "hurt": 3, "death": 4}
const ENEMY_DEATH_TIME: float = .72
const APPROVED_VISUAL_PATHS: Dictionary = {
	"city_floor_clean": "res://assets/approved/city/floors/floor_stone_clean.png",
	"city_floor_worn": "res://assets/approved/city/floors/floor_stone_worn.png",
	"city_floor_moss": "res://assets/approved/city/floors/floor_stone_moss.png",
	"city_water_edge": "res://assets/approved/city/water/water_edge.png",
	"city_wall": "res://assets/approved/city/walls/wall_straight.png",
	"city_wall_vegetation": "res://assets/approved/city/walls/wall_vegetation.png",
	"city_gate": "res://assets/approved/city/walls/gate_large.png",
	"city_house_door": "res://assets/approved/city/buildings/house_door.png",
	"city_house_window": "res://assets/approved/city/buildings/house_window.png",
	"city_roof_blue": "res://assets/approved/city/buildings/roof_blue.png",
	"city_roof_red": "res://assets/approved/city/buildings/roof_red.png",
	"city_roof_wood": "res://assets/approved/city/buildings/roof_wood.png",
	"city_store": "res://assets/approved/city/special/store.png",
	"city_tree_green": "res://assets/approved/city/props/tree_green.png",
	"city_tree_autumn": "res://assets/approved/city/props/tree_autumn.png",
	"dungeon_floor_stone": "res://assets/approved/dungeon/floors/floor_stone.png",
	"dungeon_floor_broken": "res://assets/approved/dungeon/floors/floor_broken.png",
	"dungeon_wall": "res://assets/approved/dungeon/walls/wall_straight.png",
	"dungeon_corner": "res://assets/approved/dungeon/walls/corner_inside.png",
	"dungeon_arch": "res://assets/approved/dungeon/walls/arch.png",
	"dungeon_door": "res://assets/approved/dungeon/walls/door.png",
	"dungeon_rail": "res://assets/approved/dungeon/mine/rail_straight.png",
	"dungeon_crystal_blue": "res://assets/approved/dungeon/natural/crystal_blue.png",
	"dungeon_crystal_purple": "res://assets/approved/dungeon/natural/crystal_purple.png",
	"dungeon_torch": "res://assets/approved/dungeon/lighting/torch.png",
	"dungeon_emissive_crystal": "res://assets/approved/dungeon/lighting/emissive_crystal.png",
	"dungeon_spikes": "res://assets/approved/dungeon/traps/spikes.png",
	"dungeon_corridor": "res://assets/approved/dungeon/tunnels/corridor_straight.png"
}

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
	load_approved_visuals()
	REG.ensure_loaded()
	reg_game = REGG.new(self)
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

func load_approved_visuals() -> void:
	approved_visuals.clear()
	for key_value in APPROVED_VISUAL_PATHS.keys():
		var key: String = str(key_value)
		var path: String = str(APPROVED_VISUAL_PATHS[key])
		assert(ResourceLoader.exists(path), "Asset visual APPROVED ausente: %s" % path)
		var texture: Resource = load(path)
		assert(texture is Texture2D, "Asset APPROVED não é Texture2D: %s" % path)
		approved_visuals[key] = texture
	assert(approved_visuals.size() == 28)

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
		reg_game.tick(delta)
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
	elif zone == "cripta":
		for wall_rect in REG.crypt_walls:
			if (wall_rect as Rect2).has_point(p):
				return false
	if zone != "cidade" and REG.blocked_at(p, zone):
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
	gold += int(float(monster_gold(kind)) * float(enemy.get("gold_mult", 1.0)))
	gain_xp(int(float(monster_xp(kind)) * float(enemy.get("xp_mult", 1.0))))
	reg_game.on_enemy_defeated(enemy)
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
			var taken: int = maxi(1, int(float(monster_damage(str(enemy["kind"]))) * float(enemy.get("dmg_mult", 1.0))) - armor - int(equipped_armor.get("def", 0)))
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
	if reg_game.try_interact():
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
	elif zone == "cripta":
		if player.y > 790:
			var gate_poi: Dictionary = REG.poi_by_id.get("REG001_POI_CRIPTA_ENTRADA", {}) as Dictionary
			var back: Vector2 = (gate_poi["pos"] as Vector2) + Vector2(0, 62) if not gate_poi.is_empty() else MAP.TOWN + Vector2(955, 748)
			change_zone("cidade", back)
		else:
			message("A saída da cripta fica ao sul.")
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
	var state: Dictionary = {"version": 4, "zone": zone, "px": player.x, "py": player.y, "hp": hp, "max_hp": max_hp, "level": level, "xp": xp, "gold": gold, "potions": potions, "weapon": weapon, "armor": armor, "kills": kills, "quest": quest, "materials": materials, "items": stored_items, "equipped_weapon": equipped_weapon, "equipped_armor": equipped_armor, "reg001": REG.export_state()}
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
		REG.import_state(data.get("reg001", {}))
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
		pass
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
	view_rect = Rect2(camera, VIEW_SIZE)
	if zone == "cidade":
		view_items = PROC.view(view_rect)
		REGR.draw_ground(self, view_items, view_rect, time_acc, approved_visuals)
		draw_overworld(camera, x_start, x_end, y_start, y_end)
		if Rect2(camera, VIEW_SIZE).intersects(MAP.TOWN_BOUNDS.grow(180.0)):
			draw_approved_town_border(camera)
		if Rect2(camera, VIEW_SIZE).intersects(MAP.TOWN_BOUNDS):
			draw_approved_town(camera)
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
		REGR.draw_emitters(self, view_rect, zone, time_acc)
	else:
		view_items = PROC.zone_view(zone)
		if zone == "masmorra":
			draw_dungeon()
		elif zone == "cripta":
			draw_crypt()
		elif zone in ["ferreiro", "loja", "alquimia", "guilda"]:
			draw_interior()
		REGR.draw_ground(self, view_items, view_rect, time_acc, approved_visuals)
		REGR.draw_emitters(self, view_rect, zone, time_acc)
	reg_game.draw_npcs(self, view_rect)
	REGR.draw_objects(self, view_items, view_rect, -1.0e9, player.y, time_acc, approved_visuals)
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
	REGR.draw_objects(self, view_items, view_rect, player.y, 1.0e9, time_acc, approved_visuals)
	reg_game.draw_overlay(self, view_rect)
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
	# Água, pontes, cascata, marcos legados e rótulos. Vegetação, props e transições vêm da camada REG_001 (chunks).
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

	# Três travessias reutilizam a mesma linguagem de madeira/pedra, mas com silhuetas próprias.
	for index in range(MAP.BRIDGE_YS.size()):
		var by: float = float(MAP.BRIDGE_YS[index])
		var bridge_center: Vector2 = Vector2(MAP.river_x(float(by)), float(by))
		if camera.distance_to(bridge_center) < 700:
			draw_bridge_details(bridge_center, index)

	# Cascata: queda animada (efeito); as rochas laterais são objetos modelados da REG_001.
	var falls: Vector2 = Vector2(MAP.river_x(471.0), 471.0)
	if camera.distance_to(falls) < 820:
		for i in 10:
			var fx: float = falls.x - 50.0 + i * 11.0
			var drift: float = fposmod(time_acc * 41.0 + i * 9.0, 35.0)
			draw_line(Vector2(fx, falls.y - 8 + drift), Vector2(fx - 3, falls.y + 29 + drift), Color(.78, .94, .99, .9), 3)

	# Marcos legados (torres, moinho, posto, abrigo, santuário) — catálogo REG_001: LEGACY_BASELINE.
	for entry in MAP.STRUCTURES:
		var center: Vector2 = entry["pos"] as Vector2
		if camera.distance_to(center) < 720:
			draw_world_structure(entry)
	for landmark in [[Vector2(230, 1240), "BOSQUE DO PRIMEIRO VENTO"], [Vector2(2520, 1700), "DUNAS DE ÂMBAR"], [Vector2(2460, 230), "PICOS DE GELO"], [Vector2(1250, 2020), "VALE DOS LÍRIOS"], [Vector2(2160, 510), "CASCATA DA AURORA"]]:
		if camera.distance_to(landmark[0]) < 480:
			draw_label(landmark[1], landmark[0], Color(.97, .92, .75))

func draw_approved_visual(key: String, ground: Vector2, scale_factor: float = .58, tint: Color = Color.WHITE) -> void:
	if not approved_visuals.has(key):
		return
	var texture: Texture2D = approved_visuals[key] as Texture2D
	var scaled: Vector2 = texture.get_size() * scale_factor
	var rect: Rect2 = Rect2(ground - Vector2(scaled.x * .5, scaled.y), scaled)
	draw_texture_rect(texture, rect, false, tint)

func draw_approved_tree(ground: Vector2, autumn: bool = false, scale_factor: float = .50) -> void:
	draw_shadow_oval(ground + Vector2(4, 4), Vector2(33, 10), Color(0, 0, 0, .24))
	draw_approved_visual("city_tree_autumn" if autumn else "city_tree_green", ground, scale_factor)

func draw_approved_house(ground: Vector2, roof_key: String) -> void:
	# Composição feita exclusivamente com módulos APPROVED.
	draw_shadow_oval(ground + Vector2(0, 5), Vector2(72, 14), Color(0, 0, 0, .22))
	draw_approved_visual("city_house_door", ground + Vector2(-42, 0), .52)
	draw_approved_visual("city_house_window", ground + Vector2(43, 0), .52)
	draw_approved_visual(roof_key, ground + Vector2(0, -78), .52)

func draw_approved_town(camera: Vector2) -> void:
	var visible_area: Rect2 = Rect2(camera - Vector2(170, 170), VIEW_SIZE + Vector2(340, 340))
	# Pavimentação inteira usa somente os três pisos APPROVED.
	for row in 25:
		for column in 26:
			var ground: Vector2 = MAP.TOWN + Vector2(35.0 + column * 70.0 + float(row % 2) * 35.0, 86.0 + row * 35.0)
			if not MAP.TOWN_BOUNDS.has_point(ground) or not visible_area.has_point(ground):
				continue
			var tile_seed: int = MAP.cell_hash(column + 400, row + 600)
			var floor_key: String = "city_floor_clean"
			if tile_seed % 7 == 0:
				floor_key = "city_floor_moss"
			elif tile_seed % 3 == 0:
				floor_key = "city_floor_worn"
			draw_approved_visual(floor_key, ground, .58)

	# Muralha norte e portão principal.
	for wall_index in 13:
		var wall_ground: Vector2 = MAP.TOWN + Vector2(150.0 + wall_index * 120.0, 180.0)
		if absf(wall_ground.x - (MAP.TOWN.x + 883.0)) < 175.0:
			continue
		if visible_area.has_point(wall_ground):
			draw_approved_visual("city_wall_vegetation" if wall_index % 4 == 0 else "city_wall", wall_ground, .58)
	var gate_ground: Vector2 = MAP.TOWN + Vector2(883, 184)
	if visible_area.has_point(gate_ground):
		draw_approved_visual("city_gate", gate_ground, .58)

	# Quatro conjuntos arquitetônicos, sempre formados por peças APPROVED.
	var houses: Array = [
		[Vector2(485, 330), "city_roof_blue"],
		[Vector2(1245, 340), "city_roof_red"],
		[Vector2(470, 615), "city_roof_wood"],
		[Vector2(1280, 625), "city_roof_blue"]
	]
	for house_value in houses:
		var house_data: Array = house_value as Array
		var house_ground: Vector2 = MAP.TOWN + (house_data[0] as Vector2)
		if visible_area.has_point(house_ground):
			draw_approved_house(house_ground, str(house_data[1]))

	var store_ground: Vector2 = MAP.TOWN + Vector2(1570, 630)
	if visible_area.has_point(store_ground):
		draw_shadow_oval(store_ground + Vector2(4, 5), Vector2(63, 13), Color(0, 0, 0, .22))
		draw_approved_visual("city_store", store_ground, .58)

	# Árvores APPROVED integram a arquitetura e dão profundidade consistente.
	var tree_positions: Array[Vector2] = [
		Vector2(175, 300), Vector2(760, 330), Vector2(1010, 300), Vector2(1600, 315),
		Vector2(180, 735), Vector2(700, 735), Vector2(1035, 745), Vector2(1570, 760)
	]
	for tree_index in range(tree_positions.size()):
		var tree_ground: Vector2 = MAP.TOWN + tree_positions[tree_index]
		if visible_area.has_point(tree_ground):
			draw_approved_tree(tree_ground, tree_index % 5 == 0, .50)

func draw_approved_town_border(camera: Vector2) -> void:
	var visible_area: Rect2 = Rect2(camera - Vector2(180, 180), VIEW_SIZE + Vector2(360, 360))
	var bounds: Rect2 = MAP.TOWN_BOUNDS
	var border_points: Array[Vector2] = []
	for index in 14:
		var ratio: float = float(index) / 13.0
		border_points.append(Vector2(bounds.position.x + ratio * bounds.size.x, bounds.position.y - 30.0))
		border_points.append(Vector2(bounds.position.x + ratio * bounds.size.x, bounds.end.y + 28.0))
	for index in 7:
		var ratio_side: float = float(index) / 6.0
		border_points.append(Vector2(bounds.position.x - 28.0, bounds.position.y + ratio_side * bounds.size.y))
		border_points.append(Vector2(bounds.end.x + 28.0, bounds.position.y + ratio_side * bounds.size.y))
	for point_index in range(border_points.size()):
		var point: Vector2 = border_points[point_index]
		if not visible_area.has_point(point):
			continue
		var local: Vector2 = point - MAP.TOWN
		if absf(local.x - 890.0) < 150.0 or absf(local.y - 478.0) < 125.0:
			continue
		draw_approved_tree(point, point_index % 7 == 0, .42)

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
	for poi_value in REG.pois_in_zone("cidade"):
		var map_poi: Dictionary = poi_value
		if not bool(map_poi.get("show_label", true)) or not REG.has_mark("visited", str(map_poi["id"])):
			continue
		var poi_color: Color = Color(1, .8, .95) if str(map_poi["kind"]) == "elite" else Color(1, .93, .55) if str(map_poi["kind"]) in ["settlement", "camp", "shrine"] else Color(.7, .95, 1)
		draw_circle(origin + (map_poi["pos"] as Vector2) * scale, 2.6, Color(.1, .05, .16))
		draw_circle(origin + (map_poi["pos"] as Vector2) * scale, 1.7, poi_color)
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
	# Dungeon final: somente os 13 módulos que passaram QA como APPROVED.
	for row in 28:
		for column in 16:
			var ground: Vector2 = Vector2(35.0 + column * 70.0 + float(row % 2) * 35.0, 74.0 + row * 35.0)
			var seed: int = MAP.cell_hash(column + 900, row + 1200)
			draw_approved_visual("dungeon_floor_broken" if seed % 7 == 0 else "dungeon_floor_stone", ground, .58)

	for wall_index in 7:
		var wall_ground: Vector2 = Vector2(120.0 + wall_index * 120.0, 188.0)
		if wall_index == 3:
			continue
		draw_approved_visual("dungeon_wall", wall_ground, .58)
	draw_approved_visual("dungeon_arch", Vector2(480, 194), .62)
	draw_approved_visual("dungeon_door", Vector2(480, 196), .54)
	draw_approved_visual("dungeon_corner", Vector2(110, 340), .52)
	draw_approved_visual("dungeon_corner", Vector2(850, 340), .52)

	# Corredor, trilho e armadilhas aprovados formam rotas legíveis.
	draw_approved_visual("dungeon_corridor", Vector2(480, 720), .58)
	draw_approved_visual("dungeon_rail", Vector2(480, 770), .58)
	draw_approved_visual("dungeon_spikes", Vector2(335, 515), .48)
	draw_approved_visual("dungeon_spikes", Vector2(625, 515), .48)

	# Cristais e tochas são os únicos elementos luminosos da sala.
	for crystal_value in [
		[Vector2(190, 430), "dungeon_crystal_blue"],
		[Vector2(785, 430), "dungeon_crystal_purple"],
		[Vector2(255, 665), "dungeon_emissive_crystal"],
		[Vector2(705, 665), "dungeon_crystal_blue"]
	]:
		var crystal_data: Array = crystal_value as Array
		draw_approved_visual(str(crystal_data[1]), crystal_data[0] as Vector2, .48)
	for torch_pos in [Vector2(285, 275), Vector2(675, 275), Vector2(205, 620), Vector2(755, 620)]:
		draw_approved_visual("dungeon_torch", torch_pos, .44)
	draw_label("CÂMARA DO GUARDIÃO", Vector2(395, 92), Color(.86, .7, 1))
	draw_label("↓ SAÍDA", Vector2(409, 805))

func draw_crypt() -> void:
	# Cripta Esquecida: pisos/paredes/arcos APPROVED + módulos modelados de dungeon (objetos da zona).
	for row in 28:
		for column in 16:
			var ground: Vector2 = Vector2(35.0 + column * 70.0 + float(row % 2) * 35.0, 74.0 + row * 35.0)
			var seed: int = MAP.cell_hash(column + 2100, row + 2300)
			draw_approved_visual("dungeon_floor_broken" if seed % 6 == 0 else "dungeon_floor_stone", ground, .58)
	for wall_value in REG.crypt_walls:
		var wall_rect: Rect2 = wall_value
		var wx: float = wall_rect.position.x + 45.0
		while wx < wall_rect.end.x - 10.0:
			draw_approved_visual("dungeon_wall", Vector2(wx, wall_rect.end.y + 6.0), .58)
			wx += 100.0
	draw_approved_visual("dungeon_corner", Vector2(60, 330), .52)
	draw_approved_visual("dungeon_corner", Vector2(900, 330), .52)
	draw_label("CRIPTA ESQUECIDA", Vector2(390, 88), Color(.86, .7, 1))
	draw_label("↓ SAÍDA", Vector2(409, 872))

func draw_interior() -> void:
	var room_size: Vector2 = FORGE_SIZE if zone == "ferreiro" else SIZE
	var floor_main: Texture2D = MODELED.texture("int_floor_wood_dark" if zone == "ferreiro" else "int_floor_wood")
	var floor_alt: Texture2D = floor_main
	for row in 31:
		for column in 23:
			var ground: Vector2 = Vector2(35.0 + column * 70.0 + float(row % 2) * 35.0, 72.0 + row * 35.0)
			if ground.x > room_size.x + 90.0 or ground.y > room_size.y + 90.0:
				continue
			var seed: int = MAP.cell_hash(column + 1300, row + 1500)
			if floor_main != null:
				var floor_tex: Texture2D = floor_alt if seed % 6 == 0 else floor_main
				draw_texture_rect(floor_tex, Rect2(ground - Vector2(124.0 * .58, 140.0 * .58), Vector2(248.0, 140.0) * .58), false)
			else:
				draw_approved_visual("city_floor_moss" if seed % 13 == 0 else "city_floor_worn" if seed % 4 == 0 else "city_floor_clean", ground, .58)
	for wall_index in 9:
		draw_approved_visual("city_wall_vegetation" if wall_index % 4 == 0 else "city_wall", Vector2(120.0 + wall_index * 110.0, 190), .52)
	if zone == "loja":
		draw_interior_person(Vector2(520, 500), Color(.9, .78, .6), 4)
	elif zone == "guilda":
		draw_approved_visual("city_gate", Vector2(480, 350), .58)
		draw_interior_person(Vector2(335, 500), Color(.78, .68, .9), 4)
		draw_interior_person(Vector2(625, 500), Color(.65, .82, .7), 4)
	elif zone == "ferreiro":
		draw_interior_person(Vector2(700, 500), Color(.82, .68, .55), 0)
	elif zone == "alquimia":
		draw_interior_person(Vector2(480, 500), Color(.64, .52, .86), 0)
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
	var elite: bool = enemy.has("elite")
	var size: float = float(ENEMY_FRAME_SIZE.get(kind, 36.0)) * (1.32 if elite else 1.0)
	var boss: bool = kind == "Guardião"
	var dead: bool = bool(enemy.get("dead", false))
	var state: String = "death" if dead else str(enemy.get("state", "idle"))
	if not ENEMY_STATE_ROW.has(state):
		state = "idle"
	draw_shadow_oval(p + Vector2(0, 11), Vector2(24, 7) if boss else Vector2(15, 5), Color(0, 0, 0, .35 if not dead else .18))
	if elite and not dead:
		draw_circle(p + Vector2(0, 4), 25, Color(1, .75, .3, .16))
		draw_arc(p + Vector2(0, 4), 25 + sin(time_acc * 4.0) * 2.0, 0, TAU, 28, Color(1, .8, .35, .6), 2)
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
	if not dead and (int(enemy.get("hp", max_life)) < max_life or boss or elite):
		var w: float = 48.0 if (boss or elite) else 32.0
		var top: Vector2 = p + Vector2(-w * .5, -58.0 if boss else -46.0 if elite else -32.0)
		if elite:
			draw_label("★ " + str(enemy.get("elite_name", "Elite")), top + Vector2(w * .5 - 90.0, -6.0), Color(1, .82, .5))
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
