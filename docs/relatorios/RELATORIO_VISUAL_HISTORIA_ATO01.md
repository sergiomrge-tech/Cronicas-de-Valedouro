# Relatório visual — História Ato I (Lote 1: Berço de Valedouro)

Branch: `ccr-bb54cda9-tvw178` (sem merge em `main`). Todos os assets novos permanecem `MODELED_PENDING_GATE` — nenhum foi marcado `APPROVED`.
Lógica de combate, save, campanha, crafting, economia, skills, passivas e dungeon **não** foi alterada (ver "Código tocado").

## 1. Locais entregues

| ID | Local | Onde no mapa | Capturas |
|---|---|---|---|
| LOC_VAL_GATE | Portão de Valedouro (torres, muralha reparada/rompida, barricadas, fogueira, carroça quebrada, sentinelas) | Muralha norte da cidade | A01_01–03 |
| LOC_VAL_GUILD | Guilda dos Aventureiros (salão 2 pavimentos, toldo, quadro, rack, bonecos, pátio) | Cidade, leste do Arquivo | A01_04–05 |
| LOC_VAL_NORTH_ROAD | Estrada Norte (lavouras, cercas, paliçadas quebradas, carroça, ossos, pegadas, postes de aviso) | Cidade → Fazendas → Mata | A01_06–08 |
| LOC_FIRST_WIND_RUINS | Ruínas do Primeiro Vento (mecanismo, muro de inscrição, arco de raízes, círculo de piso) | Floresta | A01_09–10 |
| LOC_ALPHA_CLEARING | Clareira do Alfa (arena pisoteada, toca, ossos da matilha) | Floresta | A01_11–12 |
| LOC_ECHO_MINE | Mina do Eco: exterior + Galeria Antiga + 3 zonas internas | Vale sul | A01_13–16 |
| LOC_ECHO_MINE_CORE | Núcleo do Eco (arena do Guardião com anel rúnico) | Fim da mina (zona 3) | A01_17 |
| LOC_SIX_CROWNS_ARCHIVE | Arquivo das Seis Coroas: exterior + interior | Cidade, noroeste do pátio | A01_18–19 |

Capturas reais do Godot 4.7.2: `docs/visual_qa/story/act01/A01_01…A01_19*.jpg` (visão geral, detalhe, entorno, caminho de chegada, interior, arena de chefe). Spots em `game/data/reg001_capture_spots.json`.

## 2. Assets

**49 assets novos** (pipeline Blender profissional, `game/tools/art_pipeline/pro_ato1_*.py`), QC 49/49 PASS, 64 cores Oklab, sombra projetada por `cast_shadow.gd`:
- Cidade: `val_gate_main`, `val_gate_tower`, `val_wall_segment/_repaired/_breach`, `val_barricade_a/b`, `val_banner_pole_tall`, `val_supply_stack`, `val_guild_hall`, `val_weapon_rack`, `val_training_dummy`, `val_notice_board`, `val_archive_hall`, `val_archive_lamp`, `val_crown_monument`, interior do Arquivo (`val_archive_shelf_tall`, `_map_table`, `_lectern`, `val_map_fragment_pedestal`).
- Estrada/Mata: `val_cart_wrecked`, `val_warning_post`, `val_palisade_broken`, `val_wolf_bones`, `val_camp_remains`, `val_paw_tracks`, `val_ruin_mechanism/_inscription_wall/_root_arch/_floor_circle`, `val_wolf_den`, `val_pack_bones`, `val_trampled_earth`.
- Mina: `val_mine_portal/_cart/_winch/_rails_a/_b/_lantern_post/_floor/_rock_wall(+_eco)/_beam_arch/_machine`, `val_ore_pile`, `val_eco_vein/_core/_crystal_cluster`, `val_core_floor_ring`.

**Reaproveitados** (existentes, APPROVED/MODELED): árvores, rochas, cercas, bancos, barris, caixotes, lamparinas, poço, fogueira, feno, tendas, vegetação `nat_*`/`city_*`.
Modularidade: muralha em 3 estados, trilhos em 2 segmentos, parede da mina em variante normal e corrompida (`_eco`), arcos/vigas repetíveis.

## 3. Alterações no mundo
- `build_world.py`: bloco das Ruínas reescrito (sem portão de dungeon), Clareira renomeada "CLAREIRA DO ALFA", complexo da Mina no Vale sul (POI `REG001_POI_CRIPTA_ENTRADA` reaproveitado, ID persistente mantido), Galeria Antiga (antiga cripta), interior da mina, sala `arquivo`, portão/guilda/arquivo/estrada norte; removidos 3 casas, jardineiras, 2 árvores e o quadro antigo que colidiam.
- `audit_logic.py`: 35 sítios, **0 falhas**. Retângulo legado de colisão da guilda removido (bloqueava o pátio novo).
- Ambiente: transição cidade→campo→ruínas→corrupção do Eco (rocha `_eco`, veias, cristais, brilho ciano) → mina; iluminação por lanternas/tochas.

## 4. Testes (Godot 4.7.2 headless)
15/15 PASS: approved_visuals, asset_catalog, boss_patterns, cast_shadow, character_art, hero_animation, loot_progression, mobile_input, modeled_assets (392 assets), monster_animation, reg001_gameplay, reg001_world (1079 objetos, 67 POIs, 5016 células conectadas), smoke, vertical_slice, world_travel. `qa_capture_art_gate` exige display/`xvfb` e não faz parte do gate headless.
Métricas: 1079 objetos no mundo, 1251 itens em 30 chunks (125 ms de build), pico visível 212 objetos.

## 5. Problemas conhecidos / limitações
1. **Piso da mina e do Arquivo (interior) com aparência de grade** (A01_15–17, A01_19): losangos repetidos ainda legíveis como tile. Precisa de variação/decalques de piso e quebra de repetição. Prioridade alta para o próximo passe.
2. **Três estados (antes/durante/depois)** só existem onde já há flag de mundo: ossos da matilha somem após o Alfa (`elites:`), muralha tem os 3 modelos mas o portão/mecanismo não trocam de estado no runtime (sem lit/unlit do mecanismo, sem portal pós-missão). Comparativos antes/depois em captura ficaram pendentes.
3. Casa antiga próxima às Ruínas (A01_09) destoa da narrativa "ruína isolada"; sugestão: remover ou ruinizar.
4. Poucos riachos ao redor da Mina (ver A01_13); vegetação densa, mas falta água corrente.
5. Falas das sentinelas do portão são flavor não canônico.
6. Nada aprovado visualmente: todos os assets precisam de gate visual do Diretor.

## 6. Código tocado (fora de arte/mundo)
Mínimo e sem mexer nos sistemas do Gerente GPT: `main.gd` (RANGES `arquivo`, coordenadas de interação/saída, `archive_menu()` com texto canônico da Cena 3, `draw_dungeon()` novo piso com fallback legado, remoção de casas/árvore legadas), `reg001_world.gd` (`ZONE_IDS` +arquivo, prefixos `elites:`/`lore:` em `is_hidden`), validador e 4 testes ajustados.

## 7. Decisões pedidas ao Diretor
1. Aceitar a reconciliação Mina do Eco (Vale sul, ID `CRIPTA_ENTRADA`) + cripta como "Galeria Antiga" selada?
2. Aprovar renomeação LORE_03 para "Alfa da Matilha"?
3. Autorizar trabalho no piso (item 5.1) e nos estados portão/mecanismo (5.2) antes do Lote 2?
4. Gate visual dos 49 assets (APPROVED / REWORKED / HOLD).
