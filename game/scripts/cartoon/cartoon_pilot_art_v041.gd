extends RefCounted
## Shared original painted assets. This family is enabled for the REG001 pilot.
const FOLIAGE = preload("res://assets/cartoon/v041/foliage.png")
const GRASS = preload("res://assets/cartoon/v041/grass.png")
const STONE = preload("res://assets/cartoon/v041/stone.png")
const CREATURES = preload("res://assets/cartoon/v041/creatures.png")
const PEOPLE = preload("res://assets/cartoon/v041/people.png")
static var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cartoon/v041/art.json"))
static var cache: Dictionary = {}
static var animation_cache: Dictionary = {}
static func atlas(name: String, source: Texture2D, box: Array) -> AtlasTexture:
	if not cache.has(name):
		var tex = AtlasTexture.new()
		tex.atlas = source
		tex.region = Rect2(box[0],box[1],box[2],box[3])
		tex.filter_clip = true
		cache[name] = tex
	return cache[name] as AtlasTexture
static func nature_key(kind: String, variant: int) -> String:
	if kind=="tree": return ["oak","birch","maple"][posmod(variant,3)]
	return kind if kind in ["pine","bush","rock","flowers","tuft"] else ""
static func nature_texture(key: String) -> AtlasTexture:
	return atlas(key,FOLIAGE,manifest.nature[key].region)
static func nature_rect(key: String) -> Rect2:
	var data: Dictionary = manifest.nature[key]
	var size_v = Vector2(data.region[2],data.region[3])
	var anchor = Vector2(data.anchor[0],data.anchor[1])
	var factor: float = float(data.world_width)/size_v.x
	return Rect2(-anchor*factor,size_v*factor)
static func draw_prop(canvas: CanvasItem, kind: String, variant: int) -> bool:
	var key: String = nature_key(kind,variant)
	if key.is_empty(): return false
	canvas.draw_texture_rect(nature_texture(key),nature_rect(key),false)
	return true
static func people_texture(role: String, frame: int) -> AtlasTexture:
	var frames: Array = manifest.people[role].frames
	var index: int = posmod(frame,frames.size())
	return atlas("npc_%s_%d"%[role,index],PEOPLE,frames[index].region)
static func people_anchor(role: String, frame: int) -> Vector2:
	var frames: Array = manifest.people[role].frames
	var anchor: Array = frames[posmod(frame,frames.size())].anchor
	return Vector2(anchor[0],anchor[1])
static func people_frames(role: String) -> SpriteFrames:
	if not animation_cache.has(role):
		var frames = SpriteFrames.new()
		frames.remove_animation("default")
		frames.add_animation("idle")
		frames.add_frame("idle",people_texture(role,0))
		frames.add_animation("walk")
		frames.set_animation_speed("walk",5)
		var count: int = manifest.people[role].frames.size()
		for index: int in ([0,1,0,2] if count==3 else [0]): frames.add_frame("walk",people_texture(role,index))
		animation_cache[role] = frames
	return animation_cache[role] as SpriteFrames
static func pose_index(animation: StringName, frame: int) -> int:
	return [0,1,0,2][posmod(frame,4)] if animation==&"walk" else 0

static func creature_texture(kind: String, pose: int) -> AtlasTexture:
	return atlas("creature_%s_%d"%[kind,pose],CREATURES,manifest.creatures[kind].frames[posmod(pose,3)].region)
static func creature_rect(kind: String, pose: int) -> Rect2:
	var data: Dictionary = manifest.creatures[kind]
	var frame: Dictionary = data.frames[posmod(pose,3)]
	return Rect2(-Vector2(frame.anchor[0],frame.anchor[1])*float(data.scale),Vector2(frame.region[2],frame.region[3])*float(data.scale))
static func draw_creature(canvas: CanvasItem, kind: String, pose: int, tint: Color = Color.WHITE) -> void:
	canvas.draw_texture_rect(creature_texture(kind,pose),creature_rect(kind,pose),false,tint)
