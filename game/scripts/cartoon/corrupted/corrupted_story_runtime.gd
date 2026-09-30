class_name ValedouroCartoonCorruptedStoryRuntime
extends RefCounted

const STORY_PATH: String = "res://data/main_story_v1.json"

var quests: Dictionary = {}
var current_id: String = "Q_MS07_LAST_BASTION"
var destroyed_obelisks: Dictionary = {}
var act7_complete: bool = false

func _init() -> void:
	var file: FileAccess = FileAccess.open(STORY_PATH,FileAccess.READ)
	assert(file != null)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary)
	for q in (parsed as Dictionary).get("quests",[]):
		if int(q.get("act",0)) == 7:
			quests[String(q.get("id",""))] = q

func current() -> Dictionary:
	return quests.get(current_id,{}) as Dictionary

func title() -> String:
	return String(current().get("title",""))

func current_location() -> String:
	return String(current().get("loc",""))

func objective() -> String:
	if act7_complete:
		return "Ato VII concluído — atravesse o Portão do Último Mapa"
	if current_id == "Q_MS07_OBELISKS":
		return "Destrua os três Obeliscos de Guerra — %d/3" % destroyed_obelisks.size()
	return String(current().get("objective",""))

func hud_text() -> String:
	if act7_complete:
		return "HISTÓRIA PRINCIPAL\nAto VII concluído — O Último Mapa"
	return "HISTÓRIA PRINCIPAL\n%s — %s" % [title(),objective()]

func interact(location_id: String) -> bool:
	if act7_complete or location_id != current_location():
		return false
	var kind: String = String(current().get("type",""))
	if kind in ["travel","dungeon","council"]:
		_advance()
		return true
	return false

func destroy_obelisk(obelisk_id: String) -> bool:
	if current_id != "Q_MS07_OBELISKS":
		return false
	if obelisk_id not in ["LOC_WAR_OBELISK_W","LOC_WAR_OBELISK_C","LOC_WAR_OBELISK_E"]:
		return false
	destroyed_obelisks[obelisk_id] = true
	if destroyed_obelisks.size() >= 3:
		_advance()
		return true
	return false

func register_boss(boss_id: String) -> bool:
	if current_id == "Q_MS07_GENERAL_VOID" and boss_id == "BOSS_GENERAL_ECO_VAZIO_001":
		act7_complete = true
		current_id = "Q_MS08_LAST_MAP_GATE"
		return true
	return false

func _advance() -> void:
	current_id = String(current().get("next",""))
