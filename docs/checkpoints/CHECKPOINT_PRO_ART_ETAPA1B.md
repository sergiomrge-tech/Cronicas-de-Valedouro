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
