extends SceneTree

const ForestScene = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")
const Forest = preload("res://scripts/cartoon/forest/forest_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/forest/forest_story_map.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/forest/forest_story_runtime.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert(Forest.REGION_SIZE == Vector2(46000,47000))
	assert(Forest.ACTIVE_RADIUS == 2)
	assert(StoryMap.locations().size() == 6)
	assert(StoryMap.root_subshrines().size() == 3)
	assert(StoryMap.route_points().size() >= 12)

	var required: Dictionary = {}
	for row in StoryMap.locations():
		required[String(row.get("id",""))] = true
	for loc_id in [
		"LOC_FOREST_STONE_BRIDGE",
		"LOC_FOREST_RANGER_LODGE",
		"LOC_FOREST_ROOT_SHRINES",
		"LOC_MEMORY_TREE",
		"LOC_HOLLOW_ROOT_ARENA",
		"LOC_FOREST_CARTOGRAPHER_SHRINE"
	]:
		assert(required.has(loc_id))
		assert(Forest.in_region(_location_pos(loc_id),64.0))

	var runtime: ValedouroCartoonForestStoryRuntime = StoryRuntimeScript.new()
	assert(runtime.current_id == "Q_MS02_BORDER")
	assert(runtime.try_location("LOC_FOREST_STONE_BRIDGE"))
	assert(runtime.current_id == "Q_MS02_RANGERS")
	for i in range(3):
		assert(not runtime.register_defense_kill("forest_defense"))
	assert(runtime.register_defense_kill("forest_defense"))
	assert(runtime.current_id == "Q_MS02_ROOTS")
	assert(not runtime.activate_root_shrine("LOC_FOREST_ROOT_SHRINE_W"))
	assert(not runtime.activate_root_shrine("LOC_FOREST_ROOT_SHRINE_C"))
	assert(runtime.activate_root_shrine("LOC_FOREST_ROOT_SHRINE_E"))
	assert(runtime.current_id == "Q_MS02_MEMORY_TREE")
	assert(runtime.try_location("LOC_MEMORY_TREE"))
	assert(runtime.current_id == "Q_MS02_HOLLOW_ROOT")
	assert(runtime.register_boss("BOSS_RAIZ_OCA_001"))
	assert(runtime.current_id == "Q_MS02_VEIL_SHRINE")
	assert(runtime.try_location("LOC_FOREST_CARTOGRAPHER_SHRINE"))
	assert(runtime.act2_complete)
	assert(runtime.current_id == "Q_MS03_CARAVAN")

	var forest: Node = ForestScene.instantiate()
	root.add_child(forest)
	await process_frame
	await process_frame
	assert(forest.get_node_or_null("WorldObjects") != null)
	assert(forest.get_node_or_null("HUD") != null)
	assert(forest.get_node_or_null("WorldObjects/Player") != null)
	assert(forest.world_stream.active_count() >= 9)
	assert(forest.pois.size() == 16)
	assert(forest.monsters.size() == 9)
	forest.hero.position = Vector2(23000,23500)
	forest.world_stream._refresh(true)
	await process_frame
	assert(forest.world_stream.active_count() >= 20)
	print("forest_act2: PASS — região 20x, 6 áreas canônicas e fluxo completo do Ato II")
	quit(0)

func _location_pos(id: String) -> Vector2:
	for row in StoryMap.locations():
		if String(row.get("id","")) == id:
			return row.get("pos",Vector2.ZERO)
	return Vector2.ZERO
