"""Remapeamento Etapa 2 — Valedouro: anel de muralha orgânico e quarteirões ao longo das ruas.

Regras (skill valedouro-asset-quality + referência estrutural Kenney Sketch Town, reconstruída no padrão Valedouro):
  * muralha SÓ nos eixos isométricos, em passos exatos da peça, torre em todo vértice; o traçado segue o contorno orgânico da
    cidade em "dentes" (escada isométrica) e TERMINA no rio com torre de ponta — nunca atravessa a água;
  * portões onde as avenidas saem da cidade (o vão absorve o descasamento da grade isométrica);
  * casas inteiras em 3/4 com a porta voltada para a rua, afastadas da via, com anexos/props variados (sem fileira repetida).
"""
import math
import random

import geo
import layout

L_SEG = 90.1
DX, DY = 80.6, 40.3
DIRS = {'se': (DX, DY), 'nw': (-DX, -DY), 'sw': (-DX, DY), 'ne': (DX, -DY)}
TARGET = 0.94            # fração do contorno da cidade onde corre a muralha (por dentro da borda do chão da cidade)


def _near_river(x, y, pad):
    return abs(x - geo.river_x(y)) < geo.river_hw(y) + pad


def _grad(x, y):
    e = 4.0
    return ((layout._town_d(x + e, y) - layout._town_d(x - e, y)) / (2 * e), (layout._town_d(x, y + e) - layout._town_d(x, y - e)) / (2 * e))


def walk_arm(start, ccw, stop, max_runs=40, run=2):
    """Escada isométrica ao longo do contorno a partir de `start`. ccw=True percorre no sentido anti-horário da tela.
    `stop(x, y)` -> True quando o próximo vértice não deve ser alcançado (portão, rio). Devolve a lista de movimentos."""
    x, y = start
    moves = []
    for _ in range(max_runs):
        gx, gy = _grad(x, y)
        tx, ty = (gy, -gx) if ccw else (-gy, gx)             # tangente ao contorno
        n = math.hypot(tx, ty) or 1.0
        tx, ty = tx / n, ty / n
        best = None
        for d, (dx, dy) in DIRS.items():
            if (dx * tx + dy * ty) / L_SEG < .15:
                continue
            ex, ey = x + dx * run, y + dy * run
            score = abs(layout._town_d(ex, ey) - TARGET) * 60 - (dx * tx + dy * ty) / L_SEG
            if best is None or score < best[0]:
                best = (score, d, ex, ey)
        if best is None:
            break
        _, d, ex, ey = best
        # corta a corrida se atravessaria a parada (portão/rio) no meio
        k = 0
        for i in range(1, run + 1):
            px, py = x + DIRS[d][0] * i, y + DIRS[d][1] * i
            if stop(px, py) or stop(x + DIRS[d][0] * (i - .5), y + DIRS[d][1] * (i - .5)):
                break
            k = i
        if k == 0:
            break
        moves.append((d, k))
        x, y = x + DIRS[d][0] * k, y + DIRS[d][1] * k
        if k < run:
            break
    return moves, (x, y)


def teeth_arm(start, first, stop, max_runs=20, run=2):
    """Dentes em linha (lado a lado com a água ou em trecho reto): alterna `first` e sua volta até a parada."""
    back = {'sw': 'nw', 'nw': 'sw', 'se': 'ne', 'ne': 'se'}
    x, y = start
    moves = []
    d = first
    for _ in range(max_runs):
        k = 0
        for i in range(1, run + 1):
            px, py = x + DIRS[d][0] * i, y + DIRS[d][1] * i
            if stop(px, py) or stop(x + DIRS[d][0] * (i - .5), y + DIRS[d][1] * (i - .5)):
                break
            k = i
        if k == 0:
            break
        moves.append((d, k))
        x, y = x + DIRS[d][0] * k, y + DIRS[d][1] * k
        if k < run:
            break
        d = back[d]
    return moves, (x, y)


# ------------------------------------------------------------------ quarteirões
HOUSE_W, HOUSE_UP, HOUSE_DN = 88.0, 44.0, 8.0          # meia-largura, altura acima do pé e abaixo (planta 3/4 + folga)


def _rect_pts(x, y, pad=0.0):
    x0, x1, y0, y1 = x - HOUSE_W - pad, x + HOUSE_W + pad, y - HOUSE_UP - pad, y + HOUSE_DN + pad
    return [(x0 + (x1 - x0) * i / 4, y0 + (y1 - y0) * j / 2) for i in range(5) for j in range(3)]


def _collides(W, x, y, pad):
    x0, x1, y0, y1 = x - HOUSE_W - pad, x + HOUSE_W + pad, y - HOUSE_UP - pad, y + HOUSE_DN + pad
    for c in W.colliders:
        if c.get('zone', 'cidade') != 'cidade' or c.get('hide_when'):
            continue
        if c['kind'] == 'rect':
            a, b, w, h = c['rect']
            if a < x1 and a + w > x0 and b < y1 and b + h > y0:
                return True
        else:
            cx, cy = c['pos']
            r = c['r']
            if x0 - r < cx < x1 + r and y0 - r < cy < y1 + r:
                return True
    return False


def lot_ok(W, x, y, houses, walls, avoid_pts):
    if not all(layout.town_area(px, py) for px, py in _rect_pts(x, y, 8)):
        return False
    if any(layout.path_at(px, py) for px, py in _rect_pts(x, y, 14)):
        return False
    if any(_near_river(px, py, 52) for px, py in _rect_pts(x, y)):
        return False
    if _collides(W, x, y, 8):
        return False
    if any(abs(x - hx) < 2 * HOUSE_W + 20 and abs(y - hy) < HOUSE_UP + HOUSE_DN + 40 for hx, hy in houses):
        return False
    if any(math.hypot(x - wx, y - wy) < 100 for wx, wy in walls):
        return False
    if any(math.hypot(x - px, y - py) < pr for px, py, pr in avoid_pts):
        return False
    return True


def _road_dist(x, y, maxd=220.0):
    best = maxd
    for i in layout._SEG_GRID.get((int(x // layout._BUCKET), int(y // layout._BUCKET)), ()) :
        ax, ay, bx, by, h = layout.SEGS[i]
        best = min(best, layout._seg_d(x, y, ax, ay, bx, by) - h)
    for gx in (-1, 0, 1):
        for gy in (-1, 0, 1):
            for i in layout._SEG_GRID.get((int(x // layout._BUCKET) + gx, int(y // layout._BUCKET) + gy), ()):
                ax, ay, bx, by, h = layout.SEGS[i]
                best = min(best, layout._seg_d(x, y, ax, ay, bx, by) - h)
    return best


def _nearest_road_pt(x, y):
    best = (1e9, x, y)
    for gx in (-1, 0, 1):
        for gy in (-1, 0, 1):
            for i in layout._SEG_GRID.get((int(x // layout._BUCKET) + gx, int(y // layout._BUCKET) + gy), ()):
                ax, ay, bx, by, h = layout.SEGS[i]
                dx, dy = bx - ax, by - ay
                L2 = dx * dx + dy * dy or 1e-6
                t = max(0.0, min(1.0, ((x - ax) * dx + (y - ay) * dy) / L2))
                px, py = ax + dx * t, ay + dy * t
                d = math.hypot(x - px, y - py)
                if d < best[0]:
                    best = (d, px, py)
    return best[1], best[2]


def fill_districts(W, roads, walls, avoid_pts, seed=2702, max_houses=40):
    """Quarteirões: varre a cidade numa grade de 36 px e ocupa, gulosamente, os lotes livres mais próximos das ruas
    (fachada a 20–110 px da via). Casa inteira em 3/4 com a porta voltada para a rua + anexos. Devolve [(x, y, asset, flip)]."""
    rr = random.Random(seed)
    houses = [(o['pos'][0], o['pos'][1]) for o in W.objects if 'town_house' in o['asset'] or o['asset'] in ('val_guild_hall', 'val_archive_hall')]
    cands = []
    t = layout.L['town']
    cx, cy = t['center']
    for gy in range(int(cy - t['ry']), int(cy + t['ry']), 36):
        for gx in range(int(cx - t['rx']), int(cx + t['rx']), 36):
            if not layout.town_area(gx, gy):
                continue
            d = _road_dist(gx, gy - 18)
            if 10 < d < 230:
                cands.append((d + rr.uniform(0, 25), gx, gy))
    cands.sort()
    placed = []
    for _, hx, hy in cands:
        if len(placed) >= max_houses:
            break
        if not lot_ok(W, hx, hy, houses, walls, avoid_pts):
            continue
        roof = rr.choice(['red', 'blue', 'wood', 'red', 'wood'])
        asset = {'blue': 'val_town_house_blue', 'red': 'val_town_house_red', 'wood': 'val_town_house_wood'}[roof]
        rx, ry = _nearest_road_pt(hx, hy)
        flip = rx > hx                                   # porta (+x = baixo-esquerda) voltada para o lado da rua
        W.obj(asset, round(hx, 1), round(hy, 1), 'CIDADE_QUARTEIRAO', solid=False, check=False, flip=flip)
        W.collider('rect', round(hx - 80, 1), round(hy - 42, 1), 160, 48)
        houses.append((hx, hy))
        placed.append((hx, hy, asset, flip))
        _annex(W, hx, hy, flip, rr)
    return placed


ANNEX = ['city_barrels', 'city_crates', 'city_bench', 'city_planter', 'nat_hay_bale', 'city_lamp_post_a', 'nat_well_stone', 'city_sign_hanging']


def _annex(W, hx, hy, flip, rr):
    """Anexos que quebram a repetição: 1–2 props encostados na lateral oposta à porta + às vezes um quintal cercado atrás."""
    side = -1 if flip else 1
    for k in range(rr.choice((1, 1, 2))):
        a = rr.choice(ANNEX)
        px, py = hx + side * (104 + k * 30), hy - 18 + k * 22
        if layout.path_at(px, py) or _near_river(px, py, 40):
            continue
        W.obj(a, round(px, 1), round(py, 1), 'CIDADE_ANEXO', check=False, flip=rr.random() < .5)
    if rr.random() < .3:
        W.obj(rr.choice(['nat_bush_green', 'nat_flowers_meadow', 'nat_bush_flowering']), round(hx - side * 60, 1), round(hy - 70, 1), 'CIDADE_ANEXO', solid=False, check=False)


def fill_village(W, center, radius, n, way_dist, group, seed, poi=None):
    """Vila: casas inteiras em volta do centro, a 30–150 px de uma via (estrada ou trilha), porta voltada para ela, com anexos."""
    rr = random.Random(seed)
    houses = [(o['pos'][0], o['pos'][1]) for o in W.objects if 'town_house' in o['asset'] or 'str_barn' in o['asset']]
    cands = []
    for gy in range(int(center[1] - radius), int(center[1] + radius), 32):
        for gx in range(int(center[0] - radius), int(center[0] + radius), 32):
            if math.hypot(gx - center[0], gy - center[1]) > radius:
                continue
            d, wx, wy = way_dist(gx, gy - 18)
            if 30 < d < 150:
                cands.append((d + rr.uniform(0, 30), gx, gy, wx))
    cands.sort()
    placed = []
    for _, hx, hy, wx in cands:
        if len(placed) >= n:
            break
        if any(layout.path_at(px, py) or way_dist(px, py)[0] < 6 for px, py in _rect_pts(hx, hy, 10)):
            continue
        if any(_near_river(px, py, 50) for px, py in _rect_pts(hx, hy)) or _collides(W, hx, hy, 10):
            continue
        if any(abs(hx - a) < 2 * HOUSE_W + 30 and abs(hy - b) < HOUSE_UP + HOUSE_DN + 50 for a, b in houses):
            continue
        roof = rr.choice(['red', 'wood', 'wood', 'blue'])
        asset = {'blue': 'val_town_house_blue', 'red': 'val_town_house_red', 'wood': 'val_town_house_wood'}[roof]
        flip = wx > hx
        W.obj(asset, round(hx, 1), round(hy, 1), group, solid=False, check=False, flip=flip, poi=poi)
        W.collider('rect', round(hx - 80, 1), round(hy - 42, 1), 160, 48, poi=poi)
        houses.append((hx, hy))
        placed.append((hx, hy, asset, flip))
        _annex(W, hx, hy, flip, rr)
    return placed
