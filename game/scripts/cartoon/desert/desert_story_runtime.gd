class_name ValedouroCartoonDesertStoryRuntime
extends RefCounted

const STORY_PATH: String = "res://data/main_story_v1.json"

var quests: Dictionary = {}
var current_id: String = "Q_MS03_CARAVAN"
var escort_started: bool = false
var act3_complete: bool = false

func _init() -> void:
	var file: FileAccess = FileAccess.open(STORY_PATH,FileAccess.READ)
	assert(file != null)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary)
	for q in (parsed as Dictionary).get("quests",[]):
		if int(q.get("act",0)) == 3:
			quests[String(q.get("id",""))] = q

func current() -> Dictionary:
	return quests.get(current_id,{}) as Dictionary

func title() -> String:
	return String(current().get("title",""))

func current_location() -> String:
	return String(current().get("loc",""))

func objective() -> String:
	if act3_complete:
		return "Ato III concluído — a rota segue para os Pântanos Sombrios"
	if current_id == "Q_MS03_CARAVAN" and escort_started:
		return "Acompanhe a Caravana de Âmbar até o posto."
	return String(current().get("objective",""))

func hud_text() -> String:
	if act3_complete:
		return "HISTÓRIA PRINCIPAL\nAto III concluído — Lanternas Afundadas"
	return "HISTÓRIA PRINCIPAL\n%s — %s" % [title(),objective()]

func interact(location_id: String) -> bool:
	if act3_complete:
		return false
	if current_id == "Q_MS03_CARAVAN":
		if location_id == "LOC_AMBER_CARAVAN" and not escort_started:
			escort_started = true
			return true
		if location_id == "LOC_AMBER_POST" and escort_started:
			_advance()
			return true
		return false
	if location_id != current_location():
		return false
	var kind: String = String(current().get("type",""))
	if kind in ["talk","infiltrate","investigate","dungeon"]:
		_advance()
		return true
	return false

func register_boss(boss_id: String) -> bool:
	if current_id == "Q_MS03_GENERAL_ASH" and boss_id == "BOSS_GENERAL_CINZA_001":
		_advance()
		return true
	return false

func _advance() -> void:
	var next_id: String = String(current().get("next",""))
	if current_id == "Q_MS03_GENERAL_ASH":
		act3_complete = true
		current_id = "Q_MS04_STILTS"
		return
	current_id = next_id
