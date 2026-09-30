class_name ValedouroCartoonFrostStoryZone
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var zone_kind: String = "rest"
var radius: float = 650.0

func setup(data: Dictionary) -> void:
	zone_kind = String(data.get("zone_kind","rest"))
	radius = float(data.get("radius",650.0))
	position = data.get("pos",Vector2.ZERO)
	z_index = -12
	queue_redraw()

func _draw() -> void:
	match zone_kind:
		"rest": _draw_rest()
		"station": _draw_station()
		"captain": _draw_captain()
		"archive": _draw_archive_zone()
		"citadel": _draw_citadel()
		"return": _draw_return()
		_: DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.72,0.82,0.88,0.45),32)

func _draw_rest() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.74,0.84,0.89,0.76),32)
	for p in [Vector2(-310,150),Vector2(300,140),Vector2(-260,-160),Vector2(270,-150)]:
		DrawUtil.ellipse(self,p,42,16,Color(0.55,0.66,0.72,0.55))

func _draw_station() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.64,Color(0.67,0.78,0.84,0.82),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.78,radius*0.50,Color(0.38,0.48,0.56,0.38),5,32)
	for a in range(0,360,45):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		DrawUtil.ellipse(self,d*radius*0.70,28,12,Color(0.47,0.56,0.62,0.66))

func _draw_captain() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.70,Color(0.62,0.72,0.79,0.86),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.78,radius*0.55,Color(0.21,0.39,0.53,0.48),8,32)
	for a in range(0,360,36):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		draw_line(d*radius*0.74,d*radius*0.59,Color(0.42,0.52,0.58),8)

func _draw_archive_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.66,Color(0.70,0.80,0.86,0.82),32)
	for r in [150.0,300.0,450.0]:
		DrawUtil.ellipse_line(self,Vector2.ZERO,r,r*0.66,Color(0.32,0.63,0.76,0.30),4,32)

func _draw_citadel() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.72,Color(0.48,0.58,0.66,0.92),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.80,radius*0.58,Color(0.14,0.25,0.36,0.62),9,32)
	for a in range(0,360,30):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		DrawUtil.ellipse(self,d*radius*0.73,26,12,Color(0.28,0.35,0.40,0.76))

func _draw_return() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.60,Color(0.70,0.79,0.83,0.72),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.72,radius*0.45,Color(0.80,0.64,0.28,0.35),6,32)
