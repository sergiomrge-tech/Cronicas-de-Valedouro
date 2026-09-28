"""Utilitários de pixel art do estilo v0.5 (inspiração: RPGs de SNES / Drakantos).

Regras do estilo, válidas para todo asset gerado:
- contorno escuro seletivo de 1 px (cor do vizinho escurecida, puxada para roxo);
- três tons por material (luz em cima/esquerda, base, sombra embaixo/direita);
- cores saturadas e quentes, sem cinza "morto";
- personagens chibi: cabeça grande, olhos expressivos, silhueta legível a 1x.
"""
from math import sin, cos, pi, atan2, hypot
from PIL import Image, ImageDraw

OUTLINE = (32, 20, 42)


def hexc(h, a=255):
    h = h.lstrip('#')
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


def mix(c1, c2, t):
    return tuple(round(c1[i] * (1 - t) + c2[i] * t) for i in range(3)) + (255,)


def canvas(w, h):
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def outline(im, strength=.72, diagonal=False):
    """Contorno seletivo: cada pixel vazio vizinho de pixel opaco recebe a cor do
    vizinho escurecida. Deixa a silhueta legível sobre qualquer chão."""
    w, h = im.size
    src = im.load()
    out = im.copy()
    dst = out.load()
    offs = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    if diagonal:
        offs += [(1, 1), (-1, 1), (1, -1), (-1, -1)]
    for y in range(h):
        for x in range(w):
            if src[x, y][3] > 40:
                continue
            best = None
            for ox, oy in offs:
                nx, ny = x + ox, y + oy
                if 0 <= nx < w and 0 <= ny < h and src[nx, ny][3] > 110:
                    best = src[nx, ny]
                    break
            if best:
                dst[x, y] = mix(best, OUTLINE, strength)
    return out


def blob(d, cx, cy, rx, ry, colors, light_dir=(-.6, -.8)):
    """Elipse com três tons: base, luz e sombra deslocadas."""
    light, base, shade = colors
    d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=shade)
    d.ellipse((cx - rx, cy - ry, cx + rx - max(1, rx // 4), cy + ry - max(1, ry // 3)), fill=base)
    lx, ly = cx + light_dir[0] * rx * .35, cy + light_dir[1] * ry * .4
    d.ellipse((lx - rx * .45, ly - ry * .35, lx + rx * .3, ly + ry * .25), fill=light)


def line_px(d, x0, y0, x1, y1, color, width=1):
    """Linha sem anti-aliasing com espessura quadrada (fica pixelada, sem borrão)."""
    n = max(1, int(max(abs(x1 - x0), abs(y1 - y0))) * 2)
    a = width // 2
    for i in range(n + 1):
        t = i / n
        x, y = round(x0 + (x1 - x0) * t), round(y0 + (y1 - y0) * t)
        d.rectangle((x - a, y - a, x - a + width - 1, y - a + width - 1), fill=color)


def dot(d, x, y, color):
    d.point((round(x), round(y)), fill=color)


def rect(d, x0, y0, x1, y1, color):
    d.rectangle((round(x0), round(y0), round(x1), round(y1)), fill=color)


def shaded_rect(d, x0, y0, x1, y1, colors):
    light, base, shade = colors
    rect(d, x0, y0, x1, y1, base)
    rect(d, x0, y0, x1, y0, light)
    rect(d, x0, y0, x0, y1, light)
    rect(d, x0, y1, x1, y1, shade)
    rect(d, x1, y0, x1, y1, shade)


def upscale_preview(im, k):
    return im.resize((im.width * k, im.height * k), Image.NEAREST)
