extends SceneTree

const Exploration = preload("res://scripts/cartoon/cartoon_exploration_director.gd")
const ForestScene = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var regions: Array[String] = [
		"REG_002_FLORESTA_ANCESTRAL",
		"REG_003_DESERTO_RUINAS",
		"REG_004_PANTANOS_SOMBRIOS",
		"REG_005_MONTANHAS_NEVADAS",
		"REG_006_COSTAS_ILHAS_PERDIDAS",
		"REG_007_TERRAS_CORROMPIDAS",
		"REG_008_CORACAO_ABISSAL"
	]
	var total_sites: int = 0
	var total_dungeons: int = 0
	var total_npcs: int = 0
	for region_id in regions:
		var base: Array[Dictionary] = Exploration.content_for(region_id)
		var advanced: Array[Dictionary] = Exploration.advanced_content_for(region_id)
		assert(base.size() == 5)
		assert(advanced.size() == 2)
		total_sites += base.size()+advanced.size()
		for site in advanced:
			if String(site.get("type","")) == "dungeon":
				total_dungeons += 1
				assert((site.get("mobs",[]) as Array).size() == 3)
			elif String(site.get("type","")) == "npc":
				total_npcs += 1
	assert(total_sites == 49)
	assert(total_dungeons == 7)
	assert(total_npcs == 7)

	var forest: Node = ForestScene.instantiate()
	root.add_child(forest)
	await process_frame
	await process_frame
	assert(forest.exploration_director.sites.size() == 7)
	assert(forest.exploration_director.site_nodes.size() == 7)
	forest.hero.position = Vector2(34400,33600)
	var before_materials: int = forest.exploration_director._material_total()
	assert(forest.exploration_director.try_interact())
	assert(forest.exploration_director._material_total() == before_materials+1)

	forest.hero.position = Vector2(9600,27300)
	var monster_before: int = forest.monsters.size()
	assert(forest.exploration_director.try_interact())
	assert(String(forest.exploration_director.dungeon_state.get("EXP_F02_DEEP_ROOT","")) == "active")
	assert(forest.monsters.size() == monster_before+3)

	for monster in forest.exploration_director.dungeon_mobs["EXP_F02_DEEP_ROOT"]:
		if is_instance_valid(monster):
			forest.monsters.erase(monster)
			monster.queue_free()
	await process_frame
	forest.exploration_director._process(0.0)
	assert(String(forest.exploration_director.dungeon_state.get("EXP_F02_DEEP_ROOT","")) == "cleared")
	var gold_before: int = forest.player_gold
	assert(forest.exploration_director.try_interact())
	assert(String(forest.exploration_director.dungeon_state.get("EXP_F02_DEEP_ROOT","")) == "claimed")
	assert(forest.player_gold > gold_before)
	assert(int(forest.exploration_director.materials.get("Seiva Ancestral",0)) >= 4)

	print("exploration_v013: PASS — 49 locais opcionais, 7 mini-dungeons, 7 NPCs e materiais de crafting")
	quit(0)
