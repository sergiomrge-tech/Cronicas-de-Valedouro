extends Node

const GuildMissions = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")
var demon_cooldowns: Dictionary = {}
var tracked_mission: String = "main"
func normalize_tracked_mission() -> void:
	if tracked_mission!="main" and (GuildMissions.row(tracked_mission).is_empty() or GuildMissions.status(self,tracked_mission)!="active"):
		tracked_mission = "main"
func set_tracked_mission(id: String) -> bool:
	if id!="main" and (GuildMissions.row(id).is_empty() or GuildMissions.status(self,id)!="active"): return false
	tracked_mission = id
	save_profile()
	return true

const SAVE_PATH: String = "user://valedouro_cartoon_profile_v1.json"
const SAVE_VERSION: int = 8
const Classes = preload("res://scripts/cartoon/cartoon_class_catalog.gd")
const Loot = preload("res://scripts/cartoon/cartoon_loot_catalog.gd")
const SPELL_UNLOCK_LEVELS: Array[int] = [1,10,25]
const SPELL_LABELS: Array[String] = ["Brasa","Cristal","Arcana"]
const EQUIPMENT_LEVELS: Array[int] = [1,8,18,28,40,55,70,85]
const EQUIPMENT_REGION_LABELS: Array[String] = [
	"Valedouro","Floresta Ancestral","Deserto e Ruínas","Pântanos Sombrios",
	"Montanhas Nevadas","Costas e Ilhas","Terras Corrompidas","Coração Abissal"
]
var active_class: String = "warrior"
var skill_ranks: Dictionary = {}

func spell_unlock_level(index: int) -> int:
	if index < 0 or index >= SPELL_UNLOCK_LEVELS.size():
		return 999
	return SPELL_UNLOCK_LEVELS[index]

func spell_unlocked(index: int) -> bool:
	return player_level >= spell_unlock_level(index)

func unlocked_spell_count() -> int:
	var count: int = 0
	for i in range(SPELL_UNLOCK_LEVELS.size()):
		if spell_unlocked(i):
			count += 1
	return count

func progression_unlocks(from_level: int,to_level: int) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	var start_level: int = maxi(1,from_level+1)
	var end_level: int = clampi(to_level,1,100)
	if end_level < start_level:
		return result
	for level_value in range(start_level,end_level+1):
		for i in range(SPELL_UNLOCK_LEVELS.size()):
			if i > 0 and SPELL_UNLOCK_LEVELS[i] == level_value:
				result.append("Magia liberada: "+SPELL_LABELS[i])
		for tier in range(1,EQUIPMENT_LEVELS.size()):
			if EQUIPMENT_LEVELS[tier] == level_value:
				result.append("Equipamentos liberados: "+EQUIPMENT_REGION_LABELS[tier])
	return result

func skill_rank(id: String, active_only: bool = true) -> int:
	if not Classes.SKILLS.has(id): return 0
	if active_only and Classes.SKILLS[id].class != active_class: return 0
	return clampi(int(skill_ranks.get(id,0)),0,Classes.MAX_RANK)

func available_skill_points() -> int:
	var spent: int = 0
	for id in Classes.SKILLS: spent += skill_rank(id,false)
	return maxi(0,player_level-spent)

func set_class(id: String) -> bool:
	if Classes.class_row(id).is_empty() or id==active_class: return false
	active_class = id
	if is_instance_valid(_active_hero): _active_hero.apply_class_from_state()
	save_profile()
	return true

func skill_upgrade_error(id: String) -> String:
	if not Classes.SKILLS.has(id) or Classes.SKILLS[id].class != active_class: return "Escolha uma habilidade da classe ativa."
	var rank: int = skill_rank(id,false)
	if rank>=Classes.MAX_RANK: return "Grau máximo alcançado."
	if player_level<Classes.required_level(rank+1): return "Requer nível %d." % Classes.required_level(rank+1)
	if available_skill_points()<=0: return "Suba de nível para ganhar mais pontos."
	return ""

func upgrade_skill(id: String) -> bool:
	if skill_upgrade_error(id)!="": return false
	skill_ranks[id] = skill_rank(id,false)+1
	save_profile()
	return true

func refund_class_skills() -> int:
	var refunded: int = 0
	for id in Classes.class_row(active_class).skills:
		refunded += skill_rank(id,false)
		skill_ranks.erase(id)
	if refunded>0: save_profile()
	return refunded

func _normalize_class_progress(raw: Variant) -> void:
	if Classes.class_row(active_class).is_empty(): active_class = "warrior"
	skill_ranks.clear()
	if not raw is Dictionary: return
	var remaining: int = player_level
	for row in Classes.CLASSES:
		for id in row.skills:
			var value: Variant = raw.get(id,0)
			if not (value is int or value is float): continue
			var rank: int = clampi(int(value),0,mini(Classes.MAX_RANK,remaining))
			while rank>0 and player_level<Classes.required_level(rank): rank -= 1
			if rank>0: skill_ranks[id] = rank
			remaining -= rank
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

var guild_contracts: Dictionary = {}
var wildlife_cooldowns: Dictionary = {}
var gathering_cooldowns: Dictionary = {}
var materials: Dictionary = {}
var consumables: Dictionary = {}
var loot_pity: int = 0
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

func _legacy_recipes_for(region_id: String) -> Array[Dictionary]:
	match region_id:
		"REG_001_BERCO_VALEDOURO":
			return [
				{"id":"WPN_VALE_00","label":"Lâmina de Caçador","slot":"weapon","tier":0,"attack":2,"material":"Osso de caça","cost":3},
				{"id":"ARM_VALE_00","label":"Colete de Couro do Vale","slot":"armor","tier":0,"defense":1,"material":"Couro do Vale","cost":3}
			]
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

const ARMOR_SLOTS = ["armor","helmet","gloves","legs","boots","cape"]
const SLOT_NAMES = {"weapon":"Arma","armor":"Peitoral","helmet":"Elmo","gloves":"Luvas","legs":"Calças","boots":"Botas","cape":"Capa"}
var equipped_pieces: Dictionary = {}

func recipes_for(region_id: String) -> Array[Dictionary]:
	var rows: Array[Dictionary] = _legacy_recipes_for(region_id)
	if rows.is_empty(): return rows
	var chest: Dictionary = rows[1]
	var set_id: String = String(chest.id)
	rows[0]["weapon_kind"] = "sword"
	chest["set_id"] = set_id
	chest["set_name"] = String(chest.label)
	var bow: Dictionary = rows[0].duplicate(true)
	bow.id = "BOW_"+set_id
	bow.label = "Arco • "+String(chest.label)
	bow.weapon_kind = "bow"
	bow.attack = maxi(2,int(rows[0].attack)-1)
	rows.append(bow)
	for slot: String in ["helmet","gloves","legs","boots","cape"]:
		var piece: Dictionary = chest.duplicate(true)
		piece.id = set_id+"_"+slot
		piece.slot = slot
		piece.label = String(SLOT_NAMES[slot])+" • "+String(chest.label)
		piece.defense = maxi(1,int(chest.defense)/3)
		piece.cost = 2
		rows.append(piece)
	return rows

func equipped_in_slot(slot: String) -> Dictionary:
	if slot == "weapon": return equipped_weapon
	if slot == "armor": return equipped_armor
	return equipped_pieces.get(slot,{})

func set_progress(item: Dictionary = {}) -> Dictionary:
	var set_id: String = String(item.get("set_id",equipped_armor.get("set_id","")))
	var count: int = 0
	for slot: String in ARMOR_SLOTS:
		if set_id != "" and String(equipped_in_slot(slot).get("set_id","")) == set_id: count += 1
	return {"count":count,"complete":count==6,"bonus":int(item.get("tier",equipped_armor.get("tier",0)))+2}

func craft_item(region_id: String, item_id: String) -> Dictionary:
	for row in recipes_for(region_id):
		if String(row.id) == item_id: return _craft_recipe(row)
	return {"ok":false,"message":"Receita indisponível nesta região."}

func _normalize_equipment() -> void:
	# Canonical recipes enrich legacy items without changing IDs or quest progress.
	var catalog: Dictionary = {}
	for region in ["REG_001_BERCO_VALEDOURO","REG_002_FLORESTA_ANCESTRAL","REG_003_DESERTO_RUINAS","REG_004_PANTANOS_SOMBRIOS","REG_005_MONTANHAS_NEVADAS","REG_006_COSTAS_ILHAS_PERDIDAS","REG_007_TERRAS_CORROMPIDAS","REG_008_CORACAO_ABISSAL"]:
		for row in recipes_for(region): catalog[String(row.id)] = row
	for key in crafted.keys():
		if catalog.has(key): crafted[key] = catalog[key].duplicate(true)
		else: crafted.erase(key)
	for slot: String in ["weapon","armor","helmet","gloves","legs","boots","cape"]:
		var current: Dictionary = equipped_in_slot(slot)
		var id: String = String(current.get("id",""))
		if crafted.has(id) and String(crafted[id].slot)==slot:
			if slot=="weapon": equipped_weapon = crafted[id].duplicate(true)
			elif slot=="armor": equipped_armor = crafted[id].duplicate(true)
			else: equipped_pieces[slot] = crafted[id].duplicate(true)
		elif slot=="weapon": equipped_weapon = starter_equipment()[0].duplicate(true)
		elif slot=="armor": equipped_armor = starter_equipment()[1].duplicate(true)
		else: equipped_pieces.erase(slot)

func buy_crafting_material(region_id: String) -> Dictionary:
	var rows: Array[Dictionary] = recipes_for(region_id)
	if rows.is_empty(): return {"ok":false,"message":"Fornecedor indisponível."}
	_capture_active_memory()
	if player_gold<10: return {"ok":false,"message":"São necessários 10 de ouro."}
	var material: String = String(rows[1].material)
	player_gold -= 10
	if is_instance_valid(_active_host) and _has_property(_active_host,"player_gold"):
		_active_host.set("player_gold",player_gold)
	materials[material] = material_count(material)+1
	save_profile()
	return {"ok":true,"message":"Comprado: 1 %s por 10 de ouro." % material}

func add_material(material_name: String, amount: int = 1) -> void:
	if material_name == "" or amount <= 0:
		return
	materials[material_name] = int(materials.get(material_name,0))+amount
	save_profile()

func material_count(material_name: String) -> int:
	return int(materials.get(material_name,0))

func add_consumable(id: String, amount: int = 1) -> bool:
	if amount <= 0 or Loot.consumable(id).is_empty():
		return false
	consumables[id] = int(consumables.get(id,0))+amount
	save_profile()
	return true

func consumable_count(id: String) -> int:
	return int(consumables.get(id,0))

func consumables_total() -> int:
	var total: int = 0
	for value in consumables.values():
		total += maxi(0,int(value))
	return total

func healing_consumables_total() -> int:
	return consumable_count("healing_flask")+consumable_count("greater_healing_flask")

func best_heal_consumable() -> String:
	if player_hp >= player_max_hp:
		return ""
	var missing: int = maxi(0,player_max_hp-player_hp)
	if missing >= ceili(float(player_max_hp)*0.50) and consumable_count("greater_healing_flask") > 0:
		return "greater_healing_flask"
	if consumable_count("healing_flask") > 0:
		return "healing_flask"
	if consumable_count("greater_healing_flask") > 0:
		return "greater_healing_flask"
	return ""

func quick_heal() -> Dictionary:
	_capture_active_memory()
	var id: String = best_heal_consumable()
	if id == "":
		if player_hp >= player_max_hp:
			return {"ok":false,"message":"Vida cheia."}
		return {"ok":false,"message":"Sem itens de cura."}
	return use_consumable(id)

func use_consumable(id: String) -> Dictionary:
	var row: Dictionary = Loot.consumable(id)
	if row.is_empty() or consumable_count(id) <= 0:
		return {"ok":false,"message":"Consumível indisponível."}
	_capture_active_memory()
	if player_hp >= player_max_hp:
		return {"ok":false,"message":"Sua vida já está cheia."}
	var before: int = player_hp
	var amount: int = maxi(1,roundi(float(player_max_hp)*float(row.get("heal_ratio",0.0))))
	player_hp = mini(player_max_hp,player_hp+amount)
	var left: int = consumable_count(id)-1
	if left > 0:
		consumables[id] = left
	else:
		consumables.erase(id)
	if _active_host != null and is_instance_valid(_active_host) and _has_property(_active_host,"player_hp"):
		_active_host.set("player_hp",player_hp)
	save_profile()
	return {
		"ok":true,
		"message":"%s usado • +%d vida" % [String(row.get("label","Consumível")),player_hp-before],
		"healed":player_hp-before,
		"id":id
	}

func award_enemy_loot(
	region_id: String,
	enemy_kind: String,
	enemy_level: int,
	is_boss: bool = false,
	is_elite: bool = false,
	forced: Dictionary = {}
) -> Dictionary:
	var eligible: bool = region_id != "" and not Loot.region(region_id).is_empty()
	if not eligible:
		return {"summary":"","gear_id":"","material_qty":0,"consumable_id":""}
	var pity_after: int = loot_pity+1
	var rolled: Dictionary = Loot.roll(region_id,pity_after,is_boss,is_elite,forced)
	var parts: PackedStringArray = PackedStringArray()
	var material_name: String = String(rolled.get("material",""))
	var material_qty: int = int(rolled.get("material_qty",0))
	if material_name != "" and material_qty > 0:
		materials[material_name] = material_count(material_name)+material_qty
		parts.append("+%d %s" % [material_qty,material_name])

	var consumable_id: String = String(rolled.get("consumable_id",""))
	if consumable_id != "":
		consumables[consumable_id] = consumable_count(consumable_id)+1
		var consumable_row: Dictionary = Loot.consumable(consumable_id)
		parts.append("+1 %s" % String(consumable_row.get("label","Consumível")))

	var gear_id: String = ""
	if bool(rolled.get("gear",false)):
		var available: Array[Dictionary] = []
		for recipe in recipes_for(region_id):
			var id: String = String(recipe.get("id",""))
			if id != "" and not crafted.has(id):
				available.append(recipe)
		if not available.is_empty():
			var pick_index: int = int(forced.get("gear_index",-1))
			if pick_index < 0:
				var picker: RandomNumberGenerator = RandomNumberGenerator.new()
				picker.randomize()
				pick_index = picker.randi_range(0,available.size()-1)
			pick_index = clampi(pick_index,0,available.size()-1)
			var item: Dictionary = available[pick_index].duplicate(true)
			gear_id = String(item.get("id",""))
			crafted[gear_id] = item
			loot_pity = 0
			parts.append("DROP RARO: %s" % String(item.get("label","Equipamento")))
		else:
			loot_pity = pity_after
	else:
		loot_pity = pity_after

	# Chefes e elites não quebram a cadência: o pity continua se o drop raro não vier.
	if is_boss or is_elite:
		loot_pity = maxi(loot_pity,pity_after if gear_id == "" else 0)

	save_profile()
	return {
		"summary":" • ".join(parts),
		"gear_id":gear_id,
		"material":material_name,
		"material_qty":material_qty,
		"consumable_id":consumable_id,
		"pity":loot_pity,
		"enemy_kind":enemy_kind,
		"enemy_level":enemy_level
	}

func craft(region_id: String, slot: String) -> Dictionary:
	return _craft_recipe(_recipe(region_id,slot))

func _craft_recipe(recipe: Dictionary) -> Dictionary:
	if recipe.is_empty():
		return {"ok":false,"message":"Nenhuma receita disponível nesta região."}
	var id: String = String(recipe.get("id",""))
	if crafted.has(id):
		return equip_item(id)
	var material_name: String = String(recipe.get("material",""))
	var cost: int = int(recipe.get("cost",0))
	var have: int = material_count(material_name)
	if have < cost:
		return {"ok":false,"message":"Faltam %d %s." % [cost-have,material_name],"recipe":recipe}
	var required_level: int = equipment_required_level(recipe)
	if player_level < required_level:
		return {"ok":false,"message":"Requer nível %d para fabricar." % required_level,"recipe":recipe,"required_level":required_level}
	materials[material_name] = have-cost
	crafted[id] = recipe.duplicate(true)
	_equip(recipe)
	save_profile()
	return {"ok":true,"message":"Forjado e equipado: %s." % String(recipe.get("label","Equipamento")),"recipe":recipe}

func _recipe(region_id: String, slot: String) -> Dictionary:
	for recipe in recipes_for(region_id):
		if String(recipe.get("slot","")) == slot:
			return recipe
	return {}

func _equip(recipe: Dictionary) -> void:
	if not can_equip_item(recipe):
		return
	var slot: String = String(recipe.get("slot",""))
	if slot == "weapon":
		if int(recipe.get("tier",0)) >= int(equipped_weapon.get("tier",0)):
			equipped_weapon = recipe.duplicate(true)
	elif slot == "armor":
		if int(recipe.get("tier",0)) >= int(equipped_armor.get("tier",0)):
			equipped_armor = recipe.duplicate(true)
	elif slot in ARMOR_SLOTS:
		if int(recipe.get("tier",0)) >= int(equipped_in_slot(slot).get("tier",0)):
			equipped_pieces[slot] = recipe.duplicate(true)

func equipment_required_level(item: Dictionary) -> int:
	var tier: int = clampi(int(item.get("tier",0)),0,EQUIPMENT_LEVELS.size()-1)
	return EQUIPMENT_LEVELS[tier]

func can_equip_item(item: Dictionary) -> bool:
	return player_level >= equipment_required_level(item)

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
	var required_level: int = equipment_required_level(found)
	if player_level < required_level:
		return {"ok":false,"message":"Requer nível %d para equipar." % required_level,"item":found,"required_level":required_level}
	var slot: String = String(found.get("slot",""))
	if slot == "weapon":
		equipped_weapon = found.duplicate(true)
	elif slot == "armor":
		equipped_armor = found.duplicate(true)
	elif slot in ARMOR_SLOTS:
		equipped_pieces[slot] = found.duplicate(true)
	else:
		return {"ok":false,"message":"Este item não pode ser equipado."}
	save_profile()
	return {"ok":true,"message":"Equipado: %s." % String(found.get("label","Item")),"item":found}

func is_equipped(item_id: String) -> bool:
	for slot: String in ["weapon","armor","helmet","gloves","legs","boots","cape"]:
		if String(equipped_in_slot(slot).get("id","")) == item_id: return true
	return false

func material_total() -> int:
	var total: int = 0
	for value in materials.values():
		total += int(value)
	return total

func profile_summary() -> String:
	if campaign_started:
		return "Nv %d • %d ouro • %d equip. • %d mat. • %d itens" % [player_level,player_gold,owned_equipment().size(),material_total(),consumables_total()]
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
		# Campaign travel never awards free levels, stats or healing.

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
	player_position = _active_host.campaign_position() if _active_host.has_method("campaign_position") else _active_hero.position
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

func xp_to_next(level_value: int = -1) -> int:
	var target_level: int = player_level if level_value < 0 else clampi(level_value,1,100)
	if target_level >= 100:
		return 0
	return 120 + target_level*60 + target_level*target_level*8

func xp_ratio() -> float:
	if player_level >= 100:
		return 1.0
	var needed: int = xp_to_next()
	return clampf(float(player_xp) / float(maxi(1,needed)),0.0,1.0)

func gain_xp(amount: int) -> Dictionary:
	if amount <= 0 or player_level >= 100:
		return {"gained":0,"levels":0,"leveled_up":false,"level":player_level}
	_capture_active_memory()
	var gained_levels: int = 0
	player_xp += amount
	while player_level < 100:
		var needed: int = xp_to_next(player_level)
		if player_xp < needed:
			break
		player_xp -= needed
		player_level += 1
		gained_levels += 1
		player_max_hp += 4
		player_hp = mini(player_max_hp,player_hp+12)
	if player_level >= 100:
		player_level = 100
		player_xp = 0
	if _active_host != null and is_instance_valid(_active_host):
		if _has_property(_active_host,"player_max_hp"):
			_active_host.set("player_max_hp",player_max_hp)
		if _has_property(_active_host,"player_hp"):
			_active_host.set("player_hp",player_hp)
	save_profile()
	return {
		"gained":amount,
		"levels":gained_levels,
		"leveled_up":gained_levels > 0,
		"level":player_level,
		"xp":player_xp,
		"next":xp_to_next()
	}

func set_camera_zoom(value: float) -> void:
	camera_zoom = clampf(value,0.70,1.50)
	save_profile()

func attack_bonus() -> int:
	var progress: Dictionary = set_progress()
	return int(equipped_weapon.get("attack",0))+(int(progress.bonus) if progress.complete else 0)

func defense_bonus() -> int:
	var total: int = 0
	for slot: String in ARMOR_SLOTS: total += int(equipped_in_slot(slot).get("defense",0))
	var progress: Dictionary = set_progress()
	return total+(int(progress.bonus) if progress.complete else 0)

func attack_damage(base_damage: int) -> int:
	return maxi(1,base_damage+attack_bonus())

func reduce_damage(raw_damage: int) -> int:
	return maxi(1,roundi(maxi(1,raw_damage-defense_bonus())*(1-0.02*skill_rank("guard"))))

func equipment_summary() -> String:
	var progress: Dictionary = set_progress()
	return "%s • ATQ +%d\nDefesa total +%d • Conjunto %d/6%s" % [String(equipped_weapon.get("label","Espada")),attack_bonus(),defense_bonus(),int(progress.count)," • bônus ativo" if progress.complete else ""]

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
		"tracked_mission":tracked_mission,
		"demon_cooldowns":demon_cooldowns,
		"active_class":active_class,
		"skill_ranks":skill_ranks,
		"materials":materials,
		"consumables":consumables,
		"loot_pity":loot_pity,
		"guild_contracts":guild_contracts,
		"wildlife_cooldowns":wildlife_cooldowns,
		"gathering_cooldowns":gathering_cooldowns,
		"crafted":crafted,
		"equipped_weapon":equipped_weapon,
		"equipped_armor":equipped_armor,
		"equipped_pieces":equipped_pieces,
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
	var contracts_value: Variant = data.get("guild_contracts",{})
	guild_contracts = contracts_value.duplicate(true) if contracts_value is Dictionary else {}
	var demons_value: Variant = data.get("demon_cooldowns",{})
	demon_cooldowns = demons_value.duplicate(true) if demons_value is Dictionary else {}
	tracked_mission = String(data.get("tracked_mission","main"))
	normalize_tracked_mission()
	var wildlife_value: Variant = data.get("wildlife_cooldowns",{})
	wildlife_cooldowns = wildlife_value.duplicate(true) if wildlife_value is Dictionary else {}
	var gathering_value: Variant = data.get("gathering_cooldowns",{})
	gathering_cooldowns = gathering_value.duplicate(true) if gathering_value is Dictionary else {}
	materials = data.get("materials",{}) as Dictionary
	var consumables_value: Variant = data.get("consumables",{})
	consumables = consumables_value.duplicate(true) if consumables_value is Dictionary else {}
	loot_pity = clampi(int(data.get("loot_pity",0)),0,50)
	crafted = data.get("crafted",{}) as Dictionary
	equipped_weapon = (data.get("equipped_weapon",equipped_weapon) as Dictionary).duplicate(true)
	equipped_armor = (data.get("equipped_armor",equipped_armor) as Dictionary).duplicate(true)
	var pieces_value: Variant = data.get("equipped_pieces",{})
	equipped_pieces = pieces_value.duplicate(true) if pieces_value is Dictionary else {}
	_normalize_equipment()
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
	active_class = String(data.get("active_class","warrior"))
	_normalize_class_progress(data.get("skill_ranks",{}))
	var story_value: Variant = data.get("story_progress",{})
	story_progress = (story_value as Dictionary).duplicate(true) if story_value is Dictionary else {}
	var extras_value: Variant = data.get("scene_extras",{})
	scene_extras = (extras_value as Dictionary).duplicate(true) if extras_value is Dictionary else {}

func reset_progress(delete_save: bool = true) -> void:
	_clear_active_binding()
	active_class = "warrior"
	skill_ranks.clear()
	demon_cooldowns.clear()
	guild_contracts.clear()
	tracked_mission = "main"
	wildlife_cooldowns.clear()
	gathering_cooldowns.clear()
	materials.clear()
	consumables.clear()
	loot_pity = 0
	crafted.clear()
	equipped_pieces.clear()
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
