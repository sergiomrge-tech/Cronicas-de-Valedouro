extends SceneTree

const APPROVED_PATHS: Array[String] = [
	"res://assets/approved/city/floors/floor_stone_clean.png",
	"res://assets/approved/city/floors/floor_stone_worn.png",
	"res://assets/approved/city/floors/floor_stone_moss.png",
	"res://assets/approved/city/water/water_edge.png",
	"res://assets/approved/city/props/tree_green.png",
	"res://assets/approved/city/props/tree_autumn.png",
	"res://assets/approved/dungeon/floors/floor_stone.png",
	"res://assets/approved/dungeon/floors/floor_broken.png",
	"res://assets/approved/dungeon/walls/wall_straight.png",
	"res://assets/approved/dungeon/walls/corner_inside.png",
	"res://assets/approved/dungeon/walls/arch.png",
	"res://assets/approved/dungeon/walls/door.png",
	"res://assets/approved/dungeon/mine/rail_straight.png",
	"res://assets/approved/dungeon/natural/crystal_blue.png",
	"res://assets/approved/dungeon/natural/crystal_purple.png",
	"res://assets/approved/dungeon/lighting/torch.png",
	"res://assets/approved/dungeon/lighting/emissive_crystal.png",
	"res://assets/approved/dungeon/traps/spikes.png",
	"res://assets/approved/dungeon/tunnels/corridor_straight.png"
]

func _initialize() -> void:
	call_deferred("check")

func check() -> void:
	assert(APPROVED_PATHS.size() == 19)
	for path in APPROVED_PATHS:
		assert(ResourceLoader.exists(path), "APPROVED missing: %s" % path)
		var resource: Resource = load(path)
		assert(resource is Texture2D, "APPROVED invalid: %s" % path)
	print("APPROVED VISUALS PASS: 19/19 active legacy-approved assets loaded; retired architecture excluded")
	quit(0)
