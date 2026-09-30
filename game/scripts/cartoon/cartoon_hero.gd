class_name ValedouroCartoonHero
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var move_vector: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.DOWN
var anim_t: float = 0.0
var attack_t: float = 0.0

func set_motion(v: Vector2) -> void:
	move_vector = v
	if v.length() > 0.08:
		facing = v.normalized()
	queue_redraw()

func trigger_attack() -> void:
	attack_t = 0.28
	queue_redraw()

func _process(delta: float) -> void:
	anim_t += delta
	attack_t = maxf(0.0, attack_t - delta)
	queue_redraw()

func _draw() -> void:
	var moving := move_vector.length() > 0.08
	var bob := absf(sin(anim_t * 9.0)) * 3.0 if moving else sin(anim_t * 2.0) * 1.0
	var step := sin(anim_t * 9.0) * 3.0 if moving else 0.0
	DrawUtil.shadow(self, Vector2(0, 9), 19, 0.30)
	draw_set_transform(Vector2(0,-bob),0,Vector2.ONE)
	# legs
	DrawUtil.capsule_outlined(self,Vector2(-7,-7),Vector2(-8-step,-1),7,Color(0.25,0.22,0.22),DrawUtil.OUTLINE,2.5)
	DrawUtil.capsule_outlined(self,Vector2(7,-7),Vector2(8+step,-1),7,Color(0.25,0.22,0.22),DrawUtil.OUTLINE,2.5)
	# body / blue tunic
	DrawUtil.ellipse_outlined(self,Vector2(0,-24),17,19,Color(0.12,0.38,0.72),DrawUtil.OUTLINE,3)
	DrawUtil.rect_outlined(self,Rect2(-15,-25,30,11),Color(0.83,0.67,0.24),DrawUtil.OUTLINE,2)
	# cape
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-14,-31),Vector2(14,-31),Vector2(11,-7),Vector2(0,-1),Vector2(-11,-7)]),Color(0.34,0.12,0.46),DrawUtil.OUTLINE,2.5)
	# arms
	DrawUtil.capsule_outlined(self,Vector2(-15,-29),Vector2(-20,-15),6,Color(0.85,0.63,0.45),DrawUtil.OUTLINE,2)
	var sword_hand := Vector2(18,-16)
	if attack_t > 0.0:
		var k := 1.0 - attack_t / 0.28
		sword_hand += Vector2(10,-10).rotated(k*PI*1.2)
	DrawUtil.capsule_outlined(self,Vector2(15,-29),sword_hand,6,Color(0.85,0.63,0.45),DrawUtil.OUTLINE,2)
	# sword
	var dir := Vector2(0,-1) if attack_t <= 0.0 else (sword_hand-Vector2(15,-29)).normalized().rotated(-0.7)
	var blade_a := sword_hand
	var blade_b := sword_hand + dir*27
	DrawUtil.capsule_outlined(self,blade_a,blade_b,4,Color(0.88,0.91,0.94),DrawUtil.OUTLINE,1.8)
	draw_line(sword_hand+Vector2(-6,0),sword_hand+Vector2(6,0),Color(0.92,0.72,0.18),5)
	# head + hair
	DrawUtil.circle_outlined(self,Vector2(0,-47),14,Color(0.89,0.67,0.48),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-13,-52),Vector2(-9,-66),Vector2(-3,-59),Vector2(2,-69),Vector2(6,-58),Vector2(13,-63),Vector2(13,-48)]),Color(0.32,0.17,0.10),DrawUtil.OUTLINE,2.5)
	# face
	draw_circle(Vector2(-5,-46),2.1,Color(0.12,0.08,0.08))
	draw_circle(Vector2(5,-46),2.1,Color(0.12,0.08,0.08))
	draw_line(Vector2(-3,-39),Vector2(4,-39),Color(0.35,0.15,0.12),1.8)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
