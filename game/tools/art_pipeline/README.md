# Valedouro Art Pipeline

This folder contains the technical side of the new professional visual-production workflow for **Crônicas de Valedouro**.

## Why this exists
The REG_001 primitive renderer is useful for deterministic blockout, but several assets read as simple geometric constructions. The production art pipeline now separates:

1. blockout/proportion;
2. professional form modeling;
3. locked dimetric render;
4. deterministic pixel conversion;
5. hand pixel cleanup;
6. technical QA;
7. visual Director gate;
8. Godot integration.

## Files

### `blender_valedouro_setup.py`
Creates the starting Blender render rig:
- orthographic camera;
- Valedouro 2:1 dimetric orientation;
- transparent PNG output;
- restrained key/fill lighting;
- no depth-of-field;
- no motion blur;
- shadow-catcher reference plane.

**Mandatory:** before batch rendering, overlay an APPROVED City/Dungeon asset and calibrate camera scale/object scale. The approved asset is the truth; theoretical camera math is only the starting point.

### `pixel_finish.py`
Deterministic bridge from pre-render to pixel cleanup:
- nearest-neighbor integer downsample;
- hard alpha;
- transparent-RGB cleanup;
- optional palette cap.

It is not a replacement for hand cleanup.

### `asset_qc.py`
Technical QA:
- empty/transparent output;
- soft-alpha halo;
- canvas clipping;
- palette explosion;
- suspicious occupancy;
- manifest sheet dimensions;
- foot-anchor bounds.

It does not approve aesthetics.

## Recommended production flow

```
APPROVED visual reference
        |
        v
concept / silhouette thumbnails
        |
        v
3D blockout with hero-scale reference
        |
        v
secondary forms + material breakup
        |
        v
Valedouro Blender rig
        |
        v
high/working render with transparent BG
        |
        v
pixel_finish.py
        |
        v
manual pixel cleanup
        |
        v
asset_qc.py
        |
        v
contact sheet + Godot screenshot
        |
        v
MODELED_PENDING_GATE
        |
        v
Director visual decision
```

## Quality principle
A technically clean asset can still be visually weak. The final acceptance question is:

> Does this asset look intentionally authored for the same game as the approved Valedouro City/Dungeon art at actual gameplay zoom?

If not, it returns to modeling/cleanup instead of being integrated as final art.

## Godot notes
Pixel-art sprites should use nearest texture sampling. Pixel-style dynamic lighting cannot be achieved by texture filtering alone; if dynamic 2D lights are used, light/shadow sampling should be snapped to the chosen pixel grid so it does not conflict with the sprite language.

## Coordination rule
This branch is intentionally separate from the current Claude asset-completion work. Merge only after checking for newer asset/catalog changes on the active production branch.
