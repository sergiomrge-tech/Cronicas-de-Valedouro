class_name ValedouroCartoonFrostStoryRuntime
extends RefCounted

const STORY_PATH: String = "res://data/main_story_v1.json"

var quests: Dictionary = {}
var current_id: String = "Q_MS05_FROST_REST"
var act5_region_complete: bool = false
var siege_pending: bool = false

func _init() -> void:
	var file: FileAccess = FileAccess.open(STORY_PATH,FileAccess.READ)
	assert(file != null)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary)
	for q in (parsed as Dictionary).get("quests",[]):
		if int(q.get("act",0)) == 5:
			quests[String(q.get("id",""))] = q

func current() -> Dictionary:
	return quests.get(current_id,{}) as Dictionary

func title() -> String:
	return String(current().get("title",""))

func current_location() -> String:
	return String(current().get("loc",""))

func objective() -> String:
	if act5_region_complete and siege_pending:
		return "Retorne a Valedouro para defender as muralhas."
	return String(current().get("objective",""))

func hud_text() -> String:
	return "HISTÓRIA PRINCIPAL\n%s — %s" % [title(),objective()]

func interact(location_id: String) -> bool:
	if location_id != current_location():
		return false
	var kind: String = String(current().get("type",""))
	if kind in ["talk","investigate","reveal"]:
		_advance()
		return true
	return false

func register_boss(boss_id: String) -> bool:
	if current_id == "Q_MS05_CAPTAIN" and boss_id == "BOSS_CAPITAO_GELO_001":
		_advance()
		return true
	if current_id == "Q_MS05_BLACK_FROST" and boss_id == "BOSS_GENERAL_GEADA_NEGRA_001":
		_advance()
		act5_region_complete = true
		siege_pending = true
		return true
	return false

func mark_siege_complete() -> void:
	if current_id == "Q_MS05_SIEGE":
		siege_pending = false
		current_id = "Q_MS06_MIST_PORT"

func _advance() -> void:
	current_id = String(current().get("next",""))
