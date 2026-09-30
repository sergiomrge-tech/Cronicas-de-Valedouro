extends SceneTree

const MarshScene = preload("res://scenes/cartoon/MarshDarkCartoon.tscn")
const Marsh = preload("res://scripts/cartoon/marsh/marsh_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/marsh/marsh_story_map.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/marsh/marsh_story_runtime.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert(Marsh.REGION_SIZE == Vector2(34500,35250))
	assert(Marsh.ACTIVE_RADIUS == 2)
	assert(StoryMap.locations().size() == 6)
	assert(StoryMap.zones().size() == 6)
	assert(StoryMap.route_points().size() >= 12)

	var required: Dictionary = {}
	for row in StoryMap.locations():
		var id: String = String(row.get("id",""))
		required[id] = true
		assert(Marsh.in_region(row.get("pos",Vector2.ZERO),64.0))
	for id in [
		"LOC_MARSH_STILT_VILLAGE",
		"LOC_DROWNED_BELL_TOWER",
		"LOC_FLOODED_MONASTERY",
		"LOC_REED_SANCTUM",
		"LOC_REED_THRONE",
		"LOC_MARSH_ECHO_SLICE"
	]:
		assert(required.has(id))

	var runtime: ValedouroCartoonMarshStoryRuntime = StoryRuntimeScript.new()
	assert(runtime.current_id == "Q_MS04_STILTS")
	assert(runtime.interact("LOC_MARSH_STILT_VILLAGE"))
	assert(runtime.current_id == "Q_MS04_BELL")
	assert(runtime.interact("LOC_DROWNED_BELL_TOWER"))
	assert(runtime.current_id == "Q_MS04_MONASTERY")
	assert(runtime.interact("LOC_FLOODED_MONASTERY"))
	assert(runtime.current_id == "Q_MS04_REED_SANCTUM")
	assert(runtime.interact("LOC_REED_SANCTUM"))
	assert(runtime.current_id == "Q_MS04_LADY_REEDS")
	assert(runtime.register_boss("BOSS_DAMA_JUNCOS_001"))
	assert(runtime.current_id == "Q_MS04_SLICE_GATE")
	assert(runtime.interact("LOC_MARSH_ECHO_SLICE"))
	assert(runtime.act4_complete)
	assert(runtime.current_id == "Q_MS05_FROST_REST")

	var marsh: Node = MarshScene.instantiate()
	root.add_child(marsh)
	await process_frame
	await process_frame
	assert(marsh.get_node_or_null("WorldObjects") != null)
	assert(marsh.get_node_or_null("HUD") != null)
	assert(marsh.get_node_or_null("WorldObjects/Player") != null)
	assert(marsh.story_zones.get_child_count() == 6)
	assert(marsh.pois.size() == 13)
	assert(marsh.monsters.size() == 6)
	assert(marsh.map_overlay != null)
	assert(marsh.world_stream.active_count() >= 9)
	marsh._toggle_map()
	assert(marsh.map_open)
	assert(marsh.map_overlay.visible)
	marsh._toggle_map()
	assert(not marsh.map_open)
	marsh.hero.position = Vector2(19500,22800)
	marsh.world_stream._refresh(true)
	await process_frame
	assert(marsh.world_stream.active_count() >= 20)
	print("marsh_act4: PASS — região 15x, 6 áreas canônicas, mapa e fluxo completo do Ato IV")
	quit(0)
