#!/usr/bin/env python3
"""Chão assado das cenas do Ato II (Parte B do passe visual final mobile).

Para cada composição de data/act02_compositions.json com `terrain` (padrão 'forest'), gera UMA textura 960x540 em
assets/modeled/terrain/act02/<slug>.png — custo em tempo de execução = um draw_texture por cena (mobile, 60 FPS).
Conteúdo:
  * chão próprio da Floresta Ancestral: serapilheira escura, relva, musgo, manchas de raiz — misturados por ruído, com dither
    (transições de pixel art, sem grade) e relevo macro sombreado com luz do alto-esquerdo;
  * TRILHAS por spline (Catmull-Rom), largura variável, borda erodida, relva invadindo, rebaixo sombreado (lábio claro/escuro);
  * RIOS sinuosos de largura variável: fundo, lâmina rasa, margem de lama/leito, pedras submersas e espuma estática;
  * SOMBRA DE CONTATO assada sob todo objeto de base (regra do Diretor: tudo tem sombreamento);
  * decalques de folhas/tufos/cogumelos/seixos modelados em Blender.
Trilhas com estado (show_when/hide_when) viram overlays RGBA separados (`<slug>__trail<i>.png`), ligados/desligados pelo palco.
Também grava pontos de brilho da água (`water_glints`) na composição para o palco animar."""
import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools' / 'terrain'))
import ground_detail as GD  # noqa: E402

COMPS = ROOT / 'data' / 'act02_compositions.json'
OUTDIR = ROOT / 'assets' / 'modeled' / 'terrain' / 'act02'
TILES = ROOT / 'assets' / 'modeled' / 'terrain' / 'tiles'
MAN = {a['id']: a for a in json.load(open(ROOT / 'data' / 'modeled_assets_manifest.json'))['assets']}
W, H = 960, 540
IDX = {'forest_floor': 0, 'grass_b': 1, 'moss': 2, 'dirt': 3, 'road': 4, 'mud': 5, 'riverbed': 6, 'water_shallow': 7, 'water_deep': 8, 'stone': 9,
       'grass_a': 10, 'meadow': 11, 'valley': 12, 'sand': 13, 'sand_dune': 14, 'snow': 15, 'ice': 16, 'road_sand': 17, 'road_snow': 18, 'grass_dry': 19}


def tex(name, tint=None):
    a = np.asarray(Image.open(TILES / f'ter_tex_{name}.png').convert('RGB'), dtype=np.float32)
    if tint is not None:
        a = a * np.array(tint, dtype=np.float32)
    return a


def field(seed, cells, octaves=2):
    rng = np.random.default_rng(seed)
    total = np.zeros((H, W), np.float32)
    amp = norm = 0.0
    amp = 1.0
    for o in range(octaves):
        cx, cy = cells * 2 ** o, max(2, int(cells * 2 ** o * H / W))
        small = rng.random((cy + 3, cx + 3)).astype(np.float32)
        im = Image.fromarray((small * 255).astype(np.uint8)).resize((W + 3 * W // cx, H + 3 * H // cy), Image.BICUBIC)
        total += amp * np.asarray(im, np.float32)[:H, :W] / 255.0
        norm += amp
        amp *= .5
    total /= norm
    return (total - total.min()) / (total.max() - total.min() + 1e-9)


BAY = GD.bayer if hasattr(GD, 'bayer') else None
_DITH = np.random.default_rng(91027).random((64, 64)).astype(np.float32)


def dither():
    return np.tile(_DITH, (H // 64 + 2, W // 64 + 2))[:H, :W]


def sample(t, xx, yy, sx=0, sy=0):
    n = t.shape[0]
    return t[(yy + sy) % n, (xx + sx) % n]


def catmull(pts, step=3.0):
    """Spline Catmull-Rom densa passando pelos pontos (curvas suaves, sem quinas de 90°)."""
    P = [pts[0]] + list(pts) + [pts[-1]]
    out = []
    for i in range(1, len(P) - 2):
        p0, p1, p2, p3 = (np.array(P[j], np.float32) for j in (i - 1, i, i + 1, i + 2))
        seg = max(2, int(np.linalg.norm(p2 - p1) / step))
        for k in range(seg):
            t = k / seg
            t2, t3 = t * t, t * t * t
            out.append(.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3 * p1 - 3 * p2 + p3) * t3))
    out.append(np.array(P[-2], np.float32))
    return out


def stroke(samples, half, seed, wobble=.35):
    """Campo t∈[0,1] (1 = eixo) de uma faixa de largura variável ao longo das amostras."""
    rng = np.random.default_rng(seed)
    t = np.zeros((H, W), np.float32)
    n = len(samples)
    freq = rng.uniform(.012, .02)
    ph = rng.uniform(0, 6.28)
    for i, p in enumerate(samples):
        w = half * (1.0 + wobble * math.sin(i * freq * 1.3 + ph) + wobble * .35 * math.sin(i * freq * 4.1 + ph * 2))
        w = max(4.0, w)
        x0, x1 = int(max(0, p[0] - w - 2)), int(min(W, p[0] + w + 3))
        y0, y1 = int(max(0, p[1] - w - 2)), int(min(H, p[1] + w + 3))
        if x0 >= x1 or y0 >= y1:
            continue
        yy, xx = np.mgrid[y0:y1, x0:x1]
        d = np.sqrt((xx - p[0]) ** 2 + (yy - p[1]) ** 2) / w
        t[y0:y1, x0:x1] = np.maximum(t[y0:y1, x0:x1], np.clip(1 - d, 0, 1))
    return t


def shift(a, dx, dy):
    return GD.shift(a, dx, dy)


def base_forest(xx, yy, dth, seed, pal='forest', eco=None):
    f1, f2, f3 = field(seed, 5), field(seed + 1, 9), field(seed + 2, 16, 1)
    ter = np.full((H, W), IDX['forest_floor'], np.int8)
    if pal == 'forest':
        ter = np.where(f1 + (dth - .5) * .14 > .6, IDX['grass_b'], ter)
        ter = np.where((f2 + (dth - .5) * .14 > .62) & (ter == IDX['forest_floor']), IDX['moss'], ter)
        ter = np.where((f3 + (dth - .5) * .18 > .9) & (f2 < .55), IDX['mud'], ter)          # serapilheira úmida, rara e de borda pontilhada
    elif pal == 'hollow':
        ter = np.where(f1 + (dth - .5) * .12 > .6, IDX['mud'], ter)
        ter = np.where(f2 + (dth - .5) * .1 > .72, IDX['stone'], ter)
    if eco is not None:                                # ecótono: o solo seca em direção à saída (grama seca/terra)
        lx = xx - xx.min()
        dry = lx + (f3 - .5) * 160 + (dth - .5) * 50 > eco
        ter = np.where(dry & (ter != IDX['mud']), np.where(f1 + (dth - .5) * .2 > .62, IDX['dirt'], IDX['grass_dry']), ter)
    elif pal == 'dry':
        ter = np.where(f1 + (dth - .5) * .12 > .5, IDX['grass_b'], ter)
        ter = np.where(f2 + (dth - .5) * .1 > .7, IDX['dirt'], ter)
    return ter


def colorize(ter, xx, yy, pal):
    T = {
        'forest_floor': tex('forest_floor', (.86, .82, .74)),
        'grass_b': tex('grass_b', (.5, .6, .48)),
        'moss': tex('grass_a', (.42, .62, .46)),
        'dirt': tex('dirt', (.66, .6, .52)),
        'road': tex('road', (.7, .64, .54)),
        'mud': tex('mud', (.82, .84, .74)),
        'riverbed': tex('riverbed', (.85, .88, .84)),
        'water_shallow': tex('water_shallow', (.5, .8, .68)),
        'water_deep': tex('water_deep', (.32, .6, .54)),
        'stone': tex('stone', (.8, .86, .82)),
        'grass_dry': tex('grass_b', (.78, .7, .42)),
    }
    if pal == 'hollow':
        T['forest_floor'] = tex('forest_floor', (.55, .5, .62))
        T['mud'] = tex('mud', (.62, .55, .7))
        T['stone'] = tex('stone', (.55, .5, .66))
    img = np.zeros((H, W, 3), np.float32)
    for name, t in T.items():
        m = ter == IDX[name]
        if m.any():
            hs = sum(map(ord, name))
            s = sample(t, xx, yy, hs % 97, hs % 53)
            img[m] = s[m]
    return img


def shade(img, seed, strength=.2):
    """Relevo macro: gradiente de um campo de altura, luz do alto-esquerdo, quantizado em degraus com dither."""
    h = field(seed + 50, 4, 3)
    k = 6
    g = np.zeros_like(h)
    g[k:-k, k:-k] = (h[k:-k, 2 * k:] - h[k:-k, :-2 * k]) + (h[2 * k:, k:-k] - h[:-2 * k, k:-k])
    g = g / (np.abs(g).std() + 1e-6)
    q = np.floor(np.clip(g / 2.2, -1, 1) * 2.5 + dither()) / 2.5
    return img * (1 + strength * np.clip(q, -1, 1))[..., None]


def trail_paint(img, ter, t, dth, seed):
    """Trilha: miolo de chão batido, borda de terra erodida com relva invadindo, rebaixo (sombra alto-esquerda, luz baixo-direita)."""
    edge_noise = (field(seed + 7, 30, 1) - .5) * .5
    core = t > (.55 + edge_noise * .6)
    ring = (t > (.28 + edge_noise)) & ~core
    ring &= dth > .25 + (.55 - t) * 1.6       # relva invadindo a borda em dither
    road = core | ring
    ter = np.where(core, IDX['road'], np.where(ring, IDX['dirt'], ter))
    return ter, road


def rims(img, road):
    f = np.ones(road.shape, np.float32)
    sh1 = road & ~shift(road, 2, 2)
    hi1 = road & ~shift(road, -2, -2)
    lip = ~road & shift(road, -2, -2)
    f = np.where(sh1, .72, f)
    f = np.where(hi1, 1.12, f)
    f = np.where(lip, 1.1, f)
    return img * f[..., None]


def river_paint(ter, t, dth, seed):
    n = (field(seed + 3, 24, 1) - .5) * .3
    slow = (field(seed + 4, 5, 1) - .5) * .5              # bancos rasos assimétricos (curva interna rasa, externa funda)
    deep = t > .5 + n + slow
    shal = (t > .26 + n * .7) & ~deep
    bank = (t > .14 + n * .6) & ~deep & ~shal
    ter = np.where(deep, IDX['water_deep'], ter)
    ter = np.where(shal, IDX['water_shallow'], ter)
    ter = np.where(bank, np.where(dth > .5, IDX['mud'], IDX['riverbed']), ter)
    return ter, deep | shal


def river_details(img, t, water, seed):
    """Pedras parcialmente submersas + espuma a jusante + reflexo escuro nas margens."""
    rng = np.random.default_rng(seed)
    dth_g = dither()
    ys, xs = np.nonzero(water & (t < .75))
    stones = []
    for _ in range(min(10, len(xs) // 1500 + 3)):
        if len(xs) == 0:
            break
        i = rng.integers(len(xs))
        stones.append((xs[i], ys[i], rng.uniform(4, 9)))
    yy, xx = np.mgrid[0:H, 0:W]
    for x, y, r in stones:
        r *= .7
        wob = 1 + .25 * np.sin(np.arctan2(yy - y, xx - x) * 3 + x)
        d = np.sqrt((xx - x) ** 2 + ((yy - y) * 1.7) ** 2) / wob
        body = d < r
        img[body] = img[body] * .3 + np.array([86, 92, 84]) * .7
        top = (d < r * .7) & (yy < y - r * .15)
        img[top] = img[top] * .4 + np.array([128, 136, 118]) * .6
        foam = (d > r) & (d < r + 2.2) & (yy > y) & (dth_g > .45)
        img[foam] = img[foam] * .5 + np.array([200, 222, 214]) * .5
    edge = water & ~shift(water, 4, 4)                     # margem superior-esquerda: sombra do barranco sobre a água
    img[edge] *= .62
    lip = water & ~shift(water, -2, -2)                     # reflexo claro na margem oposta
    img[lip] = img[lip] * .7 + np.array([150, 190, 180]) * .3
    return img, stones


def contact_shadows(img, comp):
    """Sombra de contato assada (oclusão ambiente) sob todo objeto com base, projetada levemente para baixo-direita."""
    ox, oy = comp['origin']
    sh = np.ones((H, W), np.float32)
    yy, xx = np.mgrid[0:H, 0:W]
    for o in comp['objects']:
        if o.get('layer') == 'ground' or o.get('show_when') or o.get('hide_when'):
            continue
        m = MAN.get(o['asset'])
        if not m:
            continue
        s = float(o.get('scale', 1.0)) * float(m.get('draw_scale', .5))
        fp = float(m.get('footprint') or 0) or m['frame_size'][0] * .12
        r = max(8.0, min(90.0, fp * s * 1.25))
        cx, cy = o['x'] - ox + r * .18, o['y'] - oy + r * .08
        x0, x1, y0, y1 = int(max(0, cx - r * 1.6)), int(min(W, cx + r * 1.6)), int(max(0, cy - r)), int(min(H, cy + r))
        if x0 >= x1 or y0 >= y1:
            continue
        d = np.sqrt(((xx[y0:y1, x0:x1] - cx) / (r * 1.5)) ** 2 + ((yy[y0:y1, x0:x1] - cy) / (r * .62)) ** 2)
        sh[y0:y1, x0:x1] = np.minimum(sh[y0:y1, x0:x1], np.clip(.62 + .38 * d, .62, 1.0))
    q = np.round(sh * 8) / 8           # degraus de pixel art
    return img * q[..., None]


def canopy_shade(img, comp, seed):
    """Sombra salpicada das copas: sob árvores grandes o chão escurece em manchas (luz filtrada), deslocada para baixo-direita
    (sol alto-esquerdo). Assada — custo zero em tempo de execução."""
    ox, oy = comp['origin']
    dap = field(seed + 77, 40, 2)
    yy, xx = np.mgrid[0:H, 0:W]
    sh = np.zeros((H, W), np.float32)
    for o in comp['objects']:
        a = o['asset']
        if 'tree' not in a or 'dead' in a or 'memory_tree' in a:
            continue
        s = float(o.get('scale', 1.0))
        r = (150 if 'ancient' in a or 'claw' in a else 80) * s
        cx, cy = o['x'] - ox + r * .35, o['y'] - oy - r * .05
        d = np.sqrt(((xx - cx) / (r * 1.25)) ** 2 + ((yy - cy) / (r * .62)) ** 2)
        sh = np.maximum(sh, np.clip(1.15 - d, 0, 1))
    m = np.clip(sh * 1.4, 0, 1) * (dap > .42 + (dither() - .5) * .12)          # buracos de luz na copa
    q = 1 - .3 * np.round(m * 3) / 3
    return img * q[..., None]


def bake(comp, idx):
    OUTDIR.mkdir(parents=True, exist_ok=True)
    pal = comp.get('terrain', 'forest')
    slug = comp.get('slug') or ('c%02d' % idx)
    ox, oy = comp['origin']
    yy, xx = np.mgrid[0:H, 0:W]
    xx = (xx + ox).astype(np.int64)
    yy = (yy + oy).astype(np.int64)
    dth = dither()
    seed = 700 + idx * 31
    ter = base_forest(xx, yy, dth, seed, pal, comp.get('ecotone_x'))
    water = np.zeros((H, W), bool)
    rivers_t = []
    for i, r in enumerate(comp.get('rivers', [])):
        t = stroke(catmull([(x - ox, y - oy) for x, y in r['pts']]), r['half'], seed + 40 + i, wobble=r.get('wobble', .38))
        ter, w_ = river_paint(ter, t, dth, seed + i)
        water |= w_
        rivers_t.append(t)
    base_trails, state_trails = [], []
    for i, tr in enumerate(comp.get('trails', [])):
        (state_trails if (tr.get('show_when') or tr.get('hide_when')) else base_trails).append((i, tr))
    road_all = np.zeros((H, W), bool)
    for i, tr in base_trails:
        if tr.get('yard'):                              # chão batido de ocupação: terra com relva rala em dither, sem rebaixo
            t = stroke(catmull([(x - ox, y - oy) for x, y in tr['pts']]), tr['half'], seed + 80 + i, wobble=.45)
            t = np.where(water, 0, t)
            nz = (field(seed + 90 + i, 26, 1) - .5) * .4
            ter = np.where(t > .5 + nz, IDX['dirt'], np.where((t > .2 + nz) & (dth > .45 + (.5 - t)), IDX['dirt'], ter))
            continue
        t = stroke(catmull([(x - ox, y - oy) for x, y in tr['pts']]), tr['half'] * 1.3, seed + 60 + i)
        t = np.where(water, 0, t)
        ter, road = trail_paint(None, ter, t, dth, seed + i)
        road_all |= road
    img = colorize(ter, xx, yy, pal)
    img = shade(img, seed)
    img = rims(img, road_all)
    stones = []
    for t in rivers_t:
        img, st = river_details(img, t, water, seed)
        stones += st
    img = np.clip(img, 0, 255).astype(np.uint8)
    # decalques modelados (folhas, tufos, cogumelos, seixos)
    rules = [
        dict(name='ter_dec_leaves', on=['forest_floor', 'grass_b', 'moss'], cell=30, p=.45),
        dict(name='ter_dec_grass', on=['grass_b', 'moss', 'forest_floor'], cell=26, p=.4),
        dict(name='ter_dec_grass_tall', on=['grass_b', 'moss'], cell=58, p=.35),
        dict(name='ter_dec_mushrooms', on=['forest_floor', 'moss'], cell=90, p=.3),
        dict(name='ter_dec_moss_stone', on=['forest_floor', 'mud'], cell=110, p=.35),
        dict(name='ter_dec_pebbles', on=['road', 'dirt', 'riverbed', 'mud'], cell=34, p=.4),
        dict(name='ter_dec_grass_dry', on=['dirt', 'grass_dry'], cell=34, p=.45),
    ]
    fields = {'clump_a': field(seed + 9, 12, 1), 'clump_b': field(seed + 10, 8, 1), 'flower': field(seed + 11, 10, 1)}
    avoid = water | (road_all & (np.asarray(Image.fromarray(road_all.astype(np.uint8) * 255).filter(ImageFilter.MinFilter(9))) > 0))
    img, n_dec = GD.scatter(img, ter, IDX, rules, fields, W, H, avoid=avoid)
    img = canopy_shade(img.astype(np.float32), comp, seed)
    img = contact_shadows(img, comp)
    img = np.clip(img, 0, 255).astype(np.uint8)
    Image.fromarray(img, 'RGB').quantize(160, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).save(OUTDIR / f'{slug}.png', optimize=True)   # paleta fechada: pixel art coesa e arquivo leve
    comp['ground_png'] = f'res://assets/modeled/terrain/act02/{slug}.png'
    # overlays de trilhas com estado
    overlays = []
    for i, tr in state_trails:
        t = stroke(catmull([(x - ox, y - oy) for x, y in tr['pts']]), tr['half'] * 1.3, seed + 60 + i)
        t = np.where(water, 0, t)
        ter2, road = trail_paint(None, ter.copy(), t, dth, seed + i)
        col = colorize(ter2, xx, yy, pal)
        col = shade(col, seed)
        col = rims(col, road)
        rgba = np.zeros((H, W, 4), np.uint8)
        rgba[..., :3] = np.clip(col, 0, 255).astype(np.uint8)
        rgba[..., 3] = np.where(road, 255, 0)
        name = f'{slug}__trail{i}.png'
        Image.fromarray(rgba, 'RGBA').save(OUTDIR / name)
        ov = {'png': f'res://assets/modeled/terrain/act02/{name}'}
        for k in ('show_when', 'hide_when'):
            if tr.get(k):
                ov[k] = tr[k]
        overlays.append(ov)
    comp['ground_overlays'] = overlays
    ys, xs = np.nonzero(water)
    rng = np.random.default_rng(seed)
    pick = rng.choice(len(xs), size=min(40, len(xs)), replace=False) if len(xs) else []
    comp['water_glints'] = [[int(xs[i] + ox), int(ys[i] + oy)] for i in pick]
    return slug, n_dec


def main():
    comps = json.load(open(COMPS))
    for i, c in enumerate(comps):
        if c.get('terrain', 'forest') == 'none':
            continue
        if c['terrain'] in ('heart', 'hollow_arena'):
            print('interior', bake_interior(c, i))
            continue
        slug, n = bake(c, i)
        print('ground', slug, 'decalques', n, 'overlays', len(c['ground_overlays']))
    COMPS.write_text(json.dumps(comps, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')



# ============================================================== PARTE E: pisos de interiores orgânicos (Coração da Árvore-Memória, arena da Raiz Oca)
INTERIOR_PAL = {
    # (fibra escura, fibra média, fibra clara, crista de raiz, massa externa, musgo/luz, seiva)
    'heart': ((34, 22, 14), (62, 40, 22), (94, 64, 34), (120, 84, 46), (16, 11, 8), (120, 210, 120), (214, 150, 52)),
    'hollow': ((30, 22, 30), (52, 40, 44), (76, 60, 58), (98, 80, 70), (12, 9, 14), (120, 110, 90), (40, 30, 38)),
}


def _chamber_mask(cx, cy, rx, ry, seed):
    """Contorno da câmara: elipse 2:1 (círculo em perspectiva) deformada por ruído de baixa frequência — assimétrica, nunca perfeita."""
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    ang = np.arctan2((yy - cy) * 2, xx - cx)
    rng = np.random.default_rng(seed)
    wob = np.zeros_like(ang)
    for k, amp in ((2, .08), (3, .07), (5, .05), (7, .03)):
        wob += amp * np.sin(k * ang + rng.uniform(0, 6.28))
    d = np.sqrt(((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2) / (1 + wob)
    return d, ang


def bake_interior(comp, idx):
    kind = comp['terrain']
    P = INTERIOR_PAL['heart' if kind == 'heart' else 'hollow']
    ox, oy = comp['origin']
    slug = comp['slug']
    seed = 900 + idx * 17
    ch = comp.get('chamber', {'cx': 480, 'cy': 350, 'rx': 420, 'ry': 190})
    cx, cy = ch['cx'], ch['cy']
    d, ang = _chamber_mask(cx, cy, ch['rx'], ch['ry'], seed)
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    dth = dither()
    n1, n2 = field(seed + 1, 14, 2), field(seed + 2, 40, 1)
    # piso: textura real (serapilheira de raiz / terra) recolorida para a paleta da câmara, com variação em manchas (sem padrão geométrico)
    base_t = tex('forest_floor' if kind == 'heart' else 'mud')
    b = sample(base_t, xx.astype(np.int64) + ox, yy.astype(np.int64) + oy)
    lum = b.mean(axis=2, keepdims=True) / (b.mean() + 1e-6)
    tone = np.clip(n1 * .6 + n2 * .4 + (dth - .5) * .2, 0, 1)
    lvl = np.floor(tone * 3).clip(0, 2).astype(int)
    pal = np.array([P[0], P[1], P[2]], np.float32)
    img = pal[lvl] * np.clip(lum, .6, 1.5)
    if kind != 'heart':                                   # arena: chão de terra batida/raiz com rachaduras e centro mais uniforme (telegráficos legíveis)
        calm = np.clip(1.2 - d * 1.4, 0, 1)[..., None]
        img = img * (1 - calm * .35) + np.array(P[1], np.float32) * calm * .35
    # cristas de raiz: poucas, assimétricas, curvas, param em raios diferentes
    rng = np.random.default_rng(seed + 5)
    ridge = np.zeros((H, W), np.float32)
    for k in range(comp.get('ridges', 8)):
        a0 = rng.uniform(0, 2 * math.pi)
        stop = rng.uniform(.18, .55)
        pts = []
        for t in np.linspace(1.15, stop, 6):
            a = a0 + (1.15 - t) * rng.uniform(-.6, .6)
            pts.append((cx + math.cos(a) * ch['rx'] * t, cy + math.sin(a) * ch['ry'] * t))
        ridge = np.maximum(ridge, stroke(catmull(pts), rng.uniform(4, 9), seed + 20 + k, wobble=.5))
    rmask = ridge > .35
    img[rmask] = (np.array(P[3], np.float32) * (0.75 + .35 * ridge[..., None]) * np.clip(lum, .5, 1.6))[rmask]
    sh = rmask & ~shift(rmask, 0, -3)                      # face sul da crista em sombra (altura)
    img[shift(rmask, 0, 3) & ~rmask] *= .55
    img[sh] *= .8
    # patamares (múltiplas alturas): topo mais claro + faixa de face lateral escura ao sul
    for k, (px, py, prx, pry) in enumerate(comp.get('platforms', [])):
        pd, _ = _chamber_mask(px, py, prx, pry, seed + 40 + k)
        top = pd < 1
        img[top] = img[top] * 1.18
        face = shift(top, 0, -9) & ~top
        img[face] = np.array(P[0], np.float32) * .8
        img[shift(top, 0, -10) & ~shift(top, 0, -9)] *= .5
    # musgo/bioluminescência e seiva em pequenos agrupamentos
    spots = field(seed + 7, 90, 1) * .6 + field(seed + 17, 12, 1) * .4
    moss = (spots > .74) & (d < 1.0) & (dth > .5)
    img[moss] = img[moss] * .4 + np.array(P[5], np.float32) * .6
    sap = (field(seed + 8, 70, 1) > .94) & (d < .85) & ~rmask
    img[sap] = img[sap] * .3 + np.array(P[6], np.float32) * .7
    # borda física: além do contorno, massa de raízes escura com fibras (nunca vazio chapado); degrau de sombra na junção
    outer = d >= 1.0
    mass = np.array(P[4], np.float32) * (1 + .6 * (np.sin(ang * 40 + n1 * 12) * .5 + .5)[..., None]) * (1 + .5 * n2[..., None])
    fade = np.clip((d - 1.0) * 2.2, 0, 1)[..., None]
    img = np.where(outer[..., None], mass * (1 - fade * .5), img)
    lip = (d < 1.0) & (d > .9)
    img[lip] *= (.55 + (d[lip, None] - .9) * 0)            # sombra da parede sobre o piso
    img = img * (1.08 - .35 * np.clip(d - .3, 0, 1))[..., None]      # luz concentrada no centro
    img = contact_shadows(img, comp)
    img = np.clip(img, 0, 255).astype(np.uint8)
    Image.fromarray(img, 'RGB').quantize(128, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).save(OUTDIR / f'{slug}.png', optimize=True)
    comp['ground_png'] = f'res://assets/modeled/terrain/act02/{slug}.png'
    # overlays de estado: veios (corrupção ativa) e cicatriz/musgo (purificado)
    overlays = []
    for i, v in enumerate(comp.get('vein_overlays', [])):
        rgba = np.zeros((H, W, 4), np.uint8)
        vm = np.zeros((H, W), np.float32)
        r2 = np.random.default_rng(seed + 60 + i)
        for k in range(v.get('n', 12)):
            a0 = r2.uniform(0, 2 * math.pi)
            pts, a = [], a0
            for t in np.linspace(v.get('r0', .08), v.get('r1', .9), 7):
                a += r2.uniform(-.35, .35)
                pts.append((cx + math.cos(a) * ch['rx'] * t, cy + math.sin(a) * ch['ry'] * t))
            vm = np.maximum(vm, stroke(catmull(pts), v.get('half', 5), seed + 70 + k, wobble=.5))
        core = vm > .5
        glow = (vm > .15) & ~core
        col = np.array(v['color'], np.uint8)
        rgba[core, :3] = col
        rgba[core, 3] = 235
        rgba[glow, :3] = col
        rgba[glow, 3] = np.where(dth[glow] > .5, 110, 60)
        if v.get('stain'):                                 # mancha escura irregular sob o núcleo (centro fundido ao solo)
            sd, _ = _chamber_mask(cx, cy, ch['rx'] * v['stain'], ch['ry'] * v['stain'], seed + 90 + i)
            st = (sd < 1) & ~core & (dth < .5 + (1 - sd) * .8)
            rgba[st, :3] = np.array(v.get('stain_color', (20, 10, 26)), np.uint8)
            rgba[st, 3] = 200
        name = f'{slug}__state{i}.png'
        Image.fromarray(rgba, 'RGBA').save(OUTDIR / name)
        ov = {'png': f'res://assets/modeled/terrain/act02/{name}'}
        for k in ('show_when', 'hide_when'):
            if v.get(k):
                ov[k] = v[k]
        overlays.append(ov)
    comp['ground_overlays'] = overlays
    comp['water_glints'] = []
    return slug


if __name__ == '__main__':
    main()
