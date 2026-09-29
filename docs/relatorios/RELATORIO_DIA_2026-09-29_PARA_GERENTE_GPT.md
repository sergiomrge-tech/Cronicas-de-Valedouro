# RELATÓRIO DO DIA — 29/09/2026 — Crônicas de Valedouro (REG_001)

**De:** Claude (produção de assets / mundo) · **Para:** Gerente do projeto (GPT) · **Diretor:** Sergio
**Repositório:** sergiomrge-tech/Cronicas-de-Valedouro · **Branch de trabalho:** `ccr-bb54cda9-tvw178` (tudo enviado ao GitHub)
**Engine:** Godot 4.7.2 (executado de verdade, headless + capturas reais) · **Etapa 2 (combate) NÃO foi iniciada.**

---

## 1. RESUMO EXECUTIVO (para ler em 30 segundos)

* O mundo REG_001 saiu de "protótipo com primitivas" para **arte modelada em 3D real (Blender)** com o mesmo enquadramento 2:1 dos assets APPROVED.
* **310 assets no manifesto**, todos `MODELED_PENDING_GATE`. **Nenhum foi promovido a APPROVED** (só o Diretor decide). Nenhum REWORKED/HOLD entra no renderer.
* **Terreno reconstruído** (prioridade pedida): chão assado sem grade, 18 decalques modelados, relevo com luz upper-left, transições orgânicas entre biomas.
* **Detalhe fino** dos landmarks/elevações melhorou de forma medida (+25% a +60% de densidade de arestas), mas **ainda está abaixo dos APPROVED** na maioria (ver §7, honestamente).
* **Qualidade técnica:** 14/14 testes Godot 4.7.2 PASS, validadores estáticos PASS, QC de assets 0 falhas, **58 capturas reais** do jogo.
* **Pendências reais:** aprovação visual do Diretor; os "novos assets aprovados" citados não foram localizados no GitHub/Drive (ver §9); merge das branches paralelas de não-visual.

---

## 2. LINHA DO TEMPO DO QUE FOI FEITO HOJE

### 2.1 Etapa 1 — Mundo Rico REG_001 (base)
* Mundo data-driven (`reg001_world.json`, gerado por `tools/reg001/build_world.py`): **61 POIs, 815 objetos, 860 colisões, 20 trilhas, 3 passagens**, elites, baús com loot, segredos, cripta/masmorra, 4 interiores (Guilda, Ferreiro, Alquimia, Loja), IDs persistentes (`REG001_POI_*`, `REG001_OBJ_*`).
* Runtime: `reg001_world.gd`, `reg001_render.gd`, `reg001_gameplay.gd`, `reg001_procedural.gd` (vegetação procedural por chunk, seed fixa, respeitando exclusões).
* Catálogo APPROVED/MODELED/LEGACY/MISSING e IDs documentados em `docs/catalog/`.

### 2.2 Finalização de modelagem/assets (ordem do Diretor antes da Etapa 2)
* **Chão assado em chunks** (sem grade de 32 px), biblioteca de texturas contínuas, água/margens/pontes pintadas, brilhos/espuma animados.
* **Elevações e estruturas** (torre, moinho, postos, santuário, cais, barcos, celeiro, plantações, caverna, cachoeira) — primeira versão com o modelador procedural próprio.
* **Cidade e povoados com peças APPROVED** (11 casas compostas, muralha sul + portão, lagoas, loja, árvores) — a pedido do Diretor: "use os assets aprovados para criar o mapa".
* Colisão composta por asset (manifesto → colliders no mundo).

### 2.3 Mudança de direção visual (ordem obrigatória do Diretor)
Problema apontado: arte "com cara de primitiva geométrica". **O método mudou** (identidade visual mantida):
> referência APPROVED → silhueta → blockout → modelagem detalhada → materiais → desgaste → luz consistente → render 2:1 fixo → pixel art → limpeza → QC → captura no Godot → `MODELED_PENDING_GATE`.

Entregas:
1. **Blender headless executável neste ambiente** (`pip install bpy` 5.0.1) — na branch paralela os scripts Blender nunca tinham sido executados; aqui **rodam e geram os PNGs**.
2. **Pipeline VK** (`game/tools/art_pipeline/vk/` + `README_VK.md`): câmera ortográfica AZ45°/EL30°, 60 px/unidade, âncora do pé exata (verificada por marcadores), luz do alto-esquerda, sombra de contato pontilhada, materiais procedurais de nós (alvenaria em fiadas, tábuas, telhas por UV, rocha em estratos com musgo/neve, casca, tecido, água/cachoeira), rig FK de humanoides/quadrúpedes, pós-processo de pixel art (alpha duro, grade de cor, contorno, linhas internas por objeto).
3. **147 assets remodelados** + 18 decalques de terreno + 6 FX (ver §3).
4. **Paleta Oklab K-means (64 cores/folha)** aplicada; paleta única de referência extraída dos 28 APPROVED (`game/data/valedouro_palette.json`).
5. **Regras operacionais no SKILL** (§18 de `docs/art/VALEDOURO_PRO_ART_MODELING_SKILL.md`) a partir de skills públicas estudadas (Blender-Kiln, aseprite-ai-artist, PixelRefiner) — sem copiar código.
6. **Merge da branch `art/pro-pixel-modeling-pipeline-v2`** (ChatGPT) mantendo o `life_art.gd` como caminho principal de NPC/fauna; `character_art.gd` da v2 ficou como segunda opção antes do tint legado.

### 2.4 Prioridade pedida por último: TERRENO + detalhe fino
Ver §4 (terreno) e §5 (detalhe fino).

---

## 3. ASSETS — O QUE FOI CRIADO / REMODELADO

| Família | Quantidade | Observações |
|---|---|---|
| **Landmarks** | 18 | torre de vigia (pedra/gelo), moinho animado (8 quadros), cachoeira em duas quedas animada (8 quadros), entrada de caverna talhada, santuário pulsante, cais (3), barcos (2, animados), celeiro, plantações (3), espantalho, posto de âmbar, abrigo da geada, abrigo de madeira |
| **Elevações** | 28 | platôs S/M, cordilheiras A/B, paredões, colinas, degraus, arco, pilares — Gelo/Rio/Deserto/Colinas; **agora em estratos empilhados** |
| **Natureza/props** | ~80 | pinheiro (+neve), bétula, seca, palmeira, cactos, arbustos, rochas, dunas, tendas, poço, carroças, fogueira, cercas, baús (3), ruínas, altares, obelisco, estátua, bandeiras, lampiões, barris, caixas… |
| **NPCs** | 14 famílias | aldeão/aldeã, ancião, criança, fazendeiro, mercador, viajante, caçadora, guarda, ferreiro, alquimista, mestre da guilda, moleiro, lojista — 5 direções (+espelho) × (4 idle + 8 caminhada). **Substituem o `hero_body` tingido.** |
| **Fauna** | 7 espécies | cervo, raposa, lebre, cabra, camelo (idle+caminhada), ave (voo), peixe (nado+ondulação) |
| **Interiores** | 8 | 5 baias de parede (janela/porta/lareira/nicho/lisa), poste, viga, 3 pisos (tábua clara/escura/laje) com padrão contínuo |
| **FX de interação** | 6 | baú, colheita, mineração, escavação, santuário, segredo (ganchos em `reg001_gameplay.gd`) |
| **Decalques de terreno** | 18 | tufos (relva/alta/seca/gelo), flores, seixos (3 tipos), rachaduras (terra/areia/gelo), folhas, cogumelos, derivas de neve, ondulações de areia, ossos, ervas/musgo de calçada |
| **Terreno assado** | 62 | chunks 512 px do mundo + Bosque, texturas contínuas, FX de água |

**Totais do manifesto:** 310 assets = 165 `blender-pro` + 6 `pixel-sim` (FX) + 139 `kit`/terreno. Status: **310 × MODELED_PENDING_GATE**, 0 × APPROVED novos.

**Revisão A/B/C/D dos antigos MODELED** (`docs/art/PRO_ART_REVIEW_MODELED.md`): PRO 233 · A 35 (ok) · B 25 (refino leve) · C 0 · D 17 (aposentados/substituídos). Nenhum promovido.

---

## 4. TERRENO (prioridade do Diretor) — o que mudou

**Diagnóstico inicial (capturas reais):** relva plana e uniforme, biomas em blocos retangulares com bordas duras, transição cidade→campo reta, faixa de estrada de neve lisa/suja.

**Intervenções:**
1. **18 decalques modelados em Blender** (30 px/u = pixels de jogo, sem contorno, luz upper-left): espalhados por **campos de agrupamento** (manchas + áreas livres, não espalhamento uniforme) — ~4.700 no mundo + ~1.500 no Bosque.
2. **Relevo macro** com sombreamento quantizado (5 degraus + dither decorrelacionado) — colinas suaves lidas por luz.
3. **Lábios de estrada e sombra de margem:** estrada levemente rebaixada (sombra alto-esquerda, luz baixo-direita), sombra de banco na água.
4. **Transições orgânicas entre biomas** (`blend_regions`): faixas largas e irregulares por campo de pertencimento + ruído de blobs; **deformação de fronteira de grande escala** (±115 px) — acabou a linha reta.
5. **Borda irregular cidade→campo** e estrada de neve como neve compactada.
6. **Dunas e derivas com direção do vento** (barlavento suave, crista, sotavento) mais suaves.
7. **Métrica de grade (ferramenta da v2):** razão de gradiente nas grades de 32/64/128/512 px **≈ 1,0** → não há leitura de tabuleiro. (O alerta "chunk seam" da ferramenta é limiar absoluto sobre gradiente médio; o índice relativo ao baseline é 0,89 — não há costura real.)

**Evidência:** `docs/visual_qa/pro/terreno/` (ANTES/DEPOIS por bioma + mundo em meia escala) e capturas reais em `docs/visual_qa/pro/game/`.

---

## 5. DETALHE FINO DOS LANDMARKS/ELEVAÇÕES (segunda parte do pedido)

* **Gate de complexidade vs APPROVED** (ferramenta da v2) — 17 amostras:
  * 1ª medição: **2/17 passam**; densidade de arestas média **0,42×** dos APPROVED.
  * Depois das melhorias: **4/17 passam**; média **0,53×**.
  * Ganhos individuais (arestas): falésia de gelo 0,40→0,68 · platô de terra 0,42→0,67 · santuário 0,56→0,71 (passa) · torre de pedra 0,22→0,31 · palmeira 0,41→0,56 · moinho 0,39→0,48.
* **Técnicas novas:** (a) passada de **ID por objeto → linhas internas** entre partes (como o line-work dos APPROVED); (b) alvenaria/madeira/telha com **grão mais fino** e variação por telha/tábua/peça; (c) **falésias em estratos empilhados** (lajes com recuos, saliências e blocos soltos) em vez de bloco único deformado.
* **O que continua abaixo do padrão:** celeiro (0,21×) e torres (0,31–0,36×) são os piores; rochas soltas (0,48×) e pinheiro (0,49×) também. Isto é diagnóstico, **não aprovação** — o Diretor decide.

---

## 6. QUALIDADE / TESTES (Godot 4.7.2 real)

* **14/14 testes PASS:** approved_visuals (28/28), asset_catalog, boss_patterns, **character_art (v2)**, hero_animation, loot_progression, mobile_input, modeled_assets (310), monster_animation, reg001_gameplay, reg001_world (815 objetos, 5.010 células navegáveis), smoke, vertical_slice (Cidade→Missão→Bosque→Combate→Loot→Equipar→Dungeon→Guardião→Save/Load), world_travel.
* Validadores estáticos: `validate_reg001`, `validate_v0_6_1` PASS (higiene, referências, hashes SHA-256).
* **QC de assets** (`asset_qc.py`): 310 arquivos, **0 falhas**; 167 PASS / 143 avisos de margem (folga anti-corte de 26 px aplicada). Alpha parcial fora da sombra baked: 0.
* **58 capturas reais** do jogo (cidade, campos, bosque, vale, rio, gelo, colinas, deserto, cachoeira, interiores, masmorra, cripta, NPCs, fauna, elevações). Nenhum mockup.
* Nota: `qa_capture_art_gate.gd` (v2) é script de captura (exige tela) e não foi contabilizado como teste.

---

## 7. RISCOS E LIMITAÇÕES (honestidade)

1. **Arte ainda abaixo dos APPROVED em densidade de detalhe** (§5). Melhorou, mas 13/17 amostras seguem em WARN.
2. **Rostos de NPC pequenos**, vela do barco e pilares do santuário finos, platôs ainda "blocados" em silhueta, dunas em monte simples, copas de arbusto tipo "cesto".
3. **Terreno base ainda é assado por ruído** + decalques; não há tiles pintados à mão.
4. **25 assets classe B** (refino leve) e mobiliário classe A dependem de nova rodada.
5. **Não há revisão humana de arte** ainda: tudo depende do gate visual do Diretor.
6. A v2 alterou `texlib.py`/`bake_ground.py` (paleta/dither); integrei as duas linhas de trabalho e regenerei o terreno — vale o Gerente conferir se a paleta resultante agrada.

---

## 7-B. FERRAMENTAS PESQUISADAS NA WEB (produtividade)

* **Blender:** `ahujasid/blender-mcp` (MIT, ~29,6 mil ★, exige Blender com interface aberta — não roda em nuvem), `elithril/blender-kiln` (skill de Claude Code, 31 regras).
* **Pixel art:** `xinkouhe/aseprite-ai-artist` (MIT, 18 ferramentas MCP + 11 workflows + especialistas `pixel-critic`/`palette-smith`), `willibrandon/pixel-plugin`, `HappyOnigiri/PixelRefiner` (K-means em Oklab).
* **Godot:** `signalcompose/godot-mcp`, `slangwald/godot-mcp` (screenshots/cena) — nosso gate headless já cobre.
* **Adotado:** regras operacionais + quantização Oklab. **Não adotado (depende de máquina local):** Aseprite MCP e Blender MCP interativo.

---

## 8. ESTADO DO REPOSITÓRIO

* Branch **`ccr-bb54cda9-tvw178`**: tudo commitado e enviado. Commits organizados por grupo (terreno/água, estruturas, pipeline VK, definições de assets, integração, checkpoint, merge da v2, terreno de decalques, detalhe fino).
* Branches paralelas existentes: `art/pro-pixel-modeling-pipeline` (skill/ferramentas — incorporada por arquivo, sem sobrescrever), **`art/pro-pixel-modeling-pipeline-v2` (mergeada)**, **`gpt-nonvisual-etapa2` (NÃO mergeada)** — contém progressão/quests/save (`main.gd` grande) e **vai conflitar em `main.gd`** com o meu trabalho; recomendo o Gerente coordenar a ordem de merge.
* Documentos-chave: `docs/checkpoints/CHECKPOINT_PRO_ART_ETAPA1B.md`, `docs/art/PRO_ART_REVIEW_MODELED.md`, `docs/art/PRO_ART_QC.json`, `docs/art/PRO_ART_COMPLEXITY_VS_APPROVED*.json`, `game/tools/art_pipeline/README_VK.md`.

---

## 9. DECISÕES / PEDIDOS AO GERENTE

1. **"Novos assets aprovados":** o Diretor mencionou novos APPROVED, mas **não os encontrei** (`approved_visual_manifest.json` = 28 "Lote01" em todas as branches; `art/assets-lote02-buildings` idêntica à `main`; Drive sem resultado). **Onde estão?** Ao receber os PNGs integro, atualizo o manifesto (o teste exige 28 hoje) e substituo minhas peças onde houver equivalente aprovado.
2. **Ordem de merge** com `gpt-nonvisual-etapa2` (conflito previsto em `main.gd`).
3. **Gate visual do Diretor** sobre: terreno, landmarks (torre/moinho/cachoeira/caverna), NPCs/fauna, interiores — único passo de aprovação restante para dizer "mundo pronto para Etapa 2".
4. **Aseprite licenciado?** Se sim, instalar `aseprite-ai-artist` na máquina do Diretor para a limpeza manual final (o resultado entra no repo como novo PNG com hash).
5. **Próxima rodada sugerida (se autorizada):** remodelagem de celeiro, torres, rochas e pinheiro até passar no gate de complexidade; NPCs com cabeça maior/rosto legível; tiles de terreno pintados à mão para as macroformas.

---

## 10. RESPOSTAS DIRETAS

* **A Etapa 2 (combate) foi iniciada?** Não.
* **Algo foi promovido a APPROVED?** Não.
* **O jogo roda e passa nos testes?** Sim — 14/14 no Godot 4.7.2.
* **Há capturas reais?** Sim, 58 (+ comparações ANTES/DEPOIS do terreno).
* **O mundo está pronto para a Etapa 2?** **Ainda não** do ponto de vista visual: depende do gate do Diretor e da rodada de detalhe fino (§5/§9).
