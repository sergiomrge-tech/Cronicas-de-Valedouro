"""Herói v0.5 — chibi estilo RPG de SNES, 8 direções, 8 quadros de andar + 10 de ataque.

Folhas de 864x448 (18 colunas x 8 linhas de 48x56), mesma matriz e mesma âncora
(pés em y=53) usadas pelo jogo desde a v0.3. Corpo, armaduras e armas são
camadas separadas que compartilham a função pose(), então ficam sempre juntas.
Rodar na raiz do projeto: python3 tools/generate_hero_animation.py
"""
from math import sin, cos, pi, atan2, hypot
from pathlib import Path
from PIL import Image
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from estilo_px import hexc, canvas, outline, rect, dot, line_px

OUT = Path(__file__).resolve().parents[1] / "assets"
FW, FH = 48, 56
WALK, ATTACK, DIRS = 8, 10, 8
FEET = 53

P = lambda *h: tuple(hexc(x) for x in h)
SKIN = P('#ffe3c4', '#f6b98c', '#cf8662')
HAIR = P('#d9733e', '#a4461f', '#6a2616')
TUNIC = P('#78c8ff', '#3486dc', '#1f4f9c')
CAPE = P('#ff7462', '#d93b3f', '#8c1f33')
PANTS = P('#8e84a8', '#5d5275', '#3b3350')
BOOT = P('#b27744', '#7d4b27', '#4d2c17')
BELT = hexc('#5b3421')
GOLD = hexc('#ffd35a')
EYE = hexc('#2b1b3d')
WHITE = hexc('#ffffff')
BLUSH = hexc('#ff9c8c')


def pose(direction, mode, step):
    ang = direction * pi / 4
    fx, fy = sin(ang), cos(ang)              # 0 = sul (de frente para a câmera)
    if fy > .7: view = 'front'
    elif fy < -.7: view = 'back'
    elif abs(fx) > .95: view = 'side'
    elif fy > 0: view = 'fdiag'
    else: view = 'bdiag'
    s = 1 if fx > .01 else -1 if fx < -.01 else 1
    p = dict(fx=fx, fy=fy, view=view, s=s, mode=mode, step=step)
    bob, legA, legB, arm, lean = 0, 0, 0, 0, 0
    if mode == 'walk':
        ph = step * pi / 4
        bob = -1 if step % 4 in (1, 2) else 0
        legA = round(sin(ph) * 2)
        legB = -legA
        arm = round(sin(ph) * 2)
    else:
        t = step / (ATTACK - 1)
        if t < .3:   lean = -round(t / .3 * 2)
        elif t < .6: lean = round((t - .3) / .3 * 4) - 2
        else:        lean = round(2 * (1 - (t - .6) / .4))
        bob = -1 if .25 < t < .55 else 0
        legA, legB = (1, -1) if .3 < t < .7 else (0, 0)
    cx = 24 + round(fx * lean * .8)
    base = FEET + round(fy * lean * .5)
    p.update(cx=cx, feet=base, bob=bob, legA=legA, legB=legB, arm=arm, lean=lean)
    top = base - 17 + bob
    p['torso'] = (cx - 6, top, cx + 6, base - 6 + bob)
    p['head'] = (cx, base - 25 + bob)
    hx = {'front': cx + 8, 'back': cx - 8, 'side': cx + s * 3, 'fdiag': cx + s * 7, 'bdiag': cx + s * 5}[view]
    hy = top + 8
    if mode == 'attack':
        t = step / (ATTACK - 1)
        reach = sin(min(1, t / .55) * pi / 2) * (1 - max(0, t - .6) / .4)
        hx += round(fx * 5 * reach)
        hy += (round(fy * 4 * reach) if fy < 0 else -round(fy * 7)) - round(sin(min(1, t / .3) * pi / 2) * 3 * (1 - reach))
    elif mode == 'walk':
        hy += abs(arm) // 2
    p['hand'] = (hx, hy)
    return p


def draw_body(p):
    im, d = canvas(FW, FH)
    cx, feet, s, view = p['cx'], p['feet'], p['s'], p['view']
    x0, y0, x1, y1 = p['torso']
    hx, hy = p['head']

    def legs():
        if view == 'side':
            for off, col in ((p['legA'], PANTS[2]), (p['legB'], PANTS[1])):
                lx = cx - 2 + off * s
                rect(d, lx, y1 + 1, lx + 3, feet - 2, col)
                rect(d, lx - (1 if s < 0 else 0), feet - 2, lx + 3 + (1 if s > 0 else 0), feet, BOOT[1])
                rect(d, lx, feet - 2, lx + 3, feet - 2, BOOT[0])
        else:
            spread = 0 if view in ('front', 'back') else s
            for lx, lift in ((cx - 5 + spread, max(0, p['legA'])), (cx + 1 + spread, max(0, p['legB']))):
                rect(d, lx, y1 + 1, lx + 3, feet - 2 - lift, PANTS[1])
                rect(d, lx, y1 + 1, lx, feet - 2 - lift, PANTS[0])
                rect(d, lx + 3, y1 + 1, lx + 3, feet - 2 - lift, PANTS[2])
                rect(d, lx, feet - 2 - lift, lx + 3, feet - lift, BOOT[1])
                rect(d, lx, feet - 2 - lift, lx + 3, feet - 2 - lift, BOOT[0])
                rect(d, lx + 3, feet - 1 - lift, lx + 3, feet - lift, BOOT[2])

    def cape():
        sway = p['arm'] // 2 if p['mode'] == 'walk' else -round(p['fx'] * p['lean'] * .6)
        if view in ('back', 'bdiag'):
            d.polygon([(x0 - 1, y0 + 1), (x1 + 1, y0 + 1), (x1 + 3 + sway, y1 + 5), (x0 - 3 + sway, y1 + 5)], fill=CAPE[1])
            d.line([(x0 + 2, y0 + 3), (x0 + 1 + sway, y1 + 4)], fill=CAPE[2])
            d.line([(cx + 1, y0 + 3), (cx + 1 + sway, y1 + 4)], fill=CAPE[2])
            d.line([(x0, y0 + 2), (x1, y0 + 2)], fill=CAPE[0])
        elif view in ('side', 'fdiag'):
            bx = cx - s * 5
            d.polygon([(bx, y0 + 1), (bx - s * 2, y0 + 1), (bx - s * (6 + abs(sway)), y1 + 4), (bx + s, y1 + 5)], fill=CAPE[2])
            d.line([(bx - s, y0 + 2), (bx - s * 4, y1 + 3)], fill=CAPE[1])
        else:
            d.polygon([(x0 - 1, y0 + 2), (x0 - 3, y1 + 3), (x0 + 1, y1 + 3)], fill=CAPE[2])
            d.polygon([(x1 + 1, y0 + 2), (x1 + 3, y1 + 3), (x1 - 1, y1 + 3)], fill=CAPE[2])

    def torso():
        rect(d, x0, y0, x1, y1, TUNIC[1])
        rect(d, x0, y0, x0 + 1, y1, TUNIC[0])
        rect(d, x1 - 1, y0, x1, y1, TUNIC[2])
        rect(d, x0, y1 - 3, x1, y1 - 3, BELT)
        if view in ('front', 'fdiag'):
            k = s if view == 'fdiag' else 0
            rect(d, cx - 1 + k, y0 + 1, cx + k, y1 - 5, TUNIC[2])
            dot(d, cx + k, y1 - 3, GOLD)
        rect(d, x0, y1 - 2, x1, y1, TUNIC[2])

    def arm(side_sign, swing, weapon_arm):
        sx, sy = cx + side_sign * 7, y0 + 1
        if weapon_arm:
            ex, ey = p['hand']
        else:
            ex, ey = sx + side_sign, sy + 7 - abs(swing) // 2
            if view == 'side':
                ey += swing
                ex += swing * s
        line_px(d, sx, sy, ex, ey - 1, TUNIC[0] if weapon_arm else TUNIC[1], 3)
        rect(d, ex - 1, ey - 1, ex + 1, ey + 1, SKIN[1])
        dot(d, ex - 1, ey - 1, SKIN[0])

    def head():
        d.ellipse((hx - 8, hy - 7, hx + 8, hy + 8), fill=SKIN[2])
        d.ellipse((hx - 8, hy - 7, hx + 7, hy + 6), fill=SKIN[1])
        d.ellipse((hx - 6, hy - 5, hx + 1, hy + 1), fill=SKIN[0])
        if view == 'back':
            d.ellipse((hx - 9, hy - 10, hx + 9, hy + 8), fill=HAIR[1])
            d.polygon([(hx - 9, hy + 1), (hx - 7, hy + 9), (hx - 4, hy + 5), (hx - 1, hy + 10), (hx + 2, hy + 5), (hx + 5, hy + 9), (hx + 9, hy + 1)], fill=HAIR[1])
            d.arc((hx - 7, hy - 8, hx + 7, hy + 6), 200, 320, fill=HAIR[0])
            for k in (-4, 0, 4):
                d.line([(hx + k, hy - 4), (hx + k + 1, hy + 5)], fill=HAIR[2])
            d.polygon([(hx - 2, hy - 9), (hx + 1, hy - 14), (hx + 3, hy - 9)], fill=HAIR[1])
        else:
            shift = {'front': 0, 'fdiag': s * 2, 'side': s * 3, 'bdiag': s * 4}[view]
            ox = -shift // 2
            d.ellipse((hx - 9 + ox, hy - 11, hx + 9 + ox, hy + 1), fill=HAIR[1])
            fr = [(hx - 9 + ox, hy - 2)]
            for i, k in enumerate(range(-7, 9, 3)):
                fr.append((hx + k + shift // 2, hy - (0 if i % 2 else 2)))
            fr += [(hx + 9 + ox, hy - 3), (hx + 9 + ox, hy - 7), (hx - 9 + ox, hy - 7)]
            d.polygon(fr, fill=HAIR[1])
            d.polygon([(hx - 7, hy - 8), (hx - 12, hy - 12), (hx - 3, hy - 10)], fill=HAIR[1])
            d.polygon([(hx - 2, hy - 10), (hx + 1, hy - 16), (hx + 3, hy - 10)], fill=HAIR[1])
            d.polygon([(hx + 4, hy - 9), (hx + 11, hy - 12), (hx + 7, hy - 5)], fill=HAIR[1])
            d.arc((hx - 7 + ox, hy - 10, hx + 5 + ox, hy - 2), 190, 290, fill=HAIR[0])
            dot(d, hx - 3, hy - 9, HAIR[0]); dot(d, hx - 2, hy - 9, HAIR[0]); dot(d, hx, hy - 13, HAIR[0])
            if view in ('side', 'bdiag', 'fdiag'):
                bx = hx - s * 6
                d.polygon([(bx - s * 3, hy - 8), (bx + s * 4, hy - 6), (bx + s * 3, hy + 6), (bx - s * 3, hy + 5)], fill=HAIR[1])
                d.line([(bx - s, hy - 4), (bx, hy + 4)], fill=HAIR[2])
            if view == 'front':
                eyes = [hx - 4, hx + 3]
            elif view == 'fdiag':
                eyes = sorted([hx + s * 1, hx + s * 6])
            elif view == 'side':
                eyes = [hx + s * 5]
            else:
                eyes = []
            for ex in eyes:
                rect(d, ex, hy, ex + 1, hy + 3, EYE)
                dot(d, ex, hy, WHITE)
                dot(d, ex + 1, hy + 3, hexc('#5a3f8a'))
            if view == 'front':
                dot(d, hx - 6, hy + 4, BLUSH); dot(d, hx + 6, hy + 4, BLUSH)
                dot(d, hx, hy + 5, SKIN[2])
            elif view == 'fdiag':
                dot(d, hx + s * 8, hy + 4, BLUSH)
                dot(d, hx + s * 4, hy + 5, SKIN[2])
        rect(d, hx - 5, hy + 7, hx + 5, hy + 9, CAPE[1])
        rect(d, hx - 5, hy + 7, hx + 5, hy + 7, CAPE[0])
        if view in ('front', 'fdiag', 'side'):
            tx = hx + (3 if view == 'front' else -s * 4)
            d.polygon([(tx, hy + 9), (tx + 2, hy + 13), (tx - 1, hy + 12)], fill=CAPE[2])

    far_arm_first = view in ('side', 'fdiag', 'bdiag')
    if view != 'back':
        cape()
    legs()
    if far_arm_first:
        arm(-s, -p['arm'], False)
    torso()
    if view == 'back':
        arm(1, p['arm'], False)
        arm(-1, 0, True)
        head()
        cape()
    else:
        if not far_arm_first:
            arm(-1, -p['arm'], False)
        head()
        arm(1 if view == 'front' else s, p['arm'], True)
    return outline(im)


ARMOR = {
    1: dict(c=P('#e0a868', '#a86c3a', '#6c4024'), trim=hexc('#f0d9a0'), gem=None),
    2: dict(c=P('#e8eef0', '#a4b2ba', '#5c6a78'), trim=hexc('#ffffff'), gem=None),
    3: dict(c=P('#fff0a0', '#e0a83a', '#94601e'), trim=hexc('#fff8d8'), gem=hexc('#ff5a6a')),
    4: dict(c=P('#d8fbff', '#6ec6e8', '#2e6ea8'), trim=hexc('#ffffff'), gem=hexc('#b8fff4')),
}


def draw_armor(p, tier):
    im, d = canvas(FW, FH)
    a = ARMOR[tier]
    L, B, S = a['c']
    x0, y0, x1, y1 = p['torso']
    view, s, cx = p['view'], p['s'], p['cx']
    if view in ('back', 'bdiag'):
        rect(d, x0, y0, x1, y0 + 1, B)   # a capa cobre as costas; só a gola da armadura aparece
        rect(d, x0, y0, x1, y0, L)
    else:
        rect(d, x0, y0 + 1, x1, y1 - 3, B)
        rect(d, x0, y0 + 1, x1, y0 + 2, L)
        rect(d, x1 - 1, y0 + 1, x1, y1 - 3, S)
        rect(d, cx - 3, y0 + 3, cx + 3, y1 - 5, L if tier > 1 else B)
        rect(d, cx - 3, y1 - 5, cx + 3, y1 - 5, S)
        rect(d, x0, y1 - 3, x1, y1 - 3, S)
    sides = (-1, 1) if view in ('front', 'back') else (s,)
    for side in sides:
        ox = cx + side * 7
        d.ellipse((ox - 3, y0 - 1, ox + 3, y0 + 4), fill=B)
        rect(d, ox - 2, y0, ox + 1, y0, L)
        if tier >= 2:
            dot(d, ox, y0 + 2, a['trim'])
    if a['gem'] and view != 'back':
        rect(d, cx - 1, y0 + 5, cx, y0 + 6, a['gem'])
        dot(d, cx - 1, y0 + 5, WHITE)
    if tier == 4:
        for side in sides:
            ox = cx + side * 8
            d.polygon([(ox, y0 - 5), (ox - 2, y0), (ox + 2, y0)], fill=a['gem'])
    return outline(im)


WEAPON = {
    'sword': [P('#f4f8f8', '#b8c6cc', '#6a7a86'), P('#ffffff', '#d4e2dc', '#7e9890'), P('#fff4b8', '#f0c050', '#a06a20'), P('#e8ffff', '#7ee0f4', '#2a8cc0')],
    'bow':   [P('#d89a5a', '#9a6030', '#5e3418'), P('#e0b07a', '#a86e3e', '#643c20'), P('#fff0a0', '#e0a83a', '#94601e'), P('#d8fbff', '#6ec6e8', '#2e6ea8')],
    'staff': [P('#c89060', '#8a5a34', '#553219'), P('#b88a6a', '#7a5438', '#4a2c1c'), P('#e0b070', '#a06e3a', '#5e3a1c'), P('#9ab0e0', '#5a6aa8', '#343c70')],
}
ORB = [P('#d8fff0', '#5ee0a8', '#2a8a6a'), P('#e8e0ff', '#a88cff', '#5a44b8'), P('#fff0c8', '#ff9a3a', '#b8481c'), P('#ffffff', '#8ef4ff', '#2e98d0')]
SMEAR = [hexc('#fffbe0', 235), hexc('#ffe6a0', 175), hexc('#ffc870', 110)]


def draw_weapon(p, family, tier):
    im, d = canvas(FW, FH)
    fx_im, fd = canvas(FW, FH)
    hx, hy = p['hand']
    fx, fy, s, mode, step = p['fx'], p['fy'], p['s'], p['mode'], p['step']
    L, B, S = WEAPON[family][tier]
    t = step / (ATTACK - 1) if mode == 'attack' else 0
    face = atan2(fy, fx)
    if family == 'sword':
        length = 13 + (1 if tier >= 2 else 0)
        if mode == 'attack':
            if t < .25:   a = face - 2.1 + t / .25 * .2
            elif t < .6:  a = face - 1.9 + (t - .25) / .35 * 3.3
            else:         a = face + 1.4 - (t - .6) / .4 * 1.2
        else:
            a = atan2(.85, s * .55 + fx * .3) + p['arm'] * .05
        vx, vy = cos(a), sin(a)
        tipx, tipy = hx + vx * length, hy + vy * length
        if mode == 'attack' and .25 <= t <= .72:
            a0 = max(face - 1.9, a - 2.4)
            outer, inner = [], []
            for i in range(24):
                u = i / 23
                aa = a0 + (a - a0) * u
                outer.append((hx + cos(aa) * (length + 2), hy + sin(aa) * (length + 2)))
                inner.append((hx + cos(aa) * (length + 1 - 7 * u), hy + sin(aa) * (length + 1 - 7 * u)))
            fd.polygon(outer + inner[::-1], fill=SMEAR[2])
            for i in range(23):
                line_px(fd, *outer[i], *outer[i + 1], SMEAR[0], 1)
        line_px(d, hx + vx * 3, hy + vy * 3, tipx, tipy, B, 2)
        line_px(d, hx + vx * 3, hy + vy * 3, tipx - vx, tipy - vy, L, 1)
        dot(d, tipx + vx, tipy + vy, L)
        px, py = -vy, vx
        guard = hexc('#b8fff4') if tier == 3 else hexc('#ffd35a')
        line_px(d, hx + vx * 2 - px * 3, hy + vy * 2 - py * 3, hx + vx * 2 + px * 3, hy + vy * 2 + py * 3, guard, 1)
        line_px(d, hx - vx * 2, hy - vy * 2, hx + vx, hy + vy, hexc('#6a3a22'), 2)
        if tier >= 2:
            dot(d, hx + vx * 2, hy + vy * 2, hexc('#ff5a6a') if tier == 2 else WHITE)
    elif family == 'bow':
        pull = 4 * sin(min(1, t / .55) * pi / 2) if mode == 'attack' and t < .6 else 0
        f = (fx, fy) if mode == 'attack' else (fx * .6 + s * .4, fy * .6 + .5)
        n = hypot(*f); f = (f[0] / n, f[1] / n)
        perp = (-f[1], f[0])
        pts = []
        for i in range(13):
            u = -1 + i / 6
            k = 3 * (1 - u * u)
            pts.append((hx + perp[0] * u * 9 + f[0] * k, hy + perp[1] * u * 9 + f[1] * k))
        for i in range(12):
            line_px(d, pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1], B, 2)
        for i in (0, 1, 11, 12):
            dot(d, *pts[i], L)
        mid = (hx - f[0] * pull, hy - f[1] * pull)
        string = hexc('#fff4d0')
        line_px(fd, pts[0][0], pts[0][1], mid[0], mid[1], string, 1)
        line_px(fd, pts[-1][0], pts[-1][1], mid[0], mid[1], string, 1)
        if mode == 'attack' and t < .62:
            line_px(d, mid[0], mid[1], hx + f[0] * 8, hy + f[1] * 8, hexc('#c89060'), 1)
            dot(d, hx + f[0] * 9, hy + f[1] * 9, hexc('#e8f0f0'))
        if tier >= 2:
            dot(d, *pts[6], hexc('#ff5a6a') if tier == 2 else hexc('#b8fff4'))
    else:
        if mode == 'attack':
            lift = sin(min(1, t / .5) * pi / 2) * (1 - max(0, t - .6) / .4)
            dirx, diry = (1 - lift) * s * .15 + lift * fx, -(1 - lift) + lift * fy
        else:
            dirx, diry = s * .18 + p['arm'] * .03, -1
        n = hypot(dirx, diry) or 1; dirx, diry = dirx / n, diry / n
        bx, by = hx - dirx * 7, hy - diry * 7
        topx, topy = hx + dirx * 12, hy + diry * 12
        line_px(d, bx, by, topx, topy, B, 2)
        line_px(d, bx, by, topx, topy, L, 1)
        O = ORB[tier]
        d.ellipse((topx - 3, topy - 3, topx + 3, topy + 3), fill=O[1])
        d.ellipse((topx - 2, topy - 2, topx + 1, topy + 1), fill=O[0])
        dot(d, topx - 1, topy - 1, WHITE)
        d.arc((topx - 4, topy - 4, topx + 4, topy + 4), 200, 340, fill=S)
        if mode == 'attack' and .3 < t < .8:
            fd.ellipse((topx - 6, topy - 6, topx + 6, topy + 6), outline=O[1][:3] + (130,))
            for k in range(5):
                aa = step * 1.3 + k * 1.26
                dot(fd, topx + cos(aa) * 7, topy + sin(aa) * 7, O[0])
    body = outline(im)
    body.alpha_composite(fx_im)
    return body


def sheet(render):
    out = Image.new('RGBA', (FW * (WALK + ATTACK), FH * DIRS))
    for direction in range(DIRS):
        for col in range(WALK + ATTACK):
            mode = 'walk' if col < WALK else 'attack'
            step = col if mode == 'walk' else col - WALK
            out.alpha_composite(render(pose(direction, mode, step)), (col * FW, direction * FH))
    return out


if __name__ == "__main__":
    sheet(draw_body).save(OUT / "hero_body.png", optimize=True)
    for tier in range(1, 5):
        sheet(lambda p, t=tier: draw_armor(p, t)).save(OUT / f"hero_armor_{tier}.png", optimize=True)
    for family in ("sword", "bow", "staff"):
        for tier in range(4):
            sheet(lambda p, f=family, t=tier: draw_weapon(p, f, t)).save(OUT / f"hero_{family}_{tier}.png", optimize=True)
    front = draw_body(pose(0, 'walk', 0))
    front.crop((11, 14, 37, 40)).save(OUT / "ui_portrait.png")
    front.crop((8, 14, 40, 54)).save(OUT / "hero.png")
    print("Folhas do herói v0.5: 17 camadas alinhadas + retrato do HUD")
