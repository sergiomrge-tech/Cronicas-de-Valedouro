class_name ValedouroCartoonForestRegion
extends Node2D

const Forest = preload("res://scripts/cartoon/forest/forest_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/forest/forest_story_map.gd")
const StreamScript = preload("res://scripts/cartoon/forest/forest_world_stream.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/forest/forest_story_runtime.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")
const StoryZoneScript = preload("res://scripts/cartoon/forest/forest_story_zone.gd")

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
var objective_nav_label: Label
var toast_label: Label

var joystick_id: int = -1
var joystick_origin: Vector2 = Vector2.ZERO
var joystick_vector: Vector2 = Vector2.ZERO
var speed: float = 230.0
var toast_timer: float = 0.0
var player_hp: int = 145
var player_max_hp: int = 145
var player_gold: int = 80

func _ready() -> void:
	story_zones = Node2D.new()
	story_zones.name = "StoryZones"
	story_zones.z_index = -12
	add_child(story_zones)
	_spawn_story_zones()

	objects = Node2D.new()
	objects.name = "WorldObjects"
	objects.y_sort_enabled = true
	add_child(objects)

	_spawn_landmarks()
	_spawn_optional_pois()

	story_runtime = StoryRuntimeScript.new()

	hero = HeroScript.new()
	hero.name = "Player"
	hero.position = Forest.ENTRY_POS
	objects.add_child(hero)

	world_stream = StreamScript.new()
	world_stream.name = "ForestWorldStream"
	add_child(world_stream)
	world_stream.setup(hero)

	_spawn_encounters()
	_spawn_defense_pack()

	camera = Camera2D.new()
	camera.name = "PlayerCamera"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(Forest.REGION_SIZE.x)
	camera.limit_bottom = int(Forest.REGION_SIZE.y)
	hero.add_child(camera)

	_build_ui()
	_refresh_objective()

func _spawn_story_zones() -> void:
	for data in StoryMap.zones():
		var zone: Node2D = StoryZoneScript.new()
		zone.setup(data)
		story_zones.add_child(zone)

func _spawn_landmarks() -> void:
	for data in StoryMap.locations():
		_add_poi_prop(data)
	for data in StoryMap.root_subshrines():
		_add_poi_prop(data)

func _spawn_optional_pois() -> void:
	for data in StoryMap.optional_pois():
		_add_poi_prop(data)

func _add_poi_prop(data: Dictionary) -> void:
	var prop: Node2D = PropScript.new()
	prop.setup(data)
	objects.add_child(prop)
	pois.append({
		"id":String(data.get("id","")),
		"label":String(data.get("label","")),
		"pos":data.get("pos",Vector2.ZERO),
		"parent":String(data.get("parent","")),
		"quest":String(data.get("quest",""))
	})

func _spawn_encounters() -> void:
	for data in StoryMap.encounters():
		_spawn_monster(data)

func _spawn_defense_pack() -> void:
	var center: Vector2 = Vector2(25800,37400)
	var rows: Array[Dictionary] = [
		{"kind":"wolf","name":"Lobo Corrompido","pos":center+Vector2(-420,-180),"hp":58,"speed":98.0,"damage":11,"scale":1.08,"story_tag":"forest_defense"},
		{"kind":"goblin","name":"Saqueador Corrompido","pos":center+Vector2(390,-110),"hp":64,"speed":84.0,"damage":12,"scale":1.08,"story_tag":"forest_defense"},
		{"kind":"slime","name":"Esporo Corrompido","pos":center+Vector2(-330,310),"hp":52,"speed":62.0,"damage":9,"scale":1.14,"story_tag":"forest_defense"},
		{"kind":"wolf","name":"Lobo de Casca Negra","pos":center+Vector2(350,330),"hp":66,"speed":100.0,"damage":12,"scale":1.12,"story_tag":"forest_defense"}
	]
	for data in rows:
		_spawn_monster(data)

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
		if Forest.in_region(next,70.0):
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
	var target: Node2D = _nearest_monster(112.0)
	if target == null:
		_show_toast("Nenhum inimigo ao alcance.")
		return
	var dead: bool = target.take_damage(20)
	if not dead:
		return
	var story_tag: String = String(target.story_tag)
	var boss_id: String = String(target.boss_id)
	monsters.erase(target)
	target.queue_free()
	player_gold += 8
	var advanced: bool = false
	if story_runtime:
		if story_tag == "forest_defense":
			advanced = story_runtime.register_defense_kill(story_tag)
		elif boss_id != "":
			advanced = story_runtime.register_boss(boss_id)
	_refresh_stats()
	_refresh_objective()
	if advanced:
		_show_toast("Objetivo principal concluído. A trilha seguinte foi revelada.")
	else:
		_show_toast("Criatura derrotada. +8 ouro")

func _interact() -> void:
	if hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,185.0)
	if poi.is_empty():
		_show_toast("Nada para interagir aqui.")
		return
	var id: String = String(poi.get("id",""))
	var label: String = String(poi.get("label","Local"))

	if id in ["LOC_FOREST_ROOT_SHRINE_W","LOC_FOREST_ROOT_SHRINE_C","LOC_FOREST_ROOT_SHRINE_E"]:
		var completed: bool = story_runtime.activate_root_shrine(id)
		_refresh_objective()
		if completed:
			_show_toast("As três raízes responderam. A Árvore-Memória despertou.")
		else:
			_show_toast(label+" purificada.")
		return

	if story_runtime.try_location(id):
		_refresh_objective()
		_show_toast("História principal atualizada: "+label)
		return

	match id:
		"LOC_FOREST_RANGER_LODGE":
			_show_toast("Guardas Verdes: as criaturas corrompidas cercam a casa.")
		"LOC_MEMORY_TREE":
			_show_toast("A árvore pulsa com lembranças antigas.")
		"LOC_HOLLOW_ROOT_ARENA":
			_show_toast("A Raiz Oca está próxima. Prepare-se.")
		"LOC_FOREST_CARTOGRAPHER_SHRINE":
			_show_toast("O selo verde reage ao mapa do Guardião.")
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
		if dist < 320.0 and dist > 52.0:
			var dir: Vector2 = (hero.position-monster.position).normalized()
			var next: Vector2 = monster.position+dir*float(monster.move_speed)*delta
			if Forest.in_region(next,70.0):
				monster.position = next
		if dist <= 54.0 and monster.can_hit():
			monster.mark_hit()
			player_hp = maxi(0,player_hp-int(monster.contact_damage))
			_refresh_stats()
			if player_hp <= 0:
				player_hp = player_max_hp
				hero.position = Forest.ENTRY_POS
				_refresh_stats()
				_show_toast("Você foi resgatado pelos Guardas Verdes.")

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
	top_style.bg_color = Color(0.06,0.10,0.08,0.94)
	top_style.border_color = Color(0.43,0.78,0.34)
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
	stats_label.add_theme_color_override("font_color",Color(0.93,1.0,0.86))
	top.add_child(stats_label)
	_refresh_stats()

	var q: PanelContainer = PanelContainer.new()
	q.position = Vector2(590,14)
	q.size = Vector2(360,96)
	ui.add_child(q)
	var qstyle: StyleBoxFlat = StyleBoxFlat.new()
	qstyle.bg_color = Color(0.05,0.09,0.07,0.93)
	qstyle.border_color = Color(0.25,0.67,0.36)
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
	objective_label.add_theme_color_override("font_color",Color(0.89,1.0,0.64))
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

	objective_nav_label = Label.new()
	objective_nav_label.position = Vector2(300,145)
	objective_nav_label.size = Vector2(370,30)
	objective_nav_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective_nav_label.add_theme_font_size_override("font_size",15)
	objective_nav_label.add_theme_color_override("font_color",Color(0.82,1.0,0.46))
	objective_nav_label.add_theme_color_override("font_shadow_color",Color.BLACK)
	objective_nav_label.add_theme_constant_override("shadow_offset_x",2)
	objective_nav_label.add_theme_constant_override("shadow_offset_y",2)
	ui.add_child(objective_nav_label)

	toast_label = Label.new()
	toast_label.position = Vector2(245,448)
	toast_label.size = Vector2(470,44)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size",18)
	toast_label.add_theme_color_override("font_color",Color(0.91,1.0,0.65))
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
		st.bg_color = Color(0.08,0.16,0.10,0.95) if state != "pressed" else Color(0.15,0.32,0.18,0.95)
		st.border_color = Color(0.48,0.82,0.32)
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
		stats_label.text = "FLORESTA ANCESTRAL\nNv 8   ❤ %d/%d   ◉ %d" % [player_hp,player_max_hp,player_gold]

func _refresh_objective() -> void:
	if objective_label and story_runtime:
		objective_label.text = story_runtime.hud_text()
	_update_navigation()

func _update_poi_hint() -> void:
	if poi_label == null or hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,190.0)
	poi_label.text = ("◆ "+String(poi.get("label",""))+"  •  USAR") if not poi.is_empty() else ""

func _target_position() -> Vector2:
	if story_runtime == null:
		return Vector2.ZERO
	if story_runtime.current_id == "Q_MS02_ROOTS":
		for sub in StoryMap.root_subshrines():
			var id: String = String(sub.get("id",""))
			if not story_runtime.shrines_active.has(id):
				return sub.get("pos",Vector2.ZERO)
	var target_id: String = story_runtime.current_location()
	for poi in pois:
		if String(poi.get("id","")) == target_id:
			return poi.get("pos",Vector2.ZERO)
	return Vector2.ZERO

func _update_navigation() -> void:
	if objective_nav_label == null or hero == null or story_runtime == null:
		return
	if story_runtime.act2_complete:
		objective_nav_label.text = "Próximo destino: Edravar"
		return
	var target: Vector2 = _target_position()
	if target == Vector2.ZERO:
		objective_nav_label.text = ""
		return
	var delta_pos: Vector2 = target-hero.position
	var dist: int = int(delta_pos.length())
	objective_nav_label.text = "%s  %dm  %s" % [_direction_arrow(delta_pos),dist,story_runtime.title()]

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
