"""Lote 2 / Ato II — Floresta Ancestral, PARTE 2B: três Santuários de Raiz (LOC_FOREST_ROOT_SHRINES, Q_MS02_ROOTS) + rotas/atalhos.
Cada santuário existe em estado CORROMPIDO e PURIFICADO (o renderer só escolhe a variante pelo estado da quest; o asset não tem lógica)."""
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
from pro_nature import branch
from ato2_common import *


def _pal(corrupt):
    """(raiz, rune, folha, pedra)."""
    return (m_root_dead() if corrupt else m_bark_old(), m_eco_corrupt() if corrupt else m_glow(), M('leaf_dry') if corrupt else m_leaf_deep(), m_stone_moss())


def _veins(cx, cy, r, n, seed, mat):
    """Veios de corrupção no chão (só no estado corrompido)."""
    rr = random.Random(seed)
    for k in range(n):
        a = rr.uniform(0, 6.28)
        L = r * rr.uniform(.6, 1.1)
        geo.cyl_between((cx + math.cos(a) * .4, cy + math.sin(a) * .4, .03), (cx + math.cos(a + .25) * L, cy + math.sin(a + .25) * L, .03), .035, mat, sides=4)


def _life(cx, cy, r, corrupt, seed):
    """Vida ao redor: samambaias, cogumelos brilhantes e flores (purificado) ou mato murcho e teias (corrompido)."""
    if corrupt:
        parts.leaf_cluster(cx, cy, .1, r, 12, M('leaf_dry'), seed, size=(.1, .2), flat=.5)
        for k in range(3):
            geo.cyl_between((cx + r * .5 * math.cos(k * 2), cy + r * .5 * math.sin(k * 2), .05), (cx + r * .5 * math.cos(k * 2 + .4), cy + r * .5 * math.sin(k * 2 + .4), .5), .02, m_root_dead(), sides=4)
    else:
        parts.leaf_cluster(cx, cy, .1, r, 22, m_fern(), seed, size=(.12, .3), flat=.35)
        glow_mushrooms(cx + r * .4, cy - r * .3, 5, seed, spread=.4)
        parts.flowers(cx - r * .3, cy + r * .4, .6, 6, seed=seed)


# ------------------------------------------------------------------ Raiz da Água: bacia de pedra, raízes sobre um espelho d'água
def _water(corrupt):
    rt, rune, lf, st = _pal(corrupt)
    geo.cyl((0, 0, 0), 2.2, .35, st, sides=18, r2=2.0)                          # plataforma circular
    geo.cyl((0, 0, .34), 1.5, .3, st, sides=16, r2=1.4)                         # bacia
    geo.cyl((0, 0, .6), 1.25, .04, m_pool(corrupt), sides=16)   # água (parada e escura se corrompida)
    for k in range(4):                                                           # quatro raízes sobem da água e sustentam o altar
        a = k * math.pi / 2 + .4
        root((math.cos(a) * 2.0, math.sin(a) * 2.0, .3), (math.cos(a) * .35, math.sin(a) * .35, 2.0), .22, .1, rt, sag=.25, sides=8)
    geo.cyl((0, 0, 1.9), .34, .55, st, sides=8, r2=.28)                          # altar/núcleo entre as raízes
    geo.cyl((0, 0, 2.45), .22, .08, rune, sides=10)
    ball((0, 0, 2.75), .24, rune, squash=1.2)
    for k in range(3):                                                           # pedras cobertas de musgo e pequenas quedas
        a = k * 2.1 + .3
        parts.rock_mass((math.cos(a) * 2.7, math.sin(a) * 2.7, 0), (.9, .8, .7), m_rock_moss(), 70 + k, subdiv=3, rough=.25, flat_top=False)
    if not corrupt:
        for k in range(3):
            geo.cyl_between((math.cos(k * 2.1 + .3) * 2.7, math.sin(k * 2.1 + .3) * 2.7, .5), (math.cos(k * 2.1 + .3) * 1.5, math.sin(k * 2.1 + .3) * 1.5, .62), .05, m_pool(False), sides=5)
    else:
        _veins(0, 0, 3.2, 8, 3, rune)
    _life(0, 2.6, 1.4, corrupt, 5)
    geo.rotate_all(45)


# ------------------------------------------------------------------ Raiz da Pedra: monólito abraçado por raízes, arco de ruína
def _stone(corrupt):
    rt, rune, lf, st = _pal(corrupt)
    geo.box((0, 0, .18), (3.0, 3.0, .36), st, bevel=0.05)
    parts.tapered_shaft(0, 0, .3, 3.3, 1.2, .9, st, seed=6)                       # monólito
    geo.box((.62, 0, 2.0), (.06, .5, 1.3), rune, bevel=0)                        # runa vertical no monólito
    for k in range(5):                                                           # raízes abraçam a rocha em espiral
        a = k * 1.25
        root((math.cos(a) * 1.6, math.sin(a) * 1.6, .1), (math.cos(a + 1.2) * .7, math.sin(a + 1.2) * .7, 3.0), .2, .08, rt, sag=.2, sides=8)
    for sy in (-1.9, 1.9):                                                       # meio arco de ruína ao lado
        geo.box((0, sy, 1.1), (.5, .5, 2.2), st, bevel=0.05)
    geo.box((0, -1.05, 2.3), (.5, 2.0, .4), st, rot=(0, 0, 0), bevel=0.05)
    parts.rubble(0, 1.6, 1.4, 6, m_rock_moss(), seed=4, rmin=.1, rmax=.28)
    if corrupt:
        _veins(0, 0, 3.0, 9, 4, rune)
    else:
        parts.ivy(.61, -.5, .61, .5, .3, 2.6, M('leaf'), seed=3, n=26)
    _life(-1.6, 1.8, 1.3, corrupt, 6)
    geo.rotate_all(45)


# ------------------------------------------------------------------ Raiz do Vento: plataforma elevada, árvores inclinadas, folhas em movimento
def _wind(corrupt):
    rt, rune, lf, st = _pal(corrupt)
    geo.box((0, 0, .5), (3.6, 3.6, 1.0), st, bevel=0.06)                          # patamar elevado
    for k in range(4):
        geo.box((1.9, -1.2 + k * .8, .2 + k * .18), (.5, .8, .4 + k * .2), st, bevel=0.03)   # degraus de acesso
    geo.cyl((0, 0, 1.0), 1.2, .1, st, sides=16)
    geo.cyl((0, 0, 1.1), .95, .03, rune, sides=16, r2=.95)                       # anel rúnico
    geo.cyl((0, 0, 1.1), .2, 1.2, st, sides=8, r2=.14)
    ball((0, 0, 2.5), .22, rune, squash=1.2)
    for sy in (-1, 1):                                                           # duas árvores inclinadas formam pórtico sobre o patamar
        root((-.4, sy * 1.5, 1.0), (-.6, sy * .3, 4.4), .3, .12, rt, sag=.1, sides=8)
        buttress_roots(.3, .6, 3, rt, seed=int(sy) + 5, spread=2.4)
    for k in range(4):
        branch((-.6, -.3 + k * .2, 4.3), (.3, -.9 + k * .6, 4.9), .09, .04, rt)
    if corrupt:
        canopy_mass([(-.2, 0, 5.2)], 1.1, 8, n_leaf=16, light=False, tuft=m_leaf_mass())
        _veins(0, 0, 2.6, 7, 5, rune)
    else:
        canopy_mass([(-.2, 0, 5.3)], 1.5, 8, n_leaf=30, light=False, tuft=m_leaf_mass())
        for k in range(6):                                                       # sinos de folhas pendentes (movem-se com o vento no jogo)
            x = -.4 + k * .16
            geo.cyl_between((x, -.9 + k * .35, 4.3), (x, -.9 + k * .35, 3.5), .01, M('rope'), sides=4)
            geo.box((x, -.9 + k * .35, 3.42), (.06, .12, .18), m_leaf_light(), bevel=0)
    _life(1.2, 2.2, 1.2, corrupt, 7)
    geo.rotate_all(45)


for _kind, _fn, _tags in (('water', _water, ('raiz_da_agua', 'agua', 'musgo')), ('stone', _stone, ('raiz_da_pedra', 'rocha', 'ruina')), ('wind', _wind, ('raiz_do_vento', 'elevado', 'folhas'))):
    for _state in ('corrupt', 'pure'):
        _corrupt = _state == 'corrupt'
        landmark(f'flo_shrine_{_kind}_{_state}', group='nature', folder='ato2', size=(760, 700), origin=(380, 520),
                 tags=('ato2', 'floresta_ancestral', 'santuario_raiz') + _tags + (('estado_corrompido',) if _corrupt else ('estado_purificado',)),
                 footprint=70, collision=circ([(0, 0), (.8, .8), (-.8, .8), (.8, -.8), (-.8, -.8)], 14), samples=24)(lambda f, fn=_fn, c=_corrupt: fn(c))


# ============================================================== rotas: atalhos destraváveis e mirante
def _root_wall(blocked):
    """Atalho destravável: parede de raízes/vegetação fechando a trilha (bloqueado) ou raízes recolhidas com o vão aberto."""
    rr = random.Random(90)
    bark = m_bark_old()
    for sy in (-2.2, 2.2):
        root((0, sy, .05), (0, sy * .55, 2.6), .38, .16, bark, sag=.2, sides=8)
    if blocked:
        for k in range(7):
            y = -1.8 + k * .6
            root((0, y, .05), (rr.uniform(-.2, .2), y + rr.uniform(-.3, .3), 1.6 + rr.uniform(0, .8)), .16, .07, bark, sag=.1, sides=6)
        canopy_mass([(0, 0, 1.6)], 1.3, 3, n_leaf=22, light=False, tuft=m_leaf_mass())
    else:
        for k in range(3):
            geo.cyl_between((0, -1.7 + k * .1, .1), (0, -1.6 + k * .1, .5), .1, bark, sides=6)
            geo.cyl_between((0, 1.7 - k * .1, .1), (0, 1.6 - k * .1, .5), .1, bark, sides=6)
        parts.leaf_cluster(0, 0, .1, 1.6, 10, m_fern(), 3, size=(.1, .22), flat=.4)
    glow_mushrooms(.4, 2.4, 3, 4, spread=.3)
    geo.rotate_all(45)


@landmark('flo_root_shortcut_blocked', group='nature', folder='ato2', size=(520, 520), origin=(260, 400), tags=('ato2', 'floresta_ancestral', 'atalho', 'bloqueado'), footprint=40, collision=circ([(0, -2.2), (0, -1.1), (0, 0), (0, 1.1), (0, 2.2)], 13), samples=24)
def root_shortcut_blocked(f):
    _root_wall(True)


@landmark('flo_root_shortcut_open', group='nature', folder='ato2', size=(520, 520), origin=(260, 400), tags=('ato2', 'floresta_ancestral', 'atalho', 'aberto'), footprint=40, collision=circ([(0, -2.2), (0, 2.2)], 13), samples=24)
def root_shortcut_open(f):
    _root_wall(False)


@landmark('flo_lookout_rock', group='nature', folder='ato2', size=(560, 520), origin=(280, 400), tags=('ato2', 'floresta_ancestral', 'mirante', 'exploracao'), footprint=60, collision=circ([(0, 0), (.9, .9), (-.9, -.9)], 16), samples=24)
def lookout_rock(f):
    """Mirante: afloramento com plataforma de lajes, parapeito baixo e vista: de longe se enxerga o topo da Árvore-Memória."""
    st, rk = m_stone_moss(), m_rock_moss()
    parts.rock_mass((0, 0, 0), (3.2, 3.0, 2.0), rk, 81, subdiv=4, rough=.3, terrace=.35, step=.5, taper=.1, flat_top=True)
    geo.box((0, 0, 2.05), (2.4, 2.4, .2), st, bevel=0.05)
    for sy in (-1.1, 1.1):
        geo.box((-.2, sy, 2.4), (2.2, .16, .5), st, bevel=0.03)
    geo.box((-1.1, 0, 2.4), (.16, 2.2, .5), st, bevel=0.03)
    for k in range(5):
        geo.box((1.8 + k * .1, -.8 + k * .4, .3 + k * .35), (.7, .5, .3), st, bevel=0.03)
    parts.hanging_vines(-1.1, -1.1, -1.1, 1.1, 2.6, .9, 4, m_leaf_deep(), 3)
    glow_mushrooms(1.6, 1.8, 3, 5, spread=.3)
    parts.leaf_cluster(0, 2.0, .1, 1.0, 10, m_fern(), 4, size=(.12, .26), flat=.4)
    geo.rotate_all(45)


@landmark('flo_shrine_path_marker', group='nature', folder='ato2', size=(180, 300), origin=(90, 240), tags=('ato2', 'floresta_ancestral', 'sinal', 'raiz'), footprint=10, collision=circ([(0, 0)], 8), samples=24)
def shrine_path_marker(f):
    """Pedra-guia com glifo de raiz: liga visualmente os três braços ao mesmo sistema radicular (mesma cultura dos santuários)."""
    st = m_stone_moss()
    parts.tapered_shaft(0, 0, 0, 1.8, .55, .4, st, seed=8)
    geo.box((.24, 0, 1.1), (.04, .26, .6), m_glow(), bevel=0)
    for k in range(3):
        geo.box((.25, -.12 + k * .12, .95 - k * .15), (.03, .03, .32), m_glow(), rot=(0, 0, 0), bevel=0)
    root((-.4, .3, .05), (-.05, 0, .9), .07, .04, m_bark_old(), sag=.05, sides=5)
    parts.leaf_cluster(0, 0, .08, .5, 6, m_fern(), 3, size=(.1, .18), flat=.4)
    geo.rotate_all(45)
