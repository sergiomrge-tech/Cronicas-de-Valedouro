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
    dict(name='ter_dec_cracks_dirt', on=['dirt'], cell=120, p=.1),                 # rachaduras RARAS (antes liam como lamaçal)
    dict(name='ter_dec_grass_dry', on=['dirt', 'road'], cell=46, p=.22),
    dict(name='ter_dec_pebbles', on=['dirt', 'road'], cell=40, p=.3),
    dict(name='ter_dec_grass', on=['dirt'], cell=38, p=.25),
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


# ------------------------------------------------------------------ famílias visuais, cor harmônica e grade de bioma
FAMILY = {'forest_floor': 1, 'grass_a': 2, 'grass_b': 2, 'meadow': 2, 'valley': 3, 'sand': 4, 'sand_dune': 4, 'snow': 5, 'ice': 5, 'stone': 5}
FAM_LETTER = {0: 'O', 1: 'F', 2: 'G', 3: 'V', 4: 'D', 5: 'S', 6: 'T'}


def family_map(ter, IDX):
    fam = np.zeros(ter.shape, dtype=np.int8)
    for name, k in FAMILY.items():
        fam[ter == IDX[name]] = k
    fam[ter == IDX['cobble']] = 6
    return fam


def harmonize(img, ter, IDX, sigma_fine=5, sigma_wide=60, prox_sigma=90):
    """Cor harmônica entre biomas: perto de uma fronteira, a componente de baixa frequência da cor é misturada entre os dois lados
    (gradiente largo), preservando o detalhe fino (grão/tufos) de cada terreno. Só em terrenos naturais (não estrada/água/pontes/cidade)."""
    from PIL import ImageFilter
    fam = family_map(ter, IDX)
    natural = (fam >= 1) & (fam <= 5)
    if not natural.any():
        return img
    # proximidade de fronteira: 1 - (maior pertencimento suavizado)
    pmax = np.zeros(ter.shape, dtype=np.float32)
    for k in range(1, 6):
        m = (fam == k)
        if not m.any():
            continue
        p = np.asarray(Image.fromarray((m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(prox_sigma)), dtype=np.float32) / 255.0
        pmax = np.maximum(pmax, p)
    s = np.clip((1.0 - pmax) * 2.2, 0, 1)
    s = s * s * (3 - 2 * s)                                   # smoothstep
    nat_f = natural.astype(np.float32)
    def masked_blur(sig):
        out = np.zeros(img.shape, dtype=np.float32)
        wm = np.asarray(Image.fromarray((nat_f * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(sig)), dtype=np.float32) / 255.0
        for c in range(3):
            ch = (img[..., c].astype(np.float32) * nat_f).clip(0, 255).astype(np.uint8)
            b = np.asarray(Image.fromarray(ch).filter(ImageFilter.GaussianBlur(sig)), dtype=np.float32) / 255.0
            out[..., c] = np.where(wm > 1e-3, b / np.maximum(wm, 1e-3), img[..., c] / 255.0) * 255.0
        return out
    Lf = masked_blur(sigma_fine)
    Lw = masked_blur(sigma_wide)
    detail = img.astype(np.float32) - Lf
    target = Lf + (Lw - Lf) * s[..., None]
    out = np.where(natural[..., None], np.clip(target + detail, 0, 255), img)
    return out.astype(np.uint8)


def biome_grid(ter, IDX, cell=32, max_d=6):
    """Grade visual por célula de 32 px: família dominante, família vizinha mais próxima e distância (0..max_d) até ela."""
    h, w = ter.shape
    fam = family_map(ter, IDX)
    gh, gw = (h + cell - 1) // cell, (w + cell - 1) // cell
    dom = np.zeros((gh, gw), dtype=np.int8)
    for gy in range(gh):
        for gx in range(gw):
            blk = fam[gy * cell:(gy + 1) * cell, gx * cell:(gx + 1) * cell]
            cnt = np.bincount(blk.ravel(), minlength=7)
            cnt[0] = 0 if cnt[1:].sum() else cnt[0]
            dom[gy, gx] = int(np.argmax(cnt))
    nb = np.zeros_like(dom)
    dist = np.full(dom.shape, max_d, dtype=np.int8)
    natural = (dom >= 1) & (dom <= 5)
    for d in range(1, max_d + 1):
        for dx, dy in ((d, 0), (-d, 0), (0, d), (0, -d), (d, d), (-d, d), (d, -d), (-d, -d)):
            o = shift(dom, dx, dy, fill=0)
            hit = natural & (o >= 1) & (o <= 5) & (o != dom) & (dist == max_d) & (nb == 0)
            nb = np.where(hit, o, nb)
            dist = np.where(hit, d - 1, dist)
    return dom, nb, dist


# ------------------------------------------------------------------ sombras projetadas do relevo (sol no alto à esquerda)
SHADOW_PX = 30.0                       # px de jogo por unidade de mundo (60 px/u renderizados × draw_scale .5)


def _proj(x, y):
    """Coordenadas locais do asset (unidades) -> deslocamento em tela (px), mesma projeção 2:1 do rig."""
    return (.7071 * (y - x) * SHADOW_PX, .5 * .7071 * (x + y) * SHADOW_PX)


def shadow_spec(asset):
    """(formas, altura em unidades). forma: ('rect', cx, cy, sx, sy) em unidades locais ou ('ell', cx, cy, rx, ry)."""
    a = asset
    if a.startswith('nat_plateau_') and a.endswith('_s'):
        return [('rect', 0, 0, 2.0, 2.0)], 1.6
    if a.startswith('nat_plateau_') and a.endswith('_m'):
        return [('rect', 0, 0, 3.2, 3.2)], 2.1
    if a.startswith('nat_ridge_'):
        return ([('rect', 0, 0, 4.6, 1.8)] if a.endswith('_a') else [('rect', 0, 0, 1.8, 4.6)]), 1.7
    if a.startswith('nat_wall_cliff_'):
        return ([('rect', 0, 0, 3.6, 1.15)] if a.endswith('_a') else [('rect', 0, 0, 1.15, 3.6)]), 2.7
    if a.startswith('nat_cliff_end_'):
        ax = '_a' in a
        return ([('rect', 0, 0, 2.6, 1.0)] if ax else [('rect', 0, 0, 1.0, 2.6)]), 1.7
    if a.startswith('nat_cliff_corner_'):
        return [('rect', -.7, 0, 2.6, 1.15), ('rect', .7, -.72, 1.15, 1.45)], 2.6
    if a.startswith('nat_hill_wide_'):
        return [('ell', 0, 0, 2.6, 2.3)], 1.1
    if a.startswith('nat_hill_low_'):
        return [('ell', 0, 0, 2.0, 1.8)], .4
    if a.startswith('nat_hill_'):
        return [('ell', 0, 0, 1.4, 1.3)], .8
    if a in ('nat_rock_pillars',):
        return [('ell', 0, 0, .9, .9)], 2.0
    return None


def relief_shadows(img, ter, IDX, objects, w, h, bay, strength=.5):
    """Sombra projetada do relevo no piso: varredura da base na direção da luz, mais escura junto ao pé e esmaecendo; penumbra pontilhada."""
    from PIL import ImageDraw, ImageFilter
    mask = Image.new('L', (w, h), 0)
    dr = ImageDraw.Draw(mask)
    casters = []
    for o in objects:
        if o.get('zone') != 'cidade':
            continue
        spec = shadow_spec(str(o['asset']))
        if spec is not None:
            casters.append((float(o['pos'][0]), float(o['pos'][1]), spec))
    for (t, val) in ((1.0, 100), (.66, 170), (.33, 240)):          # do fim da sombra até o pé: cada passada só escurece
        for px, py, (shapes, hu) in casters:
            hp = hu * SHADOW_PX
            vx, vy = hp * .55 * t, hp * .28 * t                     # luz de cima-esquerda: sombra cai para baixo-direita
            for shp in shapes:
                if shp[0] == 'rect':
                    _, cx, cy, sx, sy = shp
                    pts = [_proj(cx + dx * sx / 2, cy + dy * sy / 2) for dx, dy in ((-1, -1), (1, -1), (1, 1), (-1, 1))]
                else:
                    _, cx, cy, rx, ry = shp
                    pts = [_proj(cx + math.cos(k * .5236) * rx, cy + math.sin(k * .5236) * ry) for k in range(12)]
                allp = [(px + a, py + b) for a, b in pts] + [(px + a + vx, py + b + vy) for a, b in pts]
                dr.polygon(_hull(allp), fill=val)
    m = np.asarray(mask.filter(ImageFilter.GaussianBlur(2.2)), dtype=np.float32) / 255.0
    lvl = np.clip(m * 1.35, 0, 1)
    lvl = np.floor(lvl * 4 + (bay - .5) * .9 + .5) / 4.0              # 4 degraus com dither de Bayer (pixel art)
    skip = np.isin(ter, [IDX[k] for k in ('water_deep', 'water_shallow', 'cobble', 'deck_wood', 'deck_stone', 'deck_wood_v')])
    lvl = np.where(skip, 0.0, lvl)
    mul = np.stack([1 - strength * 1.05 * lvl, 1 - strength * lvl, 1 - strength * .72 * lvl], -1)
    return np.clip(img.astype(np.float32) * mul, 0, 255).astype(np.uint8), len(casters)


def _hull(points):
    pts = sorted(set((round(x, 2), round(y, 2)) for x, y in points))
    if len(pts) <= 2:
        return pts

    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
    lower, upper = [], []
    for p in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    for p in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    return lower[:-1] + upper[:-1]
