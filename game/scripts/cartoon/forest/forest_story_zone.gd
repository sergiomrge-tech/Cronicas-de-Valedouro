class_name ValedouroCartoonForestStoryZone
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var zone_kind: String = "grove"
var radius: float = 420.0
var label: String = ""

func setup(data: Dictionary) -> void:
	zone_kind = String(data.get("zone_kind","grove"))
	radius = float(data.get("radius",420.0))
	label = String(data.get("label",""))
	position = data.get("pos",Vector2.ZERO)
	z_index = -12
	queue_redraw()

func _draw() -> void:
	match zone_kind:
		"bridge":
			_draw_bridge_zone()
		"lodge":
			_draw_lodge_zone()
		"shrines":
			_draw_shrine_zone()
		"memory":
			_draw_memory_zone()
		"hollow":
			_draw_hollow_zone()
		"cartographer":
			_draw_cartographer_zone()
		_:
			DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.65,Color(0.30,0.58,0.26,0.45),32)

func _draw_bridge_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.42,Color(0.34,0.64,0.29,0.42),32)
	draw_rect(Rect2(-radius,-86.0,radius*2.0,172.0),Color(0.20,0.55,0.72,0.92))
	for x in range(int(-radius),int(radius),90):
		draw_line(Vector2(x,-48),Vector2(x+48,-22),Color(0.64,0.90,0.94,0.34),4)

func _draw_lodge_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.39,0.68,0.31,0.74),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.84,radius*0.50,Color(0.20,0.38,0.18,0.32),4,32)
	for p in [Vector2(-240,120),Vector2(230,130),Vector2(-210,-130),Vector2(220,-120)]:
		DrawUtil.ellipse(self,p,42,18,Color(0.25,0.51,0.22,0.72))

func _draw_shrine_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.66,Color(0.32,0.61,0.28,0.72),32)
	for r in [95.0,190.0,285.0]:
		DrawUtil.ellipse_line(self,Vector2.ZERO,r,r*0.66,Color(0.50,0.37,0.18,0.28),3,32)
	for a in range(0,360,30):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		DrawUtil.ellipse(self,d*radius*0.74,24,11,Color(0.23,0.49,0.20,0.66))

func _draw_memory_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.70,Color(0.29,0.57,0.29,0.78),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.78,radius*0.54,Color(0.42,0.83,0.72,0.28),5,32)
	for a in range(0,360,45):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		var p: Vector2 = d*radius*0.68
		DrawUtil.circle_outlined(self,p,10,Color(0.35,0.83,0.72),DrawUtil.OUTLINE,2)

func _draw_hollow_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.72,Color(0.23,0.39,0.23,0.88),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.78,radius*0.56,Color(0.34,0.16,0.25,0.52),8,32)
	for a in range(0,360,30):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		draw_line(d*radius*0.74,d*radius*0.58,Color(0.31,0.20,0.12),12)

func _draw_cartographer_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.64,Color(0.44,0.58,0.38,0.76),32)
	for r in [85.0,165.0,250.0,330.0]:
		DrawUtil.ellipse_line(self,Vector2.ZERO,r,r*0.64,Color(0.58,0.57,0.50,0.34),3,32)
	draw_line(Vector2(-radius*0.60,0),Vector2(radius*0.60,0),Color(0.68,0.63,0.46,0.35),5)
	draw_line(Vector2(0,-radius*0.40),Vector2(0,radius*0.40),Color(0.68,0.63,0.46,0.35),5)
