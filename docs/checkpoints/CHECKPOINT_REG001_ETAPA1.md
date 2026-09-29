# CHECKPOINT — REG_001 Etapa 1 de 3: Mundo Rico

**Data:** 2026-09-29 · **Engine:** Godot 4.7.2 · **Branch:** `ccr-bb54cda9-tvw178`

## Resumo

A REG_001 passou de "vila + arredores com vegetação isolada" para um mundo conectado, denso e jogável:
7 regiões com pontos de interesse, elites, baús, segredos, atalhos, armadilhas, mini-dungeon opcional, interiores mobiliados e
transições suaves entre biomas — tudo dirigido por dados com IDs persistentes e validado por testes nativos.

## Assets: nova biblioteca modelada (antes do mundo)

Só havia 28 assets APPROVED (Cidade 15 + Dungeon 13); **não existiam PNGs de Natureza nem de Interiores**. Conforme a decisão do Diretor
("primeiro terminar os assets e fazer a modelagem"), foi criado um motor de modelagem volumétrica (`game/tools/modeling/`) que renderiza
primitivas 3D na **mesma projeção isométrica 2:1 e paleta** dos APPROVED (sombreamento em rampas, sombras projetadas, contorno seletivo, pixels sem AA).

- **149 assets** em `game/assets/modeled/` — Natureza 87, Cidade 15, Dungeon 15, Interiores 32 — mais folhas de contato em `docs/visual_qa/modeled_*.png`.
- Manifesto: `game/data/modeled_assets_manifest.json` (IDs persistentes, âncora de pé, quadros de animação, hash SHA-256, colisão/exclusão).
- **Status: `MODELED_PENDING_GATE`.** Não são APPROVED até o gate visual do Diretor. O renderer só carrega os status liberados em `policy.renderer_uses_statuses`;
  para retirar/recusar um asset basta mudar seu `status` no manifesto (o teste `modeled_assets` e o validador estático acompanham).
- **Nenhum REWORKED/HOLD** no renderer (61 + 22 continuam excluídos; teste varre `scripts/`).

## Conteúdo do mundo (dados: `game/data/reg001_world.json`, fonte: `game/tools/reg001/build_world.py`)

| Item | Qtd |
|---|---:|
| POIs (`REG001_POI_*`) | 61 |
| Objetos manuais (`REG001_OBJ_*`) | 493 |
| Trilhas / rotas secundárias | 20 |
| Passagens (2 vaus + atalho da fazenda) | 3 |
| Transições de bioma | 10 |
| Fragmentos de lore | 12 |
| Elites | 8 (clareira, bosque norte, vale, gelo, oásis, masmorra, cripta, Bosque-instância) |
| Baús | 15 (8 exigem derrotar um elite, 3 exigem revelar um segredo) |
| Recursos raros | 8 |
| Armadilhas | 5 (+ 3 espinhos na Cripta) |
| Segredos | 3 (mata NO, gruta de gelo, duna móvel) |

- **Cidade**: bandeiras, lampiões, fonte, monumento, mercado (barracas listradas, carroça), bancos, jardineiras, barris/caixas, placas — substituem os desenhos geométricos.
- **Campos/Vale**: Vila dos Campos, Fazenda cercada em losango isométrico (portão = atalho), Aldeia do Vale, Santuário (cura), elite Flor Anciã, **Cripta Esquecida** (mini-dungeon).
- **Bosque**: acampamento abandonado, casa abandonada, mirantes (Torres Oeste/Norte), Ruínas do Primeiro Vento (altar + lore), clareira do Lobo Ancião, tecelã do bosque, viajante cartógrafa (NPC ambulante).
- **Gelo**: Pouso da Geada, passagem estreita (cânion de gelo), círculo de gelo (elite), gruta secreta, cristais raros.
- **Colinas do Leste (pradaria)**: estação de viajantes, mirante; ponte entre Gelo e Deserto.
- **Deserto**: Caravana de Âmbar, Ruínas das Dunas (armadilhas de placa/fosso, altar de areia), oásis com elite, duna secreta, dunas-obstáculo.
- **Rio**: 3 pontes + 2 vaus (`REG001_PASS_VAU_*`), juncos, margens de lama, cachoeira (efeito) com rochas.
- **Interiores**: Guilda, Ferreiro, Alquimia e Loja mobiliados (balcões, prateleiras, forja, caldeirão, quadro de missões...).
- **Masmorra do Guardião**: pilares (agora visíveis onde havia colisão invisível), círculo rúnico, braseiros, sarcófagos, cristal de repouso, elite + baú.

## Transições suaves

Fronteiras entre biomas usam (1) dispersão de ±48 px no *tile* de piso (`MAP.ground_biome`), (2) decalques do bioma vizinho e props de borda por chunk,
(3) sujeira/tufos nas bordas de estradas e trilhas. Pares: cidade↔campos, campos↔floresta, floresta↔vale, colinas↔gelo, colinas↔deserto, vale↔deserto (+4).

## Level design e navegação

Obstáculos: árvores/rochas/troncos/cercas/muros/ruínas/colunas/fendas/dunas/portões/estátuas/armadilhas, passagens estreitas, atalhos e rotas secundárias.
Vegetação procedural respeita exclusões (POIs, trilhas, objetos, vaus, estradas). O teste faz BFS na malha de 32 px e exige **todos os POIs alcançáveis**
(segredos fechados e abertos), vaus atravessáveis e abrir segredos nunca reduzir a malha.

## Performance / mobile

- Chunks de 512 px gerados sob demanda (30 chunks = ~150 ms no total, ~5 ms cada), cache e lista unificada por janela, ordenada por Y, com busca binária + culling.
- Pico medido: **231 objetos** na janela visível (limite do teste: 900). Colisão por hash espacial (chave inteira).
- Emissores ambientais (fumaça, brilho, névoa) são funções puras do tempo — sem alocação por quadro, logo sem necessidade de pooling.
- Sombras de contato baratas (polígono de 14 pontos) só em objetos sólidos e árvores.

## Gate da Etapa 1 (executado localmente com Godot 4.7.2 oficial)

| Item | Resultado |
|---|---|
| Import/parser Godot 4.7.2 (`--editor --quit-after`) | PASS (sem erros) |
| smoke, world_travel, hero/monster animation, loot, asset_catalog, approved_visuals, vertical_slice, boss_patterns, mobile_input | PASS (regressão) |
| `modeled_assets` (149 assets, arquivos, quadros, hashes) | PASS |
| `reg001_world` (IDs, referências, navegação BFS, exclusão, chunks, performance) | PASS |
| `reg001_gameplay` (baús, elites, segredos, atalho, recurso, santuário, lore, NPC, armadilha, cripta, save aditivo) | PASS |
| Validadores estáticos v0.6, v0.6.1 e REG_001 | PASS |
| Referências quebradas | 0 (`res://` literais validados) |
| Visual QA real | 37 capturas reais (gl_compatibility) → `docs/visual_qa/reg001/capture_*.jpg` e artifact `valedouro-reg001-visual-qa` no CI |
| REWORKED/HOLD no renderer | 0 |

O workflow `godot-gate.yml` foi estendido (novos testes, validador e captura REG_001). O gate no GitHub Actions roda no `main`; nesta branch os mesmos testes foram executados localmente.

## Catálogo APPROVED / INTEGRATED / MISSING / NOT_USED

`docs/catalog/REG001_ASSET_CATALOG.md` (+ `game/data/reg001_asset_catalog.json`) e `docs/planning/CRONICAS_VALEDOURO_REG001_WORLD_IDS_v1.md`.

- APPROVED: 27 INTEGRATED, 1 NOT_USED (`city/water_edge`).
- MODELED_PENDING_GATE: 130 INTEGRATED, 19 NOT_USED (kit de paredes internas, cama, lareira etc. — disponíveis).
- LEGACY_BASELINE: 119 (chão, fauna, herói, UI, marcos) — inalterados.
- **MISSING_APPROVED_ASSET: 14** (NPCs, fauna, torre/moinho/posto/santuário, tiles de chão, cachoeira, plantações, cais/barcos, colinas, entrada de caverna, paredes internas, FX de interação).

## Pontos que dependem do Diretor

1. **Gate visual** dos 149 assets modelados (aprovar/rejeitar por ID no manifesto).
2. Decidir o destino da arte **LEGACY_BASELINE** (chão, fauna, NPC tingido, marcos): segue em produção porque não é REWORKED/HOLD, mas não é APPROVED.
3. Ordem dos MISSING mais impactantes: chão/água, NPCs, fauna.

## Notas técnicas

- `Resource.reset_state()` existe no Godot 4.4+: uma função estática com esse nome num script é sombreada quando chamada via `preload`. Renomeada para `clear_progress()`.
- Literais de dicionário constantes são compartilhados em GDScript: o estado é reconstruído por seção.
- Save continua **v4**, com bloco aditivo `reg001` (baús, elites, segredos, recursos, lore, descobertas). Saves antigos carregam normalmente.
- `build_asset_catalog.py`/`validate_v0_6_1.py` agora ignoram `assets/approved` e `assets/modeled` (têm manifestos próprios).
