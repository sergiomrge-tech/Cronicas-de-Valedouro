"""Pós-processo do chão assado: sombreamento macro (colinas suaves com luz upper-left), lábios de estrada/água,
transição irregular cidade->campo e espalhamento de decalques modelados em Blender (tufos, flores, seixos, rachaduras…).

Tudo determinístico (seeds fixas). As funções recebem o mapa de ids `ter` (IDX) do bake para respeitar água, pontes e estradas.
"""
import json
import math
from pathlib import Path

import numpy as np
from PIL import Image

GAME = Path(__file__).resolve().parents[2]
DECALS = GAME / 'assets' / 'modeled' / 'terrain' / 'decals'


def shift(a, dx, dy, fill=0):
    """out[y,x] = a[y-dy, x-dx]"""
    h, w = a.shape[:2]
    out = np.full_like(a, fill)
    y0, y1 = max(0, dy), min(h, h + dy)
    x0, x1 = max(0, dx), min(w, w + dx)
    out[y0:y1, x0:x1] = a[y0 - dy:y1 - dy, x0 - dx:x1 - dx]
    return out


# ------------------------------------------------------------------ sombreamento macro
def macro_shade(img, ter, IDX, field, bay, strength=.24, levels=5):
    """Relevo suave: gradiente de um campo de altura -> claro nas faces voltadas ao alto-esquerdo, escuro no lado oposto.
    Quantizado em `levels` degraus com dither decorrelacionado (mantém a leitura de pixel art). Só em terrenos naturais."""
    k = 7
    gx = np.zeros_like(field)
    gy = np.zeros_like(field)
    gx[:, k:-k] = field[:, 2 * k:] - field[:, :-2 * k]
    gy[k:-k, :] = field[2 * k:, :] - field[:-2 * k, :]
    b = (gx + gy)
    b = b / (np.abs(b).std() + 1e-6)
    b = np.clip(b, -2.2, 2.2) / 2.2                      # -1..1
    q = np.floor((b * (levels / 2.0)) + bay) / (levels / 2.0)   # dither entre degraus
    factor = 1.0 + strength * np.clip(q, -1, 1)
    natural = np.isin(ter, [IDX[n] for n in ('grass_a', 'grass_b', 'meadow', 'valley', 'forest_floor', 'dirt', 'sand', 'sand_dune', 'snow', 'ice', 'mud')])
    f = np.where(natural, factor, 1.0)
    out = np.clip(img.astype(np.float32) * f[..., None], 0, 255)
    return out.astype(np.uint8)


# ------------------------------------------------------------------ lábios de estrada e sombra de margem
def rims(img, ter, IDX):
    road = np.isin(ter, [IDX[n] for n in ('road', 'road_sand', 'road_snow', 'dirt')])
    # estrada levemente rebaixada: sombra na borda alto-esquerda interna, luz na borda baixo-direita interna
    sh1 = road & ~shift(road, 2, 2)
    sh2 = road & ~shift(road, 4, 4) & ~sh1
    hi1 = road & ~shift(road, -2, -2)
    f = np.ones(ter.shape, dtype=np.float32)
    f = np.where(sh2, .86, f)
    f = np.where(sh1, .7, f)
    f = np.where(hi1, 1.16, f)
    # lábio de relva ao redor: fio de luz do lado alto-esquerdo externo
    lip = ~road & shift(road, -2, -2) & ~np.isin(ter, [IDX[n] for n in ('water_deep', 'water_shallow', 'deck_wood', 'deck_stone', 'deck_wood_v', 'cobble')])
    f = np.where(lip, 1.12, f)
    water = np.isin(ter, [IDX['water_deep'], IDX['water_shallow']])
    wsh = water & ~shift(water, 3, 3)
    wsh2 = water & ~shift(water, 6, 6) & ~wsh
    f = np.where(wsh2, np.minimum(f, .88), f)
    f = np.where(wsh, np.minimum(f, .74), f)
    return np.clip(img.astype(np.float32) * f[..., None], 0, 255).astype(np.uint8)


# ------------------------------------------------------------------ transição cidade -> campo
def ragged_town_edge(ter, IDX, fine, bay, blur_px=16):
    from PIL import ImageFilter
    town = ter == IDX['cobble']
    p = np.asarray(Image.fromarray((town * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(blur_px)), dtype=np.float32) / 255.0
    band = (p > .12) & (p < .88)
    if not band.any():
        return ter
    noise = (fine - .5) * .9 + (bay - .5) * .5
    keep = p > (.5 + noise)
    # terreno externo mais próximo (procura em 8 direções, 14 px)
    alt = np.full(ter.shape, IDX['grass_a'], dtype=ter.dtype)
    found = np.zeros(ter.shape, dtype=bool)
    for dx, dy in ((14, 0), (-14, 0), (0, 14), (0, -14), (10, 10), (-10, 10), (10, -10), (-10, -10), (26, 0), (-26, 0), (0, 26), (0, -26)):
        cand = shift(ter, dx, dy, fill=-1)
        ok = (cand != IDX['cobble']) & (cand >= 0) & ~found
        alt = np.where(ok, cand, alt)
        found |= ok
    out = ter.copy()
    out = np.where(band & town & ~keep, alt, out)
    out = np.where(band & ~town & keep, IDX['cobble'], out)
    return out.astype(ter.dtype)


# ------------------------------------------------------------------ decalques
_cache = {}


def load_decals():
    if _cache:
        return _cache
    meta = {e['id']: e for e in json.loads((GAME / 'data' / 'modeled_parts' / 'pro.json').read_text(encoding='utf-8')) if e['id'].startswith('ter_dec_')}
    for i, e in meta.items():
        im = Image.open(GAME / e['path'][6:]).convert('RGBA')
        fw, fh = e['frame_size']
        frames = [im.crop((k * fw, 0, k * fw + fw, fh)) for k in range(e['frames'])]
        _cache[i] = (frames, tuple(int(v) for v in e['foot']))
    return _cache


def hash2(ix, iy, salt):
    n = (ix * 73856093) ^ (iy * 19349663) ^ (salt * 83492791)
    n = (n ^ (n >> 13)) * 1274126177
    return ((n ^ (n >> 16)) & 0xFFFFFF) / float(0xFFFFFF)


def scatter(img, ter, IDX, rules, fields, w, h, x0=0, y0=0, avoid=None):
    """rules: lista de dict(name, on=[terrain names], cell, p, field=None|key, lo, hi, jitter=.9).
    Um ponto por célula (jitter); probabilidade p modulada por um campo de agrupamento (lo..hi -> 0..1)."""
    decals = load_decals()
    canvas = Image.fromarray(img, 'RGB').convert('RGBA')
    placed = []
    for si, rule in enumerate(rules):
        if rule['name'] not in decals:
            continue
        ids = np.array([IDX[n] for n in rule['on']], dtype=ter.dtype)
        cell = rule['cell']
        for cy in range(0, h, cell):
            for cx in range(0, w, cell):
                r0 = hash2(cx, cy, si * 3 + 1)
                px = int(cx + (.5 + (hash2(cx, cy, si * 3 + 2) - .5) * rule.get('jitter', .9)) * cell)
                py = int(cy + (.5 + (hash2(cx, cy, si * 3 + 3) - .5) * rule.get('jitter', .9)) * cell)
                if not (0 <= px < w and 0 <= py < h):
                    continue
                if ter[py, px] not in ids:
                    continue
                p = rule['p']
                fk = rule.get('field')
                if fk:
                    v = fields[fk][py, px]
                    p *= float(np.clip((v - rule.get('lo', .4)) / max(1e-6, rule.get('hi', .7) - rule.get('lo', .4)), 0, 1))
                if r0 > p:
                    continue
                if avoid is not None and avoid[py, px]:
                    continue
                placed.append((py, px, rule['name'], int(hash2(px, py, 77) * 997)))
    placed.sort()
    for py, px, name, v in placed:
        frames, foot = decals[name]
        fr = frames[v % len(frames)]
        _paste(canvas, fr, px - foot[0], py - foot[1])
    return np.asarray(canvas.convert('RGB')).copy(), len(placed)


def _paste(canvas, fr, x, y):
    W, H = canvas.size
    fw, fh = fr.size
    sx, sy = max(0, -x), max(0, -y)
    ex, ey = min(fw, W - x), min(fh, H - y)
    if ex <= sx or ey <= sy:
        return
    canvas.alpha_composite(fr.crop((sx, sy, ex, ey)), (x + sx, y + sy))


WORLD_RULES = [
    # relva: tufos em manchas (agrupamentos) + tufos altos raros + flores em canteiros + seixos esparsos
    dict(name='ter_dec_grass', on=['grass_a', 'grass_b', 'meadow', 'valley'], cell=26, p=.5, field='clump_a', lo=.42, hi=.66),
    dict(name='ter_dec_grass_tall', on=['grass_a', 'grass_b', 'meadow', 'valley'], cell=60, p=.4, field='clump_b', lo=.55, hi=.75),
    dict(name='ter_dec_flowers', on=['meadow', 'valley', 'grass_a'], cell=34, p=.55, field='flower', lo=.62, hi=.8),
    dict(name='ter_dec_pebbles', on=['grass_a', 'grass_b', 'meadow', 'valley', 'dirt', 'road'], cell=80, p=.2),
    dict(name='ter_dec_cracks_dirt', on=['dirt'], cell=30, p=.5),
    dict(name='ter_dec_grass_dry', on=['dirt', 'road'], cell=70, p=.12),
    # floresta
    dict(name='ter_dec_leaves', on=['forest_floor', 'grass_b'], cell=34, p=.4, field='clump_a', lo=.45, hi=.7),
    dict(name='ter_dec_grass', on=['forest_floor'], cell=44, p=.3, field='clump_b', lo=.5, hi=.72),
    dict(name='ter_dec_mushrooms', on=['forest_floor'], cell=90, p=.28),
    # deserto
    dict(name='ter_dec_sand_ripple', on=['sand', 'sand_dune'], cell=52, p=.28, field='clump_a', lo=.35, hi=.62),
    dict(name='ter_dec_stones_sand', on=['sand', 'sand_dune', 'road_sand'], cell=72, p=.26),
    dict(name='ter_dec_grass_dry', on=['sand', 'sand_dune'], cell=80, p=.22, field='clump_b', lo=.5, hi=.72),
    dict(name='ter_dec_cracks_sand', on=['sand', 'stone'], cell=70, p=.22),
    dict(name='ter_dec_bones', on=['sand'], cell=300, p=.35),
    # gelo
    dict(name='ter_dec_snow_drift', on=['snow', 'ice'], cell=64, p=.26, field='clump_a', lo=.35, hi=.62),
    dict(name='ter_dec_grass_frost', on=['snow'], cell=90, p=.22, field='clump_b', lo=.5, hi=.72),
    dict(name='ter_dec_stones_ice', on=['snow', 'ice', 'stone', 'road_snow'], cell=90, p=.22),
    dict(name='ter_dec_cracks_ice', on=['ice'], cell=42, p=.5),
    # margens do rio e cidade
    dict(name='ter_dec_pebbles', on=['riverbed', 'mud'], cell=34, p=.4),
    dict(name='ter_dec_cobble_weeds', on=['cobble'], cell=52, p=.22, field='clump_a', lo=.45, hi=.7),
    dict(name='ter_dec_moss_stone', on=['cobble'], cell=90, p=.14),
]


# ------------------------------------------------------------------ transição orgânica entre biomas
def blend_regions(ter, IDX, names, blob, blur_px=20, wobble=.55, salt=0):
    """Embaralha as fronteiras entre regiões naturais: por região, campo de pertencimento suavizado + ruído de blobs;
    vence a região de maior escore. Resultado: faixas largas de transição irregulares (sem linha reta nem tapete de dither)."""
    from PIL import ImageFilter
    ids = [IDX[n] for n in names]
    region = np.isin(ter, ids)
    scores = []
    for k, i in enumerate(ids):
        m = (ter == i)
        if not m.any():
            scores.append(np.full(ter.shape, -9.0, dtype=np.float32))
            continue
        p = np.asarray(Image.fromarray((m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(blur_px)), dtype=np.float32) / 255.0
        nz = np.roll(blob, (k * 173 + salt) % blob.shape[1], axis=1)
        nz = np.roll(nz, (k * 97 + salt) % blob.shape[0], axis=0)
        scores.append(p + (nz - .5) * wobble)
    best = np.argmax(np.stack(scores, 0), axis=0)
    out = np.array(ids, dtype=ter.dtype)[best]
    return np.where(region, out, ter).astype(ter.dtype)
