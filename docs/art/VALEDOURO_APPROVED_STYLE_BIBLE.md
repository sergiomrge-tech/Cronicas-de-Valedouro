# VALEDOURO — APPROVED VISUAL STYLE BIBLE

Source of truth: the reconstructed APPROVED City/Hub + Caves/Dungeons contact sheet already versioned in `approved_source_catalog/part00..07.b64`.

This document records the visual language visible in that approved sheet. It is not a new art direction.

## 1. Core read

Valedouro is **dense, ornamental, high-contrast fantasy pixel art**.

The approved assets do NOT read as:
- minimalist;
- flat;
- soft-painted;
- low-detail low-poly;
- pastel;
- generic procedural primitives.

They read as:
- chunky, readable silhouettes;
- dark selective outlines;
- strong value separation;
- rich material breakup;
- bright focal accents;
- dense but controlled decoration;
- exaggerated RPG proportions;
- hand-authored pixel clusters.

## 2. City / Hub language

### Stone
Warm sandstone/cream family with:
- peach/orange mids;
- pale golden highlights;
- brown-violet occlusion;
- individual blocks clearly readable;
- selective cracks, chips and moss;
- brighter top planes than side planes.

### Roofs
Hero colors:
- saturated royal/cobalt blue;
- vivid red;
- warm timber roof variants.

Roofs contain:
- trim;
- ridge caps;
- gold accents;
- chimneys or finials;
- broken/offset tile rhythm;
- strong dark valleys between planes.

### Wood
Warm orange-brown rather than neutral gray.
Visible:
- beams;
- joints;
- plank direction;
- darker end grain;
- edge highlights.

### Vegetation
High-saturation green with yellow-green highlights.
Vegetation is integrated into architecture:
- wall moss;
- vines;
- planters;
- flowers around foundations;
- foliage breaking silhouettes.

### Metal / ornament
Gold/orange accents are important.
Use on:
- banners;
- roof finials;
- lanterns;
- signs;
- trim;
- heraldry.

### Lighting
Warm emissive light from:
- torches;
- windows;
- lanterns.

These orange lights contrast with blue roofs and dark outlines.

## 3. Dungeon language

### Stone
Cool blue-violet stone.
Not plain gray.

Use:
- navy/indigo shadow;
- slate-violet mid;
- blue-gray highlight;
- selective pale edge light.

### Crystal/emissive
Very saturated:
- cyan;
- electric blue;
- violet;
- occasional red/lava.

Emission is a focal accent and must not wash the full asset.

### Wood
Dungeon timber is warm orange/brown, intentionally contrasting against cool stone.

### Architecture
Dungeon shapes are heavier than city:
- thick pillars;
- deep arches;
- iron bars;
- heavy doors;
- stone bases;
- rails/mineshaft structures;
- substantial stairs.

## 4. Silhouette standard

At gameplay zoom, each asset must be recognizable before texture detail is inspected.

Important silhouettes should use:
- offsets;
- height changes;
- overhangs;
- props;
- broken symmetry;
- roof/beam protrusions;
- vegetation or banners.

Avoid perfect box/cone/cylinder silhouettes.

## 5. Detail hierarchy

### Primary
Overall readable shape.

### Secondary
Construction:
- roof planes;
- buttresses;
- timber frame;
- stairs;
- arches;
- foundation;
- platforms;
- large rock strata.

### Tertiary
Story/detail:
- cracks;
- moss;
- flowers;
- rope;
- nails;
- trim;
- banners;
- barrels;
- rubble;
- lanterns;
- runes.

Tertiary detail must not destroy the primary silhouette.

## 6. Outline language

Use dark navy/brown-violet outlines rather than pure black whenever possible.

Outlines are:
- stronger around external silhouette;
- selective inside the form;
- broken by highlights where useful;
- not uniformly one-pixel around every internal surface.

## 7. Contrast

Approved art uses large value jumps.

Do not compress everything into mid-tones.

A typical object should contain:
- deep occlusion;
- dark structural color;
- readable local mid;
- bright top/edge plane;
- small high-energy accent.

## 8. Working palette roles

These are workflow roles, not immutable swatches. Final values should be extracted from APPROVED PNGs with `extract_approved_palette.py`.

- Outline: very dark navy / violet-brown
- City stone shadow: muted violet-brown
- City stone mid: warm peach sandstone
- City stone light: pale cream/gold
- Roof blue dark: deep cobalt
- Roof blue mid: saturated royal blue
- Roof blue light: cyan-blue edge highlight
- Roof red dark: burgundy
- Roof red mid: bright red
- Gold dark: burnt orange
- Gold light: yellow-gold
- Wood dark: deep brown
- Wood mid: warm orange-brown
- Foliage dark: forest green
- Foliage mid: vivid green
- Foliage light: yellow-green
- Dungeon stone dark: navy-indigo
- Dungeon stone mid: slate violet
- Dungeon stone light: blue-gray
- Crystal cyan: electric cyan
- Crystal purple: saturated violet
- Lava: saturated red-orange

## 9. Professional asset acceptance

Reject a candidate if any are true:
- mostly flat gray/brown with no accent hierarchy;
- primitive silhouette still obvious;
- material cannot be identified at gameplay zoom;
- city asset lacks warm/cool contrast;
- dungeon asset looks like city stone recolored gray;
- architecture has no trim/joints/construction logic;
- vegetation is spherical/featureless;
- repeated identical micro-detail creates noise;
- shadow direction conflicts with approved sheet;
- scale does not match doors/hero;
- anti-aliased halo survives pixel cleanup.

## 10. Landmark bar

Watchtower, windmill, shrine, cave entrance, waterfall/cliff, dock and outposts must contain enough secondary/tertiary detail to sit beside the approved:
- city gate;
- blue-roof houses;
- merchant stall;
- fountain;
- dungeon boss stairs/platform;
- mine entrances;
- crystal clusters.

If a landmark looks visibly simpler than those references, it is not finished.

## 11. Character bar

NPCs should inherit the same contrast logic:
- dark outer silhouette;
- rich cloth/leather clusters;
- small metal/gold accents;
- profession-readable props;
- no simple recolor of hero.

## 12. Review format

Every new family must be reviewed:
1. isolated on neutral dark checker;
2. next to an APPROVED reference;
3. next to 48x56 hero scale reference;
4. at 100%;
5. at gameplay scale;
6. inside Godot 4.7.2.

Only the Director can change `MODELED_PENDING_GATE` to `APPROVED`.
