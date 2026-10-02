extends RefCounted
## Shared original painted key poses. Gameplay timers and frame counts are unchanged.
const FRAMES = {"idle":8,"walk":12,"attack":6,"cast":8,"hurt":4,"death":8,"shoot":8,"evade":6}
const GROUND_RECT = Rect2(-40,-92.5,80,100)
const TEXTURES = {
	"archery":preload("res://assets/cartoon/v042/archery.png"),
	"front":preload("res://assets/cartoon/v042/hero_front.png"),
	"back":preload("res://assets/cartoon/v042/hero_back.png"),
	"right":preload("res://assets/cartoon/v042/hero_right.png")}
const POSES = {
	"idle":[0,0,0,0,0,0,0,0],
	"walk":[2,1,1,1,2,2,2,3,3,3,2,2],
	"attack":[4,4,5,5,6,6],
	"cast":[7,7,7,7,8,8,8,8],
	"hurt":[9,9,9,9],
	"death":[10,10,10,11,11,11,11,11],
	"shoot":[12,12,12,12,13,13,13,13],
	"evade":[14,14,14,15,15,15]}
static var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cartoon/v042/art.json"))
static func ground_offset(_state: String,_frame: int) -> float:
	return 0.0 # Each key pose has its own measured ground anchor, without vertical bob.
static func frame_data(direction: String,state: String,frame: int) -> Dictionary:
	var row: Dictionary = manifest.hero["right" if direction=="left" else direction]
	return row.frames[POSES[state][posmod(frame,FRAMES[state])]]
static func hero_frame(node: CanvasItem,direction: String,state: String,frame: int,rect: Rect2,tint: Color=Color.WHITE) -> void:
	var key: String = "right" if direction=="left" else direction
	var family: Dictionary = manifest.hero[key]
	var data: Dictionary = frame_data(direction,state,frame)
	var region: Rect2 = Rect2(data.region[0],data.region[1],data.region[2],data.region[3])
	var factor: float = float(data.get("scale",family.scale))*rect.size.y/100.0
	var anchor: Vector2 = Vector2(data.anchor[0],data.anchor[1])
	var target: Rect2 = Rect2(-anchor*factor,region.size*factor)
	if state=="idle":
		var breath: float = 1.0+sin(posmod(frame,8)*TAU/8.0)*0.005
		target.position.y *= breath
		target.size.y *= breath
	if direction=="left":
		target.position.x = (anchor.x-region.size.x)*factor
		target.size.x *= -1
	node.draw_texture_rect_region(TEXTURES[data.get("texture",key)],target,region,tint)

static func hand_position(direction: String,state: String,frame: int) -> Vector2:
	var key: String = "right" if direction=="left" else direction
	var data: Dictionary = frame_data(direction,state,frame)
	var p: Vector2 = (Vector2(data.hand[0]-data.region[0],data.hand[1]-data.region[1])-Vector2(data.anchor[0],data.anchor[1]))*float(data.get("scale",manifest.hero[key].scale))
	if direction=="left": p.x *= -1
	return p

static func head_position(direction: String,state: String,frame: int) -> Vector2:
	var key: String = "right" if direction=="left" else direction
	var data: Dictionary = frame_data(direction,state,frame)
	var p: Vector2 = (Vector2(data.head[0]-data.region[0],data.head[1]-data.region[1])-Vector2(data.anchor[0],data.anchor[1]))*float(data.get("scale",manifest.hero[key].scale))
	if direction=="left": p.x *= -1
	return p

static func pull_hand_position(direction: String,frame: int) -> Vector2:
	var key: String = "right" if direction=="left" else direction
	var data: Dictionary = frame_data(direction,"shoot",frame)
	var p: Vector2 = (Vector2(data.pull_hand[0]-data.region[0],data.pull_hand[1]-data.region[1])-Vector2(data.anchor[0],data.anchor[1]))*float(data.get("scale",manifest.hero[key].scale))
	if direction=="left": p.x *= -1
	return p
