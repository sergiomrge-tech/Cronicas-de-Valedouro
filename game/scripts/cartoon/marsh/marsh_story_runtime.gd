class_name ValedouroCartoonMarshStoryRuntime
extends RefCounted

const STORY_PATH: String = "res://data/main_story_v1.json"

var quests: Dictionary = {}
var current_id: String = "Q_MS04_STILTS"
var act4_complete: bool = false

func _init() -> void:
	var file: FileAccess = FileAccess.open(STORY_PATH,FileAccess.READ)
	assert(file != null)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary)
	for q in (parsed as Dictionary).get("quests",[]):
		if int(q.get("act",0)) == 4:
			quests[String(q.get("id",""))] = q

func current() -> Dictionary:
	return quests.get(current_id,{}) as Dictionary

func title() -> String:
	return String(current().get("title",""))

func current_location() -> String:
	return String(current().get("loc",""))

func objective() -> String:
	if act4_complete:
		return "Ato IV concluído — o Eco aponta para o Norte Gelado"
	return String(current().get("objective",""))

func hud_text() -> String:
	if act4_complete:
		return "HISTÓRIA PRINCIPAL\nAto IV concluído — O Frio sem Túmulos"
	return "HISTÓRIA PRINCIPAL\n%s — %s" % [title(),objective()]

func interact(location_id: String) -> bool:
	if act4_complete or location_id != current_location():
		return false
	var kind: String = String(current().get("type",""))
	if kind in ["travel","investigate","dungeon","activate"]:
		_advance()
		return true
	return false

func register_boss(boss_id: String) -> bool:
	if current_id == "Q_MS04_LADY_REEDS" and boss_id == "BOSS_DAMA_JUNCOS_001":
		_advance()
		return true
	return false

func _advance() -> void:
	var next_id: String = String(current().get("next",""))
	if current_id == "Q_MS04_SLICE_GATE":
		act4_complete = true
		current_id = "Q_MS05_FROST_REST"
		return
	current_id = next_id
