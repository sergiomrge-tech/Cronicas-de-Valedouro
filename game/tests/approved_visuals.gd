extends SceneTree

const APPROVED_PATHS: Array[String] = [
	"res://assets/approved/city/floors/floor_stone_clean.png",
	"res://assets/approved/city/floors/floor_stone_worn.png",
	"res://assets/approved/city/floors/floor_stone_moss.png",
	"res://assets/approved/city/water/water_edge.png",
	"res://assets/approved/city/walls/wall_straight.png",
	"res://assets/approved/city/walls/wall_vegetation.png",
	"res://assets/approved/city/walls/gate_large.png",
	"res://assets/approved/city/buildings/house_door.png",
	"res://assets/approved/city/buildings/house_window.png",
	"res://assets/approved/city/buildings/roof_blue.png",
	"res://assets/approved/city/buildings/roof_red.png",
	"res://assets/approved/city/buildings/roof_wood.png",
	"res://assets/approved/city/special/store.png",
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
	assert(APPROVED_PATHS.size() == 28)
	for path in APPROVED_PATHS:
		assert(ResourceLoader.exists(path), "APPROVED missing: %s" % path)
		var resource: Resource = load(path)
		assert(resource is Texture2D, "APPROVED invalid: %s" % path)
	print("APPROVED VISUALS PASS: 28/28 assets loaded; REWORKED/HOLD not part of final set")
	quit(0)
