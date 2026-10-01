class_name ValedouroCartoonMarshRegion
extends Node2D

const WildlifeScript = preload("res://scripts/cartoon/cartoon_wildlife_director.gd")
var wildlife

const GameLayout = preload("res://scripts/cartoon/cartoon_game_layout.gd")

const Marsh = preload("res://scripts/cartoon/marsh/marsh_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/marsh/marsh_story_map.gd")
const StreamScript = preload("res://scripts/cartoon/marsh/marsh_world_stream.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/marsh/marsh_story_runtime.gd")
const ZoneScript = preload("res://scripts/cartoon/marsh/marsh_story_zone.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")
const MapOverlayScript = preload("res://scripts/cartoon/marsh/marsh_map_overlay.gd")
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
var speed: float = 225.0
var toast_timer: float = 0.0
var player_hp: int = 205
var player_max_hp: int = 205
var player_gold: int = 210

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
	hero.position = Marsh.ENTRY_POS
	objects.add_child(hero)

	exploration_director = ExplorationDirectorScript.new()
	exploration_director.name = "ExplorationDirector"
	add_child(exploration_director)
	exploration_director.setup(self,objects,hero,Marsh.REGION_ID)

	world_stream = StreamScript.new()
	world_stream.name = "MarshWorldStream"
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
	camera.limit_right = int(Marsh.REGION_SIZE.x)
	camera.limit_bottom = int(Marsh.REGION_SIZE.y)
	hero.add_child(camera)

	_build_ui()
	hud_status = HUDStatusScript.new()
	hud_status.name = "PlayerStatusHUD"
	ui.add_child(hud_status)
	hud_status.setup("PÂNTANOS SOMBRIOS",Color(0.34,0.76,0.62))
	_refresh_stats()
	zoom_controls = ZoomControlsScript.new()
	zoom_controls.name = "ZoomControls"
	ui.add_child(zoom_controls)
	zoom_controls.setup(camera)
	crafting_ui = CraftingUIScript.new()
	crafting_ui.name = "CraftingUI"
	ui.add_child(crafting_ui)
	crafting_ui.setup(self,hero,Marsh.REGION_ID)
	inventory_ui = InventoryUIScript.new()
	inventory_ui.name = "InventoryUI"
	ui.add_child(inventory_ui)
	inventory_ui.setup(self,hero,true)
	wildlife = WildlifeScript.new()
	wildlife.name = "WildlifeDirector"
	add_child(wildlife)
	wildlife.setup(self,Marsh)
	_bind_campaign_save()
	_refresh_objective()

func _bind_campaign_save() -> void:
	if get_tree().current_scene != self:
		return
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null:
		return
	state.bind_scene("res://scenes/cartoon/MarshDarkCartoon.tscn",self,hero,story_runtime,28,205,210,[])
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
		if Marsh.in_region(next,70.0):
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
	if hero == null:
		return
	if wildlife != null and wildlife.attack(): return
	hero.trigger_attack()
	var target: Node2D = _nearest_monster(114.0)
	if target == null:
		_show_toast("Nenhum inimigo ao alcance.")
		return
	var boss_id: String = String(target.boss_id)
	if boss_id == "BOSS_DAMA_JUNCOS_001" and story_runtime.current_id != "Q_MS04_LADY_REEDS":
		_show_toast("O vínculo ritual ainda protege a Dama dos Juncos.")
		return
	var dead: bool = target.take_damage(hero.attack_damage(24))
	if not dead:
		return
	monsters.erase(target)
	target.queue_free()
	player_gold += 12
	_grant_combat_xp(38,boss_id)
	var advanced: bool = false
	if boss_id != "":
		advanced = story_runtime.register_boss(boss_id)
	_refresh_stats()
	_refresh_objective()
	if advanced:
		_show_toast("A Dama dos Juncos caiu. A Comporta dos Ecos pode ser fechada.")
	else:
		_show_toast("Criatura derrotada. +12 ouro")

func _interact() -> void:
	if hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,205.0)
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
		"LOC_MARSH_STILT_VILLAGE":
			_show_toast("As lanternas da vila oscilam sobre a água negra.")
		"LOC_DROWNED_BELL_TOWER":
			_show_toast("O sino submerso revela canais escondidos quando desperta.")
		"LOC_FLOODED_MONASTERY":
			_show_toast("Os registros do mosteiro guardam os nomes dos desaparecidos.")
		"LOC_REED_SANCTUM":
			_show_toast("Os juncos se abrem para um santuário antigo.")
		"LOC_REED_THRONE":
			_show_toast("O Trono dos Juncos pulsa com Eco corrompido.")
		"POI_MARSH_FROST_ROUTE":
			if story_runtime.act4_complete:
				_show_toast("Seguindo o fluxo do Eco para o Norte Gelado...")
				_change_scene_saved("res://scenes/cartoon/FrostMountainsCartoon.tscn")
			else:
				_show_toast("A rota do norte ainda está encoberta pela névoa.")
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
			if Marsh.in_region(next,70.0):
				monster.position = next
		if dist <= 56.0 and monster.can_hit():
			monster.mark_hit()
			player_hp = maxi(0,player_hp-int(hero.reduce_incoming_damage(int(monster.contact_damage))))
			_refresh_stats()
			if player_hp <= 0:
				player_hp = player_max_hp
				hero.position = Marsh.ENTRY_POS
				_refresh_stats()
				_show_toast("Moradores da Vila das Lanternas resgataram você.")

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
	var level_value: int = 28
	var xp_value: int = 0
	var xp_next: int = 0
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		level_value = int(state.player_level)
		xp_value = int(state.player_xp)
		xp_next = int(state.xp_to_next())
	if stats_label:
		stats_label.text = "PÂNTANOS SOMBRIOS\nNv %d   ❤ %d/%d   ◉ %d" % [level_value,player_hp,player_max_hp,player_gold]
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
	var poi: Dictionary = _nearest_poi(hero.position,210.0)
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
	if story_runtime.act4_complete:
		nav_label.text = "Próximo destino: Norte Gelado"
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
