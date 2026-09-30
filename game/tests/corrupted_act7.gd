extends SceneTree

const RegionScene = preload("res://scenes/cartoon/CorruptedLandsCartoon.tscn")
const Corrupted = preload("res://scripts/cartoon/corrupted/corrupted_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/corrupted/corrupted_story_map.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/corrupted/corrupted_story_runtime.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert(Corrupted.REGION_SIZE == Vector2(46000,47000))
	assert(Corrupted.ACTIVE_RADIUS == 2)
	assert(StoryMap.locations().size() == 5)
	assert(StoryMap.obelisks().size() == 3)
	assert(StoryMap.zones().size() == 5)
	assert(StoryMap.route_points().size() >= 10)
	var required: Dictionary = {}
	for row in StoryMap.locations():
		var id: String = String(row.get("id",""))
		required[id] = true
		assert(Corrupted.in_region(row.get("pos",Vector2.ZERO),64.0))
	for id in [
		"LOC_LAST_BASTION",
		"LOC_WAR_OBELISKS",
		"LOC_BROKEN_CATHEDRAL",
		"LOC_ALLIANCE_WAR_COUNCIL",
		"LOC_HOLLOW_CROWN_CITADEL"
	]:
		assert(required.has(id))

	var runtime: ValedouroCartoonCorruptedStoryRuntime = StoryRuntimeScript.new()
	assert(runtime.current_id == "Q_MS07_LAST_BASTION")
	assert(runtime.interact("LOC_LAST_BASTION"))
	assert(runtime.current_id == "Q_MS07_OBELISKS")
	assert(not runtime.destroy_obelisk("LOC_WAR_OBELISK_W"))
	assert(not runtime.destroy_obelisk("LOC_WAR_OBELISK_C"))
	assert(runtime.destroy_obelisk("LOC_WAR_OBELISK_E"))
	assert(runtime.current_id == "Q_MS07_CATHEDRAL")
	assert(runtime.interact("LOC_BROKEN_CATHEDRAL"))
	assert(runtime.current_id == "Q_MS07_COUNCIL")
	assert(runtime.interact("LOC_ALLIANCE_WAR_COUNCIL"))
	assert(runtime.current_id == "Q_MS07_GENERAL_VOID")
	assert(runtime.register_boss("BOSS_GENERAL_ECO_VAZIO_001"))
	assert(runtime.act7_complete)
	assert(runtime.current_id == "Q_MS08_LAST_MAP_GATE")

	var region: Node = RegionScene.instantiate()
	root.add_child(region)
	await process_frame
	await process_frame
	assert(region.get_node_or_null("WorldObjects") != null)
	assert(region.get_node_or_null("HUD") != null)
	assert(region.get_node_or_null("WorldObjects/Player") != null)
	assert(region.story_zones.get_child_count() == 5)
	assert(region.pois.size() == 15)
	assert(region.monsters.size() == 6)
	assert(region.map_overlay != null)
	assert(region.world_stream.active_count() >= 9)
	region._toggle_map()
	assert(region.map_open)
	region._toggle_map()
	assert(not region.map_open)
	region.hero.position = Vector2(23200,27000)
	region.world_stream._refresh(true)
	await process_frame
	assert(region.world_stream.active_count() >= 20)
	print("corrupted_act7: PASS — região 20x, obeliscos, 5 áreas canônicas e fluxo completo do Ato VII")
	quit(0)
