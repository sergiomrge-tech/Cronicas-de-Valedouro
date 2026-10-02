extends SceneTree
const Buildings = preload("res://scripts/cartoon/cartoon_building_assets_v040.gd")
const Env = preload("res://scripts/cartoon/hub_environment.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func run() -> void:
	var atlas: Image = Buildings.ATLAS.get_image()
	assert(atlas.get_size()==Vector2i(1448,1086))
	assert(Buildings.manifest.assets.size()==12)
	var regions: Array[Rect2] = []
	for key: String in Buildings.manifest.assets:
		var texture: AtlasTexture = Buildings.texture(key)
		assert(texture.atlas==Buildings.ATLAS)
		assert(Rect2(Vector2.ZERO,atlas.get_size()).encloses(texture.region))
		for other: Rect2 in regions: assert(not texture.region.intersects(other),"Buildings overlap in atlas")
		regions.append(texture.region)
		# Reject clipped roofs/foundations, including spires crossing regular grid cells.
		var image: Image = atlas.get_region(Rect2i(texture.region))
		for x in range(image.get_width()):
			assert(image.get_pixel(x,0).a<0.20 and image.get_pixel(x,image.get_height()-1).a<0.20,"Clipped sprite "+key)
		for y in range(image.get_height()):
			assert(image.get_pixel(0,y).a<0.20 and image.get_pixel(image.get_width()-1,y).a<0.20,"Clipped sprite "+key)
		var rect: Rect2 = Buildings.rect_for(key)
		var asset: Dictionary = Buildings.manifest.assets[key]
		var anchor = Vector2(asset.anchor[0],asset.anchor[1])
		assert((rect.position+anchor*rect.size/texture.region.size).length()<0.001)
		var bottom: int = -1
		for y in range(image.get_height()-1,-1,-1):
			for x in range(image.get_width()):
				if image.get_pixel(x,y).a>0.20: bottom = y; break
			if bottom>=0: break
		assert(absf(rect.position.y+bottom*rect.size.y/image.get_height())<=3.0,"Foundation floats: "+key)
	var keys: Dictionary = {}
	for variant in range(6): keys[Buildings.key_for("house",variant)] = true
	assert(keys.size()==6)
	assert(Buildings.key_for("tree").is_empty())
	assert(Buildings.key_for("house",-1)=="garden_cabin")
	var env = Env.new()
	root.add_child(env)
	await settle()
	assert(env.use_baked_ground and Env.CITY_GROUND.get_size()==Vector2(2048,2048))
	assert(env.nearest_poi(Region.world_from_hub(Vector2(720,790))).id=="POI_REG001_FORGE")
	assert(env.is_walkable(Region.world_from_hub(Vector2(300,900))))
	assert(not env.is_walkable(Region.world_from_hub(Vector2(720,730))))
	env.queue_free()
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	var hub = load("res://scenes/cartoon/ValedouroCartoonHub.tscn").instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	var bag = hub.inventory_ui
	assert(not bag.is_open())
	assert(bag.preview_viewport.render_target_update_mode==SubViewport.UPDATE_DISABLED)
	assert(not bag.preview_hero.is_processing())
	var idle: float = bag.preview_hero.anim_t
	await settle()
	assert(bag.preview_hero.anim_t==idle,"Hidden inventory hero still animates")
	bag.open_panel("equipment")
	await settle()
	assert(bag.preview_viewport.render_target_update_mode!=SubViewport.UPDATE_DISABLED)
	assert(bag.preview_hero.is_processing() and bag.preview_hero.anim_t>idle)
	bag.close_panel()
	await settle()
	assert(bag.preview_viewport.render_target_update_mode==SubViewport.UPDATE_DISABLED)
	assert(not bag.preview_hero.is_processing())
	bag.open_panel("materials")
	await settle()
	assert(bag.preview_hero.is_processing())
	bag.close_panel()
	hub.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_city_v040: PASS — 12 unclipped architectures, foundation contacts, cached ground, routes and inventory preview lifecycle")
	quit()
