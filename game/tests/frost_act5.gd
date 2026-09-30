extends SceneTree

const FrostScene = preload("res://scenes/cartoon/FrostMountainsCartoon.tscn")
const Frost = preload("res://scripts/cartoon/frost/frost_region_config.gd")
const StoryMap = preload("res://scripts/cartoon/frost/frost_story_map.gd")
const StoryRuntimeScript = preload("res://scripts/cartoon/frost/frost_story_runtime.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert(Frost.REGION_SIZE == Vector2(34500,35250))
	assert(Frost.ACTIVE_RADIUS == 2)
	assert(StoryMap.locations().size() == 6)
	assert(StoryMap.zones().size() == 6)
	assert(StoryMap.route_points().size() >= 10)
	var required: Dictionary = {}
	for row in StoryMap.locations():
		var id: String = String(row.get("id",""))
		required[id] = true
		assert(Frost.in_region(row.get("pos",Vector2.ZERO),64.0))
	for id in [
		"LOC_FROST_REST",
		"LOC_FROZEN_EXPEDITION_STATION",
		"LOC_FROZEN_COMMAND_POST",
		"LOC_FROZEN_ARCHIVE",
		"LOC_BLACK_FROST_CITADEL",
		"LOC_VAL_GATE"
	]:
		assert(required.has(id))

	var runtime: ValedouroCartoonFrostStoryRuntime = StoryRuntimeScript.new()
	assert(runtime.current_id == "Q_MS05_FROST_REST")
	assert(runtime.interact("LOC_FROST_REST"))
	assert(runtime.current_id == "Q_MS05_EXPEDITION")
	assert(runtime.interact("LOC_FROZEN_EXPEDITION_STATION"))
	assert(runtime.current_id == "Q_MS05_CAPTAIN")
	assert(runtime.register_boss("BOSS_CAPITAO_GELO_001"))
	assert(runtime.current_id == "Q_MS05_ARCHIVE")
	assert(runtime.interact("LOC_FROZEN_ARCHIVE"))
	assert(runtime.current_id == "Q_MS05_BLACK_FROST")
	assert(runtime.register_boss("BOSS_GENERAL_GEADA_NEGRA_001"))
	assert(runtime.current_id == "Q_MS05_SIEGE")
	assert(runtime.siege_pending)
	assert(runtime.act5_region_complete)

	var frost: Node = FrostScene.instantiate()
	root.add_child(frost)
	await process_frame
	await process_frame
	assert(frost.get_node_or_null("WorldObjects") != null)
	assert(frost.get_node_or_null("HUD") != null)
	assert(frost.get_node_or_null("WorldObjects/Player") != null)
	assert(frost.story_zones.get_child_count() == 6)
	assert(frost.pois.size() == 13)
	assert(frost.monsters.size() == 5)
	assert(frost.map_overlay != null)
	assert(frost.world_stream.active_count() >= 9)
	frost._toggle_map()
	assert(frost.map_open)
	assert(frost.map_overlay.visible)
	frost._toggle_map()
	assert(not frost.map_open)
	frost.hero.position = Vector2(19800,16900)
	frost.world_stream._refresh(true)
	await process_frame
	assert(frost.world_stream.active_count() >= 20)
	print("frost_act5: PASS — região 15x, 6 áreas canônicas e retorno ao cerco preparado")
	quit(0)
