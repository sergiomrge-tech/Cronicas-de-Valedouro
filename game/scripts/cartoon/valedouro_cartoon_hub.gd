class_name ValedouroCartoonHub
extends Node2D

const EnvScript = preload("res://scripts/cartoon/hub_environment.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const StreamScript = preload("res://scripts/cartoon/cartoon_world_stream.gd")
const ExplorationContent = preload("res://scripts/cartoon/cartoon_exploration_content.gd")
const MainStoryMap = preload("res://scripts/cartoon/cartoon_main_story_map.gd")
const StoryZoneScript = preload("res://scripts/cartoon/cartoon_story_zone.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/cartoon_story_runtime.gd")
const MapOverlayScript = preload("res://scripts/cartoon/hub_map_overlay.gd")
const CraftingUIScript = preload("res://scripts/cartoon/cartoon_crafting_ui.gd")
const ZoomControlsScript = preload("res://scripts/cartoon/cartoon_zoom_controls.gd")
const InventoryUIScript = preload("res://scripts/cartoon/cartoon_inventory_ui.gd")
const HUDStatusScript = preload("res://scripts/cartoon/cartoon_hud_status.gd")

var environment: ValedouroCartoonHubEnvironment
var objects: Node2D
var story_zones: Node2D
var hero: ValedouroCartoonHero
var camera: Camera2D
var world_stream: ValedouroCartoonWorldStream
var story_runtime
var ui: CanvasLayer
var objective_label: Label
var stats_label: Label
var toast_label: Label
var poi_label: Label
var map_overlay: Control
var crafting_ui: Control
var zoom_controls: Control
var inventory_ui: Control
var hud_status: Control
var map_open: bool = false
var objective_nav_label: Label
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
	story_zones = Node2D.new()
	story_zones.name = "StoryZones"
	story_zones.z_index = -12
	add_child(story_zones)
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
	_spawn_outer_landmarks()
	_spawn_main_story_zones()
	_spawn_main_story_locations()
	_spawn_region_transitions()
	story_runtime = StoryRuntimeScript.new()
	hero = HeroScript.new()
	hero.name = "Player"
	hero.position = Region.world_from_hub(Vector2(1150,330))
	objects.add_child(hero)
	world_stream = StreamScript.new()
	world_stream.name = "WorldStream"
	add_child(world_stream)
	world_stream.setup(hero)
	_spawn_monsters()
	_spawn_outer_encounters()
	_spawn_main_story_encounters()
	camera = Camera2D.new()
	camera.name = "PlayerCamera"
	camera.position = Vector2.ZERO
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0; camera.limit_top = 0
	camera.limit_right = int(environment.WORLD_SIZE.x); camera.limit_bottom = int(environment.WORLD_SIZE.y)
	hero.add_child(camera)
	_build_ui()
	hud_status = HUDStatusScript.new()
	hud_status.name = "PlayerStatusHUD"
	ui.add_child(hud_status)
	hud_status.setup("VALEDOURO",Color(0.96,0.69,0.17))
	_refresh_stats()
	zoom_controls = ZoomControlsScript.new()
	zoom_controls.name = "ZoomControls"
	ui.add_child(zoom_controls)
	zoom_controls.setup(camera)
	crafting_ui = CraftingUIScript.new()
	crafting_ui.name = "CraftingUI"
	ui.add_child(crafting_ui)
	crafting_ui.setup(self,hero,"REG_001_BERCO_VALEDOURO")
	inventory_ui = InventoryUIScript.new()
	inventory_ui.name = "InventoryUI"
	ui.add_child(inventory_ui)
	inventory_ui.setup(self,hero,true)
	_bind_campaign_save()
	_update_poi_hint()

func _bind_campaign_save() -> void:
	if get_tree().current_scene != self:
		return
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null:
		return
	state.bind_scene("res://scenes/cartoon/ValedouroCartoonHub.tscn",self,hero,story_runtime,1,120,35,["field_quest_active","field_kills"])
	if objective_label != null and story_runtime != null:
		objective_label.text = story_runtime.hud_text()
	_update_objective_navigation()
	_refresh_stats()

func _change_scene_saved(path: String) -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		state.prepare_transition(path)
	get_tree().change_scene_to_file(path)

func _build_ui() -> void:
	ui = CanvasLayer.new(); ui.name = "HUD"; add_child(ui)
	var top = PanelContainer.new(); top.position = Vector2(14,14); top.size = Vector2(305,74); ui.add_child(top)
	top.visible = false
	var top_style = StyleBoxFlat.new(); top_style.bg_color = Color(0.08,0.07,0.12,0.94); top_style.border_color = Color(0.96,0.69,0.17); top_style.set_border_width_all(3); top_style.corner_radius_top_left=16; top_style.corner_radius_top_right=16; top_style.corner_radius_bottom_left=16; top_style.corner_radius_bottom_right=16; top.add_theme_stylebox_override("panel",top_style)
	stats_label = Label.new(); stats_label.position=Vector2(18,10); stats_label.size=Vector2(275,55); stats_label.add_theme_font_size_override("font_size",16); stats_label.add_theme_color_override("font_color",Color(1,0.95,0.82)); top.add_child(stats_label); _refresh_stats()
	var q = PanelContainer.new(); q.position=Vector2(690,14); q.size=Vector2(256,96); ui.add_child(q)
	var qstyle = StyleBoxFlat.new(); qstyle.bg_color=Color(0.07,0.08,0.12,0.92); qstyle.border_color=Color(0.21,0.49,0.82); qstyle.set_border_width_all(3); qstyle.corner_radius_top_left=14; qstyle.corner_radius_top_right=14; qstyle.corner_radius_bottom_left=14; qstyle.corner_radius_bottom_right=14; q.add_theme_stylebox_override("panel",qstyle)
	objective_label=Label.new(); objective_label.position=Vector2(14,9); objective_label.size=Vector2(228,78); objective_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; objective_label.text=story_runtime.hud_text(); objective_label.add_theme_color_override("font_color",Color(1,0.91,0.58)); q.add_child(objective_label)
	toast_label=Label.new(); toast_label.position=Vector2(280,450); toast_label.size=Vector2(400,42); toast_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; toast_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; toast_label.add_theme_font_size_override("font_size",18); toast_label.add_theme_color_override("font_color",Color(1,0.92,0.58)); toast_label.add_theme_color_override("font_shadow_color",Color(0,0,0)); toast_label.add_theme_constant_override("shadow_offset_x",2); toast_label.add_theme_constant_override("shadow_offset_y",2); ui.add_child(toast_label)
	poi_label=Label.new(); poi_label.position=Vector2(330,105); poi_label.size=Vector2(300,30); poi_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; poi_label.add_theme_font_size_override("font_size",17); poi_label.add_theme_color_override("font_color",Color(1,1,1)); poi_label.add_theme_color_override("font_shadow_color",Color(0,0,0)); poi_label.add_theme_constant_override("shadow_offset_x",2); poi_label.add_theme_constant_override("shadow_offset_y",2); ui.add_child(poi_label)
	map_overlay=MapOverlayScript.new(); map_overlay.position=Vector2(55,40); map_overlay.size=Vector2(850,460); map_overlay.visible=false; map_overlay.setup(hero); ui.add_child(map_overlay)
	_add_map_button()
	objective_nav_label=Label.new(); objective_nav_label.position=Vector2(350,140); objective_nav_label.size=Vector2(260,30); objective_nav_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; objective_nav_label.add_theme_font_size_override("font_size",15); objective_nav_label.add_theme_color_override("font_color",Color(1,0.84,0.32)); objective_nav_label.add_theme_color_override("font_shadow_color",Color(0,0,0)); objective_nav_label.add_theme_constant_override("shadow_offset_x",2); objective_nav_label.add_theme_constant_override("shadow_offset_y",2); ui.add_child(objective_nav_label)
	_add_action_button("ATQ",Vector2(835,430),78,func(): _attack())
	_add_action_button("USAR",Vector2(748,455),64,func(): _interact())
	var hint = Label.new(); hint.position=Vector2(20,487); hint.size=Vector2(300,32); hint.text="Arraste aqui para mover"; hint.add_theme_color_override("font_color",Color(1,1,1,0.72)); ui.add_child(hint)

func _add_map_button() -> void:
	var button: Button = Button.new()
	button.text = "MAPA"
	button.position = Vector2(350,18)
	button.size = Vector2(104,46)
	button.add_theme_font_size_override("font_size",15)
	for state in ["normal","hover","pressed","focus"]:
		var st: StyleBoxFlat = StyleBoxFlat.new()
		st.bg_color = Color(0.08,0.08,0.14,0.97) if state != "pressed" else Color(0.18,0.16,0.28,0.97)
		st.border_color = Color(0.30,0.62,0.92)
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
	if map_open:
		if crafting_ui != null and crafting_ui.has_method("close_panel"):
			crafting_ui.close_panel()
		if inventory_ui != null and inventory_ui.has_method("close_panel"):
			inventory_ui.close_panel()
	if map_overlay:
		map_overlay.visible = map_open
		if map_open:
			map_overlay.set_target(story_runtime.current_location())
	joystick_id = -1
	joystick_vector = Vector2.ZERO

func _add_action_button(text: String, pos: Vector2, size: float, callback: Callable) -> void:
	var b = Button.new(); b.text=text; b.position=pos-Vector2(size,size)*0.5; b.size=Vector2(size,size); b.add_theme_font_size_override("font_size",16)
	for state in ["normal","hover","pressed","focus"]:
		var st = StyleBoxFlat.new(); st.bg_color=Color(0.12,0.08,0.19,0.95) if state!="pressed" else Color(0.28,0.17,0.42,0.95); st.border_color=Color(0.95,0.66,0.16); st.set_border_width_all(4); st.corner_radius_top_left=int(size/2); st.corner_radius_top_right=int(size/2); st.corner_radius_bottom_left=int(size/2); st.corner_radius_bottom_right=int(size/2); b.add_theme_stylebox_override(state,st)
	b.pressed.connect(callback); ui.add_child(b)

func _process(delta: float) -> void:
	toast_timer=maxf(0.0,toast_timer-delta)
	if toast_timer<=0.0 and toast_label: toast_label.text=""
	if map_open or (crafting_ui != null and crafting_ui.is_open()) or (inventory_ui != null and inventory_ui.is_open()):
		if hero: hero.set_motion(Vector2.ZERO)
		return
	var dir = Input.get_vector("move_left","move_right","move_up","move_down")
	if joystick_vector.length()>0.12: dir=joystick_vector
	if dir.length()>1.0: dir=dir.normalized()
	if hero:
		var next = hero.position + dir*speed*delta
		if environment and environment.is_walkable(next): hero.position=next
		hero.set_motion(dir)
		_update_poi_hint()
		_update_objective_navigation()
	_update_monsters(delta)
	if Input.is_action_just_pressed("attack"): _attack()
	if Input.is_action_just_pressed("interact"): _interact()

func _input(event: InputEvent) -> void:
	if map_open or (crafting_ui != null and crafting_ui.is_open()) or (inventory_ui != null and inventory_ui.is_open()):
		return
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
	var dead: bool = target.take_damage(hero.attack_damage(18))
	if dead:
		var kind: String = String(target.kind)
		var story_tag: String = String(target.story_tag)
		var boss_id: String = String(target.boss_id)
		monsters.erase(target)
		target.queue_free()
		player_gold += 6
	_grant_combat_xp(10,boss_id)
		var story_advanced: bool = false
		if story_runtime:
			story_advanced = story_runtime.register_kill(story_tag,boss_id)
			if story_tag != "":
				objective_label.text = story_runtime.hud_text()
		if field_quest_active and kind == "wolf" and story_tag == "":
			field_kills += 1
			if field_kills >= 3:
				_show_toast("Área segura por enquanto. Retorne à Guilda.")
			else:
				_show_toast("Lobo derrotado — contrato dos Campos %d/3." % field_kills)
		elif story_advanced:
			_show_toast("Objetivo principal concluído. Próxima etapa atualizada.")
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
	var canonical_id: String = _canonical_story_location(id)
	if story_runtime and canonical_id != "" and story_runtime.try_location(canonical_id):
		objective_label.text = story_runtime.hud_text()
		_show_toast("História principal atualizada: " + label)
		return
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
		"POI_REG001_ROADSIDE_POST": _show_toast("Posto da Estrada — descanso e comércio leve no cinturão rural.")
		"POI_REG001_PILGRIM_MARK": _show_toast("Marco dos Peregrinos — a estrada sul segue para áreas mais perigosas.")
		"POI_REG001_WEST_CAMP": _show_toast("Acampamento do Vale — mercadores e rumores de monstros próximos.")
		"POI_REG001_OLD_RUINS": _show_toast("Ruínas do Caminho Antigo — há sinais de saqueadores.")
		"POI_REG001_SOUTH_WAYSHRINE": _show_toast("Santuário da Estrada Sul — último marco antes da próxima faixa de exploração.")
		"POI_REG001_HUNTER_CAMP": _show_toast("Acampamento dos Caçadores — lobos maiores rondam a mata.")
		"POI_REG001_EAST_QUARRY": _show_toast("Pedreira Abandonada — futura área de recurso e elite.")
		"TRANSITION_FOREST_ANCESTRAL":
			if story_runtime and story_runtime.act1_complete:
				_show_toast("Entrando na Floresta Ancestral...")
				_change_scene_saved("res://scenes/cartoon/ForestAncientCartoon.tscn")
			else:
				_show_toast("A passagem ainda não foi revelada pela história principal.")
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
		var world_data: Dictionary = data.duplicate(true)
		world_data["pos"] = Region.world_from_hub(data["pos"] as Vector2)
		monster.setup(world_data)
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
			player_hp = maxi(0, player_hp - int(hero.reduce_incoming_damage(int(monster.contact_damage))))
			_refresh_stats()
			if player_hp <= 0:
				player_hp = player_max_hp
				hero.position = Region.world_from_hub(Vector2(1150,970))
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

func _grant_combat_xp(base_amount: int,boss_id: String = "") -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null:
		return
	var scaled: int = maxi(base_amount,int(round(float(state.player_level)*1.2)))
	var reward: int = scaled * (3 if boss_id != "" else 1)
	state.gain_xp(reward)
	player_hp = int(state.player_hp)
	player_max_hp = int(state.player_max_hp)

func _refresh_stats() -> void:
	var level_value: int = 1
	var xp_value: int = 0
	var xp_next: int = 0
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		level_value = int(state.player_level)
		xp_value = int(state.player_xp)
		xp_next = int(state.xp_to_next())
	if stats_label:
		stats_label.text = "VALEDOURO\nNv %d   ❤ %d/%d   ◉ %d" % [level_value,player_hp,player_max_hp,player_gold]
	if hud_status != null:
		hud_status.refresh(player_hp,player_max_hp,player_gold,level_value,xp_value,xp_next)

func _spawn_outer_landmarks() -> void:
	for data in ExplorationContent.landmarks():
		var prop: Node2D = PropScript.new()
		prop.setup(data)
		objects.add_child(prop)
		environment.pois.append({
			"id":String(data.get("id","")),
			"label":String(data.get("label","")),
			"pos":data.get("pos",Vector2.ZERO)
		})

func _spawn_outer_encounters() -> void:
	for data in ExplorationContent.encounters():
		var monster: Node2D = MonsterScript.new()
		monster.setup(data)
		objects.add_child(monster)
		monsters.append(monster)


func _spawn_main_story_locations() -> void:
	for data in MainStoryMap.act1_locations():
		var id: String = String(data.get("id",""))
		var label: String = String(data.get("label",""))
		var pos: Vector2 = data.get("pos",Vector2.ZERO)
		if id == "LOC_VAL_GUILD":
			environment.pois.append({"id":id,"label":label,"pos":pos,"quest":String(data.get("quest",""))})
			continue
		var prop: Node2D = PropScript.new()
		prop.setup(data)
		objects.add_child(prop)
		environment.pois.append({
			"id":id,
			"label":label,
			"pos":pos,
			"quest":String(data.get("quest","")),
			"instanced":bool(data.get("instanced",false))
		})


func _spawn_main_story_zones() -> void:
	for data in MainStoryMap.act1_zones():
		var zone: Node2D = StoryZoneScript.new()
		zone.setup(data)
		story_zones.add_child(zone)


func _canonical_story_location(poi_id: String) -> String:
	match poi_id:
		"POI_REG001_GATE_NORTH": return "LOC_VAL_GATE"
		"POI_REG001_GUILD": return "LOC_VAL_GUILD"
		"POI_REG001_RUINS_FIRST_WIND": return "LOC_FIRST_WIND_RUINS"
		_: return poi_id if poi_id.begins_with("LOC_") else ""

func _spawn_main_story_encounters() -> void:
	for data in MainStoryMap.act1_encounters():
		var monster: Node2D = MonsterScript.new()
		monster.setup(data)
		objects.add_child(monster)
		monsters.append(monster)


func _update_objective_navigation() -> void:
	if map_overlay and story_runtime:
		map_overlay.set_target(story_runtime.current_location())
	if not objective_nav_label or not story_runtime or not hero or not environment:
		return
	if story_runtime.act1_complete:
		objective_nav_label.text = "Próximo: Floresta Ancestral"
		return
	var target_id: String = story_runtime.current_location()
	var target_pos: Vector2 = Vector2.ZERO
	var found: bool = false
	for poi in environment.pois:
		if String(poi.get("id","")) == target_id:
			target_pos = poi.get("pos",Vector2.ZERO)
			found = true
			break
	if not found:
		objective_nav_label.text = ""
		return
	var delta_pos: Vector2 = target_pos - hero.position
	var distance: int = int(delta_pos.length())
	var direction: String = _direction_arrow(delta_pos)
	objective_nav_label.text = "%s  %dm  %s" % [direction,distance,story_runtime.title()]

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


func _spawn_region_transitions() -> void:
	for data in MainStoryMap.region_transitions():
		var prop: Node2D = PropScript.new()
		prop.setup(data)
		objects.add_child(prop)
		environment.pois.append({
			"id":String(data.get("id","")),
			"label":String(data.get("label","")),
			"pos":data.get("pos",Vector2.ZERO),
			"quest":String(data.get("quest","")),
			"next_scene":String(data.get("next_scene",""))
		})
