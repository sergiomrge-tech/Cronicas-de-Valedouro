class_name ValedouroCartoonMonster
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var kind: String = "wolf"
var monster_name: String = "Lobo do Vale"
var hp: int = 34
var max_hp: int = 34
var move_speed: float = 86.0
var contact_damage: int = 7
var attack_cooldown: float = 0.0
var hit_flash: float = 0.0
var story_tag: String = ""
var boss_id: String = ""
var anim_t: float = 0.0

func setup(data: Dictionary) -> void:
	kind = String(data.get("kind","wolf"))
	monster_name = String(data.get("name","Lobo do Vale"))
	hp = int(data.get("hp",34))
	max_hp = hp
	move_speed = float(data.get("speed",86.0))
	contact_damage = int(data.get("damage",7))
	story_tag = String(data.get("story_tag",""))
	boss_id = String(data.get("boss_id",""))
	position = data.get("pos",Vector2.ZERO)
	scale = Vector2.ONE * float(data.get("scale",1.0))
	queue_redraw()

func _process(delta: float) -> void:
	anim_t += delta
	attack_cooldown = maxf(0.0,attack_cooldown-delta)
	hit_flash = maxf(0.0,hit_flash-delta)
	queue_redraw()

func take_damage(amount: int) -> bool:
	hp = maxi(0,hp-amount)
	hit_flash = 0.12
	queue_redraw()
	return hp <= 0

func can_hit() -> bool:
	return attack_cooldown <= 0.0

func mark_hit() -> void:
	attack_cooldown = 0.9

func _draw() -> void:
	var bob: float = absf(sin(anim_t*7.0))*2.0
	DrawUtil.shadow(self,Vector2(0,10),24,0.26)
	draw_set_transform(Vector2(0,-bob),0.0,Vector2.ONE)
	match kind:
		"goblin":
			_draw_goblin()
		"slime":
			_draw_slime()
		"guardian":
			_draw_guardian()
		"root_beast":
			_draw_root_beast()
		_:
			_draw_wolf()
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
	if hp < max_hp:
		DrawUtil.bar(self,Vector2(-25,-62),Vector2(50,6),float(hp)/float(max_hp),Color(0.82,0.18,0.18))
	if hit_flash > 0.0:
		DrawUtil.ellipse(self,Vector2.ZERO,30,36,Color(1,1,1,0.25))

func _draw_wolf() -> void:
	var fur: Color = Color(0.33,0.35,0.40)
	DrawUtil.ellipse_outlined(self,Vector2(0,-18),25,18,fur,DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(18,-35),14,fur.lightened(0.05),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(9,-46),Vector2(13,-61),Vector2(20,-47)]),fur,DrawUtil.OUTLINE,2.5)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(22,-47),Vector2(29,-60),Vector2(31,-43)]),fur,DrawUtil.OUTLINE,2.5)
	draw_circle(Vector2(22,-36),2.2,Color(1.0,0.78,0.18))
	draw_circle(Vector2(31,-30),2.5,Color(0.10,0.07,0.07))
	for x in [-14.0,4.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-10),Vector2(x+2,5),6,fur.darkened(0.08),DrawUtil.OUTLINE,2)
	draw_line(Vector2(-23,-24),Vector2(-38,-34),DrawUtil.OUTLINE,7)
	draw_line(Vector2(-23,-24),Vector2(-38,-34),fur,4)

func _draw_goblin() -> void:
	var skin: Color = Color(0.36,0.68,0.24)
	DrawUtil.ellipse_outlined(self,Vector2(0,-21),18,22,Color(0.44,0.24,0.14),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(0,-45),15,skin,DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-11,-49),Vector2(-28,-54),Vector2(-12,-40)]),skin,DrawUtil.OUTLINE,2.5)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(11,-49),Vector2(28,-54),Vector2(12,-40)]),skin,DrawUtil.OUTLINE,2.5)
	draw_circle(Vector2(-5,-46),2,Color(0.08,0.06,0.05))
	draw_circle(Vector2(5,-46),2,Color(0.08,0.06,0.05))
	DrawUtil.capsule_outlined(self,Vector2(15,-22),Vector2(27,-12),5,skin,DrawUtil.OUTLINE,2)
	draw_line(Vector2(26,-13),Vector2(36,-36),DrawUtil.OUTLINE,5)
	draw_line(Vector2(26,-13),Vector2(36,-36),Color(0.45,0.28,0.12),2.5)

func _draw_slime() -> void:
	var col: Color = Color(0.28,0.72,0.42,0.92)
	var pts: PackedVector2Array = PackedVector2Array([Vector2(-27,2),Vector2(-24,-19),Vector2(-14,-34),Vector2(0,-42),Vector2(16,-33),Vector2(25,-18),Vector2(28,2)])
	DrawUtil.poly_outlined(self,pts,col,DrawUtil.OUTLINE,3)
	DrawUtil.ellipse(self,Vector2(0,2),28,9,col.darkened(0.06))
	draw_circle(Vector2(-8,-20),3,Color(0.05,0.08,0.05))
	draw_circle(Vector2(8,-20),3,Color(0.05,0.08,0.05))
	DrawUtil.ellipse(self,Vector2(-10,-31),7,4,Color(0.85,1.0,0.88,0.35))

func _draw_guardian() -> void:
	var stone: Color = Color(0.47,0.50,0.52)
	DrawUtil.ellipse_outlined(self,Vector2(0,-18),30,25,stone,DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-23,-58,46,40),stone.lightened(0.04),DrawUtil.OUTLINE,4)
	for x in [-25.0,25.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-38),Vector2(x*1.25,-10),10,stone.darkened(0.05),DrawUtil.OUTLINE,3)
	for x in [-12.0,12.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-3),Vector2(x,14),11,stone.darkened(0.08),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(0,-39),8,Color(0.28,0.76,0.96),DrawUtil.OUTLINE,2)
	draw_circle(Vector2(0,-39),3,Color(0.85,0.98,1.0))


func _draw_root_beast() -> void:
	var bark: Color = Color(0.33,0.24,0.13)
	var moss: Color = Color(0.24,0.52,0.22)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),34,27,bark,DrawUtil.OUTLINE,4)
	DrawUtil.circle_outlined(self,Vector2(0,-58),24,bark.lightened(0.04),DrawUtil.OUTLINE,4)
	for x in [-30.0,30.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-35),Vector2(x*1.28,1),9,bark.darkened(0.06),DrawUtil.OUTLINE,3)
	for x in [-14.0,14.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,-2),Vector2(x*1.22,19),11,bark.darkened(0.08),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-15,-72),Vector2(-27,-96),Vector2(-8,-82)]),bark,DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(15,-72),Vector2(27,-96),Vector2(8,-82)]),bark,DrawUtil.OUTLINE,3)
	for p in [Vector2(-18,-48),Vector2(18,-48),Vector2(0,-77),Vector2(-27,-16),Vector2(28,-17)]:
		DrawUtil.circle_outlined(self,p,10,moss,DrawUtil.OUTLINE,2)
	draw_circle(Vector2(-8,-59),3,Color(0.52,0.94,0.54))
	draw_circle(Vector2(8,-59),3,Color(0.52,0.94,0.54))
	DrawUtil.circle_outlined(self,Vector2(0,-34),8,Color(0.36,0.76,0.31),DrawUtil.OUTLINE,2)
