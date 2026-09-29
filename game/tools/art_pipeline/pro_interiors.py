"""Kit modular de interiores (Blender): baias de parede frontais, poste/coluna e portal — arquitetura real com vigas, ombreiras, janelas e luz.

Cada baia tem 2.4 u de largura (144 px de sprite = 72 px no jogo) e é modelada voltada para +x; `rotate_all(45)` a volta para a câmera,
de modo que baias adjacentes emendam em linha horizontal na tela (como o fundo da sala).
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

W_BAY = 2.4
H_WALL = 3.5


def _plaster():
    return mats.flat('int_plaster', '#d4c09a', rough=0.95, spec=0.03, bevel_wear=0.3)


def wall_shell(kind_seed=0, wainscot='wood', plaster='#d4c09a'):
    """Base comum: plinto de pedra, lambri, reboco, montantes e vigas de coroamento."""
    ms = M('stone')
    mw = M('wood')
    mwd = M('wood_dark')
    pl = mats.ground('int_pl', ('#b48c58', '#d0a86c', '#e6c48a', '#f4dca6', '#fff0c4'), scale=3.0, fine=22.0)
    # plinto e lambri
    geo.box((-.12, 0, .22), (.34, W_BAY, .44), ms, bevel=0.03)
    geo.box((-.1, 0, .95), (.22, W_BAY - .18, 1.0), M('wood_y'), bevel=0.02)
    geo.box((-.1, 0, 1.5), (.26, W_BAY - .1, .1), mwd, bevel=0.02)
    # reboco superior
    geo.box((-.12, 0, 2.5), (.2, W_BAY - .1, 2.0), pl, bevel=0.02)
    # montantes laterais e travessas (enxaimel)
    for sgn in (-1, 1):
        geo.box((-.02, sgn * (W_BAY / 2 - .1), H_WALL / 2), (.3, .2, H_WALL), mwd, bevel=0.03)
    geo.box((0, 0, H_WALL - .12), (.36, W_BAY, .26), mwd, bevel=0.03)       # viga de coroamento
    for sgn in (-1, 1):
        geo.beam((-.04, sgn * (W_BAY / 2 - .12), 1.55), (-.04, sgn * (W_BAY / 2 - .55), 2.35), .09, .1, mwd, bevel=0.015)   # mãos-francesas
    return pl


def arch_window(y0, z0, w, h, glow=True):
    mwd, ms = M('wood_dark'), M('stone')
    geo.box((-.02, y0, z0 + h / 2), (.34, w + .3, h + .26), ms, bevel=0.04)          # moldura de pedra
    geo.box((.02, y0, z0 + h / 2), (.2, w, h), M('hole'), bevel=0.0)
    geo.box((.09, y0, z0 + h / 2), (.05, w - .06, h - .06), M('glass'), bevel=0.01)
    for k in range(1, 3):
        geo.box((.12, y0, z0 + h * k / 3), (.04, w - .06, .04), mwd, bevel=0.005)
    geo.box((.12, y0, z0 + h / 2), (.04, .04, h - .06), mwd, bevel=0.005)
    for sgn in (-1, 1):
        geo.box((.17, y0 + sgn * (w / 2 + .12), z0 + h / 2), (.06, .24, h + .1), M('wood'), rot=(0, 0, 0), bevel=0.015)     # venezianas
    geo.box((.2, y0, z0 - .05), (.3, w + .4, .08), ms, bevel=0.02)                       # peitoril
    # vasos com flores no peitoril
    for i, c in enumerate(('#ff7aa8', '#ffd23a', '#f6f0d8')):
        geo.cyl((.22, y0 - .25 + i * .25, z0 - .01), .06, .1, mats.flat('vase%d' % i, '#a8623a', rough=.8, bevel_wear=0), sides=8, r2=.05)
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.07)
        o = bpy.context.object
        o.location = (.22, y0 - .25 + i * .25, z0 + .14)
        o.data.materials.append(mats.flat('flw%d' % i, c, rough=.7, bevel_wear=0))


def hang_lantern(y, z):
    geo.cyl_between((.22, y, H_WALL - .2), (.22, y, z + .3), .01, M('iron'), sides=4)
    geo.box((.22, y, z), (.16, .16, .26), M('glass'), bevel=0.02)
    geo.box((.22, y, z + .16), (.2, .2, .04), M('iron'), bevel=0.01)


def banner(y, z, mat):
    geo.cyl_between((.2, y - .4, z + .6), (.2, y + .4, z + .6), .015, M('gold'), sides=6)
    parts.cloth_sheet((.2, y - .36, z + .58), (.2, y + .36, z + .58), (.2, y - .36, z - .5), (.2, y + .36, z - .5), mat, nu=8, nv=8, sag=0, folds=.05, fold_n=3, thickness=.02, name='banner')


def _finish():
    geo.rotate_all(45)


def _reg(id, builder):
    landmark(id, group='interior', folder='walls', size=(170, 250), origin=(85, 208), tags=('interior', 'parede', 'baia'), footprint=0, samples=24)(builder)


def bay_plain(f):
    wall_shell()
    hang_lantern(-.5, 1.8)
    banner(.5, 2.2, M('cloth_blue'))
    _finish()


def bay_window(f):
    wall_shell()
    arch_window(0, 1.8, .9, 1.25)
    hang_lantern(-.85, 1.9)
    _finish()


def bay_door(f):
    wall_shell()
    mwd, mw, ms = M('wood_dark'), M('wood'), M('stone')
    geo.box((-.02, 0, 1.1), (.4, 1.5, 2.2), ms, bevel=0.05)
    geo.box((.06, 0, 1.0), (.2, 1.06, 2.0), M('hole'), bevel=0)
    geo.box((.1, 0, .98), (.12, .98, 1.95), mw, bevel=0.02)
    for z in (.4, 1.0, 1.6):
        geo.box((.17, 0, z), (.03, .96, .09), M('iron'), bevel=0.005)
    geo.box((.18, .3, 1.0), (.06, .06, .06), M('gold'), bevel=0.01)
    geo.box((.1, 0, 2.15), (.2, 1.3, .22), ms, bevel=0.04)
    hang_lantern(.95, 1.9)
    hang_lantern(-.95, 1.9)
    _finish()


def bay_hearth(f):
    wall_shell()
    ms, mwd = M('stone'), M('wood_dark')
    geo.box((.05, 0, 1.1), (.5, 1.7, 2.2), ms, bevel=0.06)
    geo.box((.2, 0, .6), (.4, 1.0, 1.0), M('hole'), bevel=0)
    fm = mats.emissive('hearth_fire', '#ff9a30', 9.0)
    for (y, h) in ((-.2, .32), (0.0, .45), (.2, .3)):
        parts.geo.cyl((.28, y, .12), .1, h, fm, sides=6, r2=.01)
    geo.box((.2, 0, 1.27), (.5, 1.2, .12), mwd, bevel=0.02)
    geo.box((.22, 0, 1.4), (.3, 1.3, .05), ms, bevel=0.02)
    geo.box((.1, 0, 3.0), (.36, .7, 1.4), ms, bevel=0.05)     # chaminé
    for i, c in enumerate(('#c8641e', '#5a8a3a', '#a03030')):
        geo.cyl((.25, -.4 + i * .4, 1.45), .07, .14, mats.flat('hp%d' % i, c, rough=.6, bevel_wear=0), sides=10, r2=.06)
    hang_lantern(-1.0, 2.0)
    _finish()


def bay_niche(f):
    wall_shell()
    ms, mwd, mw = M('stone'), M('wood_dark'), M('wood')
    geo.box((.02, 0, 2.15), (.34, 1.7, 1.5), ms, bevel=0.05)
    geo.box((.08, 0, 2.15), (.2, 1.5, 1.32), M('hole'), bevel=0)
    for z in (1.85, 2.3):
        geo.box((.16, 0, z), (.22, 1.5, .05), mwd, bevel=0.01)
    rr = random.Random(3)
    for i in range(6):
        y = -.6 + i * .24
        h = .16 + rr.uniform(0, .12)
        c = rr.choice(('#5adf8a', '#ff7aa8', '#7ab4ff', '#ffd23a'))
        geo.cyl((.2, y, 1.88), .05, h, mats.flat('bt%d' % i, c, rough=.25, spec=.7, emission=c, emission_strength=.4, bevel_wear=0), sides=8, r2=.03)
    for i in range(5):
        y = -.6 + i * .27
        geo.box((.2, y, 2.35), (.1, .09, .22 + rr.uniform(0, .05)), mats.flat('bk%d' % i, rr.choice(('#7a2a2a', '#2a4a7a', '#4a6a3a', '#8a6a2a')), rough=.8, bevel_wear=0), bevel=0.01)
    hang_lantern(.95, 1.5)
    _finish()


for _id, _b in (('int_wall_plain', bay_plain), ('int_wall_window', bay_window), ('int_wall_door', bay_door), ('int_wall_hearth', bay_hearth), ('int_wall_niche', bay_niche)):
    _reg(_id, _b)


@landmark('int_post', group='interior', folder='walls', size=(90, 250), origin=(45, 218), tags=('interior', 'poste', 'coluna'), footprint=0, samples=24)
def post(f):
    mwd, ms = M('wood_dark'), M('stone')
    geo.box((0, 0, .18), (.6, .6, .36), ms, bevel=0.05)
    geo.box((0, 0, H_WALL / 2), (.34, .34, H_WALL), mwd, bevel=0.04)
    geo.box((0, 0, H_WALL - .1), (.6, .6, .2), mwd, bevel=0.03)
    for sgn in (-1, 1):
        geo.beam((0, sgn * .2, 2.8), (0, sgn * .75, 3.4), .1, .1, mwd, bevel=0.02)
    geo.cyl((0, 0, .36), .2, .1, M('iron'), sides=8)
    _finish()


@landmark('int_beam', group='interior', folder='walls', size=(180, 60), origin=(90, 40), tags=('interior', 'viga'), footprint=0, samples=24)
def beam_span(f):
    mwd = M('wood_dark')
    geo.box((0, 0, .2), (.3, 2.6, .34), mwd, bevel=0.04)
    for y in (-1.25, 1.25):
        geo.box((0, y, .1), (.4, .4, .5), mwd, bevel=0.04)
    geo.rotate_all(45)


# ------------------------------------------------------------------ pisos (tile 248x140, losango de 2.92 u; padrão contínuo entre tiles)
S_TILE = 2.92


def _floor_wood(cols, seed):
    rr = random.Random(seed)
    n = 8
    w = S_TILE / n
    mats_ = [mats.plank_piece('fp%d_%d' % (seed, k), cols) for k in range(6)]
    geo.box((0, 0, -.03), (S_TILE, S_TILE, .05), mats.flat('floor_gap', '#120a06', rough=1.0, bevel_wear=0), bevel=0)
    for i in range(n):
        y = -S_TILE / 2 + (i + .5) * w
        joint = .25 + ((i * 0.37) % 1) * .5
        L1 = S_TILE * joint
        L2 = S_TILE - L1
        for (x0, L) in ((-S_TILE / 2, L1), (-S_TILE / 2 + L1, L2)):
            geo.box((x0 + L / 2, y, rr.uniform(-.004, .006)), (L - .022, w - .02, .03), rr.choice(mats_), bevel=0.006)
            for nx in (x0 + .06, x0 + L - .06):
                geo.cyl((nx, y + rr.uniform(-.03, .03), .014), .012, .006, mats.flat('nail', '#2a2622', rough=.5, metallic=.6, bevel_wear=0), sides=6)


@landmark('int_floor_wood', group='interior', folder='floors', size=(248, 140), origin=(124, 70), tags=('interior', 'chao'), footprint=0, samples=16, catcher=False, outline=0, diamond=(124, 62))
def floor_wood(f):
    _floor_wood(('#4a2a16', '#7a4a26', '#a8703a', '#d0a060'), 1)


@landmark('int_floor_wood_dark', group='interior', folder='floors', size=(248, 140), origin=(124, 70), tags=('interior', 'chao'), footprint=0, samples=16, catcher=False, outline=0, diamond=(124, 62))
def floor_wood_dark(f):
    _floor_wood(('#20120c', '#42261a', '#68402a', '#8a5a38'), 2)


@landmark('int_floor_stone', group='interior', folder='floors', size=(248, 140), origin=(124, 70), tags=('interior', 'chao', 'ferreiro'), footprint=0, samples=16, catcher=False, outline=0, diamond=(124, 62))
def floor_stone(f):
    rr = random.Random(3)
    geo.box((0, 0, -.03), (S_TILE, S_TILE, .05), mats.flat('grout', '#1c1618', rough=1.0, bevel_wear=0), bevel=0)
    n = 4
    w = S_TILE / n
    ms = [mats.rock('slab%d' % k, ('#3a3038', '#5e4e50', '#8a746a', '#b89a84', '#dcc0a4'), strata=(1.0, .1)) for k in range(4)]
    for i in range(n):
        for j in range(n):
            geo.box((-S_TILE / 2 + (i + .5) * w, -S_TILE / 2 + (j + .5) * w, rr.uniform(0, .012)), (w - .07 - rr.uniform(0, .05), w - .07 - rr.uniform(0, .05), .04), ms[(i * 3 + j * 5) % 4], bevel=0.02)
