# CRÔNICAS DE VALEDOURO — TOPOLOGIA MACRO DA CAMPANHA v1

**Objetivo:** impedir que regiões, landmarks, dungeons e construções da história principal sejam posicionados de forma desconectada das missões.

**Fontes:** `game/data/main_story_v1.json`, `game/data/story_locations_v1.json`, `docs/canon/MAIN_STORY_CANON_v1.md`, `docs/canon/MAIN_STORY_CONSTRUCTION_PLAN_v1.md` e `.claude/skills/valedouro-map-logic/SKILL.md`.

## Regra global

A campanha deve ser legível como uma viagem física e narrativa:

**Berço de Valedouro**
→ **Floresta Ancestral**
→ **Deserto e Ruínas / Edravar**
→ **Pântanos Sombrios**
→ **Montanhas Nevadas**
→ **Costas e Ilhas Perdidas**
→ **Terras Corrompidas**
→ **Coração Abissal**.

Fast travel pode reduzir retorno, mas não substituir a coerência geográfica da primeira travessia.

Toda estrutura principal precisa responder:
1. qual quest a apresenta;
2. por que fica exatamente ali;
3. como se conecta à rota;
4. qual função mantém depois da quest;
5. qual mudança física persiste após o evento.

## Ato I — Berço de Valedouro

Sequência:
`LOC_VAL_GATE`
→ `LOC_VAL_GUILD`
→ `LOC_VAL_NORTH_ROAD`
→ `LOC_FIRST_WIND_RUINS`
→ `LOC_ALPHA_CLEARING`
→ `LOC_ECHO_MINE`
→ `LOC_ECHO_MINE_CORE`
→ `LOC_SIX_CROWNS_ARCHIVE`.

Função macro: apresentar o mundo, o Eco, o primeiro mapa e Adrian Vale.

Saída física do ato:
Arquivo das Seis Coroas → estrada de fronteira → Ponte de Pedra da Floresta.

## Ato II — Floresta Ancestral

Sequência:
`LOC_FOREST_STONE_BRIDGE`
→ `LOC_FOREST_RANGER_LODGE`
→ `LOC_FOREST_ROOT_SHRINES`
→ `LOC_MEMORY_TREE`
→ `LOC_HOLLOW_ROOT_ARENA`
→ `LOC_FOREST_CARTOGRAPHER_SHRINE`.

Topologia:
fronteira estreita → clareira dos Guardas → três braços exploráveis → centro monumental → profundidade corrompida → ruína elevada de revelação.

Função macro: mostrar que Adrian já foi aliado e que a corrupção da Coroa é externa à floresta.

Saída:
o Santuário dos Cartógrafos aponta o jogador para as rotas comerciais rumo a Edravar.

## Ato III — Deserto e Ruínas / Edravar

Sequência:
`LOC_AMBER_CARAVAN`
→ `LOC_AMBER_POST`
→ `LOC_EDRAVAR_OCCUPIED_CITY`
→ `LOC_EDRAVAR_RESISTANCE_CISTERN`
→ `LOC_ASH_OBSERVATORY`
→ `LOC_ASH_CITADEL`.

Topologia:
rota comercial aberta → posto fortificado → cidade ocupada → subterrâneo da resistência → elevação científica/mística → fortaleza militar.

Por que funciona:
- caravana depende de estrada;
- posto existe em cruzamento de rota e água;
- cisterna fica sob a cidade;
- observatório precisa de horizonte aberto e terreno alto;
- cidadela controla a ocupação e a rota de saída.

Estado persistente:
a derrota do General da Cinza enfraquece a presença militar, mas Edravar continua marcada pela guerra.

Saída:
rota de refugiados/comércio conduz às zonas úmidas do Ato IV.

## Ato IV — Pântanos Sombrios

Sequência:
`LOC_MARSH_STILT_VILLAGE`
→ `LOC_DROWNED_BELL_TOWER`
→ `LOC_FLOODED_MONASTERY`
→ `LOC_REED_SANCTUM`
→ `LOC_REED_THRONE`
→ `LOC_MARSH_ECHO_SLICE`.

Topologia:
vila sobre palafitas → landmark vertical visível à distância → dungeon inundada → santuário profundo → arena → infraestrutura ritual que controla o fluxo.

Geografia:
água é a infraestrutura da região. Passarelas, barcos rasos, ilhotas e troncos elevados substituem estradas comuns.

Estado persistente:
fechar a Comporta dos Ecos deve alterar água, iluminação e atividade ambiental de áreas-chave sem secar o pântano por completo.

Saída:
uma rota elevada/antiga conduz às encostas frias do Ato V.

## Ato V — Montanhas Nevadas

Sequência:
`LOC_FROST_REST`
→ `LOC_FROZEN_EXPEDITION_STATION`
→ `LOC_FROZEN_COMMAND_POST`
→ `LOC_FROZEN_ARCHIVE`
→ `LOC_BLACK_FROST_CITADEL`
→ retorno a `LOC_VAL_GATE` para o cerco.

Topologia:
pouso protegido → estação de expedição → posto militar abandonado/corrompido → arquivo escondido no gelo → cidadela dominante → retorno dramático a Valedouro.

Geografia:
rotas seguem vales, gargantas e passagens; estruturas de comando ocupam altura e visibilidade.

Virada espacial:
o primeiro grande retorno à região inicial deve mostrar que o mundo mudou: Valedouro sofre ataque como consequência direta da descoberta no Arquivo Congelado.

Saída:
após o cerco, a campanha procura uma rota marítima para a próxima linha de Eco.

## Ato VI — Costas e Ilhas Perdidas

Sequência:
`LOC_MIST_PORT`
→ `LOC_TWIN_LIGHTHOUSE`
→ `LOC_SUNKEN_TEMPLE`
→ `LOC_LOST_ISLAND_SHIPYARD`
→ `LOC_TIDAL_OBSERVATORY`.

Topologia:
porto/hub → faróis pareados em pontos de navegação → ruína submersa → infraestrutura naval ocupada → observatório costeiro elevado.

Geografia:
a água deixa de ser obstáculo e vira estrada. O jogador deve ler rotas marítimas, canais e linhas de visão entre ilhas.

Persistência:
o Farol Gêmeo desbloqueia navegação/fast travel marítimo; o estaleiro continua útil para contratos; o observatório permanece como ponto de navegação e revanche.

Saída:
rota naval desemboca no principal front da guerra.

## Ato VII — Terras Corrompidas

Sequência:
`LOC_LAST_BASTION`
→ `LOC_WAR_OBELISKS`
→ `LOC_BROKEN_CATHEDRAL`
→ `LOC_ALLIANCE_WAR_COUNCIL`
→ `LOC_HOLLOW_CROWN_CITADEL`.

Topologia:
fortaleza aliada na borda → três objetivos distribuídos no território → dungeon histórica no centro → conselho avançado após recuperação do pacto → cidadela inimiga no fundo da frente.

Geografia:
as Terras Corrompidas precisam parecer uma frente militar contínua, com trincheiras, estradas quebradas, acampamentos, campos de batalha e linhas de abastecimento.

Os três Obeliscos devem formar rede espacial coerente e não três arenas desconectadas.

Persistência:
cada obelisco destruído reduz visualmente a corrupção de uma parcela do mapa; destruir os três abre/estabiliza o corredor para a Catedral e depois a cidadela.

Saída:
a Cidadela da Coroa Oca guarda o acesso ao Portão do Último Mapa.

## Ato VIII — Coração Abissal

Sequência:
`LOC_LAST_MAP_GATE`
→ `LOC_HALL_LOST_PATHS`
→ `LOC_VOID_ARCHIVE`
→ `LOC_EMPTY_THRONE_ANTECHAMBER`
→ `LOC_EMPTY_THRONE`
→ `LOC_EARTH_GATE`.

Topologia:
portal de entrada → dungeon surreal de transição → arquivo/boss → sala de confronto pessoal → arena final → limiar estabilizado.

Regra visual:
o Coração Abissal pode distorcer motivos das sete regiões anteriores, mas nunca virar colagem aleatória. Cada fragmento deve ter função de memória, ameaça ou navegação.

Persistência:
após Azharel:
- guerra encerrada;
- portal estabilizado;
- Trono da Coroa Oca vira memorial;
- Limiar da Terra permanece acessível;
- escolha final não apaga save nem bloqueia pós-jogo.

## Conexões obrigatórias entre atos

### I → II
Arquivo das Seis Coroas revela a linha da Floresta.
Conexão física: estrada/fronteira + Ponte de Pedra.

### II → III
Santuário dos Cartógrafos revela Edravar.
Conexão física: saída da floresta para rota de comércio e encontro com Caravana de Âmbar.

### III → IV
A queda do General da Cinza libera a passagem para os corredores úmidos.
Conexão física: antiga rota baixa/refugiados até o pântano.

### IV → V
A Comporta dos Ecos revela/estabiliza uma rota para o norte.
Conexão física: terreno sobe progressivamente do pântano para encostas frias.

### V → VI
Após o cerco de Valedouro, buscar a próxima linha exige rota marítima.
Conexão física: estrada de retorno ao sul/leste até o Porto das Brumas ou transição regional equivalente coerente.

### VI → VII
A derrota do General da Maré libera transporte para a frente.
Conexão física: desembarque militar/comercial próximo ao Último Bastião.

### VII → VIII
Derrota do General do Eco Vazio abre o Portão do Último Mapa.
Conexão física e narrativa: transição explícita de mundo físico para domínio da Coroa Oca.

## Política de estados persistentes

Para chefes e estruturas principais:
- primeira conclusão = estado narrativo persistente;
- revanche = estado de combate temporário;
- save/load sempre restaura o estado narrativo;
- renderer não possui verdade própria;
- quest/world state é a fonte de verdade.

Aplicar a:
- Guardião do Eco;
- Arauto da Raiz Oca;
- General da Cinza;
- Dama dos Juncos;
- Capitão/General da Geada;
- General da Maré;
- General do Eco Vazio;
- demais bosses repetíveis.

Azharel e Cartógrafo Vazio podem ter política de revanche específica de pós-jogo, sem alterar o final canônico.

## Critérios de implantação no mapa

Uma construção principal só pode receber posição final quando:
1. o caminho de chegada está definido;
2. existe justificativa “por que aqui?” com pelo menos dois fatores;
3. a silhueta é visível antes do jogador chegar, quando apropriado;
4. há espaço de gameplay ao redor;
5. colisões e navegação foram consideradas;
6. o estado antes/depois da missão foi especificado;
7. sua função pós-missão foi preservada.

## Regra para assets produzidos antes da implantação

Assets podem ser modelados modularmente antes da posição final, mas devem trazer:
- footprint;
- ponto de entrada;
- direção principal/fachada;
- âncora de chão;
- zonas que podem receber props;
- zonas proibidas para colisão;
- variantes de estado quando exigidas pela história.

O Gerente GPT posicionará os conjuntos finais no mapa após o lote de assets correspondente estar validado.
