class_name ValedouroCartoonSiegeRuntime
extends RefCounted

var current_id: String = "Q_MS05_SIEGE"
var act1_complete: bool = false
var complete: bool = false
var kills: int = 0
var required_kills: int = 6

func current_location() -> String:
	return "LOC_VAL_GATE"

func title() -> String:
	return "As Muralhas de Valedouro"

func hud_text() -> String:
	if complete:
		return "HISTÓRIA PRINCIPAL\nValedouro resistiu — siga para o Porto da Névoa"
	return "HISTÓRIA PRINCIPAL\nAs Muralhas de Valedouro — defensores %d/%d" % [kills,required_kills]

func try_location(_location_id: String) -> bool:
	return false

func register_kill(story_tag: String, _boss_id: String = "") -> bool:
	if complete or story_tag != "siege_attacker":
		return false
	kills += 1
	if kills >= required_kills:
		complete = true
		return true
	return false
