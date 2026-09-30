extends SceneTree

const HubScene = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const EnvScript = preload("res://scripts/cartoon/hub_environment.gd")
const HeroScript = preload("res://scripts/cartoon/cartoon_hero.gd")
const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const MainStoryMap = preload("res://scripts/cartoon/cartoon_main_story_map.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var env = EnvScript.new()
	root.add_child(env)
	await process_frame
	assert(env.props.size() >= 118)
	assert(env.pois.size() >= 9)
	assert(env.WORLD_SIZE == Vector2(16100,16450))
	assert(env.is_walkable(Region.world_from_hub(Vector2(1150,970))))
	assert(not env.is_walkable(Region.world_from_hub(Vector2(1150,510))))
	var near = env.nearest_poi(Region.world_from_hub(Vector2(1150,560)),180.0)
	assert(String(near.get("id","")) == "POI_REG001_CASTLE")
	var prop = PropScript.new(); prop.setup({"kind":"tree","pos":Vector2(10,10),"scale":1.0}); root.add_child(prop)
	var hero = HeroScript.new(); root.add_child(hero); hero.set_motion(Vector2.RIGHT); hero.trigger_attack()
	var packed = HubScene.instantiate(); root.add_child(packed)
	await process_frame
	await process_frame
	assert(packed.get_node_or_null("WorldObjects") != null)
	assert(packed.get_node_or_null("HUD") != null)
	assert(packed.get_node_or_null("WorldObjects/Player") != null)
	assert(packed.monsters.size() == 12)
	assert(packed.environment.nearest_poi(Region.world_from_hub(Vector2(650,1935)),190.0).get("id","") == "POI_REG001_FARM")
	assert(packed.world_stream != null)
	assert(packed.world_stream.active_count() >= 1)
	var roadside: Dictionary = packed.environment.nearest_poi(Vector2(Region.SOUTH_ROAD_X-330.0,Region.HUB_RECT.end.y+1350.0),180.0)
	assert(String(roadside.get("id","")) == "POI_REG001_ROADSIDE_POST")
	var poi_ids: Dictionary = {}
	for poi in packed.environment.pois:
		poi_ids[String(poi.get("id",""))] = true
	for required_id in MainStoryMap.required_ids_by_act()[1]:
		assert(poi_ids.has(String(required_id)))
	for story_loc in MainStoryMap.act1_locations():
		assert(Region.in_region(story_loc.get("pos",Vector2.ZERO),64.0))
	packed.hero.position = Vector2(Region.SOUTH_ROAD_X,Region.HUB_RECT.end.y + 3600.0)
	await process_frame
	await process_frame
	assert(packed.world_stream.active_count() >= 9)
	assert(packed.environment.is_walkable(packed.hero.position))
	print("cartoon_hub: PASS — hub 7x, streaming e 8 áreas obrigatórias do Ato I presentes")
	quit(0)
