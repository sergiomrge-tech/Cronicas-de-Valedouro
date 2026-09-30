extends Node

const SAVE_PATH: String = "user://valedouro_cartoon_profile_v1.json"
const SAVE_VERSION: int = 2
const DEFAULT_SCENE: String = "res://scenes/cartoon/ValedouroCartoonHub.tscn"
const VALID_SCENES: Array[String] = [
	DEFAULT_SCENE,
	"res://scenes/cartoon/ForestAncientCartoon.tscn",
	"res://scenes/cartoon/DesertEdravarCartoon.tscn",
	"res://scenes/cartoon/MarshDarkCartoon.tscn",
	"res://scenes/cartoon/FrostMountainsCartoon.tscn",
	"res://scenes/cartoon/ValedouroSiegeCartoon.tscn",
	"res://scenes/cartoon/CoastLostIslandsCartoon.tscn",
	"res://scenes/cartoon/CorruptedLandsCartoon.tscn",
	"res://scenes/cartoon/AbyssHeartCartoon.tscn"
]
const STORY_STATE_KEYS: Array[String] = [
	"current_id","act1_complete","wolf_kills",
	"defend_kills","shrines_active","act2_complete",
	"escort_started","act3_complete","act4_complete",
	"act5_region_complete","siege_pending",
	"fleet_kills","act6_complete",
	"destroyed_obelisks","act7_complete",
	"campaign_complete","ending",
	"complete","kills","required_kills"
]

var materials: Dictionary = {}
var crafted: Dictionary = {}
var equipped_weapon: Dictionary = {"id":"starter_blade","label":"Espada de Viagem","tier":0,"attack":0,"slot":"weapon"}
var equipped_armor: Dictionary = {"id":"starter_armor","label":"Túnica de Viagem","tier":0,"defense":0,"slot":"armor"}
var camera_zoom: float = 1.0

# Save global da campanha Cartoon v0.16.
var campaign_started: bool = false
var current_scene: String = DEFAULT_SCENE
var player_position: Vector2 = Vector2.ZERO
var player_hp: int = 120
var player_max_hp: int = 120
var player_gold: int = 35
var player_level: int = 1
var player_xp: int = 0
var story_progress: Dictionary = {}
var scene_extras: Dictionary = {}

var _active_scene: String = ""
var _active_host: Node = null
var _active_hero: Node2D = null
var _active_story = null
var _active_extra_keys: Array = []
var _autosave_elapsed: float = 0.0

func _ready() -> void:
	load_profile()
	set_process(true)

func _process(delta: float) -> void:
	if _active_scene == "" or _active_host == null or _active_hero == null:
		return
	if not is_instance_valid(_active_host) or not is_instance_valid(_active_hero):
		_clear_active_binding()
		return
	_autosave_elapsed += delta
	if _autosave_elapsed >= 2.5:
		_autosave_elapsed = 0.0
		save_profile()

func recipes_for(region_id: String) -> Array[Dictionary]:
	match region_id:
		"REG_002_FLORESTA_ANCESTRAL":
			return [
				{"id":"WPN_FOREST_01","label":"Lâmina de Carvalho Vivo","slot":"weapon","tier":1,"attack":4,"material":"Seiva Ancestral","cost":3},
				{"id":"ARM_FOREST_01","label":"Couraça dos Guardas Verdes","slot":"armor","tier":1,"defense":2,"material":"Seiva Ancestral","cost":2}
			]
		"REG_003_DESERTO_RUINAS":
			return [
				{"id":"WPN_DESERT_02","label":"Sabre de Âmbar Negro","slot":"weapon","tier":2,"attack":7,"material":"Âmbar Negro","cost":3},
				{"id":"ARM_DESERT_02","label":"Armadura das Dunas","slot":"armor","tier":2,"defense":3,"material":"Âmbar Negro","cost":2}
			]
		"REG_004_PANTANOS_SOMBRIOS":
			return [
				{"id":"WPN_MARSH_03","label":"Espada dos Juncos","slot":"weapon","tier":3,"attack":10,"material":"Fibra de Junco","cost":3},
				{"id":"ARM_MARSH_03","label":"Manto do Brejo","slot":"armor","tier":3,"defense":4,"material":"Fibra de Junco","cost":2}
			]
		"REG_005_MONTANHAS_NEVADAS":
			return [
				{"id":"WPN_FROST_04","label":"Lâmina de Geada","slot":"weapon","tier":4,"attack":14,"material":"Cristal de Geada","cost":3},
				{"id":"ARM_FROST_04","label":"Cota da Vigília Branca","slot":"armor","tier":4,"defense":5,"material":"Cristal de Geada","cost":2}
			]
		"REG_006_COSTAS_ILHAS_PERDIDAS":
			return [
				{"id":"WPN_COAST_05","label":"Espada da Maré Azul","slot":"weapon","tier":5,"attack":18,"material":"Coral Luminoso","cost":3},
				{"id":"ARM_COAST_05","label":"Armadura do Navegante","slot":"armor","tier":5,"defense":6,"material":"Coral Luminoso","cost":2}
			]
		"REG_007_TERRAS_CORROMPIDAS":
			return [
				{"id":"WPN_WAR_06","label":"Quebra-Obelisco","slot":"weapon","tier":6,"attack":23,"material":"Fragmento de Obelisco","cost":3},
				{"id":"ARM_WAR_06","label":"Placas das Seis Coroas","slot":"armor","tier":6,"defense":8,"material":"Fragmento de Obelisco","cost":2}
			]
		"REG_008_CORACAO_ABISSAL":
			return [
				{"id":"WPN_ABYSS_07","label":"Lâmina do Último Mapa","slot":"weapon","tier":7,"attack":30,"material":"Fragmento do Último Mapa","cost":3},
				{"id":"ARM_ABYSS_07","label":"Armadura Entre Mundos","slot":"armor","tier":7,"defense":10,"material":"Fragmento do Último Mapa","cost":2}
			]
		_:
			return []

func add_material(material_name: String, amount: int = 1) -> void:
	if material_name == "" or amount <= 0:
		return
	materials[material_name] = int(materials.get(material_name,0))+amount
	save_profile()

func material_count(material_name: String) -> int:
	return int(materials.get(material_name,0))

func craft(region_id: String, slot: String) -> Dictionary:
	var recipe: Dictionary = _recipe(region_id,slot)
	if recipe.is_empty():
		return {"ok":false,"message":"Nenhuma receita disponível nesta região."}
	var id: String = String(recipe.get("id",""))
	if crafted.has(id):
		_equip(recipe)
		save_profile()
		return {"ok":true,"message":"%s equipado." % String(recipe.get("label","Equipamento")),"recipe":recipe}
	var material_name: String = String(recipe.get("material",""))
	var cost: int = int(recipe.get("cost",0))
	var have: int = material_count(material_name)
	if have < cost:
		return {"ok":false,"message":"Faltam %d %s." % [cost-have,material_name],"recipe":recipe}
	materials[material_name] = have-cost
	crafted[id] = recipe.duplicate(true)
	_equip(recipe)
	save_profile()
	return {"ok":true,"message":"Forjado: %s." % String(recipe.get("label","Equipamento")),"recipe":recipe}

func _recipe(region_id: String, slot: String) -> Dictionary:
	for recipe in recipes_for(region_id):
		if String(recipe.get("slot","")) == slot:
			return recipe
	return {}

func _equip(recipe: Dictionary) -> void:
	var slot: String = String(recipe.get("slot",""))
	if slot == "weapon":
		if int(recipe.get("tier",0)) >= int(equipped_weapon.get("tier",0)):
			equipped_weapon = recipe.duplicate(true)
	elif slot == "armor":
		if int(recipe.get("tier",0)) >= int(equipped_armor.get("tier",0)):
			equipped_armor = recipe.duplicate(true)

func starter_equipment() -> Array[Dictionary]:
	return [
		{"id":"starter_blade","label":"Espada de Viagem","tier":0,"attack":0,"slot":"weapon"},
		{"id":"starter_armor","label":"Túnica de Viagem","tier":0,"defense":0,"slot":"armor"}
	]

func owned_equipment() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in starter_equipment():
		result.append(item.duplicate(true))
	for value in crafted.values():
		if value is Dictionary:
			result.append((value as Dictionary).duplicate(true))
	result.sort_custom(func(a: Dictionary,b: Dictionary): return int(a.get("tier",0)) > int(b.get("tier",0)))
	return result

func equip_item(item_id: String) -> Dictionary:
	var found: Dictionary = {}
	for item in owned_equipment():
		if String(item.get("id","")) == item_id:
			found = item
			break
	if found.is_empty():
		return {"ok":false,"message":"Item não encontrado no inventário."}
	var slot: String = String(found.get("slot",""))
	if slot == "weapon":
		equipped_weapon = found.duplicate(true)
	elif slot == "armor":
		equipped_armor = found.duplicate(true)
	else:
		return {"ok":false,"message":"Este item não pode ser equipado."}
	save_profile()
	return {"ok":true,"message":"Equipado: %s." % String(found.get("label","Item")),"item":found}

func is_equipped(item_id: String) -> bool:
	return String(equipped_weapon.get("id","")) == item_id or String(equipped_armor.get("id","")) == item_id

func material_total() -> int:
	var total: int = 0
	for value in materials.values():
		total += int(value)
	return total

func profile_summary() -> String:
	if campaign_started:
		return "Nv %d • %d ouro • %d equipamentos • %d materiais" % [player_level,player_gold,owned_equipment().size(),material_total()]
	return "%d equipamentos • %d materiais" % [owned_equipment().size(),material_total()]

func has_profile_progress() -> bool:
	return campaign_started or not crafted.is_empty() or material_total() > 0 or int(equipped_weapon.get("tier",0)) > 0 or int(equipped_armor.get("tier",0)) > 0

func has_campaign_save() -> bool:
	return campaign_started and FileAccess.file_exists(SAVE_PATH)

func continue_scene_path() -> String:
	return current_scene if current_scene in VALID_SCENES else DEFAULT_SCENE

func start_new_game() -> void:
	reset_progress(true)
	campaign_started = true
	current_scene = DEFAULT_SCENE
	player_position = Vector2.ZERO
	player_hp = 120
	player_max_hp = 120
	player_gold = 35
	player_level = 1
	player_xp = 0
	save_profile()

func delete_profile() -> void:
	reset_progress(true)

func prepare_transition(next_scene: String) -> void:
	if next_scene not in VALID_SCENES:
		return
	_capture_active_memory()
	_clear_active_binding()
	campaign_started = true
	current_scene = next_scene
	player_position = Vector2.ZERO
	save_profile()

func bind_scene(
	scene_path: String,
	host_node: Node,
	hero_node: Node2D,
	story_runtime,
	default_level: int,
	default_max_hp: int,
	default_gold: int,
	extra_keys: Array = []
) -> void:
	if scene_path not in VALID_SCENES or host_node == null or hero_node == null:
		return
	var was_started: bool = campaign_started
	var resuming_here: bool = campaign_started and current_scene == scene_path and player_position != Vector2.ZERO

	_active_scene = scene_path
	_active_host = host_node
	_active_hero = hero_node
	_active_story = story_runtime
	_active_extra_keys = extra_keys.duplicate()
	_autosave_elapsed = 0.0

	if not was_started:
		campaign_started = true
		player_gold = default_gold
		player_level = default_level
		player_max_hp = default_max_hp
		player_hp = default_max_hp

	current_scene = scene_path
	if resuming_here:
		hero_node.position = player_position
	else:
		player_position = hero_node.position
		player_level = maxi(player_level,default_level)
		player_max_hp = maxi(player_max_hp,default_max_hp)
		player_hp = player_max_hp

	if _has_property(host_node,"player_max_hp"):
		host_node.set("player_max_hp",player_max_hp)
	if _has_property(host_node,"player_hp"):
		host_node.set("player_hp",clampi(player_hp,0,player_max_hp))
	if _has_property(host_node,"player_gold"):
		host_node.set("player_gold",maxi(0,player_gold))

	_restore_story(scene_path,story_runtime)
	_restore_extras(scene_path,host_node,extra_keys)
	save_profile()

func _capture_active_memory() -> void:
	if _active_scene == "" or _active_host == null or _active_hero == null:
		return
	if not is_instance_valid(_active_host) or not is_instance_valid(_active_hero):
		return
	campaign_started = true
	current_scene = _active_scene
	player_position = _active_hero.position
	if _has_property(_active_host,"player_hp"):
		player_hp = maxi(0,int(_active_host.get("player_hp")))
	if _has_property(_active_host,"player_max_hp"):
		player_max_hp = maxi(1,int(_active_host.get("player_max_hp")))
	if _has_property(_active_host,"player_gold"):
		player_gold = maxi(0,int(_active_host.get("player_gold")))
	if _active_story != null:
		story_progress[_active_scene] = _story_snapshot(_active_story)
	if not _active_extra_keys.is_empty():
		var extras: Dictionary = {}
		for key_value in _active_extra_keys:
			var key: String = String(key_value)
			if _has_property(_active_host,key):
				extras[key] = _json_copy(_active_host.get(key))
		scene_extras[_active_scene] = extras

func _story_snapshot(runtime) -> Dictionary:
	var result: Dictionary = {}
	if runtime == null:
		return result
	var names: Dictionary = _property_names(runtime)
	for key in STORY_STATE_KEYS:
		if names.has(key):
			result[key] = _json_copy(runtime.get(key))
	return result

func _restore_story(scene_path: String,runtime) -> void:
	if runtime == null:
		return
	var value: Variant = story_progress.get(scene_path,{})
	if not (value is Dictionary):
		return
	var names: Dictionary = _property_names(runtime)
	for key_value in (value as Dictionary).keys():
		var key: String = String(key_value)
		if names.has(key) and key in STORY_STATE_KEYS:
			runtime.set(key,_json_copy((value as Dictionary)[key]))

func _restore_extras(scene_path: String,host_node: Node,extra_keys: Array) -> void:
	var value: Variant = scene_extras.get(scene_path,{})
	if not (value is Dictionary):
		return
	for key_value in extra_keys:
		var key: String = String(key_value)
		if (value as Dictionary).has(key) and _has_property(host_node,key):
			host_node.set(key,_json_copy((value as Dictionary)[key]))

func _property_names(target: Object) -> Dictionary:
	var result: Dictionary = {}
	for info_value in target.get_property_list():
		var info: Dictionary = info_value
		result[String(info.get("name",""))] = true
	return result

func _has_property(target: Object,key: String) -> bool:
	if target == null:
		return false
	for info_value in target.get_property_list():
		var info: Dictionary = info_value
		if String(info.get("name","")) == key:
			return true
	return false

func _json_copy(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value

func _clear_active_binding() -> void:
	_active_scene = ""
	_active_host = null
	_active_hero = null
	_active_story = null
	_active_extra_keys.clear()
	_autosave_elapsed = 0.0

func set_camera_zoom(value: float) -> void:
	camera_zoom = clampf(value,0.70,1.50)
	save_profile()

func attack_bonus() -> int:
	return int(equipped_weapon.get("attack",0))

func defense_bonus() -> int:
	return int(equipped_armor.get("defense",0))

func attack_damage(base_damage: int) -> int:
	return maxi(1,base_damage+attack_bonus())

func reduce_damage(raw_damage: int) -> int:
	return maxi(1,raw_damage-defense_bonus())

func equipment_summary() -> String:
	return "⚔ %s  +%d ATQ\n🛡 %s  +%d DEF" % [
		String(equipped_weapon.get("label","Espada de Viagem")),attack_bonus(),
		String(equipped_armor.get("label","Túnica de Viagem")),defense_bonus()
	]

func materials_summary() -> String:
	if materials.is_empty():
		return "Nenhum material coletado."
	var parts: PackedStringArray = PackedStringArray()
	var keys: Array = materials.keys()
	keys.sort()
	for key in keys:
		var amount: int = int(materials[key])
		if amount > 0:
			parts.append("%s: %d" % [String(key),amount])
	return " • ".join(parts) if not parts.is_empty() else "Nenhum material coletado."

func save_profile() -> void:
	if _active_scene != "":
		_capture_active_memory()
	var file: FileAccess = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if file == null:
		return
	var data: Dictionary = {
		"version":SAVE_VERSION,
		"materials":materials,
		"crafted":crafted,
		"equipped_weapon":equipped_weapon,
		"equipped_armor":equipped_armor,
		"camera_zoom":camera_zoom,
		"campaign_started":campaign_started,
		"current_scene":current_scene,
		"player_position":{"x":player_position.x,"y":player_position.y},
		"player_hp":player_hp,
		"player_max_hp":player_max_hp,
		"player_gold":player_gold,
		"player_level":player_level,
		"player_xp":player_xp,
		"story_progress":story_progress,
		"scene_extras":scene_extras
	}
	file.store_string(JSON.stringify(data))

func load_profile() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH,FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return
	var data: Dictionary = parsed
	materials = data.get("materials",{}) as Dictionary
	crafted = data.get("crafted",{}) as Dictionary
	equipped_weapon = (data.get("equipped_weapon",equipped_weapon) as Dictionary).duplicate(true)
	equipped_armor = (data.get("equipped_armor",equipped_armor) as Dictionary).duplicate(true)
	camera_zoom = clampf(float(data.get("camera_zoom",1.0)),0.70,1.50)

	var version: int = int(data.get("version",1))
	campaign_started = bool(data.get("campaign_started",false))
	if version < 2 and not campaign_started:
		campaign_started = not crafted.is_empty() or material_total() > 0 or int(equipped_weapon.get("tier",0)) > 0 or int(equipped_armor.get("tier",0)) > 0
	current_scene = String(data.get("current_scene",DEFAULT_SCENE))
	if current_scene not in VALID_SCENES:
		current_scene = DEFAULT_SCENE
	var pos_value: Variant = data.get("player_position",{})
	if pos_value is Dictionary:
		player_position = Vector2(float((pos_value as Dictionary).get("x",0.0)),float((pos_value as Dictionary).get("y",0.0)))
	else:
		player_position = Vector2.ZERO
	player_max_hp = maxi(1,int(data.get("player_max_hp",120)))
	player_hp = clampi(int(data.get("player_hp",player_max_hp)),0,player_max_hp)
	player_gold = maxi(0,int(data.get("player_gold",35)))
	player_level = clampi(int(data.get("player_level",1)),1,100)
	player_xp = maxi(0,int(data.get("player_xp",0)))
	var story_value: Variant = data.get("story_progress",{})
	story_progress = (story_value as Dictionary).duplicate(true) if story_value is Dictionary else {}
	var extras_value: Variant = data.get("scene_extras",{})
	scene_extras = (extras_value as Dictionary).duplicate(true) if extras_value is Dictionary else {}

func reset_progress(delete_save: bool = true) -> void:
	_clear_active_binding()
	materials.clear()
	crafted.clear()
	equipped_weapon = {"id":"starter_blade","label":"Espada de Viagem","tier":0,"attack":0,"slot":"weapon"}
	equipped_armor = {"id":"starter_armor","label":"Túnica de Viagem","tier":0,"defense":0,"slot":"armor"}
	camera_zoom = 1.0
	campaign_started = false
	current_scene = DEFAULT_SCENE
	player_position = Vector2.ZERO
	player_hp = 120
	player_max_hp = 120
	player_gold = 35
	player_level = 1
	player_xp = 0
	story_progress.clear()
	scene_extras.clear()
	if delete_save and FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
