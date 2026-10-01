extends RefCounted
## The marsh/coast renderers and wildlife share the same water geometry.
static var cache: Dictionary = {}
static func patches(region_id: String, coord: Vector2i) -> Array[Dictionary]:
	var key: String = region_id+str(coord)
	if cache.has(key): return cache[key]
	var rows: Array[Dictionary] = []
	var coast: bool = "COSTAS" in region_id
	if not coast and not "PANTANOS" in region_id: return rows
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 660811+coord.x*73973+coord.y*55763+517 if coast else 470113+coord.x*79133+coord.y*53831+311
	for i in range(6 if coast else 8):
		var p: Vector2 = Vector2(rng.randf_range(80 if coast else 70,944 if coast else 954),rng.randf_range(80 if coast else 70,944 if coast else 954))
		var size_v: Vector2 = Vector2(rng.randf_range(70 if coast else 55,150 if coast else 130),rng.randf_range(32 if coast else 28,80 if coast else 72))
		rows.append({"pos":p,"radius":size_v})
	cache[key] = rows
	return rows
static func is_water(p: Vector2, region_id: String) -> bool:
	var coord: Vector2i = Vector2i(floori(p.x/1024),floori(p.y/1024))
	for row in patches(region_id,coord):
		var local: Vector2 = p-Vector2(coord)*1024-row.pos
		if (local/(row.radius+Vector2(16,16))).length_squared()<1: return true
	return false
