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
	poi_id = String(data.get("poi_id",data.get("id","")))
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
		"ruin": _draw_ruin()
		"shrine": _draw_shrine()
		"campfire": _draw_campfire()
		"gate": _draw_gate()
		"arena": _draw_arena()
		"mine": _draw_mine()
		"boss_gate": _draw_boss_gate()
		"archive": _draw_archive()
		"stone_bridge": _draw_stone_bridge()
		"ranger_lodge": _draw_ranger_lodge()
		"root_shrine": _draw_root_shrine()
		"memory_tree": _draw_memory_tree()
		"hollow_root_arena": _draw_hollow_root_arena()
		"cartographer_shrine": _draw_cartographer_shrine()
		"amber_caravan": _draw_amber_caravan()
		"amber_post": _draw_amber_post()
		"edravar_city": _draw_edravar_city()
		"resistance_cistern": _draw_resistance_cistern()
		"ash_observatory": _draw_ash_observatory()
		"ash_citadel": _draw_ash_citadel()
		"stilt_village": _draw_stilt_village()
		"drowned_bell": _draw_drowned_bell()
		"flooded_monastery": _draw_flooded_monastery()
		"reed_sanctum": _draw_reed_sanctum()
		"reed_throne": _draw_reed_throne()
		"echo_sluice": _draw_echo_sluice()
		"frost_rest": _draw_frost_rest()
		"frozen_station": _draw_frozen_station()
		"frozen_command": _draw_frozen_command()
		"frozen_archive": _draw_frozen_archive()
		"black_frost_citadel": _draw_black_frost_citadel()
		"return_gate": _draw_return_gate()
		"mist_port": _draw_mist_port()
		"twin_lighthouse": _draw_twin_lighthouse()
		"sunken_temple": _draw_sunken_temple()
		"lost_shipyard": _draw_lost_shipyard()
		"tidal_observatory": _draw_tidal_observatory()
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


func _draw_ruin() -> void:
	DrawUtil.shadow(self,Vector2(0,10),42,0.20)
	DrawUtil.rect_outlined(self,Rect2(-42,-34,18,52),Color(0.55,0.55,0.52),DrawUtil.OUTLINE,3)
	DrawUtil.rect_outlined(self,Rect2(18,-54,20,72),Color(0.58,0.58,0.55),DrawUtil.OUTLINE,3)
	draw_line(Vector2(-34,-34),Vector2(28,-53),Color(0.43,0.43,0.40),8)
	draw_line(Vector2(-31,-30),Vector2(25,-49),Color(0.70,0.70,0.64),3)
	for p in [Vector2(-48,10),Vector2(-10,15),Vector2(38,12)]:
		DrawUtil.ellipse(self,p,12,6,Color(0.44,0.46,0.43))

func _draw_shrine() -> void:
	DrawUtil.shadow(self,Vector2(0,8),30,0.18)
	DrawUtil.rect_outlined(self,Rect2(-20,-46,40,56),Color(0.66,0.65,0.60),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-28,-44),Vector2(0,-70),Vector2(28,-44)]),Color(0.18,0.42,0.72),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(0,-26),9,Color(0.94,0.76,0.20),DrawUtil.OUTLINE,2)
	draw_line(Vector2(0,-21),Vector2(0,-5),Color(0.92,0.74,0.20),3)

func _draw_campfire() -> void:
	DrawUtil.shadow(self,Vector2(0,7),24,0.16)
	for a in [0.5,-0.5]:
		draw_line(Vector2(-18,a*9),Vector2(18,-a*9),DrawUtil.OUTLINE,7)
		draw_line(Vector2(-17,a*9),Vector2(17,-a*9),Color(0.47,0.28,0.12),4)
	DrawUtil.flame(self,Vector2(0,-5),27,10,anim_t)
	for p in [Vector2(-29,10),Vector2(28,11),Vector2(0,18)]:
		DrawUtil.ellipse(self,p,9,5,Color(0.48,0.49,0.47))


func _draw_gate() -> void:
	_building_shadow(170)
	for x in [-62.0,62.0]:
		DrawUtil.rect_outlined(self,Rect2(x-22,-72,44,90),Color(0.65,0.64,0.60),DrawUtil.OUTLINE,3)
		draw_rect(Rect2(x-28,-82,16,12),Color(0.65,0.64,0.60))
		draw_rect(Rect2(x+12,-82,16,12),Color(0.65,0.64,0.60))
	DrawUtil.rect_outlined(self,Rect2(-62,-61,124,22),Color(0.61,0.60,0.56),DrawUtil.OUTLINE,3)
	DrawUtil.ellipse_outlined(self,Vector2(0,-16),34,30,Color(0.29,0.17,0.09),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-34,-16,68,34),Color(0.29,0.17,0.09))
	for x in [-14.0,14.0]:
		DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(x-9,-66),Vector2(x+9,-66),Vector2(x+9,-39),Vector2(x,-31),Vector2(x-9,-39)]),Color(0.08,0.30,0.74),DrawUtil.OUTLINE,2)

func _draw_arena() -> void:
	DrawUtil.shadow(self,Vector2(0,8),56,0.16)
	DrawUtil.ellipse_outlined(self,Vector2.ZERO,58,35,Color(0.58,0.62,0.42),DrawUtil.OUTLINE,3)
	DrawUtil.ellipse_line(self,Vector2.ZERO,43,25,Color(0.33,0.28,0.20,0.55),3,24)
	for p in [Vector2(-44,-8),Vector2(42,-10),Vector2(-20,22),Vector2(20,23)]:
		DrawUtil.ellipse(self,p,8,4,Color(0.44,0.45,0.43))

func _draw_mine() -> void:
	DrawUtil.shadow(self,Vector2(0,10),60,0.22)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-58,15),Vector2(-48,-38),Vector2(-22,-64),Vector2(15,-70),Vector2(50,-41),Vector2(60,14)]),Color(0.39,0.41,0.40),DrawUtil.OUTLINE,4)
	DrawUtil.ellipse_outlined(self,Vector2(0,-11),30,34,Color(0.13,0.12,0.12),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-30,-11,60,28),Color(0.13,0.12,0.12))
	for x in [-38.0,38.0]:
		draw_line(Vector2(x,8),Vector2(x,-42),Color(0.48,0.30,0.14),8)
	draw_line(Vector2(-42,-42),Vector2(42,-42),Color(0.48,0.30,0.14),9)
	for p in [Vector2(-47,-29),Vector2(46,-30)]:
		DrawUtil.flame(self,p,15,6,anim_t)

func _draw_boss_gate() -> void:
	DrawUtil.shadow(self,Vector2(0,8),44,0.18)
	DrawUtil.rect_outlined(self,Rect2(-42,-55,84,67),Color(0.40,0.41,0.42),DrawUtil.OUTLINE,4)
	DrawUtil.ellipse_outlined(self,Vector2(0,-52),42,28,Color(0.40,0.41,0.42),DrawUtil.OUTLINE,4)
	draw_rect(Rect2(-42,-52,84,64),Color(0.40,0.41,0.42))
	DrawUtil.ellipse_outlined(self,Vector2(0,-19),24,29,Color(0.11,0.10,0.14),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-24,-19,48,31),Color(0.11,0.10,0.14))
	DrawUtil.circle_outlined(self,Vector2(0,-44),9,Color(0.33,0.76,0.96),DrawUtil.OUTLINE,2)

func _draw_archive() -> void:
	_building_shadow(150)
	DrawUtil.rect_outlined(self,Rect2(-62,-64,124,82),Color(0.75,0.72,0.61),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-72,-61),Vector2(0,-105),Vector2(72,-61)]),Color(0.18,0.36,0.68),DrawUtil.OUTLINE,4)
	for x in [-34.0,0.0,34.0]:
		DrawUtil.rect_outlined(self,Rect2(x-7,-48,14,42),Color(0.55,0.52,0.44),DrawUtil.OUTLINE,2)
	DrawUtil.rect_outlined(self,Rect2(-14,-21,28,39),Color(0.31,0.19,0.10),DrawUtil.OUTLINE,2.5)
	DrawUtil.circle_outlined(self,Vector2(0,-68),11,Color(0.92,0.72,0.19),DrawUtil.OUTLINE,2.5)
	for a in [0.0,TAU/3.0,2.0*TAU/3.0]:
		var d: Vector2 = Vector2.RIGHT.rotated(a)
		draw_line(Vector2(0,-68)+d*5,Vector2(0,-68)+d*17,Color(0.92,0.72,0.19),2.5)


func _draw_stone_bridge() -> void:
	DrawUtil.shadow(self,Vector2(0,12),78,0.18)
	DrawUtil.rect_outlined(self,Rect2(-82,-28,164,56),Color(0.62,0.63,0.59),DrawUtil.OUTLINE,4)
	for x in range(-68,69,34):
		DrawUtil.rect_outlined(self,Rect2(x,-25,28,50),Color(0.69,0.69,0.64),DrawUtil.OUTLINE,2)
	for x in [-78.0,78.0]:
		DrawUtil.rect_outlined(self,Rect2(x-8,-42,16,84),Color(0.52,0.54,0.51),DrawUtil.OUTLINE,3)
	for p in [Vector2(-58,-38),Vector2(58,-38)]:
		DrawUtil.poly_outlined(self,PackedVector2Array([p+Vector2(-10,0),p+Vector2(10,0),p+Vector2(8,24),p+Vector2(0,31),p+Vector2(-8,24)]),Color(0.10,0.40,0.22),DrawUtil.OUTLINE,2)

func _draw_ranger_lodge() -> void:
	_building_shadow(155)
	DrawUtil.rect_outlined(self,Rect2(-68,-62,136,82),Color(0.57,0.37,0.18),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-82,-60),Vector2(0,-108),Vector2(82,-60)]),Color(0.17,0.38,0.20),DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-16,-24,32,44),Color(0.27,0.16,0.08),DrawUtil.OUTLINE,3)
	for x in [-42.0,42.0]:
		DrawUtil.rect_outlined(self,Rect2(x-10,-43,20,24),Color(0.48,0.71,0.82),DrawUtil.OUTLINE,2)
	DrawUtil.circle_outlined(self,Vector2(0,-72),11,Color(0.76,0.86,0.33),DrawUtil.OUTLINE,2)
	draw_line(Vector2(-40,15),Vector2(-62,35),Color(0.35,0.22,0.11),6)
	draw_line(Vector2(40,15),Vector2(62,35),Color(0.35,0.22,0.11),6)

func _draw_root_shrine() -> void:
	DrawUtil.shadow(self,Vector2(0,10),38,0.16)
	for a in [-1.0,0.0,1.0]:
		var x: float = a*24.0
		DrawUtil.capsule_outlined(self,Vector2(x,-6),Vector2(x*1.2,-54),7,Color(0.39,0.27,0.13),DrawUtil.OUTLINE,2)
	DrawUtil.circle_outlined(self,Vector2(0,-62),15,Color(0.32,0.68,0.28),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(0,-62),6,Color(0.77,0.96,0.49),DrawUtil.OUTLINE,2)
	for a in range(0,360,60):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		draw_line(Vector2.ZERO+d*18,Vector2.ZERO+d*31,Color(0.47,0.35,0.16),4)

func _draw_memory_tree() -> void:
	DrawUtil.shadow(self,Vector2(0,18),105,0.22)
	DrawUtil.rect_outlined(self,Rect2(-18,-112,36,126),Color(0.34,0.23,0.12),DrawUtil.OUTLINE,5)
	for branch in [
		PackedVector2Array([Vector2(0,-92),Vector2(-56,-132),Vector2(-94,-126)]),
		PackedVector2Array([Vector2(0,-80),Vector2(56,-122),Vector2(94,-116)]),
		PackedVector2Array([Vector2(-4,-62),Vector2(-62,-78),Vector2(-88,-58)]),
		PackedVector2Array([Vector2(6,-58),Vector2(64,-78),Vector2(92,-50)])
	]:
		draw_polyline(branch,DrawUtil.OUTLINE,14,true)
		draw_polyline(branch,Color(0.34,0.23,0.12),8,true)
	var leaf: Color = Color(0.22,0.58,0.25)
	for p in [Vector2(-74,-136),Vector2(-35,-151),Vector2(10,-149),Vector2(54,-140),Vector2(83,-113),Vector2(-88,-101),Vector2(-48,-102),Vector2(44,-104)]:
		DrawUtil.circle_outlined(self,p,31,leaf.lightened(0.04 if p.y < -130 else 0.0),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(0,-100),12,Color(0.35,0.88,0.92),DrawUtil.OUTLINE,2)
	draw_circle(Vector2(0,-100),5,Color(0.86,1.0,1.0))

func _draw_hollow_root_arena() -> void:
	DrawUtil.shadow(self,Vector2(0,8),74,0.18)
	DrawUtil.ellipse_outlined(self,Vector2.ZERO,82,52,Color(0.31,0.43,0.25),DrawUtil.OUTLINE,4)
	DrawUtil.ellipse_line(self,Vector2.ZERO,64,38,Color(0.20,0.13,0.10,0.65),4,32)
	for a in range(0,360,45):
		var d: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(float(a)))
		var p: Vector2 = d*72.0
		draw_line(p,p-d*24.0,Color(0.35,0.22,0.12),9)
	for p in [Vector2(-28,-8),Vector2(34,6),Vector2(4,24)]:
		DrawUtil.circle_outlined(self,p,7,Color(0.42,0.16,0.28),DrawUtil.OUTLINE,2)

func _draw_cartographer_shrine() -> void:
	DrawUtil.shadow(self,Vector2(0,9),48,0.17)
	DrawUtil.rect_outlined(self,Rect2(-38,-58,76,68),Color(0.63,0.64,0.60),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-48,-56),Vector2(0,-91),Vector2(48,-56)]),Color(0.15,0.47,0.36),DrawUtil.OUTLINE,4)
	DrawUtil.circle_outlined(self,Vector2(0,-30),15,Color(0.88,0.76,0.28),DrawUtil.OUTLINE,3)
	for a in [0.0,PI*0.5,PI,PI*1.5]:
		var d: Vector2 = Vector2.RIGHT.rotated(a)
		draw_line(Vector2(0,-30)+d*6,Vector2(0,-30)+d*17,Color(0.88,0.76,0.28),3)


func _draw_amber_caravan() -> void:
	DrawUtil.shadow(self,Vector2(0,10),72,0.18)
	DrawUtil.rect_outlined(self,Rect2(-62,-34,124,54),Color(0.55,0.31,0.13),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-72,-32),Vector2(-50,-72),Vector2(50,-72),Vector2(72,-32)]),Color(0.90,0.55,0.16),DrawUtil.OUTLINE,4)
	for x in [-44.0,44.0]:
		DrawUtil.circle_outlined(self,Vector2(x,23),16,Color(0.26,0.19,0.12),DrawUtil.OUTLINE,4)
		DrawUtil.circle_outlined(self,Vector2(x,23),6,Color(0.68,0.45,0.19),DrawUtil.OUTLINE,2)
	DrawUtil.rect_outlined(self,Rect2(-17,-14,34,34),Color(0.33,0.18,0.09),DrawUtil.OUTLINE,2)
	DrawUtil.circle_outlined(self,Vector2(0,-52),7,Color(1.0,0.76,0.20),DrawUtil.OUTLINE,2)

func _draw_amber_post() -> void:
	_building_shadow(170)
	DrawUtil.rect_outlined(self,Rect2(-72,-70,144,90),Color(0.74,0.57,0.34),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-86,-68),Vector2(0,-112),Vector2(86,-68)]),Color(0.48,0.22,0.12),DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-15,-26,30,46),Color(0.31,0.17,0.08),DrawUtil.OUTLINE,3)
	for x in [-45.0,45.0]:
		DrawUtil.rect_outlined(self,Rect2(x-10,-45,20,24),Color(0.42,0.64,0.72),DrawUtil.OUTLINE,2)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-10,-78),Vector2(10,-78),Vector2(10,-53),Vector2(0,-45),Vector2(-10,-53)]),Color(0.95,0.62,0.16),DrawUtil.OUTLINE,2)

func _draw_edravar_city() -> void:
	_building_shadow(230)
	for x in [-92.0,-32.0,36.0,94.0]:
		var h: float = 82.0+float((int(x)+100)%3)*18.0
		DrawUtil.rect_outlined(self,Rect2(x-26,-h,52,h+18),Color(0.62,0.50,0.36),DrawUtil.OUTLINE,4)
		DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(x-32,-h),Vector2(x,-h-34),Vector2(x+32,-h)]),Color(0.45,0.25,0.16),DrawUtil.OUTLINE,3)
		if x == 36.0:
			draw_line(Vector2(x+5,-h-18),Vector2(x+26,-h-4),Color(0.18,0.15,0.12),5)
	for p in [Vector2(-120,15),Vector2(-58,24),Vector2(65,18),Vector2(125,12)]:
		DrawUtil.ellipse(self,p,18,8,Color(0.46,0.42,0.35))

func _draw_resistance_cistern() -> void:
	DrawUtil.shadow(self,Vector2(0,9),54,0.17)
	DrawUtil.ellipse_outlined(self,Vector2.ZERO,54,31,Color(0.55,0.51,0.42),DrawUtil.OUTLINE,4)
	DrawUtil.ellipse_outlined(self,Vector2(0,-4),32,20,Color(0.15,0.18,0.18),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-32,-4,64,20),Color(0.15,0.18,0.18))
	for x in [-42.0,42.0]:
		draw_line(Vector2(x,-3),Vector2(x,-42),Color(0.46,0.28,0.14),7)
	draw_line(Vector2(-46,-42),Vector2(46,-42),Color(0.46,0.28,0.14),8)
	DrawUtil.circle_outlined(self,Vector2(0,-31),7,Color(0.92,0.63,0.18),DrawUtil.OUTLINE,2)

func _draw_ash_observatory() -> void:
	_building_shadow(180)
	DrawUtil.rect_outlined(self,Rect2(-62,-66,124,82),Color(0.56,0.52,0.46),DrawUtil.OUTLINE,4)
	DrawUtil.ellipse_outlined(self,Vector2(0,-66),62,30,Color(0.43,0.42,0.41),DrawUtil.OUTLINE,4)
	DrawUtil.circle_outlined(self,Vector2(0,-84),26,Color(0.32,0.35,0.37),DrawUtil.OUTLINE,4)
	draw_line(Vector2(0,-84),Vector2(36,-111),Color(0.24,0.24,0.25),8)
	DrawUtil.circle_outlined(self,Vector2(0,-84),8,Color(0.92,0.42,0.17),DrawUtil.OUTLINE,2)
	for x in [-38.0,38.0]:
		DrawUtil.rect_outlined(self,Rect2(x-8,-42,16,34),Color(0.28,0.25,0.22),DrawUtil.OUTLINE,2)

func _draw_ash_citadel() -> void:
	_building_shadow(250)
	for x in [-92.0,92.0]:
		DrawUtil.rect_outlined(self,Rect2(x-34,-118,68,136),Color(0.42,0.40,0.38),DrawUtil.OUTLINE,5)
		for bx in [-24.0,0.0,24.0]:
			draw_rect(Rect2(x+bx-7,-128,14,16),Color(0.42,0.40,0.38))
	DrawUtil.rect_outlined(self,Rect2(-92,-76,184,94),Color(0.49,0.45,0.40),DrawUtil.OUTLINE,5)
	DrawUtil.ellipse_outlined(self,Vector2(0,-18),34,36,Color(0.18,0.13,0.11),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-34,-18,68,36),Color(0.18,0.13,0.11))
	for p in [Vector2(-58,-72),Vector2(58,-72)]:
		DrawUtil.flame(self,p,26,10,anim_t)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-13,-104),Vector2(13,-104),Vector2(13,-75),Vector2(0,-66),Vector2(-13,-75)]),Color(0.73,0.23,0.11),DrawUtil.OUTLINE,3)


func _draw_stilt_village() -> void:
	_building_shadow(210)
	draw_line(Vector2(-72,18),Vector2(-72,62),Color(0.32,0.22,0.13),10)
	draw_line(Vector2(72,18),Vector2(72,62),Color(0.32,0.22,0.13),10)
	DrawUtil.rect_outlined(self,Rect2(-86,-46,172,66),Color(0.54,0.37,0.20),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-98,-44),Vector2(0,-96),Vector2(98,-44)]),Color(0.20,0.38,0.24),DrawUtil.OUTLINE,4)
	for x in [-52.0,0.0,52.0]:
		DrawUtil.rect_outlined(self,Rect2(x-10,-26,20,26),Color(0.25,0.46,0.54),DrawUtil.OUTLINE,2)
	for p in [Vector2(-70,-55),Vector2(70,-55)]:
		DrawUtil.circle_outlined(self,p,7,Color(0.94,0.76,0.24),DrawUtil.OUTLINE,2)

func _draw_drowned_bell() -> void:
	_building_shadow(150)
	DrawUtil.rect_outlined(self,Rect2(-46,-92,92,110),Color(0.49,0.53,0.48),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-58,-90),Vector2(0,-132),Vector2(58,-90)]),Color(0.18,0.35,0.27),DrawUtil.OUTLINE,4)
	DrawUtil.ellipse_outlined(self,Vector2(0,-55),18,24,Color(0.21,0.24,0.23),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(0,-60),10,Color(0.58,0.47,0.22),DrawUtil.OUTLINE,2)
	draw_line(Vector2(0,-49),Vector2(0,-31),Color(0.48,0.36,0.16),3)
	for x in [-30.0,30.0]:
		DrawUtil.rect_outlined(self,Rect2(x-7,-30,14,24),Color(0.28,0.45,0.49),DrawUtil.OUTLINE,2)

func _draw_flooded_monastery() -> void:
	_building_shadow(230)
	DrawUtil.rect_outlined(self,Rect2(-96,-76,192,94),Color(0.52,0.54,0.50),DrawUtil.OUTLINE,5)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-110,-73),Vector2(0,-126),Vector2(110,-73)]),Color(0.20,0.31,0.25),DrawUtil.OUTLINE,4)
	for x in [-60.0,-20.0,20.0,60.0]:
		DrawUtil.rect_outlined(self,Rect2(x-7,-45,14,34),Color(0.19,0.31,0.33),DrawUtil.OUTLINE,2)
	DrawUtil.ellipse_outlined(self,Vector2(0,-4),30,25,Color(0.16,0.18,0.17),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-30,-4,60,22),Color(0.16,0.18,0.17))
	for p in [Vector2(-76,10),Vector2(73,12)]:
		DrawUtil.ellipse(self,p,32,8,Color(0.20,0.46,0.52,0.55))

func _draw_reed_sanctum() -> void:
	DrawUtil.shadow(self,Vector2(0,12),74,0.18)
	for x in [-48.0,48.0]:
		DrawUtil.capsule_outlined(self,Vector2(x,10),Vector2(x,-72),9,Color(0.37,0.30,0.13),DrawUtil.OUTLINE,3)
		for y in [-25.0,-47.0,-69.0]:
			draw_line(Vector2(x,y),Vector2(x+sign(x)*20,y-8),Color(0.37,0.47,0.18),5)
	DrawUtil.rect_outlined(self,Rect2(-58,-24,116,38),Color(0.50,0.45,0.27),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(0,-42),16,Color(0.31,0.64,0.42),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(0,-42),6,Color(0.72,0.93,0.57),DrawUtil.OUTLINE,2)

func _draw_reed_throne() -> void:
	DrawUtil.shadow(self,Vector2(0,12),90,0.20)
	DrawUtil.rect_outlined(self,Rect2(-45,-58,90,76),Color(0.36,0.28,0.17),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-58,-56),Vector2(-36,-98),Vector2(-8,-78),Vector2(0,-118),Vector2(8,-78),Vector2(36,-98),Vector2(58,-56)]),Color(0.29,0.41,0.17),DrawUtil.OUTLINE,4)
	DrawUtil.circle_outlined(self,Vector2(0,-48),12,Color(0.48,0.18,0.32),DrawUtil.OUTLINE,3)
	for x in [-70.0,-52.0,52.0,70.0]:
		draw_line(Vector2(x,14),Vector2(x,-72),Color(0.34,0.43,0.17),6)

func _draw_echo_sluice() -> void:
	_building_shadow(220)
	for x in [-78.0,78.0]:
		DrawUtil.rect_outlined(self,Rect2(x-22,-76,44,96),Color(0.51,0.52,0.49),DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-78,-63,156,26),Color(0.57,0.57,0.53),DrawUtil.OUTLINE,4)
	for x in [-42.0,0.0,42.0]:
		draw_line(Vector2(x,-35),Vector2(x,16),Color(0.25,0.29,0.28),7)
	DrawUtil.circle_outlined(self,Vector2(0,-51),13,Color(0.32,0.79,0.84),DrawUtil.OUTLINE,3)
	draw_circle(Vector2(0,-51),5,Color(0.83,1.0,1.0))
	for p in [Vector2(-94,8),Vector2(94,8)]:
		DrawUtil.ellipse(self,p,34,8,Color(0.21,0.46,0.52,0.58))


func _draw_frost_rest() -> void:
	_building_shadow(170)
	DrawUtil.rect_outlined(self,Rect2(-70,-62,140,82),Color(0.62,0.48,0.31),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-84,-60),Vector2(0,-111),Vector2(84,-60)]),Color(0.30,0.46,0.60),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-76,-64),Vector2(0,-104),Vector2(76,-64)]),Color(0.90,0.95,0.98),Color(0.90,0.95,0.98),2)
	DrawUtil.rect_outlined(self,Rect2(-14,-24,28,44),Color(0.29,0.17,0.09),DrawUtil.OUTLINE,3)
	for x in [-43.0,43.0]:
		DrawUtil.rect_outlined(self,Rect2(x-10,-42,20,23),Color(0.46,0.73,0.86),DrawUtil.OUTLINE,2)

func _draw_frozen_station() -> void:
	_building_shadow(190)
	DrawUtil.rect_outlined(self,Rect2(-82,-70,164,90),Color(0.59,0.62,0.62),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-96,-68),Vector2(0,-116),Vector2(96,-68)]),Color(0.37,0.49,0.58),DrawUtil.OUTLINE,4)
	for x in [-52.0,-18.0,18.0,52.0]:
		DrawUtil.rect_outlined(self,Rect2(x-7,-45,14,30),Color(0.31,0.49,0.58),DrawUtil.OUTLINE,2)
	DrawUtil.rect_outlined(self,Rect2(-17,-26,34,46),Color(0.28,0.25,0.22),DrawUtil.OUTLINE,3)
	for p in [Vector2(-65,-76),Vector2(63,-75)]:
		DrawUtil.ellipse(self,p,24,7,Color(0.93,0.97,1.0))

func _draw_frozen_command() -> void:
	_building_shadow(205)
	DrawUtil.rect_outlined(self,Rect2(-88,-78,176,96),Color(0.50,0.55,0.59),DrawUtil.OUTLINE,5)
	for x in [-62.0,62.0]:
		DrawUtil.rect_outlined(self,Rect2(x-20,-108,40,126),Color(0.46,0.52,0.57),DrawUtil.OUTLINE,4)
		DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(x-26,-106),Vector2(x,-133),Vector2(x+26,-106)]),Color(0.26,0.39,0.52),DrawUtil.OUTLINE,3)
	DrawUtil.ellipse_outlined(self,Vector2(0,-18),30,34,Color(0.16,0.19,0.22),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-30,-18,60,36),Color(0.16,0.19,0.22))
	DrawUtil.circle_outlined(self,Vector2(0,-57),10,Color(0.43,0.76,0.94),DrawUtil.OUTLINE,2)

func _draw_frozen_archive() -> void:
	DrawUtil.shadow(self,Vector2(0,11),72,0.18)
	DrawUtil.rect_outlined(self,Rect2(-58,-68,116,86),Color(0.61,0.68,0.72),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-70,-66),Vector2(0,-108),Vector2(70,-66)]),Color(0.33,0.56,0.72),DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-15,-26,30,44),Color(0.24,0.29,0.33),DrawUtil.OUTLINE,3)
	DrawUtil.circle_outlined(self,Vector2(0,-54),11,Color(0.46,0.83,1.0),DrawUtil.OUTLINE,2)
	for p in [Vector2(-43,-42),Vector2(43,-42)]:
		DrawUtil.rect_outlined(self,Rect2(p-Vector2(7,10),Vector2(14,20)),Color(0.54,0.81,0.92),DrawUtil.OUTLINE,2)

func _draw_black_frost_citadel() -> void:
	_building_shadow(260)
	for x in [-98.0,98.0]:
		DrawUtil.rect_outlined(self,Rect2(x-35,-126,70,144),Color(0.31,0.39,0.47),DrawUtil.OUTLINE,5)
		for bx in [-24.0,0.0,24.0]:
			draw_rect(Rect2(x+bx-7,-137,14,17),Color(0.31,0.39,0.47))
	DrawUtil.rect_outlined(self,Rect2(-98,-82,196,100),Color(0.36,0.44,0.50),DrawUtil.OUTLINE,5)
	DrawUtil.ellipse_outlined(self,Vector2(0,-20),36,38,Color(0.10,0.15,0.20),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-36,-20,72,38),Color(0.10,0.15,0.20))
	for p in [Vector2(-64,-79),Vector2(64,-79)]:
		DrawUtil.flame(self,p,25,9,anim_t)
	DrawUtil.circle_outlined(self,Vector2(0,-104),13,Color(0.18,0.43,0.70),DrawUtil.OUTLINE,3)

func _draw_return_gate() -> void:
	DrawUtil.shadow(self,Vector2(0,10),70,0.18)
	for x in [-52.0,52.0]:
		DrawUtil.rect_outlined(self,Rect2(x-18,-72,36,88),Color(0.63,0.65,0.64),DrawUtil.OUTLINE,4)
	DrawUtil.rect_outlined(self,Rect2(-52,-62,104,22),Color(0.69,0.70,0.68),DrawUtil.OUTLINE,3)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-12,-68),Vector2(12,-68),Vector2(12,-43),Vector2(0,-34),Vector2(-12,-43)]),Color(0.11,0.37,0.78),DrawUtil.OUTLINE,2)


func _draw_mist_port() -> void:
	_building_shadow(220)
	DrawUtil.rect_outlined(self,Rect2(-92,-54,184,72),Color(0.50,0.36,0.20),DrawUtil.OUTLINE,4)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-106,-52),Vector2(0,-104),Vector2(106,-52)]),Color(0.19,0.39,0.48),DrawUtil.OUTLINE,4)
	for x in [-58.0,0.0,58.0]:
		DrawUtil.rect_outlined(self,Rect2(x-9,-32,18,25),Color(0.38,0.67,0.76),DrawUtil.OUTLINE,2)
	for x in [-76.0,76.0]:
		draw_line(Vector2(x,18),Vector2(x,56),Color(0.36,0.24,0.13),8)

func _draw_twin_lighthouse() -> void:
	DrawUtil.shadow(self,Vector2(0,12),86,0.18)
	for x in [-42.0,42.0]:
		DrawUtil.rect_outlined(self,Rect2(x-18,-104,36,120),Color(0.82,0.80,0.70),DrawUtil.OUTLINE,4)
		DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(x-25,-102),Vector2(x,-132),Vector2(x+25,-102)]),Color(0.20,0.42,0.54),DrawUtil.OUTLINE,3)
		DrawUtil.circle_outlined(self,Vector2(x,-89),8,Color(1.0,0.84,0.34),DrawUtil.OUTLINE,2)
	draw_line(Vector2(-42,-88),Vector2(42,-88),Color(0.86,0.78,0.44),4)

func _draw_sunken_temple() -> void:
	_building_shadow(240)
	DrawUtil.rect_outlined(self,Rect2(-96,-70,192,88),Color(0.52,0.61,0.59),DrawUtil.OUTLINE,5)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-110,-68),Vector2(0,-124),Vector2(110,-68)]),Color(0.18,0.49,0.57),DrawUtil.OUTLINE,4)
	for x in [-64.0,-32.0,32.0,64.0]:
		DrawUtil.rect_outlined(self,Rect2(x-8,-48,16,48),Color(0.43,0.55,0.53),DrawUtil.OUTLINE,3)
	DrawUtil.ellipse_outlined(self,Vector2(0,-18),28,32,Color(0.12,0.23,0.28),DrawUtil.OUTLINE,3)
	draw_rect(Rect2(-28,-18,56,36),Color(0.12,0.23,0.28))
	for p in [Vector2(-82,8),Vector2(82,8)]:
		DrawUtil.ellipse(self,p,34,8,Color(0.16,0.54,0.65,0.52))

func _draw_lost_shipyard() -> void:
	DrawUtil.shadow(self,Vector2(0,12),105,0.19)
	for y in [-42.0,8.0]:
		DrawUtil.rect_outlined(self,Rect2(-108,y,216,20),Color(0.47,0.31,0.17),DrawUtil.OUTLINE,3)
	for x in [-82.0,-28.0,28.0,82.0]:
		draw_line(Vector2(x,-42),Vector2(x,40),Color(0.38,0.25,0.13),8)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(-62,-14),Vector2(0,-54),Vector2(62,-14),Vector2(44,18),Vector2(-44,18)]),Color(0.36,0.48,0.48),DrawUtil.OUTLINE,3)
	draw_line(Vector2(0,-50),Vector2(0,-105),Color(0.39,0.27,0.15),6)
	DrawUtil.poly_outlined(self,PackedVector2Array([Vector2(4,-100),Vector2(48,-78),Vector2(4,-62)]),Color(0.23,0.55,0.64),DrawUtil.OUTLINE,2)

func _draw_tidal_observatory() -> void:
	_building_shadow(210)
	DrawUtil.rect_outlined(self,Rect2(-78,-74,156,92),Color(0.45,0.54,0.57),DrawUtil.OUTLINE,5)
	DrawUtil.ellipse_outlined(self,Vector2(0,-75),78,34,Color(0.28,0.45,0.52),DrawUtil.OUTLINE,4)
	DrawUtil.circle_outlined(self,Vector2(0,-94),29,Color(0.20,0.33,0.40),DrawUtil.OUTLINE,4)
	draw_line(Vector2(0,-94),Vector2(47,-128),Color(0.18,0.28,0.34),9)
	DrawUtil.circle_outlined(self,Vector2(0,-94),8,Color(0.30,0.79,0.91),DrawUtil.OUTLINE,2)
	for x in [-48.0,48.0]:
		DrawUtil.rect_outlined(self,Rect2(x-9,-46,18,36),Color(0.24,0.36,0.39),DrawUtil.OUTLINE,2)
