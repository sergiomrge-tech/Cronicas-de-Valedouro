extends SceneTree
const Art = preload("res://scripts/cartoon/cartoon_hero_art_v042.gd")
const Hero = preload("res://scripts/cartoon/cartoon_hero.gd")
const FX = preload("res://scripts/cartoon/cartoon_combat_fx.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
class FrameProbe extends Node2D:
	const Art = preload("res://scripts/cartoon/cartoon_hero_art_v042.gd")
	var direction: String
	var animation: String
	var frame: int
	func _draw() -> void: Art.hero_frame(self,direction,animation,frame,Art.GROUND_RECT)
var output: String
var shots: Array = []
var max_calls: int = 0
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in range(6): await process_frame
func shot(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png"))==OK)
	var calls: int = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	assert(calls>0 and calls<2000,"Illustrated render budget regressed")
	max_calls = maxi(max_calls,calls)
	shots.append({"name":name,"size":[root.size.x,root.size.y],"draw_calls":calls})
func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(128,128); root.content_scale_size = root.size; root.transparent_bg = true
	var probe = FrameProbe.new(); probe.position = Vector2(64,110); root.add_child(probe)
	var checked: int = 0
	for direction in ["front","back","left","right"]:
		for animation: String in Art.FRAMES:
			for frame in range(Art.FRAMES[animation]):
				probe.direction = direction; probe.animation = animation; probe.frame = frame; probe.queue_redraw()
				await process_frame; await RenderingServer.frame_post_draw
				var image: Image = root.get_texture().get_image()
				var lowest: int = -1
				for y in range(127,-1,-1):
					for x in range(128):
						if image.get_pixel(x,y).a>0.20: lowest = y; break
					if lowest>=0: break
				assert(absi(lowest-110)<=2,"Floating illustrated pose %s/%s/%d: %d"%[direction,animation,frame,lowest])
				checked += 1
	probe.queue_free(); await settle(); root.transparent_bg = false
	root.size = Vector2i(960,540); root.content_scale_size = root.size
	# Real Hero actors, including class palette, equipped pieces, sword, bow and pose anchors.
	var gallery = Node2D.new(); root.add_child(gallery)
	var heroes: Array = []
	for i in range(8):
		var actor = Hero.new(); gallery.add_child(actor); actor.set_process(false)
		actor.position = Vector2(120+(i%4)*240,235+(i/4)*265); actor.scale = Vector2(1.7,1.7)
		actor.facing = [Vector2.DOWN,Vector2.UP,Vector2.LEFT,Vector2.RIGHT][i%4]
		actor.bow_equipped = i>=4; heroes.append(actor)
	for animation: String in Art.FRAMES:
		for frame in range(Art.FRAMES[animation]):
			for actor in heroes:
				actor.move_vector = Vector2.ZERO; actor.attack_t = 0; actor.cast_t = 0; actor.hurt_t = 0; actor.death_t = 0; actor.dodge_t = 0
				actor.anim_t = frame/8.0
				match animation:
					"walk": actor.move_vector = actor.facing; actor.anim_t = frame/12.0
					"attack": actor.bow_equipped = false; actor.attack_t = 0.28*(1-float(frame)/6)
					"shoot": actor.bow_equipped = true; actor.attack_t = 0.65*(1-float(frame)/8)
					"cast": actor.cast_t = 0.65*(1-float(frame)/8); actor.cast_spell_index = frame%3
					"hurt": actor.hurt_t = 0.22*(1-float(frame)/4)
					"death": actor.death_t = 0.7*(1-float(frame)/8)
					"evade": actor.dodge_t = 0.3; actor.dodge_elapsed = float(frame)/6*actor.DODGE_DURATION; actor.dodge_direction = actor.facing
				actor.refresh_spell_focus(); actor.queue_redraw()
			await shot("animation_%s_%02d"%[animation,frame])
	gallery.queue_free(); await settle()
	root.size = Vector2i(960,840); root.content_scale_size = root.size
	gallery = Node2D.new(); root.add_child(gallery)
	var Decor = preload("res://scripts/cartoon/cartoon_interior_art_v042.gd")
	var index: int = 0
	for key: String in Decor.manifest.furniture:
		var prop = Decor.new(); prop.key = key; prop.dimensions = Vector2(150,140)
		prop.position = Vector2(95+190*(index%5),145+165*(index/5)); prop.ground = key=="rug"
		gallery.add_child(prop); index += 1
	await shot("furniture_gallery")
	gallery.queue_free(); await settle()
	root.size = Vector2i(960,540); root.content_scale_size = root.size
	var state = root.get_node("CartoonPlayerState"); state.reset_progress(true); state.start_new_game()
	var hub = load("res://scenes/cartoon/ValedouroCartoonHub.tscn").instantiate(); root.add_child(hub); current_scene = hub
	await settle()
	hub.set_process(false); hub.hero.set_process(false); hub.camera.position_smoothing_enabled = false
	hub.get_node("HUD/GameLayout").demon_director.set_process(false)
	hub.wildlife.set_process(false); hub.ambient_encounters.set_process(false)
	for actor in hub.monsters: actor.set_process(false)
	for size in [Vector2i(960,540),Vector2i(640,360)]:
		root.size = size; root.content_scale_size = size
		for zoom: float in [0.70,1.50]:
			hub.zoom_controls.set_zoom_value(zoom,false)
			var suffix: String = "%dx%d_z%d"%[size.x,size.y,roundi(zoom*100)]
			for room: String in ["tavern","forge","guild"]:
				hub.interiors.enter(room); hub.interiors.set_process(false)
				hub.hero.position = Vector2(0,-55) if zoom<1 else {"tavern":Vector2(-220,-45),"forge":Vector2(-90,-20),"guild":Vector2(-320,-95)}[room]
				hub.camera.reset_smoothing(); hub.hero.queue_redraw(); hub.interiors._refresh_hint(); hub.toast_label.text = ""
				await shot(room+"_"+suffix)
				if room=="guild" and zoom>1:
					hub.hero.position = Vector2(-390,-285)
					assert(hub.interiors.is_walkable(hub.hero.position))
					hub.interiors._refresh_hint(); hub.camera.reset_smoothing()
					await shot("guild_board_"+suffix)
				hub.interiors.leave()
			hub.hero.position = Region.world_from_hub(Vector2(-300,630)); hub.world_stream._refresh(true); hub.camera.reset_smoothing(); hub._update_poi_hint(); hub.toast_label.text = ""
			await shot("hero_world_"+suffix)
			for animation: String in Art.FRAMES:
				for sample in [0,1]:
					var actor = hub.hero
					var frame: int = 0 if sample==0 else int(Art.FRAMES[animation]*0.65)
					actor.move_vector = Vector2.ZERO; actor.attack_t = 0; actor.cast_t = 0; actor.hurt_t = 0; actor.death_t = 0; actor.dodge_t = 0
					actor.bow_equipped = animation=="shoot"; actor.anim_t = frame/8.0
					match animation:
						"walk": actor.move_vector = Vector2.DOWN; actor.anim_t = frame/12.0
						"attack": actor.attack_t = 0.28*(1-float(frame)/6)
						"shoot": actor.attack_t = 0.65*(1-float(frame)/8)
						"cast": actor.cast_t = 0.65*(1-float(frame)/8); actor.cast_spell_index = sample
						"hurt": actor.hurt_t = 0.22*(1-float(frame)/4)
						"death": actor.death_t = 0.7*(1-float(frame)/8)
						"evade": actor.dodge_t = 0.3; actor.dodge_elapsed = float(frame)/6*actor.DODGE_DURATION; actor.dodge_direction = Vector2.DOWN
					actor.refresh_spell_focus(); actor.queue_redraw()
					await shot("world_%s_%d_%s"%[animation,sample,suffix])
			var actor = hub.hero
			actor.move_vector = Vector2.ZERO; actor.attack_t = 0; actor.cast_t = 0; actor.hurt_t = 0; actor.death_t = 0; actor.dodge_t = 0; actor.bow_equipped = false
			actor.refresh_spell_focus(); actor.queue_redraw()
			# Spell sprites share original art; real FX nodes retain bounded lights and lifetimes.
			for spell: String in ["ember","frost","arcane"]:
				var effects: Array = []
				for stage in range(4):
					var fx = FX.spawn(hub.objects,hub.hero.position+Vector2((stage-1.5)*85,-20),"impact_"+spell if stage==3 else spell,Vector2.RIGHT)
					assert(fx!=null and fx.spell_sprite!=null)
					fx.travel_visual = false; fx.set_process(false); fx._process([0.04,0.17,0.35,0.25][stage]); effects.append(fx)
				await shot("spell_%s_%s"%[spell,suffix])
				for fx in effects: fx.queue_free()
				await settle()
	state.reset_progress(true)
	var report = FileAccess.open(output.path_join("report.json"),FileAccess.WRITE)
	report.store_string(JSON.stringify({"grounded_frames":checked,"max_draw_calls":max_calls,"captures":shots},"\t"))
	print("illustrated_v042: PASS — %d grounded poses, eight animation states, real interiors/world/spells at 960x540/640x360 and zoom 70/150, <2000 draw calls"%checked)
	quit()
