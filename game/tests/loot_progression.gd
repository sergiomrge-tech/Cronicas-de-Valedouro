extends SceneTree
const LOOT = preload("res://scripts/loot_system.gd")
const WORLD = preload("res://scripts/world_map.gd")
func _initialize() -> void:
	call_deferred("check")
func check() -> void:
	if FileAccess.file_exists("user://valedouro_v1.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://valedouro_v1.json"))
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = 92813
	var equipment_count: int = 0
	var material_count: int = 0
	for i in 50000:
		var roll: Dictionary = LOOT.roll("Lobo", random)
		if not (roll["item"] as Dictionary).is_empty():
			equipment_count += 1
			assert(roll["item"]["tier"] == 1)
		if roll["material"] != "": material_count += 1
	assert(equipment_count > 500 and equipment_count < 800)
	assert(material_count > 18500 and material_count < 19500)
	var game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.change_zone("floresta", Vector2(1000, 760))
	assert(game.walkable(Vector2(700, 610)))
	assert(not game.walkable(Vector2(166, 178)))
	game.change_zone("cidade", WORLD.TOWN + Vector2(884, 696))
	game.player = Vector2(2740, 1800)
	game.spawn_enemy()
	assert(game.enemies.size() > 0 and game.enemies[0]["kind"] == "Escorpião")
	var item: Dictionary = {"name":"Armadura de Bronze", "kind":"armor", "tier":2, "req":6, "chapter":3, "def":4}
	game.stored_items.append(item)
	game.level = 5
	game.quest = 2
	game.equip_item(0)
	assert(game.equipped_armor["tier"] == 0)
	game.level = 6
	game.quest = 3
	game.equip_item(0)
	assert(game.equipped_armor["tier"] == 2)
	assert(game.textures.has("equip_armor_2"))
	game.save_game()
	game.equipped_armor = {}
	game.load_game()
	assert(game.equipped_armor["tier"] == 2)
	game.quest = 1
	game.level = 8
	game.gain_xp(5000)
	assert(game.level == 8)
	game.quest = 3
	game.gain_xp(5000)
	assert(game.level == 16)
	print("LOOT PASS: 1.3% drop, material, tiers, mapa livre, mob regional, requisito, visual, teto e save")
	quit()
