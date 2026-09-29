# CHECKPOINT — Professional Art Pipeline v2

**Date:** 2026-09-29  
**Working branch:** `art/pro-pixel-modeling-pipeline-v2`  
**Base branch:** `ccr-bb54cda9-tvw178`  
**Base synchronized at:** `4b072166af529218ce9c01d0076e5eecb27ac537`  
**Validation PR:** #1 — draft, do not merge yet.

## Objective

Raise Crônicas de Valedouro from technically rich but visually uneven/procedural content to a coherent professional pixel-art production standard while preserving the already approved identity.

No new candidate produced by this branch is APPROVED automatically. The Director remains the only visual approval authority.

## State inherited from Claude / REG_001

The latest ccr branch has advanced beyond the original Etapa 1 checkpoint.

Current catalog state reviewed:
- 28 APPROVED assets integrated;
- 258 MODELED_PENDING_GATE assets total;
- 171 modeled candidates integrated;
- 87 modeled candidates available/not used;
- 119 LEGACY_BASELINE assets still present;
- 61 POIs;
- 795 manual/world objects after the latest village/interior enrichment;
- latest Claude commit reports 13/13 native Godot tests passing plus static validators.

Claude has already produced modeled candidates for:
- watchtowers;
- windmill;
- desert/ice outposts;
- shelter;
- shrine;
- barn;
- boats/docks;
- crops;
- cave entrance;
- hills/ridges/plateaus/cliff walls/steps;
- waterfall front;
- additional world enrichment.

Therefore this branch no longer treats those groups as simply “missing.” They are now **visual review/refinement candidates**.

## Approved visual source of truth

The versioned `approved_source_catalog/part00..07.b64` was reconstructed and visually reviewed.

A dedicated style bible was created:

`docs/art/VALEDOURO_APPROVED_STYLE_BIBLE.md`

The APPROVED art language is:
- dense ornamental fantasy pixel art;
- strong readable silhouettes;
- dark selective navy/brown-violet outline;
- high value separation;
- warm peach/cream city stone;
- saturated cobalt/royal-blue and red roofs;
- warm orange timber;
- gold trim and warm emissive lights;
- vivid integrated vegetation;
- cool indigo/violet dungeon stone;
- electric cyan/blue/purple dungeon focal accents.

## Professional pipeline

Source:
`docs/art/VALEDOURO_PRO_ART_MODELING_SKILL.md`

Production chain:

`APPROVED reference -> silhouette -> blockout -> detailed source modeling -> material/detail pass -> locked AZ45/EL30 orthographic render -> nearest pixel finish -> manual pixel cleanup -> technical QA -> Godot 4.7.2 capture -> MODELED_PENDING_GATE -> Director gate`

The old primitive modeler remains valid for:
- blockout;
- collision;
- deterministic placement;
- simple supporting props.

It is no longer considered automatically sufficient for final hero-facing art.

## Real Godot capture diagnosis

Reviewed:
- `capture_B_floresta_campos_vale.jpg`
- `capture_D_gelo_colinas_deserto.jpg`
- `capture_E_deserto_rio_masmorra.jpg`

Main visual issue:
**the baked terrain exposes square/procedural structure more strongly than the approved architecture does.**

Visible symptoms:
- orthogonal snow/grass boundaries;
- desert/grass rectangular patches;
- hard river-bank transitions;
- stair-stepped rectangular paths;
- high-frequency procedural surface noise.

## Terrain V2 implemented

Modified on this branch:

### `game/tools/terrain/bake_ground.py`
- replaced repeated 8x8 Bayer transition carpet with deterministic decorrelated 64x64 threshold field;
- increased biome coordinate warp into broad continuous organic masses;
- replaced binary warp-source switching with smooth macro mixing;
- broadened road edge shaping;
- broadened trail edge shaping.

### `game/tools/terrain/texlib.py`
- palette moved closer to APPROVED City/Dungeon contrast;
- warmer dirt/road/sand/wood;
- deeper greens;
- cooler indigo-violet rock;
- controlled snow;
- substantially reduced micro-speckle and tuft density.

### Terrain metric
`game/tools/art_pipeline/terrain_visual_metrics.py`

Measures excess gradient energy on:
- 32 px;
- 64 px;
- 128 px;
- 512 px boundaries.

Also measures:
- chunk seam energy;
- high-frequency surface noise.

This creates an objective alarm for the same grid problem visible in the Director screenshots.

## NPC / character art pipeline

Runtime review confirmed:
- hero uses 48x56 frames;
- 8 directions;
- town/interior NPCs currently tint `hero_body`.

New source families:
- villager;
- merchant;
- traveler;
- guard;
- blacksmith;
- alchemist;
- guild member.

Source:
`game/tools/art_pipeline/blender_npc_fauna_reg001.py`

Each family has profession-specific silhouette/props instead of recoloring the hero.

Supporting pipeline:
- `game/data/reg001_character_art_spec.json`
- `blender_render_character_directions.py`
- `pack_character_sheets.py`
- `build_character_candidate_manifest.py`

Target NPC:
- 48x56;
- 8 directions;
- idle 4 frames;
- walk 8 frames;
- interact 6 frames.

## Fauna pipeline

Runtime still uses legacy fauna.

New source species:
- deer;
- fox;
- hare;
- goat;
- camel;
- bird;
- fish.

Each source has species-specific silhouette features and its own target frame size/animation spec.

No legacy fauna is removed until a replacement has passed visual/integration review.

## Modeled candidate visual audit

Full audit:
`docs/art/REG001_VISUAL_AUDIT_2026-09-29.md`

### REMODEL priority
- `str_watchtower_stone`
- `str_watchtower_frost`
- `str_windmill`
- `str_cave_entrance`
- `nat_hill_earth`
- hill ice/sand family
- plateau family
- `nat_waterfall_front`

### Strong refine
- outpost/lodge/shelter;
- shrine;
- boats;
- barn;
- ridges;
- cliff walls;
- rock pillars;
- selected interior wall/furniture modules.

### Preserve/polish candidates
- crops;
- scarecrow;
- docks;
- natural rock arch;
- dunes;
- several dungeon support props.

## Landmark replacement source

`game/tools/art_pipeline/blender_landmarks_reg001.py`

Detailed source geometry exists for:
- watchtower;
- windmill;
- natural cave entrance;
- waterfall/cliff composition.

A second approved-density layer was added:

`game/tools/art_pipeline/blender_detail_landmarks_approved.py`

It adds purposeful:
- stone face breakup;
- blue/gold trim;
- finials;
- banners;
- lanterns;
- vegetation;
- windows;
- mechanism details;
- rock strata;
- cyan cave crystals;
- waterfall lip;
- impact foam;
- vegetation framing.

Material calibration:
`game/tools/art_pipeline/blender_apply_approved_materials.py`

## Elevation source

`game/tools/art_pipeline/blender_terrain_modules_reg001.py`

Contains replacement-oriented source modules for:
- straight cliff;
- inner corner;
- outer corner;
- natural steps;
- canyon walls;
- grass/snow/sand families.

These are source candidates, not automatic replacement of Claude's existing modeled elevation set.

## QA tools

- `asset_qc.py`: alpha/halo/clipping/palette/dimensions/anchor;
- `pixel_finish.py`: nearest downsample + hard alpha + optional palette cap;
- `extract_approved_palette.py`: palette extraction from APPROVED PNGs;
- `make_visual_comparison.py`: BEFORE / AFTER / APPROVED REF contact sheets;
- `terrain_visual_metrics.py`: grid/chunk/noise metrics.

## CI status

A dedicated workflow exists:

`.github/workflows/art-pipeline-qa.yml`

It is designed to:
- compile Python art/terrain tooling;
- generate terrain texture preview;
- regenerate terrain world preview;
- run grid/chunk metrics;
- run terrain asset QA;
- run REG001 static validator;
- upload art QA artifacts.

Draft PR #1 exists for validation only.

Important limitation:
the connected GitHub workflow-run endpoint currently exposes pull-request-triggered runs only, while the new workflow is not yet established in the base branch. Therefore the art CI artifact is not yet visible through the connector.

Do **not** treat this as a passing CI result.

## Current professional-art queue

Source:
`game/data/reg001_professional_art_queue.json`

### P0
1. terrain V2;
2. dedicated NPC art;
3. dedicated fauna art.

### P1 review / selective remodel
1. watchtower;
2. windmill;
3. cave entrance;
4. waterfall;
5. elevation/cliff family;
6. outposts/shrine/boats/docks.

### P2
1. interior-specific architecture where APPROVED exterior modules are insufficient;
2. interaction FX.

## Integration policy

Do not merge the draft PR until:
- terrain V2 is generated and visually compared;
- Python QA has executed successfully;
- existing REG001 static/native tests are preserved;
- no LEGACY asset is removed without a replacement;
- no REWORKED/HOLD asset enters renderer;
- candidate art is kept MODELED_PENDING_GATE;
- real Godot 4.7.2 screenshots are available for visual decision.

## Next concrete work

1. execute/generate terrain V2 preview in a capable runner;
2. compare current vs V2 using grid metric + real image review;
3. render first NPC family and first fauna family using fixed camera;
4. create directional sheets;
5. integrate behind fallback logic;
6. capture real Godot screenshots;
7. render hero-facing replacement landmarks;
8. visual Director gate.
