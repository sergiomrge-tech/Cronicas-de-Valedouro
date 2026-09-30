class_name ValedouroCartoonForestStoryRuntime
extends RefCounted

const STORY_PATH: String = "res://data/main_story_v1.json"

var quests: Dictionary = {}
var current_id: String = "Q_MS02_BORDER"
var defend_kills: int = 0
var shrines_active: Dictionary = {}
var act2_complete: bool = false

func _init() -> void:
	var file: FileAccess = FileAccess.open(STORY_PATH,FileAccess.READ)
	assert(file != null)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary)
	for q in (parsed as Dictionary).get("quests",[]):
		if int(q.get("act",0)) == 2:
			quests[String(q.get("id",""))] = q

func current() -> Dictionary:
	return quests.get(current_id,{}) as Dictionary

func title() -> String:
	return String(current().get("title",""))

func current_location() -> String:
	return String(current().get("loc",""))

func objective() -> String:
	if act2_complete:
		return "Ato II concluído — a rota aponta para Edravar"
	match current_id:
		"Q_MS02_RANGERS":
			return "Defenda a Casa dos Guardas Verdes — %d/4" % defend_kills
		"Q_MS02_ROOTS":
			return "Purifique os três Santuários de Raiz — %d/3" % shrines_active.size()
		_:
			return String(current().get("objective",""))

func hud_text() -> String:
	if act2_complete:
		return "HISTÓRIA PRINCIPAL\nAto II concluído — Cinzas de Edravar"
	return "HISTÓRIA PRINCIPAL\n%s — %s" % [title(),objective()]

func try_location(location_id: String) -> bool:
	if act2_complete or location_id != current_location():
		return false
	var kind: String = String(current().get("type",""))
	if kind in ["travel","investigate","reveal"]:
		_advance()
		return true
	return false

func register_defense_kill(tag: String) -> bool:
	if current_id != "Q_MS02_RANGERS" or tag != "forest_defense":
		return false
	defend_kills += 1
	if defend_kills >= 4:
		_advance()
		return true
	return false

func activate_root_shrine(shrine_id: String) -> bool:
	if current_id != "Q_MS02_ROOTS":
		return false
	if shrine_id not in ["LOC_FOREST_ROOT_SHRINE_W","LOC_FOREST_ROOT_SHRINE_C","LOC_FOREST_ROOT_SHRINE_E"]:
		return false
	shrines_active[shrine_id] = true
	if shrines_active.size() >= 3:
		_advance()
		return true
	return false

func register_boss(boss_id: String) -> bool:
	if current_id == "Q_MS02_HOLLOW_ROOT" and boss_id == "BOSS_RAIZ_OCA_001":
		_advance()
		return true
	return false

func _advance() -> void:
	var next_id: String = String(current().get("next",""))
	if current_id == "Q_MS02_VEIL_SHRINE":
		act2_complete = true
		current_id = "Q_MS03_CARAVAN"
		return
	current_id = next_id
