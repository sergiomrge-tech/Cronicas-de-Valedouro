#!/usr/bin/env python3
"""Renderiza os assets modelados (Natureza, Cidade, Dungeon, Interiores) -> game/assets/modeled/.

Uso: python3 build_assets.py [id_ou_prefixo ...] [--sheet arquivo.png]
Determinístico. Os PNGs gerados são versionados; o gerador fica como fonte.
"""
import sys, json, hashlib, importlib, inspect
from pathlib import Path
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from registry import REGISTRY
from kit import Scene
import manifest_lib

MODULES = ['nature_a', 'nature_b', 'nature_c', 'city_extra', 'dungeon_extra', 'interior_kit', 'terrain_forms', 'structures']
GAME = HERE.parents[1]
OUT = GAME / 'assets' / 'modeled'
MANIFEST = GAME / 'data' / 'modeled_assets_manifest.json'
SHEETS = GAME.parent / 'docs' / 'visual_qa'
DEFAULT_STATUS = 'MODELED_PENDING_GATE'


def pro_ids():
    f = GAME / 'data' / 'modeled_parts' / 'pro.json'
    ids = {e['id'] for e in json.loads(f.read_text(encoding='utf-8'))} if f.exists() else set()
    reg = GAME / 'data' / 'pro_registry_ids.json'
    if reg.exists():
        ids |= set(json.loads(reg.read_text(encoding='utf-8')))
    return ids


def load_modules():
    for name in MODULES:
        if (HERE / f'{name}.py').exists():
            importlib.import_module(name)


def render(spec, frame=0, row=0):
    sc = Scene(spec.size[0], spec.size[1], spec.origin, scale=spec.scale, seed=spec.seed, az=spec.az)
    sc.ground_shadow = False
    if spec.contact is not None:
        sc.contact = spec.contact
    if 'row' in inspect.signature(spec.build).parameters:
        spec.build(sc, frame, row=row)
    else:
        spec.build(sc, frame)
    return sc.render()


def render_sheet(spec):
    fw, fh = spec.size
    im = Image.new('RGBA', (fw * spec.frames, fh * spec.rows), (0, 0, 0, 0))
    for r in range(spec.rows):
        for i in range(spec.frames):
            im.paste(render(spec, i, r), (i * fw, r * fh))
    return im


def main(argv):
    sheet = None
    filters = []
    it = iter(argv)
    for a in it:
        if a == '--sheet':
            sheet = next(it)
        else:
            filters.append(a)
    load_modules()
    skip = pro_ids()
    specs = [s for s in REGISTRY if s.id not in skip and (not filters or any(s.id.startswith(f) for f in filters))]
    tiles = []
    entries = {}
    for spec in specs:
        im = render_sheet(spec)
        folder = OUT / spec.group / spec.folder
        folder.mkdir(parents=True, exist_ok=True)
        path = folder / f'{spec.id}.png'
        im.save(path)
        tiles.append((spec, im))
        entries[spec.id] = manifest_entry(spec, im, path)
        print('OK', spec.id, im.size)
    if not filters:
        write_manifest(entries)
        make_group_sheets(tiles)
    if sheet:
        make_sheet(tiles, sheet)


def manifest_entry(spec, im, path):
    return manifest_lib.make_entry(spec.id, path, spec.group, spec.folder, spec.size, spec.frames, spec.rows, spec.origin, spec.draw_scale,
                                   spec.blocks[0] if spec.blocks else 0.0, spec.footprint, spec.tags, 'game/tools/modeling/build_assets.py',
                                   extra={'collision': [list(c) for c in spec.collision]} if spec.collision else None)


def write_manifest(entries):
    manifest_lib.write_part('kit', list(entries.values()))
    print('MANIFEST', manifest_lib.merge())


def make_group_sheets(tiles):
    SHEETS.mkdir(parents=True, exist_ok=True)
    for group, bg in (('nature', (70, 108, 66, 255)), ('city', (70, 108, 66, 255)), ('dungeon', (52, 48, 66, 255)), ('interior', (58, 52, 46, 255))):
        sub = [(s, i) for s, i in tiles if s.group == group]
        if sub:
            make_sheet(sub, str(SHEETS / f'modeled_{group}.png'), bg=bg)


def make_sheet(tiles, path, bg=(70, 108, 66, 255), width=1500, zoom=1):
    x = y = rowh = 0
    pad = 10
    layout = []
    for spec, im in tiles:
        w = im.width // 1 if spec.frames == 1 else spec.size[0]
        im2 = im if spec.frames == 1 else im.crop((0, 0, spec.size[0], spec.size[1]))
        w, h = im2.size
        if x + w > width:
            x = 0; y += rowh + pad + 12; rowh = 0
        layout.append((spec, im2, x, y))
        x += w + pad
        rowh = max(rowh, h)
    sheet = Image.new('RGBA', (width, y + rowh + 30), bg)
    d = ImageDraw.Draw(sheet)
    for spec, im2, x, y in layout:
        sheet.alpha_composite(im2, (x, y + 12))
        d.text((x, y), spec.id[:26], fill=(255, 255, 255, 255))
    sheet.save(path)


if __name__ == '__main__':
    main(sys.argv[1:])
