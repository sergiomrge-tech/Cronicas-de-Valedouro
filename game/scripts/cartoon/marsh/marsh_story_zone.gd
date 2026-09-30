class_name ValedouroCartoonMarshStoryZone
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var zone_kind: String = "village"
var radius: float = 600.0

func setup(data: Dictionary) -> void:
	zone_kind = String(data.get("zone_kind","village"))
	radius = float(data.get("radius",600.0))
	position = data.get("pos",Vector2.ZERO)
	z_index = -12
	queue_redraw()

func _draw() -> void:
	match zone_kind:
		"village": _draw_village()
		"bell": _draw_bell()
		"monastery": _draw_monastery()
		"sanctum": _draw_sanctum()
		"throne": _draw_throne()
		"sluice": _draw_sluice()
		_: DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.24,0.45,0.28,0.55),32)

func _draw_village() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.28,0.50,0.31,0.80),32)
	for x in [-320.0,-110.0,120.0,330.0]:
		draw_line(Vector2(x,-radius*0.45),Vector2(x,radius*0.45),Color(0.50,0.36,0.20,0.45),10)
	for p in [Vector2(-280,-170),Vector2(270,-150),Vector2(-260,180),Vector2(290,170)]:
		DrawUtil.circle_outlined(self,p,8,Color(0.95,0.75,0.22),DrawUtil.OUTLINE,2)

func _draw_bell() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.58,Color(0.22,0.42,0.31,0.78),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.74,radius*0.44,Color(0.22,0.53,0.59,0.45),6,32)
	for a in range(0,360,45):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		DrawUtil.ellipse(self,d*radius*0.67,28,12,Color(0.39,0.46,0.37,0.62))

func _draw_monastery() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.70,Color(0.22,0.38,0.30,0.86),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.80,radius*0.54,Color(0.16,0.40,0.45,0.55),8,32)
	for p in [Vector2(-420,210),Vector2(410,220),Vector2(-390,-220),Vector2(390,-210)]:
		DrawUtil.ellipse(self,p,50,17,Color(0.36,0.43,0.37,0.70))

func _draw_sanctum() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.64,Color(0.26,0.44,0.28,0.84),32)
	for r in [160.0,320.0,480.0]:
		DrawUtil.ellipse_line(self,Vector2.ZERO,r,r*0.64,Color(0.49,0.65,0.29,0.28),4,32)
	for a in range(0,360,30):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		draw_line(d*radius*0.72,d*radius*0.58,Color(0.33,0.45,0.18),7)

func _draw_throne() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.72,Color(0.18,0.33,0.25,0.92),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.78,radius*0.56,Color(0.48,0.17,0.31,0.56),8,32)
	for a in range(0,360,24):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		draw_line(d*radius*0.74,d*radius*0.60,Color(0.30,0.39,0.16),10)

func _draw_sluice() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.19,0.38,0.36,0.86),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.72,radius*0.46,Color(0.25,0.70,0.78,0.50),8,32)
	for x in [-360.0,-180.0,0.0,180.0,360.0]:
		draw_line(Vector2(x,-radius*0.38),Vector2(x,radius*0.38),Color(0.47,0.49,0.46,0.50),8)
