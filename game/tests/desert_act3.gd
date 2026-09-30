extends SceneTree

const DesertScene = preload("res://scenes/cartoon/DesertEdravarCartoon.tscn")
const Desert = preload("res://scripts/cartoon/desert/desert_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/desert/desert_story_map.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/desert/desert_story_runtime.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert(Desert.REGION_SIZE == Vector2(34500,35250))
	assert(Desert.ACTIVE_RADIUS == 2)
	assert(StoryMap.locations().size() == 6)
	assert(StoryMap.zones().size() == 6)
	assert(StoryMap.route_points().size() >= 10)

	var required: Dictionary = {}
	for row in StoryMap.locations():
		var id: String = String(row.get("id",""))
		required[id] = true
		assert(Desert.in_region(row.get("pos",Vector2.ZERO),64.0))
	for id in [
		"LOC_AMBER_CARAVAN",
		"LOC_AMBER_POST",
		"LOC_EDRAVAR_OCCUPIED_CITY",
		"LOC_EDRAVAR_RESISTANCE_CISTERN",
		"LOC_ASH_OBSERVATORY",
		"LOC_ASH_CITADEL"
	]:
		assert(required.has(id))

	var runtime: ValedouroCartoonDesertStoryRuntime = StoryRuntimeScript.new()
	assert(runtime.current_id == "Q_MS03_CARAVAN")
	assert(runtime.interact("LOC_AMBER_CARAVAN"))
	assert(runtime.escort_started)
	assert(runtime.current_id == "Q_MS03_CARAVAN")
	assert(runtime.interact("LOC_AMBER_POST"))
	assert(runtime.current_id == "Q_MS03_AMBER_POST")
	assert(runtime.interact("LOC_AMBER_POST"))
	assert(runtime.current_id == "Q_MS03_EDRAVAR")
	assert(runtime.interact("LOC_EDRAVAR_OCCUPIED_CITY"))
	assert(runtime.current_id == "Q_MS03_CISTERN")
	assert(runtime.interact("LOC_EDRAVAR_RESISTANCE_CISTERN"))
	assert(runtime.current_id == "Q_MS03_OBSERVATORY")
	assert(runtime.interact("LOC_ASH_OBSERVATORY"))
	assert(runtime.current_id == "Q_MS03_GENERAL_ASH")
	assert(runtime.register_boss("BOSS_GENERAL_CINZA_001"))
	assert(runtime.act3_complete)
	assert(runtime.current_id == "Q_MS04_STILTS")

	var desert: Node = DesertScene.instantiate()
	root.add_child(desert)
	await process_frame
	await process_frame
	assert(desert.get_node_or_null("WorldObjects") != null)
	assert(desert.get_node_or_null("HUD") != null)
	assert(desert.get_node_or_null("WorldObjects/Player") != null)
	assert(desert.story_zones.get_child_count() == 6)
	assert(desert.map_overlay != null)
	desert._toggle_map()
	assert(desert.map_open)
	assert(desert.map_overlay.visible)
	desert._toggle_map()
	assert(not desert.map_open)
	assert(desert.pois.size() == 14)
	assert(desert.monsters.size() == 7)
	assert(desert.world_stream.active_count() >= 9)
	desert.hero.position = Vector2(16800,22200)
	desert.world_stream._refresh(true)
	await process_frame
	assert(desert.world_stream.active_count() >= 20)
	print("desert_act3: PASS — região 15x, 6 áreas canônicas e fluxo completo do Ato III")
	quit(0)
