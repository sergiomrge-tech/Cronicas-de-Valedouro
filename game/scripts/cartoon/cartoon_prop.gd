class_name ValedouroCartoonProp
extends Node2D

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")

var kind: String = "tree"
var variant: int = 0
var label: String = ""
var poi_id: String = ""
var base_scale: float = 1.0
var anim_t: float = 0.0

func setup(data: Dictionary) -> void:
	kind = String(data.get("kind", "tree"))
	variant = int(data.get("variant", 0))
	label = String(data.get("label", ""))
	poi_id = String(data.get("poi_id", ""))
	base_scale = float(data.get("scale", 1.0))
	position = data.get("pos", Vector2.ZERO)
	scale = Vector2.ONE * base_scale
	queue_redraw()

func _process(delta: float) -> void:
	anim_t += delta
	if kind in ["torch", "fountain", "market"]:
		queue_redraw()

func _draw() -> void:
	match kind:
		"tree": _draw_tree()
		"pine": _draw_pine()
		"rock": _draw_rock()
		"bush": _draw_bush()
		"house": _draw_house()
		"forge": _draw_forge()
		"tavern": _draw_tavern()
		"guild": _draw_guild()
		"alchemist": _draw_alchemist()
		"castle": _draw_castle()
		"fountain": _draw_fountain()
		"market": _draw_market()
		"bench": _draw_bench()
		"lamp": _draw_lamp()
		"well": _draw_well()
		"bridge": _draw_bridge()
		"fence": _draw_fence()
		"flowers": _draw_flowers()
		"sign": _draw_sign()
		"hay": _draw_hay()
		"chest": _draw_chest()
		"windmill": _draw_windmill()
		_: _draw_rock()

func _draw_tree() -> void:
	DrawUtil.shadow(self, Vector2(0, 13), 33, 0.26)
	DrawUtil.rect_outlined(self, Rect2(-7, -28, 14, 48), Color(0.38, 0.22, 0.11), DrawUtil.OUTLINE, 3)
	var leaves = Color(0.25, 0.58, 0.22) if variant % 3 == 0 else Color(0.32, 0.67, 0.24) if variant % 3 == 1 else Color(0.22, 0.52, 0.26)
	for e in [Vector2(-20,-42), Vector2(17,-47), Vector2(0,-68), Vector2(-4,-35)]:
		DrawUtil.circle_outlined(self, e, 25, leaves.lightened(0.04 if e.y < -50 else 0.0), DrawUtil.OUTLINE, 3)
	DrawUtil.ellipse(self, Vector2(-11,-71), 9, 5, Color(0.7,0.9,0.38,0.38))

func _draw_pine() -> void:
	DrawUtil.shadow(self, Vector2(0, 13), 30, 0.25)
	DrawUtil.rect_outlined(self, Rect2(-5,-23,10,42), Color(0.34,0.21,0.12), DrawUtil.OUTLINE, 2.5)
	for layer in range(3):
		var y = -35.0 - layer * 21.0
		var hw = 31.0 - layer * 5.0
		DrawUtil.poly_outlined(self, PackedVector2Array([Vector2(0,y-34),Vector2(-hw,y+17),Vector2(hw,y+17)]), Color(0.08+layer*0.02,0.38+layer*0.04,0.27), DrawUtil.OUTLINE, 3)

func _draw_rock() -> void:
	DrawUtil.shadow(self, Vector2(0, 8), 23, 0.22)
	var pts = PackedVector2Array([Vector2(-25,5),Vector2(-18,-17),Vector2(-3,-27),Vector2(20,-17),Vector2(27,4),Vector2(12,15),Vector2(-13,14)])
	DrawUtil.poly_outlined(self, pts, Color(0.55,0.57,0.58), DrawUtil.OUTLINE, 3)
	draw_colored_polygon(PackedVector2Array([Vector2(-13,-13),Vector2(-3,-22),Vector2(14,-15),Vector2(5,-6)]), Color(0.75,0.77,0.75,0.75))

func _draw_bush() -> void:
	DrawUtil.shadow(self, Vector2(0,8), 24, 0.18)
	for c in [Vector2(-18,-7),Vector2(0,-14),Vector2(19,-7),Vector2(4,2)]:
		DrawUtil.circle_outlined(self,c,18,Color(0.28,0.62,0.22),DrawUtil.OUTLINE,2.5)
	if variant % 2 == 0:
		for p in [Vector2(-9,-13),Vector2(7,-7),Vector2(13,-15)]: draw_circle(p,2.8,Color(0.96,0.25,0.35))

func _building_shadow(w: float) -> void:
	DrawUtil.ellipse(self, Vector2(0,18), w*0.46, 16, Color(0,0,0,0.23))

func _draw_house() -> void:
	_building_shadow(110)
	DrawUtil.rect_outlined(self, Rect2(-43,-50,86,68), Color(0.92,0.78,0.56), DrawUtil.OUTLINE,3)
	var roof = Color(0.82,0.25,0.16) if variant % 2 == 0 else Color(0.16,0.43,0.72)
	DrawUtil.poly_outlined(self, PackedVector2Array([Vector2(-54,-48),Vector2(0,-91),Vector2(54,-48)]), roof, DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self, Rect2(-10,-18,20,36), Color(0.37,0.20,0.11), DrawUtil.OUTLINE,2.5)
	for x in [-29.0,29.0]:
		DrawUtil.rect_outlined(self, Rect2(x-8,-35,16,18), Color(0.47,0.78,0.9), DrawUtil.OUTLINE,2)
	DrawUtil.rect_outlined(self, Rect2(27,-78,11,24), Color(0.55,0.34,0.18), DrawUtil.OUTLINE,2)

func _draw_forge() -> void:
	_building_shadow(128)
	DrawUtil.rect_outlined(self, Rect2(-52,-56,104,73),Color(0.72,0.57,0.39),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-63,-54),Vector2(-20,-93),Vector2(63,-54)]),Color(0.64,0.23,0.16),DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-48,-40,36,31),Color(0.24,0.19,0.17),DrawUtil.OUTLINE,2.5)
	DrawUtil.rect_outlined(self,Rect2(20,-79,14,51),Color(0.38,0.26,0.2),DrawUtil.OUTLINE,2.5)
	DrawUtil.flame(self,Vector2(27,-81),19,7,anim_t)
	# big anvil sign
	DrawUtil.rect_outlined(self,Rect2(41,-35,7,31),Color(0.34,0.22,0.13),DrawUtil.OUTLINE,2)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(30,-43),Vector2(51,-43),Vector2(47,-36),Vector2(34,-36)]),Color(0.25,0.28,0.31),DrawUtil.OUTLINE,2)

func _draw_tavern() -> void:
	_building_shadow(132)
	DrawUtil.rect_outlined(self,Rect2(-53,-58,106,76),Color(0.88,0.68,0.42),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-65,-55),Vector2(0,-96),Vector2(65,-55)]),Color(0.58,0.20,0.13),DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-9,-20,22,38),Color(0.30,0.16,0.08),DrawUtil.OUTLINE,2.5)
	DrawUtil.rect_outlined(self,Rect2(29,-35,39,19),Color(0.95,0.76,0.26),DrawUtil.OUTLINE,2.5)
	draw_circle(Vector2(48,-26),6,Color(0.45,0.2,0.08))

func _draw_guild() -> void:
	_building_shadow(150)
	DrawUtil.rect_outlined(self,Rect2(-60,-64,120,82),Color(0.76,0.68,0.54),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-70,-61),Vector2(-27,-102),Vector2(70,-61)]),Color(0.15,0.38,0.68),DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-13,-25,26,43),Color(0.34,0.19,0.1),DrawUtil.OUTLINE,2.5)
	# crossed swords badge
	DrawUtil.circle_outlined(self,Vector2(0,-51),15,Color(0.94,0.72,0.18),DrawUtil.OUTLINE,2.5)
	draw_line(Vector2(-7,-58),Vector2(7,-44),Color(0.95,0.96,0.97),3)
	draw_line(Vector2(7,-58),Vector2(-7,-44),Color(0.95,0.96,0.97),3)

func _draw_alchemist() -> void:
	_building_shadow(118)
	DrawUtil.rect_outlined(self,Rect2(-49,-57,98,75),Color(0.79,0.66,0.51),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-59,-54),Vector2(0,-92),Vector2(59,-54)]),Color(0.38,0.25,0.62),DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-9,-19,20,37),Color(0.30,0.17,0.12),DrawUtil.OUTLINE,2.5)
	DrawUtil.circle_outlined(self,Vector2(35,-38),13,Color(0.30,0.83,0.76),DrawUtil.OUTLINE,2.5)
	draw_line(Vector2(31,-49),Vector2(39,-49),DrawUtil.OUTLINE,5)

func _draw_castle() -> void:
	_building_shadow(260)
	# central keep
	DrawUtil.rect_outlined(self,Rect2(-85,-102,170,122),Color(0.73,0.72,0.68),DrawUtil.OUTLINE,4)
	# towers
	for x in [-104.0,104.0]:
		DrawUtil.rect_outlined(self,Rect2(x-34,-116,68,136),Color(0.68,0.68,0.66),DrawUtil.OUTLINE,4)
		DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(x-43,-114),Vector2(x,-166),Vector2(x+43,-114)]),Color(0.12,0.37,0.72),DrawUtil.OUTLINE,4)
		for cx in [x-22,x,x+22]:
			draw_rect(Rect2(cx-7,-123,14,12),Color(0.68,0.68,0.66))
	# keep roof
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-97,-101),Vector2(0,-158),Vector2(97,-101)]),Color(0.15,0.43,0.78),DrawUtil.OUTLINE,4)
	# gate
	DrawUtil.rect_outlined(self,Rect2(-25,-37,50,57),Color(0.31,0.18,0.10),DrawUtil.OUTLINE,3)
	DrawUtil.ellipse_outlined(self,Vector2(0,-36),25,22,Color(0.31,0.18,0.10),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-25,-36,50,56),Color(0.31,0.18,0.10))
	# banners
	for x in [-56.0,56.0]:
		DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(x-12,-87),Vector2(x+12,-87),Vector2(x+12,-48),Vector2(x,-38),Vector2(x-12,-48)]),Color(0.08,0.29,0.75),DrawUtil.OUTLINE,2)
		draw_circle(Vector2(x,-64),4,Color(0.96,0.75,0.18))

func _draw_fountain() -> void:
	DrawUtil.shadow(self,Vector2(0,8),43,0.18)
	DrawUtil.ellipse_outlined(self,Vector2.ZERO,45,20,Color(0.57,0.6,0.62),DrawUtil.OUTLINE,3)
	DrawUtil.ellipse(self,Vector2(0,-2),35,13,Color(0.22,0.66,0.9))
	DrawUtil.rect_outlined(self,Rect2(-7,-42,14,38),Color(0.67,0.69,0.68),DrawUtil.OUTLINE,2.5)
	DrawUtil.circle_outlined(self,Vector2(0,-43),10,Color(0.67,0.69,0.68),DrawUtil.OUTLINE,2.5)
	for side in [-1.0,1.0]:
		draw_arc(Vector2(side*10,-37),19,0.3 if side>0 else PI+0.3,1.3 if side>0 else TAU-0.3,12,Color(0.45,0.85,1.0,0.9),3,true)

func _draw_market() -> void:
	DrawUtil.shadow(self,Vector2(0,10),42,0.18)
	DrawUtil.rect_outlined(self,Rect2(-39,-23,78,34),Color(0.58,0.32,0.16),DrawUtil.OUTLINE,2.5)
	var awning = Color(0.85,0.18,0.16) if variant % 2 == 0 else Color(0.12,0.42,0.76)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-48,-25),Vector2(-40,-52),Vector2(40,-52),Vector2(48,-25)]),awning,DrawUtil.OUTLINE,3)
	for x in [-28.0,-9.0,10.0,29.0]:
		draw_rect(Rect2(x-4,-52,8,27),Color(1,0.84,0.47,0.85))

func _draw_bench() -> void:
	DrawUtil.shadow(self,Vector2(0,6),25,0.16)
	DrawUtil.rect_outlined(self,Rect2(-29,-10,58,9),Color(0.55,0.31,0.14),DrawUtil.OUTLINE,2)
	DrawUtil.rect_outlined(self,Rect2(-27,-25,54,9),Color(0.60,0.35,0.16),DrawUtil.OUTLINE,2)
	for x in [-22.0,22.0]: draw_line(Vector2(x,-17),Vector2(x,6),DrawUtil.OUTLINE,4)

func _draw_lamp() -> void:
	draw_line(Vector2(0,8),Vector2(0,-42),DrawUtil.OUTLINE,7)
	draw_line(Vector2(0,8),Vector2(0,-42),Color(0.33,0.25,0.18),3)
	DrawUtil.circle_outlined(self,Vector2(0,-48),10,Color(1.0,0.69,0.17),DrawUtil.OUTLINE,2)
	draw_circle(Vector2(0,-48),16,Color(1.0,0.75,0.22,0.13))

func _draw_well() -> void:
	DrawUtil.shadow(self,Vector2(0,8),31,0.18)
	DrawUtil.ellipse_outlined(self,Vector2(0,0),30,14,Color(0.56,0.57,0.56),DrawUtil.OUTLINE,3)
	DrawUtil.ellipse(self,Vector2(0,-3),22,8,Color(0.16,0.37,0.49))
	for x in [-23.0,23.0]: draw_line(Vector2(x,0),Vector2(x,-36),Color(0.37,0.23,0.12),6)
	draw_line(Vector2(-28,-36),Vector2(28,-36),Color(0.37,0.23,0.12),7)

func _draw_bridge() -> void:
	DrawUtil.rect_outlined(self,Rect2(-52,-20,104,40),Color(0.56,0.34,0.16),DrawUtil.OUTLINE,3)
	for x in range(-44,45,15): draw_line(Vector2(x,-17),Vector2(x,17),Color(0.35,0.22,0.11),2)

func _draw_fence() -> void:
	for x in [-28.0,0.0,28.0]:
		draw_line(Vector2(x,9),Vector2(x,-20),DrawUtil.OUTLINE,6)
		draw_line(Vector2(x,9),Vector2(x,-20),Color(0.48,0.29,0.14),3)
	for y in [-13.0,0.0]:
		draw_line(Vector2(-34,y),Vector2(34,y),DrawUtil.OUTLINE,7)
		draw_line(Vector2(-34,y),Vector2(34,y),Color(0.55,0.33,0.15),4)

func _draw_flowers() -> void:
	for i in range(5):
		var a = float(i)*1.9 + float(variant)
		var p = Vector2(cos(a)*18,sin(a)*9)
		draw_line(p+Vector2(0,5),p+Vector2(0,-4),Color(0.2,0.55,0.18),2)
		draw_circle(p+Vector2(0,-5),3.5,Color(1.0,0.85,0.22) if i%2==0 else Color(1.0,0.6,0.75))

func _draw_sign() -> void:
	draw_line(Vector2(0,12),Vector2(0,-28),DrawUtil.OUTLINE,7)
	draw_line(Vector2(0,12),Vector2(0,-28),Color(0.42,0.25,0.12),4)
	DrawUtil.rect_outlined(self,Rect2(-29,-37,58,20),Color(0.62,0.39,0.18),DrawUtil.OUTLINE,2.5)


func _draw_hay() -> void:
	DrawUtil.shadow(self,Vector2(0,7),25,0.15)
	DrawUtil.rect_outlined(self,Rect2(-26,-17,52,30),Color(0.88,0.68,0.20),DrawUtil.OUTLINE,2.5)
	for y in [-10.0,0.0,9.0]:
		draw_line(Vector2(-22,y),Vector2(22,y),Color(0.67,0.46,0.13,0.8),1.5)

func _draw_chest() -> void:
	DrawUtil.shadow(self,Vector2(0,7),25,0.20)
	DrawUtil.rect_outlined(self,Rect2(-26,-16,52,28),Color(0.46,0.25,0.11),DrawUtil.OUTLINE,3)
	DrawUtil.ellipse_outlined(self,Vector2(0,-16),26,14,Color(0.57,0.31,0.13),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-4,-7,8,12),Color(0.95,0.72,0.18))

func _draw_windmill() -> void:
	_building_shadow(120)
	DrawUtil.rect_outlined(self,Rect2(-35,-78,70,96),Color(0.86,0.76,0.58),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-45,-76),Vector2(0,-109),Vector2(45,-76)]),Color(0.64,0.24,0.16),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(16,-65),8,Color(0.77,0.66,0.45),DrawUtil.OUTLINE,2)
	var center: Vector2 = Vector2(42,-75)
	DrawUtil.circle_outlined(self,center,7,Color(0.48,0.28,0.12),DrawUtil.OUTLINE,2)
	for a in [0.0,PI*0.5,PI,PI*1.5]:
		var d: Vector2 = Vector2.RIGHT.rotated(a)
		draw_line(center+d*6,center+d*45,DrawUtil.OUTLINE,7)
		draw_line(center+d*7,center+d*43,Color(0.70,0.55,0.29),4)
