"""Monstros (4 quadros) e fauna no estilo v0.5 — contorno escuro, 3 tons, olhos grandes.

Saídas:
  assets/<monstro>_anim.png  folha horizontal de 4 quadros (36x36; Guardião 64x64)
  assets/<monstro>.png       quadro 0, mantido para compatibilidade
  assets/<animal>.png        fauna 32x32
Todos olham para a direita; o jogo espelha quando o bicho anda para a esquerda.
"""
from math import sin, cos, pi
from pathlib import Path
from PIL import Image
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from estilo_px import hexc, canvas, outline, rect, dot, line_px

OUT = Path(__file__).resolve().parents[1] / "assets"
P = lambda *h: tuple(hexc(x) for x in h)
WHITE = hexc('#ffffff')
EYE = hexc('#231530')


def ell(d, x0, y0, x1, y1, c):
    d.ellipse((round(x0), round(y0), round(x1), round(y1)), fill=c)


def shade_ell(d, cx, cy, rx, ry, C):
    L, B, S = C
    ell(d, cx - rx, cy - ry, cx + rx, cy + ry, S)
    ell(d, cx - rx, cy - ry, cx + rx - 1, cy + ry - 2, B)
    ell(d, cx - rx * .7, cy - ry * .85, cx + rx * .2, cy - ry * .1, L)


# ------------------------------------------------------------------ lobos

def wolf(frame, fur, belly, eye_col, crystals=None):
    im, d = canvas(36, 36)
    ph = frame * pi / 2
    bob = -1 if frame % 2 else 0
    step = round(sin(ph) * 2)
    L, B, S = fur
    # pernas de trás e da frente, alternando
    for lx, off, col in ((9, step, S), (13, -step, B), (21, -step, S), (25, step, B)):
        rect(d, lx + off, 22 + bob, lx + 2 + off, 29, col)
        rect(d, lx + off, 29, lx + 3 + off, 30, S)
    # cauda
    tail = round(sin(ph + 1) * 2)
    d.polygon([(8, 18 + bob), (2, 12 + tail + bob), (3, 16 + tail + bob), (7, 21 + bob)], fill=B)
    dot(d, 3, 13 + tail + bob, L)
    # corpo
    shade_ell(d, 17, 19 + bob, 10, 6, fur)
    ell(d, 12, 21 + bob, 23, 25 + bob, belly)
    if crystals:
        for x, h in ((11, 5), (15, 7), (19, 5)):
            d.polygon([(x, 14 + bob), (x + 2, 14 - h + bob), (x + 4, 14 + bob)], fill=crystals[1])
            d.line([(x + 1, 13 + bob), (x + 2, 15 - h + bob)], fill=crystals[0])
    # cabeça grande (leitura chibi) + focinho
    hx, hy = 27, 14 + bob
    shade_ell(d, hx, hy, 7, 6, fur)
    ell(d, hx + 2, hy + 1, hx + 9, hy + 6, belly)
    rect(d, hx + 8, hy + 2, hx + 9, hy + 3, EYE)                     # nariz
    d.polygon([(hx - 5, hy - 3), (hx - 4, hy - 11), (hx, hy - 5)], fill=B)   # orelhas
    d.polygon([(hx, hy - 4), (hx + 3, hy - 11), (hx + 5, hy - 4)], fill=L)
    dot(d, hx + 2, hy - 7, hexc('#ff9aa8'))
    rect(d, hx + 2, hy - 1, hx + 4, hy + 1, eye_col)                 # olho feroz
    dot(d, hx + 2, hy - 1, WHITE)
    rect(d, hx + 1, hy - 2, hx + 4, hy - 2, S)                        # sobrancelha brava
    dot(d, hx + 6, hy + 5, WHITE)                                     # presa
    return outline(im)


def slime(frame):
    im, d = canvas(36, 36)
    squash = [0, 2, 0, -2][frame]
    C = P('#b8ff9a', '#4cd66a', '#1e8a4a')
    rx, ry = 12 + squash // 1, 9 - squash // 1
    cy = 30 - ry
    d.polygon([(18 - rx, 30), (18 - rx + 2, cy), (18, cy - ry + 2), (18 + rx - 2, cy), (18 + rx, 30)], fill=C[1])
    ell(d, 18 - rx, cy - ry, 18 + rx, 30, C[1])
    ell(d, 18 - rx, cy + 2, 18 + rx, 30, C[2])
    ell(d, 18 - rx + 1, cy - ry + 1, 18 + rx - 2, 27, C[1])
    ell(d, 18 - rx + 3, cy - ry + 2, 18 - rx + 9, cy - ry + 6, C[0])
    dot(d, 18 - rx + 4, cy - ry + 3, WHITE)
    for ex in (13, 22):
        rect(d, ex, cy - 1, ex + 1, cy + 3, EYE)
        dot(d, ex, cy - 1, WHITE)
    rect(d, 16, cy + 5, 19, cy + 5, EYE)
    # gotas brilhando dentro do gel
    dot(d, 25, cy + 4, C[0]); dot(d, 11, cy + 6, C[0])
    return outline(im)


def scorpion(frame):
    im, d = canvas(36, 36)
    C = P('#ffd27a', '#e08a2c', '#8e4a18')
    step = round(sin(frame * pi / 2) * 1.5)
    for i, lx in enumerate((10, 14, 18, 22)):     # patas
        o = step if i % 2 else -step
        d.line([(lx, 22), (lx - 3 + o, 28)], fill=C[2], width=2)
        d.line([(lx, 18), (lx - 3 - o, 13)], fill=C[2], width=2)
    shade_ell(d, 17, 20, 9, 5, C)
    for k in range(3):
        rect(d, 11 + k * 5, 17, 11 + k * 5, 23, C[2])
    # cauda segmentada curvando por cima
    sway = round(sin(frame * pi / 2 + 1) * 1)
    segs = [(8, 19), (5, 15), (5, 10), (8, 6 + sway), (12, 5 + sway)]
    for i, (x, y) in enumerate(segs):
        ell(d, x - 3, y - 3, x + 3, y + 3, C[1] if i % 2 else C[0])
    d.polygon([(12, 2 + sway), (17, 5 + sway), (12, 8 + sway)], fill=hexc('#8a2a8a'))
    dot(d, 15, 5 + sway, WHITE)
    # garras
    pinch = frame % 2
    for cy in (15, 25):
        line_px(d, 25, 20 + (cy - 20) // 2, 29, cy, C[1], 2)
        d.polygon([(28, cy - 3), (34, cy - 2 - pinch), (31, cy), (34, cy + 2 + pinch), (28, cy + 3)], fill=C[0])
    for ex in (23, 26):
        rect(d, ex, 18, ex + 1, 19, EYE)
        dot(d, ex, 18, WHITE)
    return outline(im)


def guardian(frame):
    """Guardião das Ruínas: cavaleiro de pedra com runas violetas pulsando (64x64)."""
    im, d = canvas(64, 64)
    stone = P('#c6c0dc', '#7f78a4', '#463f6a')
    rune = [hexc('#f4d8ff'), hexc('#c07cff'), hexc('#7a3adc')]
    glow = [0, 1, 2, 1][frame]
    bob = [0, -1, -1, 0][frame]
    # pernas pesadas
    for lx in (20, 36):
        rect(d, lx, 44 + bob, lx + 8, 58, stone[2])
        rect(d, lx, 44 + bob, lx + 7, 56, stone[1])
        rect(d, lx - 1, 55, lx + 9, 59, stone[2])
        rect(d, lx, 55, lx + 8, 56, stone[0])
    # tronco em blocos
    rect(d, 16, 22 + bob, 48, 46 + bob, stone[2])
    rect(d, 17, 22 + bob, 46, 44 + bob, stone[1])
    rect(d, 17, 22 + bob, 46, 24 + bob, stone[0])
    for y in (30, 38):
        rect(d, 18, y + bob, 46, y + bob, stone[2])
    rect(d, 31, 24 + bob, 32, 44 + bob, stone[2])
    # runa central pulsando
    rc = rune[2 - glow] if glow < 2 else rune[0]
    d.polygon([(32, 27 + bob), (37, 33 + bob), (32, 39 + bob), (27, 33 + bob)], fill=rune[1])
    d.polygon([(32, 30 + bob), (34, 33 + bob), (32, 36 + bob), (30, 33 + bob)], fill=rc)
    # ombreiras e braços com punhos enormes
    for sx, side in ((10, -1), (54, 1)):
        ell(d, sx - 8, 18 + bob, sx + 8, 30 + bob, stone[1])
        ell(d, sx - 7, 18 + bob, sx + 4, 25 + bob, stone[0])
        rect(d, sx - 4, 28 + bob, sx + 4, 40 + bob, stone[2])
        ell(d, sx - 7, 37 + bob + glow * side // 2, sx + 7, 50 + bob, stone[1])
        ell(d, sx - 6, 38 + bob, sx + 2, 44 + bob, stone[0])
        dot(d, sx, 45 + bob, rune[1])
    # elmo com fenda luminosa e chifres
    ell(d, 21, 3 + bob, 43, 25 + bob, stone[2])
    ell(d, 21, 3 + bob, 42, 23 + bob, stone[1])
    ell(d, 24, 5 + bob, 34, 12 + bob, stone[0])
    d.polygon([(22, 10 + bob), (13, 1 + bob), (24, 6 + bob)], fill=stone[0])
    d.polygon([(42, 10 + bob), (51, 1 + bob), (40, 6 + bob)], fill=stone[1])
    rect(d, 25, 14 + bob, 39, 17 + bob, EYE)
    rect(d, 27, 15 + bob, 29, 16 + bob, rune[glow])
    rect(d, 35, 15 + bob, 37, 16 + bob, rune[glow])
    out = outline(im)
    if glow:
        halo, hd = canvas(64, 64)
        hd.ellipse((24, 25 + bob, 40, 41 + bob), outline=rune[1][:3] + (90 + glow * 40,))
        out.alpha_composite(halo)
    return out


# ------------------------------------------------------------------ fauna

def quadruped(fur, belly, head_extra=None, size=1.0, neck=0, hump=False, long_ears=False):
    im, d = canvas(32, 32)
    L, B, S = fur
    for lx, col in ((9, S), (12, B), (19, S), (22, B)):
        rect(d, lx, 20, lx + 1, 27, col)
        dot(d, lx, 27, hexc('#3a2418'))
    shade_ell(d, 16, 18, 9, 5, fur)
    ell(d, 11, 20, 21, 23, belly)
    if hump:
        shade_ell(d, 14, 12, 5, 4, fur)
    hx, hy = 25, 12 - neck
    if neck:
        line_px(d, 22, 16, hx - 1, hy + 2, B, 4)
    shade_ell(d, hx, hy, 4, 4, fur)
    ell(d, hx + 1, hy, hx + 6, hy + 4, belly)
    dot(d, hx + 5, hy + 1, EYE)
    rect(d, hx + 1, hy - 1, hx + 2, hy, EYE); dot(d, hx + 1, hy - 1, WHITE)
    if long_ears:
        d.polygon([(hx - 3, hy - 2), (hx - 3, hy - 11), (hx, hy - 3)], fill=B)
        d.polygon([(hx - 1, hy - 3), (hx + 1, hy - 11), (hx + 2, hy - 3)], fill=L)
    else:
        d.polygon([(hx - 3, hy - 2), (hx - 4, hy - 6), (hx - 1, hy - 3)], fill=B)
    if head_extra:
        head_extra(d, hx, hy)
    return im


def deer():
    def antlers(d, hx, hy):
        c = hexc('#f4e2b8')
        for base, k in ((hx - 2, -1), (hx + 1, 1)):
            d.line([(base, hy - 3), (base + k, hy - 9)], fill=c)
            d.line([(base + k, hy - 6), (base + k * 3, hy - 8)], fill=c)
    im = quadruped(P('#e8a868', '#b8703a', '#7a4424'), hexc('#fbe4c4'), antlers, neck=2)
    d = __import__('PIL.ImageDraw', fromlist=['Draw']).Draw(im)
    for x, y in ((12, 16), (16, 15), (19, 17)):
        dot(d, x, y, hexc('#fbe4c4'))
    return outline(im)


def fox():
    im = quadruped(P('#ffa24a', '#e0641e', '#9a3a14'), hexc('#fff0dc'))
    d = __import__('PIL.ImageDraw', fromlist=['Draw']).Draw(im)
    d.polygon([(8, 17), (1, 10), (2, 17), (6, 21)], fill=hexc('#e0641e'))
    d.polygon([(1, 10), (3, 12), (2, 14)], fill=hexc('#fff0dc'))
    d.polygon([(26, 10), (28, 4), (29, 10)], fill=hexc('#e0641e'))
    return outline(im)


def hare():
    im, d = canvas(32, 32)
    C = P('#f4e8dc', '#c8b4a0', '#8a7464')
    shade_ell(d, 15, 20, 7, 6, C)
    ell(d, 7, 18, 11, 22, WHITE)
    shade_ell(d, 21, 15, 4, 4, C)
    d.polygon([(18, 12), (17, 2), (20, 11)], fill=C[1])
    d.polygon([(21, 12), (22, 2), (23, 11)], fill=C[0])
    dot(d, 22, 5, hexc('#ffb0b8'))
    rect(d, 22, 14, 23, 15, EYE); dot(d, 22, 14, WHITE)
    dot(d, 25, 16, hexc('#ff8fa0'))
    rect(d, 12, 25, 18, 26, C[2])
    return outline(im)


def goat():
    def horns(d, hx, hy):
        c = hexc('#8a7a64')
        d.arc((hx - 6, hy - 9, hx + 1, hy - 1), 180, 330, fill=c, width=2)
        line_px(d, hx + 4, hy + 3, hx + 4, hy + 7, hexc('#e8e0d4'), 1)
    return outline(quadruped(P('#ffffff', '#dcdce8', '#9a9ab4'), hexc('#f4f4fa'), horns))


def camel():
    return outline(quadruped(P('#f4d08c', '#d0a054', '#8e6428'), hexc('#f8e2b0'), neck=4, hump=True))


def bird(frame=0):
    im, d = canvas(32, 32)
    C = P('#8ad8ff', '#3a8ae0', '#1e4a9a')
    shade_ell(d, 16, 16, 6, 4, C)
    wing = [-6, -2, 3, -2][frame]
    d.polygon([(13, 14), (18, 14), (15, 14 + wing - 2)], fill=C[0])
    ell(d, 19, 10, 25, 16, C[1])
    d.polygon([(25, 12), (29, 13), (25, 14)], fill=hexc('#ffc23a'))
    dot(d, 22, 12, EYE)
    d.polygon([(10, 15), (4, 13), (6, 17)], fill=C[2])
    ell(d, 14, 17, 19, 20, hexc('#ffe8c8'))
    return outline(im)


def fish():
    im, d = canvas(32, 32)
    C = P('#fff0a8', '#ff9a3a', '#c24a1e')
    shade_ell(d, 16, 16, 8, 5, C)
    d.polygon([(8, 16), (2, 11), (2, 21)], fill=C[1])
    d.polygon([(14, 11), (18, 7), (19, 12)], fill=C[2])
    rect(d, 20, 14, 21, 15, EYE); dot(d, 20, 14, WHITE)
    for x in (12, 15):
        d.arc((x - 2, 13, x + 2, 19), 300, 60, fill=C[0])
    return outline(im)


def strip(frames):
    w, h = frames[0].size
    out = Image.new('RGBA', (w * len(frames), h))
    for i, f in enumerate(frames):
        out.alpha_composite(f, (i * w, 0))
    return out


if __name__ == '__main__':
    gray = P('#c8d4e8', '#7f8fb0', '#48527a')
    ice = P('#ffffff', '#bfe8f8', '#6aa8d4')
    monsters = {
        'wolf': [wolf(f, gray, hexc('#e8eef8'), hexc('#ffd23a')) for f in range(4)],
        'ice_wolf': [wolf(f, ice, hexc('#ffffff'), hexc('#3ae0ff'), P('#ffffff', '#8ef4ff', '#2e98d0')) for f in range(4)],
        'slime': [slime(f) for f in range(4)],
        'scorpion': [scorpion(f) for f in range(4)],
        'boss': [guardian(f) for f in range(4)],
    }
    for name, frames in monsters.items():
        strip(frames).save(OUT / f'{name}_anim.png')
        frames[0].save(OUT / f'{name}.png')
    for name, fn in (('deer', deer), ('fox', fox), ('hare', hare), ('goat', goat), ('camel', camel), ('fish', fish)):
        fn().save(OUT / f'{name}.png')
    bird(0).save(OUT / 'bird.png')
    strip([bird(f) for f in range(4)]).save(OUT / 'bird_anim.png')
    print('Monstros animados e fauna v0.5 gerados')
