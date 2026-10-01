class_name ValedouroCartoonHero
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const VisualAssets = preload("res://scripts/cartoon/cartoon_visual_assets.gd")

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
	DrawUtil.shadow(self, Vector2(0, 9), 19, 0.30)
	draw_set_transform(Vector2(0,-bob),0,Vector2.ONE)
	var direction: String = "front"
	if absf(facing.x) > absf(facing.y):
		direction = "left" if facing.x < 0.0 else "right"
	elif facing.y < 0.0:
		direction = "back"
	var sprite_name: String = "hero_"+direction
	if moving: sprite_name += "_walk_%d" % (0 if sin(anim_t*9.0) < 0.0 else 1)
	draw_texture_rect(VisualAssets.texture(sprite_name),Rect2(-29,-68,58,75),false)
	# Equipment still has an in-world color cue; the sword keeps its attack motion.
	var armor_colors: Array[Color] = [Color("d1b369"),Color("91b77a"),Color("dca569"),Color("89b999"),Color("b6deec"),Color("75c8d7"),Color("bd82af"),Color("a390d4")]
	draw_circle(Vector2(-9,-34),2.4,armor_colors[clampi(armor_tier,0,7)])
	var sword_hand: Vector2 = Vector2(18,-17)
	if facing.x < -0.5: sword_hand.x = -18.0
	if direction == "back": sword_hand.y = -25.0
	if attack_t > 0.0:
		var k: float = 1.0 - attack_t / 0.28
		sword_hand += Vector2(10,-10).rotated(k*PI*1.2)
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
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
