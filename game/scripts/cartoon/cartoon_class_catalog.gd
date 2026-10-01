class_name ValedouroCartoonClassCatalog
extends RefCounted
## Switchable specializations of the same Traveler; extra mechanics are PROPOSED.
const RANK_LEVELS = [1,3,5,8,12,18,25,35,50,70]
const MAX_RANK = 10
const CLASSES = [
	{"id":"warrior","name":"Guerreiro","color":"e9ba62","description":"Espada, defesa e esquiva frequente.","skills":["blade","guard","footwork"]},
	{"id":"mage","name":"Mago","color":"ce91ff","description":"Magias fortes, conjuração rápida e domínio elemental.","skills":["power","focus","elements"]},
	{"id":"hunter","name":"Caçador","color":"92d58f","description":"Arco, caça, mobilidade e alcance.","skills":["hunt","agility","reach"]}
]
const SKILLS = {
	"blade":{"class":"warrior","name":"Lâmina treinada","description":"+4% de dano da espada por grau."},
	"guard":{"class":"warrior","name":"Guarda firme","description":"Reduz o dano recebido em 2% por grau, após a defesa do equipamento."},
	"footwork":{"class":"warrior","name":"Passos de batalha","description":"Reduz a recarga da esquiva em 0,06 s por grau."},
	"power":{"class":"mage","name":"Afinidade mágica","description":"+4% de dano mágico por grau."},
	"focus":{"class":"mage","name":"Concentração","description":"Reduz a recarga das magias em 0,08 s por grau."},
	"elements":{"class":"mage","name":"Domínio elemental","description":"Por grau: +1% de dano em cada pulso de Brasa, +0,1 s de lentidão e +5 de alcance do salto de Arcana."},
	"hunt":{"class":"hunter","name":"Caça precisa","description":"+4% de dano com arco; +6% adicional contra animais de caça por grau."},
	"agility":{"class":"hunter","name":"Instinto ágil","description":"+4 unidades de distância da esquiva por grau."},
	"reach":{"class":"hunter","name":"Olhar atento","description":"+4 unidades de alcance do arco e das magias por grau."}
}
static func class_row(id: String) -> Dictionary:
	for row in CLASSES:
		if row.id==id: return row
	return {}
static func required_level(next_rank: int) -> int:
	return RANK_LEVELS[clampi(next_rank-1,0,MAX_RANK-1)]
