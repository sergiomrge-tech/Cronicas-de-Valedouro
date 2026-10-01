extends SceneTree
const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Monster = preload("res://scripts/cartoon/cartoon_monster.gd")
const Hero = preload("res://scripts/cartoon/cartoon_hero.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
var output: String
var hub
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func shot(key: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(key+".png"))
func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	root.size = Vector2i(960,640)
	root.content_scale_size = root.size
	hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.hero.position = Region.world_from_hub(Vector2(1150,1850))
	hub.camera.reset_smoothing()
	# Freeze world simulation for a controlled visual inspection, while UI/rendering stays live.
	hub.set_process(false)
	hub.wildlife.set_process(false)
	for animal in hub.wildlife.active.values(): animal.set_process(false)
	for monster in hub.monsters: monster.set_process(false)
	state.add_material("Osso de caça",40)
	state.add_material("Couro do Vale",40)
	for row in state.recipes_for("REG_001_BERCO_VALEDOURO"): state.craft_item("REG_001_BERCO_VALEDOURO",row.id)
	hub.hero.apply_equipment_from_state()
	hub.inventory_ui.open_panel("armor")
	await shot("full_set_inventory")
	hub.inventory_ui.open_panel("weapon")
	await shot("bow_inventory")
	hub.inventory_ui.close_panel()
	hub.crafting_ui._toggle()
	await shot("forge")
	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	await shot("forge_mobile")
	hub.crafting_ui.recipe_list.get_parent().scroll_vertical = 350
	await shot("forge_mobile_scrolled")
	hub.crafting_ui.close_panel()
	hub.inventory_ui.open_panel("weapon")
	await shot("bow_inventory_mobile")
	hub.inventory_ui.close_panel()
	root.size = Vector2i(960,640)
	root.content_scale_size = root.size
	var target = Monster.new()
	target.kind = "wolf"
	target.hp = 200
	target.max_hp = 200
	hub.objects.add_child(target)
	target.position = hub.hero.position+Vector2(220,0)
	target.set_process(false)
	hub.monsters.append(target)
	hub.hero.set_process(false)
	var arrow = hub.hero.launch_arrow(hub,target,18)
	assert(arrow!=null)
	arrow.set_process(false)
	for frame in range(3):
		assert(is_instance_valid(arrow) and not arrow.is_queued_for_deletion())
		arrow._process(0.03)
		hub.hero.attack_t = 0.65-frame*0.055
		hub.hero.queue_redraw()
		await shot("bow_flight_%02d" % frame)
	hub.queue_free()
	await settle()
	root.size = Vector2i(960,640)
	root.content_scale_size = root.size
	var gallery = Node2D.new()
	root.add_child(gallery)
	current_scene = gallery
	var bg = ColorRect.new()
	bg.color = Color("182d37")
	bg.size = Vector2(960,640)
	gallery.add_child(bg)
	var title = Label.new()
	title.text = "CRÔNICAS DE VALEDOURO • HERÓI / EQUIPAMENTO"
	title.position = Vector2(44,20)
	title.add_theme_font_size_override("font_size",22)
	gallery.add_child(title)
	var heroes: Array = []
	for i in range(8):
		var actor = Hero.new()
		gallery.add_child(actor)
		actor.position = Vector2(130+(i%4)*230,310+(i/4)*285)
		actor.scale = Vector2(2,2)
		actor.set_process(false)
		actor.facing = [Vector2.DOWN,Vector2.UP,Vector2.LEFT,Vector2.RIGHT][i%4]
		actor.bow_equipped = i>=4
		var label = Label.new()
		label.position = Vector2(actor.position.x-70,actor.position.y+23)
		label.text = ["Frente","Costas","Esquerda","Direita"][i%4]+(" • arco" if i>=4 else " • espada")
		label.add_theme_font_size_override("font_size",16)
		gallery.add_child(label)
		heroes.append(actor)
	for frame in range(12):
		for i in range(8):
			var actor = heroes[i]
			actor.anim_t = frame/12.0
			actor.move_vector = actor.facing
			actor.attack_t = 0
			actor.queue_redraw()
		await shot("walk_%02d" % frame)
	for frame in range(8):
		for i in range(8):
			var actor = heroes[i]
			actor.move_vector = Vector2.ZERO
			actor.attack_t = 0.65*(1-frame/8.0) if i>=4 else 0.28*(1-frame/8.0)
			actor.queue_redraw()
		await shot("attack_%02d" % frame)
	for frame in range(8):
		for actor in heroes:
			actor.attack_t = 0
			actor.cast_spell_index = frame%3
			actor.cast_t = 0.65*(1-frame/8.0)
			actor.queue_redraw()
		await shot("cast_%02d" % frame)
	print("equipment_v028 QA: real forge, seven slots, archery, 4-direction animation captured")
	quit()
