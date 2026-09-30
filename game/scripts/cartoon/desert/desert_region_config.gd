class_name ValedouroCartoonDesertConfig
extends RefCounted

const REGION_ID: String = "REG_003_DESERTO_RUINAS"
const REGION_SIZE: Vector2 = Vector2(34500,35250)
const CHUNK_SIZE: int = 1024
const ACTIVE_RADIUS: int = 2
const ENTRY_POS: Vector2 = Vector2(3600,31500)

static func chunk_of(world_pos: Vector2) -> Vector2i:
	return Vector2i(floori(world_pos.x/float(CHUNK_SIZE)),floori(world_pos.y/float(CHUNK_SIZE)))

static func in_region(world_pos: Vector2, margin: float = 64.0) -> bool:
	return world_pos.x >= margin and world_pos.y >= margin and world_pos.x <= REGION_SIZE.x-margin and world_pos.y <= REGION_SIZE.y-margin
