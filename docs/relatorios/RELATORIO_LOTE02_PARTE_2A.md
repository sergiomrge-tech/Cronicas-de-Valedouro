# Lote 2 / Ato II — Parte 2A: Fronteira e hub (Ponte de Pedra + Casa dos Guardas Verdes)

Base: `LOTE02_ATO2_STORY_TO_MAP_v1.md` (Gerente GPT). Branch `ccr-bb54cda9-tvw178`. Nenhum ID canônico novo (`LOC_*`, `Q_MS02_*`); todos os assets `MODELED_PENDING_GATE`, sem REWORKED/HOLD.

## Escopo desta parte (ordem do §9 do documento do Gerente)
Ponte de Pedra e ecótono (2A-1) e Casa dos Guardas Verdes com clareira, rotas e estados pré/durante/pós-defesa (2A-2). As Partes 2B–2E (três raízes, Árvore-Memória, Coração da Raiz Oca, Santuário dos Cartógrafos) seguem depois, cada uma validada antes da seguinte.

## Decisão de arquitetura (respeitando §11)
O Gerente faz a implantação final no mapa. Por isso o lote entrega **kit de assets + composições locais por `LOC_*` + estados**, e não coordenadas finais no REG_001:
- `game/data/act02_compositions.json` (gerado por `game/tools/act02/build_compositions.py`): objetos em coordenadas locais, trilhas, água, exclusões (trilha, rio, plataforma, fogueira, pátio) e capturas por estado.
- Chaves de estado canônicas: `quest:<Q_MS02_*>` = concluída, `quest:<Q_MS02_*>:active` = em curso, prefixo `!` = ausente. Nada de flags paralelas: na implantação o Gerente liga estas chaves à fonte de verdade de quests/mundo (mesmo padrão do Guardião: `elites:<ID>` para bosses).
- Palco de revisão real: `game/tests/act02_stage.gd` + `qa_capture_act02.gd` usam o **mesmo renderer do jogo** (`REGR.draw_item/cast_item`, `ground_bake`), sombras projetadas incluídas.

## Assets (23, prefixo `flo_`, Blender pro-pipeline, 64 cores Oklab, QC 23/23 PASS)
Vegetação/terreno: `flo_ancient_tree_a/_b`, `flo_claw_tree` (árvore arranhada), `flo_root_arch` (porta natural), `flo_stone_moss`, `flo_root_run`, `flo_glow_mushrooms`, `flo_fern_patch`.
Ponte: `flo_bridge_span`, `flo_bridge_span_broken` (guarda-corpo quebrado), `flo_bridge_ramp`, `flo_border_marker`, `flo_rest_platform`.
Casa dos Guardas: `flo_ranger_lodge`, `flo_ranger_watch`, `flo_ranger_shed`, `flo_herb_bench`, `flo_map_table`, `flo_training_target`, `flo_weapon_rack_green`, `flo_palisade_organic`, `flo_palisade_broken`, `flo_barricade_improvised`.
Identidade própria da região: pedra pré-guerra verde-acinzentada com musgo, cascas antigas de sulcos fundos, copas de massa escura com tufos claros, bioluminescência discreta (cogumelos), verde dos Guardas (emblema/panos).
Reaproveitados (existentes): pinheiros/bétulas do Berço (margem oeste), juncos, rochas, fogueira, tora, arbustos e flores.

## Locais
**LOC_FOREST_STONE_BRIDGE** (`Q_MS02_BORDER`): rio real sob o arco (vão aberto), rampas, marcos de fronteira em ambos os lados, plataforma de descanso, trilha antiga; margem oeste = árvores do Berço, margem leste = árvores ancestrais, raízes, cogumelos e pedras engolidas; **estados:** antes = trilha interior fechada por raízes; depois = raízes abertas (ponte vira ligação persistente/fast travel).
**LOC_FOREST_RANGER_LODGE** (`Q_MS02_RANGERS`): casa apoiada em duas árvores ancestrais, posto de observação, depósito, bancada de ervas, mesa de mapas, alvos, arsenal, fogueira, trilhas de patrulha, paliçada em trechos (não contínua), árvore com garras; **estados:** pré = barricadas improvisadas e paliçada quebrada; durante = pontos de entrada das criaturas marcados por raízes no chão; pós = paliçada reparada, barricadas removidas, rotina retomada.
Cada objeto tem função (patrulha, defesa, suprimento, cartografia, treino). Nenhuma estrutura grande sem uso.

## Capturas reais (Godot 4.7.2 + xvfb) — `docs/visual_qa/story/act02/`
`FLO_2A_PONTE_ANTES/DEPOIS`, `FLO_2A_CASA_PRE/DURANTE/POS` e folha do kit `FLO_2A_kit_assets_folha`. (A folha do kit é render Blender, identificada como tal; as demais são frames do Godot.)

## Testes
Novo `tests/act02_compositions.gd`: LOCs existentes e na região `floresta_ancestral`, assets carregáveis, sem REWORKED/HOLD, estados só por quests canônicas, ≥2 estados capturáveis por local. Suíte completa: **17/17 PASS** (os 15 anteriores + `guardian_state` + `act02_compositions`; `qa_capture_*` ficam fora do headless).

## Limitações / decisões
- Ainda não há região `floresta_ancestral` no `reg001_world.json`: a implantação (mapa, colisões, POIs, rotas 2–3 atalhos, mirante, segredos) é do Gerente; as composições já trazem exclusões e colisões nos assets (`footprint`/círculos).
- Cenário de referência usa a arte pintada do bosque como piso (não é o chão final da Floresta Ancestral); um piso próprio fica para a integração.
- Rios/cascatas reais de cada braço (Raiz da Água) serão tratados na Parte 2B.
- Falta luz/partícula dinâmica no jogo (feixes e brilho são pós-efeitos do palco); implementação de runtime fica com a integração.
