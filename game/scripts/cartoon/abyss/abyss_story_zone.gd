class_name ValedouroCartoonAbyssStoryZone
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var zone_kind: String = "gate"
var radius: float = 800.0

func setup(data: Dictionary) -> void:
	zone_kind = String(data.get("zone_kind","gate"))
	radius = float(data.get("radius",800.0))
	position = data.get("pos",Vector2.ZERO)
	z_index = -12
	queue_redraw()

func _draw() -> void:
	match zone_kind:
		"gate": _draw_gate_zone()
		"paths": _draw_paths()
		"archive": _draw_archive_zone()
		"antechamber": _draw_antechamber()
		"throne": _draw_throne()
		"earth": _draw_earth()
		_: DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.19,0.15,0.25,0.60),32)

func _draw_gate_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.18,0.15,0.25,0.88),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.80,radius*0.55,Color(0.55,0.26,0.72,0.55),9,32)

func _draw_paths() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.68,Color(0.16,0.14,0.23,0.90),32)
	for a in range(0,360,45):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		draw_line(Vector2.ZERO,d*radius*0.72,Color(0.36,0.24,0.48,0.45),10)

func _draw_archive_zone() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.70,Color(0.13,0.11,0.20,0.94),32)
	for r in [220.0,440.0,660.0]:
		DrawUtil.ellipse_line(self,Vector2.ZERO,r,r*0.70,Color(0.49,0.20,0.68,0.42),6,32)

func _draw_antechamber() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.66,Color(0.17,0.13,0.20,0.94),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.76,radius*0.50,Color(0.70,0.47,0.25,0.35),7,32)

func _draw_throne() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.74,Color(0.10,0.08,0.14,0.97),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.82,radius*0.60,Color(0.68,0.10,0.38,0.70),10,32)
	for a in range(0,360,24):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		DrawUtil.ellipse(self,d*radius*0.75,28,12,Color(0.24,0.17,0.28,0.80))

func _draw_earth() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.28,0.45,0.58,0.85),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.72,radius*0.46,Color(0.68,0.91,1.0,0.70),10,32)
	for a in range(0,360,30):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		draw_line(d*radius*0.70,d*radius*0.56,Color(0.79,0.96,1.0,0.56),6)
