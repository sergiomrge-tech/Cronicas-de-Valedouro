#!/usr/bin/env python3
"""Gate estático REG_001 (Etapa 1): manifestos, IDs, referências, hashes e política APPROVED-only.

Complementa (não substitui) os testes nativos do Godot 4.7.2.
"""
from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'data'


def check(cond: bool, msg: str) -> None:
    if not cond:
        raise AssertionError(msg)


def load(name: str):
    path = DATA / name
    check(path.is_file(), f'{name} ausente')
    return json.loads(path.read_text(encoding='utf-8'))


approved = load('approved_visual_manifest.json')
modeled = load('modeled_assets_manifest.json')
world = load('reg001_world.json')
catalog = load('reg001_asset_catalog.json')
check(approved['count'] == 28, 'esperados 28 APPROVED')
sys.path.insert(0, str(ROOT / 'tools' / 'reg001'))
from spec import APP_KEYS  # chaves curtas do renderer para as 28 peças APPROVED
approved_keys = set(APP_KEYS)
check(len(approved_keys) == 28, 'chaves APPROVED != 28')

# ---- assets modelados: arquivos, quadros, hashes, status
ids = set()
for e in modeled['assets']:
    check(e['id'] not in ids, f"id de asset duplicado: {e['id']}")
    ids.add(e['id'])
    check(e['status'] in {'APPROVED', 'MODELED_PENDING_GATE', 'REJECTED', 'HOLD'}, f"status inválido: {e['id']}")
    check('REWORKED' not in e['path'].upper() and '/HOLD/' not in e['path'].upper(), f"caminho proibido: {e['path']}")
    file = ROOT / e['path'].replace('res://', '')
    check(file.is_file(), f'PNG ausente: {e["path"]}')
    check((file.with_name(file.name + '.import')).is_file(), f'.import ausente: {e["path"]}')
    check(hashlib.sha256(file.read_bytes()).hexdigest() == e['sha256'], f'hash divergente: {e["id"]}')
    with Image.open(file) as im:
        check(im.size == (e['frame_size'][0] * e['frames'], e['frame_size'][1] * e.get('rows', 1)), f'dimensões divergem: {e["id"]}')
        check(im.mode == 'RGBA', f'esperado RGBA: {e["id"]}')
    check(0 <= e['foot'][0] <= e['frame_size'][0] and 0 <= e['foot'][1] <= e['frame_size'][1], f'âncora fora do quadro: {e["id"]}')
check(len(ids) >= 140, 'manifesto de assets modelados incompleto')

# ---- mundo: IDs, referências, terreno declarado
seen = set()
poi_ids = {p['id'] for p in world['pois']}
check(len(poi_ids) == len(world['pois']), 'POI duplicado')
for p in world['pois']:
    check(re.fullmatch(r'REG001_POI_[A-Z0-9_]+', p['id']) is not None, f"ID de POI fora do padrão: {p['id']}")
    d = p['data']
    for key in ('requires_elite', 'requires_secret', 'chest'):
        if key in d:
            check(d[key] in poi_ids, f"{p['id']}: {key} -> {d[key]} inexistente")
    if 'lore' in d:
        check(d['lore'] in world['lore'], f"{p['id']}: lore inexistente")
    if p['kind'] == 'elite':
        check(d['chest'] in poi_ids and d['enemy'], f"elite incompleto: {p['id']}")
for o in world['objects']:
    check(re.fullmatch(r'REG001_OBJ_[A-Z0-9_]+_\d{3}', o['id']) is not None, f"ID de objeto fora do padrão: {o['id']}")
    check(o['id'] not in seen, f"objeto duplicado: {o['id']}")
    seen.add(o['id'])
    a = o['asset']
    if a.startswith('APP:'):
        check(a[4:] in approved_keys, f'APPROVED inexistente: {a}')
    else:
        check(a in ids, f'asset modelado inexistente: {a}')
        status = next(e['status'] for e in modeled['assets'] if e['id'] == a)
        check(status in {'APPROVED', 'MODELED_PENDING_GATE'}, f'asset com status bloqueado no mundo: {a} ({status})')
    for key in ('poi', 'hide_when', 'show_when'):
        if key in o:
            check(o[key].split(':', 1)[-1] in poi_ids or o[key].startswith('lore:'), f"{o['id']}: {key} -> {o[key]} inexistente")
check(len(world['objects']) >= 450 and len(world['pois']) >= 55, 'conteúdo insuficiente')
kinds = {p['kind'] for p in world['pois']}
for needed in ('elite', 'chest', 'secret', 'gate', 'resource', 'camp', 'settlement', 'viewpoint', 'lore', 'npc', 'entrance', 'trap', 'checkpoint', 'shrine'):
    check(needed in kinds, f'tipo de POI ausente: {needed}')
pairs = {tuple(sorted(t['between'])) for t in world['transitions']}
for a, b in [('cidade', 'campos'), ('campos', 'floresta'), ('floresta', 'vale'), ('gelo', 'pradaria'), ('deserto', 'vale'), ('deserto', 'pradaria')]:
    check(tuple(sorted((a, b))) in pairs, f'transição ausente: {a}|{b}')
for zone in ('guilda', 'ferreiro', 'alquimia', 'loja', 'masmorra', 'cripta'):
    check(any(o['zone'] == zone for o in world['objects']), f'zona sem mobília/ambientação: {zone}')

# ---- catálogo
check(catalog['policy']['excluded_counts'] == {'REWORKED': 61, 'HOLD': 22}, 'contagem REWORKED/HOLD alterada')
check(catalog['counts']['APPROVED']['INTEGRATED'] + catalog['counts']['APPROVED'].get('NOT_USED', 0) == 28, 'catálogo APPROVED incompleto')
check(len(catalog['missing_approved_asset']) >= 10, 'lista MISSING_APPROVED_ASSET vazia')
n_mod = sum(1 for e in catalog['entries'] if e['approval'] in ('MODELED_PENDING_GATE', 'APPROVED') and e['id'].startswith('MOD_'))
check(n_mod == len(ids), 'catálogo desatualizado em relação ao manifesto modelado')
check((ROOT.parent / 'docs' / 'catalog' / 'REG001_ASSET_CATALOG.md').is_file(), 'relatório do catálogo ausente')

# ---- renderer nunca referencia REWORKED/HOLD
for path in (ROOT / 'scripts').glob('*.gd'):
    text = path.read_text(encoding='utf-8')
    check(':=' not in text, f'inferência := em {path.name}')
    check(not re.search(r'assets/(rework|hold)', text, re.I), f'referência REWORKED/HOLD em {path.name}')

print(f"STATIC PASS REG_001: {len(ids)} assets modelados, {len(world['objects'])} objetos, {len(world['pois'])} POIs, {len(world['passages'])} passagens, {len(world['trails'])} trilhas, catálogo consistente")
