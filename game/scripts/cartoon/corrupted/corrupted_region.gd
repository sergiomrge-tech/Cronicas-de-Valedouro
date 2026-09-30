class_name ValedouroCartoonCorruptedRegion
extends Node2D

const Corrupted = preload("res://scripts/cartoon/corrupted/corrupted_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/corrupted/corrupted_story_map.gd")
const StreamScript = preload("res://scripts/cartoon/corrupted/corrupted_world_stream.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/corrupted/corrupted_story_runtime.gd")
const ZoneScript = preload("res://scripts/cartoon/corrupted/corrupted_story_zone.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")
const MapOverlayScript = preload("res://scripts/cartoon/corrupted/corrupted_map_overlay.gd")
const ExplorationDirectorScript = preload("res://scripts/cartoon/cartoon_exploration_director.gd")
const CraftingUIScript = preload("res://scripts/cartoon/cartoon_crafting_ui.gd")

var story_zones: Node2D
var objects: Node2D
var hero: Node2D
var camera: Camera2D
var world_stream: Node2D
var story_runtime: RefCounted
var exploration_director: Node
var crafting_ui: Control
var monsters: Array[Node2D] = []
var pois: Array[Dictionary] = []
var ui: CanvasLayer
var objective_label: Label
var stats_label: Label
var poi_label: Label
var nav_label: Label
var toast_label: Label
var map_overlay: Control
var map_open: bool = false
var joystick_id: int = -1
var joystick_origin: Vector2 = Vector2.ZERO
var joystick_vector: Vector2 = Vector2.ZERO
var speed: float = 228.0
var toast_timer: float = 0.0
var player_hp: int = 330
var player_max_hp: int = 330
var player_gold: int = 470

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
	for data in StoryMap.obelisks():
		_add_poi_prop(data)
	for data in StoryMap.optional_pois():
		_add_poi_prop(data)
	story_runtime = StoryRuntimeScript.new()
	hero = HeroScript.new()
	hero.name = "Player"
	hero.position = Corrupted.ENTRY_POS
	objects.add_child(hero)

	exploration_director = ExplorationDirectorScript.new()
	exploration_director.name = "ExplorationDirector"
	add_child(exploration_director)
	exploration_director.setup(self,objects,hero,Corrupted.REGION_ID)
	world_stream = StreamScript.new()
	world_stream.name = "CorruptedWorldStream"
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
	camera.limit_right = int(Corrupted.REGION_SIZE.x)
	camera.limit_bottom = int(Corrupted.REGION_SIZE.y)
	hero.add_child(camera)
	_build_ui()
	crafting_ui = CraftingUIScript.new()
	crafting_ui.name = "CraftingUI"
	ui.add_child(crafting_ui)
	crafting_ui.setup(self,hero,Corrupted.REGION_ID)
	_refresh_objective()

func _add_poi_prop(data: Dictionary) -> void:
	var prop: Node2D = PropScript.new()
	prop.setup(data)
	objects.add_child(prop)
	pois.append({"id":String(data.get("id","")),"label":String(data.get("label","")),"pos":data.get("pos",Vector2.ZERO),"parent":String(data.get("parent","")),"quest":String(data.get("quest",""))})

func _spawn_monster(data: Dictionary) -> void:
	var monster: Node2D = MonsterScript.new()
	monster.setup(data)
	objects.add_child(monster)
	monsters.append(monster)

func _process(delta: float) -> void:
	toast_timer = maxf(0.0,toast_timer-delta)
	if toast_timer <= 0.0 and toast_label:
		toast_label.text = ""
	if map_open or (crafting_ui != null and crafting_ui.is_open()):
		if hero:
			hero.set_motion(Vector2.ZERO)
		return
	var dir: Vector2 = Input.get_vector("move_left","move_right","move_up","move_down")
	if joystick_vector.length() > 0.12:
		dir = joystick_vector
	if dir.length() > 1.0:
		dir = dir.normalized()
	if hero:
		var next: Vector2 = hero.position+dir*speed*delta
		if Corrupted.in_region(next,70.0):
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
	if map_open or (crafting_ui != null and crafting_ui.is_open()):
		return
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
	var target: Node2D = _nearest_monster(118.0)
	if target == null:
		_show_toast("Nenhum inimigo ao alcance.")
		return
	var boss_id: String = String(target.boss_id)
	if boss_id == "BOSS_GENERAL_ECO_VAZIO_001" and story_runtime.current_id != "Q_MS07_GENERAL_VOID":
		_show_toast("A Cidadela da Coroa Oca ainda protege o último General.")
		return
	var dead: bool = target.take_damage(hero.attack_damage(30))
	if not dead:
		return
	monsters.erase(target)
	target.queue_free()
	player_gold += 18
	var advanced: bool = false
	if boss_id != "":
		advanced = story_runtime.register_boss(boss_id)
	_refresh_stats()
	_refresh_objective()
	if advanced:
		_show_toast("O General do Eco Vazio caiu. O Portão do Último Mapa se abriu.")
	else:
		_show_toast("Inimigo derrotado. +18 ouro")

func _interact() -> void:
	if hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,220.0)
	if poi.is_empty():
		if exploration_director != null and exploration_director.try_interact():
			return
		_show_toast("Nada para interagir aqui.")
		return
	var id: String = String(poi.get("id",""))
	var label: String = String(poi.get("label","Local"))
	if id in ["LOC_WAR_OBELISK_W","LOC_WAR_OBELISK_C","LOC_WAR_OBELISK_E"]:
		var completed: bool = story_runtime.destroy_obelisk(id)
		_refresh_objective()
		_show_toast("Obelisco destruído." if not completed else "Os três obeliscos ruíram. O corredor demoníaco enfraqueceu.")
		return
	if story_runtime.interact(id):
		_refresh_objective()
		_show_toast("História principal atualizada: "+label)
		return
	match id:
		"LOC_LAST_BASTION": _show_toast("A Aliança mantém sua última linha de defesa.")
		"LOC_BROKEN_CATHEDRAL": _show_toast("O Pacto das Seis Coroas está dentro da Catedral Partida.")
		"LOC_ALLIANCE_WAR_COUNCIL": _show_toast("As Seis Coroas preparam o avanço final.")
		"LOC_HOLLOW_CROWN_CITADEL": _show_toast("O último General protege o corredor central.")
		"POI_CORRUPTED_ABYSS_ROUTE":
			if story_runtime.act7_complete:
				_show_toast("Entrando no Coração Abissal...")
				get_tree().change_scene_to_file("res://scenes/cartoon/AbyssHeartCartoon.tscn")
			else:
				_show_toast("O corredor central permanece bloqueado.")
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
		if dist < 345.0 and dist > 54.0:
			var dir: Vector2 = (hero.position-monster.position).normalized()
			var next: Vector2 = monster.position+dir*float(monster.move_speed)*delta
			if Corrupted.in_region(next,70.0):
				monster.position = next
		if dist <= 56.0 and monster.can_hit():
			monster.mark_hit()
			player_hp = maxi(0,player_hp-int(hero.reduce_incoming_damage(int(monster.contact_damage))))
			_refresh_stats()
			if player_hp <= 0:
				player_hp = player_max_hp
				hero.position = Corrupted.ENTRY_POS
				_refresh_stats()
				_show_toast("A patrulha do Último Bastião resgatou você.")

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
	top_style.bg_color = Color(0.08,0.04,0.08,0.96)
	top_style.border_color = Color(0.66,0.20,0.45)
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
	stats_label.add_theme_color_override("font_color",Color(1.0,0.84,0.92))
	top.add_child(stats_label)
	_refresh_stats()
	var q: PanelContainer = PanelContainer.new()
	q.position = Vector2(590,14)
	q.size = Vector2(360,96)
	ui.add_child(q)
	var qstyle: StyleBoxFlat = StyleBoxFlat.new()
	qstyle.bg_color = Color(0.07,0.035,0.07,0.95)
	qstyle.border_color = Color(0.55,0.15,0.37)
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
	objective_label.add_theme_color_override("font_color",Color(1.0,0.79,0.89))
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
	nav_label.add_theme_color_override("font_color",Color(0.95,0.54,0.72))
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
	toast_label.add_theme_color_override("font_color",Color(0.96,0.66,0.80))
	toast_label.add_theme_color_override("font_shadow_color",Color.BLACK)
	toast_label.add_theme_constant_override("shadow_offset_x",2)
	toast_label.add_theme_constant_override("shadow_offset_y",2)
	ui.add_child(toast_label)
	map_overlay = MapOverlayScript.new()
	map_overlay.position = Vector2(55,40)
	map_overlay.size = Vector2(850,460)
	map_overlay.visible = false
	map_overlay.setup(hero)
	ui.add_child(map_overlay)
	_add_map_button()
	_add_action_button("ATQ",Vector2(835,430),78,func(): _attack())
	_add_action_button("USAR",Vector2(748,455),64,func(): _interact())
	var hint: Label = Label.new()
	hint.position = Vector2(20,487)
	hint.size = Vector2(300,32)
	hint.text = "Arraste aqui para mover"
	hint.add_theme_color_override("font_color",Color(1,1,1,0.72))
	ui.add_child(hint)

func _add_map_button() -> void:
	var button: Button = Button.new()
	button.text = "MAPA"
	button.position = Vector2(425,18)
	button.size = Vector2(108,46)
	button.add_theme_font_size_override("font_size",15)
	for state in ["normal","hover","pressed","focus"]:
		var st: StyleBoxFlat = StyleBoxFlat.new()
		st.bg_color = Color(0.13,0.06,0.12,0.97) if state != "pressed" else Color(0.26,0.10,0.22,0.97)
		st.border_color = Color(0.69,0.22,0.47)
		st.set_border_width_all(3)
		st.corner_radius_top_left = 12
		st.corner_radius_top_right = 12
		st.corner_radius_bottom_left = 12
		st.corner_radius_bottom_right = 12
		button.add_theme_stylebox_override(state,st)
	button.pressed.connect(_toggle_map)
	ui.add_child(button)

func _toggle_map() -> void:
	map_open = not map_open
	if map_overlay:
		map_overlay.visible = map_open
		if map_open:
			map_overlay.set_target(story_runtime.current_location())
	joystick_id = -1
	joystick_vector = Vector2.ZERO

func _add_action_button(text_value: String, pos: Vector2, button_size: float, callback: Callable) -> void:
	var button: Button = Button.new()
	button.text = text_value
	button.position = pos-Vector2(button_size,button_size)*0.5
	button.size = Vector2(button_size,button_size)
	button.add_theme_font_size_override("font_size",16)
	for state in ["normal","hover","pressed","focus"]:
		var st: StyleBoxFlat = StyleBoxFlat.new()
		st.bg_color = Color(0.13,0.06,0.12,0.96) if state != "pressed" else Color(0.27,0.10,0.23,0.96)
		st.border_color = Color(0.69,0.22,0.47)
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
		stats_label.text = "TERRAS CORROMPIDAS\nNv 68   ❤ %d/%d   ◉ %d" % [player_hp,player_max_hp,player_gold]

func _refresh_objective() -> void:
	if objective_label and story_runtime:
		objective_label.text = story_runtime.hud_text()
	if map_overlay and story_runtime:
		map_overlay.set_target(story_runtime.current_location())
	_update_navigation()

func _update_poi_hint() -> void:
	if poi_label == null or hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,220.0)
	if not poi.is_empty():
		poi_label.text = "◆ "+String(poi.get("label",""))+"  •  USAR"
	elif exploration_director != null:
		poi_label.text = exploration_director.hint_text()
	else:
		poi_label.text = ""

func _target_position() -> Vector2:
	if story_runtime == null:
		return Vector2.ZERO
	if story_runtime.current_id == "Q_MS07_OBELISKS":
		for row in StoryMap.obelisks():
			var id: String = String(row.get("id",""))
			if not story_runtime.destroyed_obelisks.has(id):
				return row.get("pos",Vector2.ZERO)
	var target_id: String = story_runtime.current_location()
	for poi in pois:
		if String(poi.get("id","")) == target_id:
			return poi.get("pos",Vector2.ZERO)
	return Vector2.ZERO

func _update_navigation() -> void:
	if nav_label == null or hero == null or story_runtime == null:
		return
	if story_runtime.act7_complete:
		nav_label.text = "Próximo destino: Coração Abissal"
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
	if a >= -PI*0.125 and a < PI*0.125: return "→"
	if a >= PI*0.125 and a < PI*0.375: return "↘"
	if a >= PI*0.375 and a < PI*0.625: return "↓"
	if a >= PI*0.625 and a < PI*0.875: return "↙"
	if a >= PI*0.875 or a < -PI*0.875: return "←"
	if a >= -PI*0.875 and a < -PI*0.625: return "↖"
	if a >= -PI*0.625 and a < -PI*0.375: return "↑"
	return "↗"

func _show_toast(text_value: String) -> void:
	if toast_label:
		toast_label.text = text_value
	toast_timer = 3.2
