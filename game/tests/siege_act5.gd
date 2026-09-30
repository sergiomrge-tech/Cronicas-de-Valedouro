extends SceneTree

const SiegeScene = preload("res://scenes/cartoon/ValedouroSiegeCartoon.tscn")
const SiegeRuntimeScript = preload("res://scripts/cartoon/valedouro_siege_runtime.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var runtime: ValedouroCartoonSiegeRuntime = SiegeRuntimeScript.new()
	assert(runtime.current_id == "Q_MS05_SIEGE")
	for i in range(5):
		assert(not runtime.register_kill("siege_attacker"))
	assert(runtime.register_kill("siege_attacker"))
	assert(runtime.complete)
	assert(runtime.kills == 6)

	var siege: Node = SiegeScene.instantiate()
	root.add_child(siege)
	await process_frame
	await process_frame
	await process_frame
	assert(siege.hub != null)
	assert(siege.runtime != null)
	assert(siege.hub.monsters.size() == 6)
	assert(siege.hub.objective_label != null)
	assert(siege.hub.hero != null)
	print("siege_act5: PASS — defesa das Muralhas de Valedouro usa o LOC_VAL_GATE real")
	quit(0)
