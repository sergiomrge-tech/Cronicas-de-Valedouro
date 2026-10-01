extends RefCounted
## Eight connected wings; decoration and interaction remain separate from canon.
const Assets = preload("res://scripts/cartoon/cartoon_royal_assets.gd")
const UISkin = preload("res://scripts/cartoon/cartoon_ui_theme.gd")
const SPAWN: Vector2 = Vector2(0,1310)
const BOUNDS: Rect2 = Rect2(-2110,-2100,4220,3700)
const ROOMS: Array[Dictionary] = [
	{"id":"vestibule","title":"Grande Vestíbulo","rect":Rect2(-620,600,1240,850)},
	{"id":"throne","title":"Salão do Trono","rect":Rect2(-690,-800,1380,1350)},
	{"id":"banquet","title":"Salão de Banquetes","rect":Rect2(-2010,0,1190,1050)},
	{"id":"library","title":"Biblioteca Real","rect":Rect2(820,-750,1190,1000)},
	{"id":"bedroom","title":"Aposentos Reais","rect":Rect2(820,520,1190,960)},
	{"id":"gallery","title":"Galeria Real","rect":Rect2(-2010,-1220,1190,920)},
	{"id":"council","title":"Câmara do Conselho","rect":Rect2(820,-1980,1190,1000)},
	{"id":"honor","title":"Galeria de Honra","rect":Rect2(-660,-1980,1320,940)}]
const CORRIDORS: Array[Rect2] = [
	Rect2(-150,480,300,180),Rect2(-870,300,260,220),Rect2(620,-100,250,220),
	Rect2(550,950,360,180),Rect2(-880,-500,250,220),Rect2(-1550,-390,260,510),
	Rect2(1180,-1070,280,370),Rect2(-150,-1100,300,360)]
static func location(p: Vector2) -> String:
	for room in ROOMS:
		if room.rect.has_point(p): return room.title
	return "Passagem Real"
static func walkable(p: Vector2) -> bool:
	for room in ROOMS:
		if room.rect.grow(-26).has_point(p): return true
	for corridor in CORRIDORS:
		if corridor.grow(-16).has_point(p): return true
	return false
static func _prop(interior,key: String,p: Vector2,size_v: Vector2,solid: bool = true,ground: bool = false) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = key
	sprite.texture = Assets.texture(key)
	sprite.scale = size_v/sprite.texture.get_size()
	sprite.offset.y = -sprite.texture.get_height()*0.5+10/sprite.scale.y
	sprite.position = p
	if ground: sprite.z_index = -10
	interior.room_objects.add_child(sprite)
	if solid:
		interior.blockers.append(Rect2(p+Vector2(-size_v.x*0.28,-size_v.y*0.22),Vector2(size_v.x*0.56,size_v.y*0.25)))
static func build(interior) -> void:
	interior.room_objects = Node2D.new()
	interior.room_objects.name = "RoyalFurniture"
	interior.room_objects.y_sort_enabled = true
	interior.add_child(interior.room_objects)
	for room in ROOMS:
		var floor: Sprite2D = Sprite2D.new()
		floor.name = "RoyalFloor_"+String(room.id)
		floor.texture = Assets.texture("floor_"+String(room.id))
		floor.position = room.rect.get_center()
		floor.scale = room.rect.size/floor.texture.get_size()
		floor.z_index = -20
		interior.add_child(floor)
		var title: Label = UISkin.label(room.title.to_upper(),18,Color("f0d597"))
		title.position = room.rect.position+Vector2(200,30)
		title.size = Vector2(room.rect.size.x-400,32)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		interior.add_child(title)
		# Corner bouquets, ceiling lights and wall art define each wing.
		for side: float in [-1,1]:
			var p: Vector2 = room.rect.get_center()+Vector2(side*(room.rect.size.x/2-90),-room.rect.size.y/2+220)
			_prop(interior,"royal_vase",p,Vector2(108,126))
			_prop(interior,"royal_banner",p+Vector2(side*-140,-35),Vector2(95,145),false)
		var lamp: Vector2 = room.rect.get_center()+Vector2(0,-room.rect.size.y*0.24)
		_prop(interior,"chandelier",lamp,Vector2(175,195),false)
		interior.glow_points.append(lamp)
	# Corridors overlay the edges of rooms to leave visible door openings.
	var directions: Array[String] = ["TRONO ↑  •  SAÍDA ↓","BANQUETES ←","BIBLIOTECA →","APOSENTOS →","GALERIA ←","GALERIA ↑","CONSELHO ↑","HONRA ↑"]
	for corridor_index in range(CORRIDORS.size()):
		var corridor: Rect2 = CORRIDORS[corridor_index]
		var background: Polygon2D = Polygon2D.new()
		background.z_index = -19
		background.color = Color("d8d8bf")
		background.polygon = PackedVector2Array([corridor.position,corridor.position+Vector2(corridor.size.x,0),corridor.end,corridor.position+Vector2(0,corridor.size.y)])
		interior.add_child(background)
		var line: Line2D = Line2D.new()
		line.z_index = -18
		line.width = 3
		line.default_color = Color("b99f69")
		line.points = PackedVector2Array([corridor.position+Vector2(18,18),corridor.position+Vector2(18,corridor.size.y-18),corridor.end-Vector2(18,18)])
		interior.add_child(line)
		var sign_copy: Label = UISkin.label(directions[corridor_index],13,Color("5e694e"))
		sign_copy.position = corridor.get_center()-Vector2(110,14)
		sign_copy.size = Vector2(220,28)
		sign_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		interior.add_child(sign_copy)
	# Entrance hall: long runner, paired sentries, columns and marble statues.
	_prop(interior,"royal_runner",Vector2(0,1300),Vector2(245,630),false,true)
	for y: float in [880,1230]:
		for side: float in [-1,1]:
			_prop(interior,"column",Vector2(side*370,y),Vector2(165,235))
			_prop(interior,"statue",Vector2(side*500,y),Vector2(130,180))
	for side: float in [-1,1]: _prop(interior,"royal_guard",Vector2(side*180,1320),Vector2(66,85))
	interior._point("exit","Portão do castelo • sair para Valedouro",Vector2(0,1400))
	# Throne dais and aisle: clear central route, grand columns on both sides.
	_prop(interior,"royal_runner",Vector2(0,460),Vector2(330,1060),false,true)
	_prop(interior,"throne",Vector2(0,-490),Vector2(200,240))
	_prop(interior,"king",Vector2(0,-375),Vector2(78,98))
	for side: float in [-1,1]:
		_prop(interior,"royal_guard",Vector2(side*200,-420),Vector2(75,94))
		_prop(interior,"royal_banner",Vector2(side*155,-595),Vector2(150,205),false)
		for y: float in [-300,20,350]: _prop(interior,"column",Vector2(side*440,y),Vector2(160,235))
		_prop(interior,"statue",Vector2(side*555,-450),Vector2(155,220))
	interior._point("royal_audience","Rei de Valedouro • audiência",Vector2(0,-270))
	# Dining room: two long banquet tables, silverware, velvet seating.
	for x: float in [-1710,-1170]:
		for y: float in [310,550,790]: _prop(interior,"banquet_table",Vector2(x,y),Vector2(220,235))
		for side: float in [-1,1]:
			for y: float in [230,530,840]: _prop(interior,"royal_sofa",Vector2(x+side*155,y),Vector2(100,98))
	interior._point("inspect_feast","Mesa do banquete • observar",Vector2(-1420,600))
	# Library stacks and writing tables; aisles remain comfortably navigable.
	for x: float in [1040,1400,1760]:
		_prop(interior,"royal_bookcase",Vector2(x,-475),Vector2(195,250))
		_prop(interior,"royal_bookcase",Vector2(x,-170),Vector2(195,250))
	for x: float in [1190,1640]: _prop(interior,"royal_desk",Vector2(x,110),Vector2(210,185))
	interior._point("inspect_library","Biblioteca real • consultar os livros",Vector2(1400,80))
	# Royal suite: canopy bed, private study and velvet sitting area.
	_prop(interior,"royal_bed",Vector2(1450,930),Vector2(290,310))
	_prop(interior,"royal_runner",Vector2(1420,1340),Vector2(290,390),false,true)
	_prop(interior,"royal_sofa",Vector2(1080,1190),Vector2(220,180))
	_prop(interior,"royal_sofa",Vector2(1770,1190),Vector2(220,180))
	_prop(interior,"royal_desk",Vector2(1770,880),Vector2(220,200))
	_prop(interior,"portrait",Vector2(1050,825),Vector2(170,205),false)
	interior._point("royal_rest","Aposentos • descansar e salvar",Vector2(1420,1160))
	# West gallery: oil paintings and carved sculptures.
	for x: float in [-1760,-1430,-1100]:
		_prop(interior,"portrait",Vector2(x,-890),Vector2(185,235),false)
		_prop(interior,"statue",Vector2(x,-560),Vector2(175,230))
	_prop(interior,"royal_sofa",Vector2(-1790,-405),Vector2(190,145))
	interior._point("inspect_gallery","Galeria real • observar as obras",Vector2(-1430,-420))
	# Council chamber and northern honor gallery.
	for x: float in [1120,1630]: _prop(interior,"royal_desk",Vector2(x,-1360),Vector2(255,225))
	for x: float in [1050,1410,1790]: _prop(interior,"royal_bookcase",Vector2(x,-1700),Vector2(170,225))
	interior._point("inspect_council","Conselho • observar os documentos",Vector2(1390,-1190))
	for side: float in [-1,1]:
		for y: float in [-1660,-1310]: _prop(interior,"statue",Vector2(side*390,y),Vector2(170,245))
	_prop(interior,"royal_runner",Vector2(0,-1160),Vector2(260,560),false,true)
	interior._point("inspect_honor","Galeria de honra • observar as esculturas",Vector2(0,-1410))
