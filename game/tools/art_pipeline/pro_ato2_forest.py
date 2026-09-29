"""Lote 2 / Ato II — Floresta Ancestral, PARTE 2A: fronteira (Ponte de Pedra) e hub leve (Casa dos Guardas Verdes). IDs persistentes flo_*."""
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
from pro_nature import trunk, branch, canopy_clumps
from ato2_common import *


# ============================================================== vegetação e massa da floresta ancestral
def _ancient_tree(seed, h=6.6, r0=.95, lean=(.3, .1), n_root=6, claws=False):
    rr = random.Random(seed)
    bark = m_bark_old()
    pts = trunk(h, r0, r0 * .42, bark, lean=lean, seed=seed, flare=False)
    buttress_roots(r0, h * .3, n_root, bark, seed=seed, spread=2.4)
    top = pts[-1]
    centers = []
    for k in range(5):                                        # galhos grossos que abrem para a copa
        a = k * 1.25 + rr.uniform(-.2, .2)
        z0 = h * (.62 + .07 * k)
        p0 = (pts[3][0] + (pts[4][0] - pts[3][0]) * (k / 5.0), pts[3][1] + (pts[4][1] - pts[3][1]) * (k / 5.0), z0)
        p1 = (p0[0] + math.cos(a) * 2.0, p0[1] + math.sin(a) * 2.0, z0 + rr.uniform(.6, 1.3))
        branch(p0, p1, .22, .09, bark)
        centers.append((p1[0] + math.cos(a) * .3, p1[1] + math.sin(a) * .3, p1[2] + .9))
    centers.append((top[0], top[1], top[2] + 1.0))
    centers.append((top[0] + .8, top[1] - .7, top[2] + .2))
    canopy_mass(centers, 1.7, seed, size=(.2, .32))
    parts.hanging_vines(.6, -.6, .6, .6, h * .62, 1.9, 5, m_leaf_deep(), seed)
    parts.leaf_cluster(0, 0, .12, 1.7, 22, m_fern(), seed + 9, size=(.14, .3), flat=.35)
    glow_mushrooms(r0 * 1.5, -r0 * .5, 5, seed + 3, spread=.35)
    if claws:                                                 # marcas de garras: três sulcos fundos com brilho fraco de Eco
        for k in range(3):
            geo.box((r0 * .78, -.28 + k * .3, 1.4 + k * .05), (.05, .06, 1.1), m_root_dead(), rot=(0, 0, 0), bevel=0)
            geo.box((r0 * .8, -.28 + k * .3, 1.4 + k * .05), (.02, .03, .9), m_eco_corrupt(), bevel=0)


@landmark('flo_ancient_tree_a', group='nature', folder='ato2', size=(860, 880), origin=(350, 740), tags=('ato2', 'floresta_ancestral', 'arvore', 'ancestral'), footprint=30, collision=circ([(0, 0)], 20), samples=24)
def ancient_tree_a(f):
    _ancient_tree(201, h=6.4, r0=1.35, lean=(.3, .1), n_root=7)


@landmark('flo_ancient_tree_b', group='nature', folder='ato2', size=(860, 880), origin=(350, 740), tags=('ato2', 'floresta_ancestral', 'arvore', 'ancestral'), footprint=30, collision=circ([(0, 0)], 20), samples=24)
def ancient_tree_b(f):
    _ancient_tree(233, h=6.0, r0=1.15, lean=(-.35, .2), n_root=6)


@landmark('flo_claw_tree', group='nature', folder='ato2', size=(780, 800), origin=(310, 660), tags=('ato2', 'floresta_ancestral', 'arvore', 'ataque', 'guardas'), footprint=26, collision=circ([(0, 0)], 17), samples=24)
def claw_tree(f):
    _ancient_tree(261, h=5.2, r0=1.05, lean=(.2, -.1), n_root=5, claws=True)


@landmark('flo_root_arch', group='nature', folder='ato2', size=(600, 620), origin=(300, 500), tags=('ato2', 'floresta_ancestral', 'arco', 'ecotono', 'passagem'), footprint=40, collision=circ([(0, -1.9), (0, 1.9)], 16), samples=24)
def root_arch(f):
    """Porta natural: dois troncos inclinados que se encontram no alto, raízes abraçando a passagem; o vão fica livre."""
    bark = m_bark_old()
    rr = random.Random(5)
    for sy in (-1, 1):
        root((0, sy * 2.2, .1), (0, sy * .5, 4.4), .55, .28, bark, sag=.2, sides=9)
        buttress_roots(.55, 1.2, 4, bark, seed=7 + sy, spread=2.0)
    for k in range(4):                                       # galhos entrelaçados no topo
        y0 = -.5 + k * .33
        branch((0, y0, 4.3), (rr.uniform(-.7, .7), y0 * 1.8, 4.9 + rr.uniform(0, .4)), .13, .05, bark)
    canopy_mass([(0, -1.4, 4.7), (0, 0, 5.5), (0, 1.4, 4.7)], 1.35, 12, n_leaf=34, light=False, tuft=m_leaf_mass())
    parts.hanging_vines(0, -1.0, 0, 1.0, 4.2, 1.6, 6, m_leaf_deep(), 4)
    glow_mushrooms(.3, 1.8, 4, 6, spread=.3)
    parts.leaf_cluster(.2, -1.8, .1, 1.0, 12, m_fern(), 3, size=(.12, .26), flat=.35)
    geo.rotate_all(45)


@landmark('flo_stone_moss', group='nature', folder='ato2', size=(340, 300), origin=(170, 210), tags=('ato2', 'floresta_ancestral', 'pedra', 'pre_guerra'), footprint=22, collision=circ([(0, 0)], 14), samples=24)
def stone_moss(f):
    """Bloco pré-guerra parcialmente engolido por raízes e musgo."""
    rk, st = m_rock_moss(), m_stone_moss()
    geo.box((0, 0, .42), (1.2, 1.1, .9), st, rot=(0, 0, .35), bevel=0.06)
    parts.rock_mass((.3, .2, 0), (1.3, 1.1, .8), rk, 61, subdiv=3, rough=.25, taper=.1, flat_top=False)
    root((-.9, -.5, .05), (.1, .1, .9), .13, .06, m_bark_old(), sag=.1)
    root((.7, -.7, .05), (-.2, .3, .8), .11, .05, m_bark_old(), sag=.1)
    parts.leaf_cluster(0, 0, .8, .8, 10, m_fern(), 4, size=(.12, .22), flat=.4)
    glow_mushrooms(-.7, .6, 3, 8, spread=.25)


@landmark('flo_root_run', group='nature', folder='ato2', size=(420, 200), origin=(210, 100), tags=('ato2', 'floresta_ancestral', 'raiz', 'chao'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def root_run(f):
    """Raízes correndo sobre o solo (composição de piso, sem colisão)."""
    bark = m_bark_old()
    rr = random.Random(9)
    for k in range(4):
        y0 = -1.3 + k * .8
        root((-2.4, y0, .02), (2.4, y0 + rr.uniform(-.5, .5), .02), .16 - k * .015, .07, bark, sag=-.08, sides=6)
    moss_patches(0, 0, 4.4, 2.6, .03, 22, 5, mat=M('leaf_dry'), size=(.14, .26))


def m_leaf_dry_or():
    return M('leaf_dry')


@landmark('flo_glow_mushrooms', group='nature', folder='ato2', size=(220, 170), origin=(110, 100), tags=('ato2', 'floresta_ancestral', 'cogumelo', 'bioluminescencia'), footprint=0, collision=(), samples=16, catcher=False)
def glow_shrooms(f):
    glow_mushrooms(0, 0, 9, 3, spread=.55, h=.3)
    parts.leaf_cluster(0, 0, .05, .7, 8, m_fern(), 2, size=(.1, .2), flat=.4)


@landmark('flo_fern_patch', group='nature', folder='ato2', size=(260, 190), origin=(130, 110), tags=('ato2', 'floresta_ancestral', 'samambaia'), footprint=0, collision=(), samples=16, catcher=False)
def fern_patch(f):
    parts.leaf_cluster(0, 0, .1, 1.0, 26, m_fern(), 7, size=(.12, .34), flat=.3)
    parts.leaf_cluster(.5, .4, .06, .6, 12, m_leaf_light(), 3, size=(.1, .2), flat=.5)


# ============================================================== LOC_FOREST_STONE_BRIDGE
def _bridge(broken):
    """Ponte de pedra (6 u ao longo de y, 2,8 u de largura): arco sob o tabuleiro, guarda-corpo, musgo e raízes."""
    st, sm, wd = m_stone_moss(), m_rock_moss(), M('wood_old')
    rr = random.Random(11 if broken else 10)
    # tabuleiro + muros frontais com VÃO de arco real (o rio aparece por baixo); aduelas no anel do arco
    geo.box((0, 0, 1.2), (2.5, 6.0, .34), st, bevel=0.05)
    for k in range(-2, 3):
        geo.box((0, k * 1.12, 1.4), (2.3, .9, .12), st, bevel=0.03)
    span = 1.75
    for sx in (-1, 1):
        n = 20
        for i in range(n):
            y = -3.0 + (i + .5) * 6.0 / n
            w = 6.0 / n
            if abs(y) < span:
                zb = .95 * math.sqrt(max(0.0, 1 - (y / span) ** 2)) - .05
                if 1.05 - zb > .05:
                    geo.box((sx * 1.15, y, (zb + 1.05) / 2 + .0), (.5, w + .02, 1.05 - zb), st, bevel=0.02)
            else:
                geo.box((sx * 1.15, y, .55), (.5, w + .02, 1.1), st, bevel=0.02)
        for k in range(11):                                    # aduelas do anel do arco
            a = math.pi * (k + .5) / 11
            geo.box((sx * 1.42, -math.cos(a) * span, .95 * math.sin(a) - .02), (.12, .42, .3), sm, rot=(a - math.pi / 2, 0, 0), bevel=0.02)
    parts.rubble(0, 0, 1.2, 4, sm, seed=2, rmin=.06, rmax=.14)
    # guarda-corpo: muretas com pilares; na versão quebrada faltam trechos
    for sx in (-1, 1):
        for i in range(7):
            y = -2.7 + i * .9
            if broken and sx == 1 and i in (2, 3, 4):
                parts.rubble(sx * 1.15, y, .4, 3, sm, seed=3 + i, rmin=.08, rmax=.2)
                continue
            geo.box((sx * 1.15, y, 1.7), (.3, .78, .5), st, bevel=0.04)
        for y in (-3.0, 3.0):
            geo.box((sx * 1.15, y, 1.65), (.42, .42, .95), st, bevel=0.05)
    # raízes atravessando a pedra e musgo no piso
    for k in range(4):
        root((rr.uniform(-1.2, 1.2), -2.8 + k * 1.7, 1.36), (rr.uniform(-1.4, 1.4), -2.2 + k * 1.7, 1.42), .07, .04, m_bark_old(), sag=-.05, sides=5)
    moss_patches(0, 0, 2.2, 5.6, 1.38, 22, 5)
    parts.hanging_vines(1.3, -2.6, 1.3, 2.6, 1.6, 1.0, 5, m_leaf_deep(), 6)
    for y in (-2.2, 2.4):
        geo.box((-1.1, y, 1.35), (.1, .5, .04), m_glow_dim(), bevel=0)       # runa de patrulha antiga (brilho discreto)
    geo.rotate_all(45)


@landmark('flo_bridge_span', group='nature', folder='ato2', size=(640, 460), origin=(320, 330), tags=('ato2', 'floresta_ancestral', 'ponte', 'fronteira', 'modular'), footprint=40, collision=circ([(-1.15, -3.0), (-1.15, -1.8), (-1.15, -.6), (-1.15, .6), (-1.15, 1.8), (-1.15, 3.0), (1.15, -3.0), (1.15, -1.8), (1.15, 1.8), (1.15, 3.0)], 10), samples=24)
def bridge_span(f):
    _bridge(False)


@landmark('flo_bridge_span_broken', group='nature', folder='ato2', size=(640, 460), origin=(320, 330), tags=('ato2', 'floresta_ancestral', 'ponte', 'fronteira', 'modular', 'guarda_corpo_quebrado'), footprint=40, collision=circ([(-1.15, -3.0), (-1.15, -1.8), (-1.15, -.6), (-1.15, .6), (-1.15, 1.8), (-1.15, 3.0), (1.15, -3.0), (1.15, 3.0)], 10), samples=24)
def bridge_span_broken(f):
    _bridge(True)


@landmark('flo_bridge_ramp', group='nature', folder='ato2', size=(560, 380), origin=(280, 270), tags=('ato2', 'floresta_ancestral', 'ponte', 'rampa', 'modular'), footprint=30, collision=circ([(-1.15, -1.0), (1.15, -1.0)], 10), samples=24)
def bridge_ramp(f):
    """Rampa de acesso da ponte: degraus largos de pedra afundando no chão, com raízes e musgo."""
    st, sm = m_stone_moss(), m_rock_moss()
    for k in range(5):
        geo.box((0, -1.7 + k * .6, .12 + k * .22), (2.5, .64, .24 + k * .22), st, bevel=0.04)
    for sx in (-1, 1):
        geo.box((sx * 1.15, -.5, .55), (.5, 3.0, 1.1), st, bevel=0.05)
        parts.rock_mass((sx * 1.3, -2.1, 0), (.8, .9, .7), sm, 21 + sx, subdiv=3, rough=.25, flat_top=False)
    root((-1.2, -1.9, .05), (.6, -1.5, .3), .1, .05, m_bark_old(), sag=.05)
    parts.leaf_cluster(0, -1.0, .2, 1.4, 14, m_fern(), 4, size=(.1, .2), flat=.5)
    geo.rotate_all(45)


@landmark('flo_border_marker', group='nature', folder='ato2', size=(200, 340), origin=(100, 270), tags=('ato2', 'floresta_ancestral', 'marco', 'fronteira', 'guardas'), footprint=12, collision=circ([(0, 0)], 9), samples=24)
def border_marker(f):
    """Marco de fronteira: pilar de pedra com emblema de folha dos Guardas Verdes, musgo e fita verde."""
    st = m_stone_moss()
    geo.box((0, 0, .18), (.9, .9, .36), st, bevel=0.05)
    parts.tapered_shaft(0, 0, .3, 2.3, .62, .5, st, seed=4)
    geo.box((0, 0, 2.4), (.7, .7, .22), st, bevel=0.04)
    geo.box((.36, 0, 1.55), (.05, .34, .5), M('gold'), bevel=0.01)          # emblema (folha) esculpido
    geo.box((.37, 0, 1.55), (.03, .1, .38), m_ranger_cloth(), bevel=0)
    parts.cloth_sheet((.34, -.1, 2.1), (.34, .1, 2.1), (.34, -.1, 1.45), (.34, .1, 1.45), m_ranger_cloth(), nu=3, nv=5, sag=.03, folds=.03, fold_n=2, phase=1)
    parts.ivy(.31, -.3, .31, .3, .3, 2.0, M('leaf'), seed=3, n=22)
    parts.leaf_cluster(0, 0, .1, .6, 8, m_fern(), 3, size=(.1, .18), flat=.4)
    geo.rotate_all(45)


@landmark('flo_rest_platform', group='nature', folder='ato2', size=(420, 340), origin=(210, 220), tags=('ato2', 'floresta_ancestral', 'descanso', 'ponte', 'guardas'), footprint=44, collision=fpr(2.2, 3.4), samples=24)
def rest_platform(f):
    """Pequena plataforma de descanso na margem: piso de lajes, banco de madeira, lanterna e caixa de patrulha."""
    st, wd = m_stone_moss(), M('wood_old')
    geo.box((0, 0, .1), (2.6, 3.6, .2), st, bevel=0.05)
    geo.box((-.7, 0, .5), (.5, 2.4, .1), wd, bevel=0.02)
    for sy in (-1.0, 1.0):
        geo.box((-.7, sy, .28), (.4, .12, .5), wd, bevel=0.02)
    geo.box((-1.0, 0, .85), (.08, 2.4, .5), wd, bevel=0.02)
    geo.box((.7, 1.1, .35), (.7, .5, .5), M('wood'), bevel=0.03)              # caixa de patrulha
    geo.cyl((1.0, -1.3, 0), .07, 1.8, M('wood_dark'), sides=6)
    lantern(1.0, -1.3, 1.7)
    moss_patches(0, 0, 2.2, 3.2, .2, 14, 5)
    parts.grass_tufts(1.1, 1.3, .6, 6, m_fern(), seed=3, h=.3)
    geo.rotate_all(45)


# ============================================================== LOC_FOREST_RANGER_LODGE
@landmark('flo_ranger_lodge', group='nature', folder='ato2', size=(820, 660), origin=(410, 480), tags=('ato2', 'floresta_ancestral', 'guardas_verdes', 'casa', 'hub'), footprint=110, collision=fpr(3.6, 5.6), samples=24)
def ranger_lodge(f):
    """Casa dos Guardas Verdes: base de pedra, paredes de tábuas e enxaimel, telhado de palha envelhecido, varanda; construída ENTRE duas árvores."""
    st, wd, wo, wdk = m_stone_moss(), M('wood_old'), M('wood'), M('wood_dark')
    rr = random.Random(21)
    W, D = 3.6, 5.4                                          # profundidade (x) × largura (y)
    geo.box((0, 0, .3), (W + .3, D + .3, .6), st, bevel=0.05)
    # paredes: tábuas + travamento de madeira escura
    geo.box((0, 0, 1.55), (W, D, 1.9), wo, bevel=0.03)
    for i in range(0, 7):
        y = -D / 2 + i * D / 6
        geo.box((W / 2 + .03, y, 1.55), (.1, .14, 1.95), wdk, bevel=0.01)
    geo.box((W / 2 + .03, 0, 2.45), (.1, D, .14), wdk, bevel=0.01)
    geo.box((W / 2 + .03, 0, .68), (.1, D, .12), wdk, bevel=0.01)
    # porta e janelas com brilho quente
    geo.box((W / 2 + .06, 0, 1.25), (.14, 1.0, 1.7), M('wood_dark'), bevel=0.03)
    for y in (-1.8, 1.8):
        geo.box((W / 2 + .05, y, 1.65), (.1, .9, .85), M('glass'), bevel=0.02)
        geo.box((W / 2 + .08, y, 1.65), (.06, .9, .8), wdk, bevel=0.02)
    # telhado de duas águas em palha velha com musgo e cumeeira
    r = m_roof_moss()
    geo.box((W / 4 + .25, 0, 3.15), (W / 2 + 1.05, D + .8, .22), r, rot=(0, .5, 0), bevel=0.04)
    geo.box((-W / 4 - .25, 0, 3.15), (W / 2 + 1.05, D + .8, .22), r, rot=(0, -.5, 0), bevel=0.04)
    geo.box((0, 0, 3.72), (.3, D + .85, .16), wdk, bevel=0.03)
    for sy in (-D / 2 - .4, D / 2 + .4):                         # oitões (empenas) fechando as pontas do telhado
        geo.box((0, sy, 2.95), (W + .2, .12, 1.1), wo, bevel=0.02)
    # varanda com corrimão e degraus
    geo.box((W / 2 + .9, 0, .28), (1.4, D - .6, .12), wo, bevel=0.02)
    for sy in (-D / 2 + .4, D / 2 - .4, 0):
        geo.box((W / 2 + 1.5, sy, .8), (.12, .12, 1.0), wdk, bevel=0.01)
    geo.box((W / 2 + 1.5, 0, 1.25), (.1, D - .6, .1), wdk, bevel=0.01)
    geo.box((W / 2 + 1.7, 0, .08), (.8, 1.8, .16), st, bevel=0.03)
    # fumaça de chaminé de pedra e ervas secando no beiral
    geo.box((-.6, D / 4, 3.6), (.7, .7, 1.4), st, bevel=0.04)
    for k in range(5):
        geo.cyl_between((W / 2 + 1.35, -1.6 + k * .8, 1.2), (W / 2 + 1.35, -1.6 + k * .8, .7), .015, M('rope'), sides=4)
        geo.cyl((W / 2 + 1.35, -1.6 + k * .8, .5), .08, .25, m_herb(), sides=6, r2=.03)
    torch(W / 2 + .3, 1.3, 1.7)
    parts.hanging_vines(-W / 2 + .1, -D / 2, -W / 2 + .1, D / 2, 3.5, .9, 6, m_leaf_deep(), 5)
    geo.rotate_all(45)


@landmark('flo_ranger_watch', group='nature', folder='ato2', size=(340, 540), origin=(170, 420), tags=('ato2', 'floresta_ancestral', 'guardas_verdes', 'observacao'), footprint=40, collision=circ([(-.7, -.7), (.7, -.7), (-.7, .7), (.7, .7)], 8), samples=24)
def ranger_watch(f):
    """Posto de observação baixo: estrado de madeira sobre quatro esteios, escada, parapeito e pano verde."""
    wd, wo, wdk = M('wood_old'), M('wood'), M('wood_dark')
    for sx in (-.9, .9):
        for sy in (-.9, .9):
            geo.cyl((sx, sy, 0), .13, 3.6, wdk, sides=6, r2=.1)
    for z in (1.2, 2.3):
        for sx in (-.9, .9):
            geo.beam((sx, -.9, z), (sx, .9, z + .3), .07, .07, wo, bevel=0.01)
    geo.box((0, 0, 3.55), (2.3, 2.3, .16), wd, bevel=0.03)
    for sy in (-1.1, 1.1):
        geo.box((0, sy, 4.1), (2.3, .08, .8), wo, bevel=0.02)
        geo.box((sy, 0, 4.1), (.08, 2.3, .8), wo, bevel=0.02)
    for sx in (-1.1, 1.1):
        for sy in (-1.1, 1.1):
            geo.cyl((sx, sy, 3.55), .07, 1.0, wdk, sides=6)
    parts.ladder(1.2, 0, 0, 3.55, wdk, wo, axis='y', spacing=.34, width=.5, tilt=.12)
    geo.cyl((-1.1, -1.1, 3.6), .04, 1.6, wdk, sides=5)
    parts.cloth_sheet((-1.1, -1.1, 5.1), (-1.1, -.3, 5.1), (-1.1, -1.1, 4.4), (-1.1, -.3, 4.4), m_ranger_cloth(), nu=4, nv=4, sag=.05, folds=.05, fold_n=2, phase=2)
    torch(1.15, 1.15, 3.7)
    moss_patches(0, 0, 2.0, 2.0, 3.64, 8, 3)
    geo.rotate_all(45)


@landmark('flo_ranger_shed', group='nature', folder='ato2', size=(420, 340), origin=(210, 230), tags=('ato2', 'floresta_ancestral', 'guardas_verdes', 'deposito'), footprint=46, collision=fpr(2.2, 3.0), samples=24)
def ranger_shed(f):
    wo, wdk, st = M('wood_old'), M('wood_dark'), m_stone_moss()
    geo.box((0, 0, .2), (2.3, 3.1, .4), st, bevel=0.04)
    geo.box((0, 0, 1.15), (2.0, 2.8, 1.5), wo, bevel=0.03)
    geo.box((1.03, 0, .95), (.1, 1.0, 1.2), wdk, bevel=0.02)
    geo.box((0, -.7, 2.15), (2.4, 1.9, .16), m_roof_moss(), rot=(.5, 0, 0), bevel=0.03)
    geo.box((0, .7, 2.15), (2.4, 1.9, .16), m_roof_moss(), rot=(-.5, 0, 0), bevel=0.03)
    for k in range(3):                                        # barris e sacas de suprimento encostados
        geo.cyl((1.2, -1.9 + k * .6, 0), .28, .6, wdk, sides=10)
    geo.box((-.8, 1.7, .3), (.6, .5, .45), m_sack(), bevel=0.05)
    geo.rotate_all(45)


@landmark('flo_herb_bench', group='nature', folder='ato2', size=(320, 250), origin=(160, 170), tags=('ato2', 'floresta_ancestral', 'guardas_verdes', 'ervas'), footprint=30, collision=fpr(1.0, 2.2), samples=24)
def herb_bench(f):
    wd, wdk = M('wood_old'), M('wood_dark')
    geo.box((0, 0, .75), (.9, 2.0, .1), wd, bevel=0.02)
    for sy in (-.85, .85):
        for sx in (-.3, .3):
            geo.box((sx, sy, .38), (.1, .1, .76), wdk, bevel=0.01)
    for k in range(4):                                        # ervas em maços, cestos e almofariz
        geo.cyl((0, -.7 + k * .45, .8), .12, .12, m_herb(), sides=6, r2=.16)
    geo.box((.2, .3, .9), (.28, .28, .16), M('wood_dark'), bevel=0.02)
    for sy in (-1.0, 1.0):
        geo.cyl((-.5, sy, 0), .05, 2.1, wdk, sides=5)
    geo.beam((-.5, -1.0, 2.05), (-.5, 1.0, 2.05), .05, .05, wdk, bevel=0.01)
    for k in range(6):
        y = -.8 + k * .32
        geo.cyl_between((-.5, y, 2.0), (-.5, y, 1.5), .01, M('rope'), sides=4)
        geo.cyl((-.5, y, 1.25), .07, .3, m_herb(), sides=6, r2=.03)
    geo.rotate_all(45)


@landmark('flo_map_table', group='nature', folder='ato2', size=(340, 280), origin=(170, 190), tags=('ato2', 'floresta_ancestral', 'guardas_verdes', 'mapa'), footprint=34, collision=fpr(1.2, 2.2), samples=24)
def map_table(f):
    wd, wdk = M('wood_old'), M('wood_dark')
    geo.box((0, 0, .85), (1.2, 2.1, .1), wd, bevel=0.02)
    for sy in (-.9, .9):
        for sx in (-.4, .4):
            geo.box((sx, sy, .42), (.12, .12, .84), wdk, bevel=0.01)
    geo.box((0, 0, .93), (.9, 1.7, .03), m_parchment(), bevel=0)
    for k in range(5):
        geo.box((-.2 + k * .1, -.5 + k * .28, .955), (.06, .16, .015), m_ink(), rot=(0, 0, k), bevel=0)
    geo.box((.3, .7, .97), (.12, .12, .1), M('iron'), bevel=0.01)            # peso de mapa
    for sy in (-1.15, 1.15):
        geo.cyl((-.45, sy, 0), .07, 2.6, wdk, sides=6)
    geo.box((-.45, 0, 2.62), (.5, 2.5, .08), m_canvas(), rot=(0, .25, 0), bevel=0.01)
    geo.rotate_all(45)


@landmark('flo_training_target', group='nature', folder='ato2', size=(200, 270), origin=(100, 200), tags=('ato2', 'floresta_ancestral', 'guardas_verdes', 'treino'), footprint=14, collision=circ([(0, 0)], 9), samples=24)
def training_target(f):
    wdk, sk = M('wood_dark'), m_straw()
    for sy in (-.5, .5):
        geo.beam((0, sy, 0), (.3, sy * .4, 1.5), .06, .06, wdk, bevel=0.01)
    geo.cyl((.28, 0, .6), .62, .16, sk, rot=(0, 90, 0), sides=20)
    for r, mtl in ((.62, m_straw()), (.46, m_red_rag()), (.3, m_straw()), (.14, m_red_rag())):
        geo.cyl((.36, 0, .6), r, .03, mtl, rot=(0, 90, 0), sides=20)
    for k in range(4):
        geo.cyl_between((.4 + k * .01, -.2 + k * .14, .6 + (k % 2) * .12), (-.3, -.3 + k * .18, .6 + (k % 2) * .24), .012, wdk, sides=4)
    geo.rotate_all(45)


@landmark('flo_weapon_rack_green', group='nature', folder='ato2', size=(260, 240), origin=(130, 170), tags=('ato2', 'floresta_ancestral', 'guardas_verdes', 'arsenal'), footprint=22, collision=fpr(.6, 2.0), samples=24)
def weapon_rack_green(f):
    wd, wdk, iron = M('wood_old'), M('wood_dark'), M('iron')
    for sy in (-.9, .9):
        geo.box((0, sy, .8), (.14, .14, 1.6), wdk, bevel=0.02)
    geo.box((0, 0, 1.5), (.14, 2.0, .12), wdk, bevel=0.02)
    geo.box((0, 0, .5), (.14, 2.0, .1), wdk, bevel=0.02)
    for k in range(4):                                        # arcos longos
        geo.cyl_between((.1, -.7 + k * .18, .5), (.16, -.6 + k * .18, 1.7), .025, wd, sides=5)
    for k in range(3):                                        # lanças
        y = .25 + k * .22
        geo.cyl_between((.1, y, .5), (.05, y, 2.1), .022, wd, sides=5)
        geo.box((.05, y, 2.15), (.05, .05, .2), iron, bevel=0.01)
    geo.box((.1, 0, .13), (.34, .5, .26), m_ranger_cloth(), bevel=0.03)   # aljava/pano
    geo.rotate_all(45)


def _palisade(broken):
    """Trecho de paliçada orgânica (3 u): estacas de tamanhos desiguais amarradas com corda e raízes; quebrada = falhas e estacas caídas."""
    rr = random.Random(41 if broken else 40)
    wdk, wo = M('wood_dark'), M('wood_old')
    n = 9
    for i in range(n):
        y = -1.6 + i * 3.2 / (n - 1)
        if broken and i in (3, 4, 5):
            if i == 4:
                geo.cyl_between((0, y - .3, .15), (.6, y + .3, .35), .1, wo, sides=6)
            continue
        h = rr.uniform(1.5, 2.3)
        geo.cyl((0, y, 0), .11, h, wo if i % 2 else wdk, sides=6, r2=.05)
    for z in (.6, 1.3):
        geo.beam((.11, -1.6, z), (.11, 1.6, z + .05), .04, .04, M('rope'), bevel=0.0)
    root((.08, -1.6, .05), (.08, -.4, .5), .05, .03, m_bark_old(), sag=.04, sides=5)
    parts.grass_tufts(0, 0, 1.6, 8, m_fern(), seed=3, h=.25)
    geo.rotate_all(45)


@landmark('flo_palisade_organic', group='nature', folder='ato2', size=(360, 260), origin=(180, 170), tags=('ato2', 'floresta_ancestral', 'guardas_verdes', 'palicada', 'modular'), footprint=30, collision=fpr(.5, 3.2), samples=24)
def palisade_organic(f):
    _palisade(False)


@landmark('flo_palisade_broken', group='nature', folder='ato2', size=(360, 260), origin=(180, 170), tags=('ato2', 'floresta_ancestral', 'guardas_verdes', 'palicada', 'modular', 'ataque'), footprint=30, collision=fpr(.5, 3.2), samples=24)
def palisade_broken(f):
    _palisade(True)


@landmark('flo_barricade_improvised', group='nature', folder='ato2', size=(360, 260), origin=(180, 170), tags=('ato2', 'floresta_ancestral', 'guardas_verdes', 'barricada', 'pre_defesa'), footprint=34, collision=fpr(.9, 3.0), samples=24)
def barricade_improvised(f):
    """Barricada improvisada (estado pré-defesa): troncos empilhados, estacas inclinadas, carroça velha e pano rasgado."""
    rr = random.Random(50)
    wdk, wo = M('wood_dark'), M('bark_log')
    for k in range(3):
        geo.cyl((0, -1.4, .25 + k * .3), .22, 2.9, wo, rot=(90, 0, 0), sides=8)
    for k in range(6):
        y = -1.2 + k * .5
        geo.cyl_between((.5, y, .1), (-.2, y + rr.uniform(-.1, .1), 1.7 + rr.uniform(0, .3)), .07, wdk, sides=5, r2=.03)
    geo.box((.6, .3, .45), (.1, 1.0, .5), M('wood_old'), rot=(0, .3, .2), bevel=0.02)
    parts.cloth_sheet((.55, -.4, 1.5), (.55, .2, 1.5), (.55, -.4, .9), (.55, .2, .9), m_red_rag(), nu=3, nv=4, sag=.04, folds=.05, fold_n=2, phase=1)
    parts.rubble(.9, 0, 1.2, 6, m_rock_moss(), seed=3, rmin=.06, rmax=.16)
    geo.rotate_all(45)
