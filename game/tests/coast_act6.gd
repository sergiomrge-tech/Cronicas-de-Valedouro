extends SceneTree

const CoastScene = preload("res://scenes/cartoon/CoastLostIslandsCartoon.tscn")
const Coast = preload("res://scripts/cartoon/coast/coast_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/coast/coast_story_map.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/coast/coast_story_runtime.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert(Coast.REGION_SIZE == Vector2(46000,47000))
	assert(Coast.ACTIVE_RADIUS == 2)
	assert(StoryMap.locations().size() == 5)
	assert(StoryMap.zones().size() == 5)
	assert(StoryMap.route_points().size() >= 10)

	var required: Dictionary = {}
	for row in StoryMap.locations():
		var id: String = String(row.get("id",""))
		required[id] = true
		assert(Coast.in_region(row.get("pos",Vector2.ZERO),64.0))
	for id in [
		"LOC_MIST_PORT",
		"LOC_TWIN_LIGHTHOUSE",
		"LOC_SUNKEN_TEMPLE",
		"LOC_LOST_ISLAND_SHIPYARD",
		"LOC_TIDAL_OBSERVATORY"
	]:
		assert(required.has(id))

	var runtime: ValedouroCartoonCoastStoryRuntime = StoryRuntimeScript.new()
	assert(runtime.current_id == "Q_MS06_MIST_PORT")
	assert(runtime.interact("LOC_MIST_PORT"))
	assert(runtime.current_id == "Q_MS06_LIGHTHOUSE")
	assert(runtime.interact("LOC_TWIN_LIGHTHOUSE"))
	assert(runtime.current_id == "Q_MS06_SUNKEN_TEMPLE")
	assert(runtime.interact("LOC_SUNKEN_TEMPLE"))
	assert(runtime.current_id == "Q_MS06_HOLLOW_FLEET")
	for i in range(3):
		assert(not runtime.register_fleet_kill("hollow_fleet"))
	assert(runtime.register_fleet_kill("hollow_fleet"))
	assert(runtime.current_id == "Q_MS06_GENERAL_TIDE")
	assert(runtime.register_boss("BOSS_GENERAL_MARE_OCA_001"))
	assert(runtime.act6_complete)
	assert(runtime.current_id == "Q_MS07_LAST_BASTION")

	var coast: Node = CoastScene.instantiate()
	root.add_child(coast)
	await process_frame
	await process_frame
	assert(coast.get_node_or_null("WorldObjects") != null)
	assert(coast.get_node_or_null("HUD") != null)
	assert(coast.get_node_or_null("WorldObjects/Player") != null)
	assert(coast.story_zones.get_child_count() == 5)
	assert(coast.pois.size() == 12)
	assert(coast.monsters.filter(func(m): return not m.is_in_group("cartoon_elite_demons")).size() == 9)
	assert(coast.map_overlay != null)
	assert(coast.world_stream.active_count() >= 9)
	coast._toggle_map()
	assert(coast.map_open)
	assert(coast.map_overlay.visible)
	coast._toggle_map()
	assert(not coast.map_open)
	coast.hero.position = Vector2(22200,28600)
	coast.world_stream._refresh(true)
	await process_frame
	assert(coast.world_stream.active_count() >= 20)
	print("coast_act6: PASS — região 20x, 5 áreas canônicas e fluxo completo do Ato VI")
	quit(0)
