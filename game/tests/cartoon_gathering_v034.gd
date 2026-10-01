extends SceneTree

const Hub = preload("res://scenes/cartoon/ValedouroCartoonHub.tscn")
const Forest = preload("res://scenes/cartoon/ForestAncientCartoon.tscn")
const Director = preload("res://scripts/cartoon/cartoon_exploration_director.gd")

const REGIONS: Array[String] = [
	"REG_001_BERCO_VALEDOURO",
	"REG_002_FLORESTA_ANCESTRAL",
	"REG_003_DESERTO_RUINAS",
	"REG_004_PANTANOS_SOMBRIOS",
	"REG_005_MONTANHAS_NEVADAS",
	"REG_006_COSTAS_ILHAS_PERDIDAS",
	"REG_007_TERRAS_CORROMPIDAS",
	"REG_008_CORACAO_ABISSAL"
]

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	for i in range(8):
		await process_frame

func run() -> void:
	var state = root.get_node("CartoonPlayerState")
	state.reset_progress(true)
	state.start_new_game()
	assert(state.SAVE_VERSION == 8)
	assert(state.gathering_cooldowns.is_empty())

	var ids: Dictionary = {}
	var total_nodes: int = 0
	for region_id in REGIONS:
		var rows: Array[Dictionary] = Director.gathering_sites_for(region_id)
		assert(rows.size() == 6,"Expected six gathering nodes in "+region_id)
		total_nodes += rows.size()
		for row in rows:
			assert(String(row.get("type","")) == "resource")
			assert(String(row.get("material","")) != "")
			assert(int(row.get("amount",0)) >= 1)
			assert(float(row.get("respawn",0)) == Director.GATHER_RESPAWN_SECONDS or region_id == REGIONS[0])
			var id: String = String(row.get("id",""))
			assert(id != "" and not ids.has(id),"Duplicate gathering id: "+id)
			ids[id] = true
	assert(total_nodes == 48)

	root.size = Vector2i(640,360)
	root.content_scale_size = root.size
	var hub = Hub.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	hub.set_process(false)
	hub.hero.set_process(false)
	if hub.wildlife != null:
		hub.wildlife.set_process(false)

	assert(hub.exploration_director != null)
	var hub_site: Dictionary = Director.gathering_sites_for(REGIONS[0])[0]
	var hub_id: String = String(hub_site.id)
	var hub_material: String = String(hub_site.material)
	hub.hero.position = hub_site.pos
	await settle()
	assert(hub.exploration_director.hint_text(220).contains("COLETAR"))
	var before: int = state.material_count(hub_material)
	assert(hub.exploration_director.try_interact(220))
	assert(state.material_count(hub_material) == before+int(hub_site.amount))
	assert(float(state.gathering_cooldowns.get(hub_id,0)) > Time.get_unix_time_from_system())
	assert(not hub.exploration_director.try_interact(220),"Gathering node ignored cooldown")
	assert(not hub.exploration_director.site_nodes[hub_id].visible)

	var saved_until: float = float(state.gathering_cooldowns[hub_id])
	state.save_profile()
	state.gathering_cooldowns.clear()
	state.load_profile()
	assert(is_equal_approx(float(state.gathering_cooldowns.get(hub_id,0)),saved_until))

	state.gathering_cooldowns[hub_id] = 0.0
	state.save_profile()
	hub.exploration_director._sync_resource_nodes()
	assert(hub.exploration_director.site_nodes[hub_id].visible)
	assert(hub.exploration_director.try_interact(220))
	assert(state.material_count(hub_material) == before+int(hub_site.amount)*2)

	hub.queue_free()
	await settle()

	var forest = Forest.instantiate()
	root.add_child(forest)
	current_scene = forest
	await settle()
	forest.set_process(false)
	forest.hero.set_process(false)
	if forest.wildlife != null:
		forest.wildlife.set_process(false)

	var forest_site: Dictionary = Director.gathering_sites_for(REGIONS[1])[0]
	forest.hero.position = forest_site.pos
	await settle()
	var seiva_before: int = state.material_count("Seiva Ancestral")
	assert(forest.exploration_director.hint_text(220).contains("COLETAR"))
	assert(forest.exploration_director.try_interact(220))
	assert(state.material_count("Seiva Ancestral") == seiva_before+1)
	assert(not forest.exploration_director.site_nodes[String(forest_site.id)].visible)

	forest.queue_free()
	await settle()
	state.reset_progress(true)
	print("cartoon_gathering_v034: PASS — 48 resource nodes, map interaction, save v8 cooldown, respawn and regional materials")
	quit(0)
