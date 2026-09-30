extends SceneTree

const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const EnvScript = preload("res://scripts/cartoon/hub_environment.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var env := EnvScript.new()
	root.add_child(env)
	await process_frame
	assert(env.props.size() >= 105)
	assert(env.pois.size() >= 9)
	assert(env.WORLD_SIZE == Vector2(2300,1700))
	assert(env.is_walkable(Vector2(1150,970)))
	assert(not env.is_walkable(Vector2(1150,510)))
	var near := env.nearest_poi(Vector2(1150,560),180.0)
	assert(String(near.get("id","")) == "POI_REG001_CASTLE")
	var prop := PropScript.new(); prop.setup({"kind":"tree","pos":Vector2(10,10),"scale":1.0}); root.add_child(prop)
	var hero := HeroScript.new(); root.add_child(hero); hero.set_motion(Vector2.RIGHT); hero.trigger_attack()
	var packed := HubScene.instantiate(); root.add_child(packed)
	await process_frame
	await process_frame
	assert(packed.get_node_or_null("WorldObjects") != null)
	assert(packed.get_node_or_null("HUD") != null)
	assert(packed.get_node_or_null("WorldObjects/Player") != null)
	print("cartoon_hub: PASS — hub central vetorial carregado e jogável")
	quit(0)
