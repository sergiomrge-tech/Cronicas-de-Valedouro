class_name ValedouroCartoonCombatFX
extends Node2D
## Short lived additive effects: shared radial light, bounded actors, no external assets.
static var active_count: int = 0
static var light_count: int = 0
static var light_texture: Texture2D
var travel_visual: bool = true
var kind: String = "arcane"
var age: float = 0.0
var lifetime: float = 0.8
var direction: Vector2 = Vector2.RIGHT
var tint: Color = Color("a287ff")
var damage: int = 0
var owns_light: bool = false
var light: PointLight2D
var corpse_texture: Texture2D
var corpse_rect: Rect2 = Rect2(-44,-88,88,98)
var corpse_region: Rect2
var strike_radius: float = 64.0
static func spawn(parent: Node, origin: Vector2, effect: String, aim: Vector2 = Vector2.RIGHT, color: Color = Color("a287ff"), amount: int = 0):
	if parent == null or not parent.is_inside_tree() or active_count >= 48: return null
	var fx = ValedouroCartoonCombatFX.new()
	fx.kind = effect
	fx.position = origin
	fx.direction = aim.normalized() if aim.length()>0.01 else Vector2.RIGHT
	fx.tint = color
	fx.damage = amount
	fx.lifetime = 0.5 if effect in ["slash","hit","hurt","evade","enemy_strike"] else 0.9
	parent.add_child(fx)
	return fx
func _ready() -> void:
	active_count += 1
	add_to_group("cartoon_combat_fx")
	z_index = 5
	var additive = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = additive
	if light_texture == null:
		var gradient = Gradient.new()
		gradient.colors = PackedColorArray([Color.WHITE,Color(1,1,1,0)])
		var radial = GradientTexture2D.new()
		radial.gradient = gradient
		radial.width = 128
		radial.height = 128
		radial.fill = GradientTexture2D.FILL_RADIAL
		radial.fill_from = Vector2(0.5,0.5)
		radial.fill_to = Vector2(1,0.5)
		light_texture = radial
	if light_count < 8:
		light = PointLight2D.new()
		light.texture = light_texture
		light.color = tint
		light.energy = 0.5
		light.texture_scale = 1.7
		add_child(light)
		light_count += 1
		owns_light = true
func _exit_tree() -> void:
	active_count -= 1
	if owns_light: light_count -= 1
func _process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	if light != null: light.energy = (1.0-age/lifetime)*0.55
	queue_redraw()
func _draw() -> void:
	var p: float = clampf(age/lifetime,0,1)
	var fade: float = 1-p
	var bloom: float = sin(p*PI)
	var center: Vector2 = direction*(p*90.0) if travel_visual and kind in ["ember","frost","arcane"] else Vector2.ZERO
	for i in range(6,0,-1):
		draw_circle(center,float(i)*(4+8*bloom),Color(tint,fade*0.035))
	if corpse_texture != null:
		draw_texture_rect_region(corpse_texture,corpse_rect,corpse_region,Color(tint,fade*0.7))
	match kind:
		"enemy_strike":
			draw_arc(Vector2.ZERO,strike_radius,0,TAU,64,Color(tint,fade),3.5,true)
			draw_arc(Vector2.ZERO,strike_radius*(0.7+p*0.3),direction.angle()-1.4,direction.angle()+1.4,40,Color(tint,fade*0.6),6,true)
		"evade":
			for i in range(5):
				var start: Vector2 = -direction*(p*40+i*7)+direction.orthogonal()*float(i-2)*6
				draw_line(start,start-direction*(15+fade*22),Color(tint,fade*(0.7-i*0.1)),2,true)
		"slash":
			var angle: float = direction.angle()
			for i in range(4):
				draw_arc(Vector2(0,-18),36+p*35+i*3,angle-1.2+p,angle+0.8+p,32,Color(tint,fade*(0.65-i*0.13)),3.5,true)
		"ember":
			for i in range(7):
				var q: Vector2 = center-direction*(i*9.0)+direction.orthogonal()*sin(age*22+i)*5
				draw_circle(q,14-i*1.4,Color(tint,fade*(0.65-i*0.07)))
				draw_circle(q,5-i*0.5,Color(1,0.87,0.35,fade*0.8))
			for i in range(5):
				var a: float = age*8+i*TAU/5
				draw_arc(center,18+bloom*16,a,a+0.8,12,Color("ffbf53",fade),2,true)
		"frost":
			for i in range(6):
				var arm: Vector2 = Vector2.from_angle(i*TAU/6+age)*float(20+28*bloom)
				draw_line(center,center+arm,Color(tint,fade),3,true)
				for side: float in [-1.0,1.0]:
					draw_line(center+arm*0.65,center+arm*0.65-arm.rotated(side*0.8)*0.28,Color(0.8,1,1,fade),2,true)
				draw_colored_polygon(PackedVector2Array([center+arm,center+arm*1.25+arm.orthogonal()*0.10,center+arm*1.5,center+arm*1.25-arm.orthogonal()*0.10]),Color(tint,fade))
		"arcane":
			for ring in range(3):
				var a: float = age*(3+ring)*(1 if ring%2==0 else -1)
				draw_arc(center,20+ring*12+bloom*9,a,a+PI*1.55,48,Color(tint,fade),2,true)
			for i in range(8):
				var v: Vector2 = Vector2.from_angle(i*TAU/8-age*2)*(48+bloom*10)
				draw_colored_polygon(PackedVector2Array([center+v+Vector2(0,-5),center+v+Vector2(3,0),center+v+Vector2(0,5),center+v-Vector2(3,0)]),Color(0.94,0.74,1,fade))
		_:
			draw_arc(center,12+p*46,0,TAU,48,Color(tint,fade),3,true)
	for i in range(18):
		var a: float = float(i)*2.39996+age*0.7
		var speed: float = 25+float((i*17)%65)
		var q: Vector2 = center+Vector2.from_angle(a)*(8+p*speed)+Vector2(0,p*p*22)
		draw_line(q,q-Vector2.from_angle(a)*(3+fade*7),Color(tint,fade*0.85),1.6,true)
		draw_circle(q,1+fade,Color(1,0.96,0.72,fade))
	if damage > 0:
		draw_string(ThemeDB.fallback_font,Vector2(-12,-30-age*44),str(damage),HORIZONTAL_ALIGNMENT_CENTER,32,17,Color(1,0.94,0.7,fade))
