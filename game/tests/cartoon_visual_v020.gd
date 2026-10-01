extends SceneTree
## Regression gates for the new art pass: routes and streamed sprite ownership.

const Env = preload("res://scripts/cartoon/hub_environment.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
const Landscape = preload("res://scripts/cartoon/cartoon_landscape_layout.gd")
const Exploration = preload("res://scripts/cartoon/cartoon_exploration_content.gd")
const Story = preload("res://scripts/cartoon/cartoon_main_story_map.gd")
const Assets = preload("res://scripts/cartoon/cartoon_visual_assets.gd")
const Stream = preload("res://scripts/cartoon/cartoon_world_stream.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var env = Env.new()
	root.add_child(env)
	await process_frame
	# Flood fill tests actual collisions, including the regenerated town groves.
	var start: Vector2i = Vector2i(46,13)
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = {start:true}
	var cursor: int = 0
	while cursor < queue.size():
		var cell: Vector2i = queue[cursor]
		cursor += 1
		for delta: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+delta
			if next.x < 1 or next.y < -68 or next.x > 140 or next.y > 93 or visited.has(next): continue
			if not env.is_walkable(Region.world_from_hub(Vector2(next)*25.0)): continue
			visited[next] = true
			queue.append(next)
	for poi: Dictionary in env.pois:
		var reached: bool = false
		for cell: Vector2i in queue:
			if Region.world_from_hub(Vector2(cell)*25.0).distance_to(poi["pos"]) < 135.0:
				reached = true
				break
		assert(reached,"Unreachable town POI: "+String(poi["id"]))
	assert(env.is_walkable(Region.world_from_hub(Vector2(300,900))),"West bridge blocked")
	assert(env.is_walkable(Region.world_from_hub(Vector2(2080,870))),"East bridge blocked")
	for landmark: Dictionary in Exploration.landmarks():
		assert(Landscape.near_road(landmark["pos"],55.0),"Exploration landmark lacks a road")
	for location: Dictionary in Story.act1_locations():
		if not Region.in_authored_hub(location["pos"]):
			assert(Landscape.near_road(location["pos"],55.0),"Story location lacks a road")
	for name: String in ["tree_0","tree_1","tree_2","pine","bush","rock","house_0","house_1","house_2","forge","tavern","guild","alchemist","archive","castle","fountain","market","ruin","mine","barrel","grass","wolf","guardian","lamp","bench","well","bridge","shrine","windmill","hero_front","hero_back","hero_left","hero_right"]:
		var texture: Texture2D = Assets.texture(name)
		assert(texture != null and texture.get_width() > 0,"Missing sprite: "+name)
	for direction: String in ["front","back","left","right"]:
		for frame in range(2):
			assert(Assets.texture("hero_%s_walk_%d" % [direction,frame]) != null)
	for name: String in ["hay","chest","fence"]:
		assert(Assets.texture(name) != null)
	# Travel across chunks repeatedly: foliage must share y-sort with the hero,
	# and stale sprites must disappear when their ground chunks are retired.
	var sorted_root: Node2D = Node2D.new()
	sorted_root.y_sort_enabled = true
	root.add_child(sorted_root)
	var hero: Node2D = Node2D.new()
	root.add_child(hero)
	var stream = Stream.new()
	root.add_child(stream)
	hero.position = Vector2(8100,11500)
	stream.setup(hero,sorted_root)
	stream.set_process(false)
	for pos: Vector2 in [Vector2(8100,4200),Vector2(4200,11800),Vector2(12500,14000),Vector2(8100,11500)]:
		hero.position = pos
		stream._refresh(true)
		await process_frame
		await process_frame
		var expected: int = 0
		for chunk in stream.active_chunks.values():
			expected += chunk.owned_props.size()
			for prop in chunk.owned_props:
				assert(prop.get_parent() == sorted_root,"Foliage lost shared y-sort")
				assert(not chunk._reserved_clearing(prop.position),"Vegetation covers a reserved mission clearing")
		assert(sorted_root.get_child_count() == expected,"Stale streamed sprites leaked")
	stream.queue_free()
	await process_frame
	await process_frame
	assert(sorted_root.get_child_count() == 0,"Stream teardown left orphan sprites")
	sorted_root.queue_free(); hero.queue_free(); env.queue_free()
	print("cartoon_visual_v020: PASS — POI reachability, bridges, road access, 44 sprites, y-sort and streaming cleanup")
	quit(0)
