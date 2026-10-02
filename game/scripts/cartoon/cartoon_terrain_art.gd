class_name ValedouroCartoonTerrainArt
extends RefCounted
## Static ground commands, issued once per chunk/redraw; no per-frame noise.

const DrawUtil = preload("res://scripts/cartoon/cartoon_draw.gd")
const PilotArt = preload("res://scripts/cartoon/cartoon_pilot_art_v041.gd")
const Assets = preload("res://scripts/cartoon/cartoon_visual_assets.gd")

static func grass(canvas: CanvasItem, rect: Rect2, tint: Color = Color.WHITE, world_origin: Vector2 = Vector2.ZERO) -> void:
	var points = PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
	var uv = PackedVector2Array()
	for point in points: uv.append((point+world_origin)/512.0)
	canvas.draw_polygon(points,PackedColorArray([tint]),uv,PilotArt.GRASS)

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
	if paved:
		for i in range(points.size()-1):
			var side: Vector2 = (points[i+1]-points[i]).normalized().orthogonal()*(width*0.5-3)
			var corners = PackedVector2Array([points[i]-side,points[i]+side,points[i+1]+side,points[i+1]-side])
			var uv = PackedVector2Array()
			for point in corners: uv.append(point/256.0)
			canvas.draw_polygon(corners,PackedColorArray([Color.WHITE]),uv,PilotArt.STONE)
		return
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

static func courtyard(canvas: CanvasItem, center: Vector2, size: Vector2, _seed_value: int) -> void:
	DrawUtil.ellipse(canvas,center,size.x,size.y,Color("657b43"),48)
	DrawUtil.ellipse(canvas,center,size.x-3,size.y-2,Color("bfa36b"),48)
	var points: PackedVector2Array = DrawUtil.ellipse_points(center,size.x-7,size.y-5,48)
	var uv = PackedVector2Array()
	for point in points: uv.append(point/256.0)
	canvas.draw_polygon(points,PackedColorArray([Color.WHITE]),uv,PilotArt.STONE)
