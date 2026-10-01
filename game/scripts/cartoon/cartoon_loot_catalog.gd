extends RefCounted
## Loot cadenciado da campanha Cartoon v0.31.
## Mantém equipamentos raros, materiais úteis e cura limitada sem acelerar
## demais o poder do personagem no começo do jogo.

const CONSUMABLES: Dictionary = {
	"healing_flask":{
		"id":"healing_flask",
		"label":"Frasco de Cura",
		"description":"Restaura 35% da vida máxima.",
		"heal_ratio":0.35,
		"rarity":"Comum"
	},
	"greater_healing_flask":{
		"id":"greater_healing_flask",
		"label":"Elixir Restaurador",
		"description":"Restaura 70% da vida máxima.",
		"heal_ratio":0.70,
		"rarity":"Raro"
	}
}

const REGIONS: Dictionary = {
	"REG_001_BERCO_VALEDOURO":{"tier":0,"material":"Osso de caça"},
	"REG_002_FLORESTA_ANCESTRAL":{"tier":1,"material":"Seiva Ancestral"},
	"REG_003_DESERTO_RUINAS":{"tier":2,"material":"Âmbar Negro"},
	"REG_004_PANTANOS_SOMBRIOS":{"tier":3,"material":"Fibra de Junco"},
	"REG_005_MONTANHAS_NEVADAS":{"tier":4,"material":"Cristal de Geada"},
	"REG_006_COSTAS_ILHAS_PERDIDAS":{"tier":5,"material":"Coral Luminoso"},
	"REG_007_TERRAS_CORROMPIDAS":{"tier":6,"material":"Fragmento de Obelisco"},
	"REG_008_CORACAO_ABISSAL":{"tier":7,"material":"Fragmento do Último Mapa"}
}

static func consumable(id: String) -> Dictionary:
	var row: Variant = CONSUMABLES.get(id,{})
	return (row as Dictionary).duplicate(true) if row is Dictionary else {}

static func region(region_id: String) -> Dictionary:
	var row: Variant = REGIONS.get(region_id,{})
	return (row as Dictionary).duplicate(true) if row is Dictionary else {}

static func roll(
	region_id: String,
	pity_after_kill: int,
	is_boss: bool = false,
	is_elite: bool = false,
	forced: Dictionary = {}
) -> Dictionary:
	var row: Dictionary = region(region_id)
	if row.is_empty():
		return {"material_qty":0,"consumable_id":"","gear":false}

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var material_roll: float = float(forced.get("material",rng.randf()))
	var consumable_roll: float = float(forced.get("consumable",rng.randf()))
	var gear_roll: float = float(forced.get("gear",rng.randf()))

	var material_chance: float = 1.0 if is_boss else (0.45 if is_elite else 0.22)
	var consumable_chance: float = 0.35 if is_boss else (0.20 if is_elite else 0.08)
	var gear_chance: float = 0.18 if is_boss else (0.06 if is_elite else 0.015)
	if not is_boss and not is_elite and pity_after_kill > 35:
		gear_chance = minf(0.12,gear_chance+float(pity_after_kill-35)*0.008)
	var gear_drop: bool = pity_after_kill >= 50 or gear_roll < gear_chance

	var material_qty: int = 0
	if material_roll < material_chance:
		material_qty = 2 if is_boss else 1
		if is_boss and int(row.get("tier",0)) >= 5:
			material_qty = 3

	var consumable_id: String = ""
	if consumable_roll < consumable_chance:
		var tier: int = int(row.get("tier",0))
		consumable_id = "greater_healing_flask" if (is_boss and tier >= 3) or (is_elite and tier >= 5) else "healing_flask"

	return {
		"material":String(row.get("material","")),
		"material_qty":material_qty,
		"consumable_id":consumable_id,
		"gear":gear_drop,
		"gear_chance":gear_chance
	}
