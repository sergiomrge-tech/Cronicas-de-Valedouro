# REG_001 — Visual Art Audit (Professional Gate)

**Date:** 2026-09-29  
**Branch reviewed:** `ccr-bb54cda9-tvw178` @ `4b072166af529218ce9c01d0076e5eecb27ac537`  
**Reference:** APPROVED City/Hub + Caves/Dungeons catalog and real Godot REG_001 captures.  
**Decision authority:** only the Director may set `APPROVED`.

## Executive finding

The project has gained a large amount of modeled content (258 `MODELED_PENDING_GATE` assets), but quantity and technical integration are ahead of final visual quality.

The APPROVED sheet establishes a much higher bar: dense ornamental fantasy pixel art, strong silhouette, warm/cool material contrast, selective dark outline, layered construction, foliage/props integrated into architecture, and small high-energy accents.

The main remaining visible gaps in real Godot captures are:

1. baked terrain reads as procedural square regions / grid in snow, desert, river edges and some paths;
2. town/interior NPCs still use tinted `hero_body`;
3. fauna remains LEGACY_BASELINE;
4. several newly modeled hero-facing landmarks are structurally valid but visually much simpler than APPROVED architecture;
5. natural elevation pieces often still read as geometric blocks rather than natural landforms.

## Gate vocabulary

- **KEEP / POLISH** — foundation is good; only pixel cleanup/material/detail integration required.
- **STRONG REFINE** — recognizable and usable, but visibly below APPROVED bar.
- **REMODEL** — silhouette/construction concept itself is too simple/geometric; surface polish alone will not solve it.
- **DO NOT USE AS FINAL** — may remain useful as blockout/collision source, but should not become final visual art.

No item in this document is promoted to APPROVED.

## Structures / City modeled candidates

| Asset | Gate | Visual reason |
|---|---|---|
| `str_watchtower_stone` | REMODEL | Large square tower body, simple roof mass, sparse secondary construction; clearly less authored than APPROVED city gate/tower language. |
| `str_watchtower_frost` | REMODEL | Same base weakness plus broad snow slab; needs layered roof accumulation, timber/stone breakup and regional ornaments. |
| `str_windmill` | REMODEL | Tapered body is readable, but blades/body are simplified and clean; lacks timber mechanics, joints, windows, trim, weathering and surrounding storytelling props. |
| `str_outpost_amber` | STRONG REFINE | Reads as a box shelter with roof; needs beams, trim, entry construction, cloth/sign/lantern accents and desert wear. |
| `str_lodge_ice` | STRONG REFINE | Better silhouette than outpost, but snow/roof/walls are broad flat masses and materials are under-detailed. |
| `str_shelter_wood` | STRONG REFINE | Useful supporting structure but too sparse for a focal POI. |
| `str_shrine_stone` | STRONG REFINE | Shape is readable; add sacred focal symbol, gold/cyan accent, carved detail, stronger base composition and vegetation. |
| `str_dock_a/b/end` | KEEP / POLISH | Construction reads correctly; improve plank rhythm, edge wear, ropes/mooring details, water-contact shadow and prop integration. |
| `str_boat_row` | STRONG REFINE | Very simple hull/read; needs gunwale/interior/rope/paddle/material detail. |
| `str_boat_sail` | STRONG REFINE | Sailboat silhouette works but sail/hull are broad simple shapes; needs rigging, trim and stronger material clusters. |
| `str_barn` | STRONG REFINE | Functional shape; add framing, hinges, roof trim, wall variation and farm storytelling details. |
| `str_crop_wheat/corn/cabbage` | KEEP / POLISH | Good readable crop identity; reduce stamp repetition when placed and add edge/soil variation. |
| `str_scarecrow` | KEEP / POLISH | Small supporting prop; needs only pixel cleanup/cloth variation. |

## Natural elevation / terrain forms

| Asset | Gate | Visual reason |
|---|---|---|
| `nat_hill_earth` | REMODEL | Currently reads as a rounded green blob rather than an earth/rock elevation. |
| `nat_hill_ice` | REMODEL | Needs layered snow-over-rock form, not a smooth mound treatment. |
| `nat_hill_sand` | REMODEL | Needs wind-shaped dune/rock logic and a directional silhouette. |
| `nat_plateau_*_s/m` | REMODEL | Hexagonal/cylindrical top silhouette is conspicuously procedural; natural plateaus need irregular footprint and strata. |
| `nat_ridge_*_a/b` | STRONG REFINE | Useful modular intent, but long rectangular faces and straight top edges remain obvious. |
| `nat_wall_cliff_*_a/b` | STRONG REFINE | Better vertical breakup, but still reads closer to a constructed stone wall than natural geology. |
| `nat_rock_arch_natural` | KEEP / POLISH | Strongest natural elevation candidate reviewed; silhouette works, needs richer strata, erosion and regional surface treatment. |
| `nat_rock_pillars` | STRONG REFINE | Preserve concept but increase asymmetry/erosion/material breakup. |
| `nat_dune_large` | KEEP / POLISH | Directional dune form is readable; reduce repetitive ripple bands and integrate base into surrounding sand. |
| `nat_dune_small` | KEEP / POLISH | Same as above. |
| `nat_waterfall_front` | REMODEL | Current waterfall reads as two grass-topped rock towers framing a vertical water curtain. It lacks a natural cliff mass, upper river lip, impact basin, irregular rock strata and integrated vegetation/mist. |

## Dungeon candidates

The modeled dungeon set is more coherent than the new outdoor structures because its cool violet palette already approaches the APPROVED dungeon family, but it is still generally simpler.

| Asset/family | Gate | Notes |
|---|---|---|
| pillars / broken pillars | KEEP / POLISH | Good modular support; increase chips/edge accents selectively. |
| portcullis | KEEP / POLISH | Readable; stronger iron highlights and stone damage can bring it closer to APPROVED. |
| sarcophagus | KEEP / POLISH | Needs ornament/rune focal detail. |
| brazier | KEEP / POLISH | Emissive focal read works; improve metal construction. |
| rune circle | KEEP / POLISH | Useful floor focal; final pixel cleanup and palette discipline. |
| checkpoint crystal | KEEP / POLISH | Strong focal color; avoid over-soft emission. |
| altar | STRONG REFINE | Needs denser sculptural/ritual identity. |
| `str_cave_entrance` | REMODEL | Current form reads as a round grass-topped masonry tower with a dark rectangular opening, not a natural cave entrance. |

## Interiors

Claude correctly stopped using the simple modeled wood floors as the primary interior floor and reused APPROVED architecture where possible. That is a good direction.

The remaining modeled furniture is useful as supporting content, but much of it is cleaner/flatter than the APPROVED environment bar.

### Keep/polish
- shelves with goods/potions;
- forge/anvil;
- quest board;
- weapon rack;
- alchemy table;
- cauldron;
- rugs;
- sacks;
- small props.

### Strong refine
- interior wall/window/door modules;
- large tables/counters;
- bed/fireplace;
- armor stand;
- generic chairs/stools.

Interior composition should use APPROVED architectural modules as the visual backbone until a dedicated interior set reaches equivalent quality.

## Runtime art still requiring replacement

### NPCs
Real runtime code still draws town/interior NPCs by tinting `hero_body`. This remains a visible placeholder and is a P0 replacement.

Professional source pipeline now defines:
- villager;
- merchant;
- traveler;
- guard;
- blacksmith;
- alchemist;
- guild member;
- 8 directions;
- dedicated profession silhouettes.

### Fauna
Runtime still uses legacy deer, fox, hare, goat, camel, bird and fish sprites. These remain P0.

### Terrain
The real REG_001 Godot captures show:
- obvious square biome patches;
- hard orthogonal snow/grass and desert/grass boundaries;
- river/water transitions that expose tile/bake structure;
- road edges that often read as rectangular stair-steps;
- high-frequency procedural texture that competes with props.

The professional terrain V2 branch therefore changes the **source bake**, not gameplay geometry:
- larger continuous coordinate warp;
- decorrelated 64×64 transition threshold rather than repeated Bayer 8×8;
- broader road/trail edge shaping;
- APPROVED-calibrated palette;
- reduced micro-speckle/tuft density;
- automatic 32/64/128/512px grid-seam metrics.

## Director review priority

Visual review should happen in this order:

1. terrain V2 real Godot capture;
2. dedicated NPC sheet in-world;
3. dedicated fauna in-world;
4. watchtower / windmill / cave / waterfall replacement candidates;
5. cliff/elevation family;
6. remaining outposts/shrine/docks/boats;
7. interior supporting props.

## Definition of visual readiness for Etapa 2

REG_001 should not move to the combat-art stage as “visually finalized” until:
- terrain no longer exposes obvious square biome/grid structure;
- visible town/interior NPCs are not tinted hero clones;
- fauna no longer uses legacy placeholder art;
- watchtower, windmill, cave entrance and waterfall are at least comparable in detail density to APPROVED focal structures;
- cliff/elevation pieces read as geology rather than primitive geometry;
- real Godot 4.7.2 screenshots confirm the improvements;
- Director visual gate remains the final approval authority.
