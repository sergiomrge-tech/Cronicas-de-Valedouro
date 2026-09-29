"""Estruturas regionais REG_001 em Blender: postos, abrigos, santuário, cais, barcos, celeiro, plantações, espantalho."""
import math
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import bpy
from mathutils import Vector
from vk import geo, mats, parts
from vk.parts import M
from pro_landmarks import landmark


# ------------------------------------------------------------------ posto de âmbar (deserto)
@landmark('str_outpost_amber', group='city', folder='structures', size=(440, 400), origin=(220, 310), tags=('estrutura', 'posto', 'deserto', 'ambar'), footprint=52, coll=(2.7, 2.5), samples=24)
def outpost_amber(f):
    ss, mwd, mw, mo = M('stone_sand'), M('wood_dark'), M('wood'), M('wood_old')
    rr = random.Random(521)
    # piso de terra batida e plinto de arenito
    geo.cyl((0, 0, 0), 2.1, .1, M('sand_ground'), sides=10)
    # muros de arenito em L (fundo) com nicho em arco e vãos
    geo.box((-1.1, 0, .95), (.5, 2.4, 1.9), ss, bevel=0.06)
    geo.box((0, -1.05, .95), (2.3, .5, 1.9), ss, bevel=0.06)
    for i in range(6):
        geo.box((-1.1 + rr.uniform(-.05, .05), -1.0 + i * .4, 1.95), (.55, .3, .18 + rr.uniform(0, .1)), ss, bevel=0.03)
    for i in range(5):
        geo.box((-.9 + i * .42, -1.05, 1.95), (.3, .55, .18 + rr.uniform(0, .1)), ss, bevel=0.03)
    geo.box((-1.1, .1, .8), (.55, .9, 1.0), M('hole'), bevel=0.0)
    geo.box((-1.1, .1, 1.35), (.6, .96, .12), ss, bevel=0.04)
    # postes de madeira dianteiros + cumeeira + toldo listrado em duas águas (com caimento)
    for x, y in ((1.15, 1.15), (1.15, -.6), (-.3, 1.15)):
        geo.box((x, y, 1.15), (.16, .16, 2.3), mwd, bevel=0.03)
        geo.box((x, y, .06), (.3, .3, .12), mo, bevel=0.03)
    geo.beam((-.7, -.7, 2.35), (1.15, 1.15, 2.3), .14, .14, mwd, bevel=0.02)
    geo.beam((-.7, -.7, 2.35), (1.15, -.6, 2.3), .12, .12, mwd, bevel=0.02)
    geo.beam((-.7, -.7, 2.35), (-.3, 1.15, 2.3), .12, .12, mwd, bevel=0.02)
    parts.cloth_sheet((-1.2, -1.2, 2.5), (1.5, -.8, 2.05), (-.4, 1.45, 2.05), (1.5, 1.45, 1.85), M('stripe_amber'), nu=16, nv=10, sag=.22, folds=.09, fold_n=6, name='canopy')
    parts.rope((1.5, 1.45, 1.9), (2.0, 1.85, .1), .05, .018, M('rope'))
    parts.rope((1.5, -.8, 2.05), (2.05, -1.2, .1), .05, .018, M('rope'))
    geo.cyl((2.0, 1.85, 0), .07, .16, mwd, sides=6)
    # cristais de âmbar sobre pedra + barris, caixas, mesa com potes
    parts.boulder((-.2, -.3, 0), .5, M('rock_sand'), 5, squash=.6)
    for i, (dx, dy, h) in enumerate(((0, 0, .55), (.16, .1, .38), (-.14, .12, .34), (.05, -.16, .3))):
        geo.cyl((-.2 + dx, -.3 + dy, .28), .1, h, M('amber'), sides=6, r2=.015)
    geo.cyl((.65, -.2, 0), .28, .7, M('wood_old'), sides=14, r2=.25)
    geo.cyl((.65, -.2, .65), .27, .05, M('iron'), sides=14)
    geo.cyl((1.0, .2, 0), .24, .6, M('wood_old'), sides=14, r2=.22)
    geo.box((.55, .55, .22), (.55, .45, .44), mo, rot=(0, 0, 20), bevel=0.03)
    geo.box((.65, .5, .55), (.36, .34, .3), mo, rot=(0, 0, -15), bevel=0.03)
    geo.box((-.1, 1.0, .55), (1.0, .5, .08), mw, bevel=0.02)
    for lx in (-.5, .3):
        geo.box((lx, 1.2, .27), (.06, .06, .54), mwd, bevel=0.01)
    for i, c in enumerate(('#c8641e', '#5a8a3a', '#a03030')):
        geo.cyl((-.4 + i * .3, 1.0, .59), .09, .16, mats.flat('pot%d' % i, c, rough=.6, bevel_wear=0), sides=10, r2=.07)
    # lampião e bandeira; areia acumulada e ossos/cactos ao redor
    geo.box((1.15, 1.15, 1.9), (.18, .18, .26), M('glass'), bevel=0.02)
    geo.cyl_between((1.15, 1.15, 2.28), (1.15, 1.15, 2.03), .012, M('iron'), sides=4)
    geo.cyl((-1.1, -1.05, 1.85), .03, 1.1, mwd, sides=6)
    parts.flag(-1.1, -1.05, 2.7, .8, .45, M('cloth_red'), phase=.5)
    parts.rubble(0, 0, 2.05, 12, M('rock_sand'), seed=7, rmin=.12, rmax=.3)
    parts.grass_tufts(1.5, -1.6, 1.0, 6, M('leaf_dry'), seed=3)
    parts.grass_tufts(-1.6, 1.5, 1.0, 6, M('leaf_dry'), seed=4)


# ------------------------------------------------------------------ abrigo da geada (cabana de toras com neve)
def log_wall(x0, y0, x1, y1, z0, rows, r, mat, seed=0):
    a, b = Vector((x0, y0, 0)), Vector((x1, y1, 0))
    rr = random.Random(seed)
    for i in range(rows):
        z = z0 + r + i * r * 1.85
        off = rr.uniform(-.02, .02)
        e0 = a + (b - a).normalized() * (-.16 if i % 2 == 0 else -.28)
        e1 = b + (b - a).normalized() * (.16 if i % 2 == 0 else .28)
        geo.cyl_between((e0.x, e0.y, z + off), (e1.x, e1.y, z + off), r, mat, sides=10)


@landmark('str_lodge_ice', group='city', folder='structures', size=(440, 400), origin=(220, 310), tags=('estrutura', 'abrigo', 'gelo'), footprint=52, coll=(2.7, 2.3), samples=24)
def lodge_ice(f):
    ml, mw, mwd = M('wood_old'), M('wood'), M('wood_dark')
    rr = random.Random(522)
    logm = M('bark_log')
    hx, hy = 1.35, 1.1
    geo.box((0, 0, .1), (hx * 2 + .3, hy * 2 + .3, .2), M('stone_frost'), bevel=0.05)
    rows = 6
    for (x0, y0, x1, y1, s) in ((-hx, -hy, hx, -hy, 1), (-hx, hy, hx, hy, 2), (-hx, -hy, -hx, hy, 3), (hx, -hy, hx, hy, 4)):
        log_wall(x0, y0, x1, y1, .2, rows, .13, logm, seed=s)
    # frontão de tábuas e telhado de tábuas com neve espessa + biqueiras
    zt = .2 + rows * .13 * 1.85 + .1
    geo.roof_gable(0, 0, zt, hx * 2, hy * 2, 1.15, M('roof_snow'), overhang=.3, ridge_axis='x', thickness=.14)
    for sgn in (-1, 1):
        geo.beam((-hx - .3, sgn * (hy + .3), zt), (hx + .3, sgn * (hy + .3), zt), .12, .12, mwd, bevel=0.02)
    geo.beam((-hx - .3, 0, zt + 1.15), (hx + .3, 0, zt + 1.15), .16, .14, mwd, bevel=0.02)
    # neve acumulada no telhado (camada por cima seguindo a água) e beiral com pingentes
    for sgn in (-1, 1):
        parts.cloth_sheet((-hx - .35, sgn * (hy + .38), zt + .1), (hx + .35, sgn * (hy + .38), zt + .1), (-hx - .35, 0, zt + 1.28), (hx + .35, 0, zt + 1.28), M('snow_ground'), nu=14, nv=6, sag=0, folds=.06, fold_n=7, thickness=.13, name='snowroof')
    parts.icicles(-hx - .2, hy + .3, hx + .2, hy + .3, zt + .05, 9, M('glass_ice'), 3)
    parts.icicles(hx + .3, -hy * .8, hx + .3, hy * .8, zt + .05, 5, M('glass_ice'), 4)
    for sgn in (-1, 1):
        tri = [(sgn * hx, -hy - .02, zt), (sgn * hx, hy + .02, zt), (sgn * hx, 0, zt + 1.12)]
        geo.mesh_from(tri, [(0, 1, 2)], mw, 'gable').modifiers.new('sol', 'SOLIDIFY').thickness = .1
    # porta com pele, janela acesa com veneziana, chaminé de pedra com fumaça
    geo.box((0, hy + .05, .85), (.8, .12, 1.3), mwd, bevel=0.03)
    geo.box((0, hy + .12, .8), (.62, .06, 1.15), mw, bevel=0.02)
    geo.box((.6, hy + .1, 1.08), (.5, .08, .46), M('glass'), bevel=0.02)
    geo.box((.9, hy + .11, 1.08), (.12, .1, .5), mwd, bevel=0.01)
    geo.box((-.85, -.2, zt + .95), (.5, .5, 1.6), M('stone_frost'), bevel=0.05)
    geo.box((-.85, -.2, zt + 1.78), (.6, .6, .12), M('stone_frost'), bevel=0.03)
    for i in range(4):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.12 + i * .05)
        o = bpy.context.object
        o.location = (-.85 + i * .06, -.2 + i * .1, zt + 2.05 + i * .3)
        o.data.materials.append(mats.flat('smoke%d' % i, '#cfd6e6', rough=1.0, spec=0, bevel_wear=0))
    # lenha empilhada, peles, trenó, lampião e montes de neve
    for row in range(3):
        for i in range(4 - row):
            geo.cyl_between((-1.6 + i * .27 + row * .13, hy + .35, .13 + row * .22), (-1.6 + i * .27 + row * .13, hy + .35 + .9, .13 + row * .22), .12, M('bark_log'), sides=8)
    geo.box((1.05, hy + .09, 1.4), (.4, .04, .55), mats.flat('pelt', '#8a6a4a', rough=1.0, bevel_wear=0), bevel=0.01)
    for i, (x, y, r) in enumerate(((1.7, 1.2, .35), (-1.7, -1.1, .4), (1.8, -.8, .3), (-1.2, 1.8, .3), (.4, 1.75, .25))):
        parts.boulder((x, y, 0), r, M('snow_ground'), 30 + i, squash=.5, detail=1)
    parts.rubble(0, 0, 1.9, 8, M('rock_snow'), seed=8, rmin=.12, rmax=.26)


# ------------------------------------------------------------------ abrigo de madeira (estrada)
@landmark('str_shelter_wood', group='city', folder='structures', size=(340, 300), origin=(170, 230), tags=('estrutura', 'abrigo', 'estrada'), footprint=36, coll=(1.9, 1.6), samples=24)
def shelter_wood(f):
    mwd, mw, mo = M('wood_dark'), M('wood'), M('wood_old')
    for x, y, h in ((-.85, -.6, 1.9), (.85, -.6, 1.9), (-.85, .6, 1.25), (.85, .6, 1.25)):
        geo.box((x, y, h / 2), (.16, .16, h), mwd, bevel=0.03)
    geo.beam((-.95, -.6, 1.9), (-.95, .6, 1.27), .14, .12, mwd, bevel=0.02)
    geo.beam((.95, -.6, 1.9), (.95, .6, 1.27), .14, .12, mwd, bevel=0.02)
    # telhado inclinado de tábuas + telhas, com beirais
    parts.cloth_sheet((-1.15, -.75, 2.0), (1.15, -.75, 2.0), (-1.15, .85, 1.3), (1.15, .85, 1.3), M('roof_red'), nu=8, nv=6, sag=0, folds=0, thickness=.12, name='lean_roof')
    for i in range(6):
        geo.beam((-1.1, -.7 + i * .3, 2.0 - i * .13 - .08), (1.1, -.7 + i * .3, 2.0 - i * .13 - .08), .07, .06, mwd, bevel=0.01)
    parts.plank_wall((-.85, -.62), (.85, -.62), .1, 1.85, mo, seed=3)
    geo.box((0, -.15, .16), (1.5, .8, .2), M('hay'), rot=(0, 0, 4), bevel=0.06)
    geo.cyl((.95, .35, 0), .27, .55, mo, sides=14, r2=.24)
    geo.box((-.5, .4, .12), (.4, .3, .24), mo, rot=(0, 0, 15), bevel=0.03)
    geo.cyl_between((-.8, .55, 1.15), (-.8, .55, .9), .012, M('iron'), sides=4)
    geo.box((-.8, .55, .78), (.14, .14, .2), M('glass'), bevel=0.02)
    parts.grass_tufts(0, 0, 1.6, 14, M('grass'), seed=5)
    parts.flowers(0, 0, 1.6, 7, seed=6)
    parts.rubble(0, 0, 1.4, 6, M('rock'), seed=4)


# ------------------------------------------------------------------ santuário do vale (animado)
@landmark('str_shrine_stone', group='city', folder='structures', size=(360, 400), origin=(180, 310), frames=4, tags=('estrutura', 'santuario', 'altar', 'animado'), footprint=40, coll=(1.9, 1.9), samples=24)
def shrine_stone(f):
    ss, sm = M('stone'), M('stone')
    rr = random.Random(531)
    # degraus circulares e plataforma
    geo.cyl((0, 0, 0), 1.75, .16, ss, sides=12, r2=1.7, bevel=0.03)
    geo.cyl((0, 0, .16), 1.4, .16, ss, sides=12, r2=1.35, bevel=0.03)
    geo.cyl((0, 0, .32), 1.05, .1, M('stone_dark'), sides=12, r2=1.0, bevel=0.02)
    # 4 pilares esculpidos (base, fuste facetado com sulcos, capitel) — um deles quebrado
    for k, (x, y) in enumerate(((.95, .95), (.95, -.95), (-.95, -.95), (-.95, .95))):
        h = 1.6 if k != 2 else 1.0
        geo.box((x, y, .48), (.42, .42, .16), ss, bevel=0.04)
        geo.cyl((x, y, .56), .15, h, ss, sides=8, r2=.12, bevel=0.02)
        for zz in (.86, 1.3):
            if zz < .56 + h - .1:
                geo.cyl((x, y, zz), .17, .05, ss, sides=8)
        if k != 2:
            geo.box((x, y, .56 + h + .05), (.4, .4, .12), ss, bevel=0.04)
            geo.box((x, y, .56 + h + .15), (.3, .3, .1), ss, bevel=0.03)
        else:
            parts.boulder((x + .3, y - .2, 0), .25, ss, 9, squash=.7)
            parts.boulder((x - .1, y + .35, 0), .18, ss, 10, squash=.7)
    # arquitraves entre pilares
    for (a, b) in (((.95, .95), (.95, -.95)), ((-.95, .95), (.95, .95))):
        geo.beam((a[0], a[1], 2.28), (b[0], b[1], 2.28), .2, .18, ss, bevel=0.03)
    # altar central com cristal pulsante e runas
    geo.box((0, 0, .6), (.8, .8, .5), M('stone_dark'), bevel=0.05)
    geo.box((0, 0, .9), (.95, .95, .12), ss, bevel=0.04)
    pulse = .5 + .5 * math.sin(2 * math.pi * f / 4)
    cm = mats.flat('cryst%d' % f, '#5ab8ff', rough=.12, spec=.9, emission='#3a9aff', emission_strength=2.0 + pulse * 3.0, bevel_wear=0)
    for (dx, dy, h, tilt) in ((0, 0, .95, 0), (.18, .1, .55, 12), (-.16, .12, .5, -14), (.05, -.2, .45, 8)):
        geo.cyl_between((dx * .3, dy * .3, .96), (dx + tilt * .004, dy, .96 + h), .12 if h > .6 else .09, cm, sides=6, r2=.012)
    for i in range(6):
        ph = (f / 4 + i / 6) % 1.0
        a = i * 1.05 + f * .3
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.035)
        o = bpy.context.object
        o.location = (math.cos(a) * .55, math.sin(a) * .55, 1.0 + ph * 1.1)
        o.data.materials.append(M('rune'))
    for k in range(4):
        a = math.radians(45 + 90 * k)
    geo.box((.42, .0, .62), (.02, .3, .16), M('rune'), bevel=0)
    geo.box((0, .42, .62), (.3, .02, .16), M('rune'), bevel=0)
    # raízes, hera, flores e musgo
    parts.ivy(.95, .95, .95, -.95, .6, 1.9, M('leaf'), seed=3, n=16)
    parts.ivy(-.95, -.95, -.95, .95, .6, 1.5, M('leaf'), seed=4, n=10)
    parts.grass_tufts(0, 0, 1.9, 24, M('grass'), seed=6)
    parts.flowers(0, 0, 1.9, 14, seed=8, colors=('#8ab4ff', '#f6f0d8', '#c8a0ff'))
    parts.rubble(0, 0, 1.85, 10, M('rock'), seed=11, rmin=.1, rmax=.26)


# ------------------------------------------------------------------ cais e barcos
def dock(length, axis):
    mw, mwd, mo = M('wood'), M('wood_dark'), M('wood_old')
    rr = random.Random(541)
    w = 1.5
    n = int(length / .3)
    for i in range(n):
        u = -length / 2 + (i + .5) * length / n
        wid = .27 + rr.uniform(-.015, .015)
        ln = w - rr.uniform(0, .1)
        cx, cy = (u, 0) if axis == 'a' else (0, u)
        s = (wid, ln, .1) if axis == 'a' else (ln, wid, .1)
        geo.box((cx, cy, .52 + rr.uniform(-.005, .01)), s, mw if i % 2 else M('wood_y'), bevel=0.012)
    for sgn in (-1, 1):
        c = (0, sgn * .58, .4) if axis == 'a' else (sgn * .58, 0, .4)
        s = (length, .12, .14) if axis == 'a' else (.12, length, .14)
        geo.box(c, s, mwd, bevel=0.02)
    k = int(length / 1.1) + 1
    for i in range(k):
        u = -length / 2 + .12 + i * (length - .24) / max(1, k - 1)
        for sgn in (-1, 1):
            x, y = (u, sgn * .68) if axis == 'a' else (sgn * .68, u)
            geo.cyl((x, y, -.35), .1, 1.25 + rr.uniform(0, .1), mwd, sides=8, r2=.09)
            geo.cyl((x, y, .9), .105, .05, M('wood_y'), sides=8)
            geo.cyl((x, y, .55), .112, .05, M('rope'), sides=8)
            geo.cyl((x, y, .62), .112, .04, M('rope'), sides=8)


@landmark('str_dock_a', group='city', folder='structures', size=(360, 230), origin=(180, 130), tags=('estrutura', 'cais', 'agua'), footprint=30, coll=(3.2, 1.4), samples=24)
def dock_a(f):
    dock(3.2, 'a')


@landmark('str_dock_b', group='city', folder='structures', size=(360, 230), origin=(180, 130), tags=('estrutura', 'cais', 'agua'), footprint=30, coll=(1.4, 3.2), samples=24)
def dock_b(f):
    dock(3.2, 'b')


@landmark('str_dock_end', group='city', folder='structures', size=(300, 280), origin=(150, 190), tags=('estrutura', 'cais', 'lampiao'), footprint=24, coll=(1.7, 1.7), samples=24)
def dock_end(f):
    mw, mwd, mo = M('wood'), M('wood_dark'), M('wood_old')
    for i in range(5):
        geo.box((-.7 + i * .35, 0, .5), (.32, 1.6, .1), mw if i % 2 else M('wood_y'), bevel=0.012)
    for x in (-.8, .8):
        for y in (-.75, .75):
            geo.cyl((x, y, -.35), .1, 1.25, mwd, sides=8, r2=.09)
            geo.cyl((x, y, .55), .112, .05, M('rope'), sides=8)
    geo.cyl((.72, .72, .55), .06, 1.55, mwd, sides=6, r2=.05)
    geo.beam((.72, .72, 2.05), (.4, .72, 2.05), .05, .05, mwd, bevel=0.01)
    geo.cyl_between((.4, .72, 2.05), (.4, .72, 1.85), .012, M('iron'), sides=4)
    geo.box((.4, .72, 1.7), (.16, .16, .22), M('glass'), bevel=0.02)
    geo.cyl((-.6, -.4, .55), .16, .3, mo, sides=14)
    for k in range(4):
        geo.cyl((-.6, -.4, .55 + k * .06), .17 - k * .02, .05, M('rope'), sides=12)
    geo.box((.1, -.55, .72), (.5, .4, .3), mo, rot=(0, 0, 25), bevel=0.03)
    geo.cyl((-.5, .55, .55), .22, .45, mo, sides=12, r2=.2)


def hull(length, beam, depth, mat, bob=0.0, pitch=0.0, name='hull'):
    """Casco por seções: quilha -> borda; proa e popa afiladas com tosamento."""
    nu, nv = 20, 8
    verts, faces = [], []
    for i in range(nu + 1):
        u = i / nu
        x = (u - .5) * length
        taper = (1 - abs(2 * u - 1) ** 2.4)
        sheer = .12 * (abs(2 * u - 1) ** 2.2)
        for j in range(nv + 1):
            t = j / nv
            ang = t * math.pi / 2
            y = math.sin(ang) * beam * .5 * (.25 + .75 * taper) * (1 if True else 1)
            for side in (1,):
                pass
            z = depth - math.cos(ang) * depth + sheer * 0 + .0
            verts.append((x, y, z * (.55 + .45 * taper) + sheer + bob + x * pitch))
    for i in range(nu):
        for j in range(nv):
            a = i * (nv + 1) + j
            faces.append((a, a + nv + 1, a + nv + 2, a + 1))
    # espelho (lado oposto)
    n1 = len(verts)
    verts2 = [(v[0], -v[1], v[2]) for v in verts]
    verts += verts2
    for i in range(nu):
        for j in range(nv):
            a = n1 + i * (nv + 1) + j
            faces.append((a, a + 1, a + nv + 2, a + nv + 1))
    o = geo.mesh_from(verts, faces, mat, name, smooth=True)
    sol = o.modifiers.new('sol', 'SOLIDIFY')
    sol.thickness = .06
    return o


@landmark('str_boat_row', group='city', folder='structures', size=(320, 240), origin=(160, 140), frames=4, tags=('estrutura', 'barco', 'agua', 'animado'), footprint=26, coll=(2.0, 1.0), samples=24)
def boat_row(f):
    bob = .035 * math.sin(f / 4 * 6.283)
    pitch = .03 * math.cos(f / 4 * 6.283)
    hm = M('hull_wood')
    hull(2.5, 1.0, .5, hm, bob + .1, pitch)
    for x in (-.55, .1, .75):
        geo.box((x, 0, .5 + bob + x * pitch), (.16, .95, .05), M('wood_dark'), bevel=0.01)
    for sgn in (-1, 1):
        geo.beam((.1, sgn * .35, .58 + bob), (.35, sgn * 1.35, .75 + bob), .06, .05, M('wood_dark'), bevel=0.01)
        geo.box((.42, sgn * 1.42, .78 + bob), (.34, .09, .02), M('wood'), rot=(0, 0, 25 * sgn), bevel=0.01)
    geo.cyl((-.85, 0, .5 + bob), .17, .06, M('rope'), sides=12)
    geo.box((-1.05, 0, .62 + bob), (.16, .5, .14), M('wood_old'), bevel=0.02)


@landmark('str_boat_sail', group='city', folder='structures', size=(400, 460), origin=(200, 230), frames=4, tags=('estrutura', 'barco', 'agua', 'animado'), footprint=34, coll=(2.7, 1.2), samples=24)
def boat_sail(f):
    bob = .045 * math.sin(f / 4 * 6.283)
    pitch = .04 * math.cos(f / 4 * 6.283)
    hull(3.2, 1.25, .65, M('hull_blue'), bob + .12, pitch)
    geo.box((0, 0, .72 + bob), (1.4, 1.05, .05), M('wood'), bevel=0.01)
    geo.cyl((.35, 0, .72 + bob), .06, 3.0, M('wood_dark'), sides=8, r2=.04)
    boom_z = 1.05 + bob
    geo.beam((.35, 0, boom_z), (-1.1, .1, boom_z + .05), .06, .06, M('wood_dark'), bevel=0.01)
    billow = .16 + .05 * math.sin(f / 4 * 6.283 + 1)
    # vela latina: triângulo com barriga
    verts, faces = [], []
    n = 10
    for i in range(n + 1):
        for j in range(n + 1 - i):
            u, v = i / n, j / n
            px = .42 - (u * 1.55)
            pz = boom_z + .05 + v * (2.4 - u * 2.0)
            py = .02 + .1 * u + billow * math.sin((u + v) * 1.5) * (1 - u * .3) * min(1, v * 3 + .2)
            verts.append((px, py, pz))
    idx = {}
    k = 0
    for i in range(n + 1):
        for j in range(n + 1 - i):
            idx[(i, j)] = k
            k += 1
    for i in range(n):
        for j in range(n - i):
            faces.append((idx[(i, j)], idx[(i + 1, j)], idx[(i, j + 1)]))
            if (i + 1, j + 1) in idx and j + 1 <= n - i - 1:
                faces.append((idx[(i + 1, j)], idx[(i + 1, j + 1)], idx[(i, j + 1)]))
    sail = geo.mesh_from(verts, faces, M('sail'), 'sail', smooth=True)
    sail.modifiers.new('sol', 'SOLIDIFY').thickness = .03
    for (x, y, z) in ((1.35, .0, .85), (-1.3, .3, .8)):
        pass
    parts.rope((.35, 0, 3.4), (1.4, .1, .82 + bob), .04, .015, M('rope'))
    parts.rope((.35, 0, 3.4), (-1.4, .0, .82 + bob), .04, .015, M('rope'))
    geo.cyl_between((.35, 0, 3.45), (.35, 0, 3.75), .025, M('wood_dark'), sides=6)
    parts.flag(.35, 0, 3.6, .55, .3, M('cloth_red'), phase=f * .8, dirv=(-0.7071, 0.7071))
    geo.box((-1.15, 0, .86 + bob), (.7, .8, .5), M('wood_old'), bevel=0.03)
    geo.box((-1.15, 0, 1.15 + bob), (.8, .9, .08), M('wood'), bevel=0.02)
    geo.box((1.0, .3, .8 + bob), (.4, .4, .3), M('wood_old'), rot=(0, 0, 20), bevel=0.03)


# ------------------------------------------------------------------ celeiro, plantações e espantalho
@landmark('str_barn', group='city', folder='structures', size=(500, 460), origin=(250, 360), tags=('estrutura', 'celeiro', 'fazenda'), footprint=60, coll=(3.4, 2.5), samples=24)
def barn(f):
    mo, mwd, mw = M('wood_old'), M('wood_dark'), M('wood')
    red = M('barn_red')
    hx, hy, H = 1.7, 1.25, 1.9
    geo.box((0, 0, .1), (hx * 2 + .3, hy * 2 + .3, .2), M('stone'), bevel=0.05)
    for sgn in (-1, 1):
        parts.plank_wall((-hx, sgn * hy), (hx, sgn * hy), .2, H, red, seed=3 + sgn)
        parts.plank_wall((sgn * hx, -hy), (sgn * hx, hy), .2, H, red, seed=6 + sgn)
    for sx in (-1, 1):
        for sy in (-1, 1):
            geo.box((sx * hx, sy * hy, H / 2 + .1), (.2, .2, H), mwd, bevel=0.03)
    # empena frontal (y+) com portão duplo em X, porta do sótão de feno, viga com polia
    zt = H
    geo.roof_gable(0, 0, zt, hx * 2, hy * 2, 1.25, M('roof_red'), overhang=.3, ridge_axis='x', thickness=.14)
    # empenas triangulares (madeira) nas extremidades x±
    for sgn in (-1, 1):
        tri = [(sgn * hx, -hy, zt), (sgn * hx, hy, zt), (sgn * hx, 0, zt + 1.22)]
        geo.mesh_from(tri, [(0, 1, 2)], red, 'gable').modifiers.new('sol', 'SOLIDIFY').thickness = .09
    geo.beam((-hx - .3, 0, zt + 1.25), (hx + .3, 0, zt + 1.25), .16, .14, mwd, bevel=0.02)
    # portões na face y+ (voltada ao jogador): folhas e travessas em X
    for sx in (-1, 1):
        geo.box((sx * .5, hy + .07, .95), (.95, .08, 1.5), mw, bevel=0.02)
        geo.beam((sx * .05, hy + .12, .3), (sx * .95, hy + .12, 1.65), .09, .05, mwd, bevel=0.01)
        geo.beam((sx * .95, hy + .12, .3), (sx * .05, hy + .12, 1.65), .09, .05, mwd, bevel=0.01)
    geo.box((0, hy + .12, 1.75), (2.1, .1, .12), mwd, bevel=0.02)
    geo.box((1.0, hy + .09, 2.7), (.6, .08, .7), M('hole'), bevel=0)
    geo.box((1.0, hy + .13, 2.7), (.7, .05, .06), mwd, bevel=0.01)
    geo.beam((1.0, hy + .1, zt + .95), (1.0, hy + .5, zt + .95), .07, .07, mwd, bevel=0.01)
    geo.cyl((1.0, hy + .5, zt + .8), .06, .03, M('iron'), sides=10, rot=(90, 0, 0))
    # fardos, carroça de feno, roda, lampião
    for i, (x, y, z) in enumerate(((-.9, hy + .5, 0), (-.3, hy + .55, 0), (-.6, hy + .5, .38), (1.85, .3, 0))):
        geo.box((x, y, z + .18), (.62, .42, .36), M('hay'), rot=(0, 0, 8 * i), bevel=0.06)
    geo.cyl_between((-1.3, hy + .1, 1.6), (-1.3, hy + .1, 1.3), .012, M('iron'), sides=4)
    geo.box((-1.3, hy + .1, 1.15), (.14, .14, .2), M('glass'), bevel=0.02)
    parts.grass_tufts(0, 0, 2.6, 26, M('grass'), seed=7)
    parts.flowers(0, 0, 2.6, 10, seed=8)
    parts.rubble(0, 0, 2.3, 8, M('rock'), seed=9)


def wheat_plot(kind):
    rr = random.Random(562)
    mwd, mo = M('wood_dark'), M('wood_old')
    geo.box((0, 0, .06), (3.0, 3.0, .12), mats.ground('soil', ('#2a1a10', '#4a2e1a', '#6a4426', '#8a5c34'), scale=6.0), bevel=0.03)
    for sgn in (-1, 1):
        geo.box((sgn * 1.55, 0, .2), (.12, 3.2, .26), mo, bevel=0.02)
        geo.box((0, sgn * 1.55, .2), (3.2, .12, .26), mo, bevel=0.02)
    plant = {'wheat': M('wheat'), 'corn': M('leaf'), 'cabbage': M('cabbage')}[kind]
    for r in range(5):
        y = -1.15 + r * .57
        for i in range(9):
            x = -1.2 + i * .3 + rr.uniform(-.04, .04)
            yy = y + rr.uniform(-.05, .05)
            if kind == 'wheat':
                for s in range(4):
                    dx, dy = rr.uniform(-.07, .07), rr.uniform(-.07, .07)
                    top = (x + dx * 1.6, yy + dy * 1.6, .78 + rr.uniform(-.06, .1))
                    geo.cyl_between((x + dx * .3, yy + dy * .3, .14), top, .014, M('wheat_stalk'), sides=4, r2=.008)
                    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.05)
                    o = bpy.context.object
                    o.scale = (.6, .6, 2.0)
                    o.location = (top[0], top[1], top[2] + .05)
                    o.data.materials.append(plant)
            elif kind == 'corn':
                h = 1.0 + rr.uniform(-.1, .2)
                geo.cyl_between((x, yy, .14), (x, yy, h), .035, M('leaf'), sides=5, r2=.02)
                for k in range(3):
                    a = rr.uniform(0, 6.28)
                    geo.cyl_between((x, yy, .4 + k * .25), (x + math.cos(a) * .28, yy + math.sin(a) * .28, .3 + k * .25), .03, M('leaf'), sides=4, r2=.004)
                bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.05)
                o = bpy.context.object
                o.scale = (.7, .7, 1.7)
                o.location = (x + .05, yy, .65)
                o.data.materials.append(M('corn_gold'))
            else:
                for k in range(5):
                    a = k * 1.25 + rr.uniform(-.2, .2)
                    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.13 - k * .012)
                    o = bpy.context.object
                    o.scale = (1.0, 1.0, .5)
                    o.location = (x + math.cos(a) * .06, yy + math.sin(a) * .06, .2 + k * .045)
                    o.rotation_euler = (rr.uniform(-.4, .4), rr.uniform(-.4, .4), a)
                    o.data.materials.append(plant if k % 2 else M('leaf'))


for _kind in ('wheat', 'corn', 'cabbage'):
    landmark('str_crop_%s' % _kind, group='city', folder='structures', size=(380, 240), origin=(190, 120), tags=('estrutura', 'plantacao', 'fazenda', _kind), footprint=40, samples=24)(
        (lambda k: (lambda f: wheat_plot(k)))(_kind))


@landmark('str_scarecrow', group='city', folder='structures', size=(180, 280), origin=(90, 220), tags=('estrutura', 'fazenda', 'espantalho'), blocks=6, footprint=10, samples=24)
def scarecrow(f):
    mwd, mo = M('wood_dark'), M('wood_old')
    geo.cyl_between((0, 0, 0), (0, 0, 1.75), .05, mwd, sides=6)
    geo.cyl_between((0, -.75, 1.25), (0, .75, 1.3), .04, mwd, sides=6)
    geo.box((0, 0, 1.0), (.4, .55, .7), M('cloth_blue'), bevel=0.06)
    for sgn in (-1, 1):
        geo.box((0, sgn * .55, 1.28), (.34, .48, .16), M('cloth_blue'), bevel=0.05)
        for k in range(5):
            geo.cyl_between((0, sgn * (.85 + k * .02), 1.27), ((k - 2) * .05, sgn * (1.0 + k * .02), 1.05), .012, M('hay'), sides=4, r2=.004)
        for k in range(4):
            geo.cyl_between((0, sgn * .12, .68), ((k - 1.5) * .05, sgn * .14, .38), .014, M('hay'), sides=4, r2=.004)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=.2, location=(0, 0, 1.85))
    o = bpy.context.object
    o.data.materials.append(M('hay'))
    for p in o.data.polygons:
        p.use_smooth = True
    geo.cyl((0, 0, 1.98), .3, .03, M('straw_hat'), sides=16)
    geo.cyl((0, 0, 1.98), .17, .2, M('straw_hat'), sides=14, r2=.13)
    for sgn in (-1, 1):
        geo.box((.17, sgn * .07, 1.9), (.03, .05, .05), M('hole'), bevel=0)
    geo.cyl((0, 0, 0), .05, .05, M('rope'), sides=8)
    parts.grass_tufts(0, 0, .5, 8, M('grass'), seed=3)
