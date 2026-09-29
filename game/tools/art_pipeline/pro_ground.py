"""Decalques de chão (Blender, 30 px/u = pixels de jogo): tufos, flores, seixos, rachaduras, folhas, neve, areia, gelo.

Cada id é uma folha de N variantes (frames). O bake do terreno (`tools/terrain/bake_ground.py`) espalha esses decalques por bioma
com campos de densidade (agrupamentos + áreas livres), já com a luz upper-left e sombra de contato pontilhada.
"""
import math
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import bpy
from vk import geo, mats, parts
from vk.parts import M
from pro_landmarks import landmark

SCALE = 30.0
SIZE = (72, 56)
ORIGIN = (36, 38)
NV = 6          # variantes por folha


def dec(id, tags, size=SIZE, origin=ORIGIN, frames=NV, samples=16, outline=0):
    return landmark(id, group='terrain', folder='decals', size=size, origin=origin, frames=frames, tags=('decalque',) + tuple(tags), footprint=0, samples=samples,
                    scale=SCALE, pad=0, colors=48, outline=outline, draw_scale=1.0, exposure=0.1)


GROUND_GRASS = None


def gmat(kind='grass'):
    cols = {'grass': ('#1f6f2e', '#2f9638', '#4fba43', '#83d64b', '#b5e965'), 'dry': ('#8a6a26', '#b48a2c', '#d4aa3c', '#e8c860', '#f8e690'),
            'frost': ('#3a6a6a', '#5a9a8a', '#9ac8c0', '#d8eef0', '#ffffff')}[kind]
    return mats.foliage('dg_' + kind, cols)


def blade(x, y, h, lean, ang, r, mat):
    dx, dy = math.cos(ang) * lean, math.sin(ang) * lean
    mid = (x + dx * .45, y + dy * .45, h * .6)
    geo.cyl_between((x, y, 0), mid, r, mat, sides=4, r2=r * .75)
    geo.cyl_between(mid, (x + dx, y + dy, h), r * .75, mat, sides=4, r2=r * .05)


def tufts(f, mat, seed, n=(9, 15), h=(.32, .7), spread=.36, lean=(.05, .28), r=.05, base_mat=None):
    rr = random.Random(seed * 101 + f * 7)
    if base_mat is not None:
        parts.boulder((0, 0, -.02), spread * .55, base_mat, seed + f, squash=.25, detail=1)
    for i in range(rr.randint(*n)):
        a = rr.uniform(0, 6.283)
        d = spread * math.sqrt(rr.random())
        blade(math.cos(a) * d, math.sin(a) * d, rr.uniform(*h), rr.uniform(*lean), a + rr.uniform(-.8, .8), r * rr.uniform(.8, 1.3), mat)


@dec('ter_dec_grass', ('relva',))
def grass(f):
    tufts(f, gmat('grass'), 1, n=(6, 10), h=(.22, .5), spread=.3, r=.04)


@dec('ter_dec_grass_tall', ('relva', 'alta'))
def grass_tall(f):
    tufts(f, gmat('grass'), 2, n=(7, 11), h=(.4, .8), spread=.26, lean=(.08, .3), r=.04)


@dec('ter_dec_grass_dry', ('seca', 'campos', 'deserto'))
def grass_dry(f):
    tufts(f, gmat('dry'), 3, n=(6, 10), h=(.25, .6), spread=.3, lean=(.1, .3), r=.04)


@dec('ter_dec_grass_frost', ('gelo', 'relva'))
def grass_frost(f):
    tufts(f, gmat('frost'), 4, n=(6, 10), h=(.22, .48), spread=.3, lean=(.05, .22), r=.04)
    rr = random.Random(f + 5)
    for i in range(3):
        parts.boulder((rr.uniform(-.3, .3), rr.uniform(-.25, .25), 0), rr.uniform(.08, .16), M('snow_ground'), 40 + f + i, squash=.5, detail=1)


@dec('ter_dec_flowers', ('flores',))
def flowers(f):
    palette = (('#fff6d8', '#ffd23a'), ('#ff7aa8', '#ffd0e0'), ('#8ab4ff', '#dbe8ff'), ('#ffb35a', '#fff0b0'), ('#c8a0ff', '#f0e0ff'), ('#f6f0d8', '#ff8aa8'))[f % 6]
    rr = random.Random(f * 13 + 6)
    tufts(f, gmat('grass'), 5, n=(4, 7), h=(.2, .4), spread=.28, r=.04)
    fm = [mats.flat('fd%d_%d' % (f, k), c, rough=.7, bevel_wear=0) for k, c in enumerate(palette)]
    for i in range(rr.randint(4, 8)):
        a = rr.uniform(0, 6.283)
        d = .32 * math.sqrt(rr.random())
        x, y = math.cos(a) * d, math.sin(a) * d
        h = rr.uniform(.25, .55)
        geo.cyl_between((x, y, 0), (x + rr.uniform(-.04, .04), y, h), .018, M('grass'), sides=4)
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=rr.uniform(.06, .095), location=(x, y, h))
        bpy.context.object.scale = (1, 1, .7)
        bpy.context.object.data.materials.append(fm[i % 2])
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.03, location=(x, y, h + .04))
        bpy.context.object.data.materials.append(fm[(i + 1) % 2])


@dec('ter_dec_pebbles', ('seixos',))
def pebbles(f):
    rr = random.Random(f * 17 + 7)
    for i in range(rr.randint(3, 6)):
        a = rr.uniform(0, 6.283)
        d = .34 * math.sqrt(rr.random())
        parts.boulder((math.cos(a) * d, math.sin(a) * d, 0), rr.uniform(.06, .16), M('rock'), f * 9 + i, squash=.6, detail=1, rough=.4)
    tufts(f, gmat('grass'), 8, n=(2, 3), h=(.15, .28), spread=.34, r=.04)


@dec('ter_dec_stones_sand', ('seixos', 'deserto'))
def stones_sand(f):
    rr = random.Random(f * 19 + 8)
    for i in range(rr.randint(3, 6)):
        a = rr.uniform(0, 6.283)
        d = .34 * math.sqrt(rr.random())
        parts.boulder((math.cos(a) * d, math.sin(a) * d, 0), rr.uniform(.06, .17), M('rock_sand'), f * 9 + i, squash=.6, detail=1, rough=.4)


@dec('ter_dec_stones_ice', ('seixos', 'gelo'))
def stones_ice(f):
    rr = random.Random(f * 23 + 9)
    for i in range(rr.randint(3, 5)):
        a = rr.uniform(0, 6.283)
        d = .34 * math.sqrt(rr.random())
        parts.boulder((math.cos(a) * d, math.sin(a) * d, 0), rr.uniform(.07, .16), M('rock_ice'), f * 9 + i, squash=.6, detail=1, rough=.4)
    for i in range(3):
        geo.cyl((rr.uniform(-.3, .3), rr.uniform(-.25, .25), 0), .05, rr.uniform(.15, .3), M('glass_ice'), sides=5, r2=.0)


def flat_cracks(f, mat, seed, n=5, span=.7):
    """Rede de rachaduras: polilinhas irregulares finas sobre o chão (z ~ 0.01)."""
    rr = random.Random(seed * 31 + f)
    for i in range(n):
        x, y = rr.uniform(-.25, .25), rr.uniform(-.2, .2)
        ang = rr.uniform(0, 6.283)
        for k in range(rr.randint(3, 6)):
            ang += rr.uniform(-.7, .7)
            L = rr.uniform(.1, span / 3)
            x2, y2 = x + math.cos(ang) * L, y + math.sin(ang) * L
            geo.cyl_between((x, y, .012), (x2, y2, .012), .016, mat, sides=4)
            if rr.random() < .3:
                a2 = ang + rr.choice((-1, 1)) * rr.uniform(.6, 1.2)
                geo.cyl_between((x2, y2, .012), (x2 + math.cos(a2) * L * .6, y2 + math.sin(a2) * L * .6, .012), .016, mat, sides=4)
            x, y = x2, y2


@dec('ter_dec_cracks_dirt', ('rachadura', 'terra', 'campos'), outline=0)
def cracks_dirt(f):
    flat_cracks(f, mats.flat('crack_d', '#20120c', rough=1.0, spec=0, bevel_wear=0), 1)
    parts.rubble(0, 0, .3, 3, M('rock'), seed=f, rmin=.04, rmax=.08, ring=False)


@dec('ter_dec_cracks_sand', ('rachadura', 'deserto'), outline=0)
def cracks_sand(f):
    flat_cracks(f, mats.flat('crack_s', '#5a2c18', rough=1.0, spec=0, bevel_wear=0), 2, n=6)


@dec('ter_dec_cracks_ice', ('rachadura', 'gelo'), outline=0)
def cracks_ice(f):
    flat_cracks(f, mats.flat('crack_i', '#2a5aa0', rough=.3, spec=.4, bevel_wear=0), 3, n=5, span=.9)


@dec('ter_dec_leaves', ('folhas', 'floresta', 'campos'), outline=0)
def leaves(f):
    rr = random.Random(f * 29 + 10)
    cols = ('#c8641e', '#e0a428', '#8a3a1a', '#b0801e', '#5a7a2a')
    ms = [mats.flat('lf%d' % k, c, rough=.8, bevel_wear=0) for k, c in enumerate(cols)]
    for i in range(rr.randint(10, 18)):
        a = rr.uniform(0, 6.283)
        d = .36 * math.sqrt(rr.random())
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=rr.uniform(.05, .09), location=(math.cos(a) * d, math.sin(a) * d, .02))
        o = bpy.context.object
        o.scale = (1, .55, .12)
        o.rotation_euler = (0, 0, rr.uniform(0, 6.28))
        o.data.materials.append(rr.choice(ms))


@dec('ter_dec_mushrooms', ('cogumelos', 'floresta'))
def mushrooms(f):
    rr = random.Random(f * 31 + 11)
    parts.rubble(0, 0, .28, 3, M('rock'), seed=f, rmin=.05, rmax=.1, ring=False)
    for i in range(rr.randint(2, 4)):
        x, y = rr.uniform(-.25, .25), rr.uniform(-.2, .2)
        h = rr.uniform(.14, .26)
        geo.cyl((x, y, 0), .03, h, mats.flat('stem', '#e8dcc6', rough=.7, bevel_wear=0), sides=6)
        bpy.ops.mesh.primitive_uv_sphere_add(radius=rr.uniform(.08, .13), segments=10, ring_count=6, location=(x, y, h))
        o = bpy.context.object
        o.scale = (1, 1, .55)
        o.data.materials.append(mats.flat('cap%d' % (i % 2), ('#d02840', '#c87a3a')[i % 2], rough=.5, spec=.3, bevel_wear=0))
    tufts(f, gmat('grass'), 12, n=(3, 5), h=(.15, .3), spread=.3, r=.04)


@dec('ter_dec_snow_drift', ('neve', 'deriva'), size=(96, 56), origin=(48, 38), outline=0)
def snow_drift(f):
    from pro_nature import dune_mound
    dune_mound(1.0 + .1 * (f % 3), .5, .09 + .02 * (f % 3), 40 + f, mat=mats.ground('snow_flat', ('#a8c0e6', '#c8dcf2', '#e4f0fb', '#f6fbff', '#ffffff'), scale=3.5), ripples=False)


@dec('ter_dec_sand_ripple', ('areia', 'ondulação'), size=(96, 56), origin=(48, 38), outline=0)
def sand_ripple(f):
    from pro_nature import dune_mound
    dune_mound(1.0 + .1 * (f % 3), .5, .09 + .02 * (f % 3), 50 + f, mat=M('sand_ground'), ripples=True)


@dec('ter_dec_bones', ('ossos', 'deserto'))
def bones(f):
    rr = random.Random(f * 37 + 12)
    bm = mats.flat('bone_d', '#efe4c8', rough=.7, bevel_wear=0)
    for i in range(rr.randint(2, 4)):
        x, y = rr.uniform(-.2, .2), rr.uniform(-.15, .15)
        a = rr.uniform(0, 3.14)
        L = rr.uniform(.18, .32)
        geo.cyl_between((x - math.cos(a) * L / 2, y - math.sin(a) * L / 2, .03), (x + math.cos(a) * L / 2, y + math.sin(a) * L / 2, .03), .022, bm, sides=6)
        for s in (-1, 1):
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.038, location=(x + s * math.cos(a) * L / 2, y + s * math.sin(a) * L / 2, .03))
            bpy.context.object.data.materials.append(bm)


@dec('ter_dec_cobble_weeds', ('cidade', 'ervas'), size=(56, 44), origin=(28, 30))
def cobble_weeds(f):
    tufts(f, gmat('grass'), 14, n=(3, 5), h=(.16, .34), spread=.2, r=.035)
    parts.flowers(0, 0, .2, 2, seed=f)


@dec('ter_dec_moss_stone', ('cidade', 'musgo'), size=(56, 44), origin=(28, 30))
def moss_stone(f):
    parts.rubble(0, 0, .18, 4, M('stone'), seed=f, rmin=.06, rmax=.12, ring=False)
    parts.leaf_cluster(0, 0, .06, .16, 6, M('leaf'), f, size=(.05, .08), flat=.4)
