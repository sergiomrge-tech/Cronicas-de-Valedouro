class_name ValedouroCartoonCoastRegion
extends Node2D

const WildlifeScript = preload("res://scripts/cartoon/cartoon_wildlife_director.gd")
var wildlife

const GameLayout = preload("res://scripts/cartoon/cartoon_game_layout.gd")

const Coast = preload("res://scripts/cartoon/coast/coast_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/coast/coast_story_map.gd")
const StreamScript = preload("res://scripts/cartoon/coast/coast_world_stream.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/coast/coast_story_runtime.gd")
const ZoneScript = preload("res://scripts/cartoon/coast/coast_story_zone.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")
const MapOverlayScript = preload("res://scripts/cartoon/coast/coast_map_overlay.gd")
const ExplorationDirectorScript = preload("res://scripts/cartoon/cartoon_exploration_director.gd")
const CraftingUIScript = preload("res://scripts/cartoon/cartoon_crafting_ui.gd")
const ZoomControlsScript = preload("res://scripts/cartoon/cartoon_zoom_controls.gd")
const InventoryUIScript = preload("res://scripts/cartoon/cartoon_inventory_ui.gd")
const HUDStatusScript = preload("res://scripts/cartoon/cartoon_hud_status.gd")

var story_zones: Node2D
var objects: Node2D
var hero: Node2D
var camera: Camera2D
var world_stream: Node2D
var story_runtime: RefCounted
var exploration_director: Node
var crafting_ui: Control
var zoom_controls: Control
var inventory_ui: Control
var hud_status: Control
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
var speed: float = 230.0
var toast_timer: float = 0.0
var player_hp: int = 285
var player_max_hp: int = 285
var player_gold: int = 370

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
	hero.position = Coast.ENTRY_POS
	objects.add_child(hero)

	exploration_director = ExplorationDirectorScript.new()
	exploration_director.name = "ExplorationDirector"
	add_child(exploration_director)
	exploration_director.setup(self,objects,hero,Coast.REGION_ID)
	world_stream = StreamScript.new()
	world_stream.name = "CoastWorldStream"
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
	camera.limit_right = int(Coast.REGION_SIZE.x)
	camera.limit_bottom = int(Coast.REGION_SIZE.y)
	hero.add_child(camera)
	_build_ui()
	hud_status = HUDStatusScript.new()
	hud_status.name = "PlayerStatusHUD"
	ui.add_child(hud_status)
	hud_status.setup("COSTAS E ILHAS PERDIDAS",Color(0.36,0.78,0.84))
	_refresh_stats()
	zoom_controls = ZoomControlsScript.new()
	zoom_controls.name = "ZoomControls"
	ui.add_child(zoom_controls)
	zoom_controls.setup(camera)
	crafting_ui = CraftingUIScript.new()
	crafting_ui.name = "CraftingUI"
	ui.add_child(crafting_ui)
	crafting_ui.setup(self,hero,Coast.REGION_ID)
	inventory_ui = InventoryUIScript.new()
	inventory_ui.name = "InventoryUI"
	ui.add_child(inventory_ui)
	inventory_ui.setup(self,hero,true)
	wildlife = WildlifeScript.new()
	wildlife.name = "WildlifeDirector"
	add_child(wildlife)
	wildlife.setup(self,Coast)
	_bind_campaign_save()
	_refresh_objective()

func _bind_campaign_save() -> void:
	if get_tree().current_scene != self:
		return
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null:
		return
	state.bind_scene("res://scenes/cartoon/CoastLostIslandsCartoon.tscn",self,hero,story_runtime,52,285,370,[])
	_refresh_stats()

func _change_scene_saved(path: String) -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		state.prepare_transition(path)
	get_tree().change_scene_to_file(path)

func _add_poi_prop(data: Dictionary) -> void:
	var prop: Node2D = PropScript.new()
	prop.setup(data)
	objects.add_child(prop)
	pois.append({"id":String(data.get("id","")),"label":String(data.get("label","")),"pos":data.get("pos",Vector2.ZERO),"quest":String(data.get("quest",""))})

func _spawn_monster(data: Dictionary) -> void:
	var monster: Node2D = MonsterScript.new()
	monster.setup(data)
	objects.add_child(monster)
	monsters.append(monster)

func _hero_can_move(point: Vector2) -> bool:
	return Coast.in_region(point,70.0)

func _process(delta: float) -> void:
	var layout = get_node_or_null("HUD/GameLayout")
	if layout != null and layout.is_blocked():
		if hero != null: hero.set_motion(Vector2.ZERO)
		return
	toast_timer = maxf(0.0,toast_timer-delta)
	if toast_timer <= 0.0 and toast_label:
		toast_label.text = ""
	if map_open or (crafting_ui != null and crafting_ui.is_open()) or (inventory_ui != null and inventory_ui.is_open()):
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
		if hero.dodge_t<=0 and _hero_can_move(next):
			hero.position = next
		hero.set_motion(dir)
		_update_poi_hint()
		_update_navigation()
	_update_monsters(delta)
	if Input.is_action_just_pressed("attack"):
		_attack()
	if Input.is_action_just_pressed("interact"):
		_interact()

func _unhandled_input(event: InputEvent) -> void:
	if map_open or (crafting_ui != null and crafting_ui.is_open()) or (inventory_ui != null and inventory_ui.is_open()):
		return
	if event is InputEventScreenTouch:
		if event.pressed and GameLayout.can_start_movement(self,event.position) and joystick_id < 0:
			joystick_id = event.index
			joystick_origin = event.position
			joystick_vector = Vector2.ZERO
		elif not event.pressed and event.index == joystick_id:
			joystick_id = -1
			joystick_vector = Vector2.ZERO
	elif event is InputEventScreenDrag and event.index == joystick_id:
		joystick_vector = (event.position-joystick_origin).limit_length(80.0)/80.0

func _attack() -> void:
	if hero != null and hero.dodge_t>0: return
	if hero == null:
		return
	if wildlife != null and wildlife.attack(): return
	hero.trigger_attack()
	var target: Node2D = _nearest_monster(hero.combat_range(116.0))
	if target == null:
		_show_toast("Nenhum inimigo ao alcance.")
		return
	if not _can_damage_monster(target): return
	if hero.spell_mode:
		hero.launch_magic(self,target,28)
		return
	_damage_monster(target,hero.attack_damage(28))

func _can_damage_monster(target: Node2D, feedback: bool = true) -> bool:
	if not is_instance_valid(target) or target.is_queued_for_deletion() or target.hp<=0 or not monsters.has(target): return false
	var story_tag: String = String(target.story_tag)
	var boss_id: String = String(target.boss_id)
	if story_tag == "hollow_fleet" and story_runtime.current_id != "Q_MS06_HOLLOW_FLEET":
		if feedback: _show_toast("A Frota Oca ainda navega fora do alcance desta missão.")
		return false
	if boss_id == "BOSS_GENERAL_MARE_OCA_001" and story_runtime.current_id != "Q_MS06_GENERAL_TIDE":
		if feedback: _show_toast("O Observatório ainda protege o General da Maré Oca.")
		return false
	return true

func _damage_monster(target: Node2D, amount: int) -> bool:
	if not _can_damage_monster(target): return false
	var story_tag: String = String(target.story_tag)
	var boss_id: String = String(target.boss_id)
	var dead: bool = target.take_damage(amount)
	if not dead:
		return true
	monsters.erase(target)
	target.queue_free()
	player_gold += 16
	_grant_combat_xp(65,boss_id)
	var advanced: bool = false
	if story_tag == "hollow_fleet":
		advanced = story_runtime.register_fleet_kill(story_tag)
	elif boss_id != "":
		advanced = story_runtime.register_boss(boss_id)
	_refresh_stats()
	_refresh_objective()
	if advanced:
		_show_toast("Objetivo principal concluído. A próxima rota foi revelada.")
	else:
		_show_toast("Inimigo derrotado. +16 ouro")
	return true

func _interact() -> void:
	if hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,215.0)
	if poi.is_empty():
		if exploration_director != null and exploration_director.try_interact():
			return
		_show_toast("Nada para interagir aqui.")
		return
	var id: String = String(poi.get("id",""))
	var label: String = String(poi.get("label","Local"))
	if story_runtime.interact(id):
		_refresh_objective()
		_show_toast("História principal atualizada: "+label)
		return
	match id:
		"LOC_MIST_PORT": _show_toast("As rotas marítimas mudam sob as brumas.")
		"LOC_TWIN_LIGHTHOUSE": _show_toast("O Farol Gêmeo revela caminhos invisíveis no mar.")
		"LOC_SUNKEN_TEMPLE": _show_toast("O Astrolábio das Marés aguarda dentro do templo.")
		"LOC_LOST_ISLAND_SHIPYARD": _show_toast("A Frota Oca bloqueia o estaleiro.")
		"LOC_TIDAL_OBSERVATORY": _show_toast("O General da Maré Oca controla as correntes.")
		"POI_COAST_CORRUPTED_ROUTE":
			if story_runtime.act6_complete:
				_show_toast("Entrando nas Terras Corrompidas...")
				_change_scene_saved("res://scenes/cartoon/CorruptedLandsCartoon.tscn")
			else:
				_show_toast("O caminho permanece escondido pela Maré Oca.")
		_:
			_show_toast(label)

func _update_monsters(delta: float) -> void:
	var layout = get_node_or_null("HUD/GameLayout")
	if layout != null and layout.is_blocked(): return
	if hero == null:
		return
	for monster in monsters.duplicate():
		if not is_instance_valid(monster):
			monsters.erase(monster)
			continue
		var dist: float = monster.position.distance_to(hero.position)
		if dist < 340.0 and dist > 54.0 and monster.can_chase():
			var dir: Vector2 = (hero.position-monster.position).normalized()
			var next: Vector2 = monster.position+dir*float(monster.move_speed)*delta
			if Coast.in_region(next,70.0):
				monster.position = next
		if monster.advance_contact(hero,delta,56.0):
			hero.trigger_hurt()
			player_hp = maxi(0,player_hp-int(hero.reduce_incoming_damage(int(monster.contact_damage))))
			_refresh_stats()
			if player_hp <= 0:
				hero.trigger_fall()
				player_hp = player_max_hp
				hero.position = Coast.ENTRY_POS
				_refresh_stats()
				_show_toast("Os marinheiros do Porto das Brumas resgataram você.")

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
	GameLayout.build(self,MapOverlayScript,"nav_label")


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
	var level_value: int = 52
	var xp_value: int = 0
	var xp_next: int = 0
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		level_value = int(state.player_level)
		xp_value = int(state.player_xp)
		xp_next = int(state.xp_to_next())
	if stats_label:
		stats_label.text = "COSTAS E ILHAS PERDIDAS\nNv %d   ❤ %d/%d   ◉ %d" % [level_value,player_hp,player_max_hp,player_gold]
	if hud_status != null:
		hud_status.refresh(player_hp,player_max_hp,player_gold,level_value,xp_value,xp_next)

func _refresh_objective() -> void:
	if objective_label and story_runtime:
		objective_label.text = story_runtime.hud_text()
	if map_overlay and story_runtime:
		map_overlay.set_target(story_runtime.current_location())
	_update_navigation()

func _update_poi_hint() -> void:
	if poi_label == null or hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,215.0)
	if not poi.is_empty():
		poi_label.text = "◆ "+String(poi.get("label",""))+"  •  USAR"
	elif exploration_director != null:
		poi_label.text = exploration_director.hint_text()
	else:
		poi_label.text = ""

func _target_position() -> Vector2:
	if story_runtime == null:
		return Vector2.ZERO
	var target_id: String = story_runtime.current_location()
	for poi in pois:
		if String(poi.get("id","")) == target_id:
			return poi.get("pos",Vector2.ZERO)
	return Vector2.ZERO

func _update_navigation() -> void:
	if nav_label == null or hero == null or story_runtime == null:
		return
	if story_runtime.act6_complete:
		nav_label.text = "Próximo destino: Terras Corrompidas"
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
