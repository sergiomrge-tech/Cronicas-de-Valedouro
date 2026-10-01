extends Control
## Local navigation radar uses actual authored routes and positions in each region.
var host
var route: PackedVector2Array = []
var landmarks: Array = []
var elapsed: float = 0
var world_view: SubViewport
var map_camera: Camera2D
const RANGE: float = 1200.0
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	tooltip_text = "MAPA • azul: você • dourado: objetivo • vermelho: inimigos"
	var constants: Dictionary = host.map_overlay.get_script().get_script_constant_map()
	var story = constants.get("StoryMap")
	if story != null:
		route = story.act1_route_points() if story.has_method("act1_route_points") else story.route_points()
		landmarks = story.act1_locations() if story.has_method("act1_locations") else story.locations()
	world_view = SubViewport.new()
	world_view.size = Vector2i(128,128)
	world_view.world_2d = host.get_world_2d()
	world_view.transparent_bg = true
	world_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(world_view)
	map_camera = Camera2D.new()
	map_camera.zoom = Vector2.ONE*(128.0/90.0*42.0/RANGE)
	world_view.add_child(map_camera)
	var map_texture = TextureRect.new()
	map_texture.position = Vector2(7,7)
	map_texture.size = Vector2(90,90)
	map_texture.texture = world_view.get_texture()
	map_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_texture.show_behind_parent = true
	var material = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){ vec4 col=texture(TEXTURE,UV); col.a *= 1.0-smoothstep(0.485,0.5,length(UV-vec2(0.5))); COLOR=col; }"
	material.shader = shader
	map_texture.material = material
	add_child(map_texture)
func _process(delta: float) -> void:
	elapsed += delta
	if elapsed>=0.1 and is_visible_in_tree():
		elapsed = 0
		map_camera.position = host.hero.global_position
		world_view.render_target_update_mode = SubViewport.UPDATE_ONCE
		queue_redraw()
func point(world: Vector2) -> Vector2:
	return size*0.5+(world-host.hero.position)*(42.0/RANGE)
func _draw() -> void:
	if host == null or host.hero == null: return
	var c: Vector2 = size*0.5
	draw_arc(c,48,0,TAU,64,Color("73241e"),5,true)
	draw_arc(c,50,0,TAU,64,Color("e4b85d"),2,true)
	draw_arc(c,46,0,TAU,64,Color("823936"),1,true)
	for row in landmarks:
		var pp: Vector2 = point(row.get("pos",Vector2.ZERO))
		if pp.distance_to(c)<40: draw_rect(Rect2(pp-Vector2(2,2),Vector2(4,4)),Color("dfc17d"))
	for mob in host.monsters:
		if not is_instance_valid(mob) or mob.hp<=0: continue
		var pp: Vector2 = point(mob.position)
		if pp.distance_to(c)<40: draw_circle(pp,2,Color("ff7469"))
	var layout = host.get_node("HUD/GameLayout")
	var target: Vector2
	var has_target: bool = false
	if layout.tracked_target.get("valid",false):
		target = layout.tracked_target.position
		has_target = true
	else:
		for row in landmarks:
			if row.get("id","")==host.story_runtime.current_location():
				target = row.pos
				has_target = true
				break
	if has_target:
		var p: Vector2 = c+(point(target)-c).limit_length(38)
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(4,0),p+Vector2(0,4),p+Vector2(-4,0)]),Color("ffdc77"))
	draw_colored_polygon(PackedVector2Array([c+Vector2(0,-6),c+Vector2(4,4),c,c+Vector2(-4,4)]),Color("80d7ff"))
	draw_string(ThemeDB.fallback_font,Vector2(c.x-4,14),"N",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("fff0d4"))
