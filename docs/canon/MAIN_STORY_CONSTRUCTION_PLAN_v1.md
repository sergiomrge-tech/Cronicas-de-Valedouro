# CRÔNICAS DE VALEDOURO — PLANO DE CONSTRUÇÕES DA HISTÓRIA PRINCIPAL v1

## Regra
Toda estrutura grande do mundo deve estar conectada a uma função real de gameplay ou narrativa. Este documento deriva de `main_story_v1.json` e `story_locations_v1.json`.

Estados:
- **EXISTING_RUNTIME / EXISTING_REG001**: preservar e adaptar sem descaracterizar.
- **EXISTING_*_ADAPT**: existe um equivalente atual que deve ser refinado/renomeado/recontextualizado.
- **TO_BUILD**: construção obrigatória para a história final; não substituir por decoração genérica.

## Prioridade de produção
1. terminar todas as estruturas do Ato I antes de ampliar o mapa final;
2. produzir o hub/landmark/dungeon/boss arena de cada novo ato antes de detalhar props secundários;
3. construção principal deve aparecer visualmente antes ou durante a missão que a apresenta;
4. após a missão, a estrutura deve continuar útil quando o campo `post` definir função persistente;
5. nenhuma arena de boss pode ser improvisada a partir de uma praça genérica;
6. nenhuma dungeon principal pode reutilizar outra dungeon apenas trocando textura;
7. cada região precisa de silhueta arquitetônica própria.


## Ato 1 — O Segundo Viajante
**Região:** Berço de Valedouro · **Níveis:** 1–12

- **Portão de Valedouro** (`LOC_VAL_GATE`) — EXISTING_RUNTIME. Função: fortification. Missões: `Q_MS01_ARRIVAL`. Depois: Defesa narrativa, entrada da cidade e marco de retorno.
- **Guilda dos Aventureiros de Valedouro** (`LOC_VAL_GUILD`) — EXISTING_RUNTIME. Função: service_building. Missões: `Q_MS01_GUILD`. Depois: Contratos, domínio, recompensas e reputação.
- **Estrada Norte** (`LOC_VAL_NORTH_ROAD`) — EXISTING_REG001. Função: road. Missões: `Q_MS01_WOLVES`. Depois: Rota de exploração e contratos iniciais.
- **Ruínas do Primeiro Vento** (`LOC_FIRST_WIND_RUINS`) — EXISTING_REG001. Função: ruins. Missões: `Q_MS01_FIRST_WIND`. Depois: Lore do Primeiro Viajante e âncora de exploração.
- **Clareira do Alfa** (`LOC_ALPHA_CLEARING`) — EXISTING_REG001_ADAPT. Função: arena. Missões: `Q_MS01_ALPHA`. Depois: Arena de revanche/caçada.
- **Mina do Eco** (`LOC_ECHO_MINE`) — EXISTING_RUNTIME_ADAPT. Função: dungeon_entrance. Missões: `Q_MS01_MINE`. Depois: Dungeon repetível após a história.
- **Câmara do Guardião** (`LOC_ECHO_MINE_CORE`) — EXISTING_RUNTIME. Função: boss_arena. Missões: `Q_MS01_GUARDIAN`. Depois: Revanche do Guardião e crafting.
- **Arquivo das Seis Coroas** (`LOC_SIX_CROWNS_ARCHIVE`) — TO_BUILD. Função: archive. Missões: `Q_MS01_ARCHIVE`. Depois: Codex, registros históricos e exposição do mapa.

## Ato 2 — A Floresta que Lembra
**Região:** Floresta Ancestral · **Níveis:** 12–24

- **Ponte de Pedra da Fronteira** (`LOC_FOREST_STONE_BRIDGE`) — TO_BUILD. Função: bridge. Missões: `Q_MS02_BORDER`. Depois: Fast travel e ligação visual entre regiões.
- **Casa dos Guardas Verdes** (`LOC_FOREST_RANGER_LODGE`) — TO_BUILD. Função: lodge. Missões: `Q_MS02_RANGERS`. Depois: Contratos e suporte da floresta.
- **Santuários de Raiz** (`LOC_FOREST_ROOT_SHRINES`) — TO_BUILD. Função: shrines. Missões: `Q_MS02_ROOTS`. Depois: Pontos de lore e recursos naturais.
- **Árvore-Memória** (`LOC_MEMORY_TREE`) — TO_BUILD. Função: landmark. Missões: `Q_MS02_MEMORY_TREE`. Depois: Landmark central e memória/codex.
- **Coração da Raiz Oca** (`LOC_HOLLOW_ROOT_ARENA`) — TO_BUILD. Função: boss_arena. Missões: `Q_MS02_HOLLOW_ROOT`. Depois: Revanche opcional.
- **Santuário dos Cartógrafos** (`LOC_FOREST_CARTOGRAPHER_SHRINE`) — TO_BUILD. Função: ruins. Missões: `Q_MS02_VEIL_SHRINE`. Depois: Atualização do mapa-múndi e lore.

## Ato 3 — Cinzas de Edravar
**Região:** Deserto e Ruínas · **Níveis:** 24–36

- **Caravana de Âmbar** (`LOC_AMBER_CARAVAN`) — EXISTING_REG001. Função: mobile_camp. Missões: `Q_MS03_CARAVAN`. Depois: Mercador itinerante e contratos.
- **Posto de Âmbar** (`LOC_AMBER_POST`) — TO_BUILD. Função: outpost. Missões: `Q_MS03_AMBER_POST`. Depois: Hub menor, comércio e fast travel.
- **Edravar Ocupada** (`LOC_EDRAVAR_OCCUPIED_CITY`) — TO_BUILD. Função: city_ruins. Missões: `Q_MS03_EDRAVAR`. Depois: Grande zona urbana de exploração.
- **Cisterna da Resistência** (`LOC_EDRAVAR_RESISTANCE_CISTERN`) — TO_BUILD. Função: hideout. Missões: `Q_MS03_CISTERN`. Depois: Base de resistência e secundárias.
- **Observatório de Cinzas** (`LOC_ASH_OBSERVATORY`) — TO_BUILD. Função: dungeon. Missões: `Q_MS03_OBSERVATORY`. Depois: Dungeon repetível.
- **Cidadela da Cinza** (`LOC_ASH_CITADEL`) — TO_BUILD. Função: fortress. Missões: `Q_MS03_GENERAL_ASH`. Depois: Revanche do General e materiais.

## Ato 4 — As Lanternas Afundadas
**Região:** Pântanos Sombrios · **Níveis:** 36–48

- **Vila das Lanternas** (`LOC_MARSH_STILT_VILLAGE`) — TO_BUILD. Função: stilt_village. Missões: `Q_MS04_STILTS`. Depois: Hub do pântano.
- **Torre do Sino Afogado** (`LOC_DROWNED_BELL_TOWER`) — TO_BUILD. Função: tower. Missões: `Q_MS04_BELL`. Depois: Landmark, puzzle e navegação.
- **Mosteiro Inundado** (`LOC_FLOODED_MONASTERY`) — TO_BUILD. Função: dungeon. Missões: `Q_MS04_MONASTERY`. Depois: Dungeon/recompensas.
- **Santuário dos Juncos** (`LOC_REED_SANCTUM`) — TO_BUILD. Função: sanctum. Missões: `Q_MS04_REED_SANCTUM`. Depois: Lore e acesso ao boss.
- **Trono dos Juncos** (`LOC_REED_THRONE`) — TO_BUILD. Função: boss_arena. Missões: `Q_MS04_LADY_REEDS`. Depois: Revanche da Dama.
- **Comporta dos Ecos** (`LOC_MARSH_ECHO_SLICE`) — TO_BUILD. Função: ritual_gate. Missões: `Q_MS04_SLICE_GATE`. Depois: Controle ambiental pós-história.

## Ato 5 — O Arquivo sob o Gelo
**Região:** Montanhas Nevadas · **Níveis:** 48–60

- **Pouso da Geada** (`LOC_FROST_REST`) — EXISTING_REG001. Função: settlement. Missões: `Q_MS05_FROST_REST`. Depois: Hub, Kaya, comércio e fast travel.
- **Estação da Expedição** (`LOC_FROZEN_EXPEDITION_STATION`) — TO_BUILD. Função: station. Missões: `Q_MS05_EXPEDITION`. Depois: Abrigo, quests e lore.
- **Posto do Capitão** (`LOC_FROZEN_COMMAND_POST`) — TO_BUILD. Função: boss_arena. Missões: `Q_MS05_CAPTAIN`. Depois: Revanche do Capitão.
- **Arquivo Congelado** (`LOC_FROZEN_ARCHIVE`) — EXISTING_REG001_ADAPT. Função: archive. Missões: `Q_MS05_ARCHIVE`. Depois: Arquivo histórico permanente.
- **Cidadela da Geada Negra** (`LOC_BLACK_FROST_CITADEL`) — TO_BUILD. Função: fortress. Missões: `Q_MS05_BLACK_FROST`. Depois: Revanche do General.
- **Portão de Valedouro** (`LOC_VAL_GATE`) — EXISTING_RUNTIME. Função: fortification. Missões: `Q_MS05_SIEGE`. Depois: Defesa narrativa, entrada da cidade e marco de retorno.

## Ato 6 — Maré sem Lua
**Região:** Costas e Ilhas Perdidas · **Níveis:** 60–72

- **Porto das Brumas** (`LOC_MIST_PORT`) — TO_BUILD. Função: port. Missões: `Q_MS06_MIST_PORT`. Depois: Hub marítimo e transporte.
- **Farol Gêmeo** (`LOC_TWIN_LIGHTHOUSE`) — TO_BUILD. Função: lighthouse. Missões: `Q_MS06_LIGHTHOUSE`. Depois: Fast travel marítimo e landmark.
- **Templo Submerso** (`LOC_SUNKEN_TEMPLE`) — TO_BUILD. Função: dungeon. Missões: `Q_MS06_SUNKEN_TEMPLE`. Depois: Dungeon repetível.
- **Estaleiro das Ilhas Perdidas** (`LOC_LOST_ISLAND_SHIPYARD`) — TO_BUILD. Função: shipyard. Missões: `Q_MS06_HOLLOW_FLEET`. Depois: Base naval e contratos.
- **Observatório das Marés** (`LOC_TIDAL_OBSERVATORY`) — TO_BUILD. Função: observatory. Missões: `Q_MS06_GENERAL_TIDE`. Depois: Revanche do General e navegação.

## Ato 7 — A Terra que Sangra
**Região:** Terras Corrompidas · **Níveis:** 72–88

- **Último Bastião** (`LOC_LAST_BASTION`) — TO_BUILD. Função: fortress. Missões: `Q_MS07_LAST_BASTION`. Depois: Hub militar da frente final.
- **Obeliscos de Guerra** (`LOC_WAR_OBELISKS`) — TO_BUILD. Função: ritual_network. Missões: `Q_MS07_OBELISKS`. Depois: Eventos mundiais pós-campanha.
- **Catedral Partida** (`LOC_BROKEN_CATHEDRAL`) — TO_BUILD. Função: dungeon. Missões: `Q_MS07_CATHEDRAL`. Depois: Dungeon e arquivo do Pacto.
- **Conselho de Guerra das Seis Coroas** (`LOC_ALLIANCE_WAR_COUNCIL`) — TO_BUILD. Função: war_camp. Missões: `Q_MS07_COUNCIL`. Depois: Mandatos e conteúdo de alto nível.
- **Cidadela da Coroa Oca** (`LOC_HOLLOW_CROWN_CITADEL`) — TO_BUILD. Função: fortress. Missões: `Q_MS07_GENERAL_VOID`. Depois: Revanche do último general.

## Ato 8 — O Coração da Coroa Oca
**Região:** Coração Abissal · **Níveis:** 88–100

- **Portão do Último Mapa** (`LOC_LAST_MAP_GATE`) — TO_BUILD. Função: portal. Missões: `Q_MS08_LAST_MAP_GATE`. Depois: Entrada do conteúdo final.
- **Salão dos Caminhos Perdidos** (`LOC_HALL_LOST_PATHS`) — TO_BUILD. Função: surreal_dungeon. Missões: `Q_MS08_LOST_PATHS`. Depois: Desafio pós-jogo.
- **Arquivo do Vazio** (`LOC_VOID_ARCHIVE`) — TO_BUILD. Função: boss_arena. Missões: `Q_MS08_CARTOGRAPHER`. Depois: Revanche bloqueada após conclusão se desejado.
- **Antecâmara do Trono Vazio** (`LOC_EMPTY_THRONE_ANTECHAMBER`) — TO_BUILD. Função: story_room. Missões: `Q_MS08_FIRST_TRAVELER`. Depois: Memórias de Adrian.
- **Trono da Coroa Oca** (`LOC_EMPTY_THRONE`) — TO_BUILD. Função: final_boss_arena. Missões: `Q_MS08_AZHAREL`. Depois: Memorial da campanha.
- **Limiar da Terra** (`LOC_EARTH_GATE`) — TO_BUILD. Função: world_gate. Missões: `Q_MS08_EARTH_GATE`, `Q_MS08_CHOICE`. Depois: Portal estabilizado e epílogo.

## Construções novas obrigatórias
Total: **37** estruturas/complexos a construir para a campanha definitiva.

- `LOC_SIX_CROWNS_ARCHIVE` — Arquivo das Seis Coroas (berco_valedouro)
- `LOC_FOREST_STONE_BRIDGE` — Ponte de Pedra da Fronteira (floresta_ancestral)
- `LOC_FOREST_RANGER_LODGE` — Casa dos Guardas Verdes (floresta_ancestral)
- `LOC_FOREST_ROOT_SHRINES` — Santuários de Raiz (floresta_ancestral)
- `LOC_MEMORY_TREE` — Árvore-Memória (floresta_ancestral)
- `LOC_HOLLOW_ROOT_ARENA` — Coração da Raiz Oca (floresta_ancestral)
- `LOC_FOREST_CARTOGRAPHER_SHRINE` — Santuário dos Cartógrafos (floresta_ancestral)
- `LOC_AMBER_POST` — Posto de Âmbar (deserto_ruinas)
- `LOC_EDRAVAR_OCCUPIED_CITY` — Edravar Ocupada (deserto_ruinas)
- `LOC_EDRAVAR_RESISTANCE_CISTERN` — Cisterna da Resistência (deserto_ruinas)
- `LOC_ASH_OBSERVATORY` — Observatório de Cinzas (deserto_ruinas)
- `LOC_ASH_CITADEL` — Cidadela da Cinza (deserto_ruinas)
- `LOC_MARSH_STILT_VILLAGE` — Vila das Lanternas (pantanos_sombrios)
- `LOC_DROWNED_BELL_TOWER` — Torre do Sino Afogado (pantanos_sombrios)
- `LOC_FLOODED_MONASTERY` — Mosteiro Inundado (pantanos_sombrios)
- `LOC_REED_SANCTUM` — Santuário dos Juncos (pantanos_sombrios)
- `LOC_REED_THRONE` — Trono dos Juncos (pantanos_sombrios)
- `LOC_MARSH_ECHO_SLICE` — Comporta dos Ecos (pantanos_sombrios)
- `LOC_FROZEN_EXPEDITION_STATION` — Estação da Expedição (montanhas_nevadas)
- `LOC_FROZEN_COMMAND_POST` — Posto do Capitão (montanhas_nevadas)
- `LOC_BLACK_FROST_CITADEL` — Cidadela da Geada Negra (montanhas_nevadas)
- `LOC_MIST_PORT` — Porto das Brumas (costas_ilhas_perdidas)
- `LOC_TWIN_LIGHTHOUSE` — Farol Gêmeo (costas_ilhas_perdidas)
- `LOC_SUNKEN_TEMPLE` — Templo Submerso (costas_ilhas_perdidas)
- `LOC_LOST_ISLAND_SHIPYARD` — Estaleiro das Ilhas Perdidas (costas_ilhas_perdidas)
- `LOC_TIDAL_OBSERVATORY` — Observatório das Marés (costas_ilhas_perdidas)
- `LOC_LAST_BASTION` — Último Bastião (terras_corrompidas)
- `LOC_WAR_OBELISKS` — Obeliscos de Guerra (terras_corrompidas)
- `LOC_BROKEN_CATHEDRAL` — Catedral Partida (terras_corrompidas)
- `LOC_ALLIANCE_WAR_COUNCIL` — Conselho de Guerra das Seis Coroas (terras_corrompidas)
- `LOC_HOLLOW_CROWN_CITADEL` — Cidadela da Coroa Oca (terras_corrompidas)
- `LOC_LAST_MAP_GATE` — Portão do Último Mapa (coracao_abissal)
- `LOC_HALL_LOST_PATHS` — Salão dos Caminhos Perdidos (coracao_abissal)
- `LOC_VOID_ARCHIVE` — Arquivo do Vazio (coracao_abissal)
- `LOC_EMPTY_THRONE_ANTECHAMBER` — Antecâmara do Trono Vazio (coracao_abissal)
- `LOC_EMPTY_THRONE` — Trono da Coroa Oca (coracao_abissal)
- `LOC_EARTH_GATE` — Limiar da Terra (coracao_abissal)

## Estruturas atuais reaproveitadas/adaptadas
Total: **10** estruturas/locais já existentes ou adaptáveis.

- `LOC_VAL_GATE` — Portão de Valedouro — EXISTING_RUNTIME
- `LOC_VAL_GUILD` — Guilda dos Aventureiros de Valedouro — EXISTING_RUNTIME
- `LOC_VAL_NORTH_ROAD` — Estrada Norte — EXISTING_REG001 — POI atual: `REG001_POI_CAMP_LENHADOR`
- `LOC_FIRST_WIND_RUINS` — Ruínas do Primeiro Vento — EXISTING_REG001 — POI atual: `REG001_POI_RUINAS_PRIMEIRO_VENTO`
- `LOC_ALPHA_CLEARING` — Clareira do Alfa — EXISTING_REG001_ADAPT — POI atual: `REG001_POI_ANCIAO_CLAREIRA`
- `LOC_ECHO_MINE` — Mina do Eco — EXISTING_RUNTIME_ADAPT — POI atual: `REG001_POI_CRIPTA_ENTRADA`
- `LOC_ECHO_MINE_CORE` — Câmara do Guardião — EXISTING_RUNTIME — POI atual: `REG001_POI_DG_CHECKPOINT`
- `LOC_AMBER_CARAVAN` — Caravana de Âmbar — EXISTING_REG001 — POI atual: `REG001_POI_CARAVANA`
- `LOC_FROST_REST` — Pouso da Geada — EXISTING_REG001 — POI atual: `REG001_POI_POUSO_GEADA`
- `LOC_FROZEN_ARCHIVE` — Arquivo Congelado — EXISTING_REG001_ADAPT — POI atual: `REG001_POI_SEGREDO_GELO`

## Gate visual narrativo
Uma região não pode ser considerada pronta para campanha principal enquanto não possuir, no mínimo:
- hub ou ponto de chegada legível;
- landmark principal;
- construção ligada à revelação narrativa do ato;
- dungeon/complexo principal quando previsto;
- arena exclusiva do boss do ato;
- rota visual coerente conectando esses pontos;
- estado pós-missão definido para estruturas persistentes.
