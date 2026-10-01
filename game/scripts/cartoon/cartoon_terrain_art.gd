class_name ValedouroCartoonTerrainArt
extends RefCounted
## Static ground commands, issued once per chunk/redraw; no per-frame noise.

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const Assets = preload("res://scripts/cartoon/cartoon_visual_assets.gd")

static func grass(canvas: CanvasItem, rect: Rect2, tint: Color = Color.WHITE) -> void:
	canvas.draw_texture_rect(Assets.texture("grass"),rect,true,tint)

static func stone(canvas: CanvasItem, p: Vector2, size: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array([
		p+Vector2(3,0),p+Vector2(size.x-3,-1),p+Vector2(size.x,3),
		p+Vector2(size.x-1,size.y-2),p+Vector2(size.x-5,size.y),
		p+Vector2(1,size.y-1),p+Vector2(0,3)])
	canvas.draw_colored_polygon(points,color)
	canvas.draw_line(p+Vector2(3,1),p+Vector2(size.x-4,0),color.lightened(0.15),1.0,true)

static func path(canvas: CanvasItem, points: PackedVector2Array, width: float, paved: bool = false, seed_value: int = 0) -> void:
	if points.size() < 2: return
	var edge: Color = Color("697e50")
	var fill: Color = Color("b2a17b") if paved else Color("b09a70")
	canvas.draw_polyline(points,edge,width+16.0,true)
	canvas.draw_polyline(points,Color("8c8861"),width+6.0,true)
	canvas.draw_polyline(points,fill,width,true)
	for p: Vector2 in points:
		canvas.draw_circle(p,width*0.5,fill)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(points.size()-1):
		var a: Vector2 = points[i]
		var b: Vector2 = points[i+1]
		var d: Vector2 = (b-a).normalized()
		var perpendicular: Vector2 = Vector2(-d.y,d.x)
		var spacing: float = 23.0 if paved else 35.0
		for j in range(int(a.distance_to(b)/spacing)):
			var center: Vector2 = a+d*(float(j)*spacing+10.0)
			if paved:
				for offset: float in [-0.3,0.0,0.3]:
					var p: Vector2 = center+perpendicular*(offset*width)+Vector2(rng.randf_range(-3,3),rng.randf_range(-3,3))
					stone(canvas,p-Vector2(8,5),Vector2(16,10),Color("b9ae8d").darkened(rng.randf_range(0,0.16)))
			else:
				var p: Vector2 = center+perpendicular*rng.randf_range(-width*0.36,width*0.36)
				DrawUtil.ellipse(canvas,p,3.5,2.0,Color("8e835f"))
				canvas.draw_line(center+perpendicular*width*0.28,center+d*15+perpendicular*width*0.29,Color(0.48,0.40,0.28,0.16),1.2,true)

static func courtyard(canvas: CanvasItem, center: Vector2, size: Vector2, seed_value: int) -> void:
	DrawUtil.ellipse(canvas,center,size.x,size.y,Color("7b8659"),40)
	DrawUtil.ellipse(canvas,center,size.x-6,size.y-4,Color("a19d7a"),40)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	for y in range(int(-size.y)+12,int(size.y)-8,14):
		for x in range(int(-size.x)+12,int(size.x)-12,22):
			var p: Vector2 = Vector2(x+7*(posmod(y,28)/14),y)
			if pow(p.x/(size.x-14),2)+pow(p.y/(size.y-10),2) > 1.0: continue
			stone(canvas,center+p,Vector2(18,10),Color("b3ad91").darkened(rng.randf_range(0,0.16)))
