#!/usr/bin/env python3
"""FX de interação (pixel art, alpha duro): baú, colheita, mineração, escavação, santuário e segredo.

Simulação de partículas determinística -> 8 quadros de 96x96 por FX (pé em (48, 66)). Não depende do Blender.
Uso: python3 pro_fx.py
"""
import json
import math
import random
import sys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
GAME = HERE.parents[1]
sys.path.insert(0, str(GAME / 'tools' / 'modeling'))
import manifest_lib  # noqa: E402

W, H, ORIGIN, FRAMES = 96, 96, (48, 66), 8


def hexc(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def ramp(cols, t):
    t = max(0.0, min(0.999, t))
    k = t * (len(cols) - 1)
    i = int(k)
    a, b = hexc(cols[i]), hexc(cols[i + 1])
    f = k - i
    return tuple(int(a[j] + (b[j] - a[j]) * f) for j in range(3))


def put(im, x, y, c, a=255):
    x, y = int(round(x)), int(round(y))
    if 0 <= x < W and 0 <= y < H:
        im.putpixel((x, y), (c[0], c[1], c[2], a))


def shape(im, x, y, r, c, kind='sq', outline=None):
    r = max(1, int(round(r)))
    pts = []
    if kind == 'sq':
        pts = [(dx, dy) for dx in range(-r + 1, r) for dy in range(-r + 1, r)]
    elif kind == 'dia':
        pts = [(dx, dy) for dx in range(-r, r + 1) for dy in range(-r, r + 1) if abs(dx) + abs(dy) <= r]
    elif kind == 'star':
        pts = [(0, 0)] + [(k, 0) for k in range(-r, r + 1)] + [(0, k) for k in range(-r, r + 1)] + ([(1, 1), (-1, 1), (1, -1), (-1, -1)] if r > 2 else [])
    elif kind == 'ring':
        pts = [(dx, dy) for dx in range(-r, r + 1) for dy in range(-r, r + 1) if r - 1 <= math.hypot(dx, dy) <= r + .5]
    if outline:
        ring = {(dx + ox, dy + oy) for dx, dy in pts for ox, oy in ((1, 0), (-1, 0), (0, 1), (0, -1))} - set(pts)
        for dx, dy in ring:
            put(im, x + dx, y + dy, outline)
    for dx, dy in pts:
        put(im, x + dx, y + dy, c)


def sim(seed, n, spawn, vel, grav, life, cols, size, kind, drag=0.0, burst_only=True, outline=None, sway=0.0):
    rr = random.Random(seed)
    parts = []
    for i in range(n):
        sp = spawn(rr)
        v = vel(rr)
        parts.append(dict(x=sp[0], y=sp[1], vx=v[0], vy=v[1], t0=(0 if burst_only else rr.uniform(0, .5)), life=life * rr.uniform(.7, 1.15), s=size * rr.uniform(.7, 1.2), k=kind if isinstance(kind, str) else rr.choice(kind), ph=rr.uniform(0, 6.28)))
    frames = []
    for f in range(FRAMES):
        t = f / (FRAMES - 1)
        im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
        for p in parts:
            tt = t - p['t0']
            if tt < 0 or tt > p['life']:
                continue
            u = tt / p['life']
            x = ORIGIN[0] + p['x'] + p['vx'] * tt * (1 - drag * tt) + math.sin(p['ph'] + tt * 9) * sway * tt
            y = ORIGIN[1] + p['y'] + p['vy'] * tt + .5 * grav * tt * tt
            c = ramp(cols, u)
            shape(im, x, y, max(1, p['s'] * (1 - u * .55)), c, p['k'], outline)
        frames.append(im)
    return frames


def glow(im, cx, cy, r, c, ring=False):
    for dx in range(-r, r + 1):
        for dy in range(-r, r + 1):
            d = math.hypot(dx, dy)
            if (ring and r - 1.2 <= d <= r) or (not ring and d <= r):
                if (dx + dy) % 2 == 0:
                    put(im, cx + dx, cy + dy, c, 200)


# ------------------------------------------------------------------ efeitos
def fx_chest_open():
    gold = ['#fff6b0', '#ffe060', '#f0b030', '#c87820', '#7a3c10']
    fr = sim(11, 26, lambda r: (r.uniform(-6, 6), -14), lambda r: (r.uniform(-26, 26), r.uniform(-58, -22)), 90, .85, gold, 2.6, ('star', 'dia', 'sq'), outline=None)
    for i, im in enumerate(fr):
        t = i / (FRAMES - 1)
        if t < .55:
            r = int(6 + t * 30)
            glow(im, ORIGIN[0], ORIGIN[1] - 16, r, hexc('#fff0a0'), ring=True)
            for k in range(8):
                a = k * math.pi / 4 + t * .6
                for d in range(6, int(12 + t * 26), 2):
                    put(im, ORIGIN[0] + math.cos(a) * d, ORIGIN[1] - 16 + math.sin(a) * d * .7, hexc('#ffe89a'), 220)
    return fr


def fx_harvest():
    leaf = ['#e8ff8a', '#8ad84a', '#3ea030', '#1e6a24']
    return sim(12, 22, lambda r: (r.uniform(-8, 8), -8), lambda r: (r.uniform(-34, 34), r.uniform(-40, -6)), 70, .9, leaf, 2.4, ('dia', 'sq'), outline=(20, 50, 24), sway=6)


def fx_mine():
    rockc = ['#ffe9a0', '#c8b088', '#8a7a6a', '#4a4048']
    fr = sim(13, 20, lambda r: (r.uniform(-5, 5), -16), lambda r: (r.uniform(-46, 46), r.uniform(-52, -10)), 150, .75, rockc, 2.2, ('sq', 'dia'), outline=(24, 18, 26))
    sp = sim(14, 14, lambda r: (r.uniform(-4, 4), -16), lambda r: (r.uniform(-60, 60), r.uniform(-70, -20)), 60, .5, ['#ffffff', '#ffe060', '#ff9a30'], 1.6, 'star', drag=.5)
    for a, b in zip(fr, sp):
        a.alpha_composite(b)
    return fr


def fx_dig():
    dirt = ['#c89a64', '#946a40', '#5e4028', '#34241a']
    return sim(15, 28, lambda r: (r.uniform(-10, 10), -4), lambda r: (r.uniform(-30, 30), r.uniform(-44, -8)), 110, .85, dirt, 3.2, ('sq', 'dia'), outline=(28, 18, 14), drag=.3)


def fx_shrine():
    blue = ['#ffffff', '#bfeaff', '#5ab8ff', '#2a68d0']
    fr = sim(16, 18, lambda r: (r.uniform(-14, 14), -2), lambda r: (r.uniform(-4, 4), r.uniform(-62, -30)), -6, 1.0, blue, 2.4, ('star', 'dia'), burst_only=False, sway=5)
    for i, im in enumerate(fr):
        t = i / (FRAMES - 1)
        glow(im, ORIGIN[0], ORIGIN[1] - 2, int(10 + t * 26), hexc('#7ad0ff'), ring=True)
        glow(im, ORIGIN[0], ORIGIN[1] - 2, int(6 + t * 16), hexc('#bfeaff'), ring=True)
        for k in range(6):
            a = k * math.pi / 3 + t * 3.2
            put(im, ORIGIN[0] + math.cos(a) * (12 + t * 12), ORIGIN[1] - 2 + math.sin(a) * (12 + t * 12) * .55, hexc('#ffffff'))
    return fr


def fx_secret():
    vio = ['#ffffff', '#f0d0ff', '#b478ff', '#5a2aa8']
    fr = sim(17, 26, lambda r: (0, -12), lambda r: (r.uniform(-44, 44), r.uniform(-44, 10)), 20, .95, vio, 2.4, ('star', 'dia'), drag=.4, sway=4)
    for i, im in enumerate(fr):
        t = i / (FRAMES - 1)
        for k in range(14):
            a = k * .45 + t * 7.0
            d = 4 + t * 34
            put(im, ORIGIN[0] + math.cos(a) * d, ORIGIN[1] - 12 + math.sin(a) * d * .6, hexc('#d8b0ff'))
    return fr


FX = {'fx_chest_open': (fx_chest_open, ('baú', 'abrir')), 'fx_harvest': (fx_harvest, ('colheita', 'folhas')), 'fx_mine': (fx_mine, ('mineração', 'fagulhas')),
      'fx_dig': (fx_dig, ('escavar', 'terra')), 'fx_shrine': (fx_shrine, ('santuário', 'luz')), 'fx_secret': (fx_secret, ('segredo', 'revelar'))}


def main():
    out = GAME / 'assets' / 'modeled' / 'fx'
    out.mkdir(parents=True, exist_ok=True)
    entries = []
    for id, (fn, tags) in FX.items():
        frames = fn()
        sheet = Image.new('RGBA', (W * FRAMES, H), (0, 0, 0, 0))
        for i, im in enumerate(frames):
            sheet.paste(im, (i * W, 0))
        png = out / f'{id}.png'
        sheet.save(png)
        e = manifest_lib.make_entry(id, png, 'fx', 'fx', (W, H), FRAMES, 1, ORIGIN, 1.0, 0.0, 0.0, ('fx', 'animado') + tags, 'game/tools/art_pipeline/pro_fx.py')
        e['pipeline'] = 'pixel-sim'
        entries.append(e)
        print('OK', id)
    old = {}
    part = manifest_lib.PARTS / 'fx.json'
    manifest_lib.write_part('fx', entries)


if __name__ == '__main__':
    main()
