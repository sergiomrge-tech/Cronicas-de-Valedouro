class_name ValedouroCartoonAbyssStoryRuntime
extends RefCounted

const STORY_PATH: String = "res://data/main_story_v1.json"

var quests: Dictionary = {}
var current_id: String = "Q_MS08_LAST_MAP_GATE"
var campaign_complete: bool = false
var ending: String = ""

func _init() -> void:
	var file: FileAccess = FileAccess.open(STORY_PATH,FileAccess.READ)
	assert(file != null)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary)
	for q in (parsed as Dictionary).get("quests",[]):
		if int(q.get("act",0)) == 8:
			quests[String(q.get("id",""))] = q

func current() -> Dictionary:
	return quests.get(current_id,{}) as Dictionary

func title() -> String:
	return String(current().get("title",""))

func current_location() -> String:
	return String(current().get("loc",""))

func objective() -> String:
	if campaign_complete:
		return "Campanha concluída — " + ending
	if current_id == "Q_MS08_CHOICE":
		return "Escolha retornar à Terra ou permanecer em Elyndor."
	return String(current().get("objective",""))

func hud_text() -> String:
	if campaign_complete:
		return "CRÔNICAS DE VALEDOURO\nCampanha concluída — "+ending
	return "HISTÓRIA PRINCIPAL\n%s — %s" % [title(),objective()]

func interact(location_id: String) -> bool:
	if campaign_complete or location_id != current_location():
		return false
	var kind: String = String(current().get("type",""))
	if kind in ["enter","traverse","confront","finale"]:
		_advance()
		return true
	return false

func register_boss(boss_id: String) -> bool:
	if current_id == "Q_MS08_CARTOGRAPHER" and boss_id == "BOSS_CARTOGRAFO_VAZIO_001":
		_advance()
		return true
	if current_id == "Q_MS08_AZHAREL" and boss_id == "BOSS_AZHAREL_001":
		_advance()
		return true
	return false

func choose_ending(choice: String) -> bool:
	if current_id != "Q_MS08_CHOICE" or choice not in ["return","stay"]:
		return false
	ending = "Retorno à Terra" if choice == "return" else "Permanecer em Elyndor"
	campaign_complete = true
	return true

func _advance() -> void:
	current_id = String(current().get("next",""))
