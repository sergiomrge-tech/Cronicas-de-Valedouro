#!/usr/bin/env python3
"""Catálogo REG_001: APPROVED / MODELED_PENDING_GATE / LEGACY_BASELINE x INTEGRATED / NOT_USED / MISSING_APPROVED_ASSET.

Gera game/data/reg001_asset_catalog.json e docs/catalog/REG001_ASSET_CATALOG.md a partir das fontes de verdade:
approved_visual_manifest.json (bundle base aprovado), modeled_assets_manifest.json (incluindo promoções do Diretor), reg001_world.json, asset_catalog.json (legado) e scripts/*.gd.
"""
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT.parent / 'docs' / 'catalog'
DATA = ROOT / 'data'


def load(name):
    return json.loads((DATA / name).read_text(encoding='utf-8'))


approved = load('approved_visual_manifest.json')
modeled = load('modeled_assets_manifest.json')
world = load('reg001_world.json')
legacy = load('asset_catalog.json')
scripts = {p.name: p.read_text(encoding='utf-8') for p in (ROOT / 'scripts').glob('*.gd')}
main_text = scripts['main.gd']
proc_text = scripts['reg001_procedural.gd']

# ---- uso por fonte
world_assets = Counter(o['asset'] for o in world['objects'])
style_assets = {a for st in world['biome_style'].values() for k in ('decals', 'edge') for a in st.get(k, [])}
code_assets = set(re.findall(r'"((?:nat|city|dg|int)_[a-z0-9_]+)"', proc_text + main_text + scripts['reg001_gameplay.gd'] + scripts['reg001_render.gd']))
app_used = {a[4:] for a in world_assets if a.startswith('APP:')}
app_paths = {}
for m in re.finditer(r'"(city_[a-z_]+|dungeon_[a-z_]+)": "res://assets/approved/([^"]+)"', main_text):
    app_paths[m.group(1)] = m.group(2)


# mapa chave-do-renderer -> chave do manifesto (ex.: city_floor_clean -> city/floor_stone_clean)
renderer_key = {}
for m in re.finditer(r'"([a-z_]+)": "res://assets/approved/([a-z]+)/[a-z]+/([a-z_]+)\.png"', main_text):
    renderer_key['%s/%s' % (m.group(2), m.group(3))] = m.group(1)

entries = []
for key in approved['city'] + approved['dungeon']:
    flat = renderer_key.get(key, key.replace('/', '_'))
    used = (flat in app_used) or (('"%s"' % flat) in main_text.split('func draw_approved_visual(')[1]) or bool(re.search(r'"%s"' % flat, main_text[main_text.index('func draw_approved_visual('):]))
    entries.append({'id': 'APP_' + key.replace('/', '_').upper(), 'key': flat, 'group': key.split('/')[0], 'approval': 'APPROVED',
                    'usage': 'INTEGRATED' if used else 'NOT_USED', 'source': 'approved_assets_bundle (Lote 01, QA Claude)'})

for e in modeled['assets']:
    used = e['id'] in world_assets or e['id'] in style_assets or e['id'] in code_assets
    entries.append({'id': 'MOD_' + e['id'].upper(), 'key': e['id'], 'group': e['group'], 'approval': e['status'],
                    'usage': 'INTEGRATED' if used else 'NOT_USED', 'placed': world_assets.get(e['id'], 0), 'source': e['source']})

for e in legacy['assets']:
    if e['runtime_status'] != 'LEGACY_RUNTIME':
        continue
    entries.append({'id': e['id'], 'key': e['path'], 'group': e['category'], 'approval': 'LEGACY_BASELINE', 'usage': 'INTEGRATED', 'source': 'v0.6 gerado por tools/*.py (não faz parte do Lote 01)'})

MISSING = [
    ('MISSING_NPC_ARTISTS', 'NPCs viajantes/ambientais e moradores com sprite APPROVED (hoje: hero_body tingido, LEGACY_BASELINE)', 'REG001_POI_VIAJANTE_NORTE, REG001_POI_ESTACAO_LESTE, assentamentos'),
    ('MISSING_FAUNA_APPROVED', 'Fauna APPROVED: cervo, raposa, lebre, cabra, camelo, ave, peixe (hoje: sprites legados)', 'populate_animals / fauna por bioma'),
    ('MISSING_STRUCT_WATCHTOWER', 'Torre de vigia APPROVED (mirantes Oeste/Norte)', 'REG001_POI_MIRANTE_OESTE, REG001_POI_MIRANTE_NORTE'),
    ('MISSING_STRUCT_WINDMILL', 'Moinho APPROVED', 'Moinho do Vale'),
    ('MISSING_STRUCT_OUTPOST', 'Posto de Âmbar e Abrigo da Geada APPROVED', 'STRUCTURES legadas'),
    ('MISSING_STRUCT_SHRINE', 'Santuário APPROVED (hoje: sprite legado + altar modelado)', 'REG001_POI_SANTUARIO_VALE'),
    ('MISSING_GROUND_TILES', 'Tiles de chão APPROVED para grama, areia, neve, terra, estrada e água rasa/profunda (hoje: tiles legados 32 px)', 'ground_at / draw loop'),
    ('MISSING_WATERFALL_CLIFF', 'Cachoeira/penhasco APPROVED (hoje: efeito animado + rochas modeladas)', 'Cachoeira da Aurora'),
    ('MISSING_CROPS', 'Plantações/canteiros APPROVED para fazendas', 'REG001_POI_FAZENDA'),
    ('MISSING_BOAT_DOCK', 'Barcos, cais e docas APPROVED', 'rio / cais leste'),
    ('MISSING_HILL_ELEVATION', 'Peças de colina/elevação/falésia APPROVED (Colinas do Leste)', 'REG001_POI_ESTACAO_LESTE'),
    ('MISSING_CAVE_ENTRANCE', 'Entrada de caverna em rocha APPROVED para dungeons ao ar livre (hoje: portcullis + estátuas modeladas)', 'REG001_POI_CRIPTA_ENTRADA'),
    ('MISSING_INTERIOR_WALLS_APPROVED', 'Paredes/portas/janelas internas APPROVED específicas (hoje: paredes de Cidade APPROVED + kit modelado)', 'guilda/ferreiro/loja/alquimia'),
    ('MISSING_HERO_ANIM_FX', 'FX de interação (abrir baú, colher, cavar) APPROVED', 'gameplay REG_001'),
]
excluded = approved['excluded']
counts = defaultdict(Counter)
for e in entries:
    counts[e['approval']][e['usage']] += 1

catalog = {
    'schema_version': 1,
    'catalog_id': 'CAT_REG001_STAGE1_001',
    'policy': {
        'renderer_uses': ['APPROVED', 'MODELED_PENDING_GATE', 'LEGACY_BASELINE (inalterado desde v0.6)'],
        'never_in_renderer': ['REWORKED', 'HOLD'],
        'excluded_counts': excluded,
        'note': 'MODELED_PENDING_GATE aguarda o gate visual do Diretor; altere o status no manifesto para removê-lo do renderer.',
    },
    'counts': {k: dict(v) for k, v in counts.items()},
    'missing_approved_asset': [{'id': i, 'need': n, 'used_by': u} for i, n, u in MISSING],
    'ids': {
        'pois': [p['id'] for p in world['pois']],
        'transitions': [t['id'] for t in world['transitions']],
        'trails': [t['id'] for t in world['trails']],
        'passages': [p['id'] for p in world['passages']],
        'lore': list(world['lore'].keys()),
        'object_count': len(world['objects']),
    },
    'entries': entries,
}
(DATA / 'reg001_asset_catalog.json').write_text(json.dumps(catalog, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')

# ---- relatório humano
DOCS.mkdir(parents=True, exist_ok=True)
lines = ['# Catálogo de assets REG_001 — Etapa 1 (Mundo Rico)', '',
         'Gerado por `game/tools/build_reg001_catalog.py`. Fonte de verdade: `game/data/reg001_asset_catalog.json`.', '',
         '## Política', '',
         '- **APPROVED** (%d): inclui o bundle base do Lote 01 e assets modelados posteriormente promovidos pelo Diretor.' % sum(1 for e in entries if e['approval'] == 'APPROVED'),
         '- **MODELED_PENDING_GATE** (%d): modelados nesta etapa no mesmo ângulo/paleta dos APPROVED (Natureza, Cidade, Dungeon, Interiores). **Aguardam o gate visual do Diretor**; o renderer só os usa enquanto o status estiver liberado em `modeled_assets_manifest.json`.' % sum(1 for e in entries if e['approval'] == 'MODELED_PENDING_GATE'),
         '- **LEGACY_BASELINE**: arte v0.6 gerada por código (chão, fauna, herói, UI, marcos). Inalterada; não é APPROVED — segue em produção até substituição.',
         '- **REWORKED (%d) / HOLD (%d)**: fora do renderer final, sem exceção.' % (excluded['REWORKED'], excluded['HOLD']), '',
         '## Contagem por status', '', '| Aprovação | INTEGRATED | NOT_USED |', '|---|---:|---:|']
for approval in ['APPROVED', 'MODELED_PENDING_GATE', 'LEGACY_BASELINE']:
    lines.append('| %s | %d | %d |' % (approval, counts[approval]['INTEGRATED'], counts[approval]['NOT_USED']))
lines += ['', '## MISSING_APPROVED_ASSET', '', 'Itens indispensáveis sem asset APPROVED. Nada foi pintado por código para suprir a falta.', '', '| ID | Necessidade | Usado por |', '|---|---|---|']
for i, n, u in MISSING:
    lines.append('| `%s` | %s | %s |' % (i, n, u))
lines += ['', '## MODELED_PENDING_GATE — por grupo', '']
by_group = defaultdict(list)
for e in entries:
    if e['approval'] == 'MODELED_PENDING_GATE':
        by_group[e['group']].append(e)
for group in ['nature', 'city', 'dungeon', 'interior']:
    items = by_group[group]
    lines.append('### %s (%d)' % (group, len(items)))
    lines.append('')
    lines.append('| Asset | Uso | Instâncias |')
    lines.append('|---|---|---:|')
    for e in sorted(items, key=lambda x: x['key']):
        lines.append('| `%s` | %s | %d |' % (e['key'], e['usage'], e.get('placed', 0)))
    lines.append('')
lines += ['## APPROVED (28)', '', '| Chave | Uso |', '|---|---|']
for e in entries:
    if e['approval'] == 'APPROVED':
        lines.append('| `%s` | %s |' % (e['key'], e['usage']))
lines += ['', '## IDs persistentes', '',
          '- POIs: %d (`REG001_POI_*`); objetos: %d (`REG001_OBJ_<GRUPO>_<n>`); transições: %d; trilhas: %d; passagens: %d; fragmentos de lore: %d.' % (len(world['pois']), len(world['objects']), len(world['transitions']), len(world['trails']), len(world['passages']), len(world['lore'])), '']
(DOCS / 'REG001_ASSET_CATALOG.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
print('CATALOG OK:', {k: dict(v) for k, v in counts.items()}, 'missing', len(MISSING))

# ---- tabela de IDs do mundo (docs/planning)
PLAN = ROOT.parent / 'docs' / 'planning'
rows = ['# REG_001 — IDs do mundo manual (Etapa 1)', '',
        'Gerado por `game/tools/build_reg001_catalog.py` a partir de `game/data/reg001_world.json` (fonte: `game/tools/reg001/build_world.py`).',
        'Todos os IDs são persistentes: nada crítico depende de nomes exibidos.', '',
        '## POIs', '', '| ID | Tipo | Rótulo | Região | Zona | Tier | Camada |', '|---|---|---|---|---|---:|---|']
for p in world['pois']:
    rows.append('| `%s` | %s | %s | %s | %s | %d | %s |' % (p['id'], p['kind'], p['label'].title(), p['region'], p['zone'], p['tier'], p['layer']))
rows += ['', '## Transições de bioma', '', '| ID | Entre | Largura (px) |', '|---|---|---:|']
for t in world['transitions']:
    rows.append('| `%s` | %s ↔ %s | %d |' % (t['id'], t['between'][0], t['between'][1], t['width']))
rows += ['', '## Trilhas (rotas secundárias) e passagens', '', '| ID | Nota |', '|---|---|']
for t in world['trails']:
    rows.append('| `%s` | %s |' % (t['id'], t['note']))
for t in world['passages']:
    rows.append('| `%s` | %s (%s) |' % (t['id'], t['note'], t['kind']))
rows += ['', '## Fragmentos de lore', '', '| ID | Título |', '|---|---|']
for k, v in world['lore'].items():
    rows.append('| `%s` | %s |' % (k, v['title']))
rows.append('')
(PLAN / 'CRONICAS_VALEDOURO_REG001_WORLD_IDS_v1.md').write_text('\n'.join(rows), encoding='utf-8')
print('IDS DOC OK')
