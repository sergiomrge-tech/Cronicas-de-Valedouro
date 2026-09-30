class_name ValedouroCartoonHub
extends Node2D

const EnvScript = preload("res://scripts/cartoon/hub_environment.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")

var environment: ValedouroCartoonHubEnvironment
var objects: Node2D
var hero: ValedouroCartoonHero
var camera: Camera2D
var ui: CanvasLayer
var objective_label: Label
var stats_label: Label
var toast_label: Label
var poi_label: Label
var joystick_id: int = -1
var joystick_origin = Vector2.ZERO
var joystick_vector = Vector2.ZERO
var speed = 220.0
var toast_timer = 0.0
var monsters: Array[Node2D] = []
var player_hp: int = 120
var player_max_hp: int = 120
var player_gold: int = 35
var field_quest_active: bool = false
var field_kills: int = 0

func _ready() -> void:
	objects = Node2D.new()
	objects.name = "WorldObjects"
	objects.y_sort_enabled = true
	add_child(objects)
	environment = EnvScript.new()
	environment.name = "CartoonEnvironment"
	add_child(environment)
	await get_tree().process_frame
	for data in environment.props:
		var prop = PropScript.new()
		prop.setup(data)
		objects.add_child(prop)
	hero = HeroScript.new()
	hero.name = "Player"
	hero.position = Vector2(1150,970)
	objects.add_child(hero)
	_spawn_monsters()
	camera = Camera2D.new()
	camera.name = "PlayerCamera"
	camera.position = Vector2.ZERO
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0; camera.limit_top = 0
	camera.limit_right = int(environment.WORLD_SIZE.x); camera.limit_bottom = int(environment.WORLD_SIZE.y)
	hero.add_child(camera)
	_build_ui()
	_update_poi_hint()

func _build_ui() -> void:
	ui = CanvasLayer.new(); ui.name = "HUD"; add_child(ui)
	var top = PanelContainer.new(); top.position = Vector2(14,14); top.size = Vector2(305,74); ui.add_child(top)
	var top_style = StyleBoxFlat.new(); top_style.bg_color = Color(0.08,0.07,0.12,0.94); top_style.border_color = Color(0.96,0.69,0.17); top_style.set_border_width_all(3); top_style.corner_radius_top_left=16; top_style.corner_radius_top_right=16; top_style.corner_radius_bottom_left=16; top_style.corner_radius_bottom_right=16; top.add_theme_stylebox_override("panel",top_style)
	stats_label = Label.new(); stats_label.position=Vector2(18,10); stats_label.size=Vector2(275,55); stats_label.add_theme_font_size_override("font_size",16); stats_label.add_theme_color_override("font_color",Color(1,0.95,0.82)); top.add_child(stats_label); _refresh_stats()
	var q = PanelContainer.new(); q.position=Vector2(617,16); q.size=Vector2(328,90); ui.add_child(q)
	var qstyle = StyleBoxFlat.new(); qstyle.bg_color=Color(0.07,0.08,0.12,0.92); qstyle.border_color=Color(0.21,0.49,0.82); qstyle.set_border_width_all(3); qstyle.corner_radius_top_left=14; qstyle.corner_radius_top_right=14; qstyle.corner_radius_bottom_left=14; qstyle.corner_radius_bottom_right=14; q.add_theme_stylebox_override("panel",qstyle)
	objective_label=Label.new(); objective_label.position=Vector2(14,9); objective_label.size=Vector2(300,70); objective_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; objective_label.text="HISTÓRIA PRINCIPAL\nChegada — fale com o NPC principal no Castelo"; objective_label.add_theme_color_override("font_color",Color(1,0.91,0.58)); q.add_child(objective_label)
	toast_label=Label.new(); toast_label.position=Vector2(280,450); toast_label.size=Vector2(400,42); toast_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; toast_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; toast_label.add_theme_font_size_override("font_size",18); toast_label.add_theme_color_override("font_color",Color(1,0.92,0.58)); toast_label.add_theme_color_override("font_shadow_color",Color(0,0,0)); toast_label.add_theme_constant_override("shadow_offset_x",2); toast_label.add_theme_constant_override("shadow_offset_y",2); ui.add_child(toast_label)
	poi_label=Label.new(); poi_label.position=Vector2(330,105); poi_label.size=Vector2(300,30); poi_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; poi_label.add_theme_font_size_override("font_size",17); poi_label.add_theme_color_override("font_color",Color(1,1,1)); poi_label.add_theme_color_override("font_shadow_color",Color(0,0,0)); poi_label.add_theme_constant_override("shadow_offset_x",2); poi_label.add_theme_constant_override("shadow_offset_y",2); ui.add_child(poi_label)
	_add_action_button("ATQ",Vector2(835,430),78,func(): _attack())
	_add_action_button("USAR",Vector2(748,455),64,func(): _interact())
	var hint = Label.new(); hint.position=Vector2(20,487); hint.size=Vector2(300,32); hint.text="Arraste aqui para mover"; hint.add_theme_color_override("font_color",Color(1,1,1,0.72)); ui.add_child(hint)

func _add_action_button(text: String, pos: Vector2, size: float, callback: Callable) -> void:
	var b = Button.new(); b.text=text; b.position=pos-Vector2(size,size)*0.5; b.size=Vector2(size,size); b.add_theme_font_size_override("font_size",16)
	for state in ["normal","hover","pressed","focus"]:
		var st = StyleBoxFlat.new(); st.bg_color=Color(0.12,0.08,0.19,0.95) if state!="pressed" else Color(0.28,0.17,0.42,0.95); st.border_color=Color(0.95,0.66,0.16); st.set_border_width_all(4); st.corner_radius_top_left=int(size/2); st.corner_radius_top_right=int(size/2); st.corner_radius_bottom_left=int(size/2); st.corner_radius_bottom_right=int(size/2); b.add_theme_stylebox_override(state,st)
	b.pressed.connect(callback); ui.add_child(b)

func _process(delta: float) -> void:
	toast_timer=maxf(0.0,toast_timer-delta)
	if toast_timer<=0.0 and toast_label: toast_label.text=""
	var dir = Input.get_vector("move_left","move_right","move_up","move_down")
	if joystick_vector.length()>0.12: dir=joystick_vector
	if dir.length()>1.0: dir=dir.normalized()
	if hero:
		var next = hero.position + dir*speed*delta
		if environment and environment.is_walkable(next): hero.position=next
		hero.set_motion(dir)
		_update_poi_hint()
	_update_monsters(delta)
	if Input.is_action_just_pressed("attack"): _attack()
	if Input.is_action_just_pressed("interact"): _interact()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < 330 and event.position.y > 300 and joystick_id < 0:
			joystick_id=event.index; joystick_origin=event.position; joystick_vector=Vector2.ZERO
		elif not event.pressed and event.index==joystick_id:
			joystick_id=-1; joystick_vector=Vector2.ZERO
	elif event is InputEventScreenDrag and event.index==joystick_id:
		joystick_vector=(event.position-joystick_origin).limit_length(80.0)/80.0

func _attack() -> void:
	if not hero:
		return
	hero.trigger_attack()
	var target: Node2D = _nearest_monster(105.0)
	if target == null:
		_show_toast("Ataque — nenhum inimigo ao alcance.")
		return
	var dead: bool = target.take_damage(18)
	if dead:
		var kind: String = String(target.kind)
		monsters.erase(target)
		target.queue_free()
		player_gold += 6
		if field_quest_active and kind == "wolf":
			field_kills += 1
			if field_kills >= 3:
				objective_label.text = "HISTÓRIA PRINCIPAL\nLobos nos Campos — retorne à Guilda"
				_show_toast("Área segura por enquanto. Retorne à Guilda.")
			else:
				objective_label.text = "HISTÓRIA PRINCIPAL\nLobos nos Campos — %d/3" % field_kills
		else:
			_show_toast("Inimigo derrotado. +6 ouro")
		_refresh_stats()

func _interact() -> void:
	if not hero or not environment: return
	var poi = environment.nearest_poi(hero.position,170.0)
	if poi.is_empty():
		_show_toast("Nada para interagir aqui.")
		return
	var id = String(poi.get("id","")); var label = String(poi.get("label","Local"))
	match id:
		"POI_REG001_CASTLE":
			objective_label.text="HISTÓRIA PRINCIPAL\nChegada — conheça os serviços da cidade"
			_show_toast("Castelo de Valedouro — primeira etapa de Chegada registrada.")
		"POI_REG001_FORGE": _show_toast("Ferreiro — upgrades e crafting serão ligados ao inventário.")
		"POI_REG001_TAVERN": _show_toast("Taverna — descanso, rumores e save no vertical slice.")
		"POI_REG001_GUILD":
			if field_quest_active and field_kills >= 3:
				field_quest_active = false
				player_gold += 30
				objective_label.text = "HISTÓRIA PRINCIPAL\nExplore os Campos do Vale e siga pela estrada sul"
				_show_toast("Contrato concluído. +30 ouro")
				_refresh_stats()
			else:
				field_quest_active = true
				field_kills = mini(field_kills,3)
				objective_label.text = "HISTÓRIA PRINCIPAL\nLobos nos Campos — %d/3" % field_kills
				_show_toast("Contrato aceito: afaste 3 lobos dos Campos do Vale.")
		"POI_REG001_ALCHEMIST": _show_toast("Alquimista — poções e consumíveis.")
		"POI_REG001_FIELDS": _show_toast("Campos do Vale — primeiro anel de exploração fora da cidade.")
		"POI_REG001_FARM": _show_toast("Fazenda do Sol — a estrada continua para o sul.")
		"POI_REG001_FIELD_CHEST":
			player_gold += 12
			_refresh_stats()
			_show_toast("Baú encontrado: +12 ouro.")
		_: _show_toast(label)

func _show_toast(text: String) -> void:
	if toast_label: toast_label.text=text
	toast_timer=3.2

func _update_poi_hint() -> void:
	if not poi_label or not hero or not environment: return
	var poi = environment.nearest_poi(hero.position,190.0)
	poi_label.text=("◆ " + String(poi.get("label","")) + "  •  USAR") if not poi.is_empty() else ""


func _spawn_monsters() -> void:
	var rows: Array[Dictionary] = [
		{"kind":"wolf","name":"Lobo do Vale","pos":Vector2(1040,1870),"hp":34,"speed":88.0,"damage":7,"scale":1.0},
		{"kind":"wolf","name":"Lobo do Vale","pos":Vector2(1240,1960),"hp":34,"speed":90.0,"damage":7,"scale":1.0},
		{"kind":"wolf","name":"Lobo Alfa Jovem","pos":Vector2(1110,2160),"hp":44,"speed":96.0,"damage":9,"scale":1.08},
		{"kind":"goblin","name":"Saqueador Verde","pos":Vector2(1440,2210),"hp":42,"speed":76.0,"damage":8,"scale":1.0},
		{"kind":"slime","name":"Gosma do Prado","pos":Vector2(880,2220),"hp":28,"speed":54.0,"damage":5,"scale":1.0}
	]
	for data in rows:
		var monster: Node2D = MonsterScript.new()
		monster.setup(data)
		objects.add_child(monster)
		monsters.append(monster)

func _update_monsters(delta: float) -> void:
	if not hero or not environment:
		return
	for monster in monsters.duplicate():
		if not is_instance_valid(monster):
			monsters.erase(monster)
			continue
		var dist: float = monster.position.distance_to(hero.position)
		if dist < 270.0 and dist > 50.0:
			var dir: Vector2 = (hero.position - monster.position).normalized()
			var next: Vector2 = monster.position + dir * float(monster.move_speed) * delta
			if environment.is_walkable(next):
				monster.position = next
		if dist <= 52.0 and monster.can_hit():
			monster.mark_hit()
			player_hp = maxi(0, player_hp - int(monster.contact_damage))
			_refresh_stats()
			if player_hp <= 0:
				player_hp = player_max_hp
				hero.position = Vector2(1150,970)
				_show_toast("Você foi resgatado e voltou à Praça Central.")
				_refresh_stats()

func _nearest_monster(radius: float) -> Node2D:
	if not hero:
		return null
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

func _refresh_stats() -> void:
	if stats_label:
		stats_label.text = "CRÔNICAS DE VALEDOURO\nNv 1   ❤ %d/%d   ◉ %d" % [player_hp,player_max_hp,player_gold]
