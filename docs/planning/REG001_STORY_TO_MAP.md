# REG_001 — História → Mapa (matriz de construções e lugares)

Regras: skill `.claude/skills/valedouro-map-logic/SKILL.md`. Verificação automática: `python3 game/tools/reg001/audit_logic.py` (20 construções, 0 falhas). Nada aqui inventa lore: tudo vem de `docs/canon/CANON_SOURCE_OF_TRUTH.md`, `docs/README_CONTINUE_AQUI.md`, `docs/planning/*QUEST_FLOW*`, `*LEVEL_DESIGN*`, `*LANDMARKS_SEGREDOS*`, `*NPCS_SERVICOS*`, `docs/roadmap/ROADMAP_DIARIO_001_120.md` e os `REG001_LORE_*` do mundo.

## A história que o mapa precisa contar (fontes)
- Elyndor vive a **Guerra da Coroa Oca** há 23 anos; o protagonista vem da Terra, é o **Segundo Viajante**; **Azharel** foi **Adrian Vale**, o Primeiro Viajante. Objetivo: reunir os Sete Sigilos, apoiar as Seis Coroas, derrotar Azharel e usar o Coração do Limiar para voltar.
- Vertical Slice (roadmap 028–044): *O Estrangeiro / Valedouro* — Floresta da Queda → Estrada dos Peregrinos → vila → Campos (fazendas e ruínas) → rios e pontes → **Ruínas do Primeiro Limiar** (dungeon 01, boss Guardião) → ferreiro/crafting → primeira prova de portal entre mundos.
- Quest flow REG_001 (001–008): Chegada (hub, NPC, serviços) → Arredores → Contrato dos Lobos → Sinais no Bosque → Elite do Bosque → **Ruínas antigas (ativar mecanismo, liberar a dungeon)** → **O Guardião** → Retorno (entregar material, desbloquear crafting).
- Rota principal (LEVEL_DESIGN v1): **Cidade → Campos → Bosque → Ruínas → Dungeon**; entrada da dungeon = "arco de pedra, tochas, vegetação, água ou queda d'água, sinal de perigo".
- Lore no mapa: chegada dos Viajantes "por onde o vento nasce" (altar das Ruínas do Primeiro Vento vibra); Santuário do Vale "erguido por quem cruzou o Limiar antes de você"; Círculo de gelo com o reflexo de Adrian Vale; Cripta "dos que guardaram o Limiar"; ruínas das dunas com a mesma runa (um caminho, um Limiar, uma escolha); famílias que fugiram para a Vila dos Campos.

## Matriz beat → lugar → lógica de sítio → estado

| Beat / necessidade | Lugar (ID) | Por que está aqui | Estado |
|---|---|---|---|
| Chegada, NPC principal, serviços | Cidade de Valedouro (praça, guilda, ferreiro, loja, alquimia) | hub no cruzamento das duas estradas; rio a leste (cais, forja perto d'água) | mantido |
| Descanso/save/rumor (NPCS_SERVICOS §6) | **Taverna do Viajante** (`REG001_POI_TAVERNA`) | casa junto da praça e da estrada principal; placa, barris, bancos | **novo** |
| Arredores / Lobos / Sinais no Bosque | Portão norte → Bosque; torre do Norte na estrada | torre vigia a saída; estrada norte contínua | mantido |
| Chegada dos Viajantes / mecanismo | Ruínas do Primeiro Vento (altar, obeliscos, arco) | ponta da rota principal do Bosque; altar sobre o local de chegada | mantido |
| **Dungeon 01 / Guardião** | **Portão do Primeiro Limiar** (`REG001_POI_MASMORRA_ENTRADA`) | **antes** um portal solto na muralha sul da cidade; **agora** grade de pedra encaixada no paredão logo além do arco dos antigos (rota Cidade→Bosque→Ruínas→Dungeon), com paredões, tochas, estátuas guardiãs e vegetação; saída devolve ao portão | **corrigido** |
| Segunda dungeon opcional | Cripta Esquecida (`REG001_POI_CRIPTA_ENTRADA`) | fim de trilha no sul do Vale; **agora escavada no flanco de colina** (paredões laterais + colinas), com tochas e estátuas | **corrigido** |
| Santuário dos que cruzaram antes | Santuário do Vale | ramal da estrada sul, no Vale | mantido |
| Moinho / campos (level design §2) | Moinho do Vale | borda da aldeia, trilha própria; **agora com faixa de trigo, feno e cerca** (moinho existe por causa das lavouras) | **corrigido** |
| Fazendas e cercas | Fazenda do Vale + celeiro | celeiro encostado nas lavouras, portão, poço da vila | mantido |
| Guerra: vigilância | Torres do Oeste/Norte/Geadas, muralha da cidade | torres em cruzamentos e sobre mesa de relevo; **muralha sul agora fechada** (o vão do portal antigo virou muro) | **corrigido** |
| Rotas e comércio | Cais (norte/central/sul), pontes, Estação das Colinas, Caravana de Âmbar, Posto de Âmbar | cais na orla junto às pontes, **agora com carga (caixotes/barris)**; **Estação das Colinas ganhou a casa de posta** (casa + feno + cerca); posto de âmbar na bifurcação para o oásis | **corrigido** |
| Abastecimento | Poço da cidade | **estava dentro do rio**; movido para a rua do mercado | **corrigido** |
| Guerra: gente que fugiu | Acampamento do lenhador, casa abandonada + bilhete → Vila dos Campos | trilhas próprias, fogueira acesa/cerca quebrada | mantido |
| Vilão / passado | Círculo de gelo, gruta congelada, ruínas das dunas | nos extremos das rotas; segredos a um desvio curto | mantido |

## Lacunas conhecidas (não resolvidas — dependem de decisão/assets)
- **Água perto da entrada da dungeon** (LEVEL_DESIGN §6): o Bosque das Ruínas não tem córrego; a cachoeira fica na cabeceira do rio, longe. Proposta: córrego raso do Bosque ao Portão (exige ampliar o bake de água + `world_map.gd`).
- **Riachos nos Campos/Vale/Bosque** (LEVEL_DESIGN §2/§8): só existe o rio leste; fazendas e aldeias usam poços.
- **Templo e residência do NPC principal** (LEVEL_DESIGN §1): sem asset/interior próprio ainda.
- **Ativar mecanismo antes de abrir a dungeon** (QUEST_FLOW 006): o portão continua aberto (não alterei o fluxo de missão sem ordem).
- Cidade com apenas 11 casas + 4 de serviço: escala de hub pequeno; não há bairros de pobres/ricos além da borda.
