class_name ValedouroCartoonDesertRegion
extends Node2D

const Desert = preload("res://scripts/cartoon/desert/desert_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/desert/desert_story_map.gd")
const StreamScript = preload("res://scripts/cartoon/desert/desert_world_stream.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/desert/desert_story_runtime.gd")
const ZoneScript = preload("res://scripts/cartoon/desert/desert_story_zone.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")

var story_zones: Node2D
var objects: Node2D
var hero: Node2D
var camera: Camera2D
var world_stream: Node2D
var story_runtime: RefCounted

var monsters: Array[Node2D] = []
var pois: Array[Dictionary] = []

var ui: CanvasLayer
var objective_label: Label
var stats_label: Label
var poi_label: Label
var nav_label: Label
var toast_label: Label

var joystick_id: int = -1
var joystick_origin: Vector2 = Vector2.ZERO
var joystick_vector: Vector2 = Vector2.ZERO
var speed: float = 235.0
var toast_timer: float = 0.0
var player_hp: int = 175
var player_max_hp: int = 175
var player_gold: int = 140

func _ready() -> void:
	story_zones = Node2D.new()
	story_zones.name = "StoryZones"
	story_zones.z_index = -12
	add_child(story_zones)
	for data in StoryMap.zones():
		var zone: Node2D = ZoneScript.new()
		zone.setup(data)
		story_zones.add_child(zone)

	objects = Node2D.new()
	objects.name = "WorldObjects"
	objects.y_sort_enabled = true
	add_child(objects)

	for data in StoryMap.locations():
		_add_poi_prop(data)
	for data in StoryMap.optional_pois():
		_add_poi_prop(data)

	story_runtime = StoryRuntimeScript.new()

	hero = HeroScript.new()
	hero.name = "Player"
	hero.position = Desert.ENTRY_POS
	objects.add_child(hero)

	world_stream = StreamScript.new()
	world_stream.name = "DesertWorldStream"
	add_child(world_stream)
	world_stream.setup(hero)

	for data in StoryMap.encounters():
		_spawn_monster(data)

	camera = Camera2D.new()
	camera.name = "PlayerCamera"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(Desert.REGION_SIZE.x)
	camera.limit_bottom = int(Desert.REGION_SIZE.y)
	hero.add_child(camera)

	_build_ui()
	_refresh_objective()

func _add_poi_prop(data: Dictionary) -> void:
	var prop: Node2D = PropScript.new()
	prop.setup(data)
	objects.add_child(prop)
	pois.append({
		"id":String(data.get("id","")),
		"label":String(data.get("label","")),
		"pos":data.get("pos",Vector2.ZERO),
		"quest":String(data.get("quest",""))
	})

func _spawn_monster(data: Dictionary) -> void:
	var monster: Node2D = MonsterScript.new()
	monster.setup(data)
	objects.add_child(monster)
	monsters.append(monster)

func _process(delta: float) -> void:
	toast_timer = maxf(0.0,toast_timer-delta)
	if toast_timer <= 0.0 and toast_label:
		toast_label.text = ""

	var dir: Vector2 = Input.get_vector("move_left","move_right","move_up","move_down")
	if joystick_vector.length() > 0.12:
		dir = joystick_vector
	if dir.length() > 1.0:
		dir = dir.normalized()

	if hero:
		var next: Vector2 = hero.position+dir*speed*delta
		if Desert.in_region(next,70.0):
			hero.position = next
		hero.set_motion(dir)
		_update_poi_hint()
		_update_navigation()

	_update_monsters(delta)
	if Input.is_action_just_pressed("attack"):
		_attack()
	if Input.is_action_just_pressed("interact"):
		_interact()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < 330 and event.position.y > 300 and joystick_id < 0:
			joystick_id = event.index
			joystick_origin = event.position
			joystick_vector = Vector2.ZERO
		elif not event.pressed and event.index == joystick_id:
			joystick_id = -1
			joystick_vector = Vector2.ZERO
	elif event is InputEventScreenDrag and event.index == joystick_id:
		joystick_vector = (event.position-joystick_origin).limit_length(80.0)/80.0

func _attack() -> void:
	if hero == null:
		return
	hero.trigger_attack()
	var target: Node2D = _nearest_monster(114.0)
	if target == null:
		_show_toast("Nenhum inimigo ao alcance.")
		return
	var boss_id: String = String(target.boss_id)
	if boss_id == "BOSS_GENERAL_CINZA_001" and story_runtime.current_id != "Q_MS03_GENERAL_ASH":
		_show_toast("A Cidadela ainda alimenta a proteção do General da Cinza.")
		return
	var dead: bool = target.take_damage(22)
	if not dead:
		return
	monsters.erase(target)
	target.queue_free()
	player_gold += 10
	var advanced: bool = false
	if boss_id != "":
		advanced = story_runtime.register_boss(boss_id)
	_refresh_stats()
	_refresh_objective()
	if advanced:
		_show_toast("O General da Cinza caiu. A rota para os pântanos foi revelada.")
	else:
		_show_toast("Inimigo derrotado. +10 ouro")

func _interact() -> void:
	if hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,200.0)
	if poi.is_empty():
		_show_toast("Nada para interagir aqui.")
		return
	var id: String = String(poi.get("id",""))
	var label: String = String(poi.get("label","Local"))

	if story_runtime.interact(id):
		_refresh_objective()
		if id == "LOC_AMBER_CARAVAN" and story_runtime.current_id == "Q_MS03_CARAVAN":
			_show_toast("Sahir iniciou a marcha. Acompanhe a caravana até o Posto de Âmbar.")
		elif id == "LOC_AMBER_POST" and story_runtime.current_id == "Q_MS03_AMBER_POST":
			_show_toast("A caravana chegou ao Posto de Âmbar. Procure o contato da resistência.")
		else:
			_show_toast("História principal atualizada: "+label)
		return

	match id:
		"LOC_EDRAVAR_OCCUPIED_CITY": _show_toast("Edravar está ocupada. Há rotas subterrâneas entre as ruínas.")
		"LOC_EDRAVAR_RESISTANCE_CISTERN": _show_toast("A resistência preservou registros sob a cidade.")
		"LOC_ASH_OBSERVATORY": _show_toast("O mecanismo do observatório drena o Eco do deserto.")
		"LOC_ASH_CITADEL": _show_toast("O General da Cinza aguarda dentro da cidadela.")
		"POI_DESERT_MARSH_ROUTE":
			if story_runtime.act3_complete:
				_show_toast("Próxima região: Pântanos Sombrios.")
			else:
				_show_toast("A rota para os pântanos ainda está bloqueada pela campanha.")
		_:
			_show_toast(label)

func _update_monsters(delta: float) -> void:
	if hero == null:
		return
	for monster in monsters.duplicate():
		if not is_instance_valid(monster):
			monsters.erase(monster)
			continue
		var dist: float = monster.position.distance_to(hero.position)
		if dist < 330.0 and dist > 54.0:
			var dir: Vector2 = (hero.position-monster.position).normalized()
			var next: Vector2 = monster.position+dir*float(monster.move_speed)*delta
			if Desert.in_region(next,70.0):
				monster.position = next
		if dist <= 56.0 and monster.can_hit():
			monster.mark_hit()
			player_hp = maxi(0,player_hp-int(monster.contact_damage))
			_refresh_stats()
			if player_hp <= 0:
				player_hp = player_max_hp
				hero.position = Desert.ENTRY_POS
				_refresh_stats()
				_show_toast("A Caravana de Âmbar resgatou você.")

func _nearest_monster(radius: float) -> Node2D:
	var best: Node2D = null
	var best_d: float = radius
	for monster in monsters:
		if not is_instance_valid(monster):
			continue
		var d: float = hero.position.distance_to(monster.position)
		if d < best_d:
			best_d = d
			best = monster
	return best

func _nearest_poi(pos: Vector2, radius: float) -> Dictionary:
	var best: Dictionary = {}
	var best_d: float = radius
	for poi in pois:
		var d: float = pos.distance_to(poi.get("pos",Vector2.ZERO))
		if d < best_d:
			best_d = d
			best = poi
	return best

func _build_ui() -> void:
	ui = CanvasLayer.new()
	ui.name = "HUD"
	add_child(ui)

	var top: PanelContainer = PanelContainer.new()
	top.position = Vector2(14,14)
	top.size = Vector2(320,76)
	ui.add_child(top)
	var top_style: StyleBoxFlat = StyleBoxFlat.new()
	top_style.bg_color = Color(0.12,0.08,0.05,0.95)
	top_style.border_color = Color(0.92,0.56,0.18)
	top_style.set_border_width_all(3)
	top_style.corner_radius_top_left = 16
	top_style.corner_radius_top_right = 16
	top_style.corner_radius_bottom_left = 16
	top_style.corner_radius_bottom_right = 16
	top.add_theme_stylebox_override("panel",top_style)

	stats_label = Label.new()
	stats_label.position = Vector2(16,10)
	stats_label.size = Vector2(292,56)
	stats_label.add_theme_font_size_override("font_size",16)
	stats_label.add_theme_color_override("font_color",Color(1.0,0.92,0.72))
	top.add_child(stats_label)
	_refresh_stats()

	var q: PanelContainer = PanelContainer.new()
	q.position = Vector2(590,14)
	q.size = Vector2(360,96)
	ui.add_child(q)
	var qstyle: StyleBoxFlat = StyleBoxFlat.new()
	qstyle.bg_color = Color(0.11,0.07,0.05,0.94)
	qstyle.border_color = Color(0.80,0.34,0.14)
	qstyle.set_border_width_all(3)
	qstyle.corner_radius_top_left = 14
	qstyle.corner_radius_top_right = 14
	qstyle.corner_radius_bottom_left = 14
	qstyle.corner_radius_bottom_right = 14
	q.add_theme_stylebox_override("panel",qstyle)

	objective_label = Label.new()
	objective_label.position = Vector2(14,8)
	objective_label.size = Vector2(332,80)
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.add_theme_font_size_override("font_size",14)
	objective_label.add_theme_color_override("font_color",Color(1.0,0.83,0.50))
	q.add_child(objective_label)

	poi_label = Label.new()
	poi_label.position = Vector2(320,112)
	poi_label.size = Vector2(330,28)
	poi_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	poi_label.add_theme_font_size_override("font_size",17)
	poi_label.add_theme_color_override("font_color",Color.WHITE)
	poi_label.add_theme_color_override("font_shadow_color",Color.BLACK)
	poi_label.add_theme_constant_override("shadow_offset_x",2)
	poi_label.add_theme_constant_override("shadow_offset_y",2)
	ui.add_child(poi_label)

	nav_label = Label.new()
	nav_label.position = Vector2(285,145)
	nav_label.size = Vector2(400,30)
	nav_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav_label.add_theme_font_size_override("font_size",15)
	nav_label.add_theme_color_override("font_color",Color(1.0,0.75,0.32))
	nav_label.add_theme_color_override("font_shadow_color",Color.BLACK)
	nav_label.add_theme_constant_override("shadow_offset_x",2)
	nav_label.add_theme_constant_override("shadow_offset_y",2)
	ui.add_child(nav_label)

	toast_label = Label.new()
	toast_label.position = Vector2(235,448)
	toast_label.size = Vector2(490,44)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size",18)
	toast_label.add_theme_color_override("font_color",Color(1.0,0.84,0.48))
	toast_label.add_theme_color_override("font_shadow_color",Color.BLACK)
	toast_label.add_theme_constant_override("shadow_offset_x",2)
	toast_label.add_theme_constant_override("shadow_offset_y",2)
	ui.add_child(toast_label)

	_add_action_button("ATQ",Vector2(835,430),78,func(): _attack())
	_add_action_button("USAR",Vector2(748,455),64,func(): _interact())

	var hint: Label = Label.new()
	hint.position = Vector2(20,487)
	hint.size = Vector2(300,32)
	hint.text = "Arraste aqui para mover"
	hint.add_theme_color_override("font_color",Color(1,1,1,0.72))
	ui.add_child(hint)

func _add_action_button(text_value: String, pos: Vector2, button_size: float, callback: Callable) -> void:
	var button: Button = Button.new()
	button.text = text_value
	button.position = pos-Vector2(button_size,button_size)*0.5
	button.size = Vector2(button_size,button_size)
	button.add_theme_font_size_override("font_size",16)
	for state in ["normal","hover","pressed","focus"]:
		var st: StyleBoxFlat = StyleBoxFlat.new()
		st.bg_color = Color(0.19,0.10,0.05,0.96) if state != "pressed" else Color(0.35,0.17,0.07,0.96)
		st.border_color = Color(0.93,0.55,0.17)
		st.set_border_width_all(4)
		st.corner_radius_top_left = int(button_size/2.0)
		st.corner_radius_top_right = int(button_size/2.0)
		st.corner_radius_bottom_left = int(button_size/2.0)
		st.corner_radius_bottom_right = int(button_size/2.0)
		button.add_theme_stylebox_override(state,st)
	button.pressed.connect(callback)
	ui.add_child(button)

func _refresh_stats() -> void:
	if stats_label:
		stats_label.text = "DESERTO DE EDRAVAR\nNv 18   ❤ %d/%d   ◉ %d" % [player_hp,player_max_hp,player_gold]

func _refresh_objective() -> void:
	if objective_label and story_runtime:
		objective_label.text = story_runtime.hud_text()
	_update_navigation()

func _update_poi_hint() -> void:
	if poi_label == null or hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,205.0)
	poi_label.text = ("◆ "+String(poi.get("label",""))+"  •  USAR") if not poi.is_empty() else ""

func _target_position() -> Vector2:
	if story_runtime == null:
		return Vector2.ZERO
	if story_runtime.current_id == "Q_MS03_CARAVAN" and story_runtime.escort_started:
		return Vector2(8200,27800)
	var target_id: String = story_runtime.current_location()
	for poi in pois:
		if String(poi.get("id","")) == target_id:
			return poi.get("pos",Vector2.ZERO)
	return Vector2.ZERO

func _update_navigation() -> void:
	if nav_label == null or hero == null or story_runtime == null:
		return
	if story_runtime.act3_complete:
		nav_label.text = "Próximo destino: Pântanos Sombrios"
		return
	var target: Vector2 = _target_position()
	if target == Vector2.ZERO:
		nav_label.text = ""
		return
	var delta_pos: Vector2 = target-hero.position
	nav_label.text = "%s  %dm  %s" % [_direction_arrow(delta_pos),int(delta_pos.length()),story_runtime.title()]

func _direction_arrow(v: Vector2) -> String:
	if v.length() < 35.0:
		return "◆"
	var a: float = v.angle()
	if a >= -PI*0.125 and a < PI*0.125:
		return "→"
	if a >= PI*0.125 and a < PI*0.375:
		return "↘"
	if a >= PI*0.375 and a < PI*0.625:
		return "↓"
	if a >= PI*0.625 and a < PI*0.875:
		return "↙"
	if a >= PI*0.875 or a < -PI*0.875:
		return "←"
	if a >= -PI*0.875 and a < -PI*0.625:
		return "↖"
	if a >= -PI*0.625 and a < -PI*0.375:
		return "↑"
	return "↗"

func _show_toast(text_value: String) -> void:
	if toast_label:
		toast_label.text = text_value
	toast_timer = 3.2
