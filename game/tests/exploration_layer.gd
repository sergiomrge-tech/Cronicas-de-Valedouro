extends SceneTree

const Exploration = preload("res://scripts/cartoon/cartoon_exploration_director.gd")
const ForestScene = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var region_ids: Array[String] = [
		"REG_002_FLORESTA_ANCESTRAL",
		"REG_003_DESERTO_RUINAS",
		"REG_004_PANTANOS_SOMBRIOS",
		"REG_005_MONTANHAS_NEVADAS",
		"REG_006_COSTAS_ILHAS_PERDIDAS",
		"REG_007_TERRAS_CORROMPIDAS",
		"REG_008_CORACAO_ABISSAL"
	]
	var ids: Dictionary = {}
	var site_total: int = 0
	for region_id in region_ids:
		var sites: Array[Dictionary] = Exploration.content_for(region_id)
		var elites: Array[Dictionary] = Exploration.elites_for(region_id)
		assert(sites.size() == 5)
		assert(elites.size() == 1)
		site_total += sites.size()
		for site in sites:
			var id: String = String(site.get("id",""))
			assert(id != "")
			assert(not ids.has(id))
			ids[id] = true
			assert((site.get("pos",Vector2.ZERO) as Vector2) != Vector2.ZERO)
	assert(site_total == 35)

	var forest: Node = ForestScene.instantiate()
	root.add_child(forest)
	await process_frame
	await process_frame
	assert(forest.exploration_director != null)
	assert(forest.exploration_director.sites.size() == 5)
	assert(forest.exploration_director.site_nodes.size() == 5)
	assert(forest.exploration_director.elite_count == 1)

	forest.player_hp = 50
	forest.hero.position = Vector2(18800,40700)
	assert(forest.exploration_director.hint_text() != "")
	assert(forest.exploration_director.try_interact())
	assert(forest.player_hp > 50)

	var gold_before: int = forest.player_gold
	forest.hero.position = Vector2(27800,38200)
	assert(forest.exploration_director.try_interact())
	assert(forest.player_gold > gold_before)
	assert(forest.exploration_director.collected.size() == 2)

	print("exploration_layer: PASS — 35 locais de exploração, 7 elites e recompensas interativas")
	quit(0)
