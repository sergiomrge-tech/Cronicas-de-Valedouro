"""Lote 2 / Ato II — Floresta Ancestral, PARTE 2E: Santuário dos Cartógrafos (LOC_FOREST_CARTOGRAPHER_SHRINE, Q_MS02_VEIL_SHRINE) e saída para o Ato III.
Ruína mais antiga que a ocupação dos Guardas; geometria de oito linhas que ecoa as Ruínas do Primeiro Vento sem copiá-las.
Estados: INERTE (caminho encoberto, mecanismo apagado) → CAMINHO ABERTO (após o boss) → ATIVO (Selo Verde: o anel acende e projeta a segunda linha)."""
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
from ato2_common import *


def m_seal_light():
    """Luz do Selo Verde: verde-dourado claro e contido (linha do mapa), distinto do Eco azul e da corrupção roxa."""
    return X('seal_light', lambda: mats.emissive('seal_light', '#c8f090', 3.0))


def m_seal_dim():
    return X('seal_dim', lambda: mats.emissive('seal_dim', '#5e8a5a', .5))


def m_old_stone():
    """Pedra dos Cartógrafos: mais clara e lisa que a pedra dos Guardas, gasta pelo tempo (antiga)."""
    return X('old_stone', lambda: mats.masonry('old_stone', ('#3a4640', '#68786c', '#a4b4a0', '#dce6d4'), '#1a221e', block=(.8, .44), moss=.3, wear=.95))


# ------------------------------------------------------------------ anel de pedra (mecanismo) — 8 linhas radiais, 8 pedras de referência
def _ring(lit):
    """PASSE FINAL (Parte E): o SÍTIO inteiro dos Cartógrafos numa peça (sem rotação, 3/4). Fundação de lajes quebrada em DOIS níveis
    (terraço baixo irregular + estrado alto com degraus), borda desabando em entulho, mapa gravado no estrado como arcos e linhas
    INCOMPLETOS (cobertos por musgo/lajes — nada de disco perfeito), pedestal do Selo Verde, pilares sobre socos na borda, coluna
    caída, muro de fundo em L com relevo de mapa (backdrop) ligado à fundação, raízes e relva invadindo as juntas."""
    rr = random.Random(58)
    st = m_old_stone()
    sm = m_rock_moss()
    glow = m_seal_light() if lit else m_seal_dim()
    # terraço baixo: lajes irregulares com falhas e juntas de relva
    for i in range(-5, 5):
        for j in range(-4, 5):
            x, y = i * .95 + .47, j * .95
            if (x / 4.6) ** 2 + (y / 4.2) ** 2 * (1 + .25 * math.sin(i * 1.7 + j)) > 1 or rr.random() < .1:
                continue
            geo.box((x + rr.uniform(-.05, .05), y + rr.uniform(-.05, .05), .1 + rr.uniform(-.03, .03)), (.88, .88, .26), st if rr.random() < .8 else sm, rot=(rr.uniform(-.03, .03), rr.uniform(-.03, .03), rr.uniform(-.05, .05)), bevel=0.03)
    geo.box((0, 0, -.02), (8.6, 8.0, .2), sm, bevel=0.02)                            # leito sob as lajes (sem vão para o vazio)
    parts.grass_tufts(0, 0, 4.2, 40, M('grass'), seed=5, h=.22)
    for k in range(7):                                                              # borda +x desabando: lajes inclinadas e entulho
        geo.box((4.3 + rr.uniform(0, .6), -2.6 + k * .8, .0), (.8, .7, .22), st, rot=(0, rr.uniform(.2, .5), rr.uniform(-.3, .3)), bevel=0.03)
    parts.rubble(4.9, 0, 1.4, 9, sm, seed=7, rmin=.12, rmax=.3)
    # estrado alto recuado (segundo nível) com três degraus na face +x
    geo.box((-1.0, -.6, .5), (4.2, 4.2, .6), st, bevel=0.04)
    geo.box((-1.0, -.6, .82), (4.0, 4.0, .06), st, bevel=0.02)
    for k in range(3):
        geo.box((1.35 + k * .32, -.6, .62 - k * .2), (.4, 1.8, .2), st, bevel=0.03)
    # mapa gravado: arcos QUEBRADOS e linhas de comprimentos desiguais (parte coberta por lajes caídas e musgo)
    cx, cy, z = -1.0, -.6, .86
    for ring, keep in ((.9, .75), (1.6, .6)):
        n = 30
        for k in range(n):
            if rr.random() > keep:
                continue
            a = k * 2 * math.pi / n
            geo.box((cx + math.cos(a) * ring, cy + math.sin(a) * ring, z), (.2, .06, .02), glow, rot=(0, 0, a + math.pi / 2), bevel=0)
    for k in range(8):
        a = k * math.pi / 4 + rr.uniform(-.08, .08)
        L = rr.uniform(.8, 1.7)
        geo.box((cx + math.cos(a) * (.5 + L / 2), cy + math.sin(a) * (.5 + L / 2), z), (L, .07, .02), glow, rot=(0, 0, a), bevel=0)
    for k in range(3):
        geo.box((cx + rr.uniform(-1.4, 1.4), cy + rr.uniform(-1.4, 1.4), z + .05), (.7, .6, .12), sm, rot=(0, 0, rr.uniform(0, 3)), bevel=0.03)
    moss_patches(cx, cy, 3.4, 3.4, z, 10, 9)
    geo.cyl((cx, cy, z), .7, .32, st, sides=10, r2=.6)                               # pedestal do Selo Verde
    geo.cyl((cx, cy, z + .32), .36, .06, M('hole'), sides=10)
    if lit:
        ball((cx, cy, z + .65), .3, m_seal_light(), squash=1.2)
        geo.box((cx, cy + 2.6, z + .02), (.16, 3.4, .03), m_seal_light(), bevel=0)   # SEGUNDA LINHA: desce do estrado ao chão rumo à saída (+y = leste na tela)
        geo.box((cx + .2, 7.4, .05), (.16, 6.0, .03), m_seal_light(), bevel=0)
        geo.box((cx + .2, 7.4, .04), (.5, 6.0, .02), m_seal_dim(), bevel=0)
    # pilares sobre socos na borda da fundação (três em pé, um caído)
    for k, (x, y, h) in enumerate(((2.6, -3.4, 2.6), (-3.6, 2.4, 2.2), (2.8, 3.2, 1.3))):
        geo.box((x, y, .3), (.8, .8, .4), st, bevel=0.04)
        parts.tapered_shaft(x, y, .45, .45 + h, .56, .46, st, seed=30 + k)
        geo.box((x + .3, y, .45 + h * .6), (.05, .06, .45), glow, bevel=0)
        if h > 2:
            geo.box((x, y, .5 + h), (.7, .7, .16), sm, bevel=0.03)
    for k in range(4):                                                               # coluna caída em tambores sobre o terraço
        geo.cyl_between((1.2 + k * .62, 2.0 + k * .12, .42), (1.75 + k * .62, 2.1 + k * .12, .42), .26, st, sides=10)
    # muro de fundo em L (backdrop) nascendo da fundação, topo em degraus quebrados, relevo de mapa
    for i in range(9):
        y = -4.2 + i * .9
        h = 2.8 - abs(i - 2) * .25 - (1.2 if i > 6 else 0) + rr.uniform(-.2, .2)
        geo.box((-4.3, y, h / 2), (.6, .92, h), st, bevel=0.03)
    for i in range(5):
        x = -3.6 + i * .9
        h = 2.6 - i * .45 + rr.uniform(-.2, .2)
        geo.box((x, -4.5, h / 2), (.92, .6, h), st, bevel=0.03)
    for k in range(5):
        geo.box((-3.98, -3.2 + k * .6, 1.3 + (k % 2) * .4), (.03, .45, .05), glow, rot=(k * .3, 0, 0), bevel=0)
    parts.ivy(-3.98, -4.0, -3.98, -1.6, .3, 2.4, M('leaf'), seed=5, n=40)
    parts.rubble(-3.6, 3.6, 1.0, 6, sm, seed=11, rmin=.1, rmax=.26)
    for k in range(4):                                                               # raízes da floresta invadindo pelo fundo
        root((-5.2, -3 + k * 1.6, .2), (-3.0, -2.5 + k * 1.4, .95), .16, .06, m_bark_old(), sag=-.1, sides=6)
    parts.leaf_cluster(-3.4, 3.2, .1, 1.1, 14, m_fern(), 3, size=(.12, .26), flat=.4)
    if lit:
        parts.flowers(3.0, -1.0, 1.0, 10, seed=4)


@landmark('flo_cart_pillar', group='nature', folder='ato2', size=(200, 360), origin=(100, 300), tags=('ato2', 'floresta_ancestral', 'cartografos', 'ruina', 'pilar'), footprint=12, collision=circ([(0, 0)], 9), samples=24)
def cart_pillar(f):
    """Pilar antigo com sigilo de oito raios entalhado (motivo dos Cartógrafos)."""
    st = m_old_stone()
    parts.tapered_shaft(0, 0, 0, 2.6, .62, .5, st, seed=7)
    geo.box((.3, 0, 2.7), (.6, .8, .2), st, bevel=0.03)
    for k in range(8):
        a = k * math.pi / 4
        geo.box((.31, math.cos(a) * .2, 1.7 + math.sin(a) * .2), (.03, .16, .03), m_seal_dim(), rot=(a, 0, 0), bevel=0)
    root((-.4, .3, .05), (0, 0, 1.6), .08, .04, m_bark_old(), sag=.06, sides=5)
    parts.ivy(.31, -.3, .31, .3, .3, 2.4, M('leaf'), seed=3, n=16)
    geo.rotate_all(45)


@landmark('flo_cart_ruin_wall', group='nature', folder='ato2', size=(440, 360), origin=(220, 270), tags=('ato2', 'floresta_ancestral', 'cartografos', 'ruina', 'inscricao'), footprint=36, collision=circ([(-.2, -1.1), (-.2, 0), (-.2, 1.1)], 10), samples=24)
def cart_ruin_wall(f):
    """Muro em ruína com linhas de inscrição em cartografia (ecoa as Ruínas do Primeiro Vento sem copiá-las: aqui as linhas são horizontais e radiais)."""
    st, rr = m_old_stone(), random.Random(51)
    parts.rock_mass((0, 0, 0), (.8, 3.4, 2.3), st, 52, subdiv=4, rough=.14, terrace=.1, taper=.06, flat_top=False)
    for r_i in range(4):
        z = 1.6 - r_i * .32
        x0 = -1.3
        while x0 < 1.2:
            L = rr.uniform(.14, .4)
            geo.box((.42, x0 + L / 2, z), (.03, L, .04), m_seal_dim(), bevel=0)
            x0 += L + rr.uniform(.06, .12)
    for k in range(8):                                                            # rosa dos ventos de oito raios gravada
        a = k * math.pi / 4
        geo.box((.43, -.8 + math.cos(a) * .25, .55 + math.sin(a) * .25), (.02, .25, .02), m_seal_dim(), rot=(a, 0, 0), bevel=0)
    parts.hanging_vines(.4, -1.6, .4, 1.6, 2.2, 1.2, 6, m_leaf_deep(), 5)
    parts.rubble(.4, 0, 1.9, 8, m_rock_moss(), seed=4, rmin=.07, rmax=.2)
    geo.rotate_all(45)


# ------------------------------------------------------------------ caminho até o santuário: encoberto × aberto (modular 4 u)
def _path(open_):
    rr = random.Random(61)
    st = m_old_stone()
    if open_:
        for k in range(6):                                                        # lajes de passo antigas reaparecem
            geo.box((-1.6 + k * .7, rr.uniform(-.3, .3), .06), (.55, .7, .1), st, rot=(0, 0, rr.uniform(-.2, .2)), bevel=0.03)
        root((-.8, -1.5, .05), (.4, -1.2, .35), .1, .05, m_bark_old(), sag=.03, sides=5)
        root((.2, 1.5, .05), (1.2, 1.2, .35), .1, .05, m_bark_old(), sag=.03, sides=5)
        parts.leaf_cluster(0, -1.3, .05, .8, 8, m_fern(), 3, size=(.1, .2), flat=.4)
    else:
        for k in range(7):                                                        # raízes e mato cobrindo a trilha
            y = -1.5 + k * .5
            root((-1.8, y, .05), (1.8, y + rr.uniform(-.3, .3), .4 + rr.uniform(0, .5)), .16, .07, m_bark_old(), sag=.06, sides=6)
        canopy_mass([(0, 0, .8)], .9, 4, n_leaf=16, light=False, tuft=m_leaf_mass())
        geo.box((-.3, .2, .08), (.5, .6, .1), st, rot=(0, 0, .3), bevel=0.03)   # uma laje entrevista sob o mato
    geo.rotate_all(45)


@landmark('flo_cart_path_covered', group='nature', folder='ato2', size=(420, 300), origin=(210, 200), tags=('ato2', 'floresta_ancestral', 'cartografos', 'caminho', 'encoberto', 'modular'), footprint=30, collision=circ([(0, -1.2), (0, 0), (0, 1.2)], 12), samples=24)
def cart_path_covered(f):
    _path(False)


@landmark('flo_cart_path_open', group='nature', folder='ato2', size=(420, 300), origin=(210, 200), tags=('ato2', 'floresta_ancestral', 'cartografos', 'caminho', 'aberto', 'modular'), footprint=0, collision=(), samples=24, catcher=False)
def cart_path_open(f):
    _path(True)


# ------------------------------------------------------------------ terraço elevado com vista + marco de saída
@landmark('flo_cart_terrace', group='nature', folder='ato2', size=(760, 520), origin=(380, 330), tags=('ato2', 'floresta_ancestral', 'cartografos', 'terraco', 'vista'), footprint=90, collision=fpr(1.6, 6.0), samples=24)
def cart_terrace(f):
    """Borda de formação natural com terraço de lajes antigas: clareira elevada com vista para a direção da próxima região."""
    st, rk = m_old_stone(), m_rock_moss()
    parts.rock_mass((-.6, 0, 0), (2.2, 6.4, 1.6), rk, 91, subdiv=4, rough=.28, terrace=.3, step=.5, taper=.1, flat_top=True)
    geo.box((.5, 0, 1.62), (1.4, 5.6, .16), st, bevel=0.04)
    for k in range(5):
        geo.box((1.6 + k * .12, -1.0 + k * .5, .25 + k * .05), (.6, .7, .3), st, bevel=0.03)
    parts.hanging_vines(1.2, -2.8, 1.2, 2.8, 1.6, .9, 6, m_leaf_deep(), 3)
    glow_mushrooms(1.9, 2.4, 3, 4, spread=.3)
    parts.leaf_cluster(0, 2.8, .1, 1.2, 12, m_fern(), 5, size=(.12, .26), flat=.4)
    geo.rotate_all(45)


@landmark('flo_exit_marker', group='nature', folder='ato2', size=(240, 420), origin=(120, 340), tags=('ato2', 'floresta_ancestral', 'saida', 'ato3', 'marco'), footprint=12, collision=circ([(0, 0)], 9), samples=24)
def exit_marker(f):
    """Marco de saída da floresta: pedra-guia com estrela de oito pontas e faixa de pano ocre (o vento seco vindo do deserto)."""
    st = m_old_stone()
    parts.tapered_shaft(0, 0, 0, 2.4, .6, .45, st, seed=9)
    for k in range(8):
        a = k * math.pi / 4
        geo.box((.29, math.cos(a) * .22, 1.6 + math.sin(a) * .22), (.03, .2, .03), m_seal_dim(), rot=(a, 0, 0), bevel=0)
    geo.cyl((0, 0, 2.3), .04, 1.4, M('wood_dark'), sides=5)
    parts.cloth_sheet((.05, .0, 3.55), (.05, .9, 3.55), (.05, .0, 3.0), (.05, .9, 3.0), M('stripe_amber'), nu=4, nv=4, sag=.04, folds=.06, fold_n=2, phase=1)
    parts.grass_tufts(0, 0, .8, 6, M('leaf_dry'), seed=3, h=.3)
    geo.rotate_all(45)
