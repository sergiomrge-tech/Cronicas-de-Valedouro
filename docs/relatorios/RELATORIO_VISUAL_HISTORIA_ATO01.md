# Relatório visual — História Ato I (Lote 1: Berço de Valedouro)

Branch: `ccr-bb54cda9-tvw178` (sem merge em `main`). Todos os assets novos permanecem `MODELED_PENDING_GATE` — nenhum foi marcado `APPROVED`.
Lógica de combate, save, campanha, crafting, economia, skills, passivas e dungeon **não** foi alterada (ver "Código tocado").

## 1. Locais entregues

| ID | Local | Onde no mapa | Capturas |
|---|---|---|---|
| LOC_VAL_GATE | Portão de Valedouro (torres, muralha reparada/rompida, barricadas, fogueira, carroça quebrada, sentinelas) | Muralha norte da cidade | A01_01–03, A01_20 (depois) |
| LOC_VAL_GUILD | Guilda dos Aventureiros (salão 2 pavimentos, toldo, quadro, rack, bonecos, pátio) | Cidade, leste do Arquivo | A01_04–05 |
| LOC_VAL_NORTH_ROAD | Estrada Norte (lavouras, cercas, paliçadas quebradas, carroça, ossos, pegadas, postes de aviso) | Cidade → Fazendas → Mata | A01_06–08 |
| LOC_FIRST_WIND_RUINS | Ruínas do Primeiro Vento (mecanismo, muro de inscrição, arco de raízes, círculo de piso) | Floresta | A01_09–10, A01_21 (runas acesas), A01_22 (casa abandonada) |
| LOC_ALPHA_CLEARING | Clareira do Alfa (arena pisoteada, toca, ossos da matilha) | Floresta | A01_11–12 |
| LOC_ECHO_MINE | Mina do Eco: exterior + Galeria Antiga + 3 zonas internas | Vale sul | A01_13–16 |
| LOC_ECHO_MINE_CORE | Núcleo do Eco (arena do Guardião com anel rúnico) | Fim da mina (zona 3) | A01_17 |
| LOC_SIX_CROWNS_ARCHIVE | Arquivo das Seis Coroas: exterior + interior | Cidade, noroeste do pátio | A01_18–19 |

Capturas reais do Godot 4.7.2: `docs/visual_qa/story/act01/A01_01…A01_19*.jpg` (visão geral, detalhe, entorno, caminho de chegada, interior, arena de chefe). Spots em `game/data/reg001_capture_spots.json`.

## 2. Assets

**50 assets novos** (pipeline Blender profissional, `game/tools/art_pipeline/pro_ato1_*.py`), QC 50/50 PASS, 64 cores Oklab, sombra projetada por `cast_shadow.gd`:
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

## 5. Pendências resolvidas (revisão pós-Lote 1)
1. **Piso em grade — resolvido.** Novo `draw_floor_mesh()` em `main.gd`: espelhamento e brilho por célula, blocos com sobreposição (sem emendas) e manchas por hash; a mina usa base escura + malha translúcida. Vale também para os interiores (Arquivo, Ferreiro etc.). Ver A01_15–17 e A01_19.
2. **Estados antes/depois — implementados** por flags do mundo (salvas no estado REG):
   - Portão: antes = brecha na muralha, barricadas e carroça queimada; depois do Alfa = muralha reparada e estrada limpa (`hide_when/show_when = elites:REG001_POI_ANCIAO_CLAREIRA`). A01_03 × A01_20.
   - Ruínas: novo asset `val_ruin_mechanism_dim` (runas apagadas); acende ao examinar o altar (`lore:REG001_LORE_05`). A01_10 × A01_21.
   - Clareira do Alfa: ossos da matilha somem após o Alfa. A01_11 × A01_23.
   - Mina: poste de aviso some após o Alfa (portal permanece aberto para não bloquear o loop jogável).
3. **Casa antiga perto das Ruínas — reinterpretada.** É a POI canônica `CASA_ABANDONADA` (lore + baú); em vez de removê-la, ganhou sinais de abandono: mato seco, teia, tora caída, carroça quebrada e rocha musgosa (A01_22).
4. Testes: 15/15 PASS após as mudanças (393 assets modelados; `reg001_world`: 1088 objetos, 5015 células conectadas). `audit_logic.py`: 35 sítios, 0 falhas.

## 5b. Limitações restantes
1. Estado "pós-Guardião" (mina revanche, núcleo dormente/aceso, Arquivo com mais papéis) não implementado — não há flag de Guardião utilizável sem tocar na lógica de dungeon (domínio do Gerente GPT).
2. Estado "muralha reparada" usa colisão fixa (colisor do reparo existe sempre); efeito prático nulo, pois a brecha já era intransponível.
3. Poucos riachos ao redor da Mina; a teia da casa abandonada cai sobre a trilha.
4. Falas das sentinelas do portão são flavor não canônico.
5. Nada aprovado visualmente: todos os 50 assets (49 + `val_ruin_mechanism_dim`) seguem `MODELED_PENDING_GATE`.

## 6. Código tocado (fora de arte/mundo)
Mínimo e sem mexer nos sistemas do Gerente GPT: `main.gd` (RANGES `arquivo`, coordenadas de interação/saída, `archive_menu()` com texto canônico da Cena 3, `draw_dungeon()` novo piso com fallback legado, remoção de casas/árvore legadas), `reg001_world.gd` (`ZONE_IDS` +arquivo, prefixos `elites:`/`lore:` em `is_hidden`), validador e 4 testes ajustados.

## 7. Decisões pedidas ao Diretor
1. Aceitar a reconciliação Mina do Eco (Vale sul, ID `CRIPTA_ENTRADA`) + cripta como "Galeria Antiga" selada?
2. Aprovar renomeação LORE_03 para "Alfa da Matilha"?
3. Definir a flag de Guardião para o estado pós-mina (limitação 5b.1)?
4. Gate visual dos 50 assets (APPROVED / REWORKED / HOLD).
