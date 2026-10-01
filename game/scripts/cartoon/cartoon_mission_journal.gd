extends RefCounted
## Tracking changes presentation only. Story/reward authorities stay in their runtimes.
const Contracts = preload("res://scripts/cartoon/cartoon_guild_contracts.gd")
const HubRegion = preload("res://scripts/cartoon/cartoon_region_config.gd")

static var story_rows: Array = []
static func completed_story(host, state) -> Array[Dictionary]:
	if story_rows.is_empty():
		var file = FileAccess.open("res://data/main_story_v1.json",FileAccess.READ)
		story_rows = JSON.parse_string(file.get_as_text()).get("quests",[])
	var snapshots: Array = state.story_progress.values().duplicate(true)
	var current_snapshot: Dictionary = {}
	for property in host.story_runtime.get_property_list():
		var key: String = property.name
		if key in state.STORY_STATE_KEYS: current_snapshot[key] = host.story_runtime.get(key)
	snapshots.append(current_snapshot)
	var known: Dictionary = {}
	var flags = {1:"act1_complete",2:"act2_complete",3:"act3_complete",4:"act4_complete",5:"act5_region_complete",6:"act6_complete",7:"act7_complete",8:"campaign_complete"}
	for snapshot in snapshots:
		var current_index: int = -1
		var current_act: int = 0
		for i in range(story_rows.size()):
			if String(story_rows[i].id)==String(snapshot.get("current_id","")):
				current_index = i
				current_act = int(story_rows[i].act)
				break
		for i in range(story_rows.size()):
			var row: Dictionary = story_rows[i]
			var act: int = int(row.get("act",0))
			if snapshot.get(flags.get(act,""),false)==true or (act==current_act and i<current_index): known[row.id] = row
	var result: Array[Dictionary] = []
	for row in story_rows:
		if known.has(row.id): result.append({"id":"completed_"+String(row.id),"title":String(row.title),"description":String(row.objective),"category":"História • Ato %d" % int(row.act),"status":"claimed","reward":"Etapa concluída"})
	return result

static func entries(host, state, tab: String = "active") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var runtime = host.story_runtime
	var finished: bool = runtime.get("campaign_complete") == true
	if (tab=="active" and not finished) or (tab=="completed" and finished):
		result.append({"id":"main","title":runtime.title() if runtime.title()!="" else "História principal","description":runtime.objective(),"category":"História principal","status":"claimed" if finished else "active","reward":"Progresso da campanha"})
	for row in Contracts.ROWS:
		var status: String = Contracts.status(state,String(row.id))
		if (tab=="active" and status!="active") or (tab=="available" and status!="available") or (tab=="completed" and status!="claimed"): continue
		var item: Dictionary = row.duplicate(true)
		item.description = String(row.description)
		item.category = "Contrato da guilda"
		item.status = status
		item.reward = "%d ouro • %d XP" % [int(row.gold),int(row.xp)]
		if status=="active": item.description += "\nProgresso: %d/%d%s" % [Contracts.progress(state,row.id),int(row.count)," • Volte à guilda para receber" if Contracts.progress(state,row.id)>=int(row.count) else ""]
		result.append(item)
	if tab=="completed": result.append_array(completed_story(host,state))
	return result

static func guild_target(host) -> Dictionary:
	if host.crafting_ui.region_id==HubRegion.REGION_ID:
		for poi in host.environment.pois:
			if String(poi.get("id","")) in ["LOC_VAL_GUILD","POI_REG001_GUILD"]:
				return {"valid":true,"position":poi.pos,"hint":"Guilda • entre e use o quadro"}
	return {"valid":false,"position":Vector2.ZERO,"hint":"Volte à Guilda de Valedouro"}

static func target(host, state, id: String) -> Dictionary:
	var row: Dictionary = Contracts.row(id)
	if row.is_empty(): return {"valid":false,"position":Vector2.ZERO,"hint":""}
	if Contracts.progress(state,id)>=int(row.count): return guild_target(host)
	var kinds: Array = [String(row.get("kind","any"))]
	if row.has("material"): kinds = ["deer","boar"] if row.material=="Couro do Vale" else ["any"]
	var best: Vector2 = Vector2.ZERO
	var distance: float = INF
	var found: bool = false
	if kinds==["wolf"]:
		for monster in host.monsters:
			if not is_instance_valid(monster) or monster.is_queued_for_deletion() or monster.hp<=0 or monster.kind!="wolf" or monster.boss_id!="" or monster.story_tag=="story_wolf": continue
			if monster.position.distance_to(host.hero.position)<distance:
				best = monster.position
				distance = best.distance_to(host.hero.position)
				found = true
	else:
		var wildlife = host.get("wildlife")
		if wildlife != null:
			# Habitats also guide exploration outside the actor activation radius.
			var now: float = Time.get_unix_time_from_system()
			for slot in wildlife.slots:
				if "any" not in kinds and String(slot.kind) not in kinds: continue
				if float(state.wildlife_cooldowns.get(slot.id,0))>now: continue
				var position: Vector2 = slot.pos
				var animal = wildlife.active.get(slot.id)
				if is_instance_valid(animal):
					if animal.dead: continue
					position = animal.position
				if position.distance_to(host.hero.position)<distance:
					best = position
					distance = best.distance_to(host.hero.position)
					found = true
	return {"valid":found,"position":best,"hint":"Área de caça" if found else "Procure alvos em outra região ou aguarde o retorno da fauna"}
