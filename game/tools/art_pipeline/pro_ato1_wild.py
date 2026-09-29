"""Lote 1 / Ato I — fora da cidade: Estrada Norte, Ruínas do Primeiro Vento, Clareira do Alfa. IDs persistentes val_*."""
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
from pro_nature import trunk, branch
from ato1_common import *


def circ(points, r):
    return tuple((round(.7071 * (Y - X) * S, 1), round(.5 * .7071 * (X + Y) * S, 1), r) for (X, Y) in points)


# ============================================================== LOC_VAL_NORTH_ROAD
@landmark('val_cart_wrecked', group='nature', folder='ato1', size=(380, 300), origin=(190, 200), tags=('ato1', 'estrada_norte', 'carroca', 'ataque'), footprint=34, collision=circ([(-.5, 0), (.5, .2)], 12), samples=24)
def cart_wrecked(f):
    wd, wo, iron = M('wood_dark'), M('wood'), M('iron')
    rr = random.Random(4)
    # carroça tombada de lado: caixa inclinada, uma roda solta, eixo quebrado, carga espalhada
    geo.box((0, 0, .55), (2.2, 1.3, .18), wo, rot=(.5, 0, .12), bevel=0.03)
    for k in range(4):
        geo.box((-.9 + k * .6, .5, .95), (.1, .1, .8), wd, rot=(.5, 0, .1), bevel=0.02)
    geo.box((0, .7, 1.2), (2.2, .08, .3), wo, rot=(.5, 0, .12), bevel=0.02)
    for x in (-.7, .8):
        geo.cyl((x, -.7, .5), .62, .09, wd, rot=(90, 0, 0), sides=14)
        geo.cyl((x, -.7, .5), .1, .16, iron, rot=(90, 0, 0), sides=8)
        for k in range(4):
            a = k * math.pi / 4
            geo.box((x, -.72, .5), (1.2, .06, .07), wd, rot=(0, a, 0), bevel=0)
    geo.cyl((1.7, 1.0, .1), .5, .08, wd, rot=(0, 0, 0), sides=12)
    geo.beam((-1.2, -.2, .3), (-2.0, -.6, .12), .07, .06, wd, bevel=0.01)
    for i, (x, y) in enumerate(((1.1, .9), (1.5, -.4), (-.4, 1.3))):
        geo.box((x, y, .22), (.5, .5, .44), wo, rot=(0, 0, rr.uniform(-.6, .6)), bevel=0.03)
    for x, y in ((1.3, 1.5), (.7, 1.7), (2.0, .2)):
        ball((x, y, .2), .26, m_sack(), squash=.7)
    geo.box((1.3, 1.1, .02), (.9, .7, .03), m_blood(), bevel=0)
    parts.rubble(0, 0, 1.6, 7, wd, seed=5, rmin=.05, rmax=.14)
    parts.grass_tufts(0, 0, 1.6, 10, M('leaf_dry'), seed=2, h=.22)


@landmark('val_warning_post', group='nature', folder='ato1', size=(220, 360), origin=(110, 290), tags=('ato1', 'estrada_norte', 'placa', 'aviso'), blocks=6, footprint=8, samples=24)
def warning_post(f):
    wd, wo = M('wood_dark'), M('wood')
    geo.cyl((0, 0, 0), .11, 2.6, wd, sides=8, r2=.09)
    geo.box((.1, 0, 2.15), (.08, 1.2, .55), wo, bevel=0.02)
    geo.box((.15, 0, 2.15), (.03, .95, .07), m_red_rag(), rot=(0, 0, 0), bevel=0)
    geo.box((.15, .2, 2.15), (.03, .07, .4), m_red_rag(), bevel=0)
    geo.beam((.1, -.4, 1.5), (.1, .6, 1.7), .04, .04, wo, bevel=0.005)
    parts.cloth_sheet((.12, -.05, 1.75), (.12, .35, 1.75), (.16, -.05, 1.0), (.16, .35, 1.1), M('cloth_red'), nu=4, nv=8, sag=.02, folds=.06, fold_n=2)
    ball((.12, -.3, 1.05), .17, m_bone(), squash=.85)                  # crânio de lobo espetado
    geo.box((.24, -.3, .98), (.16, .1, .07), m_bone(), bevel=0.01)
    geo.cyl((0, 0, 0), .3, .16, M('stone'), sides=8, r2=.22)
    parts.rubble(0, 0, .5, 5, M('rock'), seed=2, rmin=.05, rmax=.13)


@landmark('val_palisade_broken', group='nature', folder='ato1', size=(340, 260), origin=(170, 170), tags=('ato1', 'estrada_norte', 'cerca', 'quebrada'), footprint=28, collision=circ([(-1.0, 0), (1.0, 0)], 9), samples=24)
def palisade_broken(f):
    wd, wo = M('wood_dark'), M('wood')
    rr = random.Random(8)
    for i in range(9):
        x = -1.6 + i * .4
        if i in (4, 5):
            geo.cyl_between((x, .2, 0), (x + .7, .5, .16), .08, wd, sides=6, r2=.05)
            continue
        h = 1.3 + rr.uniform(-.25, .1)
        geo.cyl_between((x, 0, 0), (x + rr.uniform(-.08, .1), 0, h), .08, wd, sides=6, r2=.03)
    geo.beam((-1.7, .12, .5), (-.3, .12, .55), .06, .06, wo, bevel=0.01)
    geo.beam((.4, .12, .9), (1.7, .12, .85), .06, .06, wo, bevel=0.01)
    for k in range(3):                     # arranhões de garras: três sulcos claros
        geo.beam((-1.2 + k * .07, -.09, .95), (-1.05 + k * .07, -.09, .45), .012, .012, M('wood_old'), bevel=0)
    parts.rubble(0, 0, 1.4, 6, wd, seed=3, rmin=.04, rmax=.12)


@landmark('val_wolf_bones', group='nature', folder='ato1', size=(240, 180), origin=(120, 110), tags=('ato1', 'estrada_norte', 'ossos', 'lobo'), footprint=10, collision=(), samples=24)
def wolf_bones(f):
    rr = random.Random(11)
    bone = m_bone()
    ball((0, 0, .1), .32, bone, squash=.6)                              # crânio
    geo.box((.35, 0, .07), (.3, .16, .1), bone, bevel=0.01)             # focinho
    for k in range(7):                                                  # costelas
        a = rr.uniform(-.3, .3)
        geo.cyl_between((-.5 - k * .16, -.5, .03), (-.5 - k * .16 + a * .3, .1, .3), .022, bone, sides=5)
        geo.cyl_between((-.5 - k * .16, .5, .03), (-.5 - k * .16 + a * .3, -.1, .3), .022, bone, sides=5)
    geo.cyl_between((-.5, 0, .04), (-1.6, 0, .05), .04, bone, sides=6)  # coluna
    for x, y in ((.4, .7), (-.2, -.9), (-1.2, .9)):
        geo.cyl_between((x, y, .03), (x + .5, y + .1, .05), .03, bone, sides=5)
    geo.box((-.7, .2, .01), (1.0, .7, .02), m_blood(), bevel=0)
    for k in range(6):                                                  # tufos de pelo
        ball((rr.uniform(-1.3, .2), rr.uniform(-.6, .6), .02), .07, M('rock_grey'), squash=.3)
    parts.grass_tufts(-.5, 0, 1.0, 5, M('leaf_dry'), seed=3, h=.15)


@landmark('val_camp_remains', group='nature', folder='ato1', size=(320, 260), origin=(160, 170), tags=('ato1', 'estrada_norte', 'acampamento', 'abandonado'), footprint=24, collision=circ([(-.6, .3)], 10), samples=24)
def camp_remains(f):
    wd, wo = M('wood_dark'), M('wood')
    # tenda rasgada, meio caída, com um mastro quebrado
    parts.cloth_sheet((-1.2, -.9, .1), (.9, -.9, .1), (-1.0, 0, 1.2), (.7, 0, 1.0), m_canvas(), nu=10, nv=6, sag=.05, folds=.08, fold_n=4)
    parts.cloth_sheet((-1.0, 0, 1.2), (.7, 0, 1.0), (-1.3, .9, .12), (.9, .9, .2), m_canvas(), nu=10, nv=6, sag=.1, folds=.08, fold_n=3, phase=1.4)
    geo.beam((-1.0, 0, 1.2), (-1.0, .35, .5), .05, .04, wd, bevel=0.01)
    # fogueira apagada: pedras, lenha carbonizada, cinza
    for k in range(8):
        a = k * .785
        geo.box((1.5 + math.cos(a) * .4, .4 + math.sin(a) * .4, .08), (.2, .16, .16), M('rock'), rot=(0, 0, a), bevel=0.03)
    for k in range(4):
        geo.cyl_between((1.3 + k * .07, .3, .1), (1.75, .5 + k * .05, .16), .04, m_scorch(), sides=5)
    geo.cyl((1.5, .4, .0), .3, .02, M('rock_grey'), sides=12)
    # marmita virada, rolo de dormir, bota e caixa aberta
    geo.cyl((2.0, -.4, .05), .13, .14, M('iron'), rot=(80, 0, 0), sides=10)
    geo.cyl((.6, 1.2, .1), .14, .8, M('cloth_red'), rot=(0, 90, .3), sides=8)
    geo.box((-.4, 1.3, .15), (.4, .3, .3), wo, rot=(0, 0, .5), bevel=0.02)
    geo.box((1.0, 1.5, .01), (.8, .5, .02), m_blood(), bevel=0)
    parts.grass_tufts(0, 0, 1.6, 8, M('leaf_dry'), seed=4, h=.18)


@landmark('val_paw_tracks', group='nature', folder='ato1', size=(280, 160), origin=(140, 80), tags=('ato1', 'estrada_norte', 'rastros', 'decalque'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def paw_tracks(f):
    rr = random.Random(2)
    dirt = m_dirt_dark()
    geo.box((0, 0, .0), (3.8, 1.6, .02), dirt, bevel=0)
    for i in range(6):
        x, y = -1.6 + i * .64, (.3 if i % 2 else -.3) + rr.uniform(-.06, .06)
        geo.cyl((x, y, .01), .13, .03, m_scorch(), sides=8)
        for k in (-1, 0, 1):
            geo.cyl((x + .16, y + k * .11, .01), .05, .03, m_scorch(), sides=6)


# ============================================================== LOC_FIRST_WIND_RUINS
def _glow_lines(x, z0, y0, y1, n, mat, seed):
    rr = random.Random(seed)
    for i in range(n):
        z = z0 + i * .3
        L = rr.uniform(.3, y1 - y0)
        geo.box((x, y0 + L / 2 + rr.uniform(0, .2), z), (.03, L, .04), mat, bevel=0)
        if rr.random() < .6:
            geo.box((x, y0 + rr.uniform(.1, y1 - y0), z + .12), (.03, .04, .22), mat, bevel=0)


@landmark('val_ruin_mechanism', group='nature', folder='ato1', size=(260, 340), origin=(130, 250), tags=('ato1', 'ruinas', 'mecanismo', 'eco', 'first_wind'), footprint=20, collision=circ([(0, 0)], 11), samples=24)
def ruin_mechanism(f):
    rk = M('rock_grey')
    geo.cyl((0, 0, 0), .8, .25, rk, sides=10, r2=.7)                    # base circular gasta
    parts.rock_mass((0, 0, .2), (.75, .75, 1.0), rk, 21, subdiv=3, rough=.12, taper=.12, flat_top=True)
    geo.box((0, 0, 1.25), (.9, .9, .12), rk, bevel=0.03)
    # placa central com anel e oito raios de Eco (símbolos de um caminho entre mundos), aceso
    geo.cyl((0, 0, 1.31), .36, .04, mats.flat('plate', '#2c2a3c', rough=.8, bevel_wear=0), sides=24)
    geo.cyl((0, 0, 1.34), .3, .02, m_eco(), sides=24, r2=.3)
    geo.cyl((0, 0, 1.36), .24, .02, mats.flat('plate2', '#2c2a3c', rough=.8, bevel_wear=0), sides=24)
    for k in range(8):
        a = k * math.pi / 4
        geo.box((math.cos(a) * .17, math.sin(a) * .17, 1.38), (.22, .03, .02), m_eco(), rot=(0, 0, a), bevel=0)
    for k in range(4):                                                   # pilares baixos e raízes invasoras
        a = k * math.pi / 2 + .4
        geo.box((math.cos(a) * .7, math.sin(a) * .7, .5), (.18, .18, .9), rk, rot=(0, 0, a), bevel=0.03)
    parts.hanging_vines(.55, -.5, .55, .5, 1.0, .8, 4, M('leaf'), 3)
    parts.leaf_cluster(-.5, .4, .25, .3, 14, M('leaf'), 8, size=(.08, .13), flat=.5)
    parts.rubble(0, 0, 1.1, 6, rk, seed=3, rmin=.06, rmax=.16)


@landmark('val_ruin_inscription_wall', group='nature', folder='ato1', size=(400, 340), origin=(200, 250), tags=('ato1', 'ruinas', 'inscricao', 'eco', 'first_wind', 'a_vale'), footprint=36, collision=circ([(-.2, -1.1), (-.2, 0), (-.2, 1.1)], 10), samples=24)
def ruin_inscription_wall(f):
    rk = M('rock_grey')
    rr = random.Random(31)
    parts.rock_mass((0, 0, 0), (.7, 3.4, 2.1), rk, 32, subdiv=4, rough=.14, terrace=.1, taper=.06, flat_top=False)
    geo.box((.36, 0, 1.0), (.05, 2.8, 1.5), mats.flat('mural', '#34324a', rough=.8, bevel_wear=0), bevel=0)
    # linhas de inscrição em Eco (acesas) — o final é interrompido: assinatura danificada
    for r in range(5):
        z = 1.55 - r * .28
        x0 = -1.3
        while x0 < 1.15:
            L = rr.uniform(.12, .38)
            geo.box((.4, x0 + L / 2, z), (.03, L, .05), m_eco() if r < 4 else m_eco_dim(), bevel=0)
            x0 += L + rr.uniform(.06, .12)
    geo.box((.4, .9, .44), (.03, .55, .06), m_eco_dim(), bevel=0)         # 'assinatura' curta e rachada
    geo.box((.39, .9, .44), (.02, .04, .3), M('rock_grey'), rot=(0, 0, 0), bevel=0)
    parts.hanging_vines(.4, -1.6, .4, 1.6, 2.1, 1.1, 6, M('leaf'), 5)
    parts.leaf_cluster(0, 1.4, 2.1, .4, 16, M('leaf'), 6, size=(.08, .13), flat=.5)
    parts.rubble(.4, 0, 1.9, 8, rk, seed=4, rmin=.07, rmax=.2)


@landmark('val_ruin_root_arch', group='nature', folder='ato1', size=(420, 420), origin=(210, 330), tags=('ato1', 'ruinas', 'arco', 'raizes', 'first_wind'), footprint=44, collision=circ([(0, -1.5), (0, 1.5)], 12), samples=24)
def ruin_root_arch(f):
    rk, bark = M('rock_grey'), M('bark_tree')
    rr = random.Random(41)
    for sy in (-1.5, 1.5):
        geo.box((0, sy, 1.4), (.7, .8, 2.8), rk, bevel=0.06)
        geo.box((0, sy, 2.85), (.9, 1.0, .2), rk, bevel=0.04)
    geo.box((0, 0, 3.15), (.7, 3.8, .55), rk, bevel=0.06)
    for k in range(5):                                                     # aduelas do arco (uma caída)
        y = -1.2 + k * .6
        if k == 3:
            geo.box((.8, .9, .3), (.5, .5, .4), rk, rot=(0, 0, .5), bevel=0.05)
            continue
        geo.box((0, y, 3.75), (.7, .5, .35 + (.15 if k == 2 else 0)), rk, bevel=0.04)
    for sy in (-1.5, 1.5):                                                 # raízes agarradas ao arco
        for k in range(4):
            a = rr.uniform(-.4, .4)
            geo.cyl_between((.4, sy + a, 0), (.4 + rr.uniform(-.1, .1), sy * .55 + a * 2, 3.3 + rr.uniform(-.2, .3)), .09, bark, sides=6, r2=.04)
    parts.hanging_vines(.4, -1.8, .4, 1.8, 3.4, 1.4, 8, M('leaf'), 3)
    for sy in (-1.5, 1.5):
        parts.leaf_cluster(0, sy, 3.05, .4, 18, M('leaf'), 7 + int(sy), size=(.08, .14), flat=.5)
    geo.box((.42, -1.5, 1.3), (.03, .5, .7), m_eco_dim(), bevel=0)         # runa gasta no pilar
    parts.rubble(.5, 0, 2.2, 10, rk, seed=5, rmin=.07, rmax=.22)


@landmark('val_ruin_floor_circle', group='nature', folder='ato1', size=(420, 260), origin=(210, 130), tags=('ato1', 'ruinas', 'piso', 'decalque', 'first_wind'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def ruin_floor_circle(f):
    rk = M('rock_grey')
    rr = random.Random(51)
    geo.cyl((0, 0, 0), 3.4, .04, mats.flat('under', '#2c2a38', rough=1, bevel_wear=0), sides=32)
    for i in range(-5, 6):
        for j in range(-5, 6):
            x, y = i * .58, j * .58
            if math.hypot(x, y) > 3.0 or rr.random() < .18:
                continue
            geo.box((x, y, .04 + rr.uniform(0, .02)), (.52, .52, .05), rk, rot=(0, 0, rr.uniform(-.04, .04)), bevel=0.01)
    for ring in (1.3, 2.3):                                                # anéis gravados
        for k in range(40):
            a = k * 2 * math.pi / 40
            if rr.random() < .3:
                continue
            geo.box((math.cos(a) * ring, math.sin(a) * ring, .085), (.14, .05, .02), m_eco_dim(), rot=(0, 0, a + math.pi / 2), bevel=0)
    for k in range(8):                                                     # rachaduras e musgo
        a = rr.uniform(0, 6.28)
        geo.cyl_between((math.cos(a) * .4, math.sin(a) * .4, .09), (math.cos(a + .2) * 2.8, math.sin(a + .2) * 2.8, .09), .018, M('hole'), sides=4)
    for k in range(10):
        parts.leaf_cluster(rr.uniform(-2.6, 2.6), rr.uniform(-2.6, 2.6), .1, .22, 8, M('leaf'), 60 + k, size=(.05, .09), flat=.3)


# ============================================================== LOC_ALPHA_CLEARING
@landmark('val_wolf_den', group='nature', folder='ato1', size=(440, 360), origin=(220, 250), tags=('ato1', 'clareira_do_alfa', 'toca', 'matilha'), footprint=44, collision=circ([(-.6, -1.0), (-.6, 1.0), (.2, -1.3), (.2, 1.3)], 12), samples=24)
def wolf_den(f):
    rk, bone = M('rock'), m_bone()
    body = parts.rock_mass((0, 0, 0), (3.0, 3.4, 2.0), rk, 61, subdiv=4, rough=.32, terrace=.3, step=.4, taper=.14, flat_top=True)
    cut = geo.box((1.0, 0, .55), (2.4, 1.5, 1.1), M('hole'), bevel=0)
    top = geo.cyl((-.2, 0, 1.1), .75, 2.4, M('hole'), rot=(0, 90, 0), sides=12)
    geo.join([cut, top], 'dcut')
    geo.boolean_cut(body, bpy.data.objects['dcut'], M('hole'))
    parts.slab_blob(-.1, 0, 2.0, 2.7, 3.0, .25, M('turf'), 62)
    parts.leaf_cluster(-.3, .6, 2.3, .4, 20, M('leaf'), 63, size=(.1, .16), flat=.6)
    parts.hanging_vines(1.5, -.8, 1.5, .8, 1.95, .8, 5, M('leaf'), 4)
    rr = random.Random(9)
    for k in range(9):                                                     # ossos e crânios na boca da toca
        x, y = 1.6 + rr.uniform(0, .9), rr.uniform(-1.1, 1.1)
        if k % 3 == 0:
            ball((x, y, .12), .16, bone, squash=.7)
        else:
            geo.cyl_between((x, y, .05), (x + rr.uniform(-.3, .3), y + rr.uniform(-.3, .3), .07), .03, bone, sides=5)
    geo.box((1.9, 0, .01), (1.2, 1.0, .02), m_dirt_dark(), bevel=0)
    for k in range(3):                                                     # arranhões na rocha
        geo.beam((1.51, -1.3 + k * .09, 1.5), (1.51, -1.2 + k * .09, .8), .012, .012, M('rock_grey'), bevel=0)
    geo.cyl((1.9, 0, .2), .0, .0, M('hole'), sides=3) if False else None
    ball((1.6, 0, .18), .08, M('glass_ice'), squash=1.0)


@landmark('val_pack_bones', group='nature', folder='ato1', size=(300, 200), origin=(150, 120), tags=('ato1', 'clareira_do_alfa', 'ossos', 'territorio'), footprint=18, collision=circ([(0, 0)], 8), samples=24)
def pack_bones(f):
    rr = random.Random(13)
    bone = m_bone()
    for k in range(3):
        ball((rr.uniform(-.7, .7), rr.uniform(-.5, .5), .12 + k * .1), .22, bone, squash=.7)
        geo.box((rr.uniform(-.6, .6), rr.uniform(-.4, .4), .1), (.28, .15, .12), bone, rot=(0, 0, rr.uniform(0, 3)), bevel=0.01)
    for k in range(14):
        a = rr.uniform(0, 6.28)
        r = rr.uniform(.2, 1.1)
        geo.cyl_between((math.cos(a) * r, math.sin(a) * r, .04), (math.cos(a) * r + rr.uniform(-.4, .4), math.sin(a) * r + rr.uniform(-.4, .4), .06 + rr.random() * .1), .03, bone, sides=5)
    geo.cyl_between((-.5, -.5, 0), (.4, .6, 1.5), .05, M('bark_dead'), sides=6, r2=.03)     # galhada/osso espetado
    geo.cyl_between((.5, -.4, 0), (.2, .5, 1.3), .05, M('bark_dead'), sides=6, r2=.03)
    ball((0, 0, 1.55), .2, bone, squash=.8)
    geo.box((-.2, .3, .01), (1.2, .8, .02), m_blood(), bevel=0)


@landmark('val_trampled_earth', group='nature', folder='ato1', size=(420, 260), origin=(210, 130), tags=('ato1', 'clareira_do_alfa', 'solo', 'decalque'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def trampled_earth(f):
    rr = random.Random(71)
    geo.cyl((0, 0, 0), 3.2, .03, m_dirt_dark(), sides=28)
    for k in range(9):
        a = rr.uniform(0, 6.28)
        r = rr.uniform(.4, 2.6)
        geo.cyl((math.cos(a) * r, math.sin(a) * r, .02), rr.uniform(.25, .6), .02, M('dirt'), sides=10)
    for k in range(16):
        a = rr.uniform(0, 6.28)
        r = rr.uniform(.5, 2.8)
        x, y = math.cos(a) * r, math.sin(a) * r
        geo.cyl((x, y, .03), .12, .03, m_scorch(), sides=8)
        for q in (-1, 0, 1):
            geo.cyl((x + .15, y + q * .1, .03), .045, .03, m_scorch(), sides=6)
    for k in range(6):
        parts.grass_tufts(rr.uniform(-2.5, 2.5), rr.uniform(-2.5, 2.5), .3, 3, M('leaf_dry'), seed=80 + k, h=.14)
