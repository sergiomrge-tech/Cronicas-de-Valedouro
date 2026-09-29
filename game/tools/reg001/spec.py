"""Construtor declarativo do conteúdo manual da REG_001 (Berço de Valedouro).

O resultado é serializado em game/data/reg001_world.json. Tudo que é CRÍTICO usa IDs persistentes
(REG001_POI_*, REG001_OBJ_*, REG001_PASS_*, REG001_LOOT_*, REG001_LORE_*); nomes exibidos são só rótulos.
A vegetação/props naturais procedurais NÃO estão aqui: são gerados em runtime por seed
(world_map.gd + reg001_world.gd) respeitando as zonas de exclusão emitidas por este arquivo.
"""
import json
import math
import random
from pathlib import Path

import geo

GAME = Path(__file__).resolve().parents[2]
MANIFEST = json.loads((GAME / 'data' / 'modeled_assets_manifest.json').read_text(encoding='utf-8'))
ASSETS = {e['id']: e for e in MANIFEST['assets']}
APPROVED_KEYS = set(json.loads((GAME / 'data' / 'approved_visual_manifest.json').read_text(encoding='utf-8'))['city'] +
                    json.loads((GAME / 'data' / 'approved_visual_manifest.json').read_text(encoding='utf-8'))['dungeon'])
# chave curta usada no renderer (main.gd APPROVED_VISUAL_PATHS)
APP_KEYS = {
    'city_house_door', 'city_house_window', 'city_roof_blue', 'city_roof_red', 'city_roof_wood', 'city_wall', 'city_wall_vegetation',
    'city_gate', 'city_store', 'city_tree_green', 'city_tree_autumn', 'city_water_edge', 'city_floor_clean', 'city_floor_worn', 'city_floor_moss',
    'dungeon_floor_stone', 'dungeon_floor_broken', 'dungeon_wall', 'dungeon_corner', 'dungeon_arch', 'dungeon_door', 'dungeon_rail',
    'dungeon_crystal_blue', 'dungeon_crystal_purple', 'dungeon_torch', 'dungeon_emissive_crystal', 'dungeon_spikes', 'dungeon_corridor',
}


class World:
    def __init__(self):
        self.objects = []
        self.pois = []
        self.passages = []
        self.colliders = []
        self.clear_zones = []
        self.emitters = []
        self.warnings = []
        self.counters = {}
        self.rnd = random.Random(270901)

    # ------------------------------------------------------------------ ids
    def next_id(self, prefix):
        n = self.counters.get(prefix, 0) + 1
        self.counters[prefix] = n
        return '%s_%03d' % (prefix, n)

    # ------------------------------------------------------------------ objetos
    def obj(self, asset, x, y, group, zone='cidade', poi=None, layer='decor', scale=None, sy=None, solid=None,
            hide_when=None, show_when=None, anim=0.0, check=True, flip=False):
        """Coloca um sprite. asset = id modelado ou 'APP:<chave aprovada>'."""
        if asset.startswith('APP:'):
            if asset[4:] not in APP_KEYS:
                raise SystemExit('asset APPROVED desconhecido: %s' % asset)
            r = 0.0
        else:
            if asset not in ASSETS:
                raise SystemExit('asset modelado desconhecido: %s' % asset)
            r = float(ASSETS[asset]['blocks_radius'])
        is_solid = (r > 0) if solid is None else solid
        if zone == 'cidade' and check:
            t = geo.terrain(x, y)
            if is_solid and t in ('water', 'shallow', 'bridge', 'path'):
                self.warnings.append('%s em %s (%.0f,%.0f) [%s]' % (asset, t, x, y, group))
        oid = self.next_id('REG001_OBJ_' + group)
        o = {'id': oid, 'asset': asset, 'pos': [round(x, 1), round(y, 1)], 'zone': zone, 'layer': layer}
        if poi:
            o['poi'] = poi
        if scale is not None:
            o['scale'] = scale
        if sy is not None:
            o['sy'] = round(sy, 1)
        if is_solid and r > 0:
            o['solid'] = round(r, 1)
        comp = None if asset.startswith('APP:') else ASSETS[asset].get('collision')
        if comp and solid is not False:
            # colisão composta do asset (círculos em px de jogo relativos ao pé), sem depender de nomes
            k = 1.0 if scale is None else float(scale)
            for dx, dy, cr_ in comp:
                self.collider('circle', round(x + dx * k, 1), round(y + dy * k, 1), round(cr_ * k, 1), zone=zone, hide_when=hide_when)
        if hide_when:
            o['hide_when'] = hide_when
        if show_when:
            o['show_when'] = show_when
        if anim:
            o['anim'] = anim
        if flip:
            o['flip'] = True
        self.objects.append(o)
        return o

    def ring(self, asset, cx, cy, r, n, group, start=0.0, jitter=0.0, ry=None, **kw):
        ry = r if ry is None else ry
        for i in range(n):
            a = start + i / n * 2 * math.pi
            j = self.rnd.uniform(-jitter, jitter)
            self.obj(asset, cx + math.cos(a) * (r + j), cy + math.sin(a) * (ry + j), group, **kw)

    def line(self, asset, x0, y0, x1, y1, step, group, jitter=0.0, skip=None, **kw):
        L = math.hypot(x1 - x0, y1 - y0)
        n = max(1, int(L / step))
        for i in range(n + 1):
            if skip and i in skip:
                continue
            t = i / n
            self.obj(asset, x0 + (x1 - x0) * t + self.rnd.uniform(-jitter, jitter), y0 + (y1 - y0) * t + self.rnd.uniform(-jitter, jitter), group, **kw)

    def iso_run(self, prefix, kind, x, y, n, group, step=32.0, **kw):
        """Fileira alinhada à diagonal isométrica. kind 'a' sobe para a direita, 'b' desce para a direita.
        (x,y) = centro do primeiro segmento; cada segmento avança (step, ±step/2)."""
        dy = -step / 2 if kind == 'a' else step / 2
        skip = kw.pop('skip', ())
        for k in range(n):
            if k in skip:
                continue
            self.obj('%s_%s' % (prefix, kind), x + step * k, y + dy * k, group, **kw)

    def scatter(self, assets, cx, cy, radius, n, group, min_dist=40.0, **kw):
        return self._scatter(assets, cx, cy, radius, n, group, min_dist, **kw)

    def _scatter(self, assets, cx, cy, radius, n, group, min_dist=40.0, **kw):
        placed = []
        tries = 0
        while len(placed) < n and tries < n * 30:
            tries += 1
            a = self.rnd.uniform(0, 2 * math.pi)
            d = math.sqrt(self.rnd.uniform(0.05, 1)) * radius
            x, y = cx + math.cos(a) * d, cy + math.sin(a) * d
            if any(math.hypot(x - px, y - py) < min_dist for px, py in placed):
                continue
            if kw.get('zone', 'cidade') == 'cidade' and geo.terrain(x, y) in ('water', 'shallow', 'bridge', 'path'):
                continue
            placed.append((x, y))
            self.obj(self.rnd.choice(assets), x, y, group, **kw)

    def house(self, x, y, roof, group, poi=None, zone='cidade', ruined=False):
        """Casa da cidade: UMA peça modelada inteira (corpo, porta, janela, madeiramento e telhado ancorado nas paredes), com colisão de base."""
        asset = {'city_roof_blue': 'val_town_house_blue', 'city_roof_red': 'val_town_house_red', 'city_roof_wood': 'val_town_house_wood'}.get(roof, 'val_town_house_wood')
        self.obj(asset, x, y, group, zone=zone, poi=poi, solid=False, check=False)
        self.collider('rect', x - 80, y - 42, 160, 48, zone=zone, poi=poi)      # planta vista em 3/4

    def collider(self, kind, a, b, c, d=None, zone='cidade', poi=None, hide_when=None):
        col = {'kind': kind, 'zone': zone}
        if kind == 'circle':
            col.update({'pos': [a, b], 'r': c})
        else:
            col.update({'rect': [a, b, c, d]})
        if poi:
            col['poi'] = poi
        if hide_when:
            col['hide_when'] = hide_when
        self.colliders.append(col)

    def clear(self, x, y, r):
        self.clear_zones.append([round(x, 1), round(y, 1), round(r, 1)])

    def emitter(self, kind, x, y, radius=24.0, zone='cidade', hide_when=None, show_when=None):
        em = {'kind': kind, 'pos': [round(x, 1), round(y, 1)], 'radius': radius, 'zone': zone}
        if hide_when:
            em['hide_when'] = hide_when
        if show_when:
            em['show_when'] = show_when
        self.emitters.append(em)

    # ------------------------------------------------------------------ POIs / passagens
    def poi(self, pid, kind, label, x, y, tier=1, layer='main', radius=70.0, zone='cidade', region='', data=None, show_label=True, clear=None):
        p = {'id': pid, 'kind': kind, 'label': label, 'pos': [round(x, 1), round(y, 1)], 'zone': zone, 'radius': radius,
             'tier': tier, 'layer': layer, 'region': region, 'show_label': show_label, 'data': data or {}}
        self.pois.append(p)
        if zone == 'cidade':
            self.clear(x, y, clear if clear is not None else radius * .9)
        return p

    def passage(self, pid, kind, rect, requires=None, note=''):
        self.passages.append({'id': pid, 'kind': kind, 'rect': [round(v, 1) for v in rect], 'requires': requires, 'note': note})
