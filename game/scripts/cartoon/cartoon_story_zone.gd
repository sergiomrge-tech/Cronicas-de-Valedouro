class_name ValedouroCartoonStoryZone
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

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
		_: _draw_generic_zone()

func _draw_generic_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.46,0.70,0.31,0.55),32)

func _draw_north_road_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.48,Color(0.50,0.72,0.31,0.44),32)
	for x in [-160.0,160.0]:
		for y in [-110.0,0.0,110.0]:
			var p: Vector2 = Vector2(x+sin(y*0.07)*18.0,y)
			DrawUtil.ellipse(self,p,34,17,Color(0.31,0.58,0.23,0.55),20)

func _draw_first_wind_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.68,Color(0.45,0.63,0.35,0.75),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.82,radius*0.54,Color(0.35,0.34,0.30,0.45),4,32)
	for a in range(0,360,45):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		var p: Vector2 = d * radius * 0.72
		DrawUtil.rect_outlined(self,Rect2(p-Vector2(8,22),Vector2(16,44)),Color(0.54,0.55,0.52),DrawUtil.OUTLINE,2)
	for p in [Vector2(-115,48),Vector2(92,-66),Vector2(138,42),Vector2(-70,-92)]:
		DrawUtil.ellipse(self,p,22,10,Color(0.46,0.47,0.44))
	DrawUtil.circle_outlined(self,Vector2.ZERO,30,Color(0.65,0.66,0.62),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2.ZERO,11,Color(0.31,0.73,0.94),DrawUtil.OUTLINE,2)

func _draw_alpha_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.72,Color(0.38,0.61,0.29,0.85),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.83,radius*0.59,Color(0.28,0.23,0.17,0.35),5,32)
	for a in range(0,360,40):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		var p: Vector2 = d * radius * 0.78
		DrawUtil.ellipse(self,p,28,13,Color(0.28,0.48,0.20,0.75))
	for p in [Vector2(-55,25),Vector2(70,-20),Vector2(15,65)]:
		DrawUtil.ellipse(self,p,17,7,Color(0.43,0.45,0.42))
	draw_arc(Vector2.ZERO,78,0,TAU,28,Color(0.34,0.20,0.13,0.35),3,true)

func _draw_mine_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.58,Color(0.39,0.48,0.31,0.70),32)
	for i in range(14):
		var a: float = TAU * float(i) / 14.0
		var d: Vector2 = Vector2.RIGHT.rotated(a)
		var p: Vector2 = d * radius * 0.76
		DrawUtil.ellipse(self,p,24+float(i%3)*7,12+float(i%2)*5,Color(0.40+float(i%2)*0.05,0.42,0.40))
	for p in [Vector2(-95,-24),Vector2(105,20)]:
		DrawUtil.flame(self,p,20,8,float(Time.get_ticks_msec())/1000.0)

func _draw_archive_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.66,Color(0.67,0.66,0.57,0.82),32)
	for r in [70.0,130.0,190.0]:
		DrawUtil.ellipse_line(self,Vector2.ZERO,r,r*0.66,Color(0.44,0.40,0.32,0.32),2,32)
	for x in [-180.0,180.0]:
		for y in [-75.0,55.0]:
			DrawUtil.rect_outlined(self,Rect2(Vector2(x-24,y-10),Vector2(48,20)),Color(0.28,0.56,0.25),DrawUtil.OUTLINE,2)
