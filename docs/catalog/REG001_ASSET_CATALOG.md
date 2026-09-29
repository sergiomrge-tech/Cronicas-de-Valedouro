# Catálogo de assets REG_001 — Etapa 1 (Mundo Rico)

Gerado por `game/tools/build_reg001_catalog.py`. Fonte de verdade: `game/data/reg001_asset_catalog.json`.

## Política

- **APPROVED** (256): inclui o bundle base do Lote 01 e assets modelados posteriormente promovidos pelo Diretor.
- **MODELED_PENDING_GATE** (476): modelados nesta etapa no mesmo ângulo/paleta dos APPROVED (Natureza, Cidade, Dungeon, Interiores). **Aguardam o gate visual do Diretor**; o renderer só os usa enquanto o status estiver liberado em `modeled_assets_manifest.json`.
- **LEGACY_BASELINE**: arte v0.6 gerada por código (chão, fauna, herói, UI, marcos). Inalterada; não é APPROVED — segue em produção até substituição.
- **REWORKED (61) / HOLD (22)**: fora do renderer final, sem exceção.

## Contagem por status

| Aprovação | INTEGRATED | NOT_USED |
|---|---:|---:|
| APPROVED | 40 | 216 |
| MODELED_PENDING_GATE | 246 | 230 |
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

### nature (250)

| Asset | Uso | Instâncias |
|---|---|---:|
| `fau_bird` | NOT_USED | 0 |
| `fau_camel` | NOT_USED | 0 |
| `fau_deer` | NOT_USED | 0 |
| `fau_fish` | NOT_USED | 0 |
| `fau_fox` | NOT_USED | 0 |
| `fau_goat` | NOT_USED | 0 |
| `fau_hare` | NOT_USED | 0 |
| `flo_ancient_tree_a` | NOT_USED | 0 |
| `flo_ancient_tree_b` | NOT_USED | 0 |
| `flo_barricade_improvised` | NOT_USED | 0 |
| `flo_border_marker` | NOT_USED | 0 |
| `flo_bridge_ramp` | NOT_USED | 0 |
| `flo_bridge_span` | NOT_USED | 0 |
| `flo_bridge_span_broken` | NOT_USED | 0 |
| `flo_cart_path_covered` | NOT_USED | 0 |
| `flo_cart_path_open` | NOT_USED | 0 |
| `flo_cart_pillar` | NOT_USED | 0 |
| `flo_cart_ring_inert` | NOT_USED | 0 |
| `flo_cart_ring_lit` | NOT_USED | 0 |
| `flo_cart_ruin_wall` | NOT_USED | 0 |
| `flo_cart_terrace` | NOT_USED | 0 |
| `flo_claw_tree` | NOT_USED | 0 |
| `flo_corrupt_ground_heavy` | NOT_USED | 0 |
| `flo_corrupt_ground_light` | NOT_USED | 0 |
| `flo_corrupt_root_spike` | NOT_USED | 0 |
| `flo_exit_marker` | NOT_USED | 0 |
| `flo_fern_patch` | NOT_USED | 0 |
| `flo_glow_mushrooms` | NOT_USED | 0 |
| `flo_heart_floor` | NOT_USED | 0 |
| `flo_heart_seed` | NOT_USED | 0 |
| `flo_heart_seed_active` | NOT_USED | 0 |
| `flo_heart_wall` | NOT_USED | 0 |
| `flo_heart_wall_diag` | NOT_USED | 0 |
| `flo_heart_wall_diagb` | NOT_USED | 0 |
| `flo_herb_bench` | NOT_USED | 0 |
| `flo_hollow_core_active` | NOT_USED | 0 |
| `flo_hollow_core_dormant` | NOT_USED | 0 |
| `flo_hollow_floor_active` | NOT_USED | 0 |
| `flo_hollow_floor_dormant` | NOT_USED | 0 |
| `flo_hollow_wall_active` | NOT_USED | 0 |
| `flo_hollow_wall_active_diag` | NOT_USED | 0 |
| `flo_hollow_wall_active_diagb` | NOT_USED | 0 |
| `flo_hollow_wall_dormant` | NOT_USED | 0 |
| `flo_hollow_wall_dormant_diag` | NOT_USED | 0 |
| `flo_hollow_wall_dormant_diagb` | NOT_USED | 0 |
| `flo_hollow_wound_healing` | NOT_USED | 0 |
| `flo_hollow_wound_open` | NOT_USED | 0 |
| `flo_lookout_rock` | NOT_USED | 0 |
| `flo_map_table` | NOT_USED | 0 |
| `flo_memory_pool` | NOT_USED | 0 |
| `flo_memory_root_arch` | NOT_USED | 0 |
| `flo_memory_stone` | NOT_USED | 0 |
| `flo_memory_tree_open` | NOT_USED | 0 |
| `flo_memory_tree_sealed` | NOT_USED | 0 |
| `flo_palisade_broken` | NOT_USED | 0 |
| `flo_palisade_organic` | NOT_USED | 0 |
| `flo_ranger_hall` | NOT_USED | 0 |
| `flo_ranger_lodge` | NOT_USED | 0 |
| `flo_ranger_shed` | NOT_USED | 0 |
| `flo_ranger_store` | NOT_USED | 0 |
| `flo_ranger_tower` | NOT_USED | 0 |
| `flo_ranger_watch` | NOT_USED | 0 |
| `flo_rest_platform` | NOT_USED | 0 |
| `flo_root_arch` | NOT_USED | 0 |
| `flo_root_run` | NOT_USED | 0 |
| `flo_root_shortcut_blocked` | NOT_USED | 0 |
| `flo_root_shortcut_open` | NOT_USED | 0 |
| `flo_shrine_path_marker` | NOT_USED | 0 |
| `flo_shrine_stone_corrupt` | NOT_USED | 0 |
| `flo_shrine_stone_pure` | NOT_USED | 0 |
| `flo_shrine_water_corrupt` | NOT_USED | 0 |
| `flo_shrine_water_pure` | NOT_USED | 0 |
| `flo_shrine_wind_corrupt` | NOT_USED | 0 |
| `flo_shrine_wind_pure` | NOT_USED | 0 |
| `flo_stone_bridge_arch` | NOT_USED | 0 |
| `flo_stone_moss` | NOT_USED | 0 |
| `flo_training_target` | NOT_USED | 0 |
| `flo_weapon_rack_green` | NOT_USED | 0 |
| `nat_altar_ancient` | NOT_USED | 0 |
| `nat_altar_sand` | INTEGRATED | 1 |
| `nat_bedroll` | INTEGRATED | 2 |
| `nat_birch_tall` | INTEGRATED | 20 |
| `nat_bones_desert` | INTEGRATED | 8 |
| `nat_boulder_ice` | INTEGRATED | 11 |
| `nat_boulder_sand` | NOT_USED | 0 |
| `nat_bush_berry` | INTEGRATED | 8 |
| `nat_bush_dry` | INTEGRATED | 8 |
| `nat_bush_flowering` | INTEGRATED | 11 |
| `nat_bush_frost` | INTEGRATED | 7 |
| `nat_bush_green` | INTEGRATED | 15 |
| `nat_cactus_round` | INTEGRATED | 5 |
| `nat_cactus_tall` | INTEGRATED | 8 |
| `nat_campfire` | INTEGRATED | 7 |
| `nat_cart_wood` | INTEGRATED | 7 |
| `nat_chest_closed` | INTEGRATED | 4 |
| `nat_chest_open` | INTEGRATED | 0 |
| `nat_chest_rare` | INTEGRATED | 11 |
| `nat_cliff_corner_ice` | NOT_USED | 0 |
| `nat_cliff_corner_rock` | INTEGRATED | 1 |
| `nat_cliff_corner_sand` | NOT_USED | 0 |
| `nat_cliff_end_ice_am` | NOT_USED | 0 |
| `nat_cliff_end_ice_ap` | NOT_USED | 0 |
| `nat_cliff_end_ice_bm` | NOT_USED | 0 |
| `nat_cliff_end_ice_bp` | NOT_USED | 0 |
| `nat_cliff_end_rock_am` | INTEGRATED | 2 |
| `nat_cliff_end_rock_ap` | NOT_USED | 0 |
| `nat_cliff_end_rock_bm` | NOT_USED | 0 |
| `nat_cliff_end_rock_bp` | INTEGRATED | 3 |
| `nat_cliff_end_sand_am` | NOT_USED | 0 |
| `nat_cliff_end_sand_ap` | NOT_USED | 0 |
| `nat_cliff_end_sand_bm` | INTEGRATED | 1 |
| `nat_cliff_end_sand_bp` | INTEGRATED | 1 |
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
| `nat_fence_broken_a` | INTEGRATED | 4 |
| `nat_fence_broken_b` | NOT_USED | 0 |
| `nat_fence_wood_a` | INTEGRATED | 13 |
| `nat_fence_wood_b` | NOT_USED | 0 |
| `nat_fissure` | INTEGRATED | 1 |
| `nat_flag_blue` | INTEGRATED | 5 |
| `nat_flag_red` | INTEGRATED | 16 |
| `nat_flowers_blue` | INTEGRATED | 4 |
| `nat_flowers_meadow` | INTEGRATED | 18 |
| `nat_flowers_red` | INTEGRATED | 5 |
| `nat_ford_stones` | INTEGRATED | 2 |
| `nat_gate_wood` | INTEGRATED | 1 |
| `nat_grass_dry` | INTEGRATED | 3 |
| `nat_grass_tall` | INTEGRATED | 8 |
| `nat_hay_bale` | INTEGRATED | 6 |
| `nat_hay_stack` | INTEGRATED | 4 |
| `nat_hill_earth` | INTEGRATED | 2 |
| `nat_hill_ice` | NOT_USED | 0 |
| `nat_hill_low_earth` | INTEGRATED | 2 |
| `nat_hill_low_ice` | INTEGRATED | 4 |
| `nat_hill_low_rock` | INTEGRATED | 9 |
| `nat_hill_low_sand` | INTEGRATED | 4 |
| `nat_hill_sand` | NOT_USED | 0 |
| `nat_hill_wide_earth` | INTEGRATED | 2 |
| `nat_hill_wide_ice` | NOT_USED | 0 |
| `nat_hill_wide_rock` | INTEGRATED | 1 |
| `nat_hill_wide_sand` | INTEGRATED | 2 |
| `nat_ice_letters` | INTEGRATED | 2 |
| `nat_ice_monolith_adrian` | INTEGRATED | 1 |
| `nat_ice_spire` | INTEGRATED | 7 |
| `nat_ice_stones` | NOT_USED | 0 |
| `nat_log_fallen` | INTEGRATED | 5 |
| `nat_log_pile` | INTEGRATED | 3 |
| `nat_mushrooms` | INTEGRATED | 10 |
| `nat_oak_a` | INTEGRATED | 25 |
| `nat_oak_autumn` | INTEGRATED | 10 |
| `nat_oak_b` | INTEGRATED | 17 |
| `nat_oak_c` | INTEGRATED | 9 |
| `nat_oak_golden` | INTEGRATED | 2 |
| `nat_obelisk_rune` | INTEGRATED | 5 |
| `nat_pine_tall_a` | INTEGRATED | 23 |
| `nat_pine_tall_b` | INTEGRATED | 15 |
| `nat_pine_tall_snow` | INTEGRATED | 0 |
| `nat_pit_trap` | INTEGRATED | 2 |
| `nat_plateau_earth_m` | NOT_USED | 0 |
| `nat_plateau_earth_s` | INTEGRATED | 1 |
| `nat_plateau_ice_m` | INTEGRATED | 1 |
| `nat_plateau_ice_s` | NOT_USED | 0 |
| `nat_plateau_rock_m` | INTEGRATED | 1 |
| `nat_plateau_rock_s` | INTEGRATED | 2 |
| `nat_plateau_sand_m` | NOT_USED | 0 |
| `nat_plateau_sand_s` | INTEGRATED | 1 |
| `nat_ramp_earth` | INTEGRATED | 2 |
| `nat_ramp_ice` | NOT_USED | 0 |
| `nat_ramp_rock` | INTEGRATED | 2 |
| `nat_ramp_sand` | INTEGRATED | 2 |
| `nat_reeds` | INTEGRATED | 14 |
| `nat_res_crystal` | INTEGRATED | 3 |
| `nat_res_herb` | INTEGRATED | 2 |
| `nat_res_ore` | INTEGRATED | 3 |
| `nat_ridge_earth_a` | INTEGRATED | 2 |
| `nat_ridge_earth_b` | INTEGRATED | 1 |
| `nat_ridge_ice_a` | INTEGRATED | 3 |
| `nat_ridge_ice_b` | INTEGRATED | 2 |
| `nat_ridge_rock_a` | INTEGRATED | 2 |
| `nat_ridge_rock_b` | INTEGRATED | 6 |
| `nat_ridge_sand_a` | INTEGRATED | 3 |
| `nat_ridge_sand_b` | INTEGRATED | 1 |
| `nat_rock_arch_natural` | NOT_USED | 0 |
| `nat_rock_boulder` | INTEGRATED | 9 |
| `nat_rock_ice` | INTEGRATED | 3 |
| `nat_rock_medium` | INTEGRATED | 0 |
| `nat_rock_mossy` | INTEGRATED | 18 |
| `nat_rock_pillars` | INTEGRATED | 0 |
| `nat_rock_sand` | INTEGRATED | 7 |
| `nat_rock_small` | INTEGRATED | 7 |
| `nat_rock_snow` | INTEGRATED | 2 |
| `nat_ruin_arch` | INTEGRATED | 2 |
| `nat_ruin_arch_sand` | INTEGRATED | 1 |
| `nat_ruin_column` | INTEGRATED | 1 |
| `nat_ruin_column_broken` | INTEGRATED | 4 |
| `nat_ruin_column_sand` | INTEGRATED | 4 |
| `nat_ruin_wall` | INTEGRATED | 2 |
| `nat_ruin_wall_sand` | INTEGRATED | 2 |
| `nat_sarcophagus_open` | INTEGRATED | 2 |
| `nat_scarecrow` | INTEGRATED | 1 |
| `nat_signpost` | INTEGRATED | 7 |
| `nat_silk_tree` | INTEGRATED | 7 |
| `nat_snow_mound` | INTEGRATED | 2 |
| `nat_statue_guardian` | INTEGRATED | 4 |
| `nat_steps_stone` | NOT_USED | 0 |
| `nat_stone_circle` | INTEGRATED | 1 |
| `nat_stump` | INTEGRATED | 2 |
| `nat_tent_frost` | INTEGRATED | 2 |
| `nat_tent_red` | INTEGRATED | 2 |
| `nat_tent_small` | INTEGRATED | 5 |
| `nat_trap_plate` | INTEGRATED | 2 |
| `nat_tree_birch` | INTEGRATED | 2 |
| `nat_tree_dead` | INTEGRATED | 4 |
| `nat_tree_palm` | INTEGRATED | 5 |
| `nat_tree_pine` | INTEGRATED | 4 |
| `nat_tree_pine_snow` | NOT_USED | 0 |
| `nat_wall_cliff_ice_a` | INTEGRATED | 5 |
| `nat_wall_cliff_ice_b` | INTEGRATED | 3 |
| `nat_wall_cliff_rock_a` | INTEGRATED | 3 |
| `nat_wall_cliff_rock_b` | INTEGRATED | 7 |
| `nat_wall_cliff_sand_a` | INTEGRATED | 2 |
| `nat_wall_cliff_sand_b` | INTEGRATED | 2 |
| `nat_wall_low_a` | INTEGRATED | 2 |
| `nat_wall_low_b` | NOT_USED | 0 |
| `nat_waterfall_front` | INTEGRATED | 1 |
| `nat_web_ground` | INTEGRATED | 8 |
| `nat_well_stone` | INTEGRATED | 4 |
| `val_camp_remains` | INTEGRATED | 1 |
| `val_cart_wrecked` | INTEGRATED | 2 |
| `val_pack_bones` | INTEGRATED | 4 |
| `val_palisade_broken` | NOT_USED | 0 |
| `val_paw_tracks` | INTEGRATED | 8 |
| `val_ruin_floor_circle` | INTEGRATED | 1 |
| `val_ruin_inscription_wall` | INTEGRATED | 2 |
| `val_ruin_mechanism` | INTEGRATED | 1 |
| `val_ruin_mechanism_dim` | INTEGRATED | 1 |
| `val_ruin_root_arch` | INTEGRATED | 2 |
| `val_trampled_earth` | INTEGRATED | 3 |
| `val_warning_post` | INTEGRATED | 4 |
| `val_wolf_bones` | INTEGRATED | 3 |
| `val_wolf_den` | INTEGRATED | 1 |

### city (46)

| Asset | Uso | Instâncias |
|---|---|---:|
| `city_banner_blue` | INTEGRATED | 3 |
| `city_banner_red` | INTEGRATED | 1 |
| `city_barrels` | INTEGRATED | 16 |
| `city_bench` | INTEGRATED | 10 |
| `city_cart_market` | INTEGRATED | 1 |
| `city_crates` | INTEGRATED | 12 |
| `city_fountain` | INTEGRATED | 1 |
| `city_lamp_post_a` | INTEGRATED | 22 |
| `city_lamp_post_b` | INTEGRATED | 2 |
| `city_monument` | INTEGRATED | 1 |
| `city_planter` | INTEGRATED | 13 |
| `city_sign_hanging` | INTEGRATED | 6 |
| `city_stairs` | NOT_USED | 0 |
| `city_stall_blue` | INTEGRATED | 1 |
| `city_stall_striped` | INTEGRATED | 1 |
| `str_barn` | INTEGRATED | 1 |
| `str_boat_row` | INTEGRATED | 2 |
| `str_boat_sail` | INTEGRATED | 1 |
| `str_crop_cabbage` | INTEGRATED | 1 |
| `str_crop_corn` | INTEGRATED | 1 |
| `str_crop_wheat` | INTEGRATED | 9 |
| `str_dock_a` | INTEGRATED | 2 |
| `str_dock_b` | INTEGRATED | 1 |
| `str_dock_end` | INTEGRATED | 3 |
| `str_lodge_ice` | INTEGRATED | 1 |
| `str_outpost_amber` | INTEGRATED | 1 |
| `str_scarecrow` | INTEGRATED | 2 |
| `str_shelter_wood` | NOT_USED | 0 |
| `str_shrine_stone` | INTEGRATED | 1 |
| `str_watchtower_frost` | INTEGRATED | 1 |
| `str_watchtower_stone` | INTEGRATED | 2 |
| `str_windmill` | INTEGRATED | 1 |
| `val_archive_lamp` | INTEGRATED | 2 |
| `val_banner_pole_tall` | NOT_USED | 0 |
| `val_barricade_a` | INTEGRATED | 1 |
| `val_barricade_b` | NOT_USED | 0 |
| `val_crown_monument` | INTEGRATED | 2 |
| `val_gate_main` | INTEGRATED | 2 |
| `val_gate_tower` | INTEGRATED | 2 |
| `val_notice_board` | INTEGRATED | 1 |
| `val_supply_stack` | INTEGRATED | 3 |
| `val_training_dummy` | INTEGRATED | 2 |
| `val_wall_breach` | NOT_USED | 0 |
| `val_wall_repaired` | NOT_USED | 0 |
| `val_wall_segment` | NOT_USED | 0 |
| `val_weapon_rack` | INTEGRATED | 1 |

### dungeon (37)

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
| `dg_pillar` | INTEGRATED | 8 |
| `dg_pillar_broken` | INTEGRATED | 2 |
| `dg_portcullis` | INTEGRATED | 1 |
| `dg_rune_circle` | INTEGRATED | 2 |
| `dg_sarcophagus` | INTEGRATED | 4 |
| `dg_stairs` | NOT_USED | 0 |
| `dg_stalagmites` | INTEGRATED | 3 |
| `str_cave_entrance` | INTEGRATED | 1 |
| `val_core_floor_ring` | INTEGRATED | 1 |
| `val_core_floor_ring_dormant` | INTEGRATED | 1 |
| `val_eco_core` | INTEGRATED | 1 |
| `val_eco_core_dormant` | INTEGRATED | 1 |
| `val_eco_crystal_cluster` | INTEGRATED | 4 |
| `val_eco_crystal_cluster_dormant` | INTEGRATED | 4 |
| `val_eco_vein` | INTEGRATED | 2 |
| `val_eco_vein_dormant` | INTEGRATED | 2 |
| `val_mine_beam_arch` | INTEGRATED | 4 |
| `val_mine_cart` | INTEGRATED | 2 |
| `val_mine_floor` | NOT_USED | 0 |
| `val_mine_lantern_post` | INTEGRATED | 4 |
| `val_mine_machine` | INTEGRATED | 1 |
| `val_mine_portal` | INTEGRATED | 1 |
| `val_mine_rails_a` | INTEGRATED | 5 |
| `val_mine_rails_b` | NOT_USED | 0 |
| `val_mine_rock_wall` | INTEGRATED | 8 |
| `val_mine_rock_wall_eco` | INTEGRATED | 14 |
| `val_mine_rock_wall_eco_dormant` | INTEGRATED | 14 |
| `val_mine_winch` | INTEGRATED | 1 |
| `val_ore_pile` | INTEGRATED | 4 |

### interior (43)

| Asset | Uso | Instâncias |
|---|---|---:|
| `int_alchemy_table` | INTEGRATED | 1 |
| `int_anvil` | INTEGRATED | 1 |
| `int_armor_stand` | INTEGRATED | 2 |
| `int_beam` | NOT_USED | 0 |
| `int_bed` | NOT_USED | 0 |
| `int_bookshelf` | INTEGRATED | 5 |
| `int_candle_stand` | INTEGRATED | 9 |
| `int_cauldron` | INTEGRATED | 1 |
| `int_chair` | INTEGRATED | 4 |
| `int_counter` | INTEGRATED | 1 |
| `int_desk_guild` | INTEGRATED | 1 |
| `int_fireplace` | NOT_USED | 0 |
| `int_floor_carpet` | NOT_USED | 0 |
| `int_floor_stone` | INTEGRATED | 0 |
| `int_floor_wood` | INTEGRATED | 0 |
| `int_floor_wood_dark` | INTEGRATED | 0 |
| `int_forge` | INTEGRATED | 1 |
| `int_post` | INTEGRATED | 0 |
| `int_quest_board` | INTEGRATED | 1 |
| `int_rug_round` | INTEGRATED | 6 |
| `int_sacks` | INTEGRATED | 2 |
| `int_shelf_goods` | INTEGRATED | 4 |
| `int_shelf_potions` | INTEGRATED | 4 |
| `int_stool` | INTEGRATED | 6 |
| `int_table_long` | INTEGRATED | 2 |
| `int_table_round` | INTEGRATED | 1 |
| `int_wall_door` | NOT_USED | 0 |
| `int_wall_door_a` | NOT_USED | 0 |
| `int_wall_door_b` | NOT_USED | 0 |
| `int_wall_hearth` | NOT_USED | 0 |
| `int_wall_niche` | NOT_USED | 0 |
| `int_wall_plain` | INTEGRATED | 0 |
| `int_wall_plain_a` | NOT_USED | 0 |
| `int_wall_plain_b` | NOT_USED | 0 |
| `int_wall_window` | NOT_USED | 0 |
| `int_wall_window_a` | NOT_USED | 0 |
| `int_wall_window_b` | NOT_USED | 0 |
| `int_weapon_rack` | INTEGRATED | 2 |
| `int_workbench` | INTEGRATED | 1 |
| `val_archive_lectern` | INTEGRATED | 2 |
| `val_archive_map_table` | INTEGRATED | 1 |
| `val_archive_shelf_tall` | INTEGRATED | 4 |
| `val_map_fragment_pedestal` | INTEGRATED | 1 |

## APPROVED (28)

| Chave | Uso |
|---|---|
| `city_floor_clean` | INTEGRATED |
| `city_floor_worn` | INTEGRATED |
| `city_floor_moss` | INTEGRATED |
| `city_water_edge` | INTEGRATED |
| `city_tree_green` | NOT_USED |
| `city_tree_autumn` | NOT_USED |
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
| `flo_barricade_improvised_a1` | NOT_USED |
| `flo_barricade_improvised_a2` | NOT_USED |
| `flo_barricade_improvised_a3` | NOT_USED |
| `flo_barricade_improvised_a4` | NOT_USED |
| `flo_barricade_improvised_a5` | NOT_USED |
| `flo_barricade_improvised_a6` | NOT_USED |
| `flo_barricade_improvised_a7` | NOT_USED |
| `flo_barricade_improvised_c0` | NOT_USED |
| `flo_barricade_improvised_c1` | NOT_USED |
| `flo_barricade_improvised_c2` | NOT_USED |
| `flo_barricade_improvised_c3` | NOT_USED |
| `flo_cart_ruin_wall_a1` | NOT_USED |
| `flo_cart_ruin_wall_a2` | NOT_USED |
| `flo_cart_ruin_wall_a3` | NOT_USED |
| `flo_cart_ruin_wall_a4` | NOT_USED |
| `flo_cart_ruin_wall_a5` | NOT_USED |
| `flo_cart_ruin_wall_a6` | NOT_USED |
| `flo_cart_ruin_wall_a7` | NOT_USED |
| `flo_cart_ruin_wall_c0` | NOT_USED |
| `flo_cart_ruin_wall_c1` | NOT_USED |
| `flo_cart_ruin_wall_c2` | NOT_USED |
| `flo_cart_ruin_wall_c3` | NOT_USED |
| `flo_heart_wall_a1` | NOT_USED |
| `flo_heart_wall_a2` | NOT_USED |
| `flo_heart_wall_a3` | NOT_USED |
| `flo_heart_wall_a4` | NOT_USED |
| `flo_heart_wall_a5` | NOT_USED |
| `flo_heart_wall_a6` | NOT_USED |
| `flo_heart_wall_a7` | NOT_USED |
| `flo_heart_wall_c0` | NOT_USED |
| `flo_heart_wall_c1` | NOT_USED |
| `flo_heart_wall_c2` | NOT_USED |
| `flo_heart_wall_c3` | NOT_USED |
| `flo_hollow_wall_active_a1` | NOT_USED |
| `flo_hollow_wall_active_a2` | NOT_USED |
| `flo_hollow_wall_active_a3` | NOT_USED |
| `flo_hollow_wall_active_a4` | NOT_USED |
| `flo_hollow_wall_active_a5` | NOT_USED |
| `flo_hollow_wall_active_a6` | NOT_USED |
| `flo_hollow_wall_active_a7` | NOT_USED |
| `flo_hollow_wall_active_c0` | NOT_USED |
| `flo_hollow_wall_active_c1` | NOT_USED |
| `flo_hollow_wall_active_c2` | NOT_USED |
| `flo_hollow_wall_active_c3` | NOT_USED |
| `flo_hollow_wall_dormant_a1` | NOT_USED |
| `flo_hollow_wall_dormant_a2` | NOT_USED |
| `flo_hollow_wall_dormant_a3` | NOT_USED |
| `flo_hollow_wall_dormant_a4` | NOT_USED |
| `flo_hollow_wall_dormant_a5` | NOT_USED |
| `flo_hollow_wall_dormant_a6` | NOT_USED |
| `flo_hollow_wall_dormant_a7` | NOT_USED |
| `flo_hollow_wall_dormant_c0` | NOT_USED |
| `flo_hollow_wall_dormant_c1` | NOT_USED |
| `flo_hollow_wall_dormant_c2` | NOT_USED |
| `flo_hollow_wall_dormant_c3` | NOT_USED |
| `flo_palisade_broken_a1` | NOT_USED |
| `flo_palisade_broken_a2` | NOT_USED |
| `flo_palisade_broken_a3` | NOT_USED |
| `flo_palisade_broken_a4` | NOT_USED |
| `flo_palisade_broken_a5` | NOT_USED |
| `flo_palisade_broken_a6` | NOT_USED |
| `flo_palisade_broken_a7` | NOT_USED |
| `flo_palisade_broken_c0` | NOT_USED |
| `flo_palisade_broken_c1` | NOT_USED |
| `flo_palisade_broken_c2` | NOT_USED |
| `flo_palisade_broken_c3` | NOT_USED |
| `flo_palisade_organic_a1` | NOT_USED |
| `flo_palisade_organic_a2` | NOT_USED |
| `flo_palisade_organic_a3` | NOT_USED |
| `flo_palisade_organic_a4` | NOT_USED |
| `flo_palisade_organic_a5` | NOT_USED |
| `flo_palisade_organic_a6` | NOT_USED |
| `flo_palisade_organic_a7` | NOT_USED |
| `flo_palisade_organic_c0` | NOT_USED |
| `flo_palisade_organic_c1` | NOT_USED |
| `flo_palisade_organic_c2` | NOT_USED |
| `flo_palisade_organic_c3` | NOT_USED |
| `nat_fence_broken_a_a1` | NOT_USED |
| `nat_fence_broken_a_a2` | NOT_USED |
| `nat_fence_broken_a_a3` | NOT_USED |
| `nat_fence_broken_a_a4` | INTEGRATED |
| `nat_fence_broken_a_a5` | NOT_USED |
| `nat_fence_broken_a_a6` | NOT_USED |
| `nat_fence_broken_a_a7` | NOT_USED |
| `nat_fence_broken_a_c0` | NOT_USED |
| `nat_fence_broken_a_c1` | NOT_USED |
| `nat_fence_broken_a_c2` | NOT_USED |
| `nat_fence_broken_a_c3` | NOT_USED |
| `nat_fence_broken_b_a1` | NOT_USED |
| `nat_fence_broken_b_a2` | NOT_USED |
| `nat_fence_broken_b_a3` | NOT_USED |
| `nat_fence_broken_b_a4` | NOT_USED |
| `nat_fence_broken_b_a5` | NOT_USED |
| `nat_fence_broken_b_a6` | NOT_USED |
| `nat_fence_broken_b_a7` | NOT_USED |
| `nat_fence_broken_b_c0` | NOT_USED |
| `nat_fence_broken_b_c1` | NOT_USED |
| `nat_fence_broken_b_c2` | NOT_USED |
| `nat_fence_broken_b_c3` | NOT_USED |
| `nat_fence_wood_a_a1` | NOT_USED |
| `nat_fence_wood_a_a2` | NOT_USED |
| `nat_fence_wood_a_a3` | NOT_USED |
| `nat_fence_wood_a_a4` | INTEGRATED |
| `nat_fence_wood_a_a5` | NOT_USED |
| `nat_fence_wood_a_a6` | NOT_USED |
| `nat_fence_wood_a_a7` | NOT_USED |
| `nat_fence_wood_a_c0` | NOT_USED |
| `nat_fence_wood_a_c1` | NOT_USED |
| `nat_fence_wood_a_c2` | NOT_USED |
| `nat_fence_wood_a_c3` | NOT_USED |
| `nat_fence_wood_b_a1` | NOT_USED |
| `nat_fence_wood_b_a2` | NOT_USED |
| `nat_fence_wood_b_a3` | NOT_USED |
| `nat_fence_wood_b_a4` | NOT_USED |
| `nat_fence_wood_b_a5` | NOT_USED |
| `nat_fence_wood_b_a6` | NOT_USED |
| `nat_fence_wood_b_a7` | NOT_USED |
| `nat_fence_wood_b_c0` | NOT_USED |
| `nat_fence_wood_b_c1` | NOT_USED |
| `nat_fence_wood_b_c2` | NOT_USED |
| `nat_fence_wood_b_c3` | NOT_USED |
| `nat_ruin_wall_a1` | NOT_USED |
| `nat_ruin_wall_a2` | NOT_USED |
| `nat_ruin_wall_a3` | NOT_USED |
| `nat_ruin_wall_a4` | NOT_USED |
| `nat_ruin_wall_a5` | NOT_USED |
| `nat_ruin_wall_a6` | NOT_USED |
| `nat_ruin_wall_a7` | NOT_USED |
| `nat_ruin_wall_c0` | NOT_USED |
| `nat_ruin_wall_c1` | NOT_USED |
| `nat_ruin_wall_c2` | NOT_USED |
| `nat_ruin_wall_c3` | NOT_USED |
| `nat_wall_low_a_a1` | NOT_USED |
| `nat_wall_low_a_a2` | NOT_USED |
| `nat_wall_low_a_a3` | NOT_USED |
| `nat_wall_low_a_a4` | INTEGRATED |
| `nat_wall_low_a_a5` | NOT_USED |
| `nat_wall_low_a_a6` | NOT_USED |
| `nat_wall_low_a_a7` | NOT_USED |
| `nat_wall_low_a_c0` | NOT_USED |
| `nat_wall_low_a_c1` | NOT_USED |
| `nat_wall_low_a_c2` | NOT_USED |
| `nat_wall_low_a_c3` | NOT_USED |
| `nat_wall_low_b_a1` | NOT_USED |
| `nat_wall_low_b_a2` | NOT_USED |
| `nat_wall_low_b_a3` | NOT_USED |
| `nat_wall_low_b_a4` | NOT_USED |
| `nat_wall_low_b_a5` | NOT_USED |
| `nat_wall_low_b_a6` | NOT_USED |
| `nat_wall_low_b_a7` | NOT_USED |
| `nat_wall_low_b_c0` | NOT_USED |
| `nat_wall_low_b_c1` | NOT_USED |
| `nat_wall_low_b_c2` | NOT_USED |
| `nat_wall_low_b_c3` | NOT_USED |
| `val_archive_hall` | INTEGRATED |
| `val_barricade_a_a1` | INTEGRATED |
| `val_barricade_a_a2` | INTEGRATED |
| `val_barricade_a_a3` | NOT_USED |
| `val_barricade_a_a4` | NOT_USED |
| `val_barricade_a_a5` | NOT_USED |
| `val_barricade_a_a6` | NOT_USED |
| `val_barricade_a_a7` | NOT_USED |
| `val_barricade_a_c0` | NOT_USED |
| `val_barricade_a_c1` | NOT_USED |
| `val_barricade_a_c2` | NOT_USED |
| `val_barricade_a_c3` | NOT_USED |
| `val_barricade_b_a1` | NOT_USED |
| `val_barricade_b_a2` | NOT_USED |
| `val_barricade_b_a3` | NOT_USED |
| `val_barricade_b_a4` | NOT_USED |
| `val_barricade_b_a5` | NOT_USED |
| `val_barricade_b_a6` | NOT_USED |
| `val_barricade_b_a7` | INTEGRATED |
| `val_barricade_b_c0` | NOT_USED |
| `val_barricade_b_c1` | NOT_USED |
| `val_barricade_b_c2` | NOT_USED |
| `val_barricade_b_c3` | NOT_USED |
| `val_guild_hall` | INTEGRATED |
| `val_palisade_broken_a1` | INTEGRATED |
| `val_palisade_broken_a2` | INTEGRATED |
| `val_palisade_broken_a3` | INTEGRATED |
| `val_palisade_broken_a4` | INTEGRATED |
| `val_palisade_broken_a5` | NOT_USED |
| `val_palisade_broken_a6` | INTEGRATED |
| `val_palisade_broken_a7` | INTEGRATED |
| `val_palisade_broken_c0` | NOT_USED |
| `val_palisade_broken_c1` | NOT_USED |
| `val_palisade_broken_c2` | NOT_USED |
| `val_palisade_broken_c3` | NOT_USED |
| `val_ruin_inscription_wall_a1` | NOT_USED |
| `val_ruin_inscription_wall_a2` | NOT_USED |
| `val_ruin_inscription_wall_a3` | NOT_USED |
| `val_ruin_inscription_wall_a4` | NOT_USED |
| `val_ruin_inscription_wall_a5` | NOT_USED |
| `val_ruin_inscription_wall_a6` | NOT_USED |
| `val_ruin_inscription_wall_a7` | NOT_USED |
| `val_ruin_inscription_wall_c0` | NOT_USED |
| `val_ruin_inscription_wall_c1` | NOT_USED |
| `val_ruin_inscription_wall_c2` | NOT_USED |
| `val_ruin_inscription_wall_c3` | NOT_USED |
| `val_town_house_blue` | INTEGRATED |
| `val_town_house_red` | INTEGRATED |
| `val_town_house_wood` | INTEGRATED |
| `val_wall_breach_a1` | NOT_USED |
| `val_wall_breach_a2` | INTEGRATED |
| `val_wall_breach_a3` | NOT_USED |
| `val_wall_breach_a4` | NOT_USED |
| `val_wall_breach_a5` | NOT_USED |
| `val_wall_breach_a6` | NOT_USED |
| `val_wall_breach_a7` | NOT_USED |
| `val_wall_breach_c0` | NOT_USED |
| `val_wall_breach_c1` | NOT_USED |
| `val_wall_breach_c2` | NOT_USED |
| `val_wall_breach_c3` | NOT_USED |
| `val_wall_repaired_a1` | NOT_USED |
| `val_wall_repaired_a2` | INTEGRATED |
| `val_wall_repaired_a3` | NOT_USED |
| `val_wall_repaired_a4` | NOT_USED |
| `val_wall_repaired_a5` | NOT_USED |
| `val_wall_repaired_a6` | INTEGRATED |
| `val_wall_repaired_a7` | NOT_USED |
| `val_wall_repaired_c0` | NOT_USED |
| `val_wall_repaired_c1` | NOT_USED |
| `val_wall_repaired_c2` | NOT_USED |
| `val_wall_repaired_c3` | NOT_USED |
| `val_wall_segment_a1` | NOT_USED |
| `val_wall_segment_a2` | INTEGRATED |
| `val_wall_segment_a3` | NOT_USED |
| `val_wall_segment_a4` | NOT_USED |
| `val_wall_segment_a5` | NOT_USED |
| `val_wall_segment_a6` | INTEGRATED |
| `val_wall_segment_a7` | NOT_USED |
| `val_wall_segment_c0` | NOT_USED |
| `val_wall_segment_c1` | NOT_USED |
| `val_wall_segment_c2` | NOT_USED |
| `val_wall_segment_c3` | NOT_USED |
| `val_wall_tower` | INTEGRATED |

## IDs persistentes

- POIs: 67 (`REG001_POI_*`); objetos: 1088 (`REG001_OBJ_<GRUPO>_<n>`); transições: 10; trilhas: 21; passagens: 3; fragmentos de lore: 12.

