class_name ValedouroCartoonSiege
extends Node2D

const Difficulty = preload("res://scripts/cartoon/cartoon_difficulty.gd")
const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")
const SiegeRuntimeScript = preload("res://scripts/cartoon/valedouro_siege_runtime.gd")

var hub: Node
var runtime: RefCounted
var transition_timer: float = 0.0

func _ready() -> void:
	hub = HubScene.instantiate()
	add_child(hub)
	await get_tree().process_frame
	runtime = SiegeRuntimeScript.new()
	hub.story_runtime = runtime
	hub.hero.position = Region.world_from_hub(Vector2(1150,430))
	_bind_campaign_save()
	if hub.hud_status != null:
		hub.hud_status.region_label.text = "CERCO DE VALEDOURO"
		hub._refresh_stats()
	for monster in hub.monsters.duplicate():
		if is_instance_valid(monster) and not monster.is_in_group("cartoon_elite_demons"):
			hub.monsters.erase(monster)
			monster.queue_free()
	_spawn_attackers()
	hub.objective_label.text = runtime.hud_text()
	hub._update_objective_navigation()
	hub._show_toast("Azharel retaliou. Defenda o Portão de Valedouro!")

func _process(delta: float) -> void:
	if hub == null or runtime == null:
		return
	hub.objective_label.text = runtime.hud_text()
	if runtime.complete:
		transition_timer += delta
		if transition_timer > 1.0 and transition_timer < 3.0:
			hub._show_toast("Ato V concluído — o próximo chamado vem do Porto das Brumas.")
		if transition_timer > 3.2:
			_change_scene_saved("res://scenes/cartoon/CoastLostIslandsCartoon.tscn")

func _bind_campaign_save() -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null or hub == null or hub.hero == null:
		return
	state.bind_scene("res://scenes/cartoon/ValedouroSiegeCartoon.tscn",hub,hub.hero,runtime,45,245,290,[])
	hub._refresh_stats()
	hub.objective_label.text = runtime.hud_text()

func _change_scene_saved(path: String) -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state != null:
		state.prepare_transition(path)
	get_tree().change_scene_to_file(path)

func _spawn_attackers() -> void:
	var center: Vector2 = Region.world_from_hub(Vector2(1150,320))
	var rows: Array[Dictionary] = [
		{"kind":"goblin","name":"Invasor da Coroa Oca","pos":center+Vector2(-260,-280),"hp":88,"speed":84.0,"damage":14,"scale":1.08,"story_tag":"siege_attacker"},
		{"kind":"goblin","name":"Invasor da Coroa Oca","pos":center+Vector2(260,-250),"hp":88,"speed":84.0,"damage":14,"scale":1.08,"story_tag":"siege_attacker"},
		{"kind":"wolf","name":"Fera de Cerco","pos":center+Vector2(-150,-420),"hp":96,"speed":100.0,"damage":15,"scale":1.15,"story_tag":"siege_attacker"},
		{"kind":"wolf","name":"Fera de Cerco","pos":center+Vector2(170,-410),"hp":96,"speed":100.0,"damage":15,"scale":1.15,"story_tag":"siege_attacker"},
		{"kind":"guardian","name":"Quebrador de Portões","pos":center+Vector2(-80,-560),"hp":132,"speed":62.0,"damage":18,"scale":1.20,"story_tag":"siege_attacker"},
		{"kind":"guardian","name":"Quebrador de Portões","pos":center+Vector2(110,-590),"hp":132,"speed":62.0,"damage":18,"scale":1.20,"story_tag":"siege_attacker"}
	]
	for data in rows:
		var monster: Node2D = MonsterScript.new()
		monster.setup(Difficulty.monster_data(data,"REG_005_SIEGE_VALEDOURO"))
		hub.objects.add_child(monster)
		hub.monsters.append(monster)
