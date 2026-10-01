extends RefCounted
## Optional proposed contracts. No main-story IDs or state are modified.
const MAX_ACTIVE: int = 3
const ROWS: Array[Dictionary] = [
	{"id":"GUILD_RABBITS","title":"Provisões para a estrada","description":"Cace 3 coelhos nos Campos do Vale. Aceite antes de caçar.","kind":"rabbit","count":3,"gold":25,"xp":20},
	{"id":"GUILD_DEER","title":"Rastros no bosque","description":"Cace 2 cervos nas clareiras fora da cidade.","kind":"deer","count":2,"gold":40,"xp":30},
	{"id":"GUILD_BOARS","title":"Javalis nas lavouras","description":"Cace 3 javalis nos campos ao sul. Eles se defendem quando atacados.","kind":"boar","count":3,"gold":55,"xp":40},
	{"id":"GUILD_VARIETY","title":"Expedição de caça","description":"Cace 6 animais de qualquer espécie, em qualquer região habitada.","kind":"any","count":6,"gold":65,"xp":45},
	{"id":"GUILD_MEAT","title":"Despensa da taverna","description":"Entregue 5 Carnes de caça. Os materiais serão consumidos.","material":"Carne de caça","count":5,"gold":30,"xp":25},
	{"id":"GUILD_WOLVES","title":"Lobos nos Campos do Vale","description":"Afaste 3 lobos comuns dos campos. Os alvos da história não contam.","kind":"wolf","count":3,"gold":30,"xp":25},
	{"id":"GUILD_LEATHER","title":"Couro para a oficina","description":"Entregue 4 Couros do Vale. Os materiais serão consumidos.","material":"Couro do Vale","count":4,"gold":45,"xp":35}
]
static func row(id: String) -> Dictionary:
	for item in ROWS:
		if item.id == id: return item
	return {}
static func status(state, id: String) -> String:
	return String(state.guild_contracts.get(id,{}).get("status","available"))
static func progress(state, id: String) -> int:
	var item: Dictionary = row(id)
	if item.has("material"): return mini(int(item.count),state.material_count(String(item.material)))
	return mini(int(item.get("count",0)),int(state.guild_contracts.get(id,{}).get("progress",0)))
static func accept(state, id: String) -> bool:
	if row(id).is_empty() or status(state,id) != "available": return false
	var active: int = 0
	for value in state.guild_contracts.values():
		if value.get("status","") == "active": active += 1
	if active >= MAX_ACTIVE: return false
	state.guild_contracts[id] = {"status":"active","progress":0}
	state.save_profile()
	return true
static func register_hunt(state, kind: String) -> void:
	for item in ROWS:
		if status(state,item.id) != "active" or not item.has("kind"): continue
		if item.kind == kind or item.kind == "any":
			state.guild_contracts[item.id]["progress"] = mini(int(item.count),progress(state,item.id)+1)
static func claim(state, host, id: String) -> bool:
	var item: Dictionary = row(id)
	if item.is_empty() or status(state,id) != "active" or progress(state,id) < int(item.count): return false
	# Mark consumed/claimed before any reward method can autosave.
	state.guild_contracts[id]["status"] = "claimed"
	if item.has("material"):
		state.materials[item.material] = state.material_count(item.material)-int(item.count)
	if id == "GUILD_WOLVES" and host.get("field_quest_active") != null: host.field_quest_active = false
	host.player_gold += int(item.gold)
	state.gain_xp(int(item.xp))
	host._refresh_stats()
	state.save_profile()
	return true
