extends RefCounted
## Materiais e receitas exclusivas de chefes — v0.36.
## Cada chefe principal entrega um troféu de crafting ligado a uma única peça.

const ROWS: Array[Dictionary] = [
	{
		"boss_id":"BOSS_ALPHA_MATILHA_001",
		"region_id":"REG_001_BERCO_VALEDOURO",
		"boss_name":"Alfa da Matilha",
		"material":"Presa do Alfa",
		"recipe":{"id":"BOSS_WPN_ALPHA_001","label":"Lâmina da Presa Alfa","slot":"weapon","weapon_kind":"sword","tier":0,"attack":3,"material":"Presa do Alfa","cost":1}
	},
	{
		"boss_id":"BOSS_GUARDIAO_PEDRA_001",
		"region_id":"REG_001_BERCO_VALEDOURO",
		"boss_name":"Guardião de Pedra",
		"material":"Núcleo do Guardião",
		"recipe":{"id":"BOSS_CAPE_GUARDIAN_001","label":"Capa do Guardião de Pedra","slot":"cape","tier":0,"defense":2,"material":"Núcleo do Guardião","cost":1}
	},
	{
		"boss_id":"BOSS_RAIZ_OCA_001",
		"region_id":"REG_002_FLORESTA_ANCESTRAL",
		"boss_name":"Raiz Oca",
		"material":"Cerne da Raiz Oca",
		"recipe":{"id":"BOSS_HELM_ROOT_001","label":"Elmo da Raiz Oca","slot":"helmet","tier":1,"defense":2,"material":"Cerne da Raiz Oca","cost":1}
	},
	{
		"boss_id":"BOSS_GENERAL_CINZA_001",
		"region_id":"REG_003_DESERTO_RUINAS",
		"boss_name":"General da Cinza",
		"material":"Coração de Cinza",
		"recipe":{"id":"BOSS_WPN_ASH_001","label":"Sabre do General da Cinza","slot":"weapon","weapon_kind":"sword","tier":2,"attack":9,"material":"Coração de Cinza","cost":1}
	},
	{
		"boss_id":"BOSS_DAMA_JUNCOS_001",
		"region_id":"REG_004_PANTANOS_SOMBRIOS",
		"boss_name":"Dama dos Juncos",
		"material":"Coroa de Junco",
		"recipe":{"id":"BOSS_CAPE_REEDS_001","label":"Manto da Dama dos Juncos","slot":"cape","tier":3,"defense":3,"material":"Coroa de Junco","cost":1}
	},
	{
		"boss_id":"BOSS_CAPITAO_GELO_001",
		"region_id":"REG_005_MONTANHAS_NEVADAS",
		"boss_name":"Capitão do Gelo",
		"material":"Insígnia do Capitão de Gelo",
		"recipe":{"id":"BOSS_GLOVES_ICE_001","label":"Manoplas do Capitão de Gelo","slot":"gloves","tier":4,"defense":3,"material":"Insígnia do Capitão de Gelo","cost":1}
	},
	{
		"boss_id":"BOSS_GENERAL_GEADA_NEGRA_001",
		"region_id":"REG_005_MONTANHAS_NEVADAS",
		"boss_name":"General da Geada Negra",
		"material":"Caco de Geada Negra",
		"recipe":{"id":"BOSS_WPN_BLACKFROST_001","label":"Lâmina da Geada Negra","slot":"weapon","weapon_kind":"sword","tier":4,"attack":17,"material":"Caco de Geada Negra","cost":1}
	},
	{
		"boss_id":"BOSS_GENERAL_MARE_OCA_001",
		"region_id":"REG_006_COSTAS_ILHAS_PERDIDAS",
		"boss_name":"General da Maré Oca",
		"material":"Olho da Maré Oca",
		"recipe":{"id":"BOSS_BOOTS_TIDE_001","label":"Botas da Maré Oca","slot":"boots","tier":5,"defense":4,"material":"Olho da Maré Oca","cost":1}
	},
	{
		"boss_id":"BOSS_GENERAL_ECO_VAZIO_001",
		"region_id":"REG_007_TERRAS_CORROMPIDAS",
		"boss_name":"General do Eco Vazio",
		"material":"Eco Condensado do Vazio",
		"recipe":{"id":"BOSS_CAPE_VOID_001","label":"Capa do Eco Vazio","slot":"cape","tier":6,"defense":5,"material":"Eco Condensado do Vazio","cost":1}
	},
	{
		"boss_id":"BOSS_CARTOGRAFO_VAZIO_001",
		"region_id":"REG_008_CORACAO_ABISSAL",
		"boss_name":"Cartógrafo do Vazio",
		"material":"Fragmento Cartográfico",
		"recipe":{"id":"BOSS_HELM_CARTOGRAPHER_001","label":"Elmo do Cartógrafo do Vazio","slot":"helmet","tier":7,"defense":6,"material":"Fragmento Cartográfico","cost":1}
	},
	{
		"boss_id":"BOSS_AZHAREL_001",
		"region_id":"REG_008_CORACAO_ABISSAL",
		"boss_name":"Azharel",
		"material":"Fragmento de Azharel",
		"recipe":{"id":"BOSS_WPN_AZHAREL_001","label":"Lâmina do Primeiro Viajante","slot":"weapon","weapon_kind":"sword","tier":7,"attack":36,"material":"Fragmento de Azharel","cost":1}
	}
]

static func row_for_boss(boss_id: String) -> Dictionary:
	for row in ROWS:
		if String(row.boss_id) == boss_id:
			return row.duplicate(true)
	return {}

static func recipes_for_region(region_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in ROWS:
		if String(row.region_id) == region_id:
			var recipe: Dictionary = row.recipe.duplicate(true)
			recipe["boss_id"] = String(row.boss_id)
			recipe["boss_name"] = String(row.boss_name)
			recipe["boss_unique"] = true
			result.append(recipe)
	return result

static func boss_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for row in ROWS:
		ids.append(String(row.boss_id))
	return ids
