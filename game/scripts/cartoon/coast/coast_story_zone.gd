class_name ValedouroCartoonCoastStoryZone
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var zone_kind: String = "port"
var radius: float = 800.0

func setup(data: Dictionary) -> void:
	zone_kind = String(data.get("zone_kind","port"))
	radius = float(data.get("radius",800.0))
	position = data.get("pos",Vector2.ZERO)
	z_index = -12
	queue_redraw()

func _draw() -> void:
	match zone_kind:
		"port": _draw_port()
		"lighthouse": _draw_lighthouse()
		"temple": _draw_temple()
		"shipyard": _draw_shipyard()
		"observatory": _draw_observatory()
		_: DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.24,0.58,0.64,0.48),32)

func _draw_port() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.60,Color(0.28,0.61,0.65,0.74),32)
	for x in [-420.0,-210.0,0.0,210.0,420.0]:
		draw_line(Vector2(x,-radius*0.42),Vector2(x,radius*0.42),Color(0.49,0.35,0.19,0.42),10)

func _draw_lighthouse() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.34,0.66,0.68,0.78),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.75,radius*0.48,Color(0.89,0.85,0.56,0.32),6,32)
	for p in [Vector2(-420,150),Vector2(410,140),Vector2(-350,-190),Vector2(360,-180)]:
		DrawUtil.ellipse(self,p,40,16,Color(0.50,0.58,0.55,0.60))

func _draw_temple() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.70,Color(0.18,0.49,0.58,0.86),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.80,radius*0.56,Color(0.34,0.77,0.80,0.45),8,32)
	for r in [240.0,480.0,720.0]:
		DrawUtil.ellipse_line(self,Vector2.ZERO,r,r*0.70,Color(0.54,0.74,0.68,0.20),3,32)

func _draw_shipyard() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.66,Color(0.31,0.58,0.57,0.84),32)
	for y in [-360.0,-120.0,120.0,360.0]:
		draw_line(Vector2(-radius*0.65,y),Vector2(radius*0.65,y),Color(0.43,0.31,0.18,0.48),11)
	for p in [Vector2(-520,-260),Vector2(500,-250),Vector2(-500,270),Vector2(520,250)]:
		DrawUtil.ellipse(self,p,48,18,Color(0.34,0.43,0.42,0.65))

func _draw_observatory() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.72,Color(0.20,0.45,0.53,0.90),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.79,radius*0.57,Color(0.22,0.72,0.82,0.58),9,32)
	for a in range(0,360,30):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		DrawUtil.ellipse(self,d*radius*0.73,28,12,Color(0.31,0.40,0.44,0.72))
