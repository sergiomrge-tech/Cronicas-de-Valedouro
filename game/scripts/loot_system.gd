extends RefCounted
# Chances are deliberately low; chapter and level requirements gate equipment.
const PROFILES: Dictionary = {
	"Lobo": {"equipment": .013, "material": .38, "resource": "Couro de lobo", "tier": 1, "req": 1, "chapter": 0},
	"Limo": {"equipment": .018, "material": .43, "resource": "Núcleo de limo", "tier": 1, "req": 1, "chapter": 0},
	"Aranha Sombria": {"equipment": .015, "material": .41, "resource": "Seda sombria", "tier": 1, "req": 2, "chapter": 0},
	"Javali Musgoso": {"equipment": .019, "material": .44, "resource": "Presa musgosa", "tier": 1, "req": 4, "chapter": 0},
	"Flor Voraz": {"equipment": .020, "material": .46, "resource": "Seiva voraz", "tier": 1, "req": 5, "chapter": 0},
	"Escorpião": {"equipment": .023, "material": .48, "resource": "Quitina âmbar", "tier": 2, "req": 6, "chapter": 3},
	"Escaravelho Âmbar": {"equipment": .026, "material": .50, "resource": "Casco de âmbar", "tier": 2, "req": 8, "chapter": 3},
	"Lobo de Gelo": {"equipment": .030, "material": .45, "resource": "Cristal gelado", "tier": 3, "req": 10, "chapter": 4},
	"Golem de Geada": {"equipment": .034, "material": .52, "resource": "Coração de geada", "tier": 3, "req": 11, "chapter": 4},
	"Guardião": {"equipment": .05, "material": 1.0, "resource": "Fragmento de Eco", "tier": 2, "req": 5, "chapter": 3}
}
const NAMES: Dictionary = {
	1: ["Espada de Carvalho", "Arco do Bosque", "Cajado de Broto", "Gibão de Couro"],
	2: ["Espada de Âmbar", "Arco do Sol", "Cajado das Dunas", "Armadura de Bronze"],
	3: ["Espada Glacial", "Arco Boreal", "Cajado da Geada", "Armadura de Gelo"]
}
const FAMILIES: Array[String] = ["sword", "bow", "staff", "armor"]

static func roll(kind: String, rng: RandomNumberGenerator) -> Dictionary:
	if not PROFILES.has(kind):
		return {}
	var profile: Dictionary = PROFILES[kind]
	var result: Dictionary = {"material": "", "item": {}}
	if rng.randf() < profile["material"]:
		result["material"] = profile["resource"]
	if rng.randf() < profile["equipment"]:
		var tier: int = profile["tier"]
		var index: int = rng.randi_range(0, 3)
		var family: String = FAMILIES[index]
		result["item"] = {
			"name": NAMES[tier][index], "kind": family, "tier": tier,
			"req": profile["req"], "chapter": profile["chapter"],
			"atk": tier * (4 if family != "armor" else 0),
			"def": tier * 2 if family == "armor" else 0
		}
	return result
