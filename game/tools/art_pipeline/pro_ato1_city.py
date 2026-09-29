"""Lote 1 / Ato I — cidade: Portão de Valedouro (portão, torres, muralha), Guilda dos Aventureiros e Arquivo das Seis Coroas.
Arquitetura frontal (modelada em +x e girada 45°) para casar com a muralha/casas APPROVED. IDs persistentes val_*."""
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


def fp(sx, sy, ox=0.0, oy=0.0, step=.9):
    """Colisão em círculos (px de jogo) de um retângulo sx×sy (unidades), depois de girar 45°: mesma projeção de terrain_forms_data."""
    from terrain_forms_data import footprint_circles
    return footprint_circles(sx, sy, step, .9)


# ============================================================== LOC_VAL_GATE
@landmark('val_gate_main', group='city', folder='ato1', size=(620, 600), origin=(310, 470), tags=('ato1', 'portao', 'fortificacao', 'val_gate'), footprint=70, collision=fp(6.6, 1.6), samples=24)
def gate_main(f):
    st, wd, wo, iron = M('stone'), M('wood_dark'), M('wood_old'), M('iron')
    # dois pilares de pedra + verga (sem booleana): vão de 2,7 u; recuo escuro atrás das folhas
    for sy in (-2.35, 2.35):
        geo.box((0, sy, 1.75), (1.6, 1.9, 3.5), st, bevel=0.06)
    geo.box((0, 0, 3.0), (1.6, 2.9, 1.0), st, bevel=0.06)
    geo.box((-.6, 0, 1.3), (.3, 2.8, 2.6), M('hole'), bevel=0)
    for k in range(7):        # aduelas em arco por cima das folhas
        a = math.radians(-70 + k * 23.3)
        geo.box((.8, math.sin(a) * 1.5, 2.55 + math.cos(a) * .55), (.26, .5, .4), M('stone_sand'), rot=(a, 0, 0), bevel=0.03)
    # base em talude e cordão de pedra
    geo.box((0, 0, .18), (1.9, 7.0, .36), st, bevel=0.05)
    geo.box((0, 0, 3.55), (1.95, 6.9, .2), st, bevel=0.04)
    # adarve com piso de tábuas e ameias dos dois lados
    geo.box((0, 0, 3.68), (1.5, 6.5, .1), M('wood'), bevel=0.01)
    crenels(.82, -3.3, 3.3, 3.62, st, 13, depth=.32, h=.5)
    crenels(-.82, -3.3, 3.3, 3.62, st, 13, depth=.32, h=.5)
    # cantoneiras claras nos cantos e no vão
    for sy in (-3.35, 3.35):
        for k in range(6):
            geo.box((.82, sy, .35 + k * .56), (.22, .34, .28), M('stone_sand'), bevel=0.03)
    for sy in (-1.45, 1.45):
        for k in range(5):
            geo.box((.82, sy, .3 + k * .5), (.24, .3, .26), M('stone_sand'), bevel=0.03)
    # folhas do portão: madeira reforçada com cintas de ferro, rebites, argolas, alças
    for sy in (-.68, .68):
        geo.box((.66, sy, 1.2), (.16, 1.28, 2.4), wo, bevel=0.03)
        for z in (.45, 1.2, 1.95):
            geo.box((.76, sy, z), (.06, 1.3, .14), iron, bevel=0.01)
            for k in range(4):
                geo.cyl((.8, sy - .5 + k * .33, z), .035, .03, iron, rot=(0, 90, 0), sides=6)
        geo.box((.78, sy * .18, 1.15), (.06, .05, 2.2), iron, bevel=0.01)
    geo.cyl((.82, -.16, 1.1), .1, .04, iron, rot=(0, 90, 0), sides=10)
    geo.cyl((.82, .16, 1.1), .1, .04, iron, rot=(0, 90, 0), sides=10)
    # grade-ferro subida (rastrilho) atrás e mecanismo de abertura: cabine de madeira + tambor + correntes
    for k in range(-2, 3):
        geo.box((-.35, k * .5, 2.75), (.05, .06, .9), iron, bevel=0.005)
    geo.box((0, 0, 4.25), (1.3, 1.5, .95), wd, bevel=0.03)
    geo.roof_gable(0, 0, 4.7, 1.3, 1.5, .55, M('roof_slate'), overhang=.15, ridge_axis='y')
    geo.cyl((.72, 0, 4.15), .22, .9, wo, rot=(90, 0, 0), sides=12)
    geo.cyl_between((.78, .35, 4.0), (.62, .5, 2.7), .02, iron, sides=4)
    geo.cyl_between((.78, -.35, 4.0), (.62, -.5, 2.7), .02, iron, sides=4)
    # estandartes de Valedouro, tochas e lanternas
    for sy in (-2.5, 2.5):
        banner(.86, sy, 3.3, 1.7, .9, seed=sy)
        torch(.86, sy * .64, 1.9)
    lantern(.95, 0, 2.95)
    # marcas de ataque antigo: fuligem, remendo de tábuas e entulho
    geo.box((.83, 2.2, 2.6), (.04, .9, .8), m_scorch(), rot=(0, 0, 0), bevel=0)
    geo.box((.83, -2.7, 1.0), (.04, .6, .5), m_scorch(), bevel=0)
    for k in range(3):
        geo.box((.86, -2.2 + k * .3, .9), (.05, .24, 1.2), M('wood_old'), rot=(0, 0, 0), bevel=0.01)
    parts.rubble(.9, 2.6, 1.3, 8, st, seed=3, rmin=.08, rmax=.22)
    steps(.9, 0, 3.4, 3, rise=.12, run=.34, mat=st)
    geo.rotate_all(45)


@landmark('val_gate_tower', group='city', folder='ato1', size=(520, 720), origin=(260, 560), tags=('ato1', 'torre', 'guarita', 'val_gate'), footprint=44, collision=fp(2.6, 2.6), samples=24)
def gate_tower(f):
    st, wd, wo, iron = M('stone'), M('wood_dark'), M('wood_old'), M('iron')
    geo.box((0, 0, .2), (3.1, 3.1, .4), st, bevel=0.05)
    body = parts.tapered_shaft(0, 0, .3, 4.4, 2.8, 2.5, st, seed=11)
    parts.quoins(0, 0, .3, 4.4, 2.8, 2.5, M('stone_sand'), seed=12)
    # frestas de arqueiro e porta de serviço
    for z in (1.5, 2.7):
        geo.box((1.32, 0, z), (.12, .18, .7), M('hole'), bevel=0)
    geo.box((1.4, 0, .85), (.3, .95, 1.6), wd, bevel=0.03)
    geo.box((1.55, 0, 1.75), (.2, 1.15, .18), M('stone_sand'), bevel=0.03)
    # coroamento: matacães (mísulas) e plataforma de vigia em balanço com parapeito e ameias
    for i in range(-4, 5):
        geo.box((1.3, i * .3, 4.25), (.32, .22, .3), st, bevel=0.03)
        geo.box((i * .3, 1.3, 4.25), (.22, .32, .3), st, bevel=0.03)
    geo.box((0, 0, 4.45), (3.3, 3.3, .14), st, bevel=0.03)
    crenels(1.55, -1.55, 1.55, 4.52, st, 9, depth=.34, h=.5)
    crenels(-1.55, -1.55, 1.55, 4.52, st, 9, depth=.34, h=.5)
    crenels_x(1.55, -1.55, 1.55, 4.52, st, 9, depth=.34, h=.5)
    crenels_x(-1.55, -1.55, 1.55, 4.52, st, 9, depth=.34, h=.5)
    # guarita de madeira coberta sobre a plataforma (posto de vigia) com telhado azul
    for sx, sy in ((-.8, -.8), (.8, -.8), (.8, .8), (-.8, .8)):
        geo.box((sx, sy, 5.3), (.14, .14, 1.5), wd, bevel=0.02)
    geo.box((0, -.8, 5.0), (1.6, .06, .9), wo, bevel=0.01)
    geo.box((-.8, 0, 5.0), (.06, 1.6, .9), wo, bevel=0.01)
    geo.roof_pyramid(0, 0, 6.0, 1.35, .9, m_roof_blue(), sides=4, rot=45, overhang=.28, thickness=.08)
    geo.cyl((0, 0, 6.85), .05, .55, wd, sides=6)
    banner(.02, .0, 6.4, .0, .01) if False else None
    # bandeira no topo e brasseiro do vigia
    parts.flag(0, 0, 7.4, 1.1, .6, M('cloth_blue'), phase=1.0)
    geo.cyl((1.2, 1.2, 4.52), .22, .12, iron, sides=8, r2=.3)
    ball((1.2, 1.2, 4.85), .2, M('fire'), squash=1.4)
    # escada de mão externa e caixas de suprimento ao pé
    for k in range(9):
        geo.box((1.36, -1.25, .3 + k * .45), (.05, .5, .05), wo, bevel=0.005)
    geo.box((1.36, -1.5, 2.3), (.05, .04, 4.4), wo, bevel=0.005)
    geo.box((1.36, -1.0, 2.3), (.05, .04, 4.4), wo, bevel=0.005)
    parts.rubble(1.0, 1.3, .9, 5, st, seed=5, rmin=.07, rmax=.18)
    geo.rotate_all(45)


@landmark('val_wall_segment', group='city', folder='ato1', size=(360, 300), origin=(180, 230), tags=('ato1', 'muralha', 'modular', 'intacto'), footprint=40, collision=fp(3.6, 1.0), samples=24)
def wall_segment(f):
    _wall(0)


@landmark('val_wall_repaired', group='city', folder='ato1', size=(360, 300), origin=(180, 230), tags=('ato1', 'muralha', 'modular', 'reparado'), footprint=40, collision=fp(3.6, 1.0), samples=24)
def wall_repaired(f):
    _wall(1)


@landmark('val_wall_breach', group='city', folder='ato1', size=(360, 300), origin=(180, 230), tags=('ato1', 'muralha', 'modular', 'quebrado', 'ataque'), footprint=40, collision=fp(3.6, 1.0), samples=24)
def wall_breach(f):
    _wall(2)


def _wall(state):
    """Trecho de muralha (3,6 u): 0 intacto, 1 reparado com madeira e pedra clara, 2 brecha de ataque com entulho."""
    st, wd = M('stone'), M('wood_dark')
    rr = random.Random(30 + state)
    geo.box((0, 0, .2), (1.3, 3.8, .4), st, bevel=0.05)
    if state < 2:
        geo.box((0, 0, 1.5), (.9, 3.6, 2.6), st, bevel=0.05)
        geo.box((0, 0, 2.86), (1.05, 3.7, .16), st, bevel=0.03)
        crenels(.4, -1.8, 1.8, 2.88, st, 7, depth=.26, h=.45)
        crenels(-.4, -1.8, 1.8, 2.88, st, 7, depth=.26, h=.45)
    else:
        # brecha: dois cotos de muro com topo irregular e vão coberto de entulho
        for sy, L in ((-1.25, 1.1), (1.25, 1.1)):
            parts.rock_mass((0, sy, 0), (.9, L, 2.2 + rr.uniform(-.2, .25)), st, 40 + int(sy * 4), subdiv=3, rough=.2, taper=.1, flat_top=False)
        parts.rubble(.3, 0, 1.0, 14, st, seed=6, rmin=.12, rmax=.34)
        for k in range(3):
            geo.beam((.4, -.5 + k * .5, .2), (.55, -.3 + k * .5, 1.0 + k * .1), .07, .07, wd, bevel=0.01)
    if state == 1:
        # remendo: painel de tábuas escoradas + blocos claros novos
        geo.box((.5, .2, 1.3), (.1, 1.5, 1.8), M('wood'), bevel=0.02)
        for k in range(3):
            geo.beam((.6, -.5 + k * .55, .3), (.6, -.2 + k * .55, 2.0), .07, .07, wd, bevel=0.01)
        for k in range(6):
            geo.box((.47, -1.5 + (k % 3) * .38, 2.0 + (k // 3) * .4), (.06, .34, .34), M('stone_sand'), bevel=0.02)
    if state >= 1:
        geo.box((.47, 1.2 if state == 2 else -1.2, 1.3), (.03, .6, .4), m_scorch(), bevel=0)
        parts.grass_tufts(0, 0, 1.6, 6, M('leaf_dry'), seed=3, h=.2)
    if state == 0:
        torch(.5, 0, 1.6)
        parts.hanging_vines(.46, -1.6, .46, -.4, 2.6, 1.2, 3, M('leaf'), 7)
    geo.rotate_all(45)


@landmark('val_barricade_a', group='city', folder='ato1', size=(340, 280), origin=(170, 190), tags=('ato1', 'barricada', 'intacta', 'val_gate'), footprint=36, collision=fp(3.2, .8), samples=24)
def barricade_a(f):
    _barricade(False)


@landmark('val_barricade_b', group='city', folder='ato1', size=(340, 280), origin=(170, 190), tags=('ato1', 'barricada', 'quebrada', 'val_gate'), footprint=36, collision=fp(3.2, .8), samples=24)
def barricade_b(f):
    _barricade(True)


def _barricade(broken):
    rr = random.Random(61 if broken else 60)
    wd, wo, iron = M('wood_dark'), M('wood_old'), M('iron')
    n = 9
    for i in range(n):
        y = -1.6 + i * 3.2 / (n - 1)
        if broken and i in (3, 4, 5):
            # estacas caídas
            geo.cyl_between((.3, y, .12), (.9 + rr.uniform(0, .3), y + rr.uniform(-.2, .2), .18), .07, wd, sides=6, r2=.03)
            continue
        lean = .34 if not broken else rr.uniform(.2, .5)
        geo.cyl_between((-.2, y, 0), (.55 + lean, y, 1.25 + rr.uniform(-.1, .12)), .075, wd, sides=6, r2=.02)
    for z in (.45, .85):
        geo.beam((.1, -1.7, z), (.1, 1.7, z), .08, .08, wo, bevel=0.01)
    # sacos de areia e caixas
    for i, y in enumerate((-1.3, -.7, .8, 1.35)):
        ball((-.35, y, .18), .3, m_sack(), squash=.6)
        if i % 2 == 0:
            ball((-.35, y + .05, .48), .26, m_sack(), squash=.6)
    geo.box((-.4, .1, .25), (.5, .5, .5), M('wood'), bevel=0.02)
    if broken:
        parts.rubble(.5, 0, 1.4, 6, wd, seed=3, rmin=.05, rmax=.14)
        geo.box((.15, .9, .02), (.7, .8, .03), m_scorch(), bevel=0)
    else:
        parts.flag(.2, -1.75, 1.5, .8, .45, M('cloth_blue'), phase=.4)
    geo.rotate_all(45)


@landmark('val_banner_pole_tall', group='city', folder='ato1', size=(280, 520), origin=(140, 440), tags=('ato1', 'bandeira', 'val_gate'), blocks=6, footprint=8, samples=24)
def banner_pole(f):
    wd = M('wood_dark')
    geo.cyl((0, 0, 0), .26, .3, M('stone'), sides=8, r2=.2)
    geo.cyl((0, 0, .3), .09, 4.3, wd, sides=8, r2=.06)
    geo.beam((0, -.6, 4.1), (0, .6, 4.1), .06, .06, wd, bevel=0.01)
    # estandarte grande de Valedouro (azul, faixa dourada) com barra rasgada
    parts.cloth_sheet((0, -.5, 4.05), (0, .5, 4.05), (.02, -.5, 2.2), (.02, .5, 2.2), M('cloth_blue'), nu=10, nv=10, sag=.05, folds=.06, fold_n=3, phase=.7)
    geo.box((.05, 0, 3.4), (.03, .86, .12), m_gold(), bevel=0.005)
    geo.box((.05, 0, 3.05), (.03, .1, .6), m_gold(), bevel=0.005)
    for k in range(3):
        geo.box((.04, -.32 + k * .32, 2.15), (.03, .08, .28), M('cloth_blue'), bevel=0)
    geo.cyl((0, 0, 4.42), .07, .14, m_gold(), sides=8, r2=.02)
    parts.rubble(0, 0, .5, 4, M('stone'), seed=2, rmin=.05, rmax=.12)


@landmark('val_supply_stack', group='city', folder='ato1', size=(280, 240), origin=(140, 170), tags=('ato1', 'suprimentos', 'val_gate', 'prop'), footprint=28, coll=(1.6, 1.4), samples=24)
def supply_stack(f):
    rr = random.Random(77)
    for i, (x, y, z, s) in enumerate(((0, 0, .25, .9), (.95, .1, .25, .8), (.4, .05, .78, .8), (-.85, .3, .2, .7))):
        geo.box((x, y, z), (s, s, s * .9 if z < .5 else s * .8), M('wood'), rot=(0, 0, rr.uniform(-.2, .2)), bevel=0.03)
        for k in (-1, 1):
            geo.box((x, y + k * s * .32, z + s * .35), (s + .02, .05, .06), M('iron'), bevel=0.005)
    for x, y in ((1.45, -.55), (1.9, .1)):
        geo.cyl((x, y, 0), .34, .8, M('wood_dark'), sides=12, r2=.32)
        for z in (.2, .6):
            geo.cyl((x, y, z), .36, .06, M('iron'), sides=12)
    for x, y in ((-.6, -.7), (-.15, -.75), (.3, -.7)):
        ball((x, y, .24), .32, m_sack(), squash=.75)
    parts.cloth_sheet((-1.0, -.4, 1.05), (1.2, -.4, 1.2), (-1.0, .9, .4), (1.2, .9, .55), m_canvas(), nu=8, nv=6, sag=.1, folds=.05, fold_n=3)
    for x, y in ((-1.0, .3), (1.25, .1)):
        geo.cyl_between((x, y, 0), (x, y, .9), .02, M('rope'), sides=4)


# ============================================================== LOC_VAL_GUILD
@landmark('val_guild_hall', group='city', folder='ato1', size=(760, 620), origin=(380, 470), tags=('ato1', 'guilda', 'servico', 'val_guild', 'landmark'), footprint=90, collision=fp(6.4, 3.6), samples=24)
def guild_hall(f):
    st, wd, wo, iron, sd = M('stone'), M('wood_dark'), M('wood'), M('iron'), M('stone_sand')
    plaster = mats.ground('guild_pl', ('#a88a5a', '#c8a672', '#dfc38c', '#f0dca8', '#fff0c8'), scale=3.0, fine=22.0)
    # base de pedra + salão principal em enxaimel
    geo.box((0, 0, .5), (3.7, 6.4, 1.0), st, bevel=0.05)
    geo.box((0, 0, 2.05), (3.4, 6.1, 2.1), plaster, bevel=0.03)
    for i in range(7):
        y = -3.0 + i * 1.0
        geo.box((1.72, y, 2.05), (.16, .2, 2.1), wd, bevel=0.03)
    for z in (1.1, 3.05):
        geo.box((1.74, 0, z), (.18, 6.2, .18), wd, bevel=0.03)
    for i in range(6):
        y = -2.5 + i * 1.0
        geo.beam((1.75, y - .2, 1.15), (1.75, y + .3, 3.0), .07, .08, wd, bevel=0.01)
    # 2º pavimento levemente em balanço + águas-furtadas
    geo.box((.1, 0, 3.55), (3.7, 5.6, 1.0), plaster, bevel=0.03)
    geo.box((1.98, 0, 3.05), (.4, 5.8, .22), wd, bevel=0.03)
    for i in range(6):
        geo.box((1.96, -2.5 + i * 1.0, 3.55), (.14, .18, 1.0), wd, bevel=0.03)
    # telhado azul em duas águas + empena central sobre a porta
    geo.roof_gable(0, 0, 4.05, 3.5, 6.1, 1.8, m_roof_blue(), overhang=.35, ridge_axis='y', thickness=.12)
    geo.roof_gable(1.7, 0, 3.4, 1.6, 2.6, 1.15, m_roof_blue(), overhang=.2, ridge_axis='x', thickness=.1)
    geo.box((1.9, 0, 4.15), (.06, 2.2, .06), wd, bevel=0.01)
    # porta dupla larga com arco de pedra, degraus e lanternas
    geo.box((1.78, 0, 1.55), (.3, 2.4, 2.1), st, bevel=0.04)
    for sy in (-.55, .55):
        geo.box((1.96, sy, 1.45), (.14, 1.0, 1.9), wd, bevel=0.03)
        for z in (.6, 1.4, 2.1):
            geo.box((2.03, sy, z), (.05, 1.0, .1), iron, bevel=0.01)
    geo.box((1.92, 0, 2.62), (.4, 2.6, .18), sd, bevel=0.03)
    steps(1.95, 0, 3.0, 3, rise=.16, run=.34, mat=st)
    lantern(2.15, -1.35, 2.35)
    lantern(2.15, 1.35, 2.35)
    # toldo listrado azul sobre a entrada
    parts.cloth_sheet((2.0, -1.4, 2.75), (2.0, 1.4, 2.75), (2.9, -1.4, 2.2), (2.9, 1.4, 2.2), M('stripe_blue'), nu=14, nv=6, sag=.08, folds=.05, fold_n=6)
    # janelas quentes com venezianas
    for y in (-2.35, -1.6, 1.6, 2.35):
        arch_frame(1.72, y, 1.5, .5, .8, sd, depth=.26, shutters=True)
    for y in (-1.8, 0, 1.8):
        arch_frame(1.92, y, 3.55, .5, .55, sd, depth=.2, shutters=True)
    # placa da Guilda pendurada em braço de ferro: escudo azul + espada dourada cruzada com bússola
    geo.beam((2.0, -3.15, 3.0), (2.55, -3.15, 3.0), .06, .06, iron, bevel=0.01)
    geo.cyl_between((2.5, -3.15, 3.0), (2.5, -3.15, 2.72), .012, iron, sides=4)
    geo.box((2.5, -3.15, 2.35), (.08, 1.05, .8), M('cloth_blue'), bevel=0.02)
    geo.box((2.56, -3.15, 2.35), (.03, .95, .08), m_gold(), rot=(0, 0, 0), bevel=0)
    geo.box((2.56, -3.15, 2.35), (.03, .08, .7), m_gold(), bevel=0)
    geo.cyl((2.57, -3.15, 2.35), .2, .03, m_gold(), rot=(0, 90, 0), sides=16, r2=.2)
    geo.cyl((2.6, -3.15, 2.35), .13, .03, M('cloth_blue'), rot=(0, 90, 0), sides=16, r2=.13)
    # extensão lateral: depósito de telhado baixo com portão de carga + chaminé de pedra
    geo.box((-.2, 4.35, .95), (2.6, 2.3, 1.9), st, bevel=0.05)
    geo.roof_gable(-.2, 4.35, 1.9, 2.5, 2.3, .9, M('roof_red'), overhang=.25, ridge_axis='x', thickness=.1)
    for sy in (-.35, .35):
        geo.box((1.12, 4.35 + sy, .95), (.1, .7, 1.4), wd, bevel=0.02)
    parts.tapered_shaft(-1.2, -1.6, 4.5, 6.1, .7, .55, st, seed=3)
    geo.box((-1.2, -1.6, 6.15), (.8, .8, .12), st, bevel=0.03)
    # entorno imediato: caixas, barris, cordas, sacos e mochilas encostados
    for x, y, z in ((2.1, 3.2, .3), (2.35, 3.55, .3)):
        geo.box((x, y, z), (.6, .6, .6), wo, bevel=0.03)
    geo.cyl((2.2, -3.05, 0), .32, .8, wd, sides=12, r2=.3)
    ball((2.4, 3.9, .22), .3, m_sack(), squash=.7)
    ball((2.15, 4.4, .2), .26, M('cloth_red'), squash=.75)
    geo.cyl_between((1.85, 2.9, .8), (1.85, 3.3, .3), .02, M('rope'), sides=4)
    parts.grass_tufts(1.4, 0, 3.4, 12, M('grass'), seed=5, h=.22)
    geo.rotate_all(45)


@landmark('val_weapon_rack', group='city', folder='ato1', size=(260, 260), origin=(130, 180), tags=('ato1', 'guilda', 'prop', 'armas'), blocks=10, footprint=14, samples=24)
def weapon_rack(f):
    wd, iron = M('wood_dark'), M('iron')
    for y in (-.8, .8):
        geo.cyl_between((0, y, 0), (.1, y, 1.5), .07, wd, sides=6)
    geo.beam((.05, -.85, 1.0), (.05, .85, 1.0), .08, .06, wd, bevel=0.01)
    geo.beam((.05, -.85, .45), (.05, .85, .45), .08, .06, wd, bevel=0.01)
    rr = random.Random(3)
    for i, y in enumerate((-.55, -.2, .2, .55)):
        h = 1.3 + rr.uniform(-.1, .2)
        geo.beam((.15, y, .3), (.22, y + .05, h), .03, .02, iron, bevel=0.005)
        geo.box((.15, y, 1.0), (.05, .16, .05), m_gold() if i % 2 else iron, bevel=0)
        geo.box((.12, y, .3), (.06, .06, .3), wd, bevel=0.01)
    geo.cyl((.22, 1.05, .5), .28, .05, M('cloth_blue'), rot=(0, 90, 0), sides=16)
    geo.cyl((.26, 1.05, .5), .07, .05, m_gold(), rot=(0, 90, 0), sides=8)
    geo.beam((.2, -1.1, 0), (.55, -1.2, 1.4), .025, .02, M('wood'), bevel=0.005)
    geo.beam((.2, -1.25, 0), (.6, -1.3, 1.3), .025, .02, M('wood'), bevel=0.005)


@landmark('val_training_dummy', group='city', folder='ato1', size=(200, 280), origin=(100, 210), tags=('ato1', 'guilda', 'prop', 'treino'), blocks=8, footprint=10, samples=24)
def training_dummy(f):
    wd = M('wood_dark')
    geo.cyl((0, 0, 0), .4, .25, M('stone'), sides=8, r2=.3)
    geo.cyl((0, 0, .25), .07, 1.5, wd, sides=8, r2=.07)
    geo.beam((0, -.6, 1.2), (0, .6, 1.2), .06, .06, wd, bevel=0.01)
    ball((0, 0, 1.05), .3, m_straw(), squash=1.4)
    ball((0, 0, 1.68), .2, m_canvas(), squash=1.0)
    geo.cyl((0, 0, .95), .34, .12, M('rope'), sides=10)
    geo.box((.28, .5, 1.25), (.1, .05, .5), M('iron'), rot=(0, 0, .5), bevel=0.005)
    geo.box((.3, -.5, 1.0), (.05, .5, .5), M('cloth_blue'), rot=(0, 0, 0), bevel=0.01)
    for k in range(4):
        geo.box((.31, -.15 + k * .1, .95 + (k % 2) * .25), (.02, .06, .18), M('iron'), bevel=0)
    parts.grass_tufts(0, 0, .6, 5, M('leaf_dry'), seed=2, h=.16)


@landmark('val_notice_board', group='city', folder='ato1', size=(260, 320), origin=(130, 240), tags=('ato1', 'guilda', 'prop', 'contratos'), blocks=10, footprint=12, samples=24)
def notice_board(f):
    wd, wo = M('wood_dark'), M('wood')
    for y in (-.9, .9):
        geo.box((0, y, .9), (.16, .16, 1.8), wd, bevel=0.02)
    geo.box((.06, 0, 1.15), (.1, 1.9, 1.35), wo, bevel=0.02)
    geo.roof_gable(0, 0, 1.85, .4, 2.3, .4, M('roof_red'), overhang=.15, ridge_axis='y', thickness=.06)
    rr = random.Random(5)
    for i in range(7):
        y, z = -.72 + (i % 4) * .48, .8 + (i // 4) * .55
        geo.box((.13, y, z + rr.uniform(-.05, .08)), (.03, .32, .4), m_parchment(), rot=(0, 0, rr.uniform(-.25, .25)), bevel=0)
        geo.box((.15, y, z + .15), (.02, .04, .04), M('cloth_red'), bevel=0)
    geo.box((.12, 0, .32), (.1, 1.9, .16), wd, bevel=0.01)
    geo.box((.14, .4, 1.62), (.03, .6, .16), M('cloth_blue'), bevel=0)
    geo.box((.18, .4, 1.62), (.02, .5, .05), m_gold(), bevel=0)


# ============================================================== LOC_SIX_CROWNS_ARCHIVE
def _crown(x, y, z, s=1.0):
    geo.cyl((x, y, z), .16 * s, .1 * s, m_gold(), rot=(0, 90, 0), sides=10, r2=.14 * s)
    for k in (-1, 0, 1):
        geo.cyl((x + .04, y + k * .11 * s, z + .05 * s), .04 * s, .16 * s, m_gold(), sides=4, r2=.0)
        ball((x + .05, y + k * .11 * s, z + .2 * s), .025 * s, M('cloth_red'), squash=1.0, smooth=False)


@landmark('val_archive_hall', group='city', folder='ato1', size=(880, 700), origin=(440, 540), tags=('ato1', 'arquivo', 'landmark', 'seis_coroas', 'six_crowns_archive'), footprint=100, collision=fp(7.6, 4.0), samples=24)
def archive_hall(f):
    nb, wd, iron, gold = m_noble(), M('wood_dark'), M('iron'), m_gold()
    slate = M('roof_slate')
    # embasamento e corpo principal de pedra nobre
    geo.box((0, 0, .3), (4.4, 7.8, .6), nb, bevel=0.05)
    geo.box((-.1, 0, 2.5), (3.8, 7.2, 3.8), nb, bevel=0.05)
    # cornija, friso com as SEIS COROAS e frontão
    geo.box((.1, 0, 4.5), (4.1, 7.5, .22), nb, bevel=0.04)
    geo.box((.12, 0, 4.85), (3.9, 7.2, .5), m_noble(), bevel=0.03)
    for i in range(6):
        _crown(1.98, -2.75 + i * 1.1, 4.72, 1.3)
    geo.roof_gable(-.1, 0, 5.05, 3.9, 7.2, 1.4, slate, overhang=.4, ridge_axis='y', thickness=.12)
    geo.roof_gable(1.55, 0, 4.85, 1.7, 3.6, 1.1, slate, overhang=.2, ridge_axis='x', thickness=.1)     # frontão do pórtico
    # pórtico: quatro colunas com capitel e base, arquitrave e escadaria larga
    for y in (-1.95, -.65, .65, 1.95):
        geo.cyl((2.35, y, .6), .3, .12, nb, sides=14, r2=.28)
        geo.cyl((2.35, y, .72), .23, 3.35, nb, sides=14, r2=.2)
        geo.box((2.35, y, 4.15), (.68, .68, .18), nb, bevel=0.03)
        geo.box((2.35, y, 4.3), (.76, .76, .14), nb, bevel=0.03)
    geo.box((2.35, 0, 4.45), (.8, 4.9, .3), nb, bevel=0.04)
    steps(2.3, 0, 5.4, 5, rise=.13, run=.36, mat=nb)
    # porta principal dupla com aros dourados e vitral azul no bandeirola
    geo.box((1.95, 0, 1.8), (.3, 2.4, 2.8), M('hole'), bevel=0)
    geo.box((1.8, 0, 1.6), (.05, 2.2, 2.3), M('wood_old'), bevel=0)
    for sy in (-.55, .55):
        geo.box((2.02, sy, 1.75), (.14, 1.1, 2.6), wd, bevel=0.03)
        geo.box((2.1, sy, 1.75), (.04, .08, 2.5), gold, bevel=0)
    geo.box((2.02, 0, 3.2), (.14, 2.3, .55), M('glass'), bevel=0.02)
    geo.box((2.08, 0, 3.2), (.05, 2.3, .06), gold, bevel=0)
    # janelas altas em arco nas duas alas
    for y in (-3.1, -2.4, 2.4, 3.1):
        arch_frame(1.82, y, 1.4, .55, 1.6, nb, depth=.24)
    # estandartes azuis com coroa e lâmpadas de ferro dourado
    for y in (-3.4, 3.4):
        banner(2.05, y, 4.0, 2.0, .8, seed=y)
        _crown(2.1, y, 2.7, .9)
    for y in (-1.0, 1.0):
        lantern(2.65, y, 3.3)
    # pátio de acesso: bancos de pedra e vasos podados
    for y in (-3.3, 3.3):
        geo.box((3.3, y, .3), (.6, 1.2, .3), nb, bevel=0.03)
        geo.cyl((3.35, y, .6), .3, .4, M('stone'), sides=10, r2=.25)
        parts.leaf_cluster(3.35, y, 1.15, .32, 18, M('leaf'), 3, size=(.08, .12), flat=.6)
    geo.rotate_all(45)


@landmark('val_archive_lamp', group='city', folder='ato1', size=(140, 340), origin=(70, 280), tags=('ato1', 'arquivo', 'prop', 'iluminacao'), blocks=6, footprint=8, samples=24)
def archive_lamp(f):
    iron, gold = M('iron'), m_gold()
    geo.cyl((0, 0, 0), .3, .22, m_noble(), sides=8, r2=.22)
    geo.cyl((0, 0, .2), .07, 2.3, iron, sides=8, r2=.05)
    geo.cyl((0, 0, 1.0), .11, .12, gold, sides=8)
    geo.cyl((0, 0, 2.4), .22, .1, iron, sides=8, r2=.3)
    geo.box((0, 0, 2.62), (.34, .34, .38), M('glass'), bevel=0.03)
    for sx, sy in ((-.17, -.17), (.17, -.17), (.17, .17), (-.17, .17)):
        geo.cyl_between((sx, sy, 2.42), (sx * .9, sy * .9, 2.84), .015, gold, sides=4)
    geo.roof_pyramid(0, 0, 2.82, .3, .3, iron, sides=4, rot=45)
    ball((0, 0, 3.2), .05, gold)
    for sgn in (-1, 1):
        geo.beam((0, 0, 1.6), (0, sgn * .32, 1.85), .02, .02, gold, bevel=0)


@landmark('val_crown_monument', group='city', folder='ato1', size=(200, 320), origin=(100, 250), tags=('ato1', 'arquivo', 'monumento', 'seis_coroas'), blocks=12, footprint=18, samples=24)
def crown_monument(f):
    nb, gold = m_noble(), m_gold()
    geo.box((0, 0, .15), (1.4, 1.4, .3), nb, bevel=0.04)
    geo.box((0, 0, .55), (1.0, 1.0, .5), nb, bevel=0.04)
    geo.box((0, 0, 1.2), (.7, .7, .9), nb, bevel=0.04)
    geo.box((0, 0, 1.75), (.9, .9, .2), nb, bevel=0.04)
    # seis coroas em anel no topo (Aliança das Seis Coroas)
    for i in range(6):
        a = i * math.pi / 3
        _crown(math.cos(a) * .42 + .05, math.sin(a) * .42, 1.95, .7)
    ball((0, 0, 2.05), .12, M('cloth_blue'), squash=1.0)
    geo.box((.36, 0, 1.2), (.03, .5, .5), gold, bevel=0)


# ---- interior do Arquivo
@landmark('val_archive_shelf_tall', group='interior', folder='ato1', size=(420, 520), origin=(210, 400), tags=('ato1', 'arquivo', 'interior', 'estante'), blocks=14, footprint=22, samples=24)
def archive_shelf(f):
    wd, wo = M('wood_dark'), M('wood')
    rr = random.Random(9)
    geo.box((-.2, 0, 1.6), (.5, 2.6, 3.2), wd, bevel=0.03)
    for z in (.25, .95, 1.65, 2.35, 3.05):
        geo.box((0, 0, z), (.7, 2.5, .08), wo, bevel=0.01)
    cols = (M('cloth_red'), M('cloth_blue'), M('cloth_green'), m_parchment(), M('wood'))
    for z in (.3, 1.0, 1.7, 2.4):
        y = -1.15
        while y < 1.1:
            w = rr.uniform(.08, .2)
            h = rr.uniform(.4, .6)
            if rr.random() < .3:
                geo.cyl((.05, y, z + .12), .07, w * 4, m_parchment(), rot=(90, 0, 0), sides=8)       # rolo de pergaminho
                y += .2
            else:
                geo.box((.02, y + w / 2, z + h / 2 + .04), (.4, w, h), rr.choice(cols), bevel=0.01)
                y += w + .012
    geo.box((.42, 1.35, 1.55), (.06, .08, 3.0), wo, bevel=0.01)          # escada de biblioteca
    geo.box((.42, 1.05, 1.55), (.06, .08, 3.0), wo, bevel=0.01)
    for z in (.5, 1.0, 1.5, 2.0, 2.5):
        geo.box((.42, 1.2, z), (.06, .38, .05), wo, bevel=0.005)
    geo.rotate_all(45)


@landmark('val_archive_map_table', group='interior', folder='ato1', size=(340, 260), origin=(170, 190), tags=('ato1', 'arquivo', 'interior', 'mapas'), blocks=16, footprint=24, samples=24)
def archive_map_table(f):
    wd, wo = M('wood_dark'), M('wood')
    geo.box((0, 0, .85), (2.6, 1.6, .16), wd, bevel=0.03)
    for sx, sy in ((-1.15, -.65), (1.15, -.65), (1.15, .65), (-1.15, .65)):
        geo.box((sx, sy, .4), (.18, .18, .8), wd, bevel=0.02)
    geo.box((0, 0, .95), (2.3, 1.35, .04), m_parchment(), bevel=0)
    rr = random.Random(2)
    for i in range(9):      # mapa de Elyndor: costas, rios e oito marcas de Eco
        a = rr.uniform(0, 6.28)
        geo.box((rr.uniform(-.9, .9), rr.uniform(-.5, .5), .975), (rr.uniform(.2, .6), .03, .01), m_ink(), rot=(0, 0, a), bevel=0)
    for k in range(8):
        a = k * math.pi / 4
        geo.cyl((math.cos(a) * .7, math.sin(a) * .45, .97), .045, .02, m_eco(), sides=8)
    for sx in (-.95, .95):
        geo.cyl((sx, .5, 1.0), .08, 1.0, M('cloth_cream'), rot=(0, 90, 0), sides=10)
    geo.cyl((.95, -.5, 1.0), .05, .16, m_ink(), sides=8)
    geo.box((1.05, -.5, 1.12), (.02, .02, .3), m_ink(), bevel=0)
    geo.cyl((-1.0, -.5, .97), .1, .28, M('iron'), sides=8)
    ball((-1.0, -.5, 1.3), .1, M('fire'), squash=1.5)


@landmark('val_archive_lectern', group='interior', folder='ato1', size=(200, 260), origin=(100, 190), tags=('ato1', 'arquivo', 'interior', 'atril'), blocks=8, footprint=10, samples=24)
def archive_lectern(f):
    wd = M('wood_dark')
    geo.cyl((0, 0, 0), .32, .12, wd, sides=8, r2=.26)
    geo.cyl((0, 0, .1), .09, 1.0, wd, sides=8, r2=.11)
    geo.box((.1, 0, 1.25), (.62, .9, .06), wd, rot=(0, -.35, 0), bevel=0.01)
    geo.box((.13, 0, 1.3), (.5, .82, .04), m_parchment(), rot=(0, -.35, 0), bevel=0)
    geo.box((.13, 0, 1.31), (.5, .03, .03), M('cloth_red'), rot=(0, -.35, 0), bevel=0)
    geo.cyl((-.32, .4, 1.0), .04, .28, M('cloth_cream'), sides=6)
    ball((-.32, .4, 1.34), .05, M('fire'), squash=1.5)


@landmark('val_map_fragment_pedestal', group='interior', folder='ato1', size=(240, 320), origin=(120, 240), tags=('ato1', 'arquivo', 'interior', 'fragmento_do_primeiro_mapa', 'chave'), blocks=14, footprint=16, samples=24)
def fragment_pedestal(f):
    nb = m_noble()
    geo.cyl((0, 0, 0), .55, .3, nb, sides=8, r2=.48)
    geo.cyl((0, 0, .3), .3, .7, nb, sides=8, r2=.26)
    geo.cyl((0, 0, 1.0), .5, .12, nb, sides=8, r2=.5)
    geo.cyl((0, 0, 1.12), .42, .04, m_gold(), sides=8)
    # o Fragmento do Primeiro Mapa: laje angular com linhas de Eco em oito direções, pairando
    slab = geo.box((0, 0, 1.75), (.8, .6, .1), M('rock_grey'), rot=(.15, .1, .3), bevel=0.03)
    for k in range(8):
        a = k * math.pi / 4 + .3
        geo.box((math.cos(a) * .18, math.sin(a) * .13, 1.82), (.34, .022, .02), m_eco(), rot=(0, 0, a), bevel=0)
    for k in range(6):
        a = k * 1.05
        geo.cyl((math.cos(a) * .55, math.sin(a) * .55, 1.3 + (k % 3) * .25), .03, .1, m_eco_dim(), sides=4, r2=.0)
    geo.cyl((0, 0, 1.15), .06, .45, m_eco_dim(), sides=6, r2=.03)
