extends RefCounted
const ROOT: String = "res://assets/cartoon/v023/"
static var cache: Dictionary = {}
static func texture(key: String) -> Texture2D:
	if not cache.has(key): cache[key] = load(ROOT+key+".svg")
	return cache[key] as Texture2D
