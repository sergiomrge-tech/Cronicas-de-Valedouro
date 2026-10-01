extends Node2D
const RoyalPalace = preload("res://scripts/cartoon/cartoon_royal_palace.gd")
const Assets = preload("res://scripts/cartoon/cartoon_living_assets.gd")
const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
const WALK_AREA: Rect2 = Rect2(-610,-325,1220,750)
const SERVICES: Dictionary = {"tavern":"TAVERNA DE VALEDOURO","forge":"OFICINA DO FERREIRO","guild":"SALÃO DA GUILDA","castle":"CASTELO REAL"}
var host
var active: bool = false
var kind: String = ""
var outdoor_position: Vector2
var room_objects: Node2D
var blockers: Array[Rect2] = []
var points: Array[Dictionary] = []
var camera_limits: Array[int] = []
var clock: float = 0
var glow_points: Array[Vector2] = []
var patrons: Array[Node2D] = []
func setup(owner_node) -> void:
	host = owner_node
	name = "BuildingInteriors"
	visible = false
func enter(building: String) -> void:
	if active or not SERVICES.has(building): return
	kind = building
	outdoor_position = host.hero.position
	camera_limits = [host.camera.limit_left,host.camera.limit_top,host.camera.limit_right,host.camera.limit_bottom]
	host.environment.visible = false
	host.objects.visible = false
	host.story_zones.visible = false
	host.world_stream.process_mode = Node.PROCESS_MODE_DISABLED
	_build_room()
	host.hero.reparent(room_objects,false)
	host.hero.position = RoyalPalace.SPAWN if kind == "castle" else Vector2(0,315)
	host.hero.set_motion(Vector2.ZERO)
	var bounds: Rect2 = RoyalPalace.BOUNDS if kind == "castle" else Rect2(-720,-500,1440,1000)
	host.camera.limit_left = int(bounds.position.x)
	host.camera.limit_top = int(bounds.position.y)
	host.camera.limit_right = int(bounds.end.x)
	host.camera.limit_bottom = int(bounds.end.y)
	host.camera.reset_smoothing()
	host.joystick_id = -1
	host.joystick_vector = Vector2.ZERO
	active = true
	visible = true
	host.hud_status.region_label.text = SERVICES[kind]
	host._show_toast("Entre e explore. Use os serviços ou a porta para sair.")
	_refresh_hint()
func leave() -> void:
	if not active: return
	host.guild_board.close_panel()
	host.crafting_ui.close_panel()
	host.inventory_ui.close_panel()
	host.hero.reparent(host.objects,false)
	host.hero.position = outdoor_position
	host.hero.set_motion(Vector2.ZERO)
	host.camera.limit_left = camera_limits[0]
	host.camera.limit_top = camera_limits[1]
	host.camera.limit_right = camera_limits[2]
	host.camera.limit_bottom = camera_limits[3]
	host.camera.reset_smoothing()
	host.environment.visible = true
	host.objects.visible = true
	host.story_zones.visible = true
	host.world_stream.process_mode = Node.PROCESS_MODE_INHERIT
	host.joystick_id = -1
	host.joystick_vector = Vector2.ZERO
	active = false
	visible = false
	host.hud_status.region_label.text = "VALEDOURO"
	host._update_poi_hint()
	host._update_objective_navigation()
	get_node("/root/CartoonPlayerState").save_profile()
func _build_room() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	blockers.clear()
	points.clear()
	glow_points.clear()
	patrons.clear()
	if kind == "castle":
		RoyalPalace.build(self)
		return
	var floor: Sprite2D = Sprite2D.new()
	floor.texture = Assets.texture("room_"+kind)
	floor.z_index = -20
	add_child(floor)
	room_objects = Node2D.new()
	room_objects.y_sort_enabled = true
	room_objects.name = "InteriorFurniture"
	add_child(room_objects)
	_prop("rug",Vector2(0,235),Vector2(240,210),false,true)
	_prop("plant",Vector2(-550,-270),Vector2(105,110))
	_prop("plant",Vector2(550,290),Vector2(105,110))
	_prop("lantern",Vector2(-545,-150),Vector2(90,95),false)
	_prop("lantern",Vector2(555,-140),Vector2(90,95),false)
	_point("exit","Sair para Valedouro",Vector2(0,400))
	match kind:
		"tavern":
			_prop("counter",Vector2(-300,-130),Vector2(280,180))
			_npc("innkeeper",Vector2(-310,-220))
			_point("rest","Taverneiro • descansar e salvar",Vector2(-300,-80))
			_prop("fireplace",Vector2(440,-250),Vector2(190,185))
			glow_points.append(Vector2(440,-270))
			_prop("cask",Vector2(-480,-90),Vector2(105,110))
			_prop("cask",Vector2(-510,30),Vector2(105,110))
			_prop("wall_map",Vector2(195,-275),Vector2(165,150),false)
			_prop("bookshelf",Vector2(50,-280),Vector2(150,160))
			for center: Vector2 in [Vector2(-250,90),Vector2(285,95)]:
				_prop("chair",center+Vector2(-78,-45),Vector2(78,88))
				_prop("chair",center+Vector2(92,20),Vector2(78,88))
				_prop("table",center,Vector2(195,158))
				_npc("patron",center+Vector2(-100,-5))
			_npc("ranger",Vector2(375,75))
			_point("rumor","Caçador • dicas da região",Vector2(375,90))
			_prop("bed",Vector2(-490,270),Vector2(150,160))
			_point("rest","Cama • descansar e salvar",Vector2(-490,315))
		"forge":
			_prop("furnace",Vector2(-380,-220),Vector2(245,220))
			glow_points.append(Vector2(-380,-230))
			_prop("anvil",Vector2(-200,5),Vector2(175,160))
			_npc("smith",Vector2(-90,-90))
			_point("craft","Ferreiro • fabricar equipamento",Vector2(-90,-20))
			_prop("workbench",Vector2(320,-140),Vector2(290,180))
			_prop("weapon_rack",Vector2(470,-285),Vector2(180,170))
			_prop("weapon_rack",Vector2(150,-285),Vector2(180,170))
			_prop("workbench",Vector2(380,200),Vector2(180,140))
			_prop("coal",Vector2(-475,115),Vector2(135,125))
			_prop("crates",Vector2(480,45),Vector2(135,130))
			_prop("crates",Vector2(-460,295),Vector2(125,125))
		"guild":
			_prop("board",Vector2(-320,-195),Vector2(270,240))
			_point("board","Quadro de contratos • 7 missões",Vector2(-320,-95))
			_prop("counter",Vector2(280,-125),Vector2(270,180))
			_npc("clerk",Vector2(280,-220))
			_point("board","Escrivão • contratos e recompensas",Vector2(280,-65))
			_prop("bookshelf",Vector2(510,-270),Vector2(150,160))
			_prop("bookshelf",Vector2(-520,-270),Vector2(150,160))
			_prop("banner",Vector2(-30,-285),Vector2(95,120),false)
			_prop("wall_map",Vector2(105,-275),Vector2(165,150),false)
			_prop("crates",Vector2(500,65),Vector2(120,120))
			_prop("table",Vector2(-285,190),Vector2(210,165))
			_prop("chair",Vector2(-400,180),Vector2(78,88))
			_npc("ranger",Vector2(390,160))
			_point("rumor","Aventureiro • dicas de caça",Vector2(390,200))
	var title: Label = UISkin.label(SERVICES[kind],19,Color("ead397"))
	title.position = Vector2(-225,-448)
	title.size = Vector2(450,32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var exit_label: Label = UISkin.label("SAÍDA",14,Color("f1d498"))
	exit_label.position = Vector2(-40,367)
	add_child(exit_label)
func _prop(key: String, p: Vector2, dimensions: Vector2, solid: bool = true, ground: bool = false) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = key
	sprite.texture = Assets.texture(key)
	sprite.position = p
	sprite.scale = dimensions/Vector2(sprite.texture.get_size())
	sprite.offset = Vector2(0,-sprite.texture.get_height()*0.5+10/sprite.scale.y)
	if ground: sprite.z_index = -10
	room_objects.add_child(sprite)
	if solid: blockers.append(Rect2(p+Vector2(-dimensions.x*0.32,-dimensions.y*0.27),Vector2(dimensions.x*0.64,dimensions.y*0.30)))
func _npc(key: String, p: Vector2) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = Assets.texture("npc_"+key)
	sprite.position = p
	sprite.scale = Vector2(0.7,0.7)
	sprite.offset.y = -52
	room_objects.add_child(sprite)
	patrons.append(sprite)
	blockers.append(Rect2(p+Vector2(-15,-14),Vector2(30,24)))
func _point(id: String, text: String, p: Vector2) -> void:
	points.append({"id":id,"label":text,"pos":p})
func is_walkable(p: Vector2) -> bool:
	if kind == "castle":
		if not RoyalPalace.walkable(p): return false
	elif not WALK_AREA.has_point(p): return false
	for blocker in blockers:
		if blocker.grow(12).has_point(p): return false
	return true
func nearest_point(radius: float = 165.0) -> Dictionary:
	var nearest: Dictionary = {}
	var distance: float = radius
	for point in points:
		var d: float = host.hero.position.distance_to(point.pos)
		if d < distance:
			distance = d
			nearest = point
	return nearest
func interact() -> void:
	var point: Dictionary = nearest_point()
	if point.is_empty():
		host._show_toast("Aproxime-se do marcador de serviço ou da saída.")
		return
	match point.id:
		"exit": leave()
		"board": host.guild_board.open_panel()
		"craft": host.crafting_ui._toggle()
		"rest":
			host.player_hp = host.player_max_hp
			host._refresh_stats()
			get_node("/root/CartoonPlayerState").save_profile()
			host._show_toast("Descansou: vida restaurada e progresso salvo.")
		"royal_audience": host._show_toast("Rei de Valedouro: seja bem-vindo. Os salões do castelo estão abertos à sua visita.")
		"royal_rest":
			host.player_hp = host.player_max_hp
			host._refresh_stats()
			get_node("/root/CartoonPlayerState").save_profile()
			host._show_toast("Descanso nos aposentos reais. Vida restaurada e progresso salvo.")
		"inspect_library": host._show_toast("Estantes entalhadas, volumes encadernados e mesas de leitura da biblioteca real.")
		"inspect_gallery": host._show_toast("Retratos emoldurados em ouro e esculturas sobre pedestais de mármore.")
		"inspect_honor": host._show_toast("A galeria reúne esculturas, tapetes e o brasão de Valedouro.")
		"inspect_council": host._show_toast("Documentos, livros e mobiliário cerimonial da câmara do conselho.")
		"inspect_feast": host._show_toast("Louça fina, taças e mesas preparadas no salão de banquetes.")
		"rumor": host._show_toast("Coelhos fogem; cervos dão couro; javalis se defendem. Procure os campos ao sul.")
func action_text(point: Dictionary = {}) -> String:
	var current: Dictionary = point if not point.is_empty() else nearest_point()
	if current.is_empty(): return ""
	match String(current.get("id","")):
		"exit": return "SAIR"
		"board": return "CONTRATOS"
		"craft": return "FORJAR"
		"rest", "royal_rest": return "DESCANSAR"
		"royal_audience": return "FALAR"
		"rumor": return "CONVERSAR"
		_: return "EXAMINAR"

func _refresh_hint() -> void:
	var point: Dictionary = nearest_point()
	if not point.is_empty():
		var prefix: String = "E — " if OS.get_name() == "Windows" else ""
		host.poi_label.text = "◆ %s • %s%s" % [String(point.label),prefix,action_text(point)]
	else:
		host.poi_label.text = "Explore o interior • procure os marcadores • saída ao sul"
	host.objective_nav_label.text = "Castelo • "+RoyalPalace.location(host.hero.position) if kind == "castle" else "Interior • "+String(SERVICES[kind]).capitalize()
func _process(delta: float) -> void:
	if not active: return
	clock += delta
	var layout = host.get_node("HUD/GameLayout")
	if layout.is_blocked():
		host.hero.set_motion(Vector2.ZERO)
		return
	var motion: Vector2 = Input.get_vector("move_left","move_right","move_up","move_down")
	if host.joystick_vector.length()>0.12: motion = host.joystick_vector
	motion = motion.limit_length()
	# Separate axes allow the player to slide along tables and counters.
	var next: Vector2 = host.hero.position
	if is_walkable(next+Vector2(motion.x*host.speed*delta,0)): next.x += motion.x*host.speed*delta
	if is_walkable(next+Vector2(0,motion.y*host.speed*delta)): next.y += motion.y*host.speed*delta
	host.hero.position = next
	host.hero.set_motion(motion)
	_refresh_hint()
	for i in range(patrons.size()): patrons[i].rotation = sin(clock*1.4+i)*0.012
	if Input.is_action_just_pressed("interact"): interact()
	queue_redraw()
func _draw() -> void:
	if not active: return
	# Interaction markers: subtle rings make services and exits readable on PC.
	for point in points:
		var p: Vector2 = point.get("pos",Vector2.ZERO)
		var nearby: bool = host != null and host.hero != null and host.hero.position.distance_to(p) <= 165.0
		var alpha: float = 0.58 if nearby else 0.30
		draw_circle(p,18.0,Color(0.93,0.74,0.30,alpha))
		draw_arc(p,24.0,0,TAU,28,Color(1.0,0.90,0.55,0.88 if nearby else 0.46),2.0,true)
	for p in glow_points:
		var strength: float = 0.018+sin(clock*5)*0.003
		for radius in range(8): draw_circle(p+Vector2(0,35),float(150-radius*16),Color(1,0.64,0.25,strength))
