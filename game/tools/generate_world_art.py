"""Mundo e interface v0.5 — tiles 32x32 sem costura, vegetação, chão do exterior, UI e ícones.

Mesmo estilo do herói: paleta saturada de RPG de SNES, 3 tons por material e
contorno escuro seletivo nos objetos (o chão não tem contorno, para não quadricular).
Rodar na raiz: python3 tools/generate_world_art.py
"""
import random
from math import sin, cos, pi, hypot
from pathlib import Path
from PIL import Image, ImageDraw
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from estilo_px import hexc, canvas, outline, rect, dot, line_px, mix

OUT = Path(__file__).resolve().parents[1] / "assets"
P = lambda *h: tuple(hexc(x) for x in h)
WHITE = hexc('#ffffff')

GRASS = P('#b6ec70', '#7fd05a', '#52ad48', '#2f8040')        # realce, luz, base, sombra
MEADOW = P('#dcf49a', '#a8e070', '#7cc85a', '#4e9a48')
SAND = P('#fff4c8', '#f8dc98', '#e8bc6e', '#b88444')
SNOW = P('#ffffff', '#eaf8ff', '#c4e2f4', '#8ab8dc')
DIRT = P('#f8e0a8', '#e8c07c', '#c8965a', '#8e6038')
WATER = P('#d4fbff', '#6cd4f4', '#3a9ee0', '#2266b0')


def tor(px, x, y, c, s):
    px[x % s, y % s] = c


def noise_tile(size, pal, seed, speck=.16, tufts=0, flowers=0, pebbles=0):
    rnd = random.Random(seed)
    im = Image.new('RGBA', (size, size), pal[2])
    px = im.load()
    # manchas grandes e suaves (variação de tom sem ruído "sujo")
    for _ in range(size * size // 90):
        cx, cy, r = rnd.randrange(size), rnd.randrange(size), rnd.randint(3, 7)
        col = pal[1] if rnd.random() < .55 else pal[3]
        for y in range(-r, r + 1):
            for x in range(-r, r + 1):
                if x * x + y * y <= r * r and rnd.random() < .5:
                    tor(px, cx + x, cy + y, mix(px[(cx + x) % size, (cy + y) % size], col, .5), size)
    for _ in range(int(size * size * speck)):
        x, y = rnd.randrange(size), rnd.randrange(size)
        tor(px, x, y, pal[1] if rnd.random() < .6 else pal[3], size)
    for _ in range(tufts):                                   # tufos em "v"
        x, y = rnd.randrange(size), rnd.randrange(size)
        tor(px, x, y, pal[3], size); tor(px, x + 1, y + 1, pal[3], size); tor(px, x + 2, y, pal[3], size)
        tor(px, x, y - 1, pal[0], size); tor(px, x + 2, y - 1, pal[1], size); tor(px, x + 1, y, pal[1], size)
    for _ in range(pebbles):
        x, y = rnd.randrange(size), rnd.randrange(size)
        tor(px, x, y, hexc('#dcd4c4'), size); tor(px, x + 1, y, hexc('#b0a494'), size)
        tor(px, x, y + 1, hexc('#8a7c6c'), size); tor(px, x + 1, y + 1, hexc('#6e604e'), size)
    for _ in range(flowers):
        x, y = rnd.randrange(size), rnd.randrange(size)
        c = rnd.choice([hexc('#ffffff'), hexc('#ffe45a'), hexc('#ff8ab8'), hexc('#b8a4ff')])
        for ox, oy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
            tor(px, x + ox, y + oy, c, size)
        tor(px, x, y, hexc('#ffb02a'), size)
        tor(px, x + 1, y + 2, pal[3], size)
    return im


def water_tile(size, seed, river=False):
    rnd = random.Random(seed)
    im = Image.new('RGBA', (size, size), WATER[2])
    px = im.load()
    for y in range(size):
        for x in range(size):
            v = sin((x + y * .4) * 2 * pi / size * 2) + sin((y - x * .3) * 2 * pi / size * 3)
            if v > 1.1: px[x, y] = WATER[1]
            elif v < -1.2: px[x, y] = WATER[3]
    for _ in range(size // 5):
        x, y = rnd.randrange(size), rnd.randrange(size)
        for k in range(rnd.randint(2, 4)):
            tor(px, x + k, y, WATER[0], size)
    if river:
        for y in (6, 20):
            for x in range(4, 14):
                tor(px, x + y, y, WATER[1], size)
    return im


def cobble(size, pal, seed, mortar):
    rnd = random.Random(seed)
    im = Image.new('RGBA', (size, size), mortar)
    d = ImageDraw.Draw(im)
    rows = [(0, 8), (8, 16), (16, 24), (24, 32)]
    for r, (y0, y1) in enumerate(rows):
        x = -(r % 2) * 5
        while x < size:
            w = rnd.randint(7, 10)
            col = rnd.choice(pal[:3])
            d.rectangle((x + 1, y0 + 1, x + w - 1, y1 - 1), fill=col)
            d.line([(x + 1, y0 + 1), (x + w - 2, y0 + 1)], fill=pal[0])
            d.line([(x + 1, y1 - 1), (x + w - 1, y1 - 1)], fill=pal[3])
            if x + w > size:
                d.rectangle((x + 1 - size, y0 + 1, x + w - 1 - size, y1 - 1), fill=col)
            x += w
    return im


def planks(size, pal, seed, vertical=False):
    rnd = random.Random(seed)
    im = Image.new('RGBA', (size, size), pal[2])
    d = ImageDraw.Draw(im)
    for i in range(4):
        y0 = i * 8
        d.rectangle((0, y0, size, y0 + 7), fill=pal[1] if i % 2 else pal[2])
        d.line([(0, y0), (size, y0)], fill=pal[0])
        d.line([(0, y0 + 7), (size, y0 + 7)], fill=pal[3])
        cut = (i * 11 + 5) % size
        d.line([(cut, y0), (cut, y0 + 7)], fill=pal[3])
        dot(d, cut + 2, y0 + 3, hexc('#e8c070')); dot(d, cut - 3, y0 + 3, hexc('#e8c070'))
        for _ in range(3):
            x = rnd.randrange(size)
            d.line([(x, y0 + 3), (x + rnd.randint(2, 5), y0 + 3)], fill=pal[3])
    return im.rotate(90) if vertical else im


def bricks(size, pal):
    im = Image.new('RGBA', (size, size), pal[3])
    d = ImageDraw.Draw(im)
    for r in range(4):
        y0 = r * 8
        off = 8 if r % 2 else 0
        for x in range(-16, size + 16, 16):
            bx = x + off
            d.rectangle((bx + 1, y0 + 1, bx + 14, y0 + 6), fill=pal[1])
            d.line([(bx + 1, y0 + 1), (bx + 13, y0 + 1)], fill=pal[0])
            d.line([(bx + 2, y0 + 6), (bx + 14, y0 + 6)], fill=pal[2])
    return im


def roof(size):
    pal = P('#ff9a78', '#e05a44', '#a83430', '#6a1e28')
    im = Image.new('RGBA', (size, size), pal[3])
    d = ImageDraw.Draw(im)
    for r in range(4):
        y0 = r * 8
        off = 4 if r % 2 else 0
        for x in range(-8, size + 8, 8):
            d.ellipse((x + off, y0 - 2, x + off + 7, y0 + 8), fill=pal[1])
            d.arc((x + off, y0 - 2, x + off + 7, y0 + 8), 20, 160, fill=pal[2])
            dot(d, x + off + 2, y0 + 1, pal[0])
    return im


# ------------------------------------------------------------------ objetos

def tree(kind='leaf'):
    """Árvore 64x64 refinada: silhueta irregular, 4 níveis tonais e tronco enraizado."""
    im, d = canvas(64, 64)
    trunk_dark = hexc('#4b2c1d'); trunk_mid = hexc('#754823'); trunk_light = hexc('#b0783f')
    d.polygon([(27,57),(29,34),(36,34),(38,57),(34,53),(31,53)], fill=trunk_dark)
    d.polygon([(30,54),(31,34),(35,35),(35,52)], fill=trunk_mid)
    d.line((32,36,32,50),fill=trunk_light,width=1)
    d.polygon([(29,50),(22,58),(31,56)],fill=trunk_dark)
    d.polygon([(36,50),(43,58),(34,56)],fill=trunk_dark)

    if kind == 'leaf':
        dark, mid, light, hi = map(hexc, ('#123a22','#226b32','#4ea148','#a6df67'))
        clusters=[(20,18,14,12),(36,15,15,13),(49,24,11,12),(14,30,12,12),(29,29,17,15),(44,34,14,13),(23,40,13,11)]
        for i,(cx,cy,rx,ry) in enumerate(clusters):
            d.ellipse((cx-rx,cy-ry,cx+rx,cy+ry),fill=dark)
            d.ellipse((cx-rx+2,cy-ry+3,cx+rx-2,cy+ry-2),fill=mid)
            if i in (0,1,4,5):
                d.ellipse((cx-rx+7,cy-ry+5,cx+rx-6,cy+ry-6),fill=light)
        for box in [(13,11,25,17),(31,7,43,13),(39,20,51,25),(18,28,28,33)]:
            d.ellipse(box,fill=hi)
        # recortes escuros quebram a copa redonda e criam profundidade
        for box in [(9,24,17,31),(24,20,32,27),(39,29,48,36),(25,39,34,44)]:
            d.ellipse(box,fill=dark)
        for x,y in [(18,13),(38,11),(48,22),(22,31),(41,24)]:
            dot(d,x,y,hexc('#d9f18a'))
    else:
        snowy = kind == 'frost'
        if snowy:
            dark, mid, light, hi = map(hexc, ('#35536c','#628b9c','#a6ced2','#edfafa'))
        else:
            dark, mid, light, hi = map(hexc, ('#10382e','#1f664a','#3f956e','#86cfa0'))
        # pinheiro menos geométrico: ramos alternados e quatro níveis de profundidade
        tiers=[(32,10,11),(30,19,16),(34,29,20),(31,39,18)]
        for i,(cx,cy,half) in enumerate(tiers):
            d.polygon([(cx,cy-half),(cx-half-2,cy+half*.55),(cx+half,cy+half*.52)],fill=dark)
            d.polygon([(cx,cy-half+3),(cx-half+2,cy+half*.36),(cx+half-4,cy+half*.34)],fill=mid)
            d.polygon([(cx-2,cy-half+5),(cx-half//2,cy+half*.08),(cx+half//2-2,cy+half*.06)],fill=light)
            d.line((cx-half+5,cy-2,cx+half-7,cy-4),fill=hi,width=1)
            if snowy and i>0:
                d.line((cx-half+4,cy+1,cx+half-8,cy-1),fill=hexc('#ffffff'),width=2)
    return outline(im, .78)


def bush():
    im, d = canvas(32, 32)
    dark, mid, light, hi = map(hexc, ('#123b20','#267236','#55aa50','#a7df70'))
    clusters=[(7,19,6),(13,14,7),(20,13,7),(25,19,6),(16,21,8)]
    for i,(cx,cy,r) in enumerate(clusters):
        d.ellipse((cx-r,cy-r,cx+r,cy+r),fill=dark)
        d.ellipse((cx-r+2,cy-r+2,cx+r-1,cy+r-2),fill=mid)
        if i in (1,2,4):
            d.ellipse((cx-r+4,cy-r+4,cx+r-4,cy+r-4),fill=light)
    for x,y in [(10,11),(18,9),(22,15),(14,18)]:
        d.ellipse((x-2,y-1,x+2,y+2),fill=hi)
    for x,y in [(7,22),(21,23),(27,19)]:
        d.ellipse((x-2,y-1,x+2,y+2),fill=dark)
    return outline(im, .78)

def flower_patch():
    im, d = canvas(32, 32)
    rnd = random.Random(3)
    for _ in range(7):
        x, y = rnd.randint(5, 26), rnd.randint(6, 26)
        c = rnd.choice([hexc('#ffffff'), hexc('#ffe45a'), hexc('#ff8ab8'), hexc('#b8a4ff'), hexc('#ff6a5a')])
        d.line([(x, y + 1), (x, y + 4)], fill=hexc('#2f8040'))
        for ox, oy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
            dot(d, x + ox, y + oy, c)
        dot(d, x, y, hexc('#ffb02a'))
    return outline(im, .55)


def cactus():
    im, d = canvas(32, 48)
    C = P('#b8f07a', '#62c05a', '#2e8a48', '#1a5a38')
    d.rounded_rectangle((11, 8, 20, 44), 4, fill=C[2])
    d.rounded_rectangle((11, 8, 17, 42), 3, fill=C[1])
    d.rounded_rectangle((3, 18, 9, 30), 3, fill=C[2]); rect(d, 8, 26, 12, 29, C[2])
    d.rounded_rectangle((22, 14, 28, 26), 3, fill=C[2]); rect(d, 19, 22, 23, 25, C[2])
    for x in (13, 16):
        for y in range(12, 40, 6):
            dot(d, x, y, C[0])
    d.ellipse((13, 4, 19, 10), fill=hexc('#ff6aa8')); dot(d, 15, 6, hexc('#ffd0e8'))
    return outline(im)


def rock(pal, crystal=None):
    im, d = canvas(32, 32)
    d.polygon([(5, 26), (8, 13), (16, 7), (25, 11), (28, 26)], fill=pal[2])
    d.polygon([(6, 24), (9, 13), (16, 8), (24, 12), (22, 22), (12, 24)], fill=pal[1])
    d.polygon([(10, 14), (16, 9), (19, 12), (13, 17)], fill=pal[0])
    d.line([(16, 17), (22, 24)], fill=pal[3])
    if crystal:
        d.polygon([(18, 12), (21, 1), (24, 12)], fill=crystal[1])
        d.line([(20, 10), (21, 3)], fill=crystal[0])
    return outline(im)


# ------------------------------------------------------------------ chão grande do exterior

def big_ground(size, pal, seed, **kw):
    """Textura de 512 px repetível: mosaico de tiles + manchas de flores e tufos."""
    n = (size // 32) ** 2
    kw = {k: (v * n if k in ('tufts', 'flowers', 'pebbles') else v) for k, v in kw.items()}
    return noise_tile(size, pal, seed, **kw)


# ------------------------------------------------------------------ interface

UI = dict(bg=P('#3a2e5a', '#2a2046', '#1c1532'), gold=P('#fff2a8', '#f2c14e', '#a8702a', '#5a3418'))


def panel(w, h, button=False):
    im, d = canvas(w, h)
    g = UI['gold']
    top, mid, bot = UI['bg'] if not button else P('#5a4a8a', '#44366e', '#2e2450')
    d.rounded_rectangle((0, 0, w - 1, h - 1), 6, fill=g[3])
    d.rounded_rectangle((2, 2, w - 3, h - 3), 5, fill=g[2])
    d.rounded_rectangle((3, 3, w - 4, h - 4), 4, fill=g[1])
    d.line([(6, 3), (w - 7, 3)], fill=g[0])
    d.rounded_rectangle((6, 6, w - 7, h - 7), 3, fill=g[3])
    for y in range(7, h - 7):                          # interior em degradê de 3 faixas
        t = (y - 7) / max(1, h - 15)
        c = top if t < .33 else mid if t < .8 else bot
        d.line([(7, y), (w - 8, y)], fill=c)
    d.line([(8, 8), (w - 9, 8)], fill=mix(top, WHITE, .18))
    for cx, cy in ((6, 6), (w - 7, 6), (6, h - 7), (w - 7, h - 7)):   # cantos com gema
        d.polygon([(cx, cy - 4), (cx + 4, cy), (cx, cy + 4), (cx - 4, cy)], fill=g[1])
        d.polygon([(cx, cy - 2), (cx + 2, cy), (cx, cy + 2), (cx - 2, cy)], fill=hexc('#ff5a7a') if not button else hexc('#6ae8ff'))
        dot(d, cx - 1, cy - 1, WHITE)
    return im


def round_button(size=64):
    im, d = canvas(size, size)
    g = UI['gold']
    d.ellipse((0, 0, size - 1, size - 1), fill=g[3])
    d.ellipse((2, 2, size - 3, size - 3), fill=g[2])
    d.ellipse((3, 3, size - 4, size - 5), fill=g[1])
    d.ellipse((7, 7, size - 8, size - 8), fill=g[3])
    d.ellipse((8, 8, size - 9, size - 9), fill=hexc('#44366e'))
    d.ellipse((8, 8, size - 11, size - 13), fill=hexc('#5a4a8a'))
    d.arc((12, 11, size - 16, size - 18), 200, 260, fill=hexc('#8a7ac0'), width=2)
    return im


def icon_heart():
    im, d = canvas(16, 16)
    d.polygon([(8, 14), (1, 7), (1, 4), (4, 1), (8, 4), (12, 1), (15, 4), (15, 7)], fill=hexc('#e8344a'))
    d.polygon([(3, 4), (5, 3), (6, 5), (4, 7)], fill=hexc('#ff9aa8'))
    return outline(im)


def icon_coin():
    im, d = canvas(16, 16)
    d.ellipse((2, 2, 13, 13), fill=hexc('#a8702a'))
    d.ellipse((2, 2, 12, 12), fill=hexc('#f2c14e'))
    d.ellipse((4, 4, 10, 10), outline=hexc('#fff2a8'))
    rect(d, 7, 5, 7, 9, hexc('#a8702a'))
    return outline(im)


def icon_potion():
    im, d = canvas(16, 16)
    rect(d, 6, 1, 9, 4, hexc('#b07a4a'))
    d.ellipse((2, 4, 13, 15), fill=hexc('#c43a8a'))
    d.ellipse((2, 4, 12, 13), fill=hexc('#ff5ab0'))
    d.ellipse((4, 6, 7, 9), fill=hexc('#ffd0f0'))
    return outline(im)


def icon_xp():
    im, d = canvas(16, 16)
    d.polygon([(8, 1), (10, 6), (15, 7), (11, 10), (12, 15), (8, 12), (4, 15), (5, 10), (1, 7), (6, 6)], fill=hexc('#6ae8ff'))
    d.polygon([(8, 3), (9, 7), (7, 8)], fill=WHITE)
    return outline(im)


def btn_icons():
    """Ícones 24x24 dos botões de toque (sem depender de símbolos da fonte)."""
    im, d = canvas(24, 24)                                    # atacar: espada diagonal
    line_px(d, 5, 19, 18, 6, hexc('#8a9aa8'), 3); line_px(d, 6, 18, 18, 6, hexc('#f4f8f8'), 1)
    line_px(d, 4, 14, 10, 20, hexc('#ffd35a'), 2); line_px(d, 2, 21, 5, 18, hexc('#7a4a2a'), 3)
    outline(im).save(OUT / 'btn_attack.png')
    im, d = canvas(24, 24)                                    # interagir: balão com "!"
    d.rounded_rectangle((2, 3, 21, 16), 4, fill=hexc('#fff4d8'))
    d.polygon([(6, 15), (6, 21), (11, 15)], fill=hexc('#fff4d8'))
    rect(d, 11, 5, 12, 10, hexc('#d93b3f')); rect(d, 11, 12, 12, 13, hexc('#d93b3f'))
    outline(im).save(OUT / 'btn_interact.png')
    im, d = canvas(24, 24)                                    # mapa: pergaminho
    d.polygon([(3, 5), (9, 3), (15, 5), (21, 3), (21, 19), (15, 21), (9, 19), (3, 21)], fill=hexc('#f8e0a8'))
    d.line([(9, 3), (9, 19)], fill=hexc('#c8965a')); d.line([(15, 5), (15, 21)], fill=hexc('#c8965a'))
    d.line([(5, 14), (8, 10), (12, 13), (17, 8)], fill=hexc('#3a9ee0'))
    line_px(d, 16, 13, 19, 16, hexc('#d93b3f'), 1); line_px(d, 19, 13, 16, 16, hexc('#d93b3f'), 1)
    outline(im).save(OUT / 'btn_map.png')
    im, d = canvas(24, 24)                                    # bolsa
    d.ellipse((3, 7, 20, 22), fill=hexc('#a86c3a')); d.ellipse((3, 7, 18, 19), fill=hexc('#d09050'))
    rect(d, 8, 3, 15, 8, hexc('#a86c3a')); rect(d, 7, 8, 16, 9, hexc('#6a4020'))
    rect(d, 10, 12, 13, 14, hexc('#ffd35a'))
    outline(im).save(OUT / 'btn_bag.png')
    icon_potion().resize((24, 24), Image.NEAREST).save(OUT / 'btn_potion.png')


def equip_icons():
    import generate_hero_animation as H
    for family in ('sword', 'bow', 'staff'):
        for tier in range(4):
            p = H.pose(2, 'walk', 0)
            p['hand'] = (16, 28)
            layer = H.draw_weapon(p, family, tier).crop((0, 6, 32, 46))
            layer.save(OUT / f'equip_{family}_{tier}.png')
    for tier in range(1, 5):
        p = H.pose(0, 'walk', 0)
        body = H.draw_armor(p, tier).crop((8, 10, 40, 50))
        body.save(OUT / f'equip_armor_{tier}.png')


if __name__ == '__main__':
    noise_tile(32, GRASS, 1, tufts=5).save(OUT / 'grass.png')
    noise_tile(32, GRASS, 2, tufts=3, flowers=2).save(OUT / 'grass2.png')
    noise_tile(32, MEADOW, 3, tufts=3, flowers=3).save(OUT / 'meadow.png')
    noise_tile(32, SAND, 4, speck=.12).save(OUT / 'sand.png')
    noise_tile(32, SAND, 5, speck=.1, pebbles=2).save(OUT / 'sand2.png')
    noise_tile(32, SNOW, 6, speck=.08).save(OUT / 'snow.png')
    noise_tile(32, SNOW, 7, speck=.08, pebbles=1).save(OUT / 'snow2.png')
    noise_tile(32, DIRT, 8, speck=.14, pebbles=3).save(OUT / 'path.png')
    water_tile(32, 9).save(OUT / 'water.png')
    water_tile(32, 10, river=True).save(OUT / 'river.png')
    cobble(32, P('#e4e0f0', '#b8b4d0', '#9894b8', '#5a567a'), 11, hexc('#46425e')).save(OUT / 'stone.png')
    bricks(32, P('#a8a0c8', '#7a72a0', '#5a5280', '#2e2848')).save(OUT / 'wall.png')
    roof(32).save(OUT / 'roof.png')
    planks(32, P('#f0c080', '#d09050', '#a86c38', '#6a4020'), 12).save(OUT / 'plank.png')
    planks(32, P('#e0b070', '#b8804a', '#8a5a30', '#4e3018'), 13, vertical=True).save(OUT / 'bridge.png')
    tree('leaf').save(OUT / 'tree.png')
    tree('pine').save(OUT / 'pine.png')
    tree('frost').save(OUT / 'frost_tree.png')
    bush().save(OUT / 'bush.png')
    flower_patch().save(OUT / 'flower.png')
    cactus().save(OUT / 'cactus.png')
    rock(P('#fff0d0', '#e0b87a', '#b08450', '#6e4e2a')).save(OUT / 'sand_rock.png')
    rock(P('#ffffff', '#c8e4f4', '#8ab0d0', '#4a6a90'), P('#ffffff', '#8ef4ff')).save(OUT / 'ice_rock.png')
    big_ground(512, GRASS, 40, tufts=6, flowers=1, pebbles=1).convert('RGB').save(OUT / 'outskirts_ground.png')
    big_ground(512, DIRT, 60, speck=.14, pebbles=3).convert('RGB').save(OUT / 'path_ground.png')
    panel(256, 128).save(OUT / 'ui_wood_panel.png')
    panel(128, 64, button=True).save(OUT / 'ui_wood_button.png')
    round_button().save(OUT / 'ui_round_button.png')
    icon_heart().save(OUT / 'icon_heart.png')
    icon_coin().save(OUT / 'icon_coin.png')
    icon_potion().save(OUT / 'icon_potion.png')
    icon_xp().save(OUT / 'icon_xp.png')
    equip_icons()
    btn_icons()
    print('Tiles, vegetação, chão, interface e ícones v0.5 gerados')
