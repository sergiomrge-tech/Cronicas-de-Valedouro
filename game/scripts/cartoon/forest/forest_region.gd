class_name ValedouroCartoonForestRegion
extends Node2D

const WildlifeScript = preload("res://scripts/cartoon/cartoon_wildlife_director.gd")
var wildlife

const Difficulty = preload("res://scripts/cartoon/cartoon_difficulty.gd")
const GameLayout = preload("res://scripts/cartoon/cartoon_game_layout.gd")

const Forest = preload("res://scripts/cartoon/forest/forest_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/forest/forest_story_map.gd")
const StreamScript = preload("res://scripts/cartoon/forest/forest_world_stream.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/forest/forest_story_runtime.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")
const StoryZoneScript = preload("res://scripts/cartoon/forest/forest_story_zone.gd")
const MapOverlayScript = preload("res://scripts/cartoon/forest/forest_map_overlay.gd")
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
var objective_nav_label: Label
var toast_label: Label
var map_overlay: Control
var map_open: bool = false

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

	exploration_director = ExplorationDirectorScript.new()
	exploration_director.name = "ExplorationDirector"
	add_child(exploration_director)
	exploration_director.setup(self,objects,hero,Forest.REGION_ID)

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
	hud_status = HUDStatusScript.new()
	hud_status.name = "PlayerStatusHUD"
	ui.add_child(hud_status)
	hud_status.setup("FLORESTA ANCESTRAL",Color(0.43,0.78,0.34))
	_refresh_stats()
	zoom_controls = ZoomControlsScript.new()
	zoom_controls.name = "ZoomControls"
	ui.add_child(zoom_controls)
	zoom_controls.setup(camera)
	crafting_ui = CraftingUIScript.new()
	crafting_ui.name = "CraftingUI"
	ui.add_child(crafting_ui)
	crafting_ui.setup(self,hero,Forest.REGION_ID)
	inventory_ui = InventoryUIScript.new()
	inventory_ui.name = "InventoryUI"
	ui.add_child(inventory_ui)
	inventory_ui.setup(self,hero,true)
	wildlife = WildlifeScript.new()
	wildlife.name = "WildlifeDirector"
	add_child(wildlife)
	wildlife.setup(self,Forest)
	_bind_campaign_save()
	_refresh_objective()

func _bind_campaign_save() -> void:
	if get_tree().current_scene != self:
		return
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null:
		return
	state.bind_scene("res://scenes/cartoon/ForestAncientCartoon.tscn",self,hero,story_runtime,8,145,80,[])
	_refresh_stats()

func _change_scene_saved(path: String) -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		state.prepare_transition(path)
	get_tree().change_scene_to_file(path)

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
	monster.setup(Difficulty.monster_data(data,Forest.REGION_ID))
	objects.add_child(monster)
	monsters.append(monster)

func _hero_can_move(point: Vector2) -> bool:
	return Forest.in_region(point,70.0)

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
	if hero != null and not hero.spell_mode and hero.melee_cooldown>0: return
	if hero != null and hero.bow_equipped and not hero.spell_mode and hero.bow_cooldown>0: return
	if hero != null and hero.dodge_t>0: return
	if hero == null:
		return
	if wildlife != null and wildlife.attack(): return
	hero.trigger_attack()
	var target: Node2D = _nearest_monster(hero.combat_range(112.0))
	if target == null:
		_show_toast("Nenhum inimigo ao alcance.")
		return
	if not _can_damage_monster(target): return
	if hero.spell_mode:
		hero.launch_magic(self,target,20)
		return
	if hero.bow_equipped:
		hero.launch_arrow(self,target,20)
		return
	_damage_monster(target,hero.attack_damage(20))

func _can_damage_monster(target: Node2D, feedback: bool = true) -> bool:
	if not is_instance_valid(target) or target.is_queued_for_deletion() or target.hp<=0 or not monsters.has(target): return false
	var target_tag: String = String(target.story_tag)
	var target_boss: String = String(target.boss_id)
	if target_tag == "forest_defense" and story_runtime.current_id != "Q_MS02_RANGERS":
		if feedback: _show_toast("A corrupção recua entre as árvores. Esta luta pertence a outra etapa da história.")
		return false
	if target_boss == "BOSS_RAIZ_OCA_001" and story_runtime.current_id != "Q_MS02_HOLLOW_ROOT":
		if feedback: _show_toast("Raízes antigas protegem o Arauto. A história ainda não abriu esta batalha.")
		return false
	return true

func _damage_monster(target: Node2D, amount: int) -> bool:
	if not _can_damage_monster(target): return false
	var combat_state = get_node_or_null("/root/CartoonPlayerState")
	amount = Difficulty.outgoing(amount,combat_state.player_level if combat_state!=null else 1,target.level)
	if target.is_in_group("cartoon_elite_demons"): return target.receive_combat_damage(amount)
	var dead: bool = target.take_damage(amount)
	if not dead:
		return true
	var story_tag: String = String(target.story_tag)
	var kind: String = String(target.kind)
	var boss_id: String = String(target.boss_id)
	monsters.erase(target)
	target.queue_free()
	player_gold += 8
	_grant_combat_xp(18,boss_id,target.level)
	var loot_text: String = _award_combat_loot(kind,boss_id,int(target.level))
	var advanced: bool = false
	if story_runtime:
		if story_tag == "forest_defense":
			advanced = story_runtime.register_defense_kill(story_tag)
		elif boss_id != "":
			advanced = story_runtime.register_boss(boss_id)
	_refresh_stats()
	_refresh_objective()
	if advanced:
		_show_toast("Objetivo principal concluído. A trilha seguinte foi revelada."+("\n"+loot_text if loot_text!="" else ""))
	else:
		_show_toast("Criatura derrotada. +8 ouro"+("\n"+loot_text if loot_text!="" else ""))
	return true

func _interact() -> void:
	if hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,185.0)
	if poi.is_empty():
		if exploration_director != null and exploration_director.try_interact():
			return
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
		"POI_FOREST_VEIL_MARK":
			if story_runtime.act2_complete:
				_show_toast("Seguindo a segunda linha do mapa para Edravar...")
				_change_scene_saved("res://scenes/cartoon/DesertEdravarCartoon.tscn")
			else:
				_show_toast("A rota para Edravar ainda não foi revelada.")
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
		if dist < 320.0 and dist > 52.0 and monster.can_chase():
			var dir: Vector2 = (hero.position-monster.position).normalized()
			var next: Vector2 = monster.position+dir*float(monster.move_speed)*delta
			if Forest.in_region(next,70.0):
				monster.position = next
		if monster.advance_contact(hero,delta,54.0):
			hero.trigger_hurt()
			player_hp = maxi(0,player_hp-int(hero.reduce_incoming_damage(int(monster.contact_damage),monster.level)))
			_refresh_stats()
			if player_hp <= 0:
				hero.trigger_fall()
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
	GameLayout.build(self,MapOverlayScript,"objective_nav_label")


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


func _award_combat_loot(kind: String,boss_id: String,enemy_level: int) -> String:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null:
		return ""
	var result: Dictionary = state.award_enemy_loot("REG_002_FLORESTA_ANCESTRAL",kind,enemy_level,boss_id!="",false)
	return String(result.get("summary",""))

func _grant_combat_xp(base_amount: int,boss_id: String = "",enemy_level: int = 1) -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null:
		return
	var scaled: int = base_amount+2*maxi(0,enemy_level-1)
	var reward: int = scaled * (3 if boss_id != "" else 1)
	state.gain_xp(reward)
	player_hp = int(state.player_hp)
	player_max_hp = int(state.player_max_hp)

func _refresh_stats() -> void:
	var level_value: int = 8
	var xp_value: int = 0
	var xp_next: int = 0
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		level_value = int(state.player_level)
		xp_value = int(state.player_xp)
		xp_next = int(state.xp_to_next())
	if stats_label:
		stats_label.text = "FLORESTA ANCESTRAL\nNv %d   ❤ %d/%d   ◉ %d" % [level_value,player_hp,player_max_hp,player_gold]
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
	var poi: Dictionary = _nearest_poi(hero.position,190.0)
	if not poi.is_empty():
		poi_label.text = "◆ "+String(poi.get("label",""))+"  •  USAR"
	elif exploration_director != null:
		poi_label.text = exploration_director.hint_text()
	else:
		poi_label.text = ""

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
