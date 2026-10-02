extends SceneTree
const Art = preload("res://scripts/cartoon/cartoon_hero_art_v042.gd")
const SpellArt = preload("res://scripts/cartoon/cartoon_spell_art_v042.gd")
const FX = preload("res://scripts/cartoon/cartoon_combat_fx.gd")
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(8): await process_frame
func run() -> void:
	for animation: String in Art.FRAMES:
		assert(Art.POSES[animation].size()==Art.FRAMES[animation])
	for direction: String in ["front","back","left","right"]:
		for animation: String in Art.FRAMES:
			for frame in range(Art.FRAMES[animation]):
				var data: Dictionary = Art.frame_data(direction,animation,frame)
				assert(data.region[2]>0 and data.region[3]>0)
				assert(data.anchor[1]>data.region[3]-8)
				assert(Art.hand_position(direction,animation,frame).is_finite())
				assert(Art.head_position(direction,animation,frame).is_finite())
				if animation=="shoot": assert(Art.pull_hand_position(direction,frame).is_finite())
	for spell: String in SpellArt.TEXTURES:
		assert(SpellArt.texture(spell,2)==SpellArt.texture(spell,2),"Spell frames must share resources")
		var impact = FX.spawn(root,Vector2.ZERO,"impact_"+spell)
		impact.set_process(false)
		assert(impact.spell_sprite.texture==SpellArt.texture(spell,3),"Impact flashed gathering frame")
		assert(impact.spell_sprite.material.light_mode==CanvasItemMaterial.LIGHT_MODE_UNSHADED)
		impact.queue_free()
	await settle()
	var effects: Array = []
	for i in range(48):
		var fx = FX.spawn(root,Vector2.ZERO,"ember")
		assert(fx!=null and fx.spell_sprite!=null)
		fx.set_process(false); effects.append(fx)
	assert(FX.active_count==48 and FX.light_count==8)
	assert(FX.spawn(root,Vector2.ZERO,"arcane")==null,"FX bypassed actor budget")
	for fx in effects: fx._process(2.0)
	await settle()
	assert(FX.active_count==0 and FX.light_count==0,"Expired effects leaked light/actor slots")
	var state = root.get_node("CartoonPlayerState"); state.reset_progress(true); state.start_new_game()
	var hub = load("res://scenes/cartoon/ValedouroCartoonHub.tscn").instantiate(); root.add_child(hub); current_scene = hub
	await settle(); hub.set_process(false)
	hub.hero.set_process(false)
	hub.hero.cast_spell_index = 1; hub.hero.cast_t = 0.4; hub.hero.refresh_spell_focus()
	var pose: Dictionary = hub.hero.visual_pose()
	assert(hub.hero.spell_focus.visible and hub.hero.spell_focus.texture==SpellArt.texture("frost",0))
	assert(hub.hero.spell_focus.position==Art.hand_position(pose.direction,"cast",pose.frame))
	hub.hero.hurt_t = 0.2; hub.hero.refresh_spell_focus()
	assert(not hub.hero.spell_focus.visible,"Hurt pose retained casting focus")
	hub.hero.cast_t = 0; hub.hero.hurt_t = 0
	var blocker_counts: Dictionary = {}
	for room: String in ["tavern","forge","guild"]:
		hub.interiors.enter(room)
		for prop in hub.interiors.room_objects.get_children():
			if prop.get_script()==preload("res://scripts/cartoon/cartoon_interior_art_v042.gd"):
				assert(prop.manifest.furniture.has(prop.key))
				if room=="guild" and String(prop.name) in ["counter","table"]: assert(prop.key.begins_with("guild_"))
		blocker_counts[room] = hub.interiors.blockers.size()
		assert(hub.interiors.nearest_point().id=="exit")
		hub.interiors.leave()
	assert(blocker_counts=={"tavern":18,"forge":12,"guild":11},"Painted art changed authored blockers: "+str(blocker_counts))
	root.size = Vector2i(640,360); root.content_scale_size = root.size
	hub.zoom_controls.set_zoom_value(1.50,false); await settle()
	assert(hub.camera.offset.y<0)
	var head_y: float = 180-hub.camera.offset.y*1.5-116*1.5
	assert(head_y>=110,"Mobile HUD covers raised hero")
	hub.zoom_controls.set_zoom_value(0.70,false)
	assert(hub.hero.spell_cooldowns.size()==3)
	state.reset_progress(true)
	print("cartoon_illustrated_v042: PASS — pose/hand/head anchors, shared spell frames, immediate impacts, 48 FX/8 lights, no leaks, authored interior blockers and mobile framing")
	quit()
