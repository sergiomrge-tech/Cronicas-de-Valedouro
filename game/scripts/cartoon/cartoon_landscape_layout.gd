class_name ValedouroCartoonLandscapeLayout
extends RefCounted
## One road graph for ground rendering and vegetation clearance in Valedouro.

const Region = preload("res://scripts/cartoon/cartoon_region_config.gd")
static var cached_roads: Array[Dictionary] = []

static func roads() -> Array[Dictionary]:
	if not cached_roads.is_empty(): return cached_roads
	var x: float = Region.SOUTH_ROAD_X
	var north: float = Region.HUB_RECT.position.y
	var south: float = Region.HUB_RECT.end.y
	var definitions: Array = [
		[Vector2(x,0),Vector2(x,north),102.0],
		# The northeast palace leaves the canonical northern road unobstructed.
		[Vector2(x,north+120),Vector2(x+1350,north+120),100.0],
		[Vector2(x+1350,north+120),Vector2(x+1350,north-280),120.0],
		[Vector2(x,south),Vector2(x,Region.REGION_SIZE.y),116.0],
		[Vector2(x-760,north-1800),Vector2(x,north-1800),94.0],
		[Vector2(x,north-2950),Vector2(x+900,north-2950),94.0],
		[Vector2(x-1120,north-4100),Vector2(x,north-4100),94.0],
		[Vector2(x,north-5350),Vector2(x+1080,north-5350),94.0],
		[Vector2(x-980,north-4100),Vector2(x-980,north-4460),60.0],
		[Vector2(x-3300,south+2100),Vector2(x,south+2100),108.0],
		[Vector2(x,south+4200),Vector2(x+3600,south+4200),108.0],
		# Local accesses: shelter and shrines face the road; ruins use their old route.
		[Vector2(x-330,south+1350),Vector2(x,south+1350),54.0],
		[Vector2(x,south+2850),Vector2(x+180,south+2850),42.0],
		[Vector2(x-2050,south+2100),Vector2(x-2050,south+2150),54.0],
		[Vector2(x+1950,south+4100),Vector2(x+1950,south+4200),54.0],
		[Vector2(x-220,south+6100),Vector2(x,south+6100),54.0],
		[Vector2(x-2650,south+2100),Vector2(x-2650,south+4550),42.0],
		[Vector2(x-2650,south+4550),Vector2(x,south+4550),42.0],
		[Vector2(x+2850,south+4200),Vector2(x+2850,south+5050),42.0]
	]
	for definition: Array in definitions:
		cached_roads.append({"a":definition[0],"b":definition[1],"width":definition[2]})
	return cached_roads

static func near_road(p: Vector2, margin: float) -> bool:
	for road: Dictionary in roads():
		if p.distance_to(Geometry2D.get_closest_point_to_segment(p,road["a"],road["b"])) < margin:
			return true
	return false
