"""Lote 1 / Ato I — Mina do Eco (exterior + interior em 3 zonas) e Núcleo do Eco (arena do Guardião). IDs persistentes val_*."""
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
from ato1_common import *


def circ(points, r):
    return tuple((round(.7071 * (Y - X) * S, 1), round(.5 * .7071 * (X + Y) * S, 1), r) for (X, Y) in points)


def fp(sx, sy):
    from terrain_forms_data import footprint_circles
    return footprint_circles(sx, sy, .9, .9)


def m_eco_d():
    # Eco DORMENTE (pós-Guardião): cristal quase apagado, azul-acinzentado, emissão mínima
    return X('eco_d', lambda: mats.emissive('eco_d', '#3d7a90', 0.9))


def m_eco_dd():
    return X('eco_dd', lambda: mats.emissive('eco_dd', '#27485a', 0.35))


def _pal(dorm):
    return (m_eco_d(), m_eco_dd()) if dorm else (m_eco(), m_eco_dim())


def crystal(x, y, z, h, r, mat, tilt=(0, 0)):
    o = geo.cyl((x, y, z), r, h, mat, sides=6, r2=r * .12)
    o.rotation_euler = (tilt[0], tilt[1], 0)
    return o


# ============================================================== LOC_ECHO_MINE — exterior
@landmark('val_mine_portal', group='dungeon', folder='ato1', size=(760, 700), origin=(380, 560), tags=('ato1', 'mina_do_eco', 'entrada', 'echo_mine'), footprint=80, collision=tuple((round(30 * y, 1), 0.0, 15.0) for y in (-3.0, -2.4, -1.8, 1.8, 2.4, 3.0)), samples=24)
def mine_portal(f):
    rk, wd, wo, iron = M('rock'), M('wood_dark'), M('wood_old'), M('iron')
    body = parts.rock_mass((0, 0, 0), (3.2, 6.6, 4.2), rk, 81, subdiv=5, rough=.3, terrace=.5, step=.5, taper=.1, flat_top=True, squash_base=.05)
    cut = geo.box((1.0, 0, 1.15), (3.4, 2.5, 2.3), M('hole'), bevel=0)
    top = geo.cyl((-.7, 0, 2.3), 1.25, 3.4, M('hole'), rot=(0, 90, 0), sides=14)
    geo.join([cut, top], 'mcut')
    geo.boolean_cut(body, bpy.data.objects['mcut'], M('hole'))
    parts.slab_blob(0, 0, 4.2, 3.0, 6.3, .3, M('turf'), 82)
    for i in range(5):
        parts.leaf_cluster(0, -2.5 + i * 1.25, 4.4, .45, 20, M('leaf'), 90 + i, size=(.1, .17), flat=.6)
    parts.hanging_vines(1.55, -2.6, 1.55, 2.6, 4.1, 1.1, 8, M('leaf'), 5)
    # boca: dois esteios grossos, verga de pedra com glifo de Eco, escoras diagonais, plataforma de embarque
    for sy in (-1.3, 1.3):
        geo.box((1.75, sy, 1.2), (.34, .34, 2.4), wd, bevel=0.04)
        geo.beam((1.78, sy, .5), (1.78, sy * .45, 2.3), .11, .11, wd, bevel=0.02)
    geo.box((1.78, 0, 2.55), (.4, 3.1, .34), wd, bevel=0.04)
    geo.box((1.95, 0, 3.05), (.34, 3.5, .55), M('stone_sand'), bevel=0.05)
    geo.box((2.15, 0, 3.05), (.05, .7, .08), m_eco(), bevel=0)
    for k in range(3):
        geo.box((2.15, -.35 + k * .35, 2.9), (.05, .05, .32), m_eco(), bevel=0)
    geo.box((2.3, 0, .1), (1.6, 2.6, .2), wo, bevel=0.02)
    for sy in (-1.6, 1.6):
        lantern(2.25, sy, 2.3)
    # trilhos saindo da boca, vagonete cheio e barreira de segurança quebrada
    for sy in (-.35, .35):
        geo.box((3.4, sy, .06), (2.8, .09, .09), iron, bevel=0.005)
    for k in range(7):
        geo.box((2.5 + k * .4, 0, .03), (.14, 1.1, .06), wd, bevel=0.005)
    # pilhas de minério e entulho ladeando
    for sy in (-2.7, 2.7):
        parts.rubble(2.5, sy, 1.0, 9, m_ore(), seed=int(sy * 3) + 9, rmin=.14, rmax=.36)
        crystal(2.4, sy, 0, .5, .09, m_eco_dim())
    parts.rubble(1.6, 0, 3.2, 12, rk, seed=13, rmin=.12, rmax=.34)
    geo.rotate_all(45)


@landmark('val_mine_cart', group='dungeon', folder='ato1', size=(280, 220), origin=(140, 150), tags=('ato1', 'mina_do_eco', 'vagonete', 'prop'), footprint=20, collision=circ([(0, 0)], 10), samples=24)
def mine_cart(f):
    wd, iron = M('wood_dark'), M('iron')
    geo.box((0, 0, .55), (1.5, 1.0, .7), M('wood'), bevel=0.04)
    for z in (.3, .75):
        geo.box((0, 0, z), (1.56, 1.06, .07), iron, bevel=0.01)
    for sx in (-.55, .55):
        for sy in (-.55, .55):
            geo.cyl((sx, sy, .22), .2, .08, iron, rot=(90, 0, 0), sides=12)
    # carga de minério com veios de Eco
    parts.rubble(0, 0, .55, 12, m_ore(), seed=3, rmin=.12, rmax=.26)
    for k in range(3):
        crystal(-.3 + k * .3, .1 * (k - 1), .85, .32, .06, m_eco_dim())
    geo.box((.8, 0, .55), (.06, .4, .06), iron, bevel=0)


@landmark('val_ore_pile', group='dungeon', folder='ato1', size=(320, 240), origin=(160, 160), tags=('ato1', 'mina_do_eco', 'minerio', 'prop'), footprint=24, collision=circ([(0, 0)], 11), samples=24)
def ore_pile(f):
    rr = random.Random(7)
    parts.rock_mass((0, 0, 0), (1.9, 1.4, .8), m_ore(), 71, subdiv=3, rough=.35, taper=.35, flat_top=False)
    parts.rubble(0, 0, 1.3, 14, m_ore(), seed=4, rmin=.1, rmax=.3)
    for k in range(5):
        crystal(rr.uniform(-.7, .7), rr.uniform(-.5, .5), .55, rr.uniform(.25, .5), .07, m_eco(), tilt=(rr.uniform(-.3, .3), rr.uniform(-.3, .3)))
    geo.cyl_between((1.1, .3, 0), (1.4, .3, .9), .04, M('wood_dark'), sides=5)          # pá cravada
    geo.box((1.42, .3, .95), (.26, .2, .05), M('iron'), rot=(0, .3, 0), bevel=0.005)


@landmark('val_mine_winch', group='dungeon', folder='ato1', size=(300, 400), origin=(150, 300), tags=('ato1', 'mina_do_eco', 'guincho', 'prop'), footprint=20, collision=circ([(-.6, -.6), (.6, .6)], 9), samples=24)
def mine_winch(f):
    wd, wo, iron = M('wood_dark'), M('wood_old'), M('iron')
    geo.box((0, 0, .1), (1.8, 1.8, .2), wo, bevel=0.03)                   # plataforma sobre o poço
    geo.box((0, 0, .21), (.9, .9, .02), M('hole'), bevel=0)
    for sx, sy in ((-.7, -.7), (.7, -.7), (.7, .7), (-.7, .7)):
        geo.cyl_between((sx, sy, .2), (sx * .3, sy * .3, 2.6), .09, wd, sides=6, r2=.07)      # tripé/torre em A
    geo.beam((-.4, 0, 2.5), (.4, 0, 2.5), .1, .1, wd, bevel=0.02)
    geo.cyl((0, 0, 1.3), .22, 1.2, wo, rot=(0, 90, 0), sides=12)          # tambor com corda
    geo.cyl((.75, 0, 1.3), .05, .4, iron, rot=(0, 0, 90), sides=6)
    geo.cyl_between((0, 0, 2.5), (0, 0, .3), .022, M('rope'), sides=4)
    geo.box((0, 0, .5), (.4, .4, .35), wo, bevel=0.03)                    # balde
    geo.cyl_between((.8, 0, 1.3), (1.2, 0, .5), .03, wd, sides=5)         # manivela
    lantern(-.7, .75, 1.7)


def _rail(axis):
    iron, wd = M('iron'), M('wood_dark')
    for k in range(6):
        geo.box((-1.25 + k * .5, 0, .03), (.14, 1.0, .06), wd, bevel=0.005)
    for sy in (-.35, .35):
        geo.box((0, sy, .09), (3.2, .07, .07), iron, bevel=0.005)
    if axis == 'b':
        geo.rotate_all(90)


@landmark('val_mine_rails_a', group='dungeon', folder='ato1', size=(240, 120), origin=(120, 60), tags=('ato1', 'mina_do_eco', 'trilhos', 'modular'), footprint=0, collision=(), samples=16, outline=0, catcher=False)
def mine_rails_a(f):
    _rail('a')


@landmark('val_mine_rails_b', group='dungeon', folder='ato1', size=(240, 120), origin=(120, 60), tags=('ato1', 'mina_do_eco', 'trilhos', 'modular'), footprint=0, collision=(), samples=16, outline=0, catcher=False)
def mine_rails_b(f):
    _rail('b')


@landmark('val_mine_lantern_post', group='dungeon', folder='ato1', size=(140, 320), origin=(70, 260), tags=('ato1', 'mina_do_eco', 'lanterna', 'prop'), blocks=5, footprint=6, samples=24)
def mine_lantern_post(f):
    wd, iron = M('wood_dark'), M('iron')
    geo.cyl((0, 0, 0), .09, 2.2, wd, sides=6, r2=.07)
    geo.beam((0, 0, 2.1), (.5, 0, 2.05), .05, .05, wd, bevel=0.01)
    geo.beam((0, 0, 1.6), (.4, 0, 2.0), .03, .03, wd, bevel=0.005)
    lantern(.5, 0, 1.85)
    ball((.5, 0, 1.75), .18, m_eco_dim(), squash=1.0)
    geo.cyl((0, 0, 0), .26, .12, M('rock'), sides=8, r2=.18)


# ============================================================== interior — 3 zonas
@landmark('val_mine_floor', group='dungeon', folder='ato1', size=(248, 140), origin=(124, 70), tags=('ato1', 'mina_do_eco', 'interior', 'chao'), footprint=0, collision=(), samples=16, catcher=False, outline=0, diamond=(124, 62))
def mine_floor(f):
    rr = random.Random(5)
    S_T = 4.0
    geo.box((0, 0, -.03), (S_T, S_T, .05), m_dirt_dark(), bevel=0)
    for k in range(60):
        geo.box((rr.uniform(-1.9, 1.9), rr.uniform(-1.9, 1.9), .015), (rr.uniform(.15, .4), rr.uniform(.12, .3), .03), m_gravel(), rot=(0, 0, rr.uniform(0, 3)), bevel=0.01)
    for k in range(4):
        geo.box((rr.uniform(-1.6, 1.6), rr.uniform(-1.6, 1.6), .02), (rr.uniform(.5, 1.0), rr.uniform(.4, .8), .04), M('rock_grey'), rot=(0, 0, rr.uniform(0, 3)), bevel=0.02)
    for k in range(2):
        geo.cyl_between((rr.uniform(-1.8, -.5), rr.uniform(-1.8, 1.8), .02), (rr.uniform(.5, 1.8), rr.uniform(-1.8, 1.8), .02), .012, M('hole'), sides=4)


@landmark('val_mine_rock_wall', group='dungeon', folder='ato1', size=(420, 460), origin=(210, 380), tags=('ato1', 'mina_do_eco', 'interior', 'parede', 'modular'), footprint=0, collision=(), samples=24)
def mine_rock_wall(f):
    _rockwall(0)


@landmark('val_mine_rock_wall_eco', group='dungeon', folder='ato1', size=(420, 460), origin=(210, 380), tags=('ato1', 'mina_do_eco', 'interior', 'parede', 'modular', 'eco'), footprint=0, collision=(), samples=24)
def mine_rock_wall_eco(f):
    _rockwall(1)


@landmark('val_mine_rock_wall_eco_dormant', group='dungeon', folder='ato1', size=(420, 460), origin=(210, 380), tags=('ato1', 'mina_do_eco', 'interior', 'parede', 'modular', 'eco', 'estado_dormente'), footprint=0, collision=(), samples=24)
def mine_rock_wall_eco_dormant(f):
    _rockwall(2)


def _rockwall(state):
    me = m_eco_d() if state == 2 else m_eco()
    rr = random.Random(90 + state)
    rk = M('rock') if state == 0 else M('rock_grey')
    parts.rock_mass((0, 0, 0), (1.3, 3.4, 3.2), rk, 91 + state, subdiv=4, rough=.32, terrace=.4, step=.45, taper=.08, flat_top=True)
    for k in range(4):
        parts.rock_mass((.6, -1.2 + k * .8, .3), (.5, rr.uniform(.6, .9), rr.uniform(.6, 1.2)), rk, 100 + k + state * 9, subdiv=3, rough=.35, flat_top=False)
    if state == 0:
        for sy in (-1.5, 1.5):                                       # escoras de madeira e viga
            geo.box((.75, sy, 1.3), (.24, .26, 2.6), M('wood_dark'), bevel=0.03)
        geo.box((.75, 0, 2.7), (.26, 3.4, .26), M('wood_dark'), bevel=0.03)
        geo.box((.72, 0, 1.8), (.14, .8, .5), m_ore(), bevel=0.03)
        lantern(.95, 0, 2.3)
    else:                                                            # contato com o Eco: fissuras e cristais
        for k in range(5):
            y = -1.3 + k * .65
            geo.beam((.68, y, rr.uniform(.4, 1.2)), (.68, y + rr.uniform(-.3, .3), rr.uniform(1.6, 2.7)), .03, .02, me, bevel=0)
        for k in range(6):
            crystal(.7, rr.uniform(-1.4, 1.4), rr.uniform(.4, 2.2), rr.uniform(.3, .6), .08, me, tilt=(0, 1.2))
    geo.rotate_all(45)


@landmark('val_mine_beam_arch', group='dungeon', folder='ato1', size=(320, 340), origin=(160, 270), tags=('ato1', 'mina_do_eco', 'interior', 'suporte', 'modular'), footprint=0, collision=(), samples=24)
def mine_beam_arch(f):
    wd, wo = M('wood_dark'), M('wood_old')
    for sy in (-1.3, 1.3):
        geo.box((0, sy, 1.3), (.3, .3, 2.6), wd, bevel=0.04)
        geo.beam((.02, sy, .4), (.02, sy * .5, 2.3), .1, .1, wo, bevel=0.02)
    geo.box((0, 0, 2.65), (.34, 3.0, .32), wd, bevel=0.04)
    for k in range(4):
        geo.box((-.4 - k * .3, -1.0 + k * .7, 2.9), (.26, .4, .1), wo, bevel=0.01)
    lantern(.25, -1.0, 2.5)
    parts.rubble(.3, 0, 1.4, 5, M('rock'), seed=2, rmin=.05, rmax=.14)
    geo.rotate_all(45)


@landmark('val_eco_vein', group='dungeon', folder='ato1', size=(280, 260), origin=(140, 170), tags=('ato1', 'mina_do_eco', 'eco', 'cristal', 'prop'), footprint=16, collision=circ([(0, 0)], 9), samples=24)
def eco_vein(f):
    _eco_vein(False)


def _eco_vein(dorm):
    me, md = _pal(dorm)
    rr = random.Random(31)
    parts.rock_mass((0, 0, 0), (1.3, 1.1, .8), M('rock_grey'), 33, subdiv=3, rough=.3, taper=.3, flat_top=False)
    for k in range(9):
        a = rr.uniform(0, 6.28)
        d = rr.uniform(.1, .5)
        crystal(math.cos(a) * d, math.sin(a) * d, .35, rr.uniform(.4, 1.1), rr.uniform(.08, .16), me, tilt=(rr.uniform(-.4, .4), rr.uniform(-.4, .4)))
    geo.cyl((0, 0, 0), 1.0, .01, md, sides=16)


@landmark('val_eco_vein_dormant', group='dungeon', folder='ato1', size=(280, 260), origin=(140, 170), tags=('estado_dormente', 'ato1', 'mina_do_eco', 'eco', 'cristal', 'prop'), footprint=16, collision=circ([(0, 0)], 9), samples=24)
def eco_vein_dormant(f):
    _eco_vein(True)



@landmark('val_mine_machine', group='dungeon', folder='ato1', size=(400, 360), origin=(200, 240), tags=('ato1', 'mina_do_eco', 'maquinario', 'antigo'), footprint=34, collision=circ([(-.6, 0), (.6, 0)], 12), samples=24)
def mine_machine(f):
    iron, wd, rk = M('iron'), M('wood_dark'), M('rock_grey')
    geo.box((0, 0, .3), (2.6, 1.8, .6), rk, bevel=0.05)
    for sx in (-.8, .8):                                                # engrenagens de ferro e bronze com dentes
        geo.cyl((sx, .95, 1.3), .7, .18, iron, rot=(90, 0, 0), sides=18)
        for k in range(12):
            a = k * math.pi / 6
            geo.box((sx + math.cos(a) * .76, .95, 1.3 + math.sin(a) * .76), (.12, .2, .12), iron, rot=(0, -a, 0), bevel=0)
        geo.cyl((sx, .95, 1.3), .12, .3, m_gold(), rot=(90, 0, 0), sides=8)
    geo.box((0, -.3, 1.3), (1.6, .3, 1.3), wd, bevel=0.04)
    geo.cyl((0, -.3, 2.2), .3, .8, iron, sides=10)                      # caldeira/bomba
    geo.cyl((0, -.3, 3.0), .1, .5, iron, sides=8)
    ball((0, -.3, 3.35), .18, M('rock_snow'), squash=1.2)               # vapor
    for k in range(4):                                                  # canos e veios de Eco ligados à máquina
        geo.cyl_between((-.5 + k * .35, -.9, .3), (-1.0 + k * .7, -1.6, .1), .05, iron, sides=6)
    crystal(1.0, -.9, .5, .5, .08, m_eco_dim())
    lantern(-1.1, .95, 1.9)


# ============================================================== LOC_ECHO_MINE_CORE
@landmark('val_eco_core', group='dungeon', folder='ato1', size=(500, 640), origin=(250, 470), tags=('ato1', 'nucleo_do_eco', 'boss', 'echo_mine_core', 'centro'), footprint=60, collision=circ([(0, 0), (.5, .5), (-.5, -.5), (.5, -.5), (-.5, .5)], 14), samples=24)
def eco_core(f):
    _eco_core(False)


def _eco_core(dorm):
    me, md = _pal(dorm)
    rk = M('rock_grey')
    # base ritual: três degraus de pedra com anéis de runas, pilares curtos e o núcleo cristalino alto com aros flutuantes
    for i, r in enumerate((2.5, 2.0, 1.5)):
        geo.cyl((0, 0, i * .22), r, .24, rk, sides=16, r2=r * .96)
    for k in range(8):
        a = k * math.pi / 4
        geo.box((math.cos(a) * 2.2, math.sin(a) * 2.2, .3), (.3, .08, .05), me, rot=(0, 0, a + math.pi / 2), bevel=0)
    for k in range(4):
        a = k * math.pi / 2 + math.pi / 4
        geo.box((math.cos(a) * 1.9, math.sin(a) * 1.9, .9), (.4, .4, 1.2), rk, rot=(0, 0, a), bevel=0.04)
        crystal(math.cos(a) * 1.9, math.sin(a) * 1.9, 1.5, .4, .1, md)
    core = crystal(0, 0, .7, 3.6, .55, me)
    for k, (h, r, t) in enumerate(((1.4, .35, .5), (1.0, .28, -.6), (1.6, .3, .9), (.9, .25, -.9))):
        crystal(.35 * math.cos(k * 1.6), .35 * math.sin(k * 1.6), .7, h + 1.2, r, me, tilt=(t * .2, -t * .2))
    for h, r in ((1.6, 1.1), (2.4, .8), (3.1, .6)):                     # anéis de energia
        geo.cyl((0, 0, h), r, .05, md, sides=24, r2=r)
    parts.rubble(0, 0, 2.6, 12, rk, seed=6, rmin=.08, rmax=.22)


@landmark('val_eco_core_dormant', group='dungeon', folder='ato1', size=(500, 640), origin=(250, 470), tags=('estado_dormente', 'ato1', 'nucleo_do_eco', 'boss', 'echo_mine_core', 'centro'), footprint=60, collision=circ([(0, 0), (.5, .5), (-.5, -.5), (.5, -.5), (-.5, .5)], 14), samples=24)
def eco_core_dormant(f):
    _eco_core(True)



@landmark('val_eco_crystal_cluster', group='dungeon', folder='ato1', size=(300, 340), origin=(150, 240), tags=('ato1', 'nucleo_do_eco', 'cristal', 'prop'), footprint=20, collision=circ([(0, 0)], 11), samples=24)
def eco_cluster(f):
    _eco_cluster(False)


def _eco_cluster(dorm):
    me, md = _pal(dorm)
    rr = random.Random(41)
    parts.rock_mass((0, 0, 0), (1.3, 1.1, .5), M('rock_grey'), 43, subdiv=3, rough=.25, taper=.2, flat_top=True)
    for k in range(11):
        a = k * 2.4
        d = rr.uniform(.05, .5)
        crystal(math.cos(a) * d, math.sin(a) * d, .3, rr.uniform(.5, 1.6), rr.uniform(.07, .17), me if k % 3 else md, tilt=(rr.uniform(-.35, .35), rr.uniform(-.35, .35)))


@landmark('val_eco_crystal_cluster_dormant', group='dungeon', folder='ato1', size=(300, 340), origin=(150, 240), tags=('estado_dormente', 'ato1', 'nucleo_do_eco', 'cristal', 'prop'), footprint=20, collision=circ([(0, 0)], 11), samples=24)
def eco_cluster_dormant(f):
    _eco_cluster(True)



@landmark('val_core_floor_ring', group='dungeon', folder='ato1', size=(760, 400), origin=(380, 200), tags=('ato1', 'nucleo_do_eco', 'arena', 'piso', 'decalque'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def core_floor_ring(f):
    _core_floor_ring(False)


def _core_floor_ring(dorm):
    me, md = _pal(dorm)
    rr = random.Random(5)
    dark = mats.flat('cfloor', '#22202e', rough=.9, bevel_wear=0)
    geo.cyl((0, 0, 0), 6.6, .03, dark, sides=40)
    for ring, w in ((6.0, .16), (4.7, .12), (3.1, .1)):
        for k in range(64):
            a = k * 2 * math.pi / 64
            if rr.random() < .25:
                continue
            geo.box((math.cos(a) * ring, math.sin(a) * ring, .05), (.42, w, .02), md, rot=(0, 0, a + math.pi / 2), bevel=0)
    for k in range(8):                                                   # 8 linhas de Eco (8 selos) até o centro
        a = k * math.pi / 4
        geo.box((math.cos(a) * 3.6, math.sin(a) * 3.6, .05), (4.4, .09, .02), me, rot=(0, 0, a), bevel=0)
    for k in range(9):                                                   # fissuras de energia e lajes rachadas
        a = rr.uniform(0, 6.28)
        geo.cyl_between((math.cos(a) * 1.2, math.sin(a) * 1.2, .05), (math.cos(a + .3) * 6.0, math.sin(a + .3) * 6.0, .05), .03, M('hole'), sides=4)
    geo.cyl((0, 0, .05), 1.0, .02, md, sides=24)


@landmark('val_core_floor_ring_dormant', group='dungeon', folder='ato1', size=(760, 400), origin=(380, 200), tags=('estado_dormente', 'ato1', 'nucleo_do_eco', 'arena', 'piso', 'decalque'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def core_floor_ring_dormant(f):
    _core_floor_ring(True)


# ------------------------------------------------------------------ Galeria Antiga (cripta): kit ISOMÉTRICO de parede
# Correção estrutural pedida pelo Diretor ("as paredes estão sem ângulos"): a cripta deixa de usar a fileira reta frontal e
# passa a correr nos dois eixos isométricos (peça girada no Blender por pro_orient) com PILAR de junção em todo vértice.
@landmark('val_crypt_wall', group='dungeon', folder='ato1', size=(360, 380), origin=(180, 290), tags=('ato1', 'galeria_antiga', 'cripta', 'parede', 'modular', 'kit_isometrico'), footprint=0, collision=(), samples=24)
def crypt_wall(f):
    """Trecho de parede de cripta (3,6 u, mesmo passo da muralha): alvenaria escura, soco, cornija, nicho com crânio e
    velas, pilastras e veio de cristal azul (luz fria da Galeria)."""
    sd = M('stone_dark')
    rr = random.Random(77)
    geo.box((0, 0, .15), (1.1, 3.6, .3), sd, bevel=0.04)                          # soco
    geo.box((0, 0, 1.55), (.8, 3.6, 2.5), sd, bevel=0.04)                         # pano de parede
    geo.box((0, 0, 2.86), (1.0, 3.62, .18), sd, bevel=0.03)                       # cornija
    for fx in (1, -1):                                                            # as DUAS faces são visíveis conforme o eixo
        for sy in (-1.2, 1.2):                                                    # pilastras
            geo.box((fx * .44, sy, 1.5), (.16, .34, 2.6), sd, bevel=0.03)
        geo.box((fx * .38, 0, 1.25), (.1, .8, .9), M('hole'), bevel=0)           # nicho funerário
        geo.box((fx * .46, 0, 1.72), (.12, .96, .12), sd, bevel=0.02)
        ball((fx * .36, -.12, .92), .13, m_bone(), squash=.9)
        for sy in (.18, .28):
            geo.cyl((fx * .36, sy, .8), .035, .16, m_bone(), sides=6)
            ball((fx * .36, sy, .98), .03, M('fire'))
        for k in range(3):                                                        # veio de cristal azul na base
            crystal(fx * .44, rr.uniform(-1.6, -.5) if k % 2 else rr.uniform(.5, 1.6), rr.uniform(.25, .5), rr.uniform(.25, .45), .06, m_eco_dim(), tilt=(0, 1.1 * fx))
    parts.rubble(.55, 1.5, .3, 4, sd, seed=9, rmin=.05, rmax=.12)
    geo.rotate_all(45)


@landmark('val_crypt_pillar', group='dungeon', folder='ato1', size=(340, 500), origin=(130, 400), tags=('ato1', 'galeria_antiga', 'cripta', 'juncao', 'kit_isometrico'), footprint=0, collision=(), samples=24)
def crypt_pillar(f):
    """Pilar de junção alinhado aos EIXOS DO MUNDO (sem rotação): cobre retas, cantos e dentes da parede sem fresta."""
    sd = M('stone_dark')
    s, H = 1.25, 3.4
    geo.box((0, 0, .2), (s + .35, s + .35, .4), sd, bevel=0.05)
    geo.box((0, 0, H / 2 + .2), (s, s, H - .2), sd, bevel=0.05)
    geo.box((0, 0, H + .12), (s + .3, s + .3, .24), sd, bevel=0.04)               # capitel
    geo.cyl((0, 0, H + .24), .32, .14, M('iron'), sides=8, r2=.4)                 # braseiro de chama fria
    ball((0, 0, H + .52), .22, m_eco(), squash=1.5)
    for (ax, ay) in ((1, 0), (0, 1)):                                             # runas nas faces visíveis
        geo.box((ax * (s / 2 + .01), ay * (s / 2 + .01), 1.9), (.04 if ax else .3, .3 if ax else .04, .5), m_eco_dim(), bevel=0)
