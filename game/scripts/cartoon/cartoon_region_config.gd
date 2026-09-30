class_name ValedouroCartoonRegionConfig
extends RefCounted

const HUB_LOCAL_SIZE: Vector2 = Vector2(2300,2350)
const CITY_LINEAR_SCALE: float = 7.0
const REGION_SIZE: Vector2 = Vector2(16100,16450)
const HUB_ORIGIN: Vector2 = (REGION_SIZE - HUB_LOCAL_SIZE) * 0.5
const HUB_RECT: Rect2 = Rect2(HUB_ORIGIN, HUB_LOCAL_SIZE)
const CHUNK_SIZE: int = 1024
const ACTIVE_RADIUS: int = 2
const REGION_ID: String = "REG_001_BERCO_VALEDOURO"
const SOUTH_ROAD_X: float = REGION_SIZE.x * 0.5

static func world_from_hub(local_pos: Vector2) -> Vector2:
	return HUB_ORIGIN + local_pos

static func hub_from_world(world_pos: Vector2) -> Vector2:
	return world_pos - HUB_ORIGIN

static func chunk_of(world_pos: Vector2) -> Vector2i:
	return Vector2i(floori(world_pos.x / float(CHUNK_SIZE)), floori(world_pos.y / float(CHUNK_SIZE)))

static func in_region(world_pos: Vector2, margin: float = 64.0) -> bool:
	return world_pos.x >= margin and world_pos.y >= margin and world_pos.x <= REGION_SIZE.x - margin and world_pos.y <= REGION_SIZE.y - margin

static func in_authored_hub(world_pos: Vector2, margin: float = 0.0) -> bool:
	return HUB_RECT.grow(margin).has_point(world_pos)
