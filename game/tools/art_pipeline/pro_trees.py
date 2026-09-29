"""Árvores finais do REG_001 (revisão visual): copa com VOLUME (massa interna escura + lóbulos de folhagem iluminada por fora),
galhos visíveis entre lóbulos, tronco com raízes/contraforte e sombra de contato. Escala coerente com as casas de dois andares
(árvore adulta ≈ 6–7,5 u; casa ≈ 6,5 u até a cumeeira). Substituem as copas APPROVED pequenas e redondas."""
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
from ato1_common import X, ball


def _mat_leaf(name, cols):
    return X(name, lambda: mats.foliage(name, cols))


PAL = {
    'verde': (('#04200e', '#0a3a18', '#135a22', '#1f7a28', '#3a9a2e'), ('#0e4a1c', '#1f7a28', '#3fa032', '#79c43e', '#c6e85a')),
    'verde2': (('#06220f', '#0c3e1c', '#185e28', '#277e30', '#43a038'), ('#12501f', '#27802c', '#4aa838', '#8ccc46', '#d4ee6a')),
    'outono': (('#2a0e06', '#4a1c0a', '#6e2e10', '#94461a', '#b86424'), ('#6a2a0c', '#a44a16', '#d2782a', '#ecaa3e', '#fad872')),
    'dourada': (('#2a1a06', '#4a300c', '#6e4c14', '#94701e', '#b8922a'), ('#6a4a10', '#a47a1c', '#d2aa30', '#ecd04a', '#faf08a')),
}


def _crown(lobes, pal, seed, size=(.11, .19), n_leaf=150):
    """Lóbulos da copa: massa interna escura (volume e sombra própria) COBERTA por folhas pequenas em três camadas:
    sombra (base/lado de baixo), meio-tom (volta toda) e luz (topo voltado ao sol, alto-esquerdo)."""
    dark = _mat_leaf('tree_mass_' + pal, PAL[pal][0])
    light = _mat_leaf('tree_leaf_' + pal, PAL[pal][1])
    rr = random.Random(seed)
    for i, (x, y, z, r) in enumerate(lobes):
        ball((x, y, z), r * .78, dark, squash=.8)
        parts.leaf_cluster(x, y, z - r * .2, r * 1.02, int(n_leaf * .55), dark, seed + i * 7 + 1, size=size, flat=.45)     # borda inferior em sombra
        parts.leaf_cluster(x, y, z + r * .05, r * 1.0, n_leaf, light, seed + i * 7, size=size, flat=.6)                    # volta toda
        parts.leaf_cluster(x - r * .25, y - r * .25, z + r * .45, r * .62, int(n_leaf * .5), light, seed + i * 7 + 3, size=size, flat=.55)  # topo iluminado
    for k in range(14):                                           # tufos soltos na borda: contorno irregular, não uma bola
        x, y, z, r = lobes[rr.randrange(len(lobes))]
        a = rr.uniform(0, 6.28)
        parts.leaf_cluster(x + math.cos(a) * r * .95, y + math.sin(a) * r * .95, z + rr.uniform(-.4, .3) * r, r * .3, 14, light if k % 3 else dark, seed + 100 + k, size=size, flat=.5)


def _base(seed, r0):
    bark = M('bark_tree')
    rr = random.Random(seed)
    for k in range(5):                                            # raízes aparentes
        a = k * 1.25 + rr.uniform(-.2, .2)
        geo.cyl_between((math.cos(a) * r0 * .5, math.sin(a) * r0 * .5, .5), (math.cos(a) * r0 * 2.2, math.sin(a) * r0 * 2.2, .02), r0 * .3, bark, sides=6, r2=r0 * .08)
    parts.grass_tufts(0, 0, 1.2, 12, M('grass'), seed=seed, h=.3)
    parts.leaf_cluster(.4, .5, .05, .6, 8, M('leaf'), seed + 5, size=(.1, .16), flat=.95)


def oak(seed, h, r0, pal, lean, n_lobes, spread, n_leaf=150):
    rr = random.Random(seed)
    bark = M('bark_tree')
    pts = trunk(h * .55, r0, r0 * .55, bark, lean=lean, seed=seed, flare=True)
    top = pts[-1]
    lobes = []
    for k in range(n_lobes):                                      # galhos-mestres -> um lóbulo de copa na ponta de cada
        a = k * (2 * math.pi / n_lobes) + rr.uniform(-.3, .3)
        d = spread * rr.uniform(.55, 1.0)
        z_end = h * rr.uniform(.62, .8)
        p0 = pts[3 + (k % 2)]
        end = (top[0] + math.cos(a) * d, top[1] + math.sin(a) * d, z_end)
        branch(p0, end, r0 * .42, r0 * .16, bark)
        lobes.append((end[0], end[1], end[2] + .35, rr.uniform(1.05, 1.4)))
    lobes.append((top[0] + .1, top[1] - .1, h * .9, 1.45))               # coroa central mais alta
    lobes.append((top[0] - .4, top[1] + .3, h * .82, 1.2))
    _crown(lobes, pal, seed, n_leaf=n_leaf)
    _base(seed, r0)


def pine_tall(seed, h, snow=False):
    rr = random.Random(seed)
    trunk(h * .95, .24, .06, M('bark_pine'), seed=seed)
    dark = _mat_leaf('pine_mass', ('#021a10', '#06301c', '#0c4424', '#145a2c', '#1f7034'))
    light = _mat_leaf('pine_needle_snow' if snow else 'pine_needle', ('#0a2a2c', '#184a44', '#3a7860', '#c8e0ec', '#ffffff') if snow else ('#0a3a22', '#155a2e', '#257a38', '#4a9e44', '#8cc860'))
    tiers = 8
    for i in range(tiers):                                        # camadas cônicas: disco escuro + agulhas claras na borda superior
        t = i / (tiers - 1)
        z = h * (.22 + .72 * t)
        r = 1.55 * (1 - t) + .2
        geo.cyl((0, 0, z - .25), r, .5, dark, sides=10, r2=r * .35)
        n = int(10 + r * 12)
        for k in range(n):
            a = 2 * math.pi * k / n + rr.uniform(-.15, .15) + i * .4
            d = r * rr.uniform(.6, 1.0)
            parts.leaf_cluster(math.cos(a) * d, math.sin(a) * d, z - .05, .24, 9, light, seed + i * 31 + k, size=(.05, .16), flat=.25)
    parts.grass_tufts(0, 0, 1.0, 10, M('grass'), seed=seed, h=.28)
    parts.leaf_cluster(0, 0, .04, 1.0, 14, M('leaf_dry'), seed + 9, size=(.08, .12), flat=.95)


def birch_tall(seed, h):
    rr = random.Random(seed)
    bark = M('bark_birch')
    lobes = []
    for s, (dx, dy) in enumerate(((0, 0), (.5, .3))):              # dois troncos finos
        pts = trunk(h * .8, .15, .06, bark, lean=(.25 + dx * .3, .1 - dy), seed=seed + s)
        for k in range(3):
            p = pts[3 + k % 2]
            a = rr.uniform(0, 6.28)
            end = (p[0] + math.cos(a) * .8, p[1] + math.sin(a) * .8, p[2] + .7)
            branch(p, end, .05, .02, bark)
            lobes.append((end[0], end[1], end[2] + .3, rr.uniform(.7, .9)))
        lobes.append((pts[-1][0], pts[-1][1], pts[-1][2] + .3, .85))
    _crown(lobes, 'dourada' if seed % 2 else 'verde2', seed, size=(.09, .15), n_leaf=90)
    _base(seed, .15)


TREE = dict(group='nature', folder='trees', size=(820, 980), origin=(410, 820), footprint=26, samples=24)


def _reg(tid, fn, tags, coll=12.0):
    landmark(tid, tags=('arvore', 'revisao_visual') + tags, collision=((0.0, 0.0, coll),), **TREE)(fn)


_reg('nat_oak_a', lambda f: oak(401, 7.0, .42, 'verde', (.3, .1), 5, 1.7), ('carvalho', 'verde'))
_reg('nat_oak_b', lambda f: oak(433, 6.2, .36, 'verde2', (-.35, .2), 4, 1.45), ('carvalho', 'verde'))
_reg('nat_oak_c', lambda f: oak(467, 7.6, .46, 'verde', (.1, -.3), 6, 1.9, n_leaf=170), ('carvalho', 'verde', 'grande'))
_reg('nat_oak_autumn', lambda f: oak(491, 6.6, .4, 'outono', (.2, .25), 5, 1.6), ('carvalho', 'outono'))
_reg('nat_oak_golden', lambda f: oak(509, 6.0, .36, 'dourada', (-.2, -.2), 4, 1.5), ('carvalho', 'dourada'))
_reg('nat_pine_tall_a', lambda f: pine_tall(521, 7.2), ('pinheiro',), coll=10.0)
_reg('nat_pine_tall_b', lambda f: pine_tall(547, 6.0), ('pinheiro',), coll=10.0)
_reg('nat_pine_tall_snow', lambda f: pine_tall(563, 6.6, snow=True), ('pinheiro', 'neve'), coll=10.0)
_reg('nat_birch_tall', lambda f: birch_tall(577, 6.0), ('betula',), coll=9.0)
