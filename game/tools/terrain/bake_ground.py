#!/usr/bin/env python3
"""Assa o chão do mundo (REG_001) em chunks PNG e a biblioteca de texturas de terreno.

Saídas (status MODELED_PENDING_GATE):
  assets/modeled/terrain/tiles/ter_tex_*.png      biblioteca contínua 256x256
  assets/modeled/terrain/ground/ter_ground_CX_CY.png   mundo aberto, chunks de 512 px (3072x2304)
  assets/modeled/terrain/ground/ter_bosque_CX_CY.png   instância do Bosque (1825x862)
  assets/modeled/terrain/fx/ter_water_*.png       glints/ondulações/espuma animados (sprites)
Determinístico (seed fixa). Usa a mesma geografia de scripts/world_map.gd (porta em tools/reg001/geo.py) e os dados de
trilhas/vaus de data/reg001_world.json, logo chão, água, estrada e colisão continuam coerentes.
"""
import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = Path(__file__).resolve().parent
GAME = HERE.parents[1]
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(GAME / 'tools' / 'reg001'))
sys.path.insert(0, str(GAME / 'tools' / 'modeling'))
import geo  # noqa: E402
import texlib as T  # noqa: E402
import manifest_lib  # noqa: E402
import ground_detail as GD  # noqa: E402

OUT = GAME / 'assets' / 'modeled' / 'terrain'
W, H = 3072, 2304
CH = 512
IDS = ['grass_a', 'grass_b', 'meadow', 'valley', 'forest_floor', 'dirt', 'road', 'mud', 'sand', 'sand_dune', 'snow', 'ice',
       'stone', 'cobble', 'water_deep', 'water_shallow', 'riverbed', 'deck_wood', 'deck_stone', 'deck_wood_v', 'road_sand', 'road_snow']
IDX = {k: i for i, k in enumerate(IDS)}


def smooth_field(w, h, cells_x, cells_y, seed, octaves=1):
    """Campo suave em [0,1] de tamanho (h,w) por interpolação bicúbica de ruído grosseiro."""
    rng = np.random.default_rng(seed)
    total = np.zeros((h, w), dtype=np.float32)
    amp, norm = 1.0, 0.0
    for o in range(octaves):
        small = rng.random((cells_y * 2 ** o + 3, cells_x * 2 ** o + 3)).astype(np.float32)
        im = Image.fromarray((small * 255).astype(np.uint8)).resize((w + (w // cells_x) * 3 * 2 ** o // (2 ** o), h + (h // cells_y) * 3 * 2 ** o // (2 ** o)), Image.BICUBIC)
        arr = np.asarray(im, dtype=np.float32) / 255.0
        total += amp * arr[:h, :w]
        norm += amp
        amp *= .5
    total /= norm
    return np.clip((total - total.min()) / (total.max() - total.min() + 1e-9), 0, 1)


_DITHER_RNG = np.random.default_rng(91027)
_DITHER64 = _DITHER_RNG.random((64, 64), dtype=np.float32)

def bayer(h, w, ox=0, oy=0):
    """Large deterministic decorrelated threshold field.

    Keeps hard pixel-art transitions but avoids the obvious 8x8 ordered-dither
    carpet visible in large REG_001 biome boundaries.
    """
    tile = np.tile(_DITHER64, (h // 64 + 3, w // 64 + 3))
    return tile[oy % 64:oy % 64 + h, ox % 64:ox % 64 + w]


def region_arrays(x0, y0, w, h):
    yy, xx = np.mgrid[y0:y0 + h, x0:x0 + w]
    return xx.astype(np.float32), yy.astype(np.float32)


def sample_tex(tex, xx, yy, shift):
    t = tex.shape[0]
    return tex[((yy.astype(np.int32) + shift[1]) % t), ((xx.astype(np.int32) + shift[0]) % t)]


def river_hw_v(y):
    return 48.0 + np.sin(y * 0.0041 + .6) * 8.0 + np.sin(y * 0.013) * 5.0


def river_x_v(y):
    return 2220.0 + np.sin(y * 0.006) * 78.0 + np.sin(y * 0.017) * 23.0 + np.sin(y * 0.0024 + 1.3) * 34.0


def biome_ids(xx, yy):
    """0 cidade, 1 gelo, 2 deserto, 3 campos, 4 vale, 5 floresta, 6 pradaria (vetorizado; igual a world_map.biome)."""
    town = (xx >= 650) & (xx < 650 + 1774) & (yy >= 680) & (yy < 680 + 887)
    ice = (xx > 2010) & (yy < 860)
    des = (xx > 1980) & (yy > 1370)
    low = yy > 1570
    out = np.full(xx.shape, 6, dtype=np.int8)
    out = np.where((xx < 1040) | (yy < 680), 5, out)
    out = np.where(low & (xx < 760), 3, np.where(low, 4, out))
    out = np.where(des, 2, out)
    out = np.where(ice, 1, out)
    out = np.where(town, 0, out)
    return out


def path_mask_geo(xx, yy):
    """Estradas principais (world_map.path_at, sem trilhas) vetorizado."""
    tx, ty = 650, 680
    town = (xx >= tx) & (xx < tx + 1774) & (yy >= ty) & (yy < ty + 887)
    qx, qy = xx - tx, yy - ty
    t = town & ((np.abs(qx - 890) < 80) | (np.abs(qy - 478) < 65) | ((qy < 478) & (np.abs(qx - 448) < 47)) | ((qy > 478) & (np.abs(qx - 1300) < 46)))
    m = t
    m |= (~town) & (xx < 650) & (np.abs(yy - 1160) < 49)
    m |= (~town) & (yy < 680) & (np.abs(xx - 1536) < 46)
    m |= (~town) & (yy > 1567) & (np.abs(xx - 1536) < 48)
    m |= (~town) & (xx > 2320) & (np.abs(yy - 1250) < 49)
    m |= (~town) & (xx > 2280) & (np.abs(xx - 2560) < 43) & (yy < 1280)
    m |= (~town) & (yy > 700) & (yy < 820) & (xx > 1700)
    m |= (~town) & (xx > 2470) & (xx < 2550) & (yy < 820)
    m |= (~town) & (yy > 1790) & (yy < 1890) & (xx > 1450)
    return m


def bridge_masks(xx, yy):
    masks = []
    for by in geo.BRIDGE_YS:
        rx, hw = geo.river_x(by), geo.river_hw(by)
        masks.append((np.abs(yy - by) < 50) & (np.abs(xx - rx) < hw + 68))
    return masks


def gt(p, thr, bay, w=.07):
    """p > thr com borda pontilhada (dither ordenado) — transições de pixel-art em vez de recorte duro."""
    return (p - thr) > ((bay - .5) * w * 2)


def build_terrain_ids(x0, y0, w, h, trails_mask, ford_mask, seeds):
    """Mapa de ids de terreno por pixel (com bordas dithered/ragged)."""
    xx, yy = region_arrays(x0, y0, w, h)
    A = seeds['warpA']; B = seeds['warpB']
    # Broad continuous coordinate warp: breaks rectangular biome borders into
    # large natural masses instead of swapping between two warped samples.
    dxa = (A[0][y0:y0 + h, x0:x0 + w] - .5) * 190
    dya = (A[1][y0:y0 + h, x0:x0 + w] - .5) * 190
    dxb = (B[0][y0:y0 + h, x0:x0 + w] - .5) * 145
    dyb = (B[1][y0:y0 + h, x0:x0 + w] - .5) * 145
    bay = bayer(h, w, x0, y0)
    fine = seeds['fine'][y0:y0 + h, x0:x0 + w]
    macro_mix = seeds['macro'][y0:y0 + h, x0:x0 + w]
    LA, LB = seeds['warpL']
    dxl = (LA[y0:y0 + h, x0:x0 + w] - .5) * 230
    dyl = (LB[y0:y0 + h, x0:x0 + w] - .5) * 230
    bx = xx + dxa * (1.0 - macro_mix) + dxb * macro_mix + dxl
    by_ = yy + dya * (1.0 - macro_mix) + dyb * macro_mix + dyl
    bio = biome_ids(bx, by_)
    patch1 = seeds['p1'][y0:y0 + h, x0:x0 + w]
    patch2 = seeds['p2'][y0:y0 + h, x0:x0 + w]
    patch3 = seeds['p3'][y0:y0 + h, x0:x0 + w]
    ter = np.full((h, w), IDX['grass_a'], dtype=np.int8)
    # cidade
    ter = np.where(bio == 0, IDX['cobble'], ter)
    # pradaria (colinas): relva com trechos de prado
    ter = np.where(bio == 6, np.where(gt(patch1, .6, bay), IDX['meadow'], np.where(gt(patch2, .9, bay, .04), IDX['dirt'], IDX['grass_a'])), ter)
    # campos
    ter = np.where(bio == 3, np.where(gt(patch1, .72, bay), IDX['grass_a'], np.where(gt(patch3, .91, bay, .04), IDX['dirt'], IDX['meadow'])), ter)
    # vale
    ter = np.where(bio == 4, np.where(gt(patch1, .66, bay), IDX['grass_a'], np.where(gt(patch3, .92, bay, .04), IDX['dirt'], IDX['valley'])), ter)
    # floresta
    ter = np.where(bio == 5, np.where(gt(patch1, .68, bay), IDX['grass_b'], np.where(gt(patch2, .91, bay, .04), IDX['dirt'], IDX['forest_floor'])), ter)
    # gelo
    ter = np.where(bio == 1, np.where(gt(patch1, .74, bay), IDX['ice'], np.where(gt(patch3, .93, bay, .04), IDX['stone'], IDX['snow'])), ter)
    # deserto
    ter = np.where(bio == 2, np.where(gt(patch3, .94, bay, .04), IDX['stone'], np.where(gt(patch2, .92, bay, .04), IDX['dirt'], IDX['sand'])), ter)
    # margem/água (geometria exata do rio, sem warp): água profunda, rasa, margem
    rx = river_x_v(yy)
    hw = river_hw_v(yy)
    d = np.abs(xx - rx)
    in_range = yy > 242
    bridge_any = np.zeros((h, w), dtype=bool)
    for m in bridge_masks(xx, yy):
        bridge_any |= m
    wob = (fine - .5) * 6
    deep_raw = in_range & (d < hw + wob)
    shal_raw = in_range & (d >= hw + wob) & (d < hw + 12 + wob * .5)
    deep = deep_raw & ~ford_mask
    shal = shal_raw & ~ford_mask
    bank = in_range & (d >= hw + 12 + wob * .5) & (d < hw + 39 + wob)
    # margem: lama/pedras, com dispersão para a relva
    bank_t = np.where(patch2 > .55, IDX['riverbed'], IDX['mud'])
    bank_t = np.where(bio == 1, np.where(patch2 > .45, IDX['stone'], IDX['ice']), np.where(bio == 2, np.where(patch2 > .5, IDX['riverbed'], IDX['sand']), bank_t))
    bank_fade = (d - (hw + 12)) / 27.0
    bank_fade = np.clip(bank_fade + (fine - .5) * .7, 0, 1)
    bank_choose = np.where(bay < (1 - bank_fade), bank_t, ter)
    ter = np.where(bank, bank_choose, ter)
    shallow_or_deep = np.where(deep, np.where((hw - d) < 8 + (fine - .5) * 10, IDX['water_shallow'], IDX['water_deep']), IDX['water_shallow'])
    ter = np.where(deep | shal, shallow_or_deep, ter)
    # vaus: leito visível
    ford_vis = ford_mask & in_range & (deep_raw | shal_raw)
    ter = np.where(ford_vis, np.where(gt(patch2, .5, bay, .12), IDX['riverbed'], IDX['water_shallow']), ter)
    # estradas e trilhas com bordas irregulares
    road = path_mask_geo(xx, yy) | trails_mask
    road_img = Image.fromarray((road * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(10))
    road_prob = np.asarray(road_img, dtype=np.float32) / 255.0
    edge_noise = (seeds['road_soft'][y0:y0 + h, x0:x0 + w] - .5) * .72 + (bay - .5) * .08
    road_final = (road_prob > (.5 + edge_noise)) & ~(deep | shal) & ~bridge_any
    road_ter = np.where(gt(patch1, .6, bay), IDX['dirt'], IDX['road'])
    road_ter = np.where(bio == 2, IDX['road_sand'], np.where(bio == 1, IDX['road_snow'], road_ter))
    ter = np.where(road_final, road_ter, ter)
    # pontes
    for i, m in enumerate(bridge_masks(xx, yy)):
        ter = np.where(m, IDX['deck_stone'] if i == 0 else IDX['deck_wood_v'], ter)
    return ter.astype(np.int8), bridge_any


def colorize(ter, textures, x0, y0, seeds):
    h, w = ter.shape
    xx, yy = region_arrays(x0, y0, w, h)
    out = np.zeros((h, w, 3), dtype=np.uint8)
    macro = seeds['macro'][y0:y0 + h, x0:x0 + w]
    bay = bayer(h, w, x0, y0)
    shifts = [(0, 0), (97, 61), (171, 199)]
    sel = np.where(macro + (bay - .5) * .12 < .33, 0, np.where(macro + (bay - .5) * .12 < .66, 1, 2))
    NO_SHIFT = {'sand', 'sand_dune', 'road_sand', 'road_snow', 'snow', 'ice', 'water_deep', 'water_shallow', 'deck_wood_v', 'deck_stone', 'deck_wood', 'road'}
    for tid, name in enumerate(IDS):
        m = ter == tid
        if not m.any():
            continue
        tex = textures[name if name != 'deck_wood_v' else 'deck_wood']
        for k, sh in enumerate(shifts):
            mk = m & (sel == k) if name not in NO_SHIFT else (m if k == 0 else np.zeros_like(m))
            if not mk.any():
                continue
            if name == 'deck_wood_v':
                # tábuas perpendiculares ao sentido da travessia (eixo x): trocar eixos
                col = tex[((xx.astype(np.int32) + sh[0]) % tex.shape[0]), ((yy.astype(np.int32) + sh[1]) % tex.shape[0])]
            else:
                col = sample_tex(tex, xx, yy, sh)
            out[mk] = col[mk]
    out = shade_dunes(out, ter, seeds, x0, y0, w, h, bay)
    return out


def shade_dunes(out, ter, seeds, x0, y0, w, h, bay):
    """Dunas (deserto) e derivas de neve (gelo) com direção do vento: barlavento suave e claro, sotavento íngreme e escuro,
    crista com filete de luz; amplitude macro varia o porte e deixa áreas planas. Luz principal: alto-esquerda."""
    for names, fld, amp_key, period, lee_dark, tint in ((('sand',), 'dune', 'dune_amp', 3.4, .8, (1.0, .92, .86)), (('snow', 'ice'), 'drift', 'drift_amp', 2.0, .92, (.95, .97, 1.03))):
        m = np.isin(ter, [IDX[n] for n in names])
        if not m.any() or fld not in seeds:
            continue
        D = seeds[fld][y0:y0 + h, x0:x0 + w]
        A = seeds[amp_key][y0:y0 + h, x0:x0 + w]
        ph = (D * period) % 1.0
        strength = np.clip((A - .28) * 3.2, 0, 1)
        on = strength > (bay * .8 + .1)                      # dither de entrada/saída das dunas
        lee = ph >= .72
        crest = (ph >= .68) & (ph < .74)
        f = np.where(lee, lee_dark + (1 - lee_dark) * (1 - (ph - .72) / .28) * .35, 1.03 + .12 * ph / .72)
        f = np.where(crest, 1.22, f)
        f = 1 + (f - 1) * np.where(on, 1.0, 0.0)
        tint_a = np.array(tint, dtype=np.float32)
        col = out.astype(np.float32) * f[..., None]
        col = np.where(lee[..., None] & on[..., None], col * tint_a, col)
        res = np.clip(col, 0, 255).astype(np.uint8)
        out = np.where(m[..., None], res, out)
    return out


def draw_bridge_rails(img_arr, x0, y0):
    """Trilhos, postes e sombra das pontes pintados no chão (vista de cima obliqua, coerente com o terreno)."""
    im = Image.fromarray(img_arr)
    d = ImageDraw.Draw(im)
    for i, by in enumerate(geo.BRIDGE_YS):
        rx, hw = geo.river_x(by), geo.river_hw(by)
        xa, xb = rx - hw - 68 - x0, rx + hw + 68 - x0
        stone = i == 0
        beam = [T.hexc('#3a2014'), T.hexc('#5e3820'), T.hexc('#84542c'), T.hexc('#a87438'), T.hexc('#e6b466')] if not stone else \
               [T.hexc('#3a3448'), T.hexc('#54506a'), T.hexc('#726c86'), T.hexc('#928ca2'), T.hexc('#cec8d8')]
        for side, ytop in ((-1, by - 50 - y0), (1, by + 50 - y0)):
            # sombra na água/tabuado
            sh_y = ytop + (3 if side < 0 else 5)
            d.rectangle((xa + 2, sh_y, xb - 2, sh_y + 5), fill=(22, 12, 40))
            # viga superior + inferior
            y_beam = ytop - 12 if side < 0 else ytop - 5
            d.rectangle((xa, y_beam, xb, y_beam + 4), fill=tuple(int(c) for c in beam[2]))
            d.rectangle((xa, y_beam, xb, y_beam), fill=tuple(int(c) for c in beam[4]))
            d.rectangle((xa, y_beam + 4, xb, y_beam + 4), fill=tuple(int(c) for c in beam[0]))
            # travessa intermediária
            d.rectangle((xa, y_beam + 8, xb, y_beam + 9), fill=tuple(int(c) for c in beam[1]))
            # postes
            px = xa
            while px <= xb:
                d.rectangle((px - 2, y_beam - 3, px + 2, y_beam + 13), fill=tuple(int(c) for c in beam[1]))
                d.rectangle((px - 2, y_beam - 3, px - 2, y_beam + 13), fill=tuple(int(c) for c in beam[3]))
                d.rectangle((px + 2, y_beam - 3, px + 2, y_beam + 13), fill=tuple(int(c) for c in beam[0]))
                d.rectangle((px - 2, y_beam - 4, px + 2, y_beam - 3), fill=tuple(int(c) for c in beam[4]))
                px += 24
    return np.asarray(im)


def rasterize_trails(x0, y0, w, h, world):
    """Máscara de trilhas (polilinhas com meia-largura) na janela."""
    im = Image.new('L', (w, h), 0)
    d = ImageDraw.Draw(im)
    for t in world['trails']:
        pts = [(p[0] - x0, p[1] - y0) for p in t['pts']]
        d.line(pts, fill=255, width=int(t['half'] * 2 * .9), joint='curve')
        for p in pts:
            r = t['half'] * .9
            d.ellipse((p[0] - r, p[1] - r, p[0] + r, p[1] + r), fill=255)
    return np.asarray(im) > 128


def ford_mask_for(x0, y0, w, h, world):
    m = np.zeros((h, w), dtype=bool)
    for p in world['passages']:
        if p['kind'] != 'ford':
            continue
        rx0, ry0, rw, rh = p['rect']
        xa, ya = int(rx0 - x0), int(ry0 - y0)
        m[max(0, ya):max(0, ya + int(rh)), max(0, xa):max(0, xa + int(rw))] = True
    return m


def make_seeds(w, h):
    s = {}
    s['warpA'] = (smooth_field(w, h, 40, 30, 101, 2), smooth_field(w, h, 40, 30, 102, 2))
    s['warpB'] = (smooth_field(w, h, 44, 33, 103, 2), smooth_field(w, h, 44, 33, 104, 2))
    s['fine'] = smooth_field(w, h, 300, 225, 105)
    s['p1'] = smooth_field(w, h, 14, 11, 106, 2)
    s['p2'] = smooth_field(w, h, 24, 18, 107, 2)
    s['p3'] = smooth_field(w, h, 34, 26, 108, 2)
    s['macro'] = smooth_field(w, h, 6, 5, 109)
    s['road_soft'] = smooth_field(w, h, 160, 120, 110)
    # dunas: cristas alongadas cisalhadas pelo vento (fase), amplitude macro que varia o tamanho/some em manchas planas
    base = smooth_field(w, h, 22, 9, 111, 2)
    yy_i = np.arange(h)[:, None]
    xx_i = np.arange(w)[None, :]
    s['dune'] = base[yy_i, (xx_i + (yy_i * .55).astype(np.int32)) % w]
    s['dune_amp'] = smooth_field(w, h, 7, 6, 112, 2)
    drift = smooth_field(w, h, 30, 8, 113, 2)
    s['drift'] = drift[yy_i, (xx_i + (yy_i * .35).astype(np.int32)) % w]
    s['drift_amp'] = smooth_field(w, h, 8, 6, 114, 2)
    s['warpL'] = (smooth_field(w, h, 6, 5, 115, 2), smooth_field(w, h, 6, 5, 116, 2))
    s['blob'] = smooth_field(w, h, w // 26, h // 26, 117, 2)
    s.update(detail_fields(w, h, 300))
    return s


def detail_fields(w, h, seed):
    """Campos para decalques (agrupamentos e áreas livres) e relevo macro."""
    return {'clump_a': smooth_field(w, h, max(4, w // 90), max(3, h // 90), seed + 1, 3), 'clump_b': smooth_field(w, h, max(3, w // 150), max(3, h // 150), seed + 2, 2),
            'flower': smooth_field(w, h, max(3, w // 200), max(3, h // 200), seed + 3, 2), 'height': smooth_field(w, h, max(3, w // 260), max(3, h // 260), seed + 4, 3)}


def finish_ground(img, ter, seeds, w, h, world_seed=0):
    bay = bayer(h, w)
    img = GD.harmonize(img, ter, IDX)
    img = GD.macro_shade(img, ter, IDX, seeds['height'], bay)
    img = GD.rims(img, ter, IDX)
    img, n = GD.scatter(img, ter, IDX, GD.WORLD_RULES, seeds, w, h)
    print('  decalques:', n)
    return img


def bake_world(textures, world):
    seeds = make_seeds(W, H)
    trails = rasterize_trails(0, 0, W, H, world)
    # suaviza a máscara de trilhas com blur curto para bordas orgânicas
    tr_img = Image.fromarray((trails * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(8))
    trails_soft = np.asarray(tr_img) > 60
    # a máscara de estradas principais também recebe um ruído de borda em build_terrain_ids; aqui só trilhas
    fords = ford_mask_for(0, 0, W, H, world)
    ter, bridge_any = build_terrain_ids(0, 0, W, H, trails_soft, fords, {**seeds, 'road_soft': seeds['road_soft']})
    ter = GD.ragged_town_edge(ter, IDX, seeds['fine'], bayer(H, W))
    ter = GD.blend_regions(ter, IDX, ['grass_a', 'grass_b', 'meadow', 'valley', 'forest_floor', 'sand', 'snow', 'ice'], seeds['blob'], blur_px=22, wobble=.6)
    img = colorize(ter, textures, 0, 0, seeds)
    img = draw_bridge_rails(img, 0, 0)
    img = finish_ground(img, ter, seeds, W, H)
    dom, nb, dist = GD.biome_grid(ter, IDX)
    rows = [''.join(GD.FAM_LETTER[int(v)] for v in r) for r in dom]
    nbs = [''.join(GD.FAM_LETTER[int(v)] for v in r) for r in nb]
    dts = [''.join(str(int(v)) for v in r) for r in dist]
    (GAME / 'data' / 'reg001_biome_grid.json').write_text(json.dumps({'cell': 32, 'w': len(rows[0]), 'h': len(rows), 'dom': rows, 'nb': nbs, 'dist': dts, 'note': 'gerado por tools/terrain/bake_ground.py; F floresta G grama V vale D deserto S neve T cidade O outro'}, separators=(',', ':')) + '\n', encoding='utf-8')
    return img, ter


def bake_bosque(textures):
    """Instância do Bosque (1825x862): sub-bosque, clareiras, trilha central e riacho (x ~ 1515)."""
    w, h = 1825, 862
    seeds = {}
    seeds['fine'] = smooth_field(w, h, 200, 90, 201)
    seeds['p1'] = smooth_field(w, h, 10, 5, 202, 2)
    seeds['p2'] = smooth_field(w, h, 18, 8, 203, 2)
    seeds['p3'] = smooth_field(w, h, 26, 12, 204, 2)
    seeds['macro'] = smooth_field(w, h, 5, 3, 205)
    seeds.update(detail_fields(w, h, 400))
    xx, yy = region_arrays(0, 0, w, h)
    bay = bayer(h, w)
    fine = seeds['fine']
    ter = np.full((h, w), IDX['forest_floor'], dtype=np.int8)
    ter = np.where(gt(seeds['p1'], .66, bay), IDX['grass_b'], ter)
    ter = np.where(gt(seeds['p2'], .92, bay, .04), IDX['dirt'], ter)
    ter = np.where(gt(seeds['p3'], .8, bay) & (seeds['p1'] < .5), IDX['grass_a'], ter)
    # riacho
    bx = 1515 + np.sin(yy * .012) * 38
    d = np.abs(xx - bx)
    water = (yy > 40) & (yy < 690) & (d < 34 + (fine - .5) * 6)
    shallow = (yy > 40) & (yy < 690) & (d >= 34) & (d < 46)
    bank = (yy > 40) & (yy < 690) & (d >= 46) & (d < 74)
    fade = np.clip((d - 46) / 28 + (fine - .5) * .7, 0, 1)
    ter = np.where(bank, np.where(bay < 1 - fade, IDX['mud'], ter), ter)
    ter = np.where(shallow, IDX['water_shallow'], ter)
    ter = np.where(water, np.where(d < 22, IDX['water_deep'], IDX['water_shallow']), ter)
    # trilhas
    im = Image.new('L', (w, h), 0)
    dr = ImageDraw.Draw(im)
    for pts, wd in [([(1000, 862), (1000, 760), (985, 620), (930, 470), (900, 330), (880, 120)], 60),
                    ([(930, 470), (760, 500), (560, 470), (400, 480)], 46),
                    ([(900, 330), (1080, 300), (1250, 300)], 46),
                    ([(985, 620), (1150, 640), (1330, 700)], 40)]:
        dr.line(pts, fill=255, width=wd, joint='curve')
        for p in pts:
            dr.ellipse((p[0] - wd / 2, p[1] - wd / 2, p[0] + wd / 2, p[1] + wd / 2), fill=255)
    rp = np.asarray(im.filter(ImageFilter.GaussianBlur(5)), dtype=np.float32) / 255.0
    rs = smooth_field(w, h, 160, 70, 206)
    road = (rp > (.5 + (rs - .5) * .55 + (bay - .5) * .12)) & ~water & ~shallow
    ter = np.where(road, np.where(gt(seeds['p1'], .6, bay), IDX['dirt'], IDX['road']), ter)
    img = colorize(ter, textures, 0, 0, seeds)
    img = finish_ground(img, ter, seeds, w, h)
    return img, ter


def save_chunks(img, prefix, group_folder, world_w, world_h, source):
    entries = []
    folder = OUT / 'ground'
    folder.mkdir(parents=True, exist_ok=True)
    for cy in range(math.ceil(world_h / CH)):
        for cx in range(math.ceil(world_w / CH)):
            x0, y0 = cx * CH, cy * CH
            crop = img[y0:y0 + CH, x0:x0 + CH]
            im = Image.fromarray(crop, 'RGB').convert('RGBA')
            png = folder / f'{prefix}_{cx}_{cy}.png'
            im.save(png, optimize=True)
            entries.append(manifest_lib.make_entry(f'{prefix}_{cx}_{cy}', png, 'terrain', 'ground', (crop.shape[1], crop.shape[0]), foot=(0, 0),
                                                   draw_scale=1.0, tags=('chao', 'baked', group_folder), source=source))
    return entries


def save_tiles(textures):
    folder = OUT / 'tiles'
    folder.mkdir(parents=True, exist_ok=True)
    entries = []
    for name, arr in textures.items():
        png = folder / f'ter_tex_{name}.png'
        Image.fromarray(arr, 'RGB').convert('RGBA').save(png, optimize=True)
        entries.append(manifest_lib.make_entry(f'ter_tex_{name}', png, 'terrain', 'tiles', (256, 256), foot=(0, 0), draw_scale=1.0,
                                               tags=('tile', 'contínuo', name), source='game/tools/terrain/texlib.py'))
    return entries


def sprite_sheet(png, frames, size, painter, seed):
    fw, fh = size
    rng = np.random.default_rng(seed)
    im = Image.new('RGBA', (fw * frames, fh), (0, 0, 0, 0))
    for f in range(frames):
        fr = Image.new('RGBA', (fw, fh), (0, 0, 0, 0))
        painter(ImageDraw.Draw(fr), f, frames, fw, fh, rng)
        im.paste(fr, (f * fw, 0))
    im.save(png, optimize=True)


def paint_glint(d, f, n, w, h, rng):
    t = f / (n - 1)
    a = math.sin(t * math.pi)
    cx, cy = w // 2, h // 2
    ln = int(2 + a * 5)
    hi = (232, 250, 255, int(255 * min(1, a * 1.5)))
    mid = (140, 210, 246, int(220 * a))
    d.line((cx - ln, cy, cx + ln, cy), fill=mid)
    d.line((cx - ln // 2, cy, cx + ln // 2, cy), fill=hi)
    if a > .6:
        d.point((cx, cy - 1), fill=hi)
        d.point((cx, cy + 1), fill=mid)


def paint_ripple(d, f, n, w, h, rng):
    t = f / (n - 1)
    rx, ry = int(3 + t * (w // 2 - 4)), int(1 + t * (h // 2 - 2))
    a = int(255 * (1 - t) ** 1.2)
    col = (220, 244, 252, a)
    col2 = (96, 170, 224, int(a * .7))
    d.ellipse((w // 2 - rx, h // 2 - ry, w // 2 + rx, h // 2 + ry), outline=col)
    if rx > 6:
        d.ellipse((w // 2 - rx + 2, h // 2 - ry + 1, w // 2 + rx - 2, h // 2 + ry - 1), outline=col2)


def paint_foam(d, f, n, w, h, rng):
    t = f / n
    for i in range(6):
        x = 2 + i * 4
        y = h // 2 + int(math.sin(t * 6.283 + i * 1.3) * 2)
        d.rectangle((x, y, x + 2, y), fill=(238, 250, 255, 230))
        d.point((x + 1, y + 1), fill=(150, 210, 240, 200))


def save_water_fx():
    folder = OUT / 'fx'
    folder.mkdir(parents=True, exist_ok=True)
    entries = []
    for name, frames, size, painter, seed in [('ter_water_glint', 8, (16, 8), paint_glint, 1), ('ter_water_ripple', 8, (28, 14), paint_ripple, 2), ('ter_water_foam', 4, (28, 6), paint_foam, 3)]:
        png = folder / f'{name}.png'
        sprite_sheet(png, frames, size, painter, seed)
        entries.append(manifest_lib.make_entry(name, png, 'terrain', 'fx', size, frames=frames, foot=(size[0] / 2, size[1] / 2), draw_scale=1.0,
                                               tags=('agua', 'efeito', 'animado'), source='game/tools/terrain/bake_ground.py'))
    return entries


def main():
    world = json.loads((GAME / 'data' / 'reg001_world.json').read_text(encoding='utf-8'))
    textures = T.build_all()
    entries = save_tiles(textures)
    entries += save_water_fx()
    world_img, ter = bake_world(textures, world)
    entries += save_chunks(world_img, 'ter_ground', 'mundo', W, H, 'game/tools/terrain/bake_ground.py')
    bosque_img, _ = bake_bosque(textures)
    entries += save_chunks(bosque_img, 'ter_bosque', 'bosque', 1825, 862, 'game/tools/terrain/bake_ground.py')
    manifest_lib.write_part('terrain', entries)
    print('TERRAIN OK', len(entries), 'assets; merged', manifest_lib.merge())
    if '--preview' in sys.argv:
        Image.fromarray(world_img).resize((W // 3, H // 3), Image.LANCZOS).save(sys.argv[sys.argv.index('--preview') + 1])


if __name__ == '__main__':
    main()
