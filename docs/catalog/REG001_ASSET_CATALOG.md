# Catálogo de assets REG_001 — Etapa 1 (Mundo Rico)

Gerado por `game/tools/build_reg001_catalog.py`. Fonte de verdade: `game/data/reg001_asset_catalog.json`.

## Política

- **APPROVED** (28): Lote 01, únicos aprovados pelo Diretor. Cidade 15 + Dungeon 13.
- **MODELED_PENDING_GATE** (149): modelados nesta etapa no mesmo ângulo/paleta dos APPROVED (Natureza, Cidade, Dungeon, Interiores). **Aguardam o gate visual do Diretor**; o renderer só os usa enquanto o status estiver liberado em `modeled_assets_manifest.json`.
- **LEGACY_BASELINE**: arte v0.6 gerada por código (chão, fauna, herói, UI, marcos). Inalterada; não é APPROVED — segue em produção até substituição.
- **REWORKED (61) / HOLD (22)**: fora do renderer final, sem exceção.

## Contagem por status

| Aprovação | INTEGRATED | NOT_USED |
|---|---:|---:|
| APPROVED | 27 | 1 |
| MODELED_PENDING_GATE | 130 | 19 |
| LEGACY_BASELINE | 119 | 0 |

## MISSING_APPROVED_ASSET

Itens indispensáveis sem asset APPROVED. Nada foi pintado por código para suprir a falta.

| ID | Necessidade | Usado por |
|---|---|---|
| `MISSING_NPC_ARTISTS` | NPCs viajantes/ambientais e moradores com sprite APPROVED (hoje: hero_body tingido, LEGACY_BASELINE) | REG001_POI_VIAJANTE_NORTE, REG001_POI_ESTACAO_LESTE, assentamentos |
| `MISSING_FAUNA_APPROVED` | Fauna APPROVED: cervo, raposa, lebre, cabra, camelo, ave, peixe (hoje: sprites legados) | populate_animals / fauna por bioma |
| `MISSING_STRUCT_WATCHTOWER` | Torre de vigia APPROVED (mirantes Oeste/Norte) | REG001_POI_MIRANTE_OESTE, REG001_POI_MIRANTE_NORTE |
| `MISSING_STRUCT_WINDMILL` | Moinho APPROVED | Moinho do Vale |
| `MISSING_STRUCT_OUTPOST` | Posto de Âmbar e Abrigo da Geada APPROVED | STRUCTURES legadas |
| `MISSING_STRUCT_SHRINE` | Santuário APPROVED (hoje: sprite legado + altar modelado) | REG001_POI_SANTUARIO_VALE |
| `MISSING_GROUND_TILES` | Tiles de chão APPROVED para grama, areia, neve, terra, estrada e água rasa/profunda (hoje: tiles legados 32 px) | ground_at / draw loop |
| `MISSING_WATERFALL_CLIFF` | Cachoeira/penhasco APPROVED (hoje: efeito animado + rochas modeladas) | Cachoeira da Aurora |
| `MISSING_CROPS` | Plantações/canteiros APPROVED para fazendas | REG001_POI_FAZENDA |
| `MISSING_BOAT_DOCK` | Barcos, cais e docas APPROVED | rio / cais leste |
| `MISSING_HILL_ELEVATION` | Peças de colina/elevação/falésia APPROVED (Colinas do Leste) | REG001_POI_ESTACAO_LESTE |
| `MISSING_CAVE_ENTRANCE` | Entrada de caverna em rocha APPROVED para dungeons ao ar livre (hoje: portcullis + estátuas modeladas) | REG001_POI_CRIPTA_ENTRADA |
| `MISSING_INTERIOR_WALLS_APPROVED` | Paredes/portas/janelas internas APPROVED específicas (hoje: paredes de Cidade APPROVED + kit modelado) | guilda/ferreiro/loja/alquimia |
| `MISSING_HERO_ANIM_FX` | FX de interação (abrir baú, colher, cavar) APPROVED | gameplay REG_001 |

## MODELED_PENDING_GATE — por grupo

### nature (87)

| Asset | Uso | Instâncias |
|---|---|---:|
| `nat_altar_ancient` | INTEGRATED | 2 |
| `nat_altar_sand` | INTEGRATED | 1 |
| `nat_bedroll` | INTEGRATED | 2 |
| `nat_bones_desert` | INTEGRATED | 8 |
| `nat_boulder_ice` | INTEGRATED | 11 |
| `nat_boulder_sand` | NOT_USED | 0 |
| `nat_bush_berry` | INTEGRATED | 3 |
| `nat_bush_dry` | INTEGRATED | 6 |
| `nat_bush_flowering` | INTEGRATED | 7 |
| `nat_bush_frost` | INTEGRATED | 7 |
| `nat_bush_green` | INTEGRATED | 10 |
| `nat_cactus_round` | INTEGRATED | 5 |
| `nat_cactus_tall` | INTEGRATED | 8 |
| `nat_campfire` | INTEGRATED | 6 |
| `nat_cart_wood` | INTEGRATED | 6 |
| `nat_chest_closed` | INTEGRATED | 4 |
| `nat_chest_open` | INTEGRATED | 0 |
| `nat_chest_rare` | INTEGRATED | 11 |
| `nat_decal_dirt_a` | INTEGRATED | 0 |
| `nat_decal_dry_a` | INTEGRATED | 0 |
| `nat_decal_grass_a` | INTEGRATED | 0 |
| `nat_decal_grass_b` | INTEGRATED | 0 |
| `nat_decal_mud_bank` | INTEGRATED | 1 |
| `nat_decal_sand_a` | INTEGRATED | 0 |
| `nat_decal_sand_b` | INTEGRATED | 0 |
| `nat_decal_snow_a` | INTEGRATED | 0 |
| `nat_decal_snow_b` | INTEGRATED | 0 |
| `nat_dune_large` | INTEGRATED | 11 |
| `nat_dune_small` | INTEGRATED | 6 |
| `nat_fence_broken_a` | NOT_USED | 0 |
| `nat_fence_broken_b` | INTEGRATED | 3 |
| `nat_fence_wood_a` | INTEGRATED | 7 |
| `nat_fence_wood_b` | INTEGRATED | 7 |
| `nat_fissure` | INTEGRATED | 1 |
| `nat_flag_blue` | INTEGRATED | 5 |
| `nat_flag_red` | INTEGRATED | 5 |
| `nat_flowers_blue` | INTEGRATED | 4 |
| `nat_flowers_meadow` | INTEGRATED | 12 |
| `nat_flowers_red` | INTEGRATED | 4 |
| `nat_ford_stones` | INTEGRATED | 2 |
| `nat_gate_wood` | INTEGRATED | 1 |
| `nat_grass_dry` | INTEGRATED | 3 |
| `nat_grass_tall` | INTEGRATED | 6 |
| `nat_hay_bale` | INTEGRATED | 4 |
| `nat_hay_stack` | INTEGRATED | 1 |
| `nat_ice_spire` | INTEGRATED | 7 |
| `nat_ice_stones` | NOT_USED | 0 |
| `nat_log_fallen` | INTEGRATED | 2 |
| `nat_log_pile` | INTEGRATED | 3 |
| `nat_mushrooms` | INTEGRATED | 4 |
| `nat_obelisk_rune` | INTEGRATED | 2 |
| `nat_pit_trap` | INTEGRATED | 2 |
| `nat_reeds` | INTEGRATED | 14 |
| `nat_res_crystal` | INTEGRATED | 3 |
| `nat_res_herb` | INTEGRATED | 2 |
| `nat_res_ore` | INTEGRATED | 3 |
| `nat_rock_boulder` | INTEGRATED | 11 |
| `nat_rock_ice` | INTEGRATED | 3 |
| `nat_rock_medium` | INTEGRATED | 0 |
| `nat_rock_mossy` | INTEGRATED | 13 |
| `nat_rock_sand` | INTEGRATED | 7 |
| `nat_rock_small` | INTEGRATED | 3 |
| `nat_rock_snow` | INTEGRATED | 2 |
| `nat_ruin_arch` | INTEGRATED | 2 |
| `nat_ruin_arch_sand` | INTEGRATED | 1 |
| `nat_ruin_column` | INTEGRATED | 6 |
| `nat_ruin_column_broken` | INTEGRATED | 9 |
| `nat_ruin_column_sand` | INTEGRATED | 4 |
| `nat_ruin_wall` | INTEGRATED | 2 |
| `nat_ruin_wall_sand` | INTEGRATED | 2 |
| `nat_scarecrow` | INTEGRATED | 1 |
| `nat_signpost` | INTEGRATED | 5 |
| `nat_snow_mound` | INTEGRATED | 2 |
| `nat_statue_guardian` | INTEGRATED | 3 |
| `nat_stump` | INTEGRATED | 2 |
| `nat_tent_frost` | INTEGRATED | 2 |
| `nat_tent_red` | INTEGRATED | 2 |
| `nat_tent_small` | INTEGRATED | 5 |
| `nat_trap_plate` | INTEGRATED | 2 |
| `nat_tree_birch` | INTEGRATED | 2 |
| `nat_tree_dead` | INTEGRATED | 1 |
| `nat_tree_palm` | INTEGRATED | 5 |
| `nat_tree_pine` | INTEGRATED | 4 |
| `nat_tree_pine_snow` | INTEGRATED | 0 |
| `nat_wall_low_a` | INTEGRATED | 3 |
| `nat_wall_low_b` | INTEGRATED | 3 |
| `nat_well_stone` | INTEGRATED | 3 |

### city (15)

| Asset | Uso | Instâncias |
|---|---|---:|
| `city_banner_blue` | INTEGRATED | 3 |
| `city_banner_red` | INTEGRATED | 1 |
| `city_barrels` | INTEGRATED | 6 |
| `city_bench` | INTEGRATED | 4 |
| `city_cart_market` | INTEGRATED | 1 |
| `city_crates` | INTEGRATED | 5 |
| `city_fountain` | INTEGRATED | 1 |
| `city_lamp_post_a` | INTEGRATED | 8 |
| `city_lamp_post_b` | NOT_USED | 0 |
| `city_monument` | INTEGRATED | 1 |
| `city_planter` | INTEGRATED | 6 |
| `city_sign_hanging` | INTEGRATED | 4 |
| `city_stairs` | NOT_USED | 0 |
| `city_stall_blue` | INTEGRATED | 1 |
| `city_stall_striped` | INTEGRATED | 1 |

### dungeon (15)

| Asset | Uso | Instâncias |
|---|---|---:|
| `dg_altar_dark` | INTEGRATED | 1 |
| `dg_barrel_old` | INTEGRATED | 2 |
| `dg_bones_pile` | INTEGRATED | 3 |
| `dg_boss_gate` | NOT_USED | 0 |
| `dg_brazier` | INTEGRATED | 6 |
| `dg_crate_old` | INTEGRATED | 2 |
| `dg_crystal_checkpoint` | INTEGRATED | 2 |
| `dg_mushroom_glow` | INTEGRATED | 3 |
| `dg_pillar` | INTEGRATED | 14 |
| `dg_pillar_broken` | INTEGRATED | 4 |
| `dg_portcullis` | INTEGRATED | 1 |
| `dg_rune_circle` | INTEGRATED | 2 |
| `dg_sarcophagus` | INTEGRATED | 4 |
| `dg_stairs` | NOT_USED | 0 |
| `dg_stalagmites` | INTEGRATED | 4 |

### interior (32)

| Asset | Uso | Instâncias |
|---|---|---:|
| `int_alchemy_table` | INTEGRATED | 1 |
| `int_anvil` | INTEGRATED | 1 |
| `int_armor_stand` | INTEGRATED | 2 |
| `int_bed` | NOT_USED | 0 |
| `int_bookshelf` | INTEGRATED | 4 |
| `int_candle_stand` | INTEGRATED | 4 |
| `int_cauldron` | INTEGRATED | 1 |
| `int_chair` | INTEGRATED | 2 |
| `int_counter` | INTEGRATED | 1 |
| `int_desk_guild` | INTEGRATED | 1 |
| `int_fireplace` | NOT_USED | 0 |
| `int_floor_carpet` | NOT_USED | 0 |
| `int_floor_stone` | NOT_USED | 0 |
| `int_floor_wood` | INTEGRATED | 0 |
| `int_floor_wood_dark` | INTEGRATED | 0 |
| `int_forge` | INTEGRATED | 1 |
| `int_quest_board` | INTEGRATED | 1 |
| `int_rug_round` | INTEGRATED | 3 |
| `int_sacks` | INTEGRATED | 2 |
| `int_shelf_goods` | INTEGRATED | 4 |
| `int_shelf_potions` | INTEGRATED | 4 |
| `int_stool` | NOT_USED | 0 |
| `int_table_long` | INTEGRATED | 1 |
| `int_table_round` | NOT_USED | 0 |
| `int_wall_door_a` | NOT_USED | 0 |
| `int_wall_door_b` | NOT_USED | 0 |
| `int_wall_plain_a` | NOT_USED | 0 |
| `int_wall_plain_b` | NOT_USED | 0 |
| `int_wall_window_a` | NOT_USED | 0 |
| `int_wall_window_b` | NOT_USED | 0 |
| `int_weapon_rack` | INTEGRATED | 2 |
| `int_workbench` | INTEGRATED | 1 |

## APPROVED (28)

| Chave | Uso |
|---|---|
| `city_floor_clean` | INTEGRATED |
| `city_floor_worn` | INTEGRATED |
| `city_floor_moss` | INTEGRATED |
| `city_water_edge` | NOT_USED |
| `city_wall` | INTEGRATED |
| `city_wall_vegetation` | INTEGRATED |
| `city_gate` | INTEGRATED |
| `city_house_door` | INTEGRATED |
| `city_house_window` | INTEGRATED |
| `city_roof_blue` | INTEGRATED |
| `city_roof_red` | INTEGRATED |
| `city_roof_wood` | INTEGRATED |
| `city_store` | INTEGRATED |
| `city_tree_green` | INTEGRATED |
| `city_tree_autumn` | INTEGRATED |
| `dungeon_floor_stone` | INTEGRATED |
| `dungeon_floor_broken` | INTEGRATED |
| `dungeon_wall` | INTEGRATED |
| `dungeon_corner` | INTEGRATED |
| `dungeon_arch` | INTEGRATED |
| `dungeon_door` | INTEGRATED |
| `dungeon_rail` | INTEGRATED |
| `dungeon_crystal_blue` | INTEGRATED |
| `dungeon_crystal_purple` | INTEGRATED |
| `dungeon_torch` | INTEGRATED |
| `dungeon_emissive_crystal` | INTEGRATED |
| `dungeon_spikes` | INTEGRATED |
| `dungeon_corridor` | INTEGRATED |

## IDs persistentes

- POIs: 61 (`REG001_POI_*`); objetos: 493 (`REG001_OBJ_<GRUPO>_<n>`); transições: 10; trilhas: 20; passagens: 3; fragmentos de lore: 12.

