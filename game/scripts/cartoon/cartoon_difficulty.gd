extends RefCounted
const REGION_LEVELS = {"REG_001_BERCO_VALEDOURO":1,"REG_002_FLORESTA_ANCESTRAL":8,"REG_003_DESERTO_RUINAS":18,"REG_004_PANTANOS_SOMBRIOS":28,"REG_005_MONTANHAS_NEVADAS":40,"REG_005_SIEGE_VALEDOURO":45,"REG_006_COSTAS_ILHAS_PERDIDAS":55,"REG_007_TERRAS_CORROMPIDAS":70,"REG_008_CORACAO_ABISSAL":85}
static func region_level(id: String) -> int: return int(REGION_LEVELS.get(id,1))
static func monster_data(source: Dictionary, region_id: String) -> Dictionary:
	var row: Dictionary = source.duplicate(true)
	var boss: bool = String(row.get("boss_id",""))!=""
	row.hp = ceili(int(row.get("hp",34))*(1.25 if boss else 1.6))
	row.damage = ceili(int(row.get("damage",7))*(1.2 if boss else 1.35))
	row.speed = float(row.get("speed",86))*1.08
	var variation: int = posmod(hash(String(row.get("name",""))+str(row.get("pos",Vector2.ZERO))),3)
	row.level = clampi(int(row.get("level",region_level(region_id)+(6 if boss else variation))),1,100)
	return row
static func outgoing(amount: int, hero_level: int, enemy_level: int) -> int:
	var gap: int = maxi(0,enemy_level-hero_level)
	return maxi(1,roundi(amount*maxf(0.035,1.0/(1+0.30*gap+0.05*gap*gap))))
static func incoming(amount: int, hero_level: int, enemy_level: int) -> int:
	var gap: int = maxi(0,enemy_level-hero_level)
	return maxi(1,roundi(amount*minf(5,1+0.12*gap+0.018*gap*gap)))
static func level_color(hero_level: int, enemy_level: int) -> Color:
	if enemy_level>hero_level+4: return Color("ff617b")
	return Color("ffc666") if enemy_level>hero_level else Color("deefdb")
