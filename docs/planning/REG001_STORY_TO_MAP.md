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

## Continuidade Cartoon v0.20 — 30/09/2026

A matriz acima é histórica. O passe atual usa `cartoon_main_story_map.gd` e
`cartoon_landscape_layout.gd`, na base Cartoon v0.19. Nenhum lugar canônico mudou
posição. Arte e novos detalhes de composição são MODELED_PENDING_GATE.

| Lugar / função | Lógica de sítio preservada | Tratamento Cartoon |
|---|---|---|
| Praça / `POI_REG001_PLAZA` | cruzamento das ruas + mercado | calçamento, fonte, bancos e iluminação |
| Serviços / `LOC_VAL_GUILD`, forja, taverna, alquimista | acessos existentes à praça + mercado/ofícios | pátios, placas, barris e materiais diferenciados |
| Casas existentes | rede de ruas + abastecimento da cidade | caminhos residenciais, jardins e três telhados |
| Fazenda / `POI_REG001_FARM` | vento aberto + lavouras / estrada | moinho completo, trigo, feno e acesso à casa |
| `LOC_FIRST_WIND_RUINS` | estrada antiga + história da missão | fundações partidas, vegetação na borda, altar legível |
| `LOC_ALPHA_CLEARING` | floresta + encontro canônico | clareira gasta e borda de árvores; entradas livres |
| `LOC_ECHO_MINE` / `LOC_ECHO_MINE_CORE` | recurso mineral + rota da missão | abertura encaixada na rocha e trilha até a câmara |
| `LOC_SIX_CROWNS_ARCHIVE` | missão canônica + ramal da estrada | pátio pavimentado e jardins emoldurando o arquivo |
| Posto, acampamentos, ruínas e pedreira da exploração | rede existente + abrigo/recurso/história | acessos contínuos no grafo compartilhado de estradas |

Verificações atuais: `tests/cartoon_hub.gd`, `tests/cartoon_visual_v020.gd` e
capturas em `docs/visual_qa/cartoon_v020/`. Fonte do escopo e pendências:
`docs/CARTOON_VISUAL_V0_20.md`.

## Passe Cartoon v0.22 — serviços internos (PROPOSED)

As construções existentes mantêm sua posição externa. Não se altera a história principal.

| Construção / POI | Por que aqui? | Entrada e função | Persistência |
|---|---|---|---|
| Taverna / POI_REG001_TAVERN | Cruzamento da rua leste e mercado da praça oferecem passagem e provisões. | Porta externa (local 1580,800); salão com descanso, cama e rumores de caça. | Save mantém posição externa; vida e materiais globais. |
| Ferreiro / POI_REG001_FORGE | Rua principal dá acesso ao comércio; lado oeste próximo da água para têmpera. | Porta externa (720,790); oficina com fornalha, bigorna e fabricação. | WPN_VALE_00 e ARM_VALE_00 persistentes. |
| Guilda / POI_REG001_GUILD / LOC_VAL_GUILD | Praça/rota de chegada e mercado concentram aventureiros e contratação. | Porta externa (760,1125); quadro e escrivão oferecem sete contratos. | GUILD_* separados de Q_MS*; contrato antigo preservado. |

Cada salão tem circulação testada por busca em grade até seus serviços e saída.
Os pontos de caça ficam em campos e clareiras fora da cidade; a fauna usa posições
reprodutíveis e evita as águas desenhadas em Pântanos/Costas. Contratos e novos
personagens funcionais são PROPOSED; não se atribuem nomes ou fatos novos ao cânone.

## Castelo Real Cartoon v0.23 — 01/10/2026 (PROPOSED)

| Lugar | Por que aqui? | Rota e função | IDs / validação |
|---|---|---|---|
| Castelo Real a nordeste, âncora local (2500,-350) | Sítio elevado/defensável ao norte + acesso à avenida de chegada e ao mercado central. A implantação lateral deixa livre a estrada da campanha. | Ramal cerimonial pela cota local y=120, antes da cabeceira do rio leste; termina na escadaria/portão em (2500,-280). | POI_REG001_CASTLE preservado; oito alas internas definidas por cartoon_royal_palace.gd. |
| Estrada Norte e chegada | Rota/história e circulação entre cidade, campos e ruínas. | Seus pontos canônicos permanecem no eixo local x=1150; não passam pelo prédio real. | LOC_VAL_GATE, LOC_VAL_NORTH_ROAD e encontros existentes mantidos. |
| Palácio interno | Função de poder + recepção/circulação no reino. | Vestíbulo → trono; alas laterais de banquetes, biblioteca e aposentos; galerias e conselho. | BFS de todas as alas/serviços, colisão e save externo em cartoon_royal_castle_v023.gd. |

O nome próprio e biografia do rei não foram definidos neste passe; usa-se apenas
Rei de Valedouro. A audiência não altera missões ou revela fatos novos do cânone.
