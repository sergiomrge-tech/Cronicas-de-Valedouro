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
    """PASSE FINAL: nascente natural — bacia de ROCHAS irregulares (não um disco), lâmina d'água de contorno orgânico com
    transbordo para a frente, raízes que sobem da água e sustentam uma pedra-altar bruta."""
    rt, rune, lf, st = _pal(corrupt)
    rr = random.Random(44)
    earth = X('earth_bank', lambda: mats.flat('earth_bank', '#3a3a1e', rough=1.0, spec=0.0, bevel_wear=.2))
    parts.slab_blob(0, 0, -.02, 5.2, 4.4, .12, earth, seed=3, wobble=.22)
    parts.slab_blob(.2, -.1, .1, 3.4, 2.8, .05, m_pool(corrupt), seed=5, wobble=.3)          # lâmina d'água orgânica
    for k in range(11):                                                          # bacia: rochas de tamanhos variados, abertura na frente (+x)
        a = -2.3 + k * (4.6 / 10) + rr.uniform(-.12, .12)
        a = a + math.pi                                                          # arco pelo fundo; frente livre para o transbordo
        d = 1.95 * (1 + .12 * math.sin(3 * a + 1)) + rr.uniform(-.1, .15)
        parts.rock_mass((math.cos(a) * d, math.sin(a) * d * .9, -.05), (rr.uniform(.5, .95), rr.uniform(.5, .85), rr.uniform(.35, .75)), m_rock_moss(), 80 + k, subdiv=3, rough=.3, flat_top=False)
    for k in range(4):                                                           # transbordo: seixos e fio d'água descendo
        parts.boulder((1.9 + k * .45, rr.uniform(-.7, .7), .02), rr.uniform(.12, .22), m_rock_moss(), seed=90 + k, squash=.5)
    parts.slab_blob(2.4, 0, .02, 1.6, .6, .03, m_pool(corrupt), seed=9, wobble=.35)
    parts.tapered_shaft(-.2, .1, 0, 1.7, .8, .45, st, seed=13)                   # pedra-altar bruta na água
    for k in range(4):                                                           # quatro raízes sobem da água e abraçam o altar
        a = k * math.pi / 2 + .4
        root((math.cos(a) * 1.7, math.sin(a) * 1.5, .1), (math.cos(a) * .3 - .2, math.sin(a) * .3 + .1, 1.9), .22, .1, rt, sag=.25, sides=8)
    geo.cyl((-.2, .1, 1.72), .2, .08, rune, sides=10)
    ball((-.2, .1, 2.0), .22, rune, squash=1.2)
    if corrupt:
        _veins(0, 0, 3.0, 8, 3, rune)
    else:
        parts.leaf_cluster(-1.8, -1.2, .4, .8, 10, m_fern(), 12, size=(.1, .24), flat=.4)
    _life(-.6, 2.6, 1.3, corrupt, 5)
    geo.rotate_all(45)


# ------------------------------------------------------------------ Raiz da Pedra: monólito abraçado por raízes, arco de ruína
def _stone(corrupt):
    """PASSE FINAL: monólito cravado num afloramento (fundação enterrada, sem laje quadrada); ruína ao lado com soco comum
    aos dois pilares, verga caída apoiada no entulho (lógica de desabamento)."""
    rt, rune, lf, st = _pal(corrupt)
    for k, (x, y, sx, sy, h) in enumerate(((0, 0, 2.2, 2.0, .6), (-.9, 1.0, 1.4, 1.2, .45), (.8, -.9, 1.2, 1.1, .4))):     # afloramento em blocos irregulares
        parts.rock_mass((x, y, -.2), (sx, sy, h), m_rock_moss(), 61 + k, subdiv=4, rough=.38, freq=1.6, taper=.35, flat_top=False, squash_base=.5)
    parts.tapered_shaft(0, 0, .1, 3.3, 1.2, .9, st, seed=6)                        # monólito
    geo.box((.62, 0, 2.0), (.06, .5, 1.3), rune, bevel=0)
    for k in range(5):
        a = k * 1.25
        root((math.cos(a) * 1.8, math.sin(a) * 1.6, .05), (math.cos(a + 1.2) * .7, math.sin(a + 1.2) * .7, 3.0), .2, .08, rt, sag=.2, sides=8)
    geo.box((-.1, 0, .12), (.9, 4.6, .5), st, bevel=0.04)                          # soco comum (fundação) da ruína, parcialmente enterrado
    geo.box((0, -1.9, 1.2), (.5, .5, 2.2), st, bevel=0.05)                         # pilar em pé
    geo.box((0, 1.9, .75), (.5, .5, 1.3), st, bevel=0.05)                          # pilar quebrado
    geo.box((.25, 1.2, .75), (.5, 1.9, .38), st, rot=(.45, 0, .2), bevel=0.05)     # verga caída apoiada no pilar quebrado e no entulho
    parts.rubble(.3, 2.1, 1.0, 7, m_rock_moss(), seed=4, rmin=.1, rmax=.28)
    if corrupt:
        _veins(0, 0, 3.0, 9, 4, rune)
    else:
        parts.ivy(.61, -.5, .61, .5, .3, 2.6, M('leaf'), seed=3, n=26)
    _life(-1.6, 1.8, 1.3, corrupt, 6)
    geo.rotate_all(45)


# ------------------------------------------------------------------ Raiz do Vento: plataforma elevada, árvores inclinadas, folhas em movimento
def _wind(corrupt):
    """PASSE FINAL: afloramento rochoso natural (não um cubo) com degraus TALHADOS na rocha, três pedras eretas com runas
    (em vez de anel/disco) e pilar central; duas árvores inclinadas formam o pórtico."""
    rt, rune, lf, st = _pal(corrupt)
    for k, (x, y, sx, sy, h) in enumerate(((0, 0, 3.4, 3.2, 1.25), (-1.3, 1.2, 1.8, 1.6, .9), (1.0, -1.4, 1.6, 1.4, .8), (-1.4, -1.0, 1.3, 1.2, .7))):
        parts.rock_mass((x, y, -.2), (sx, sy, h), m_rock_moss(), 71 + k, subdiv=4, rough=.34, freq=1.5, taper=.3, terrace=.3, step=.4, flat_top=k == 0, squash_base=.5)
    parts.slab_blob(0, 0, .98, 2.8, 2.6, .05, X('turf_forest', lambda: mats.flat('turf_forest', '#2a4a1e', rough=1.0, spec=0.0, bevel_wear=.3)), seed=7, wobble=.28)
    for k in range(5):                                                            # degraus talhados descendo pela face +x
        geo.box((1.55 + k * .32, -.4 + k * .06, .9 - k * .2), (.45, 1.0, .22), st, rot=(0, 0, .08 * k), bevel=0.04)
    for k, (x, y) in enumerate(((-.8, -.9), (-.6, .95), (.7, -1.1))):              # pedras eretas com runas
        parts.tapered_shaft(x, y, .9, 2.0 + k * .25, .42, .3, st, seed=20 + k)
        geo.box((x + .2, y, 1.6 + k * .1), (.04, .14, .5), rune, bevel=0)
    geo.cyl((0, 0, .95), .2, 1.2, st, sides=8, r2=.14)
    ball((0, 0, 2.35), .22, rune, squash=1.2)
    for sy in (-1, 1):                                                           # duas árvores inclinadas formam pórtico sobre o patamar
        root((-.9, sy * 1.6, .8), (-.6, sy * .3, 4.4), .3, .12, rt, sag=.1, sides=8)
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
