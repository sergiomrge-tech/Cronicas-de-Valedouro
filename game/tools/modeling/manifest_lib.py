"""Manifesto unificado de assets modelados: partes por gerador (kit, terreno, NPC, FX...) -> modeled_assets_manifest.json."""
import hashlib
import json
from pathlib import Path

GAME = Path(__file__).resolve().parents[2]
PARTS = GAME / 'data' / 'modeled_parts'
MANIFEST = GAME / 'data' / 'modeled_assets_manifest.json'
DEFAULT_STATUS = 'MODELED_PENDING_GATE'


def make_entry(id, png: Path, group, folder, frame_size, frames=1, rows=1, foot=(0, 0), draw_scale=.5, blocks_radius=0.0,
               footprint=0.0, tags=(), source='', extra=None):
    e = {
        'id': id,
        'path': 'res://' + png.relative_to(GAME).as_posix(),
        'group': group,
        'folder': folder,
        'frame_size': [int(frame_size[0]), int(frame_size[1])],
        'frames': int(frames),
        'rows': int(rows),
        'foot': [float(foot[0]), float(foot[1])],
        'draw_scale': float(draw_scale),
        'blocks_radius': float(blocks_radius),
        'footprint': float(footprint or blocks_radius),
        'tags': list(tags),
        'sha256': hashlib.sha256(png.read_bytes()).hexdigest(),
        'source': source,
        'status': DEFAULT_STATUS,
    }
    if extra:
        e.update(extra)
    return e


def write_part(name, entries):
    PARTS.mkdir(parents=True, exist_ok=True)
    (PARTS / f'{name}.json').write_text(json.dumps(sorted(entries, key=lambda e: e['id']), indent=1, ensure_ascii=False) + '\n', encoding='utf-8')


def merge():
    old = {}
    if MANIFEST.exists():
        for e in json.loads(MANIFEST.read_text(encoding='utf-8')).get('assets', []):
            old[e['id']] = e.get('status', DEFAULT_STATUS)
    entries = {}
    for part in sorted(PARTS.glob('*.json')):
        for e in json.loads(part.read_text(encoding='utf-8')):
            if e['id'] in entries:
                raise SystemExit('id duplicado entre partes: %s' % e['id'])
            e['status'] = old.get(e['id'], e.get('status', DEFAULT_STATUS))
            e.setdefault('rows', 1)
            entries[e['id']] = e
    doc = {
        'schema_version': 2,
        'manifest_id': 'MAN_MODELED_ASSETS_001',
        'policy': {
            'ids_are_persistent': True,
            'renderer_uses_statuses': ['APPROVED', 'MODELED_PENDING_GATE'],
            'note': 'MODELED_PENDING_GATE = modelado no estilo dos 28 APPROVED, aguardando gate visual do Diretor. Mude o status de um asset para REJECTED/HOLD para removê-lo do renderer.',
        },
        'counts': {'total': len(entries)},
        'assets': [entries[k] for k in sorted(entries)],
    }
    MANIFEST.write_text(json.dumps(doc, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
    return len(entries)
