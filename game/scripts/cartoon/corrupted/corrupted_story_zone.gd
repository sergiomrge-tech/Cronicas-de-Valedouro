class_name ValedouroCartoonCorruptedStoryZone
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var zone_kind: String = "bastion"
var radius: float = 900.0

func setup(data: Dictionary) -> void:
	zone_kind = String(data.get("zone_kind","bastion"))
	radius = float(data.get("radius",900.0))
	position = data.get("pos",Vector2.ZERO)
	z_index = -12
	queue_redraw()

func _draw() -> void:
	match zone_kind:
		"bastion": _draw_bastion()
		"obelisks": _draw_obelisks()
		"cathedral": _draw_cathedral()
		"council": _draw_council()
		"citadel": _draw_citadel()
		_: DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.33,0.25,0.29,0.55),32)

func _draw_bastion() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.62,Color(0.38,0.34,0.31,0.82),32)
	for y in [-300.0,0.0,300.0]:
		draw_line(Vector2(-radius*0.62,y),Vector2(radius*0.62,y),Color(0.29,0.27,0.24,0.45),10)

func _draw_obelisks() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.68,Color(0.30,0.22,0.29,0.88),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.80,radius*0.56,Color(0.61,0.18,0.36,0.55),9,32)
	for a in range(0,360,30):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		draw_line(d*radius*0.74,d*radius*0.59,Color(0.29,0.17,0.24),9)

func _draw_cathedral() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.70,Color(0.34,0.28,0.30,0.86),32)
	for r in [280.0,560.0,840.0]:
		DrawUtil.ellipse_line(self,Vector2.ZERO,r,r*0.70,Color(0.48,0.37,0.40,0.30),4,32)

func _draw_council() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.66,Color(0.40,0.35,0.31,0.84),32)
	for a in range(0,360,60):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		DrawUtil.ellipse(self,d*radius*0.63,48,18,Color(0.56,0.45,0.28,0.58))

func _draw_citadel() -> void:
	DrawUtil.ellipse(self,Vector2.ZERO,radius,radius*0.73,Color(0.24,0.18,0.24,0.94),32)
	DrawUtil.ellipse_line(self,Vector2.ZERO,radius*0.81,radius*0.59,Color(0.55,0.13,0.34,0.66),10,32)
	for a in range(0,360,24):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		DrawUtil.ellipse(self,d*radius*0.74,30,13,Color(0.22,0.20,0.22,0.78))
