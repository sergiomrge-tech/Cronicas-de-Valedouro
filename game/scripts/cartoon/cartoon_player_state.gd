extends Node

const SAVE_PATH: String = "user://valedouro_cartoon_profile_v1.json"

var materials: Dictionary = {}
var crafted: Dictionary = {}
var equipped_weapon: Dictionary = {"id":"starter_blade","label":"Espada de Viagem","tier":0,"attack":0,"slot":"weapon"}
var equipped_armor: Dictionary = {"id":"starter_armor","label":"Túnica de Viagem","tier":0,"defense":0,"slot":"armor"}\nvar camera_zoom: float = 1.0

func _ready() -> void:
	load_profile()

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
	var file: FileAccess = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if file == null:
		return
	var data: Dictionary = {
		"version":1,
		"materials":materials,
		"crafted":crafted,
		"equipped_weapon":equipped_weapon,
		"equipped_armor":equipped_armor
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
	equipped_armor = (data.get("equipped_armor",equipped_armor) as Dictionary).duplicate(true)\n\tcamera_zoom = clampf(float(data.get("camera_zoom",1.0)),0.70,1.50)

func reset_progress(delete_save: bool = true) -> void:
	materials.clear()
	crafted.clear()
	equipped_weapon = {"id":"starter_blade","label":"Espada de Viagem","tier":0,"attack":0,"slot":"weapon"}
	equipped_armor = {"id":"starter_armor","label":"Túnica de Viagem","tier":0,"defense":0,"slot":"armor"}
	if delete_save and FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
