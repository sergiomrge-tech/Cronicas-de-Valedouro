# CHECKPOINT — Fechamento visual profissional da REG_001 (pré-Etapa 2)

**Branch:** `ccr-bb54cda9-tvw178` · **Engine:** Godot 4.7.2 · **Nada foi promovido a APPROVED** (tudo novo = `MODELED_PENDING_GATE`).
**Etapa 2 (combate) NÃO foi iniciada.**

## Mudança de método
O fluxo "primitivas → render procedural → asset final" deixou de ser usado como arte final. O novo pipeline **executável** (`game/tools/art_pipeline/`, ver `README_VK.md`)
roda o Blender 5.0 headless (`pip install bpy`) com câmera ortográfica 2:1 (AZ45/EL30, 60 px/u) calibrada por marcadores contra a projeção dos APPROVED, luz upper-left,
materiais procedurais de nós (alvenaria em fiadas, tábuas, telhas por UV, rocha em estratos com musgo/neve, casca, tecido, água), pós-processo de pixel art
(alpha duro, grade de cor, limpeza de ruído, contorno, sombra de contato pontilhada) e QC (`asset_qc.py`). O modelador antigo (`game/tools/modeling`) ficou para blockout/colisão/props ainda não remodelados.
Os scripts `blender_*.py` da branch `art/pro-pixel-modeling-pipeline` foram incorporados (arquivos novos, sem sobrescrever aquela branch).

## O que foi produzido (147 assets Blender + 6 FX + terreno)
* **Landmarks:** torre de vigia (pedra/gelo), moinho animado (8 quadros), cachoeira em duas quedas animada (8 quadros), entrada de caverna talhada, santuário pulsante, cais (3) e barcos (2, balanço animado), celeiro, plantações (3), espantalho, posto de âmbar, abrigo da geada, abrigo de madeira.
* **Elevações:** platôs S/M, cordilheiras A/B, colinas, paredões, degraus, arco e pilares em Gelo/Rio/Deserto/Colinas, com estratos, lábios de relva/neve/areia, entulho, hera e pingentes de gelo.
* **Natureza/props:** pinheiro (+neve), bétula, árvore seca, palmeira, cactos, 5 arbustos, rochas/blocos, espigão de gelo, dunas em monte com vento, montículo de neve, tendas (3), poço, carroça, fogueira animada, placa, tronco, feno, cercas (4), portão, muro baixo, baús (3, com tesouro aberto), ruínas (arcos, colunas, muros), altares animados, obelisco, estátua, bandeiras animadas, lampiões, barris, caixas, carroça de mercado, banco, jardineira.
* **NPCs (14 famílias):** aldeão/aldeã, ancião, criança, fazendeiro, mercador, viajante, caçadora, guarda, ferreiro, alquimista, mestre da guilda, moleiro, lojista — 5 direções (+espelho) × (4 idle + 8 caminhada). Substituem o `hero_body` tingido (`life_art.gd`).
* **Fauna (7 espécies):** cervo, raposa, lebre, cabra, camelo (idle+caminhada), ave (voo 6 quadros), peixe (nado + ondulação 6 quadros).
* **Interiores:** 5 baias de parede (janela, porta, lareira, nicho, lisa) + poste; pisos de tábua clara/escura e laje com padrão contínuo em malha 2:1; composição extra de POIs.
* **FX de interação:** baú, colheita, mineração, escavação, santuário, segredo (ganchos em `reg001_gameplay.gd`).
* **Terreno:** chão assado sem grade (etapa anterior) + dunas com barlavento/sotavento/crista e derivas de neve orientadas pelo vento.
* **Cidade/povoados (APPROVED):** 11 casas compostas, muralha sul + portão, lagoas `water_edge`, loja, árvores; mais casas nos povoados.

## Revisão dos MODELED antigos (A/B/C/D)
`docs/art/PRO_ART_REVIEW_MODELED.md` / `game/data/reg001_art_review.json`: PRO 215 (inclui 62 de terreno e 6 FX), A 35, B 25, D 17 (retirados/substituídos). Nenhum promovido a APPROVED.

## Gate técnico (Godot 4.7.2 real)
13/13 testes PASS (parser/import/runtime, smoke, world travel, vertical slice, reg001 world/gameplay, modeled assets 292, catálogo, mobile input, hero/monster/boss).
Validadores estáticos PASS. QC: 0 falhas; 0 alpha parcial fora do valor único da sombra baked.
Capturas REAIS (58): `docs/visual_qa/pro/game/`; folhas ANTES/DEPOIS: `docs/visual_qa/pro/antes_depois_*.png`.

## Ainda abaixo do padrão / pendente do Diretor
* Formas de terreno (platôs) ainda "blocadas" em silhueta; copas-de-cesto dos arbustos; rostos de NPC pequenos; vela do barco; santuário com pilares finos; dunas em monte ainda simples.
* 25 assets B (refino leve) e o mobiliário A dependem de nova rodada; terreno base ainda é assado por ruído (macroformas de dunas/neve novas, mas sem tiles pintados à mão).
* Cachoeira/caverna: integração de colisão e profundidade validada, ajuste fino de composição do lago com a margem recomendado.
* Gate visual do Diretor é o único passo de aprovação restante.

## Merge da v2 (art/pro-pixel-modeling-pipeline-v2)
Incorporados: `character_art.gd` (candidatos NPC/fauna com fallback), gates `visual_complexity_gate.py`, `terrain_visual_metrics.py`, `qa_capture_art_gate.gd`, teste `character_art`, benchmarks e scripts Blender de NPC/fauna.
Resolução de conflitos: **`life_art.gd` mantido como caminho principal** de NPC/fauna (cidade, interiores, POIs, animais); `character_art.gd` fica como segunda opção antes do tint legado. `asset_qc.py` e SKILL mantidos na versão desta branch (com regras §18 e alpha único de sombra); fila de arte (`reg001_professional_art_queue.json`) tomada da v2.
Gate de complexidade vs APPROVED (`docs/art/PRO_ART_COMPLEXITY_VS_APPROVED.json`): 15 de 17 amostras abaixo de ~0,4x–0,5x da densidade de arestas/variação local dos APPROVED — diagnóstico de que ainda falta detalhe fino (rachaduras, juntas, texturas) nos landmarks e elevações.

## Atualização final do dia (terreno + detalhe fino)
Terreno: 18 decalques modelados, relevo macro, lábios de estrada/água, transições orgânicas (ver `docs/relatorios/RELATORIO_DIA_2026-09-29_PARA_GERENTE_GPT.md`, §4). Detalhe fino: passada de ID por objeto, texturas mais densas, falésias em estratos; gate de complexidade 2/17 → 4/17 (arestas 0,42× → 0,53× dos APPROVED). 14/14 testes Godot 4.7.2 PASS; 58 capturas reais em `docs/visual_qa/pro/game/`.

## Atualização — transições de bioma, relevo e level design (2026-09-29)
- **Transições harmônicas**: `ground_detail.harmonize` mistura a cor de baixa frequência entre famílias de bioma (sigma 60 px, faixa 90 px) e `blend_regions` + `warpL` tornam as fronteiras orgânicas. O bake exporta `game/data/reg001_biome_grid.json`; `world_map.veg_biome` e `reg001_procedural.build_chunk` usam a grade para misturar a vegetação do bioma vizinho de forma gradual (ecótono). Estrada de neve recolorida (menos contraste).
- **Relevo**: gerador de formações em `build_world.py` (`poly`, `mesa`, `terraces`, `arc`, `best`) — 104 peças elevadas compostas (antes 45): muralha glacial, anfiteatro do Círculo de Gelo, garganta, cordilheira e terraços das colinas, cânion e mesas do deserto, cristas do vale, colinas dos campos, cristas do bosque. Vãos abrem sozinhos onde há trilha/POI/água.
- **Level design**: `docs/planning/REG001_LEVEL_DESIGN.md` (foco, massas, espaço negativo, segredos por região).
- **Validação**: 14/14 testes Godot em PASS (`reg001_world`: 870 objetos, 4975 células conectadas), capturas reais 59–66 e 16/17/21/50/51/57 em `docs/visual_qa/pro/game/`.
- **Limites honestos**: relevo ainda usa o kit MODELED_PENDING_GATE (nenhuma promoção a APPROVED); algumas formações colocam menos peças que o ideal por causa de POIs/trilhas; ecótono de decalques específico e sombras projetadas do relevo ficam para a próxima etapa.

## Atualização — assets de relevo e sombra projetada (2026-09-29)
- **27 assets novos de relevo** (`pro_relief.py`, Blender, 64 cores, QC 30/30): colinas amplas/baixas, fins e cantos de paredão, rampas. Manifesto 337 assets (nature 150), catálogo e SHA atualizados.
- **Sombra projetada**: `relief_shadows` no bake do piso (106 peças), luz cima‑esquerda, 3 faixas de intensidade + dither de Bayer.
- **Formações**: fins de paredão nas pontas, rampas nas mesas/terraços, colinas amplas/baixas no pé e no preenchimento; 112 peças elevadas.
- **Validação**: 14/14 testes Godot PASS (`reg001_world`: 878 objetos, 4951 células conectadas, 165 ms de montagem de chunks, pico visível 192), validador estático PASS, capturas reais ANTES/DEPOIS em `docs/visual_qa/pro/relevo/`.
- **Limites honestos**: nada foi promovido a APPROVED; colina baixa de grama é mais saturada que o piso; o Bosque (instância separada) e as estruturas altas ainda não projetam sombra; algumas formações colocam menos peças que o desenhado.

## Atualização — lógica das construções conforme a história (2026-09-29)
- **Skill salva** em `.claude/skills/valedouro-map-logic/SKILL.md` (adaptada de jwynia/agent-skills *settlement-design*, Worldographer, Azgaar e H. M. Turnbull; com regras do projeto, teste "por que aqui?", regras por tipo de construção, anti‑padrões) e referenciada em `CLAUDE.md`.
- **Auditoria automática** `game/tools/reg001/audit_logic.py` (estrada/água/POI/relevo/lavouras por construção): antes 7 falhas em 20 construções, agora 0 (`docs/art/REG001_LOGIC_AUDIT.json`).
- **Matriz história → mapa** em `docs/planning/REG001_STORY_TO_MAP.md` (canon, quest flow, level design, lore) com lacunas conhecidas.
- **Correções**: entrada da masmorra saiu da muralha da cidade e foi para o **Portão do Primeiro Limiar** nas Ruínas do Primeiro Vento (rota Cidade→Bosque→Ruínas→Dungeon; `main.gd`, teste `vertical_slice.gd` e texto do contrato ajustados; muralha sul fechada); **Cripta** escavada no flanco de colina; **Taverna do Viajante** na praça (descanso/save); **casa de posta** na Estação das Colinas; **moinho com lavouras**; **cais com carga**; **poço** que estava dentro do rio movido.
- **Validação**: 14/14 testes Godot PASS (`reg001_world`: 916 objetos, 63 POIs, 4914 células conectadas), validador estático PASS, capturas reais 67–74 e ANTES/DEPOIS em `docs/visual_qa/pro/logica/`.
- **Limites**: nada promovido a APPROVED; mecanismo do altar não gateia a dungeon (fluxo de missão intocado); faltam córregos (Bosque/Campos/Vale), templo e residência do NPC principal.

## Atualização — sombra projetada em todos os assets (2026-09-29)
- **Sistema**: `game/scripts/cast_shadow.gd` (luz cima‑esquerda → sombra para baixo‑direita, cisalhamento 0,55/0,28 por px de altura). Passada única `REGR.draw_shadows` sob todos os objetos (após o piso, antes de NPCs/objetos/herói).
  - **Sprites modelados e APPROVED** (árvores, casas de campo, torres, moinho, celeiro, cactos, tendas, poço, estátuas, muralhas, portões, baús, tochas…): a própria silhueta cisalhada pela altura acima do pé (polígono texturizado em preto).
  - **Casas** (porta+janela+telhado): UMA sombra de caixa (sem empilhar as três peças). **Muralhas/loja/portão da cidade** e **árvores APPROVED**: sombra própria em `main.gd`.
  - **Personagens, NPCs, inimigos, chefes e fauna**: `CAST.figure` (contato + projeção afinada) via `draw_shadow_oval`.
  - **Relevo**: continua com sombra assada no piso (`ground_detail.relief_shadows`, agora com o mesmo ângulo).
  - Sem sombra por regra: decalques, água, lavouras, flores/grama, interior e FX (rasteiros).
- **Teste** `tests/cast_shadow.gd`: regras + cobertura (nenhum asset alto ficou sem sombra). 15/15 testes Godot PASS. Capturas em `docs/visual_qa/pro/sombras/`.
