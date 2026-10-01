class_name ValedouroCartoonStoryZone
extends Node2D
## Authored ground composition for mission places. Decoration stays off entrances.

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const Terrain = preload("res://scripts/cartoon/cartoon_terrain_art.gd")

var zone_kind: String = "road"
var zone_label: String = ""
var radius: float = 220.0
var variant: int = 0

func setup(data: Dictionary) -> void:
	zone_kind = String(data.get("zone_kind","road"))
	zone_label = String(data.get("label",""))
	position = data.get("pos",Vector2.ZERO)
	radius = float(data.get("radius",220.0))
	variant = int(data.get("variant",0))
	z_index = -12
	queue_redraw()

func _draw() -> void:
	match zone_kind:
		"north_road": _draw_north_road_zone()
		"first_wind": _draw_first_wind_zone()
		"alpha": _draw_alpha_zone()
		"mine": _draw_mine_zone()
		"archive": _draw_archive_zone()
		_: _clearing(Color(0.50,0.55,0.36,0.35))

func _clearing(color: Color) -> void:
	# Feathered, asymmetric soil instead of a hard circle under every landmark.
	for layer in range(3):
		var points: PackedVector2Array = PackedVector2Array()
		var factor: float = 1.0-float(layer)*0.10
		for i in range(48):
			var angle: float = TAU*float(i)/48.0
			var wobble: float = 1.0+sin(angle*5.0+float(variant))*0.055+cos(angle*3.0)*0.04
			points.append(Vector2(cos(angle),sin(angle)*0.66)*radius*wobble*factor)
		var fill: Color = color
		fill.a *= 0.35
		draw_colored_polygon(points,fill)

func _scatter_stones(count: int, seed_value: int) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(count):
		var p: Vector2 = Vector2(rng.randf_range(-radius*0.8,radius*0.8),rng.randf_range(-radius*0.45,radius*0.55))
		Terrain.stone(self,p,Vector2(rng.randf_range(8,18),rng.randf_range(5,9)),Color("9a9e7d").darkened(rng.randf_range(0,0.12)))

func _draw_north_road_zone() -> void:
	_clearing(Color(0.55,0.62,0.38,0.42))
	for x: float in [-155.0,155.0]:
		for y: float in [-110.0,10.0,100.0]:
			var p: Vector2 = Vector2(x+sin(y*0.07)*18.0,y)
			DrawUtil.ellipse(self,p,35,14,Color(0.34,0.43,0.28,0.22),24)

func _draw_first_wind_zone() -> void:
	_clearing(Color(0.60,0.58,0.41,0.65))
	Terrain.courtyard(self,Vector2(0,34),Vector2(radius*0.68,radius*0.34),319)
	# Ruined foundations reveal the former enclosure, with broken gaps for access.
	for i in range(18):
		var angle: float = TAU*float(i)/18.0
		var p: Vector2 = Vector2(cos(angle)*radius*0.82,sin(angle)*radius*0.52)
		if absf(p.y) < 70.0 or absf(p.x) < 65.0: continue
		Terrain.stone(self,p,Vector2(32,17),Color("7d927a"))
		Terrain.stone(self,p+Vector2(2,-5),Vector2(29,12),Color("b2b597"))
		draw_line(p+Vector2(13,-4),p+Vector2(11,8),Color("5f7564"),1.5,true)
	_scatter_stones(24,531)

func _draw_alpha_zone() -> void:
	_clearing(Color(0.52,0.47,0.31,0.72))
	# A worn central clearing is surrounded by the authored forest silhouette.
	for p: Vector2 in [Vector2(-94,41),Vector2(75,-40),Vector2(22,96)]:
		DrawUtil.ellipse(self,p,52,18,Color(0.39,0.43,0.28,0.22),24)
	_scatter_stones(18,818)
	for p: Vector2 in [Vector2(-130,-90),Vector2(148,75)]:
		draw_line(p,p+Vector2(30,-7),Color("665943"),8,true)
		draw_line(p+Vector2(0,-2),p+Vector2(27,-9),Color("a79a69"),2,true)

func _draw_mine_zone() -> void:
	_clearing(Color(0.48,0.54,0.44,0.82))
	# A rock shelf behind the opening embeds the mine in the hillside.
	for i in range(9):
		var p: Vector2 = Vector2(-215.0+float(i)*48.0,-100.0-absf(sin(float(i)*0.7))*55.0)
		var points: PackedVector2Array = PackedVector2Array([p+Vector2(-28,10),p+Vector2(-22,-25),p+Vector2(8,-40),p+Vector2(39,-15),p+Vector2(38,18)])
		draw_colored_polygon(points,Color("6c8272"))
		draw_polyline(PackedVector2Array([points[0],points[1],points[2],points[3]]),Color("9fab8b"),3,true)
	_scatter_stones(45,957)
	Terrain.path(self,PackedVector2Array([Vector2(0,35),Vector2(0,210)]),60,false,745)

func _draw_archive_zone() -> void:
	_clearing(Color(0.60,0.62,0.44,0.7))
	Terrain.courtyard(self,Vector2(0,36),Vector2(radius*0.80,radius*0.45),914)
	for x: float in [-165.0,165.0]:
		for y: float in [-80.0,85.0]:
			DrawUtil.ellipse(self,Vector2(x,y),43,21,Color("697c50"),24)
			DrawUtil.ellipse_line(self,Vector2(x,y),44,22,Color("b4b092"),3,32)
			for j in range(7):
				var p: Vector2 = Vector2(x-24+float(j)*8.0,y+sin(float(j))*6.0)
				draw_circle(p,2.2,Color("d8bb85"))
