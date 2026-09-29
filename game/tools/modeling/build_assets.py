#!/usr/bin/env python3
"""Renderiza os assets modelados (Natureza, Cidade, Dungeon, Interiores) -> game/assets/modeled/.

Uso: python3 build_assets.py [id_ou_prefixo ...] [--sheet arquivo.png]
Determinístico. Os PNGs gerados são versionados; o gerador fica como fonte.
"""
import sys, json, hashlib, importlib
from pathlib import Path
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from registry import REGISTRY
from kit import Scene

MODULES = ['nature_a', 'nature_b', 'nature_c', 'city_extra', 'dungeon_extra', 'interior_kit']
GAME = HERE.parents[1]
OUT = GAME / 'assets' / 'modeled'
MANIFEST = GAME / 'data' / 'modeled_assets_manifest.json'
SHEETS = GAME.parent / 'docs' / 'visual_qa'
DEFAULT_STATUS = 'MODELED_PENDING_GATE'


def load_modules():
    for name in MODULES:
        if (HERE / f'{name}.py').exists():
            importlib.import_module(name)


def render(spec, frame=0):
    sc = Scene(spec.size[0], spec.size[1], spec.origin, scale=spec.scale, seed=spec.seed)
    sc.ground_shadow = False
    spec.build(sc, frame)
    return sc.render()


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
    specs = [s for s in REGISTRY if not filters or any(s.id.startswith(f) for f in filters)]
    tiles = []
    entries = {}
    for spec in specs:
        if spec.frames > 1:
            frames = [render(spec, i) for i in range(spec.frames)]
            im = Image.new('RGBA', (spec.size[0] * spec.frames, spec.size[1]), (0, 0, 0, 0))
            for i, fr in enumerate(frames):
                im.paste(fr, (i * spec.size[0], 0))
        else:
            im = render(spec)
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
    w, h = spec.size
    return {
        'id': spec.id,
        'path': 'res://assets/modeled/%s/%s/%s.png' % (spec.group, spec.folder, spec.id),
        'group': spec.group,
        'folder': spec.folder,
        'frame_size': [w, h],
        'frames': spec.frames,
        'foot': [spec.origin[0], spec.origin[1]],
        'draw_scale': spec.draw_scale,
        'blocks_radius': float(spec.blocks[0]) if spec.blocks else 0.0,
        'footprint': float(spec.footprint or (spec.blocks[0] if spec.blocks else 0.0)),
        'tags': list(spec.tags),
        'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
        'source': 'game/tools/modeling/build_assets.py',
        'status': DEFAULT_STATUS,
    }


def write_manifest(entries):
    old = {}
    if MANIFEST.exists():
        for e in json.loads(MANIFEST.read_text(encoding='utf-8')).get('assets', []):
            old[e['id']] = e.get('status', DEFAULT_STATUS)
    for k, e in entries.items():
        e['status'] = old.get(k, DEFAULT_STATUS)
    doc = {
        'schema_version': 1,
        'manifest_id': 'MAN_MODELED_ASSETS_001',
        'policy': {
            'ids_are_persistent': True,
            'renderer_uses_statuses': ['APPROVED', 'MODELED_PENDING_GATE'],
            'note': 'MODELED_PENDING_GATE = modelado no estilo dos 28 APPROVED, aguardando gate visual do Diretor. Mude o status de um asset para REJECTED/HOLD para removê-lo do renderer.',
        },
        'counts': {'total': len(entries)},
        'assets': [entries[k] for k in sorted(entries)],
    }
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps(doc, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
    print('MANIFEST', len(entries))


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
