# Hotfix — estado pós-Guardião da Mina do Eco (Ato I)

Branch `ccr-bb54cda9-tvw178`, sobre o HEAD do Gerente GPT `c6e423a` (rebase sem conflitos; os 4 arquivos do Gerente foram preservados; `validate_main_story.py`: PASS).

## ID canônico e flag
- ID canônico encontrado: **`BOSS_GUARDIAO_PEDRA_001`** (`game/data/main_story_v1.json`, quest `Q_MS01_GUARDIAN`, local `LOC_ECHO_MINE_CORE`). Nenhum ID novo foi criado.
- Namespace: seção **`elites`** do estado do mundo (REG), padrão já usado (`elites:<ID>`). Flag = `elites:BOSS_GUARDIAO_PEDRA_001`. Fonte única: não existem flags paralelas; `kills["Guardião"]` e `quest` seguem como estão (legado) e só alimentam a migração.
- Constante: `REG.GUARDIAN_BOSS_ID` (`reg001_world.gd`).

## Lógica de save
- Ao morrer o Guardião (`main.gd`, tratamento de morte de inimigo): `REG.mark("elites", GUARDIAN_BOSS_ID)` e `save_game()` imediato. Permanente, entra em `reg001.elites` do save (versão 4, sem mudar o formato).
- Migração: save sem a flag mas com `kills["Guardião"] > 0` ou `quest >= 4` recebe a flag ao carregar. Saves v3/v4 antigos sem Guardião derrotado carregam com a mina ATIVA.

## Revanche (estado temporário separado do persistente)
- Interação no Núcleo (zona 3 da mina, com a flag ativa e sem Guardião vivo): diálogo "Despertar o Núcleo (revanche)". Chama `start_guardian_rematch()`: `rematch_active = true`, `REG.rematch_boss = <ID>` e o Guardião reaparece. Nada disso é salvo.
- `REG.rematch_boss` faz somente a **leitura visual** (`_flag`) da flag `elites:<ID>` retornar falso: o núcleo volta a pulsar DURANTE a luta. `has_mark`/save continuam verdadeiros.
- Fim: a morte do Guardião chama `end_guardian_rematch()`; sair da zona (`change_zone`) ou carregar o save também. O estado volta a pós-Guardião/dormente. O respawn do boss nunca altera história (`quest` só avança em `quest == 3`).

## Renderização (determinística)
- Objetos e emissores usam `hide_when` / `show_when` = `elites:BOSS_GUARDIAO_PEDRA_001` (emissores agora aceitam os dois campos: `spec.py`, `reg001_render.draw_emitters`).
- ANTES: `val_eco_core`, `val_core_floor_ring`, `dg_rune_circle` (animado), 4× `val_eco_crystal_cluster`, 2× `val_eco_vein`, paredes `val_mine_rock_wall_eco`, emissor de partículas do Eco.
- DEPOIS: variantes `_dormant` dos mesmos assets + brilho residual fraco (emissor pequeno). Sinais físicos da batalha, arquitetura, braseiros, lanternas e o portal permanecem; portal/entrada seguem acessíveis.

## Assets criados (5, `MODELED_PENDING_GATE`, QC 5/5 PASS, 64 cores)
`val_eco_core_dormant`, `val_core_floor_ring_dormant`, `val_eco_crystal_cluster_dormant`, `val_eco_vein_dormant`, `val_mine_rock_wall_eco_dormant` — mesmo modelo/escala/projeção/sombras dos originais, com material de Eco dormente (azul acinzentado, emissão ~10%).

## Arquivos alterados
`game/scripts/main.gd`, `reg001_world.gd`, `reg001_render.gd`; `game/tools/reg001/spec.py`, `build_world.py`, `validate_reg001.py`; `game/tools/art_pipeline/pro_ato1_mine.py`; manifestos/catálogo/mundo regenerados; `game/tests/reg001_world.gd`, `qa_capture_reg001.gd`, novo `game/tests/guardian_state.gd`; `game/data/reg001_capture_spots.json`.

## Testes
Novo `guardian_state` cobre: (1) mina ativa sem flag; (2) primeira derrota grava a flag; (3) save→recarregar mantém; (4) pós-Guardião = núcleo dormente (todos os assets/emissores); (5) revanche reaparece o boss sem apagar a flag; (6) fim e saída da revanche voltam ao dormente e o save não contém estado temporário; (7) portal acessível; (8) saves antigos (sem flag, com boss morto, v3) carregam. Suíte completa: **16/16 PASS** (`qa_capture_art_gate` continua fora do headless: exige tela).

## Capturas reais (Godot 4.7.2 + xvfb)
`docs/visual_qa/story/act01_hotfix_guardiao/`: `MINA_ANTES_GUARDIAO`, `MINA_POS_GUARDIAO`, `MINA_REVANCHE_ATIVA`, `MINA_APOS_REVANCHE` (a última executa a revanche real e mata o Guardião pelo fluxo de combate).

## Limitações
- O Arquivo/guilda não têm estado pós-Guardião (não pedido).
- A revanche não concede a recompensa de missão (`quest` só avança em 3→4); loot/XP de kill seguem a lógica de combate existente, não alterada.
- Assets seguem sem gate visual do Diretor.
