class_name ValedouroCartoonHubEnvironment
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

const WORLD_SIZE := Vector2(2300, 1700)
const CENTER := Vector2(1150, 860)

var rng := RandomNumberGenerator.new()
var props: Array[Dictionary] = []
var blockers: Array[Dictionary] = []
var pois: Array[Dictionary] = []
var river_polylines: Array[PackedVector2Array] = []

func _ready() -> void:
	z_index = -20
	rng.seed = 20260930
	_build_layout()
	queue_redraw()

func _build_layout() -> void:
	props.clear(); blockers.clear(); pois.clear(); river_polylines.clear()
	# Core landmarks: manually authored, then decorative ring around them.
	_add("castle",Vector2(1150,510),1.45,"Castelo de Valedouro","POI_REG001_CASTLE",Rect2(985,365,330,205))
	_add("fountain",CENTER,1.25,"Praça Central","POI_REG001_PLAZA",Rect2(1090,805,120,85))
	_add("forge",Vector2(720,790),1.25,"Ferreiro","POI_REG001_FORGE",Rect2(640,675,160,130))
	_add("tavern",Vector2(1580,800),1.28,"Taverna","POI_REG001_TAVERN",Rect2(1490,680,180,135))
	_add("guild",Vector2(760,1125),1.22,"Guilda","POI_REG001_GUILD",Rect2(675,1010,170,135))
	_add("alchemist",Vector2(1540,1130),1.18,"Alquimista","POI_REG001_ALCHEMIST",Rect2(1460,1025,160,130))
	for p in [Vector2(920,765),Vector2(1380,760),Vector2(945,1080),Vector2(1365,1080)]: _add("market",p,0.9,"Mercado","",Rect2(p-Vector2(45,50),Vector2(90,65)))
	for p in [Vector2(985,935),Vector2(1310,930),Vector2(1000,1180),Vector2(1300,1180)]: _add("bench",p,0.85)
	for p in [Vector2(930,700),Vector2(1370,700),Vector2(890,980),Vector2(1410,980),Vector2(910,1210),Vector2(1390,1210)]: _add("lamp",p,0.9)
	_add("well",Vector2(1265,1085),0.9,"Poço da Praça","POI_REG001_WELL",Rect2(1225,1040,80,70))
	# Residential ring
	var homes := [Vector2(520,545),Vector2(650,475),Vector2(1640,480),Vector2(1775,570),Vector2(490,990),Vector2(1780,1015),Vector2(590,1280),Vector2(1705,1280)]
	for i in homes.size(): _add("house",homes[i],1.0 + float(i%3)*0.06,"Casa","",Rect2(homes[i]-Vector2(58,95),Vector2(116,115)),i)
	# City gate / roads decorative signs
	_add("sign",Vector2(1150,1340),0.95,"Portão Sul","POI_REG001_GATE_SOUTH")
	_add("sign",Vector2(1150,290),0.85,"Estrada Norte","POI_REG001_GATE_NORTH")
	# deterministic vegetation outside plaza core
	for i in 110:
		var p := Vector2(rng.randf_range(110,2190),rng.randf_range(180,1560))
		if p.distance_to(CENTER) < 360 or p.distance_to(Vector2(1150,520)) < 330: continue
		if _near_road(p,100): continue
		if _near_manual_blocker(p,95): continue
		var k := "tree" if rng.randf() < 0.56 else "pine" if rng.randf() < 0.72 else "bush"
		_add(k,p,rng.randf_range(0.72,1.10),"","",Rect2(),rng.randi()%3,28.0 if k != "bush" else 17.0)
	for i in 70:
		var p := Vector2(rng.randf_range(140,2160),rng.randf_range(190,1510))
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
	props.append({"kind":kind,"pos":pos,"scale":scale_v,"label":label,"poi_id":poi_id,"variant":variant})
	if rect.size != Vector2.ZERO: blockers.append({"type":"rect","rect":rect,"kind":kind})
	elif radius > 0.0: blockers.append({"type":"circle","pos":pos,"radius":radius*scale_v,"kind":kind})
	if poi_id != "": pois.append({"id":poi_id,"label":label,"pos":pos})

func _near_manual_blocker(p: Vector2, margin: float) -> bool:
	for b in blockers:
		if b["type"] == "rect" and b["rect"].grow(margin).has_point(p): return true
	return false

func _road_points() -> Array[PackedVector2Array]:
	return [
		PackedVector2Array([Vector2(1150,150),Vector2(1150,420),Vector2(1150,700),Vector2(1150,860),Vector2(1150,1450),Vector2(1150,1650)]),
		PackedVector2Array([Vector2(330,860),Vector2(720,860),Vector2(920,860),Vector2(1150,860),Vector2(1380,860),Vector2(1600,860),Vector2(2040,860)]),
		PackedVector2Array([Vector2(1150,860),Vector2(935,1040),Vector2(760,1125)]),
		PackedVector2Array([Vector2(1150,860),Vector2(1370,1035),Vector2(1540,1130)])
	]

func _near_road(p: Vector2, margin: float) -> bool:
	for path in _road_points():
		for j in range(path.size()-1):
			var a := path[j]; var b := path[j+1]
			var ab := b-a
			var t := clampf((p-a).dot(ab)/maxf(ab.length_squared(),0.001),0.0,1.0)
			if p.distance_to(a+ab*t) < margin: return true
	return false

func is_walkable(p: Vector2) -> bool:
	if p.x < 70 or p.y < 90 or p.x > WORLD_SIZE.x-70 or p.y > WORLD_SIZE.y-70: return false
	# Rivers are blocked except around bridges.
	for river in river_polylines:
		for j in range(river.size()-1):
			var a := river[j]; var b := river[j+1]; var ab := b-a
			var t := clampf((p-a).dot(ab)/maxf(ab.length_squared(),0.001),0.0,1.0)
			if p.distance_to(a+ab*t) < 46:
				if p.distance_to(Vector2(300,900)) > 75 and p.distance_to(Vector2(2080,870)) > 75: return false
	for b in blockers:
		if b["type"] == "rect" and b["rect"].grow(10).has_point(p): return false
		if b["type"] == "circle" and p.distance_to(b["pos"]) < float(b["radius"])+9: return false
	return true

func nearest_poi(p: Vector2, radius: float = 145.0) -> Dictionary:
	var best: Dictionary = {}
	var best_d := radius
	for poi in pois:
		var d := p.distance_to(poi["pos"])
		if d < best_d:
			best_d = d; best = poi
	return best

func _draw() -> void:
	_draw_ground()
	_draw_rivers()
	_draw_roads()
	_draw_plaza()
	_draw_city_border()

func _draw_ground() -> void:
	draw_rect(Rect2(Vector2.ZERO,WORLD_SIZE),Color(0.43,0.72,0.30))
	rng.seed = 7301
	for i in 65:
		var p := Vector2(rng.randf_range(0,WORLD_SIZE.x),rng.randf_range(0,WORLD_SIZE.y))
		var col := Color(0.53,0.80,0.35,0.28) if i%2==0 else Color(0.32,0.61,0.25,0.25)
		DrawUtil.ellipse(self,p,rng.randf_range(65,180),rng.randf_range(25,62),col,22)
	for i in 180:
		var p := Vector2(rng.randf_range(40,WORLD_SIZE.x-40),rng.randf_range(80,WORLD_SIZE.y-50))
		draw_line(p,p+Vector2(rng.randf_range(-2,2),rng.randf_range(-8,-4)),Color(0.28,0.58,0.22,0.45),1.5)

func _draw_rivers() -> void:
	for river in river_polylines:
		draw_polyline(river,Color(0.25,0.50,0.63),108,true)
		draw_polyline(river,Color(0.18,0.65,0.88),88,true)
		draw_polyline(river,Color(0.44,0.86,0.96,0.7),5,true)

func _draw_roads() -> void:
	for path in _road_points():
		draw_polyline(path,Color(0.47,0.59,0.27),122,true)
		draw_polyline(path,Color(0.79,0.65,0.43),103,true)
		for p in path: draw_circle(p,51.5,Color(0.79,0.65,0.43))
	# cobbles
	rng.seed = 441
	for i in 125:
		var p := Vector2(rng.randf_range(340,1990),rng.randf_range(360,1480))
		if _near_road(p,38): DrawUtil.ellipse(self,p,rng.randf_range(2,5),rng.randf_range(1.5,3),Color(0.45,0.38,0.29,0.5))

func _draw_plaza() -> void:
	DrawUtil.ellipse(self,CENTER,245,185,Color(0.75,0.70,0.59),32)
	DrawUtil.ellipse_line(self,CENTER,245,185,Color(0.34,0.28,0.24,0.55),5,32)
	for r in [65.0,120.0,175.0]: DrawUtil.ellipse_line(self,CENTER,r,r*0.74,Color(0.58,0.53,0.45,0.45),2,32)

func _draw_city_border() -> void:
	# low masonry markers hint at hub boundary without boxing player in.
	for x in range(520,1790,130):
		DrawUtil.rect_outlined(self,Rect2(x,245,86,18),Color(0.65,0.64,0.60),DrawUtil.OUTLINE,2)
	for x in range(520,1790,130):
		DrawUtil.rect_outlined(self,Rect2(x,1485,86,18),Color(0.65,0.64,0.60),DrawUtil.OUTLINE,2)
