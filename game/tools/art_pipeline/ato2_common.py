"""Materiais e peças comuns do Lote 2 (Ato II — Floresta Ancestral): pedra pré-guerra coberta de musgo, cascas antigas, bioluminescência discreta.
Mesma escala/projeção/família de acabamento do Ato I (60 px/u de render, foot anchor, arquitetura frontal girada 45°)."""
import math
import random

import bpy
from vk import geo, mats, parts
from vk.parts import M
from ato1_common import X, S, ball, lantern, torch, m_gold, m_scorch, m_bone, m_red_rag, m_straw, m_parchment, m_ink, m_canvas, m_sack


def fpr(depth, width, step=.9, r=None):
    """Colisão de um volume frontal (girado 45°): largura vira eixo x da tela (30 px/u), profundidade vira y (15 px/u)."""
    out = []
    ny = max(1, int(math.ceil(width / step)))
    nx = max(1, int(math.ceil(depth / step)))
    for j in range(ny):
        Y = -width / 2 + (j + .5) * width / ny
        for i in range(nx):
            X_ = -depth / 2 + (i + .5) * depth / nx
            out.append((round(30 * Y, 1), round(15 * X_, 1), r or round(max(width / ny, 1.0) * 30 * .5 * 1.05, 1)))
    return tuple(out)


def circ(points, r):
    return tuple((round(.7071 * (Y - X_) * S, 1), round(.5 * .7071 * (X_ + Y) * S, 1), r) for (X_, Y) in points)


def m_stone_moss():
    """Pedra pré-guerra: cinza-esverdeada, musgo denso e desgaste alto (idade anterior à ocupação dos Guardas)."""
    return X('stone_moss', lambda: mats.masonry('stone_moss', ('#26352e', '#4c6656', '#86a08c', '#c4d4bc'), '#121c16', block=(.62, .34), moss=.62, wear=.85))


def m_rock_moss():
    return X('rock_moss', lambda: mats.rock('rock_moss', ('#1c2a26', '#3e5648', '#6c8a72', '#a4c0a0', '#dceccc'), moss=.75))


def m_bark_old():
    """Casca de árvore ancestral: sulcos fundos, tom quente-escuro com musgo."""
    return X('bark_old', lambda: mats.bark('bark_old', ('#1a120e', '#38281c', '#5c4430', '#86674a'), moss=.55))


def m_leaf_deep():
    """Copa antiga: verdes profundos com toques dourados de luz filtrada."""
    return X('leaf_deep', lambda: mats.foliage('leaf_deep', ('#06281a', '#0e4a2a', '#1a6e32', '#3c9636', '#88bc50')))


def m_leaf_mass():
    """Massa interna da copa: verde muito escuro (o volume), com os tufos claros por cima."""
    return X('leaf_mass', lambda: mats.foliage('leaf_mass', ('#03140c', '#062a16', '#0c4420', '#186a28', '#2c8a30')))


def m_leaf_light():
    return X('leaf_light', lambda: mats.foliage('leaf_light', ('#0e3a24', '#1a5e30', '#2e8038', '#5ea444', '#a4c868')))


def m_moss_flat():
    return X('moss_flat', lambda: mats.ground('moss_flat', ('#16301c', '#244a2a', '#3a6a36', '#588a44', '#82aa5a'), scale=8.0))


def m_roof_moss():
    """Telhado de palha velha coberto de musgo: verde-oliva apagado, não o dourado do palheiro novo."""
    return X('roof_moss', lambda: mats.shingles('roof_moss', ('#1c2414', '#38401e', '#5c6030', '#8a8a4c'), mortar='#141a0c', w=.22, h=.14))


def m_fern():
    return X('fern', lambda: mats.foliage('fern', ('#0a3222', '#14603a', '#2a8a44', '#5cba4a', '#a8e068')))


def m_glow():
    """Bioluminescência discreta (verde-azulada suave, nunca neon)."""
    return X('glow_bio', lambda: mats.emissive('glow_bio', '#7ce8b8', 2.2))


def m_glow_dim():
    return X('glow_bio_dim', lambda: mats.emissive('glow_bio_dim', '#4ab890', 1.0))


def m_eco_corrupt():
    """Corrupção do Eco (Raiz Oca): roxo-azulado escuro com brilho contido."""
    return X('eco_corrupt', lambda: mats.emissive('eco_corrupt', '#8a5cff', 3.0))


def m_root_dead():
    """Raiz corrompida: madeira quase preta com veios."""
    return X('root_dead', lambda: mats.bark('root_dead', ('#0c0a10', '#201c2a', '#3a3446', '#5a5268'), moss=0.0))


def m_ranger_cloth():
    """Verde dos Guardas Verdes."""
    return X('ranger_cloth', lambda: mats.cloth('ranger_cloth', '#2e6a44'))


def m_herb():
    return X('herb', lambda: mats.foliage('herb', ('#2a3a10', '#587a1e', '#8aaa2e', '#bcd050', '#e4e888')))


def root(p0, p1, r0, r1, mat, sag=0.0, sides=7):
    """Raiz sinuosa entre dois pontos (3 segmentos com curvatura)."""
    mid = ((p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2, (p0[2] + p1[2]) / 2 - sag)
    q0 = ((p0[0] + mid[0]) / 2, (p0[1] + mid[1]) / 2, (p0[2] + mid[2]) / 2 + sag * .3)
    q1 = ((p1[0] + mid[0]) / 2, (p1[1] + mid[1]) / 2, (p1[2] + mid[2]) / 2 + sag * .3)
    rm = (r0 + r1) / 2
    geo.cyl_between(p0, q0, r0, mat, sides=sides, r2=(r0 + rm) / 2)
    geo.cyl_between(q0, q1, (r0 + rm) / 2, mat, sides=sides, r2=(r1 + rm) / 2)
    geo.cyl_between(q1, p1, (r1 + rm) / 2, mat, sides=sides, r2=r1)


def buttress_roots(r_trunk, h, n, mat, seed=0, spread=2.3, r_tip=.06):
    """Raízes-contraforte ao redor de um tronco: sobem no tronco e descem em arco até o chão."""
    rr = random.Random(seed)
    for k in range(n):
        a = 2 * math.pi * k / n + rr.uniform(-.25, .25)
        L = r_trunk * spread * rr.uniform(.85, 1.25)
        root((math.cos(a) * r_trunk * .6, math.sin(a) * r_trunk * .6, h), (math.cos(a) * L, math.sin(a) * L, .05), r_trunk * .26, r_tip, mat, sag=-.15)


def glow_mushrooms(cx, cy, n, seed=0, spread=.5, h=.22):
    rr = random.Random(seed)
    for k in range(n):
        x, y = cx + rr.uniform(-spread, spread), cy + rr.uniform(-spread, spread)
        hh = h * rr.uniform(.6, 1.3)
        geo.cyl((x, y, 0), .025, hh, M('cloth_cream'), sides=5)
        ball((x, y, hh + .02), hh * .6, m_glow() if k % 3 == 0 else m_glow_dim(), squash=.5)


def moss_patches(cx, cy, sx, sy, z, n, seed=0, mat=None, size=(.3, .6)):
    """Placas de musgo achatadas sobre uma superfície (em vez de folhas soltas)."""
    rr = random.Random(seed)
    mat = mat or m_moss_flat()
    for _ in range(n):
        geo.box((cx + rr.uniform(-sx / 2, sx / 2), cy + rr.uniform(-sy / 2, sy / 2), z + .012), (rr.uniform(*size), rr.uniform(*size) * .8, .03), mat, rot=(0, 0, rr.uniform(0, 3)), bevel=0.01)


def canopy_mass(centers, radius, seed=0, dark=True, n_leaf=46, size=(.26, .4), light=True, tuft=None):
    """Copa volumosa: massa escura de esferas achatadas + tufos de folhas por cima (luz filtrada nas bordas)."""
    rr = random.Random(seed)
    for i, c in enumerate(centers):
        ball((c[0], c[1], c[2]), radius * rr.uniform(.85, 1.05), m_leaf_mass(), squash=.72)
        parts.leaf_cluster(c[0], c[1], c[2] + radius * .35, radius * .95, n_leaf, tuft or (m_leaf_light() if (light and i % 2) else m_leaf_deep()), seed + i * 5, size=size, flat=.6)


def m_pool(corrupt):
    """Espelho d'água do santuário: azul-esverdeado vivo (purificado) ou roxo-negro parado (corrompido)."""
    if corrupt:
        return X('pool_corrupt', lambda: mats.flat('pool_corrupt', '#1c1230', rough=.4, spec=.5, emission='#5a3aa8', emission_strength=.25, bevel_wear=0))
    return X('pool_pure', lambda: mats.flat('pool_pure', '#2a8a96', rough=.2, spec=.8, emission='#5ad0c0', emission_strength=.5, bevel_wear=0))
