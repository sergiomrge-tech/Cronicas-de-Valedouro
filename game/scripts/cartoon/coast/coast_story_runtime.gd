class_name ValedouroCartoonCoastStoryRuntime
extends RefCounted

const STORY_PATH: String = "res://data/main_story_v1.json"

var quests: Dictionary = {}
var current_id: String = "Q_MS06_MIST_PORT"
var fleet_kills: int = 0
var act6_complete: bool = false

func _init() -> void:
	var file: FileAccess = FileAccess.open(STORY_PATH,FileAccess.READ)
	assert(file != null)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary)
	for q in (parsed as Dictionary).get("quests",[]):
		if int(q.get("act",0)) == 6:
			quests[String(q.get("id",""))] = q

func current() -> Dictionary:
	return quests.get(current_id,{}) as Dictionary

func title() -> String:
	return String(current().get("title",""))

func current_location() -> String:
	return String(current().get("loc",""))

func objective() -> String:
	if act6_complete:
		return "Ato VI concluído — a Aliança segue para as Terras Corrompidas"
	if current_id == "Q_MS06_HOLLOW_FLEET":
		return "Proteja o estaleiro e quebre o bloqueio — %d/4" % fleet_kills
	return String(current().get("objective",""))

func hud_text() -> String:
	if act6_complete:
		return "HISTÓRIA PRINCIPAL\nAto VI concluído — A Guerra das Oito Frentes"
	return "HISTÓRIA PRINCIPAL\n%s — %s" % [title(),objective()]

func interact(location_id: String) -> bool:
	if act6_complete or location_id != current_location():
		return false
	var kind: String = String(current().get("type",""))
	if kind in ["travel","activate","dungeon"]:
		_advance()
		return true
	return false

func register_fleet_kill(tag: String) -> bool:
	if current_id != "Q_MS06_HOLLOW_FLEET" or tag != "hollow_fleet":
		return false
	fleet_kills += 1
	if fleet_kills >= 4:
		_advance()
		return true
	return false

func register_boss(boss_id: String) -> bool:
	if current_id == "Q_MS06_GENERAL_TIDE" and boss_id == "BOSS_GENERAL_MARE_OCA_001":
		act6_complete = true
		current_id = "Q_MS07_LAST_BASTION"
		return true
	return false

func _advance() -> void:
	current_id = String(current().get("next",""))
