class_name ValedouroCartoonHubEnvironment
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const Terrain = preload("res://scripts/cartoon/cartoon_terrain_art.gd")
const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")

const LOCAL_SIZE = Vector2(2300,2350)
const WORLD_SIZE = Region.REGION_SIZE
const CENTER = Vector2(1150,860)

var use_baked_ground: bool = true
const CITY_GROUND = preload("res://assets/cartoon/v041/city_ground.png")
const CITY_GROUND_RECT = Rect2(0,-1740,4096,4096)

var rng = RandomNumberGenerator.new()
var props: Array[Dictionary] = []
var blockers: Array[Dictionary] = []
var pois: Array[Dictionary] = []
var river_polylines: Array[PackedVector2Array] = []

func _ready() -> void:
	z_index = -20
	texture_repeat = CanvasItem.TEXTURE_REPEAT_MIRROR
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	rng.seed = 20260930
	_build_layout()
	queue_redraw()

func _build_layout() -> void:
	props.clear(); blockers.clear(); pois.clear(); river_polylines.clear()
	# Core landmarks: manually authored, then decorative ring around them.
	_add("castle",Region.CASTLE_ANCHOR,1.0,"Castelo Real de Valedouro","",Rect2(1730,-1370,1540,1010))
	pois.append({"id":"POI_REG001_CASTLE","label":"Castelo Real • entrada","pos":Region.world_from_hub(Region.CASTLE_DOOR)})
	for side: float in [-1,1]:
		_add("royal_statue",Vector2(2500+side*260,-170),1.2,"","",Rect2(),0,30)
		_add("royal_guard",Vector2(2500+side*130,-220),1.0)
		for y: float in [-50,120]:
			_add("royal_vase",Vector2(2500+side*330,y),1.0)
			_add("royal_banner",Vector2(2500+side*210,y),1.0)
	_add("fountain",CENTER,1.25,"Praça Central","POI_REG001_PLAZA",Rect2(1090,805,120,85))
	_add("forge",Vector2(720,790),1.25,"Ferreiro","POI_REG001_FORGE",Rect2(640,675,160,130))
	_add("tavern",Vector2(1580,800),1.28,"Taverna","POI_REG001_TAVERN",Rect2(1490,680,180,135))
	_add("guild",Vector2(760,1125),1.22,"Guilda","POI_REG001_GUILD",Rect2(675,1010,170,135))
	_add("alchemist",Vector2(1540,1130),1.18,"Alquimista","POI_REG001_ALCHEMIST",Rect2(1460,1025,160,130))
	for p in [Vector2(920,765),Vector2(1380,760),Vector2(945,1080),Vector2(1365,1080)]: _add("market",p,0.9,"Mercado","",Rect2(p-Vector2(45,50),Vector2(90,65)))
	for p in [Vector2(985,935),Vector2(1310,930),Vector2(1000,1180),Vector2(1300,1180)]: _add("bench",p,0.85)
	for p in [Vector2(930,700),Vector2(1370,700),Vector2(890,980),Vector2(1410,980),Vector2(910,1210),Vector2(1390,1210)]: _add("lamp",p,0.9)
	_add("well",Vector2(1265,1085),0.9,"Poço da Praça","POI_REG001_WELL",Rect2(1225,1040,80,70))
	# Work yards at existing services: road access + market/resource function.
	for p in [Vector2(637,814),Vector2(800,813),Vector2(1504,840),Vector2(1660,835),Vector2(695,1155),Vector2(832,1150),Vector2(1480,1160)]:
		_add("barrel",p,0.9)
	for p in [Vector2(678,872),Vector2(1658,886),Vector2(719,1202),Vector2(1577,1200)]:
		_add("flowers",p,1.2)
	# Residential ring
	var homes = [Vector2(520,545),Vector2(650,475),Vector2(1640,480),Vector2(1775,570),Vector2(490,990),Vector2(1780,1015),Vector2(590,1280),Vector2(1705,1280)]
	for i in homes.size(): _add("house",homes[i],1.0 + float(i%3)*0.06,"Casa","",Rect2(homes[i]-Vector2(58,95),Vector2(116,115)),i)
	# City gate / roads decorative signs
	_add("sign",Vector2(1150,1340),0.95,"Portão Sul","POI_REG001_GATE_SOUTH")
	_add("sign",Vector2(1150,1740),0.95,"Campos do Vale","POI_REG001_FIELDS")
	_add("windmill",Vector2(650,1935),1.12,"Fazenda do Sol","POI_REG001_FARM",Rect2(575,1805,150,155))
	_add("house",Vector2(815,1985),0.95,"Casa da Fazenda","",Rect2(755,1885,120,120),4)
	_add("house",Vector2(1760,2020),0.92,"Casa do Campo","",Rect2(1700,1920,120,118),5)
	for p in [Vector2(540,2050),Vector2(725,2100),Vector2(900,2070),Vector2(1570,2110),Vector2(1720,2150),Vector2(1875,2080)]: _add("hay",p,0.82)
	_add("chest",Vector2(1510,1900),0.9,"Baú Abandonado","POI_REG001_FIELD_CHEST",Rect2(1475,1870,70,48))
	_add("sign",Vector2(1150,290),0.85,"Estrada Norte","POI_REG001_GATE_NORTH")
	# deterministic vegetation outside plaza core
	for i in 110:
		var groves: Array[Vector2] = [Vector2(440,710),Vector2(1830,755),Vector2(430,1350),Vector2(1840,1380),Vector2(825,460),Vector2(1480,445)]
		var p: Vector2 = groves[i % groves.size()] + Vector2(rng.randf_range(-145,145),rng.randf_range(-125,125))
		if p.distance_to(CENTER) < 360 or p.distance_to(Vector2(1150,520)) < 330: continue
		if _near_road(p,100): continue
		if _near_manual_blocker(p,95): continue
		var k = "tree" if rng.randf() < 0.56 else "pine" if rng.randf() < 0.72 else "bush"
		_add(k,p,rng.randf_range(0.72,1.10),"","",Rect2(),rng.randi()%3,28.0 if k != "bush" else 17.0)
	for i in 70:
		var p = Vector2(rng.randf_range(140,2160),rng.randf_range(190,1510))
		if p.distance_to(CENTER) < 260 or _near_road(p,48) or _near_manual_blocker(p,50): continue
		_add("rock" if rng.randf()<0.48 else "flowers",p,rng.randf_range(0.55,0.9),"","",Rect2(),rng.randi()%4,16.0 if rng.randf()<0.5 else 0.0)
	# fences around a small farm east and civic garden west
	for x in range(1860,2110,70): _add("fence",Vector2(x,790),0.8)
	for x in range(220,500,70): _add("fence",Vector2(x,1180),0.8)
	# River segments flank the city without cutting the plaza.
	river_polylines.append(PackedVector2Array([Vector2(80,340),Vector2(270,470),Vector2(330,690),Vector2(260,900),Vector2(330,1160),Vector2(190,1440),Vector2(70,1620)]))
	river_polylines.append(PackedVector2Array([Vector2(2200,250),Vector2(2050,420),Vector2(2025,650),Vector2(2110,870),Vector2(2040,1090),Vector2(2140,1360),Vector2(2260,1530)]))
	_add("bridge",Vector2(300,900),1.0,"Ponte Oeste","POI_REG001_BRIDGE_W")
	_add("bridge",Vector2(2080,870),1.0,"Ponte Leste","POI_REG001_BRIDGE_E")

func _add(kind: String, pos: Vector2, scale_v: float = 1.0, label: String = "", poi_id: String = "", rect: Rect2 = Rect2(), variant: int = 0, radius: float = 0.0) -> void:
	var world_pos: Vector2 = Region.world_from_hub(pos)
	props.append({"pilot_art":true,"kind":kind,"pos":world_pos,"scale":scale_v,"label":label,"poi_id":poi_id,"variant":variant})
	if rect.size != Vector2.ZERO:
		var world_rect: Rect2 = Rect2(Region.world_from_hub(rect.position),rect.size)
		blockers.append({"type":"rect","rect":world_rect,"kind":kind})
	elif radius > 0.0:
		blockers.append({"type":"circle","pos":world_pos,"radius":radius*scale_v,"kind":kind})
	if poi_id != "":
		pois.append({"id":poi_id,"label":label,"pos":world_pos})

func _near_manual_blocker(p: Vector2, margin: float) -> bool:
	for b in blockers:
		if b["type"] == "rect" and b["rect"].grow(margin).has_point(Region.world_from_hub(p)): return true
	return false

func _road_points() -> Array[PackedVector2Array]:
	return [
		PackedVector2Array([Vector2(1150,0),Vector2(1150,420),Vector2(1150,700),Vector2(1150,860),Vector2(1150,1450),Vector2(1150,1740),Vector2(1150,2350)]),
		PackedVector2Array([Vector2(330,860),Vector2(720,860),Vector2(920,860),Vector2(1150,860),Vector2(1380,860),Vector2(1600,860),Vector2(2040,860)]),
		PackedVector2Array([Vector2(1150,860),Vector2(935,1040),Vector2(760,1125)]),
		PackedVector2Array([Vector2(1150,860),Vector2(1370,1035),Vector2(1540,1130)]),
		PackedVector2Array([Vector2(720,860),Vector2(520,615),Vector2(520,555),Vector2(650,490)]),
		PackedVector2Array([Vector2(1600,860),Vector2(1775,650),Vector2(1775,580),Vector2(1640,490)]),
		PackedVector2Array([Vector2(760,1125),Vector2(590,1295),Vector2(490,1010)]),
		PackedVector2Array([Vector2(1540,1130),Vector2(1705,1295),Vector2(1780,1030)]),
		PackedVector2Array([Vector2(1150,1985),Vector2(815,1998),Vector2(650,1970)]),
		PackedVector2Array([Vector2(1150,2020),Vector2(1760,2030)])
	]

func _near_road(p: Vector2, margin: float) -> bool:
	for path in _road_points():
		for j in range(path.size()-1):
			var a = path[j]; var b = path[j+1]
			var ab = b-a
			var t = clampf((p-a).dot(ab)/maxf(ab.length_squared(),0.001),0.0,1.0)
			if p.distance_to(a+ab*t) < margin: return true
	return false

func is_walkable(p: Vector2) -> bool:
	if not Region.in_region(p,70.0):
		return false
	for blocker in blockers:
		if blocker["type"] == "rect" and blocker["rect"].grow(10).has_point(p): return false
		if blocker["type"] == "circle" and p.distance_to(blocker["pos"]) < float(blocker["radius"])+9: return false
	if not Region.in_authored_hub(p,20.0):
		return true
	var local_p: Vector2 = Region.hub_from_world(p)
	for river in river_polylines:
		for j in range(river.size()-1):
			var a: Vector2 = river[j]
			var b: Vector2 = river[j+1]
			var ab: Vector2 = b-a
			var t: float = clampf((local_p-a).dot(ab)/maxf(ab.length_squared(),0.001),0.0,1.0)
			if local_p.distance_to(a+ab*t) < 46:
				if local_p.distance_to(Vector2(300,900)) > 75 and local_p.distance_to(Vector2(2080,870)) > 75:
					return false
	return true

func blocks_spell(p: Vector2) -> bool:
	if not Region.in_region(p,0.0): return true
	for blocker in blockers:
		if blocker["type"]=="rect" and blocker["rect"].grow(2).has_point(p): return true
		if blocker["type"]=="circle" and p.distance_to(blocker["pos"])<float(blocker["radius"])+2: return true
	return false

func nearest_poi(p: Vector2, radius: float = 145.0) -> Dictionary:
	var best: Dictionary = {}
	var best_d = radius
	for poi in pois:
		var d = p.distance_to(poi["pos"])
		if d < best_d:
			best_d = d; best = poi
	return best

func _draw() -> void:
	if use_baked_ground:
		draw_texture_rect(CITY_GROUND,Rect2(Region.HUB_ORIGIN+CITY_GROUND_RECT.position,CITY_GROUND_RECT.size),false)
		return
	draw_set_transform(Region.HUB_ORIGIN,0.0,Vector2.ONE)
	_draw_ground()
	_draw_rivers()
	_draw_roads()
	_draw_plaza()
	_draw_fields()
	_draw_city_border()
	_draw_royal_grounds()
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_ground() -> void:
	Terrain.grass(self,Rect2(Vector2.ZERO,LOCAL_SIZE),Color.WHITE,Region.HUB_ORIGIN)
	# Three readable spaces: civic stone, residential gardens, cultivated outskirts.
	for center: Vector2 in [Vector2(720,817),Vector2(1580,835),Vector2(760,1145),Vector2(1540,1150)]:
		Terrain.courtyard(self,center,Vector2(115,76),int(center.x))
	for p: Vector2 in [Vector2(520,570),Vector2(650,500),Vector2(1640,510),Vector2(1775,600),Vector2(490,1020),Vector2(1780,1050),Vector2(590,1310),Vector2(1705,1310)]:
		Terrain.courtyard(self,p,Vector2(82,46),int(p.x+p.y))

func _draw_rivers() -> void:
	for river: PackedVector2Array in river_polylines:
		draw_polyline(river,Color("5c7655"),126,true)
		draw_polyline(river,Color("9b9e73"),109,true)
		draw_polyline(river,Color("427f85"),94,true)
		draw_polyline(river,Color("65a99e"),68,true)
		for i in range(river.size()-1):
			var d: Vector2 = (river[i+1]-river[i]).normalized()
			for j in range(int(river[i].distance_to(river[i+1])/35)):
				var p: Vector2 = river[i]+d*float(j)*35.0
				draw_line(p+Vector2(-14,0),p+Vector2(13,-3),Color(0.7,0.87,0.72,0.4),1.5,true)
				for side: float in [-1.0,1.0]:
					var bank: Vector2 = p+Vector2(-d.y,d.x)*side*59.0
					draw_line(bank,bank+Vector2(-3,-10),Color("58744e"),2,true)
					draw_line(bank+Vector2(3,0),bank+Vector2(5,-8),Color("a0aa6a"),1.5,true)

func _draw_roads() -> void:
	var paths: Array[PackedVector2Array] = _road_points()
	for i in range(paths.size()):
		Terrain.path(self,paths[i],88.0 if i < 4 else 46.0,i < 4,441+i)

func _draw_plaza() -> void:
	Terrain.courtyard(self,CENTER,Vector2(245,185),7301)
	# A pale border and restrained radial inlay make the fountain the focal point.
	DrawUtil.ellipse_line(self,CENTER,238,178,Color("d0c2a0"),5,64)
	DrawUtil.ellipse_line(self,CENTER,208,152,Color("8e947b"),3,64)
	DrawUtil.ellipse_line(self,CENTER,79,54,Color("e0cfa7"),7,48)
	for i in range(8):
		var angle: float = TAU*float(i)/8.0
		var d: Vector2 = Vector2(cos(angle),sin(angle)*0.74)
		draw_line(CENTER+d*90.0,CENTER+d*198.0,Color("9a9f85"),2,true)

func _draw_fields() -> void:
	var plots: Array[Rect2] = [
		Rect2(280,1710,520,250),
		Rect2(285,2040,540,220),
		Rect2(1490,1715,515,245),
		Rect2(1475,2045,535,215)
	]
	for plot in plots:
		draw_rect(plot.grow(7),Color("8b8b5d"))
		draw_rect(plot,Color("93815b"))
		for y in range(int(plot.position.y)+28,int(plot.end.y)-15,27):
			draw_line(Vector2(plot.position.x+14,y+6),Vector2(plot.end.x-14,y+6),Color("736d4c"),5,true)
			for x in range(int(plot.position.x)+22,int(plot.end.x)-20,18):
				var p: Vector2 = Vector2(x,y)
				if _near_manual_blocker(p,20) or _near_road(p,34): continue
				var height: float = 13.0+float(posmod(x+y,7))
				draw_line(p+Vector2(0,7),p+Vector2(-1,-height),Color("d5bf76"),1.5,true)
				draw_line(p,p+Vector2(-5,-7),Color("a6ad62"),1.5,true)
				draw_line(p+Vector2(0,-4),p+Vector2(5,-10),Color("b6b869"),1.5,true)
				for j in range(3):
					var ear: Vector2 = p+Vector2(-1,-height+float(j)*3.0)
					DrawUtil.ellipse(self,ear+Vector2(-2,-1),2.8,1.5,Color("e0c783"),8)
					DrawUtil.ellipse(self,ear+Vector2(2,1),2.8,1.5,Color("c9b16a"),8)

func _draw_city_border() -> void:
	# low masonry markers hint at hub boundary without boxing player in.
	for x in range(520,1790,130):
		DrawUtil.rect_outlined(self,Rect2(x,245,86,18),Color(0.65,0.64,0.60),DrawUtil.OUTLINE,2)
	for x in range(520,1790,130):
		DrawUtil.rect_outlined(self,Rect2(x,1485,86,18),Color(0.65,0.64,0.60),DrawUtil.OUTLINE,2)
	for x in range(350,850,72):
		draw_line(Vector2(x,1695),Vector2(x,1970),Color(0.45,0.30,0.14,0.30),2)
	for x in range(1480,2010,72):
		draw_line(Vector2(x,1695),Vector2(x,1970),Color(0.45,0.30,0.14,0.30),2)

func _draw_royal_grounds() -> void:
	var estate: Rect2 = Rect2(Vector2(1480,-1680),Vector2(2040,1840))
	Terrain.grass(self,estate,Color.WHITE,Region.HUB_ORIGIN)
	Terrain.courtyard(self,Vector2(2500,-70),Vector2(645,225),23)
	Terrain.path(self,PackedVector2Array([Vector2(1150,310),Vector2(1150,120),Vector2(2500,120),Vector2(2500,-250)]),146.0,true,23)
	# Gardens frame the ceremonial approach, keeping the main axis open.
	for side: float in [-1,1]:
		for y: float in [-90,80]:
			var p: Vector2 = Vector2(2500+side*485,y)
			draw_rect(Rect2(p-Vector2(120,42),Vector2(240,84)),Color("577253"))
			draw_rect(Rect2(p-Vector2(120,42),Vector2(240,84)),Color("b3b18a"),false,6)
			for i in range(10):
				var flower: Vector2 = p+Vector2(-100+float(i)*22,sin(float(i))*18)
				draw_circle(flower,5,Color("e9d2a1"))
