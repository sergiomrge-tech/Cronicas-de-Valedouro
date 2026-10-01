class_name ValedouroCartoonHero
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const CombatArt = preload("res://scripts/cartoon/cartoon_combat_art.gd")
const Projectile = preload("res://scripts/cartoon/cartoon_spell_projectile.gd")
const FX = preload("res://scripts/cartoon/cartoon_combat_fx.gd")
const SPELLS = ["ember","frost","arcane"]
const SPELL_NAMES = ["Brasa","Cristal","Arcana"]
const SPELL_COLORS = [Color("ff8d37"),Color("65e3ff"),Color("ce91ff")]
const VisualAssets = preload("res://scripts/cartoon/cartoon_visual_assets.gd")

var move_vector: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.DOWN
var anim_t: float = 0.0
var attack_t: float = 0.0
var cast_spell_index: int = 0
var cast_t: float = 0.0
var death_t: float = 0.0
var hurt_t: float = 0.0
var spell_cooldown: float = 0.0
var spell_index: int = 0
var spell_mode: bool = false
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

func equipped_damage(base_damage: int) -> int:
	var state = get_node_or_null("/root/CartoonPlayerState")
	var amount: int = state.attack_damage(base_damage) if state != null else base_damage
	return amount

func attack_damage(base_damage: int) -> int:
	var amount: int = equipped_damage(base_damage)
	return roundi(amount*1.25) if spell_mode else amount

func launch_magic(host, target: Node2D, base_damage: int, director = null):
	facing = (target.global_position-global_position).normalized()
	return Projectile.launch(host,self,target,base_damage,director)

func reduce_incoming_damage(raw_damage: int) -> int:
	var state = get_node_or_null("/root/CartoonPlayerState")
	return state.reduce_damage(raw_damage) if state != null else raw_damage

func set_motion(v: Vector2) -> void:
	move_vector = v
	if v.length() > 0.08:
		facing = v.normalized()
	queue_redraw()

func combat_range(base_range: float) -> float:
	return maxf(base_range,220.0) if spell_mode else base_range

func cycle_spell() -> void:
	spell_index = (spell_index+1)%SPELLS.size()
	queue_redraw()

func cast_spell(host) -> bool:
	if spell_cooldown>0 or death_t>0 or get_tree().paused: return false
	var layout = host.get_node_or_null("HUD/GameLayout")
	if layout != null and layout.is_blocked(): return false
	if host.get("interiors") != null and host.interiors.active: return false
	spell_cooldown = 3.0
	cast_t = 0.65
	cast_spell_index = spell_index
	spell_mode = true
	host._attack()
	spell_mode = false
	return true

func trigger_fall() -> void:
	death_t = 0.7
	queue_redraw()

func trigger_hurt() -> void:
	hurt_t = 0.22
	FX.spawn(get_parent(),position+Vector2(0,-30),"hurt",facing,Color("ff7075"))

func trigger_attack() -> void:
	if spell_mode: cast_t = 0.65
	else: attack_t = 0.28
	var aim: Vector2 = facing
	var host = get_parent()
	while host.get_parent() != null and not host.has_method("_nearest_monster"):
		host = host.get_parent()
	if host.has_method("_nearest_monster"):
		var target = host._nearest_monster(combat_range(112.0))
		if target != null: aim = (target.position-position).normalized()
	if spell_mode: facing = aim
	if not spell_mode: FX.spawn(get_parent(),position+Vector2(0,-25),"slash",aim,Color("ffe3a0"))
	queue_redraw()

func _process(delta: float) -> void:
	anim_t += delta
	death_t = maxf(0,death_t-delta)
	cast_t = maxf(0,cast_t-delta)
	hurt_t = maxf(0,hurt_t-delta)
	spell_cooldown = maxf(0,spell_cooldown-delta)
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
	var animation: String = "idle"
	var frame: int = int(anim_t*4)%4
	if moving:
		animation = "walk"
		frame = int(anim_t*12)%8
	if attack_t>0:
		animation = "attack"
		frame = mini(5,int((1-attack_t/0.28)*6))
	if cast_t>0:
		animation = "cast"
		frame = mini(7,int((1-cast_t/0.65)*8))
	if hurt_t>0:
		animation = "hurt"
		frame = mini(3,int((1-hurt_t/0.22)*4))
	if death_t>0:
		animation = "death"
		frame = mini(7,int((1-death_t/0.7)*8))
	CombatArt.hero_frame(self,direction,animation,frame,Rect2(-40,-94,80,100),Color(1,0.75,0.8) if hurt_t>0 else Color.WHITE)
	if cast_t>0:
		var glow: Color = SPELL_COLORS[cast_spell_index]
		for i in range(4,0,-1): draw_circle(Vector2(23,-43),float(i)*4,Color(glow,0.09))
		draw_arc(Vector2(23,-43),10,anim_t*5,anim_t*5+PI*1.6,32,glow,2,true)
	if death_t>0:
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	# Equipment still has an in-world color cue; the sword keeps its attack motion.
	var armor_colors: Array[Color] = [Color("d1b369"),Color("91b77a"),Color("dca569"),Color("89b999"),Color("b6deec"),Color("75c8d7"),Color("bd82af"),Color("a390d4")]
	draw_circle(Vector2(-9,-34),2.4,armor_colors[clampi(armor_tier,0,7)])
	var sword_hand: Vector2 = Vector2(21,-27)
	if facing.x < -0.5: sword_hand.x = -21.0
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
	var edge: Vector2 = dir.orthogonal()*2.5
	var outline: PackedVector2Array = PackedVector2Array([blade_a-edge,blade_b-dir*5-edge*0.65,blade_b+dir*3,blade_b-dir*5+edge*0.65,blade_a+edge,blade_a-edge])
	draw_colored_polygon(outline,blade_color)
	draw_polyline(outline,DrawUtil.OUTLINE,1.2,true)
	draw_line(blade_a,blade_b,Color("f2fbff"),0.9,true)
	if weapon_tier >= 4:
		draw_line(blade_a,blade_b,Color(blade_color.r,blade_color.g,blade_color.b,0.32),7.0)
	draw_line(sword_hand-dir.orthogonal()*7,sword_hand+dir.orthogonal()*7,Color("f5cc69"),3.5,true)
	draw_line(sword_hand,sword_hand-dir*6,Color("987044"),4,true)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
