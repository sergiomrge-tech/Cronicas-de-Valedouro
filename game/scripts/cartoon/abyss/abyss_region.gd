class_name ValedouroCartoonAbyssRegion
extends Node2D

const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
const Difficulty = preload("res://scripts/cartoon/cartoon_difficulty.gd")
const GameLayout = preload("res://scripts/cartoon/cartoon_game_layout.gd")

const Abyss = preload("res://scripts/cartoon/abyss/abyss_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/abyss/abyss_story_map.gd")
const StreamScript = preload("res://scripts/cartoon/abyss/abyss_world_stream.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/abyss/abyss_story_runtime.gd")
const ZoneScript = preload("res://scripts/cartoon/abyss/abyss_story_zone.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")
const MapOverlayScript = preload("res://scripts/cartoon/abyss/abyss_map_overlay.gd")
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
var choice_panel: PanelContainer
var joystick_id: int = -1
var joystick_origin: Vector2 = Vector2.ZERO
var joystick_vector: Vector2 = Vector2.ZERO
var speed: float = 220.0
var toast_timer: float = 0.0
var player_hp: int = 400
var player_max_hp: int = 400
var player_gold: int = 600

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
	hero.position = Abyss.ENTRY_POS
	objects.add_child(hero)

	exploration_director = ExplorationDirectorScript.new()
	exploration_director.name = "ExplorationDirector"
	add_child(exploration_director)
	exploration_director.setup(self,objects,hero,Abyss.REGION_ID)
	world_stream = StreamScript.new()
	world_stream.name = "AbyssWorldStream"
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
	camera.limit_right = int(Abyss.REGION_SIZE.x)
	camera.limit_bottom = int(Abyss.REGION_SIZE.y)
	hero.add_child(camera)
	_build_ui()
	hud_status = HUDStatusScript.new()
	hud_status.name = "PlayerStatusHUD"
	ui.add_child(hud_status)
	hud_status.setup("CORAÇÃO ABISSAL",Color(0.62,0.34,0.80))
	_refresh_stats()
	zoom_controls = ZoomControlsScript.new()
	zoom_controls.name = "ZoomControls"
	ui.add_child(zoom_controls)
	zoom_controls.setup(camera)
	crafting_ui = CraftingUIScript.new()
	crafting_ui.name = "CraftingUI"
	ui.add_child(crafting_ui)
	crafting_ui.setup(self,hero,Abyss.REGION_ID)
	inventory_ui = InventoryUIScript.new()
	inventory_ui.name = "InventoryUI"
	ui.add_child(inventory_ui)
	inventory_ui.setup(self,hero,true)
	_bind_campaign_save()
	_refresh_objective()

func _bind_campaign_save() -> void:
	if get_tree().current_scene != self:
		return
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null:
		return
	state.bind_scene("res://scenes/cartoon/AbyssHeartCartoon.tscn",self,hero,story_runtime,90,400,600,[])
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
	monster.setup(Difficulty.monster_data(data,Abyss.REGION_ID))
	objects.add_child(monster)
	monsters.append(monster)

func _hero_can_move(point: Vector2) -> bool:
	return Abyss.in_region(point,70.0)

func _process(delta: float) -> void:
	var layout = get_node_or_null("HUD/GameLayout")
	if layout != null and layout.is_blocked():
		if hero != null: hero.set_motion(Vector2.ZERO)
		return
	toast_timer = maxf(0.0,toast_timer-delta)
	if toast_timer <= 0.0 and toast_label:
		toast_label.text = ""
	if map_open or (choice_panel and choice_panel.visible) or (crafting_ui != null and crafting_ui.is_open()) or (inventory_ui != null and inventory_ui.is_open()):
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
	if map_open or (choice_panel and choice_panel.visible) or (crafting_ui != null and crafting_ui.is_open()) or (inventory_ui != null and inventory_ui.is_open()):
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
	hero.trigger_attack()
	var target: Node2D = _nearest_monster(hero.combat_range(120.0))
	if target == null:
		_show_toast("Nenhum inimigo ao alcance.")
		return
	if not _can_damage_monster(target): return
	if hero.spell_mode:
		hero.launch_magic(self,target,34)
		return
	if hero.bow_equipped:
		hero.launch_arrow(self,target,34)
		return
	_damage_monster(target,hero.attack_damage(34))

func _can_damage_monster(target: Node2D, feedback: bool = true) -> bool:
	if not is_instance_valid(target) or target.is_queued_for_deletion() or target.hp<=0 or not monsters.has(target): return false
	var kind: String = String(target.kind)
	var boss_id: String = String(target.boss_id)
	if boss_id == "BOSS_CARTOGRAFO_VAZIO_001" and story_runtime.current_id != "Q_MS08_CARTOGRAPHER":
		if feedback: _show_toast("O Arquivo do Vazio ainda está fechado.")
		return false
	if boss_id == "BOSS_AZHAREL_001" and story_runtime.current_id != "Q_MS08_AZHAREL":
		if feedback: _show_toast("O Trono ainda não reconhece o Segundo Viajante.")
		return false
	return true

func _damage_monster(target: Node2D, amount: int) -> bool:
	if not _can_damage_monster(target): return false
	var combat_state = get_node_or_null("/root/CartoonPlayerState")
	amount = Difficulty.outgoing(amount,combat_state.player_level if combat_state!=null else 1,target.level)
	if target.is_in_group("cartoon_elite_demons"): return target.receive_combat_damage(amount)
	var boss_id: String = String(target.boss_id)
	var dead: bool = target.take_damage(amount)
	if not dead:
		return true
	monsters.erase(target)
	target.queue_free()
	player_gold += 25
	_grant_combat_xp(120,boss_id,target.level)
	var loot_text: String = _award_combat_loot(kind,boss_id,int(target.level))
	var advanced: bool = false
	if boss_id != "":
		advanced = story_runtime.register_boss(boss_id)
	_refresh_stats()
	_refresh_objective()
	if advanced:
		_show_toast("A história avançou."+("\n"+loot_text if loot_text!="" else ""))
	else:
		_show_toast("Inimigo derrotado. +25 ouro"+("\n"+loot_text if loot_text!="" else ""))
	return true

func _interact() -> void:
	if hero == null:
		return
	var poi: Dictionary = _nearest_poi(hero.position,225.0)
	if poi.is_empty():
		if exploration_director != null and exploration_director.try_interact():
			return
		_show_toast("Nada para interagir aqui.")
		return
	var id: String = String(poi.get("id",""))
	var label: String = String(poi.get("label","Local"))
	if story_runtime.current_id == "Q_MS08_CHOICE" and id == "LOC_EARTH_GATE":
		_show_choice()
		return
	if story_runtime.interact(id):
		_refresh_objective()
		_show_toast("História principal atualizada: "+label)
		if story_runtime.current_id == "Q_MS08_CHOICE":
			_show_choice()
		return
	match id:
		"LOC_LAST_MAP_GATE": _show_toast("As oito linhas convergem no mesmo portão.")
		"LOC_HALL_LOST_PATHS": _show_toast("Caminhos de vidas possíveis se abrem e desaparecem.")
		"LOC_VOID_ARCHIVE": _show_toast("Memórias descartadas por Adrian formam o Cartógrafo Vazio.")
		"LOC_EMPTY_THRONE_ANTECHAMBER": _show_toast("Adrian aguarda além da antecâmara.")
		"LOC_EMPTY_THRONE": _show_toast("A Coroa Oca ocupa o centro do trono.")
		"LOC_EARTH_GATE": _show_toast("O caminho entre Elyndor e a Terra está diante de você.")
		_: _show_toast(label)

func _show_choice() -> void:
	if choice_panel:
		choice_panel.visible = true
		joystick_id = -1
		joystick_vector = Vector2.ZERO

func _choose_ending(choice: String) -> void:
	if story_runtime.choose_ending(choice):
		choice_panel.visible = false
		_refresh_objective()
		_show_toast("Escolha registrada: "+story_runtime.ending)

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
		if dist < 350.0 and dist > 54.0 and monster.can_chase():
			var dir: Vector2 = (hero.position-monster.position).normalized()
			var next: Vector2 = monster.position+dir*float(monster.move_speed)*delta
			if Abyss.in_region(next,70.0):
				monster.position = next
		if monster.advance_contact(hero,delta,58.0):
			hero.trigger_hurt()
			player_hp = maxi(0,player_hp-int(hero.reduce_incoming_damage(int(monster.contact_damage),monster.level)))
			_refresh_stats()
			if player_hp <= 0:
				hero.trigger_fall()
				player_hp = player_max_hp
				hero.position = Abyss.ENTRY_POS
				_refresh_stats()
				_show_toast("O mapa devolveu você ao Portão do Último Mapa.")

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
	_build_choice_panel()

func _build_choice_panel() -> void:
	choice_panel = PanelContainer.new()
	choice_panel.name = "EndingChoicePanel"
	choice_panel.visible = false
	choice_panel.add_theme_stylebox_override("panel",UISkin.box(UISkin.INK,UISkin.GOLD))
	ui.add_child(choice_panel)
	var body: Control = Control.new()
	body.name = "EndingChoiceContent"
	body.custom_minimum_size = Vector2(476,236)
	choice_panel.add_child(body)
	var title: Label = UISkin.label("ENTRE DOIS MUNDOS",22)
	title.position = Vector2(24,22)
	title.size = Vector2(428,32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(title)
	var note: Label = UISkin.label("Escolha o destino do Segundo Viajante",14,UISkin.MUTED)
	note.position = Vector2(24,65)
	note.size = Vector2(428,26)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(note)
	var earth: Button = Button.new()
	earth.name = "ReturnToEarthButton"
	earth.text = "RETORNAR À TERRA"
	earth.position = Vector2(24,116)
	earth.size = Vector2(428,48)
	UISkin.button(earth)
	earth.pressed.connect(func(): _choose_ending("return"))
	body.add_child(earth)
	var stay: Button = Button.new()
	stay.name = "StayInElyndorButton"
	stay.text = "PERMANECER EM ELYNDOR"
	stay.position = Vector2(24,174)
	stay.size = Vector2(428,48)
	UISkin.button(stay)
	stay.pressed.connect(func(): _choose_ending("stay"))
	body.add_child(stay)
	UISkin.bind(choice_panel,Vector2(480,240),"center",true)

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
	var result: Dictionary = state.award_enemy_loot("REG_008_CORACAO_ABISSAL",kind,enemy_level,boss_id!="",false)
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
	var level_value: int = 90
	var xp_value: int = 0
	var xp_next: int = 0
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		level_value = int(state.player_level)
		xp_value = int(state.player_xp)
		xp_next = int(state.xp_to_next())
	if stats_label:
		stats_label.text = "CORAÇÃO ABISSAL\nNv %d   ❤ %d/%d   ◉ %d" % [level_value,player_hp,player_max_hp,player_gold]
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
	var poi: Dictionary = _nearest_poi(hero.position,225.0)
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
	if story_runtime.campaign_complete:
		nav_label.text = "Campanha concluída"
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
