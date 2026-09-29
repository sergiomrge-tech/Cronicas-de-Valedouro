# SKILL — Valedouro Professional Pixel/Isometric Art Pipeline

## Purpose
This project skill defines the production standard for visual assets in **Crônicas de Valedouro**. It replaces the previous "primitive-first" mindset with an art-directed hybrid pipeline:

**reference + blockout -> 3D form -> fixed dimetric camera -> controlled lighting -> low-resolution render -> pixel-art cleanup -> QA -> Godot integration**

The goal is not merely to make assets technically valid. The goal is to make them look hand-authored, coherent, rich and production-ready while preserving the visual direction already approved by the Director.

## 1. Projection lock
Valedouro uses the existing approved **2:1 dimetric/isometric-looking projection**. Do not change the visual projection of the world.

Rules:
- Ground-facing diagonals must visually follow the same 2:1 slope as the approved City/Dungeon assets.
- Do not mix true isometric and 2:1 dimetric camera rigs in the same asset family.
- For Blender blockout/pre-render, use the Valedouro dimetric rig: orthographic camera, 45° Z orientation and approximately 60° X tilt, then calibrate against an APPROVED asset overlay before production.
- Camera scale and object scale must be locked per asset family.
- Foot/contact anchor is part of the asset contract and must not drift between variants/frames.

## 2. Shape language
Every asset must have three readable levels:
1. **Primary silhouette** — readable at gameplay zoom.
2. **Secondary masses** — roof sections, trunk/branches, stone courses, furniture volumes, armor groups.
3. **Tertiary detail** — cracks, moss, trims, chips, metal accents, cloth folds, runes.

Never solve richness by adding random noise. Detail must reinforce material, age, use and region.

Reject:
- primitive-looking cylinders/boxes left visually obvious;
- perfect symmetry when wear/nature should break it;
- flat front faces without material breakup;
- repeated identical stones/planks;
- decorative detail that disappears at gameplay scale.

## 3. Professional blockout rule
The existing Python primitive modeler may be used for:
- collision proxies;
- rough blockout;
- silhouette experiments;
- deterministic placement prototypes.

It must NOT be the final art method for hero-facing landmarks, buildings, cliffs, caves, major trees, NPCs, fauna or hero equipment unless the result passes the same visual bar as approved hand-authored art.

For final assets prefer:
- Blender model/pre-render for complex volume and consistent perspective;
- Aseprite-style pixel cleanup for silhouette, clusters, palette and animation;
- hand-authored 2D for details that read better painted than modeled.

## 4. Lighting bible
Use one dominant world light direction across static environment assets.

Required:
- broad key light from upper-left/front-left relative to the screen;
- controlled ambient fill;
- contact occlusion at the base;
- cast shadow only when it improves grounding/readability;
- highlight hierarchy: metal > wet surface/crystal > painted wood > dry wood/stone > soil.

Do not bake contradictory light directions between neighboring assets.

For pixel-art lighting in Godot, keep texture sampling nearest. Dynamic pixel-style lighting must snap to a pixel grid rather than relying on nearest filtering alone.

## 5. Palette discipline
Each regional family receives:
- shared neutral shadows;
- 1–2 dominant local color families;
- limited accent colors;
- controlled brightest values.

Rules:
- no uncontrolled full-RGB gradients;
- no photographic noise;
- no soft anti-aliased fringes;
- avoid hue/value ramps that introduce dozens of imperceptible colors;
- use purposeful clusters rather than single-pixel salt-and-pepper noise;
- reserve high-saturation highlights for focal/interactable elements.

## 6. Pixel cleanup pass
Every pre-rendered asset receives a cleanup pass before it can enter a visual gate.

Check:
- silhouette stair-stepping;
- 2:1 diagonal consistency;
- cluster readability;
- banding;
- tangent collisions;
- accidental single pixels;
- anti-aliased alpha fringes;
- noisy dither;
- outline thickness;
- contact shadow;
- base/foot position;
- palette overgrowth.

Do not treat automatic downsampling as the final asset.

## 7. Materials
### Stone
Use large value groups first, then chips/cracks. Avoid evenly distributed speckles. Corners should show selective wear.

### Wood
Show board direction, grain only where readable, edge wear, joint logic and occasional color variation. Avoid repetitive stripes.

### Metal
Sharper highlight groups, compact bright accents, darker local occlusion around joints. Rust only where physically plausible.

### Cloth
Use broad fold masses. Flags/tents should not look like rigid polygons.

### Foliage
Build canopies from overlapping clusters and silhouette breakup. Avoid spherical "broccoli" crowns.

### Snow
Snow is a layer over form: preserve the underlying rock/roof/tree mass, with accumulation on upward-facing surfaces and breakup at edges.

### Sand
Dunes need form, wind direction and shadow planes. Avoid flat stain-like blobs.

## 8. Environment richness
A professional scene must use **composition**, not asset count alone.

For each POI:
- focal landmark;
- supporting mid-size shapes;
- small storytelling props;
- negative space for navigation;
- foreground/background overlap;
- material/color rhythm;
- path readability.

Avoid uniform scatter.

Use deliberate clusters and quiet zones.

## 9. Buildings and landmarks
Hero-facing buildings require:
- believable construction;
- layered roof/wall depth;
- trims, supports and joints;
- doors/windows sized against the hero;
- foundation/contact treatment;
- asymmetry/weathering;
- region-specific decoration.

Critical landmarks (watchtower, windmill, shrine, cave entrance, docks, waterfall/cliff) require a concept/blockout review before final sprite export.

## 10. Terrain and cliffs
Ground must not read as a repeated checkerboard.

Use:
- base tile family;
- edge variants;
- path/road variants;
- transition masks/decals;
- sparse macro breakup;
- elevation pieces;
- cliff faces;
- corner/concave/convex variants.

At gameplay zoom, tile boundaries should not be the first thing the eye notices.

## 11. NPCs and fauna
Do not use tinted hero clones as final NPCs.

NPC families require:
- unique silhouette groups;
- profession/region cues;
- consistent anatomy/scale;
- readable face/head/hair masses;
- idle/walk minimum animation where relevant.

Fauna requires:
- species-specific silhouette;
- readable gait;
- at least idle + locomotion for visible ambient animals;
- believable contact with ground.

## 12. Animation standard
Animation is authored in phases:
- anticipation;
- action;
- impact/contact;
- recovery;
- settle/loop.

Use Aseprite-like timeline organization with tags per action. Keep a stable pivot/foot anchor across frames.

For environment loops (flag, fire, water, foliage):
- avoid perfectly mechanical repetition;
- keep loop seam invisible;
- vary phase when multiple instances appear together.

## 13. Blender pre-render standard
Use the project script in `game/tools/art_pipeline/blender_valedouro_setup.py` as the starting rig.

Required:
- orthographic camera;
- transparent film;
- locked projection;
- low internal render resolution;
- consistent world light;
- no depth-of-field;
- no motion blur;
- no anti-aliasing-dependent soft edges in final pixel output;
- render separate shadow/mask passes when useful;
- export PNG with alpha.

Render larger only when needed for modeling inspection; the final pixel pass must be made at the target pixel density.

## 14. QA gates
An asset cannot advance from `MODELED_PENDING_GATE` unless all are true:

### Technical
- file exists;
- alpha valid;
- no accidental opaque background;
- correct dimensions/frames;
- correct anchor;
- manifest hash updated;
- Godot imports without error.

### Visual
- projection matches approved assets;
- silhouette reads at gameplay zoom;
- material reads without labels;
- no primitive/blockout appearance;
- palette is controlled;
- no visible AA halo;
- grounded contact;
- scale is correct beside hero/reference door;
- detail density matches neighboring approved assets;
- visual comparison sheet produced.

### Integration
- collision still matches;
- y-sort/contact anchor correct;
- navigation preserved;
- no REWORKED/HOLD dependency;
- old LEGACY_BASELINE removed only after replacement is integrated.

## 15. Visual review method
For each family produce contact sheets with:
- neutral checker/flat background;
- hero scale reference;
- approved reference asset beside it;
- 100% pixel view;
- gameplay-scale preview.

Critical assets also need in-world screenshots from Godot 4.7.2.

## 16. Current priority for REG_001
Prioritize these unresolved groups:
1. ground + water;
2. NPCs;
3. fauna;
4. cliffs/elevation;
5. watchtower;
6. windmill;
7. outposts/shelters;
8. shrine;
9. waterfall/cliff;
10. crops;
11. dock/boats;
12. cave entrance;
13. interior walls/doors/windows;
14. interaction FX.

## 17. Definition of done
The world is ready for Etapa 2 only when:
- no major POI depends on visibly provisional geometry;
- the dominant terrain no longer exposes obvious legacy tile seams;
- NPC/fauna are no longer tinted/generic placeholders;
- all critical structures have coherent final-form candidates;
- every new candidate is catalogued and visually reviewable;
- Godot 4.7.2 gate remains green;
- Director gate is the only remaining approval step.

## Sources incorporated as principles
This internal skill was authored specifically for Valedouro using general techniques from professional isometric/pixel-art workflows: fixed orthographic pre-render rigs, 3D-to-2D sprite pipelines, low-resolution rendering, hand pixel cleanup, palette/cluster discipline, spritesheet metadata, and pixel-accurate Godot integration. No external skill text is copied verbatim.
