class_name ValedouroCartoonHero
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var move_vector: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.DOWN
var anim_t: float = 0.0
var attack_t: float = 0.0
var weapon_tier: int = 0
var armor_tier: int = 0

func _ready() -> void:
	apply_equipment_from_state()

func apply_equipment_from_state() -> void:
	var state = get_node_or_null("/root/CartoonPlayerState")
	if state == null:
		return
	weapon_tier = int(state.equipped_weapon.get("tier",0))
	armor_tier = int(state.equipped_armor.get("tier",0))
	queue_redraw()

func attack_damage(base_damage: int) -> int:
	var state = get_node_or_null("/root/CartoonPlayerState")
	return state.attack_damage(base_damage) if state != null else base_damage

func reduce_incoming_damage(raw_damage: int) -> int:
	var state = get_node_or_null("/root/CartoonPlayerState")
	return state.reduce_damage(raw_damage) if state != null else raw_damage

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
	var moving = move_vector.length() > 0.08
	var bob = absf(sin(anim_t * 9.0)) * 3.0 if moving else sin(anim_t * 2.0) * 1.0
	var step = sin(anim_t * 9.0) * 3.0 if moving else 0.0
	DrawUtil.shadow(self, Vector2(0, 9), 19, 0.30)
	draw_set_transform(Vector2(0,-bob),0,Vector2.ONE)
	# legs
	DrawUtil.capsule_outlined(self,Vector2(-7,-7),Vector2(-8-step,-1),7,Color(0.25,0.22,0.22),DrawUtil.OUTLINE,2.5)
	DrawUtil.capsule_outlined(self,Vector2(7,-7),Vector2(8+step,-1),7,Color(0.25,0.22,0.22),DrawUtil.OUTLINE,2.5)
	# body / blue tunic
	var armor_colors: Array[Color] = [
		Color(0.12,0.38,0.72),Color(0.19,0.52,0.29),Color(0.62,0.42,0.17),Color(0.31,0.45,0.35),
		Color(0.48,0.68,0.82),Color(0.17,0.55,0.68),Color(0.39,0.27,0.45),Color(0.29,0.20,0.38)
	]
	var armor_color: Color = armor_colors[clampi(armor_tier,0,armor_colors.size()-1)]
	DrawUtil.ellipse_outlined(self,Vector2(0,-24),17,19,armor_color,DrawUtil.OUTLINE,3)
	DrawUtil.rect_outlined(self,Rect2(-15,-25,30,11),Color(0.83,0.67,0.24),DrawUtil.OUTLINE,2)
	# cape
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-14,-31),Vector2(14,-31),Vector2(11,-7),Vector2(0,-1),Vector2(-11,-7)]),Color(0.34,0.12,0.46),DrawUtil.OUTLINE,2.5)
	# arms
	DrawUtil.capsule_outlined(self,Vector2(-15,-29),Vector2(-20,-15),6,Color(0.85,0.63,0.45),DrawUtil.OUTLINE,2)
	var sword_hand = Vector2(18,-16)
	if attack_t > 0.0:
		var k = 1.0 - attack_t / 0.28
		sword_hand += Vector2(10,-10).rotated(k*PI*1.2)
	DrawUtil.capsule_outlined(self,Vector2(15,-29),sword_hand,6,Color(0.85,0.63,0.45),DrawUtil.OUTLINE,2)
	# sword
	var dir = Vector2(0,-1) if attack_t <= 0.0 else (sword_hand-Vector2(15,-29)).normalized().rotated(-0.7)
	var blade_a = sword_hand
	var blade_length: float = 27.0+float(weapon_tier)*1.4
	var blade_b = sword_hand + dir*blade_length
	var blade_colors: Array[Color] = [
		Color(0.88,0.91,0.94),Color(0.55,0.87,0.56),Color(0.95,0.66,0.28),Color(0.55,0.83,0.65),
		Color(0.72,0.91,1.0),Color(0.40,0.88,0.96),Color(0.84,0.34,0.62),Color(0.78,0.55,1.0)
	]
	var blade_color: Color = blade_colors[clampi(weapon_tier,0,blade_colors.size()-1)]
	DrawUtil.capsule_outlined(self,blade_a,blade_b,4,blade_color,DrawUtil.OUTLINE,1.8)
	if weapon_tier >= 4:
		draw_line(blade_a,blade_b,Color(blade_color.r,blade_color.g,blade_color.b,0.32),7.0)
	draw_line(sword_hand+Vector2(-6,0),sword_hand+Vector2(6,0),Color(0.92,0.72,0.18),5)
	# head + hair
	DrawUtil.circle_outlined(self,Vector2(0,-47),14,Color(0.89,0.67,0.48),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-13,-52),Vector2(-9,-66),Vector2(-3,-59),Vector2(2,-69),Vector2(6,-58),Vector2(13,-63),Vector2(13,-48)]),Color(0.32,0.17,0.10),DrawUtil.OUTLINE,2.5)
	# face
	draw_circle(Vector2(-5,-46),2.1,Color(0.12,0.08,0.08))
	draw_circle(Vector2(5,-46),2.1,Color(0.12,0.08,0.08))
	draw_line(Vector2(-3,-39),Vector2(4,-39),Color(0.35,0.15,0.12),1.8)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
