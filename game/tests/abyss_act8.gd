extends SceneTree

const RegionScene = preload("res://scenes/cartoon/AbyssHeartCartoon.tscn")
const Abyss = preload("res://scripts/cartoon/abyss/abyss_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/abyss/abyss_story_map.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/abyss/abyss_story_runtime.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert(Abyss.REGION_SIZE == Vector2(18400,18800))
	assert(Abyss.ACTIVE_RADIUS == 2)
	assert(StoryMap.locations().size() == 6)
	assert(StoryMap.zones().size() == 6)
	assert(StoryMap.route_points().size() >= 9)
	var required: Dictionary = {}
	for row in StoryMap.locations():
		var id: String = String(row.get("id",""))
		required[id] = true
		assert(Abyss.in_region(row.get("pos",Vector2.ZERO),64.0))
	for id in [
		"LOC_LAST_MAP_GATE",
		"LOC_HALL_LOST_PATHS",
		"LOC_VOID_ARCHIVE",
		"LOC_EMPTY_THRONE_ANTECHAMBER",
		"LOC_EMPTY_THRONE",
		"LOC_EARTH_GATE"
	]:
		assert(required.has(id))

	var runtime: ValedouroCartoonAbyssStoryRuntime = StoryRuntimeScript.new()
	assert(runtime.current_id == "Q_MS08_LAST_MAP_GATE")
	assert(runtime.interact("LOC_LAST_MAP_GATE"))
	assert(runtime.current_id == "Q_MS08_LOST_PATHS")
	assert(runtime.interact("LOC_HALL_LOST_PATHS"))
	assert(runtime.current_id == "Q_MS08_CARTOGRAPHER")
	assert(runtime.register_boss("BOSS_CARTOGRAFO_VAZIO_001"))
	assert(runtime.current_id == "Q_MS08_FIRST_TRAVELER")
	assert(runtime.interact("LOC_EMPTY_THRONE_ANTECHAMBER"))
	assert(runtime.current_id == "Q_MS08_AZHAREL")
	assert(runtime.register_boss("BOSS_AZHAREL_001"))
	assert(runtime.current_id == "Q_MS08_EARTH_GATE")
	assert(runtime.interact("LOC_EARTH_GATE"))
	assert(runtime.current_id == "Q_MS08_CHOICE")
	assert(runtime.choose_ending("return"))
	assert(runtime.campaign_complete)
	assert(runtime.ending == "Retorno à Terra")

	var region: Node = RegionScene.instantiate()
	root.add_child(region)
	await process_frame
	await process_frame
	assert(region.get_node_or_null("WorldObjects") != null)
	assert(region.get_node_or_null("HUD") != null)
	assert(region.get_node_or_null("WorldObjects/Player") != null)
	assert(region.story_zones.get_child_count() == 6)
	assert(region.pois.size() == 12)
	assert(region.monsters.size() == 5)
	assert(region.map_overlay != null)
	assert(region.choice_panel != null)
	assert(region.world_stream.active_count() >= 9)
	region._toggle_map()
	assert(region.map_open)
	region._toggle_map()
	assert(not region.map_open)
	region.story_runtime.current_id = "Q_MS08_CHOICE"
	region._show_choice()
	assert(region.choice_panel.visible)
	region.choice_panel.visible = false
	region.hero.position = Vector2(9200,7500)
	region.world_stream._refresh(true)
	await process_frame
	assert(region.world_stream.active_count() >= 20)
	print("abyss_act8: PASS — região final 8x, 6 áreas canônicas, bosses e escolha final")
	quit(0)
