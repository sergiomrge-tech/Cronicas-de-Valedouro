"""Traçado da REG_001 a partir de data/reg001_layout.json (fonte única — remapeamento Etapa 1).

Estradas: splines Catmull-Rom amostradas em segmentos (sem cruzamentos em T/90°; junções em Y e praça orgânica).
Cidade: superelipse deformada (contorno orgânico, não retângulo). Biomas: mesmas regras topológicas de antes, avaliadas
em coordenadas deformadas por uma soma de senos (bordas orgânicas idênticas na lógica, no chão assado e no runtime).
`write_grid()` gera data/reg001_layout_grid.json (células de 16 px) lido por scripts/world_map.gd."""
import json
import math
from pathlib import Path

import numpy as np

GAME = Path(__file__).resolve().parents[2]
L = json.loads((GAME / 'data' / 'reg001_layout.json').read_text(encoding='utf-8'))
W, H = L['size']
GRID_CELL = 16
BIOME_LETTER = {'cidade': 'T', 'gelo': 'S', 'deserto': 'D', 'campos': 'C', 'vale': 'V', 'floresta': 'F', 'pradaria': 'P'}
BIOME_IDS = {'cidade': 0, 'gelo': 1, 'deserto': 2, 'campos': 3, 'vale': 4, 'floresta': 5, 'pradaria': 6}


def catmull(pts, step=6.0):
    P = [pts[0]] + [tuple(p) for p in pts] + [pts[-1]]
    out = []
    for i in range(1, len(P) - 2):
        p0, p1, p2, p3 = (np.array(P[j], float) for j in (i - 1, i, i + 1, i + 2))
        n = max(2, int(np.linalg.norm(p2 - p1) / step))
        for k in range(n):
            t = k / n
            t2, t3 = t * t, t * t * t
            q = .5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3 * p1 - 3 * p2 + p3) * t3)
            out.append((float(q[0]), float(q[1])))
    out.append(tuple(map(float, P[-2])))
    return out


def _wob(i, seed):
    return 1.0 + .08 * math.sin(i * .21 + seed) + .05 * math.sin(i * .57 + seed * 2)


ROADS = []          # (id, kind, [(x, y, half)])
for k, r in enumerate(L['roads']):
    s = catmull(r['pts'])
    ROADS.append((r['id'], r['kind'], [(x, y, r['half'] * _wob(i, k)) for i, (x, y) in enumerate(s)]))

SEGS = []           # (ax, ay, bx, by, half)
for _, _, s in ROADS:
    for (ax, ay, ha), (bx, by, hb) in zip(s[:-1], s[1:]):
        SEGS.append((ax, ay, bx, by, (ha + hb) / 2))
_BUCKET = 128
_SEG_GRID = {}
for i, (ax, ay, bx, by, h) in enumerate(SEGS):
    for gx in range(int((min(ax, bx) - h) // _BUCKET), int((max(ax, bx) + h) // _BUCKET) + 1):
        for gy in range(int((min(ay, by) - h) // _BUCKET), int((max(ay, by) + h) // _BUCKET) + 1):
            _SEG_GRID.setdefault((gx, gy), []).append(i)


def _seg_d(px, py, ax, ay, bx, by):
    dx, dy = bx - ax, by - ay
    L2 = dx * dx + dy * dy or 1e-6
    t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / L2))
    return math.hypot(px - ax - dx * t, py - ay - dy * t)


def road_at(x, y, pad=0.0):
    for i in _SEG_GRID.get((int(x // _BUCKET), int(y // _BUCKET)), ()):
        ax, ay, bx, by, h = SEGS[i]
        if _seg_d(x, y, ax, ay, bx, by) < h + pad:
            return True
    return False


def _plaza_d(x, y, p):
    cx, cy = p['center']
    a = math.atan2((y - cy) / p['ry'], (x - cx) / p['rx'])
    wob = 1 + p.get('wobble', .15) * (.6 * math.sin(3 * a + 1.3) + .4 * math.sin(5 * a + .2))
    return math.hypot((x - cx) / p['rx'], (y - cy) / p['ry']) / wob


def plaza_at(x, y):
    return any(_plaza_d(x, y, p) < 1 for p in L['plazas'])


def path_at(x, y):
    return road_at(x, y) or plaza_at(x, y)


def _town_d(x, y):
    t = L['town']
    cx, cy = t['center']
    dx, dy = (x - cx) / t['rx'], (y - cy) / t['ry']
    a = math.atan2(dy, dx)
    wob = t['wobble'] * (math.sin(3 * a + .7) + .6 * math.sin(7 * a + 2.1))
    pw = t['power']
    return (abs(dx) ** pw + abs(dy) ** pw) ** (1 / pw) - wob / min(t['rx'], t['ry'])


def town_area(x, y):
    return _town_d(x, y) < 1.0


def warp(x, y):
    w = L['biome_warp']
    wx = sum(a * math.sin(fx * x + fy * y + ph) for a, fx, fy, ph in w['ax'])
    wy = sum(a * math.sin(fx * x + fy * y + ph) for a, fx, fy, ph in w['ay'])
    return wx, wy


def _biome_rule(bx, by):
    if bx > 2010 and by < 860:
        return 'gelo'
    if bx > 1980 and by > 1370:
        return 'deserto'
    if by > 1570:
        return 'campos' if bx < 760 else 'vale'
    if bx < 1040 or by < 680:
        return 'floresta'
    return 'pradaria'


def biome(x, y):
    if town_area(x, y):
        return 'cidade'
    wx, wy = warp(x, y)
    return _biome_rule(x + wx, y + wy)


# ------------------------------------------------------------------ versões vetorizadas (chão assado)
def warp_np(xx, yy):
    w = L['biome_warp']
    wx = sum(a * np.sin(fx * xx + fy * yy + ph) for a, fx, fy, ph in w['ax'])
    wy = sum(a * np.sin(fx * xx + fy * yy + ph) for a, fx, fy, ph in w['ay'])
    return wx, wy


def town_np(xx, yy):
    t = L['town']
    cx, cy = t['center']
    dx, dy = (xx - cx) / t['rx'], (yy - cy) / t['ry']
    a = np.arctan2(dy, dx)
    wob = t['wobble'] * (np.sin(3 * a + .7) + .6 * np.sin(7 * a + 2.1))
    pw = t['power']
    return (np.abs(dx) ** pw + np.abs(dy) ** pw) ** (1 / pw) - wob / min(t['rx'], t['ry']) < 1.0


def biome_ids_np(xx, yy):
    wx, wy = warp_np(xx, yy)
    bx, by = xx + wx, yy + wy
    out = np.full(xx.shape, 6, dtype=np.int8)
    out = np.where((bx < 1040) | (by < 680), 5, out)
    low = by > 1570
    out = np.where(low & (bx < 760), 3, np.where(low, 4, out))
    out = np.where((bx > 1980) & (by > 1370), 2, out)
    out = np.where((bx > 2010) & (by < 860), 1, out)
    out = np.where(town_np(xx, yy), 0, out)
    return out


def road_mask_np(x0, y0, w, h, kinds=None):
    """Máscara de estradas + praças (px) na janela, desenhada como discos encadeados de meia-largura variável."""
    from PIL import Image, ImageDraw
    im = Image.new('L', (w, h), 0)
    d = ImageDraw.Draw(im)
    for rid, kind, s in ROADS:
        if kinds and kind not in kinds:
            continue
        for x, y, hw in s:
            X, Y = x - x0, y - y0
            if -hw <= X <= w + hw and -hw <= Y <= h + hw:
                d.ellipse((X - hw, Y - hw, X + hw, Y + hw), fill=255)
    m = np.asarray(im) > 127
    if not kinds or 'plaza' in kinds:
        yy, xx = np.mgrid[y0:y0 + h, x0:x0 + w].astype(np.float32)
        for p in L['plazas']:
            cx, cy = p['center']
            a = np.arctan2((yy - cy) / p['ry'], (xx - cx) / p['rx'])
            wob = 1 + p.get('wobble', .15) * (.6 * np.sin(3 * a + 1.3) + .4 * np.sin(5 * a + .2))
            m = m | (np.hypot((xx - cx) / p['rx'], (yy - cy) / p['ry']) / wob < 1)
    return m


def _trail_at(trails_segs, x, y):
    for ax, ay, bx, by, h in trails_segs.get((int(x // _BUCKET), int(y // _BUCKET)), ()):
        if _seg_d(x, y, ax, ay, bx, by) < h:
            return True
    return False


def write_grid(trails=None):
    """Grade lógica para o runtime (16 px): estradas/praças ('1'), cidade ('1') e letra do bioma por célula."""
    gw, gh = W // GRID_CELL, H // GRID_CELL
    tsegs = {}
    for t in trails or ():
        for (ax, ay), (bx, by) in zip(t['pts'][:-1], t['pts'][1:]):
            h = t['half']
            for gx in range(int((min(ax, bx) - h) // _BUCKET), int((max(ax, bx) + h) // _BUCKET) + 1):
                for gy in range(int((min(ay, by) - h) // _BUCKET), int((max(ay, by) + h) // _BUCKET) + 1):
                    tsegs.setdefault((gx, gy), []).append((ax, ay, bx, by, h))
    road, town, bio = [], [], []
    for gy in range(gh):
        r_row, t_row, b_row = [], [], []
        for gx in range(gw):
            x, y = gx * GRID_CELL + GRID_CELL / 2, gy * GRID_CELL + GRID_CELL / 2
            r_row.append('1' if (path_at(x, y) or _trail_at(tsegs, x, y)) else '0')
            t_row.append('1' if town_area(x, y) else '0')
            b_row.append(BIOME_LETTER[biome(x, y)])
        road.append(''.join(r_row))
        town.append(''.join(t_row))
        bio.append(''.join(b_row))
    out = {'cell': GRID_CELL, 'w': gw, 'h': gh, 'road': road, 'town': town, 'biome': bio,
           'structures': L['structures'], 'exits': L.get('exits', []),
           'note': 'gerado por tools/reg001/layout.py a partir de data/reg001_layout.json — não editar à mão'}
    (GAME / 'data' / 'reg001_layout_grid.json').write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')) + '\n', encoding='utf-8')
    return out


if __name__ == '__main__':
    _w = GAME / 'data' / 'reg001_world.json'
    g = write_grid(json.loads(_w.read_text(encoding='utf-8'))['trails'] if _w.exists() else None)
    print('grade', g['w'], 'x', g['h'], '| células de estrada:', sum(r.count('1') for r in g['road']), '| cidade:', sum(r.count('1') for r in g['town']))
