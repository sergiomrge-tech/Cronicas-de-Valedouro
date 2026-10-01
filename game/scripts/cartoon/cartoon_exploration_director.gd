class_name ValedouroCartoonExplorationDirector
extends Node

const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")
const MonsterScript = preload("res://scripts/cartoon/cartoon_monster.gd")
const GATHER_RESPAWN_SECONDS: float = 300.0

var host
var objects: Node2D
var hero: Node2D
var region_id: String = ""
var sites: Array[Dictionary] = []
var collected: Dictionary = {}
var site_nodes: Dictionary = {}
var elite_count: int = 0
var materials: Dictionary = {}
var dungeon_state: Dictionary = {}
var dungeon_mobs: Dictionary = {}
var resource_sync_elapsed: float = 0.0

func setup(host_node, objects_node: Node2D, hero_node: Node2D, target_region_id: String) -> void:
	host = host_node
	objects = objects_node
	hero = hero_node
	region_id = target_region_id
	var state = _state()
	if state != null:
		materials = state.materials
	sites = content_for(region_id)
	sites.append_array(advanced_content_for(region_id))
	sites.append_array(gathering_sites_for(region_id))
	for site in sites:
		_spawn_site(site)
	for elite in elites_for(region_id):
		if host != null and host.has_method("_spawn_monster"):
			host.call("_spawn_monster",elite)
			elite_count += 1
	_sync_resource_nodes()

func _process(_delta: float) -> void:
	resource_sync_elapsed += _delta
	if resource_sync_elapsed >= 1.0:
		resource_sync_elapsed = 0.0
		_sync_resource_nodes()
	for id in dungeon_mobs.keys():
		if String(dungeon_state.get(id,"")) != "active":
			continue
		var alive: Array = []
		for monster in dungeon_mobs[id]:
			if is_instance_valid(monster):
				alive.append(monster)
		dungeon_mobs[id] = alive
		if alive.is_empty():
			dungeon_state[id] = "cleared"
			if host != null and host.has_method("_show_toast"):
				host.call("_show_toast","Mini-dungeon limpa. Volte à entrada para recolher a recompensa.")

func _spawn_site(site: Dictionary) -> void:
	if objects == null:
		return
	var prop: Node2D = PropScript.new()
	prop.name = "Explore_"+String(site.get("id","SITE"))
	prop.setup({
		"id":String(site.get("id","")),
		"label":String(site.get("label","")),
		"kind":String(site.get("prop","chest")),
		"pos":site.get("pos",Vector2.ZERO),
		"scale":float(site.get("scale",1.0)),
		"variant":int(site.get("variant",0))
	})
	objects.add_child(prop)
	site_nodes[String(site.get("id",""))] = prop

func hint_text(radius: float = 190.0) -> String:
	var site: Dictionary = _nearest_site(radius)
	if site.is_empty():
		return ""
	var action: String = "COLETAR" if String(site.get("type","")) == "resource" else "EXPLORAR"
	return "✦ %s  •  %s" % [String(site.get("label","Segredo")),action]

func try_interact(radius: float = 195.0) -> bool:
	var site: Dictionary = _nearest_site(radius)
	if site.is_empty():
		return false
	var id: String = String(site.get("id",""))
	var site_type: String = String(site.get("type","treasure"))
	if site_type == "dungeon":
		return _interact_dungeon(site)
	if site_type == "resource":
		if not _resource_ready(id):
			return false
	else:
		if collected.has(id):
			return false
		collected[id] = true
	var reward: int = int(site.get("reward",0))
	var message: String = String(site.get("text",String(site.get("label","Local descoberto"))))
	match site_type:
		"camp":
			var max_hp: int = int(host.get("player_max_hp"))
			var hp: int = int(host.get("player_hp"))
			var restored: int = maxi(1,int(round(float(max_hp)*0.35)))
			host.set("player_hp",mini(max_hp,hp+restored))
			message = "%s — descanso recuperou %d de vida." % [message,restored]
		"lore":
			if reward > 0:
				_add_gold(reward)
				message += "  +%d ouro antigo." % reward
		"resource":
			var material_name: String = String(site.get("material",_default_material()))
			var amount: int = maxi(1,int(site.get("amount",1)))
			_add_material(material_name,amount)
			_add_gold(reward)
			message = "Coletado: +%d %s." % [amount,material_name]
			if reward > 0:
				message += " +%d ouro." % reward
			_start_resource_cooldown(id,float(site.get("respawn",GATHER_RESPAWN_SECONDS)))
		"npc":
			var material_name: String = String(site.get("material",_default_material()))
			var amount: int = maxi(1,int(site.get("amount",1)))
			_add_material(material_name,amount)
			message += "  Recebeu %d %s." % [amount,material_name]
		"secret":
			_add_gold(reward)
			message += "  Tesouro secreto: +%d ouro." % reward
			_fade_site(id)
		_:
			_add_gold(reward)
			message += "  +%d ouro." % reward
			_fade_site(id)
	if host.has_method("_refresh_stats"):
		host.call("_refresh_stats")
	if host.has_method("_show_toast"):
		host.call("_show_toast",message)
	return true

func _interact_dungeon(site: Dictionary) -> bool:
	var id: String = String(site.get("id",""))
	var state: String = String(dungeon_state.get(id,"new"))
	if state == "new":
		dungeon_state[id] = "active"
		dungeon_mobs[id] = []
		var center: Vector2 = site.get("pos",Vector2.ZERO)
		var rows: Array = site.get("mobs",[])
		for i in range(rows.size()):
			var data: Dictionary = (rows[i] as Dictionary).duplicate(true)
			var offset: Vector2 = data.get("offset",Vector2.ZERO)
			data.erase("offset")
			data["pos"] = center+offset
			data["story_tag"] = "exploration_dungeon_"+id
			if host != null and host.has_method("_spawn_monster"):
				host.call("_spawn_monster",data)
				var list: Array = host.get("monsters")
				if not list.is_empty():
					(dungeon_mobs[id] as Array).append(list[list.size()-1])
		if host.has_method("_show_toast"):
			host.call("_show_toast",String(site.get("start_text","A mini-dungeon despertou. Derrote os guardiões.")))
		return true
	if state == "active":
		if host.has_method("_show_toast"):
			host.call("_show_toast","Ainda há inimigos protegendo este local.")
		return true
	if state == "cleared":
		dungeon_state[id] = "claimed"
		collected[id] = true
		var reward: int = int(site.get("reward",60))
		var material_name: String = String(site.get("material",_default_material()))
		var amount: int = maxi(1,int(site.get("amount",2)))
		_add_gold(reward)
		_add_material(material_name,amount)
		_fade_site(id)
		if host.has_method("_refresh_stats"):
			host.call("_refresh_stats")
		if host.has_method("_show_toast"):
			host.call("_show_toast","Mini-dungeon concluída: +%d ouro e %d %s." % [reward,amount,material_name])
		return true
	return false

func _state():
	return get_node_or_null("/root/CartoonPlayerState")

func _resource_ready(id: String) -> bool:
	var state = _state()
	if state == null:
		return true
	return float(state.gathering_cooldowns.get(id,0.0)) <= Time.get_unix_time_from_system()

func _start_resource_cooldown(id: String,seconds: float) -> void:
	var state = _state()
	if state != null:
		state.gathering_cooldowns[id] = Time.get_unix_time_from_system()+maxf(1.0,seconds)
		state.save_profile()
	_sync_resource_node(id)

func _sync_resource_nodes() -> void:
	for site in sites:
		if String(site.get("type","")) != "resource":
			continue
		_sync_resource_node(String(site.get("id","")))

func _sync_resource_node(id: String) -> void:
	if not site_nodes.has(id):
		return
	var node = site_nodes[id]
	if not is_instance_valid(node):
		return
	var ready: bool = _resource_ready(id)
	node.visible = ready
	node.modulate = Color.WHITE if ready else Color(0.45,0.45,0.45,0.18)

func _add_material(material_name: String, amount: int) -> void:
	if material_name == "" or amount <= 0:
		return
	var state = _state()
	if state != null:
		state.add_material(material_name,amount)
		materials = state.materials
	else:
		materials[material_name] = int(materials.get(material_name,0))+amount

func _default_material() -> String:
	match region_id:
		"REG_002_FLORESTA_ANCESTRAL": return "Seiva Ancestral"
		"REG_003_DESERTO_RUINAS": return "Âmbar Negro"
		"REG_004_PANTANOS_SOMBRIOS": return "Fibra de Junco"
		"REG_005_MONTANHAS_NEVADAS": return "Cristal de Geada"
		"REG_006_COSTAS_ILHAS_PERDIDAS": return "Coral Luminoso"
		"REG_007_TERRAS_CORROMPIDAS": return "Fragmento de Obelisco"
		"REG_008_CORACAO_ABISSAL": return "Fragmento do Último Mapa"
		_: return "Essência de Eco"

func _add_gold(amount: int) -> void:
	if host == null or amount <= 0:
		return
	host.set("player_gold",int(host.get("player_gold"))+amount)

func _fade_site(id: String) -> void:
	if not site_nodes.has(id):
		return
	var node = site_nodes[id]
	if is_instance_valid(node):
		node.modulate = Color(0.56,0.56,0.56,0.52)

func _nearest_site(radius: float) -> Dictionary:
	if hero == null:
		return {}
	var best: Dictionary = {}
	var best_d: float = radius
	for site in sites:
		var id: String = String(site.get("id",""))
		var site_type: String = String(site.get("type",""))
		if site_type == "resource":
			if not _resource_ready(id):
				continue
		elif collected.has(id):
			continue
		var pos: Vector2 = site.get("pos",Vector2.ZERO)
		var d: float = hero.position.distance_to(pos)
		if d < best_d:
			best_d = d
			best = site
	return best

func progress_text() -> String:
	var permanent_total: int = 0
	for site in sites:
		if String(site.get("type","")) != "resource":
			permanent_total += 1
	return "%d/%d locais • %d materiais" % [collected.size(),permanent_total,_material_total()]

func _material_total() -> int:
	var state = _state()
	if state != null:
		materials = state.materials
	var total: int = 0
	for value in materials.values():
		total += int(value)
	return total

static func gathering_sites_for(target_region_id: String) -> Array[Dictionary]:
	match target_region_id:
		"REG_001_BERCO_VALEDOURO":
			return [
				{"id":"GAT_V01_BONE_A","label":"Restos de Caça","type":"resource","prop":"rock","pos":Vector2(7700,10600),"material":"Osso de caça","amount":1,"scale":0.82},
				{"id":"GAT_V01_HIDE_A","label":"Armadilha Abandonada","type":"resource","prop":"chest","pos":Vector2(8460,11480),"material":"Couro do Vale","amount":1,"scale":0.78},
				{"id":"GAT_V01_BONE_B","label":"Ossada do Vale","type":"resource","prop":"rock","pos":Vector2(6740,12480),"material":"Osso de caça","amount":1,"scale":0.88},
				{"id":"GAT_V01_HIDE_B","label":"Pele Curtida Esquecida","type":"resource","prop":"chest","pos":Vector2(9460,13350),"material":"Couro do Vale","amount":1,"scale":0.80},
				{"id":"GAT_V01_BONE_C","label":"Restos do Acampamento","type":"resource","prop":"rock","pos":Vector2(5900,14500),"material":"Osso de caça","amount":2,"scale":0.92},
				{"id":"GAT_V01_HIDE_C","label":"Reserva dos Caçadores","type":"resource","prop":"chest","pos":Vector2(10350,15100),"material":"Couro do Vale","amount":2,"scale":0.84}
			]
		"REG_002_FLORESTA_ANCESTRAL":
			return _gather_rows("F02","Seiva Ancestral","Seiva Antiga","bush",[
				Vector2(29600,25200),Vector2(31800,27800),Vector2(26200,33000),
				Vector2(21400,36100),Vector2(14500,28600),Vector2(33800,22800)
			])
		"REG_003_DESERTO_RUINAS":
			return _gather_rows("D03","Âmbar Negro","Veio de Âmbar","mine",[
				Vector2(21800,15800),Vector2(24600,18100),Vector2(18800,24400),
				Vector2(13100,27100),Vector2(28400,13700),Vector2(8200,22400)
			])
		"REG_004_PANTANOS_SOMBRIOS":
			return _gather_rows("M04","Fibra de Junco","Junco de Eco","bush",[
				Vector2(11900,13700),Vector2(14500,16200),Vector2(19200,22800),
				Vector2(25800,26400),Vector2(8600,19800),Vector2(30200,17800)
			])
		"REG_005_MONTANHAS_NEVADAS":
			return _gather_rows("I05","Cristal de Geada","Cristal de Geada","rock",[
				Vector2(21100,14300),Vector2(23500,16700),Vector2(17400,21800),
				Vector2(11500,26300),Vector2(27400,19700),Vector2(30600,11200)
			])
		"REG_006_COSTAS_ILHAS_PERDIDAS":
			return _gather_rows("C06","Coral Luminoso","Coral Luminoso","flowers",[
				Vector2(27600,22600),Vector2(30200,24900),Vector2(22400,30900),
				Vector2(16700,34700),Vector2(33300,19100),Vector2(11600,28600)
			])
		"REG_007_TERRAS_CORROMPIDAS":
			return _gather_rows("W07","Fragmento de Obelisco","Estilhaço de Obelisco","rock",[
				Vector2(27200,20900),Vector2(29600,23300),Vector2(23100,28100),
				Vector2(16400,33800),Vector2(32900,17800),Vector2(10900,29400)
			])
		"REG_008_CORACAO_ABISSAL":
			return _gather_rows("A08","Fragmento do Último Mapa","Fragmento Instável","rock",[
				Vector2(11200,6500),Vector2(12600,8300),Vector2(9700,10800),
				Vector2(6500,12100),Vector2(8400,7300),Vector2(12300,12100)
			])
		_:
			return []

static func _gather_rows(prefix: String,material: String,label: String,prop: String,positions: Array) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for i in range(positions.size()):
		rows.append({
			"id":"GAT_%s_%02d" % [prefix,i+1],
			"label":label,
			"type":"resource",
			"prop":prop,
			"pos":positions[i],
			"material":material,
			"amount":2 if i == positions.size()-1 else 1,
			"scale":1.15 if i == positions.size()-1 else 0.95,
			"respawn":GATHER_RESPAWN_SECONDS
		})
	return rows

static func content_for(target_region_id: String) -> Array[Dictionary]:
	match target_region_id:
		"REG_002_FLORESTA_ANCESTRAL":
			return [
				{"id":"EXP_F02_CAMP","label":"Acampamento dos Batedores","type":"camp","prop":"campfire","pos":Vector2(18800,40700),"scale":1.05,"text":"Uma patrulha dos Guardas Verdes deixou abrigo e ervas."},
				{"id":"EXP_F02_CACHE","label":"Baú sob as Raízes","type":"secret","prop":"chest","pos":Vector2(27800,38200),"scale":0.95,"reward":24,"text":"Raízes antigas escondiam um pequeno cofre."},
				{"id":"EXP_F02_STONE","label":"Pedra do Primeiro Juramento","type":"lore","prop":"shrine","pos":Vector2(15900,31800),"scale":0.90,"reward":8,"text":"O juramento dos primeiros Guardas Verdes ainda está gravado aqui."},
				{"id":"EXP_F02_HERBS","label":"Clareira de Ervas Azuis","type":"resource","prop":"flowers","pos":Vector2(30900,26300),"scale":1.30,"reward":18,"text":"Ervas raras crescem onde a luz atravessa a copa."},
				{"id":"EXP_F02_RUIN","label":"Ruína do Caçador Sem Nome","type":"secret","prop":"ruin","pos":Vector2(13200,21600),"scale":1.05,"reward":32,"text":"Uma ruína esquecida guarda moedas e um mapa rasgado."}
			]
		"REG_003_DESERTO_RUINAS":
			return [
				{"id":"EXP_D03_CAMP","label":"Fogueira da Rota Âmbar","type":"camp","prop":"campfire","pos":Vector2(6200,28700),"scale":1.0,"text":"Mercadores abandonaram água e mantimentos."},
				{"id":"EXP_D03_CACHE","label":"Cofre Soterrado","type":"secret","prop":"chest","pos":Vector2(11800,25800),"scale":0.95,"reward":34,"text":"A areia cede e revela um cofre antigo."},
				{"id":"EXP_D03_TABLET","label":"Estela do Sol Partido","type":"lore","prop":"shrine","pos":Vector2(17600,22000),"scale":0.95,"reward":10,"text":"A estela narra a queda dos primeiros reis de Edravar."},
				{"id":"EXP_D03_ORE","label":"Veio de Âmbar Negro","type":"resource","prop":"mine","pos":Vector2(23100,16600),"scale":0.86,"reward":28,"text":"Um veio mineral raro aflora entre as ruínas."},
				{"id":"EXP_D03_RUIN","label":"Torre Sepultada","type":"secret","prop":"ruin","pos":Vector2(28600,11200),"scale":1.10,"reward":42,"text":"A torre soterrada preservou suprimentos da resistência."}
			]
		"REG_004_PANTANOS_SOMBRIOS":
			return [
				{"id":"EXP_M04_CAMP","label":"Abrigo de Lanternas","type":"camp","prop":"campfire","pos":Vector2(28100,30000),"scale":1.0,"text":"Uma plataforma seca oferece alguns minutos de segurança."},
				{"id":"EXP_M04_CACHE","label":"Baú Preso nos Juncos","type":"secret","prop":"chest","pos":Vector2(24400,23500),"scale":0.92,"reward":38,"text":"Os juncos escondiam um baú coberto de lodo."},
				{"id":"EXP_M04_BELL","label":"Marco dos Afogados","type":"lore","prop":"shrine","pos":Vector2(18300,19900),"scale":0.94,"reward":12,"text":"Nomes riscados na pedra lembram os desaparecidos do brejo."},
				{"id":"EXP_M04_REED","label":"Juncos de Eco Puro","type":"resource","prop":"bush","pos":Vector2(12600,14500),"scale":1.22,"reward":30,"text":"Alguns juncos ainda não foram tocados pela corrupção."},
				{"id":"EXP_M04_RUIN","label":"Capela Submersa","type":"secret","prop":"ruin","pos":Vector2(6400,8600),"scale":1.06,"reward":48,"text":"Sob a água rasa, uma antiga capela guarda oferendas."}
			]
		"REG_005_MONTANHAS_NEVADAS":
			return [
				{"id":"EXP_I05_CAMP","label":"Refúgio dos Caçadores","type":"camp","prop":"campfire","pos":Vector2(6900,29400),"scale":1.0,"text":"Peles e brasas protegem do vento cortante."},
				{"id":"EXP_I05_CACHE","label":"Trenó de Suprimentos","type":"secret","prop":"chest","pos":Vector2(12300,24600),"scale":0.95,"reward":44,"text":"Um trenó desaparecido ainda carrega suprimentos."},
				{"id":"EXP_I05_MARK","label":"Memorial da Expedição","type":"lore","prop":"shrine","pos":Vector2(16700,20200),"scale":0.95,"reward":14,"text":"Placas congeladas registram os nomes da expedição perdida."},
				{"id":"EXP_I05_CRYSTAL","label":"Cristais de Geada","type":"resource","prop":"rock","pos":Vector2(22200,15100),"scale":1.30,"reward":36,"text":"Cristais azuis concentram energia de Eco gelado."},
				{"id":"EXP_I05_WATCH","label":"Torre da Vigília Branca","type":"secret","prop":"ruin","pos":Vector2(28900,7800),"scale":1.10,"reward":54,"text":"A torre abandonada ainda guarda o pagamento da antiga guarnição."}
			]
		"REG_006_COSTAS_ILHAS_PERDIDAS":
			return [
				{"id":"EXP_C06_CAMP","label":"Fogueira dos Náufragos","type":"camp","prop":"campfire","pos":Vector2(8300,39400),"scale":1.0,"text":"Náufragos deixaram mantimentos protegidos da maré."},
				{"id":"EXP_C06_CACHE","label":"Carga de Contrabandistas","type":"secret","prop":"chest","pos":Vector2(15800,33400),"scale":0.95,"reward":52,"text":"Uma enseada escondida abriga carga esquecida."},
				{"id":"EXP_C06_TABLET","label":"Pedra das Sete Marés","type":"lore","prop":"shrine","pos":Vector2(21300,30100),"scale":0.96,"reward":16,"text":"A pedra descreve correntes que já não existem."},
				{"id":"EXP_C06_CORAL","label":"Banco de Coral Luminoso","type":"resource","prop":"flowers","pos":Vector2(28600,23500),"scale":1.35,"reward":40,"text":"Corais brilhantes podem ser trocados no Porto das Brumas."},
				{"id":"EXP_C06_WRECK","label":"Naufrágio do Almirante","type":"secret","prop":"ruin","pos":Vector2(36100,14700),"scale":1.15,"reward":62,"text":"O casco partido esconde o cofre do antigo almirante."}
			]
		"REG_007_TERRAS_CORROMPIDAS":
			return [
				{"id":"EXP_W07_CAMP","label":"Posto Avançado da Aliança","type":"camp","prop":"campfire","pos":Vector2(8000,39600),"scale":1.0,"text":"Curandeiros da Aliança mantêm este posto entre as frentes."},
				{"id":"EXP_W07_CACHE","label":"Depósito Perdido","type":"secret","prop":"chest","pos":Vector2(13200,35000),"scale":0.95,"reward":60,"text":"Uma trincheira desabada esconde provisões."},
				{"id":"EXP_W07_LORE","label":"Memorial das Seis Coroas","type":"lore","prop":"shrine","pos":Vector2(20600,28800),"scale":0.98,"reward":18,"text":"Seis brasões gravados registram a última aliança de Elyndor."},
				{"id":"EXP_W07_SHARD","label":"Fragmento de Obelisco","type":"resource","prop":"rock","pos":Vector2(28300,21800),"scale":1.38,"reward":48,"text":"Um fragmento ainda pulsa com energia demoníaca residual."},
				{"id":"EXP_W07_SECRET","label":"Bunker dos Cartógrafos","type":"secret","prop":"ruin","pos":Vector2(35400,14200),"scale":1.12,"reward":72,"text":"Mapas de guerra e reservas de ouro sobreviveram ao cerco."}
			]
		"REG_008_CORACAO_ABISSAL":
			return [
				{"id":"EXP_A08_CAMP","label":"Fogueira Impossível","type":"camp","prop":"campfire","pos":Vector2(7700,15900),"scale":0.92,"text":"Uma chama sem combustível aquece como uma lembrança."},
				{"id":"EXP_A08_MEMORY","label":"Memória de Valedouro","type":"lore","prop":"shrine","pos":Vector2(10900,13200),"scale":0.90,"reward":20,"text":"A cidade aparece por um instante, intacta e silenciosa."},
				{"id":"EXP_A08_CACHE","label":"Cofre de uma Vida Não Vivida","type":"secret","prop":"chest","pos":Vector2(5200,9600),"scale":0.92,"reward":80,"text":"O cofre contém moedas de uma história que nunca aconteceu."},
				{"id":"EXP_A08_SHARD","label":"Fragmento do Último Mapa","type":"resource","prop":"rock","pos":Vector2(11900,7100),"scale":1.18,"reward":56,"text":"Um fragmento do mapa pulsa entre dois mundos."},
				{"id":"EXP_A08_SECRET","label":"Sala que Não Devia Existir","type":"secret","prop":"ruin","pos":Vector2(6900,5100),"scale":0.95,"reward":90,"text":"Uma sala lateral preserva tesouros de caminhos apagados."}
			]
		_:
			return []

static func advanced_content_for(target_region_id: String) -> Array[Dictionary]:
	match target_region_id:
		"REG_002_FLORESTA_ANCESTRAL":
			return [
				{"id":"EXP_F02_TRAVELER","label":"Herbalista Elyn","type":"npc","prop":"traveler","pos":Vector2(34400,33600),"scale":1.0,"material":"Seiva Ancestral","amount":1,"text":"Elyn troca histórias por um frasco de seiva antiga."},
				{"id":"EXP_F02_DEEP_ROOT","label":"Gruta das Raízes Profundas","type":"dungeon","prop":"cave_entrance","pos":Vector2(9600,27300),"scale":1.15,"reward":70,"material":"Seiva Ancestral","amount":3,"start_text":"As raízes se fecham atrás de você. Algo se move na escuridão.","mobs":[
					{"kind":"wolf","name":"Lobo de Raiz","offset":Vector2(-85,-30),"hp":125,"speed":105.0,"damage":18,"scale":1.22},
					{"kind":"goblin","name":"Saqueador Musgoso","offset":Vector2(75,-40),"hp":118,"speed":88.0,"damage":17,"scale":1.18},
					{"kind":"guardian","name":"Guardião da Raiz Profunda","offset":Vector2(0,-115),"hp":220,"speed":64.0,"damage":24,"scale":1.35}
				]}
			]
		"REG_003_DESERTO_RUINAS":
			return [
				{"id":"EXP_D03_TRAVELER","label":"Escavador Narek","type":"npc","prop":"traveler","pos":Vector2(20500,18400),"scale":1.0,"material":"Âmbar Negro","amount":1,"text":"Narek encontrou um fragmento de âmbar sob uma coluna partida."},
				{"id":"EXP_D03_TOMB","label":"Tumba da Areia Oca","type":"dungeon","prop":"cave_entrance","pos":Vector2(26500,18800),"scale":1.15,"reward":85,"material":"Âmbar Negro","amount":3,"start_text":"O selo da tumba se rompe. Guardiões despertam sob a areia.","mobs":[
					{"kind":"goblin","name":"Ladrão da Tumba","offset":Vector2(-90,-25),"hp":145,"speed":90.0,"damage":20,"scale":1.2},
					{"kind":"slime","name":"Gosma de Vidro Negro","offset":Vector2(80,-35),"hp":135,"speed":65.0,"damage":18,"scale":1.24},
					{"kind":"guardian","name":"Sentinela da Areia Oca","offset":Vector2(0,-125),"hp":250,"speed":66.0,"damage":26,"scale":1.38}
				]}
			]
		"REG_004_PANTANOS_SOMBRIOS":
			return [
				{"id":"EXP_M04_TRAVELER","label":"Barqueira Mavra","type":"npc","prop":"traveler","pos":Vector2(21000,16600),"scale":1.0,"material":"Fibra de Junco","amount":1,"text":"Mavra conhece canais que não aparecem em mapa algum."},
				{"id":"EXP_M04_SUNKEN_CRYPT","label":"Cripta Afundada","type":"dungeon","prop":"cave_entrance","pos":Vector2(10100,19200),"scale":1.15,"reward":95,"material":"Fibra de Junco","amount":3,"start_text":"A água recua da entrada e revela uma cripta infestada.","mobs":[
					{"kind":"slime","name":"Lodo Funerário","offset":Vector2(-80,-25),"hp":155,"speed":62.0,"damage":20,"scale":1.25},
					{"kind":"wolf","name":"Fera Encharcada","offset":Vector2(85,-30),"hp":160,"speed":101.0,"damage":22,"scale":1.25},
					{"kind":"guardian","name":"Guardião Afogado","offset":Vector2(0,-125),"hp":280,"speed":64.0,"damage":28,"scale":1.4}
				]}
			]
		"REG_005_MONTANHAS_NEVADAS":
			return [
				{"id":"EXP_I05_TRAVELER","label":"Prospector Veln","type":"npc","prop":"traveler","pos":Vector2(19000,22900),"scale":1.0,"material":"Cristal de Geada","amount":1,"text":"Veln entrega um cristal que encontrou sob o gelo azul."},
				{"id":"EXP_I05_ICE_VAULT","label":"Cofre Glacial","type":"dungeon","prop":"cave_entrance","pos":Vector2(27800,17700),"scale":1.15,"reward":110,"material":"Cristal de Geada","amount":3,"start_text":"O gelo estala. A câmara glacial desperta seus guardiões.","mobs":[
					{"kind":"wolf","name":"Lobo de Gelo","offset":Vector2(-90,-20),"hp":175,"speed":110.0,"damage":24,"scale":1.27},
					{"kind":"guardian","name":"Sentinela Congelada","offset":Vector2(90,-30),"hp":205,"speed":62.0,"damage":25,"scale":1.3},
					{"kind":"guardian","name":"Guardião do Cofre Glacial","offset":Vector2(0,-130),"hp":310,"speed":64.0,"damage":30,"scale":1.42}
				]}
			]
		"REG_006_COSTAS_ILHAS_PERDIDAS":
			return [
				{"id":"EXP_C06_TRAVELER","label":"Cartógrafa Neri","type":"npc","prop":"traveler","pos":Vector2(25000,26900),"scale":1.0,"material":"Coral Luminoso","amount":1,"text":"Neri marcou uma enseada secreta e oferece um fragmento de coral."},
				{"id":"EXP_C06_SEA_CAVE","label":"Gruta da Maré Morta","type":"dungeon","prop":"cave_entrance","pos":Vector2(33500,26700),"scale":1.15,"reward":125,"material":"Coral Luminoso","amount":3,"start_text":"A maré baixa revela uma caverna tomada por saqueadores.","mobs":[
					{"kind":"goblin","name":"Corsário da Gruta","offset":Vector2(-90,-25),"hp":185,"speed":90.0,"damage":25,"scale":1.23},
					{"kind":"wolf","name":"Fera de Sal","offset":Vector2(88,-25),"hp":190,"speed":104.0,"damage":26,"scale":1.28},
					{"kind":"guardian","name":"Guardião da Maré Morta","offset":Vector2(0,-130),"hp":340,"speed":66.0,"damage":32,"scale":1.44}
				]}
			]
		"REG_007_TERRAS_CORROMPIDAS":
			return [
				{"id":"EXP_W07_TRAVELER","label":"Batedor Orin","type":"npc","prop":"traveler","pos":Vector2(24400,24000),"scale":1.0,"material":"Fragmento de Obelisco","amount":1,"text":"Orin sobreviveu a uma patrulha e trouxe um estilhaço do obelisco."},
				{"id":"EXP_W07_BUNKER","label":"Bunker da Guerra Velha","type":"dungeon","prop":"cave_entrance","pos":Vector2(30200,15100),"scale":1.15,"reward":145,"material":"Fragmento de Obelisco","amount":3,"start_text":"As portas do bunker cedem. Ecos da guerra avançam pelo corredor.","mobs":[
					{"kind":"goblin","name":"Soldado Oco","offset":Vector2(-95,-20),"hp":205,"speed":92.0,"damage":28,"scale":1.25},
					{"kind":"guardian","name":"Veterano Corrompido","offset":Vector2(90,-25),"hp":250,"speed":68.0,"damage":30,"scale":1.34},
					{"kind":"void_general","name":"Executor da Guerra Velha","offset":Vector2(0,-135),"hp":390,"speed":76.0,"damage":36,"scale":1.48}
				]}
			]
		"REG_008_CORACAO_ABISSAL":
			return [
				{"id":"EXP_A08_TRAVELER","label":"Eco de um Cartógrafo","type":"npc","prop":"traveler","pos":Vector2(10100,10100),"scale":0.92,"material":"Fragmento do Último Mapa","amount":1,"text":"Um eco humano entrega um fragmento antes de desaparecer."},
				{"id":"EXP_A08_NULL_ROOM","label":"Câmara Nula","type":"dungeon","prop":"cave_entrance","pos":Vector2(12200,5200),"scale":1.08,"reward":180,"material":"Fragmento do Último Mapa","amount":3,"start_text":"A Câmara Nula apaga o som. Três formas emergem do vazio.","mobs":[
					{"kind":"slime","name":"Fragmento Nulo","offset":Vector2(-80,-25),"hp":230,"speed":68.0,"damage":30,"scale":1.28},
					{"kind":"guardian","name":"Sentinela Nula","offset":Vector2(85,-30),"hp":285,"speed":68.0,"damage":32,"scale":1.36},
					{"kind":"void_cartographer","name":"Eco Cartográfico","offset":Vector2(0,-130),"hp":430,"speed":78.0,"damage":38,"scale":1.5}
				]}
			]
		_:
			return []

static func elites_for(target_region_id: String) -> Array[Dictionary]:
	match target_region_id:
		"REG_002_FLORESTA_ANCESTRAL":
			return [{"kind":"wolf","name":"Alfa Musgoso","pos":Vector2(33200,30000),"hp":190,"speed":108.0,"damage":20,"scale":1.34,"story_tag":"exploration_elite"}]
		"REG_003_DESERTO_RUINAS":
			return [{"kind":"guardian","name":"Sentinela de Âmbar","pos":Vector2(25600,13900),"hp":235,"speed":66.0,"damage":24,"scale":1.38,"story_tag":"exploration_elite"}]
		"REG_004_PANTANOS_SOMBRIOS":
			return [{"kind":"guardian","name":"Carrasco do Brejo","pos":Vector2(15100,18100),"hp":260,"speed":64.0,"damage":27,"scale":1.40,"story_tag":"exploration_elite"}]
		"REG_005_MONTANHAS_NEVADAS":
			return [{"kind":"wolf","name":"Lobo Branco Ancião","pos":Vector2(24500,12800),"hp":275,"speed":112.0,"damage":29,"scale":1.42,"story_tag":"exploration_elite"}]
		"REG_006_COSTAS_ILHAS_PERDIDAS":
			return [{"kind":"guardian","name":"Guardião do Naufrágio","pos":Vector2(34200,17100),"hp":320,"speed":68.0,"damage":31,"scale":1.45,"story_tag":"exploration_elite"}]
		"REG_007_TERRAS_CORROMPIDAS":
			return [{"kind":"void_general","name":"Arauto da Coroa Oca","pos":Vector2(33700,15800),"hp":390,"speed":76.0,"damage":34,"scale":1.48,"story_tag":"exploration_elite"}]
		"REG_008_CORACAO_ABISSAL":
			return [{"kind":"void_cartographer","name":"Eco do Caminho Perdido","pos":Vector2(7300,8200),"hp":440,"speed":76.0,"damage":35,"scale":1.46,"story_tag":"exploration_elite"}]
		_:
			return []
