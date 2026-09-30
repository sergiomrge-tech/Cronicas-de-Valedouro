class_name ValedouroCartoonStoryRuntime
extends RefCounted

const STORY_PATH: String = "res://data/main_story_v1.json"

var quests: Dictionary = {}
var current_id: String = "Q_MS01_ARRIVAL"
var act1_complete: bool = false
var wolf_kills: int = 0

func _init() -> void:
	_load_story()

func _load_story() -> void:
	var file: FileAccess = FileAccess.open(STORY_PATH,FileAccess.READ)
	assert(file != null)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary)
	for q in (parsed as Dictionary).get("quests",[]):
		if int(q.get("act",0)) == 1:
			quests[String(q.get("id",""))] = q

func current() -> Dictionary:
	return quests.get(current_id,{}) as Dictionary

func title() -> String:
	return String(current().get("title",""))

func objective() -> String:
	if act1_complete:
		return "Ato I concluído — siga para a Ponte de Pedra da Floresta"
	if current_id == "Q_MS01_WOLVES":
		return "Afaste os lobos das trilhas ao norte — %d/3" % wolf_kills
	return String(current().get("objective",""))

func current_location() -> String:
	return String(current().get("loc",""))

func current_type() -> String:
	return String(current().get("type",""))

func try_location(location_id: String) -> bool:
	if act1_complete:
		return false
	if location_id != current_location():
		return false
	var kind: String = current_type()
	if kind in ["arrive","talk","investigate","dungeon","reveal"]:
		_advance()
		return true
	return false

func register_kill(monster_tag: String, boss_id: String = "") -> bool:
	if act1_complete:
		return false
	if current_id == "Q_MS01_WOLVES" and monster_tag == "story_wolf":
		wolf_kills += 1
		if wolf_kills >= 3:
			_advance()
			return true
		return false
	if current_id == "Q_MS01_ALPHA" and boss_id == "BOSS_ALPHA_MATILHA_001":
		_advance()
		return true
	if current_id == "Q_MS01_GUARDIAN" and boss_id == "BOSS_GUARDIAO_PEDRA_001":
		_advance()
		return true
	return false

func _advance() -> void:
	var q: Dictionary = current()
	var next_id: String = String(q.get("next",""))
	if current_id == "Q_MS01_ARCHIVE":
		act1_complete = true
		current_id = "Q_MS02_BORDER"
		return
	if quests.has(next_id):
		current_id = next_id
	else:
		current_id = next_id

func hud_text() -> String:
	if act1_complete:
		return "HISTÓRIA PRINCIPAL\nAto I concluído — Floresta Ancestral"
	var q: Dictionary = current()
	return "HISTÓRIA PRINCIPAL\n%s — %s" % [String(q.get("title","")),objective()]
