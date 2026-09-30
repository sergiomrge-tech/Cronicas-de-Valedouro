class_name ValedouroCartoonExplorationDirector
extends Node

const PropScript = preload("res://scripts/cartoon/cartoon_prop.gd")

var host
var objects: Node2D
var hero: Node2D
var region_id: String = ""
var sites: Array[Dictionary] = []
var collected: Dictionary = {}
var site_nodes: Dictionary = {}
var elite_count: int = 0

func setup(host_node, objects_node: Node2D, hero_node: Node2D, target_region_id: String) -> void:
	host = host_node
	objects = objects_node
	hero = hero_node
	region_id = target_region_id
	sites = content_for(region_id)
	for site in sites:
		_spawn_site(site)
	for elite in elites_for(region_id):
		if host != null and host.has_method("_spawn_monster"):
			host.call("_spawn_monster",elite)
			elite_count += 1

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
	return "✦ %s  •  EXPLORAR" % String(site.get("label","Segredo"))

func try_interact(radius: float = 195.0) -> bool:
	var site: Dictionary = _nearest_site(radius)
	if site.is_empty():
		return false
	var id: String = String(site.get("id",""))
	if collected.has(id):
		return false
	collected[id] = true
	var site_type: String = String(site.get("type","treasure"))
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
			_add_gold(reward)
			message += "  Recursos convertidos em +%d ouro." % reward
			_fade_site(id)
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
		if collected.has(id):
			continue
		var pos: Vector2 = site.get("pos",Vector2.ZERO)
		var d: float = hero.position.distance_to(pos)
		if d < best_d:
			best_d = d
			best = site
	return best

func progress_text() -> String:
	return "%d/%d segredos" % [collected.size(),sites.size()]

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
