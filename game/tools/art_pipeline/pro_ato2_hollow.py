"""Lote 2 / Ato II — Floresta Ancestral, PARTE 2D: Coração da Raiz Oca (LOC_HOLLOW_ROOT_ARENA, Q_MS02_HOLLOW_ROOT, boss BOSS_RAIZ_OCA_001).
Arena desenhada para o boss (não é clareira genérica): ferida aberta na floresta, corrupção crescente na aproximação, campo delimitado por raízes gigantes,
marcadores claros para telegráficos. Estados ATIVO (pré-boss / revanche em curso) e DORMENTE (primeira derrota, persistente)."""
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


def _pal(active):
    """(raiz, luz de corrupção/energia, pedra)."""
    if active:
        return m_root_dead(), m_eco_corrupt(), m_stone_moss()
    return m_bark_old(), X('hollow_dormant_glow', lambda: mats.emissive('hollow_dormant_glow', '#5a7a68', .7)), m_stone_moss()


# ------------------------------------------------------------------ núcleo: nó de raízes em torno de um coração oco
def _core(active):
    rt, glow, st = _pal(active)
    rr = random.Random(410)
    geo.cyl((0, 0, 0), 3.0, .3, st, sides=18, r2=2.7)                            # base rompida
    for k in range(10):                                                          # raízes-mestras em espiral formando o nó
        a = 2 * math.pi * k / 10
        root((math.cos(a) * 3.0, math.sin(a) * 3.0, .1), (math.cos(a + 1.4) * .9, math.sin(a + 1.4) * .9, 4.6 + rr.uniform(-.4, .6)), .5, .16, rt, sag=.4, sides=9)
    for k in range(6):                                                           # segundo nível, mais fino
        a = 2 * math.pi * k / 6 + .3
        root((math.cos(a) * 1.8, math.sin(a) * 1.8, 1.6), (math.cos(a - 1.1) * .5, math.sin(a - 1.1) * .5, 5.4), .32, .1, rt, sag=.2, sides=7)
    # coração oco: esfera de energia entre as raízes (ativo = intenso; dormente = tênue)
    ball((0, 0, 3.0), 1.0 if active else .7, glow, squash=1.3)
    for h, r in ((1.2, 1.6), (2.3, 1.4), (3.9, 1.2)):
        geo.cyl((0, 0, h), r, .05, glow, sides=22, r2=r)
    if active:
        for k in range(8):                                                       # espinhos escuros brotando do nó
            a = k * math.pi / 4 + .2
            geo.cyl_between((math.cos(a) * 2.6, math.sin(a) * 2.6, .1), (math.cos(a) * 3.4, math.sin(a) * 3.4, 1.8 + rr.uniform(0, .6)), .12, rt, sides=5, r2=.02)
    else:
        parts.leaf_cluster(0, 0, .2, 2.8, 18, m_fern(), 6, size=(.12, .3), flat=.35)
        glow_mushrooms(2.2, -1.6, 6, 5, spread=.5)
    geo.rotate_all(45)


@landmark('flo_hollow_core_active', group='nature', folder='ato2', size=(700, 760), origin=(350, 560), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'nucleo', 'estado_ativo'), footprint=80, collision=circ([(0, 0), (1.5, 0), (-1.5, 0), (0, 1.5), (0, -1.5)], 20), samples=24)
def hollow_core_active(f):
    _core(True)


@landmark('flo_hollow_core_dormant', group='nature', folder='ato2', size=(700, 760), origin=(350, 560), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'nucleo', 'estado_dormente'), footprint=80, collision=circ([(0, 0), (1.5, 0), (-1.5, 0), (0, 1.5), (0, -1.5)], 20), samples=24)
def hollow_core_dormant(f):
    _core(False)


# ------------------------------------------------------------------ piso da arena com marcadores de telegráfico
def _floor(active):
    rt, glow, st = _pal(active)
    rr = random.Random(411)
    base = mats.flat('hollow_floor_a' if active else 'hollow_floor_d', '#1a1424' if active else '#2a3a2c', rough=.95, bevel_wear=0)
    geo.cyl((0, 0, 0), 7.2, .03, base, sides=40)
    for ring, w in ((6.6, .14), (4.8, .12), (3.0, .1)):                          # anéis: leitura clara do campo
        for k in range(72):
            a = k * 2 * math.pi / 72
            if rr.random() < .2:
                continue
            geo.box((math.cos(a) * ring, math.sin(a) * ring, .05), (.36, w, .02), glow, rot=(0, 0, a + math.pi / 2), bevel=0)
    for k in range(8):                                                           # oito cunhas: marcadores de telegráfico (ataques radiais)
        a = k * math.pi / 4 + math.pi / 8
        geo.box((math.cos(a) * 4.2, math.sin(a) * 4.2, .06), (3.4, .1, .02), glow, rot=(0, 0, a), bevel=0)
        geo.box((math.cos(a) * 6.3, math.sin(a) * 6.3, .06), (.5, .5, .02), glow, rot=(0, 0, a + .78), bevel=0)
    for k in range(10):                                                          # veios/raízes no chão: corrupção (ativo) ou raízes velhas com musgo (dormente)
        a = rr.uniform(0, 6.28)
        root((math.cos(a) * 6.8, math.sin(a) * 6.8, .04), (math.cos(a + .5) * 1.4, math.sin(a + .5) * 1.4, .04), .1, .05, rt, sag=-.03, sides=5)
    if not active:
        parts.leaf_cluster(0, 0, .04, 5.0, 30, m_fern(), 3, size=(.1, .2), flat=.9)
        moss_patches(0, 0, 10, 8, .04, 24, 4)


@landmark('flo_hollow_floor_active', group='nature', folder='ato2', size=(960, 500), origin=(480, 250), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'arena', 'piso', 'estado_ativo'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def hollow_floor_active(f):
    _floor(True)


@landmark('flo_hollow_floor_dormant', group='nature', folder='ato2', size=(960, 500), origin=(480, 250), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'arena', 'piso', 'estado_dormente'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def hollow_floor_dormant(f):
    _floor(False)


# ------------------------------------------------------------------ paredes de raízes gigantes que delimitam o campo (modular 4,2 u)
def _root_wall(active, diag=False, turn=0):
    rt, glow, st = _pal(active)
    rr = random.Random(412 if active else 413)
    for k in range(5):
        y = -1.9 + k * .95
        root((.2, y, .05), (rr.uniform(-.2, .3), y + rr.uniform(-.4, .4), 4.6 + rr.uniform(-.3, .7)), .62, .3, rt, sag=.15, sides=9)
    geo.box((-.4, 0, 2.0), (.8, 4.4, 4.0), rt, bevel=0.08)
    for k in range(4):
        y = -1.6 + k * 1.05
        geo.cyl_between((.5, y, .5), (.55, y + .3, 3.6), .035, glow, sides=4)                # veios de energia na parede
    if not active:
        parts.hanging_vines(.6, -2.1, .6, 2.1, 4.2, 1.8, 6, m_leaf_deep(), 4)
        glow_mushrooms(.9, 1.6, 3, 4, spread=.3)
    else:
        for k in range(3):
            geo.cyl_between((.4, -1.5 + k * 1.4, 4.0), (.9, -1.5 + k * 1.4, 2.6), .1, rt, sides=5, r2=.02)
    if not diag:
        geo.rotate_all(45)
    elif turn:
        geo.rotate_all(turn)    # diag=True: sem girar (↘) ou girada 90° (↙): a parede corre ao longo de um eixo isométrico (2:1 na tela), sem espelhar o sprite


@landmark('flo_hollow_wall_active', group='nature', folder='ato2', size=(440, 580), origin=(220, 460), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'parede', 'modular', 'estado_ativo'), footprint=0, collision=(), samples=24)
def hollow_wall_active(f):
    _root_wall(True)


@landmark('flo_hollow_wall_dormant', group='nature', folder='ato2', size=(440, 580), origin=(220, 460), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'parede', 'modular', 'estado_dormente'), footprint=0, collision=(), samples=24)
def hollow_wall_dormant(f):
    _root_wall(False)


# ------------------------------------------------------------------ acesso: a ferida aberta na floresta
def _wound(open_):
    rt, glow, st = _pal(open_)
    rr = random.Random(414)
    dark = mats.flat('wound_dark', '#0a0810', rough=1.0, bevel_wear=0)
    geo.cyl((0, 0, 0), 3.0, .12, dark if open_ else m_moss_flat(), sides=18)              # a abertura no solo
    for k in range(12):                                                          # raízes rompidas ao redor (bordas da ferida)
        a = 2 * math.pi * k / 12 + rr.uniform(-.1, .1)
        root((math.cos(a) * 3.6, math.sin(a) * 3.6, .05), (math.cos(a) * 2.5, math.sin(a) * 2.5, 1.3 + rr.uniform(0, .8)), .28, .1, rt, sag=.1, sides=7)
    for k in range(7):
        a = k * .9
        parts.rock_mass((math.cos(a) * 3.4, math.sin(a) * 3.4, 0), (.7, .6, .5), m_rock_moss(), 90 + k, subdiv=3, rough=.25, flat_top=False)
    if open_:
        geo.cyl((0, 0, .13), 1.7, .03, glow, sides=18)                          # brilho fundo da corrupção
        _vein_ring(rr, glow)
    else:
        parts.leaf_cluster(0, 0, .15, 2.4, 22, m_fern(), 4, size=(.12, .26), flat=.4)
        geo.cyl((0, 0, .13), 1.4, .03, m_moss_flat(), sides=18)
    geo.rotate_all(45)


def _vein_ring(rr, glow):
    for k in range(9):
        a = rr.uniform(0, 6.28)
        geo.cyl_between((math.cos(a) * 1.0, math.sin(a) * 1.0, .1), (math.cos(a + .3) * 4.2, math.sin(a + .3) * 4.2, .05), .05, glow, sides=4)


@landmark('flo_hollow_wound_open', group='nature', folder='ato2', size=(720, 480), origin=(360, 260), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'acesso', 'ferida', 'estado_ativo'), footprint=60, collision=circ([(-2.6, 0), (2.6, 0), (0, -2.6), (0, 2.6)], 14), samples=24)
def hollow_wound_open(f):
    _wound(True)


@landmark('flo_hollow_wound_healing', group='nature', folder='ato2', size=(720, 480), origin=(360, 260), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'acesso', 'ferida', 'estado_dormente'), footprint=60, collision=circ([(-2.6, 0), (2.6, 0), (0, -2.6), (0, 2.6)], 14), samples=24)
def hollow_wound_healing(f):
    _wound(False)


# ------------------------------------------------------------------ aproximação corrompida (corrupção progressiva)
@landmark('flo_corrupt_ground_light', group='nature', folder='ato2', size=(420, 220), origin=(210, 110), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'corrupcao', 'nivel1', 'chao'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def corrupt_ground_light(f):
    _corrupt_patch(3, .5)


@landmark('flo_corrupt_ground_heavy', group='nature', folder='ato2', size=(420, 220), origin=(210, 110), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'corrupcao', 'nivel2', 'chao'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def corrupt_ground_heavy(f):
    _corrupt_patch(8, 1.0)


def _corrupt_patch(n, dens):
    rr = random.Random(420 + n)
    soil = mats.flat('corrupt_soil', '#1e1a24', rough=1.0, bevel_wear=0)
    for k in range(int(4 + n)):                                              # mancha irregular (vários discos sobrepostos), sem borda circular limpa
        a = rr.uniform(0, 6.28)
        d = rr.uniform(0, 1.5)
        geo.cyl((math.cos(a) * d, math.sin(a) * d, 0), rr.uniform(.5, 1.1), .02, soil, sides=9)
    for k in range(n):
        a = rr.uniform(0, 6.28)
        root((math.cos(a) * 2.4, math.sin(a) * 2.4, .03), (math.cos(a + .6) * .4, math.sin(a + .6) * .4, .03), .09, .04, m_root_dead(), sag=-.02, sides=5)
    for k in range(int(n * 1.5)):
        a = rr.uniform(0, 6.28)
        d = rr.uniform(.3, 2.2)
        geo.box((math.cos(a) * d, math.sin(a) * d, .04), (rr.uniform(.2, .5), .04, .02), m_eco_corrupt(), rot=(0, 0, a), bevel=0)


@landmark('flo_corrupt_root_spike', group='nature', folder='ato2', size=(240, 320), origin=(120, 250), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'corrupcao', 'espinho'), footprint=14, collision=circ([(0, 0)], 9), samples=24)
def corrupt_root_spike(f):
    rr = random.Random(430)
    for k in range(4):
        a = k * 1.6
        geo.cyl_between((math.cos(a) * .3, math.sin(a) * .3, 0), (math.cos(a) * .5, math.sin(a) * .5, 1.6 + rr.uniform(0, .8)), .14, m_root_dead(), sides=5, r2=.02)
    geo.box((.02, 0, .8), (.03, .03, .5), m_eco_corrupt(), bevel=0)
    parts.leaf_cluster(0, 0, .05, .6, 6, M('leaf_dry'), 3, size=(.1, .16), flat=.5)
    geo.rotate_all(45)


@landmark('flo_hollow_wall_active_diag', group='nature', folder='ato2', size=(600, 620), origin=(300, 470), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'parede', 'modular', 'diagonal', 'estado_ativo'), footprint=0, collision=(), samples=24)
def hollow_wall_active_diag(f):
    _root_wall(True, True)


@landmark('flo_hollow_wall_dormant_diag', group='nature', folder='ato2', size=(600, 620), origin=(300, 470), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'parede', 'modular', 'diagonal', 'estado_dormente'), footprint=0, collision=(), samples=24)
def hollow_wall_dormant_diag(f):
    _root_wall(False, True)


@landmark('flo_hollow_wall_active_diagb', group='nature', folder='ato2', size=(600, 620), origin=(300, 470), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'parede', 'modular', 'diagonal', 'estado_ativo'), footprint=0, collision=(), samples=24)
def hollow_wall_active_diagb(f):
    _root_wall(True, True, 90)


@landmark('flo_hollow_wall_dormant_diagb', group='nature', folder='ato2', size=(600, 620), origin=(300, 470), tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'boss', 'parede', 'modular', 'diagonal', 'estado_dormente'), footprint=0, collision=(), samples=24)
def hollow_wall_dormant_diagb(f):
    _root_wall(False, True, 90)


# ============================================================== PASSE FINAL (Parte E): recinto da Raiz Oca em PEÇA ÚNICA, duas camadas
from pro_ato2_memory import chamber_wall, _arc_coll


def _hollow_enclosure(active):
    """Recinto orgânico: camada interna de raízes torcidas e mais baixas (com espinhos/veios no ativo) + camada externa alta
    atrás (segunda camada, profundidade e silhueta); pontas descem em raízes grandes. Estado dormente = mesma forma, madeira
    acinzentada com musgo cicatrizando (a revanche reusa a forma ativa)."""
    if active:
        bark, fiber, spike, rune = m_root_dead(), m_root_dead(), m_root_dead(), m_eco_corrupt()
    else:
        bark, fiber, spike, rune = m_bark_old(), m_bark_old(), None, None
    chamber_wall(15.6, 132, 318, 131, bark, fiber, h=(5.2, 7.6), n=46, lean_in=.1, moss=not active, rune=rune)                 # camada externa
    chamber_wall(14.4, 126, 324, 133, bark, fiber, h=(2.2, 3.8), n=58, lean_in=.55, moss=not active, rune=rune, spikes=spike, spike_n=.35,
                 alcoves=((170, 10), (262, 12)))                                                                              # camada interna
    rr = random.Random(140)
    for th in (126, 324):
        t = math.radians(th)
        for k in range(3):
            s = .1 if th == 126 else -.1
            root((math.cos(t) * 15, math.sin(t) * 15, 4.0 - k), (math.cos(t + s) * (12.4 - k), math.sin(t + s) * (12.4 - k), .02), .9 - k * .15, .2, bark, sag=-.5, sides=8)
    if not active:
        for k in range(10):
            th = math.radians(rr.uniform(130, 320))
            parts.leaf_cluster(math.cos(th) * 14.2, math.sin(th) * 14.2, rr.uniform(.2, 2.5), .7, 10, m_fern(), 150 + k, size=(.1, .22), flat=.4)


for _st in ('active', 'dormant'):
    landmark(f'flo_hollow_enclosure_{_st}', group='nature', folder='ato2', size=(2140, 1120), origin=(1070, 960),
             tags=('ato2', 'floresta_ancestral', 'raiz_oca', 'arena', 'parede', 'passe_final', 'peca_unica', 'estado_' + ('ativo' if _st == 'active' else 'dormente')),
             footprint=0, collision=_arc_coll(14.4, 130, 320, 26, 22), samples=24)(lambda f, a=(_st == 'active'): _hollow_enclosure(a))
