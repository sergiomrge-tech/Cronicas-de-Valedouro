class_name ValedouroCartoonDesertStoryZone
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var zone_kind: String = "caravan"
var radius: float = 500.0

func setup(data: Dictionary) -> void:
	zone_kind = String(data.get("zone_kind","caravan"))
	radius = float(data.get("radius",500.0))
	position = data.get("pos",Vector2.ZERO)
	z_index = -12
	queue_redraw()

func _draw() -> void:
	match zone_kind:
		"caravan": _draw_caravan()
		"outpost": _draw_outpost()
		"city": _draw_city()
		"cistern": _draw_cistern()
		"observatory": _draw_observatory()
		"citadel": _draw_citadel()
		_: DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.6,Color(0.74,0.60,0.36,0.55),32)

func _draw_caravan() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.50,Color(0.84,0.69,0.39,0.72),32)
	for p in [Vector2(-260,80),Vector2(250,90),Vector2(-210,-120),Vector2(220,-110)]:
		DrawUtil.ellipse(self,p,34,14,Color(0.55,0.39,0.22,0.45))

func _draw_outpost() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.80,0.64,0.36,0.78),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.82,radius*0.50,Color(0.45,0.30,0.18,0.35),4,32)
	for a in range(0,360,60):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		DrawUtil.rect_outlined(self,Rect2(d*radius*0.70-Vector2(9,18),Vector2(18,36)),Color(0.56,0.42,0.26),DrawUtil.OUTLINE,2)

func _draw_city() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.70,Color(0.65,0.54,0.38,0.82),32)
	for r in [220.0,430.0,650.0]:
		DrawUtil.ellipse_line(self,Vector2.ZERO,r,r*0.70,Color(0.38,0.31,0.25,0.32),4,32)
	for p in [Vector2(-520,-180),Vector2(480,-200),Vector2(-460,230),Vector2(510,190)]:
		DrawUtil.ellipse(self,p,48,19,Color(0.48,0.42,0.34,0.62))

func _draw_cistern() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.60,Color(0.64,0.52,0.35,0.74),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.68,radius*0.40,Color(0.20,0.24,0.24,0.50),6,32)
	for a in range(0,360,45):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		draw_line(d*radius*0.60,d*radius*0.47,Color(0.42,0.31,0.20),7)

func _draw_observatory() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.64,Color(0.54,0.47,0.38,0.82),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.72,radius*0.46,Color(0.72,0.28,0.14,0.38),6,32)
	for p in [Vector2(-330,110),Vector2(315,105),Vector2(-275,-160),Vector2(285,-155)]:
		DrawUtil.ellipse(self,p,36,15,Color(0.37,0.36,0.34,0.62))

func _draw_citadel() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.70,Color(0.48,0.39,0.34,0.88),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.78,radius*0.55,Color(0.69,0.20,0.10,0.48),8,32)
	for a in range(0,360,30):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		DrawUtil.ellipse(self,d*radius*0.72,26,12,Color(0.31,0.29,0.28,0.72))
