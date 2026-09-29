"""Assets que dão corpo à Lore de REG_001 (fragmentos REG001_LORE_*): seda da Tecelã, rosto de Adrian Vale no gelo,
cartas seladas, círculo de pedras rúnico da Clareira do Ancião e sarcófago vazio das dunas. IDs persistentes nat_*."""
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

S = 30.0     # px de jogo por unidade (mesma projeção 2:1 do rig)


def circles(points, r):
    """Colisão circular em px de jogo para pontos (X, Y) em unidades locais."""
    out = []
    for (X, Y) in points:
        out.append((round(.7071 * (Y - X) * S, 1), round(.5 * .7071 * (X + Y) * S, 1), r))
    return tuple(out)


def silk_mat():
    return M('sail')


def strand(p0, p1, r=.028):
    geo.cyl_between(p0, p1, r, silk_mat(), sides=5)


# ------------------------------------------------------------------ LORE_06 — seda da Tecelã do Bosque
@landmark('nat_silk_tree', group='nature', folder='nature', size=(340, 500), origin=(170, 430), tags=('lore', 'aranha', 'bosque', 'corrompido'),
          footprint=24, collision=circles([(0, 0)], 10), samples=24)
def silk_tree(f):
    """Árvore seca coberta de seda: fios entre os galhos, massas de teia e casulos pendurados."""
    bark = M('bark_dead')
    rr = random.Random(611)
    pts = trunk(2.7, .22, .08, bark, lean=(.3, -.12), seed=611)
    ends = []

    def limb(p, ang, length, r, depth):
        if depth == 0:
            return
        end = (p[0] + math.cos(ang) * length * .8, p[1] + math.sin(ang) * length * .8, p[2] + length * rr.uniform(.35, .7))
        branch(p, end, r, r * .55, bark)
        ends.append(end)
        limb(end, ang + rr.uniform(-.9, .9), length * .68, r * .55, depth - 1)
        limb(end, ang + rr.uniform(-.9, .9) + 1.6, length * .55, r * .5, depth - 1)
    for k, z in enumerate((1.4, 1.95, 2.4)):
        p = pts[min(len(pts) - 1, int(z / 2.7 * (len(pts) - 1)))]
        limb(p, k * 2.1 + .5, 1.15 - k * .2, .07, 3)
    limb(pts[-1], .3, .9, .06, 3)
    # teia: massas de seda nas forquilhas e fios ligando galhos vizinhos
    for i, e in enumerate(ends[:12]):
        parts.leaf_cluster(e[0], e[1], e[2] - .05, rr.uniform(.22, .38), 14, silk_mat(), 620 + i, size=(.06, .11), flat=.35)
    for i in range(0, len(ends) - 1, 2):
        strand(ends[i], ends[i + 1])
        strand((ends[i][0], ends[i][1], ends[i][2] - .35), (ends[i + 1][0], ends[i + 1][1], ends[i + 1][2] - .3), .02)
    # casulos pendurados (ovoides envoltos em seda) — 3 de tamanhos diferentes
    for j, e in enumerate(ends[2:8:2]):
        h = .55 + .18 * j
        strand(e, (e[0], e[1], e[2] - h), .02)
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=.2 + .04 * j)
        o = bpy.context.object
        o.scale = (.7, .7, 1.7)
        o.location = (e[0], e[1], e[2] - h - .32)
        o.data.materials.append(M('cloth_cream'))
        for pp in o.data.polygons:
            pp.use_smooth = True
    # seda no chão ao pé do tronco + ossinhos
    parts.leaf_cluster(0, 0, .12, .55, 16, silk_mat(), 640, size=(.06, .1), flat=.3)
    parts.rubble(0, 0, .7, 4, M('rock'), seed=5, rmin=.05, rmax=.12)


# ------------------------------------------------------------------ LORE_06 — teia no chão com resto de mapa
@landmark('nat_web_ground', group='nature', folder='nature', size=(300, 200), origin=(150, 100), tags=('lore', 'aranha', 'teia', 'mapa'),
          footprint=10, collision=(), samples=24)
def web_ground(f):
    """Teia radial no chão; no centro, um pedaço de pergaminho preso (o mapa que a teia guarda)."""
    R = 1.9
    spokes = 10
    for k in range(spokes):
        a = k * 2 * math.pi / spokes + .1
        strand((0, 0, .05), (math.cos(a) * R, math.sin(a) * R * .9, .05), .035)
    for ring, rr_ in enumerate((.5, .95, 1.4, 1.85)):
        for k in range(spokes):
            a0 = k * 2 * math.pi / spokes + .1
            a1 = (k + 1) * 2 * math.pi / spokes + .1
            sag = .93 + .03 * math.sin(k + ring)
            strand((math.cos(a0) * rr_, math.sin(a0) * rr_ * .9, .05), (math.cos(a1) * rr_ * sag, math.sin(a1) * rr_ * .9 * sag, .05), .026)
    # pergaminho rasgado com marcas + orvalho
    geo.box((.1, -.05, .07), (.62, .42, .03), M('cloth_cream'), rot=(0, 0, .35), bevel=0.01)
    geo.box((.18, -.02, .095), (.4, .05, .01), M('rock_grey'), rot=(0, 0, .35), bevel=0.0)
    geo.box((.05, -.12, .095), (.3, .04, .01), M('rock_grey'), rot=(0, 0, .2), bevel=0.0)
    rr = random.Random(9)
    for i in range(6):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.05)
        o = bpy.context.object
        o.location = (rr.uniform(-1.2, 1.2), rr.uniform(-1.0, 1.0), .09)
        o.data.materials.append(M('glass_ice'))


# ------------------------------------------------------------------ LORE_08 — Adrian Vale no gelo do Círculo
@landmark('nat_ice_monolith_adrian', group='nature', folder='nature', size=(300, 420), origin=(150, 350), tags=('lore', 'adrian_vale', 'gelo', 'circulo'),
          footprint=28, collision=circles([(0, 0)], 12), samples=24)
def ice_monolith(f):
    """Bloco de gelo alto; na face voltada ao jogador, um homem de casaco azul preso no gelo (reflexo de Adrian Vale, ainda humano)."""
    ice = M('glass_ice')
    frost = M('rock_ice')
    parts.rock_mass((0, 0, 0), (1.5, .8, 3.0), frost, 71, subdiv=3, rough=.18, taper=.12, flat_top=False)
    # janela no gelo: laje de gelo claro na frente + a figura
    geo.box((0, .34, 1.45), (1.05, .18, 2.1), ice, bevel=0.06)
    # figura: casaco azul, calças escuras, cabeça e mão espalmada contra o gelo
    coat = M('cloth_blue')
    geo.box((0, .52, 1.3), (.5, .22, .95), coat, bevel=0.06)
    geo.box((0, .5, .55), (.4, .2, .7), M('iron'), bevel=0.04)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=.2)
    head = bpy.context.object
    head.location = (0, .54, 2.05)
    head.data.materials.append(mats.flat('skin', '#e0b090', rough=.8, bevel_wear=0.0))
    for pp in head.data.polygons:
        pp.use_smooth = True
    geo.box((.36, .58, 1.6), (.32, .1, .12), coat, rot=(0, 0, .3), bevel=0.03)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.09)
    hand = bpy.context.object
    hand.location = (.55, .62, 1.62)
    hand.data.materials.append(mats.flat('skin2', '#e0b090', rough=.8, bevel_wear=0.0))
    # cristais e neve na base
    rr = random.Random(83)
    for i in range(5):
        a = rr.uniform(0, 6.283)
        geo.cyl((math.cos(a) * .9, math.sin(a) * .7, 0), .09, rr.uniform(.35, .7), ice, sides=5, r2=.0)
    parts.rubble(0, 0, .95, 7, M('rock_snow'), seed=4, rmin=.1, rmax=.24)


# ------------------------------------------------------------------ LORE_09 — cartas seladas em gelo
@landmark('nat_ice_letters', group='nature', folder='nature', size=(240, 200), origin=(120, 150), tags=('lore', 'cartas', 'gelo', 'gruta'),
          footprint=14, collision=circles([(0, 0)], 8), samples=24)
def ice_letters(f):
    """Blocos de gelo com cartas seladas (envelopes com lacre vermelho) presas dentro."""
    ice = M('glass_ice')
    rr = random.Random(97)
    for i, (x, y, s) in enumerate(((0, 0, 1.0), (.55, .35, .7), (-.5, .3, .6))):
        parts.rock_mass((x, y, 0), (.9 * s, .7 * s, .8 * s), M('rock_ice'), 90 + i, subdiv=3, rough=.16, taper=.15, flat_top=False)
        geo.box((x, y + .3 * s, .45 * s), (.6 * s, .1, .6 * s), ice, bevel=0.04)
    for i, (x, z, rot) in enumerate(((0, .48, .2), (.5, .34, -.3), (-.5, .3, .1))):
        geo.box((x, .5, z), (.34, .05, .24), M('cloth_cream'), rot=(0, 0, rot), bevel=0.01)
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.05)
        seal = bpy.context.object
        seal.location = (x, .55, z)
        seal.data.materials.append(M('cloth_red'))
    for i in range(4):
        a = rr.uniform(0, 6.283)
        geo.cyl((math.cos(a) * .8, math.sin(a) * .6, 0), .06, rr.uniform(.25, .5), ice, sides=5, r2=.0)


# ------------------------------------------------------------------ LORE_03 — círculo de pedras com símbolos gastos
_CIRCLE = [(2.3 * math.cos(k * 2 * math.pi / 7 + .3), 2.3 * math.sin(k * 2 * math.pi / 7 + .3)) for k in range(7)]


@landmark('nat_stone_circle', group='nature', folder='nature', size=(520, 400), origin=(260, 240), tags=('lore', 'circulo_de_pedras', 'ancião', 'runas'),
          footprint=80, collision=circles(_CIRCLE, 8), samples=24)
def stone_circle(f):
    """Sete pedras em pé com runas gastas em volta de um disco de pedra no chão (símbolos apagados pelo tempo)."""
    rr = random.Random(301)
    mat = M('rock_grey')
    for i, (x, y) in enumerate(_CIRCLE):
        h = rr.uniform(1.2, 1.9)
        parts.rock_mass((x, y, 0), (.55, .5, h), mat, 310 + i, subdiv=3, rough=.22, taper=.25, flat_top=False, lean=(rr.uniform(-.05, .05), rr.uniform(-.05, .05)))
        # runa gasta voltada para o centro (emissão fraca)
        ang = math.atan2(-y, -x)
        geo.box((x + math.cos(ang) * .27, y + math.sin(ang) * .27, h * .55), (.06, .16, .34), M('rune'), rot=(0, 0, ang), bevel=0.0)
        parts.rubble(x, y, .45, 3, mat, seed=320 + i, rmin=.06, rmax=.14)
    # disco central rebaixado com anel gasto
    parts.slab_blob(0, 0, .02, 3.0, 3.0, .12, mat, 330, wobble=.05)
    geo.cyl((0, 0, .13), 1.0, .02, mats.flat('ringgrv', '#3c3a52', rough=.9, bevel_wear=0.0), sides=32)
    geo.cyl((0, 0, .145), .82, .02, mat, sides=32)
    for k in range(8):
        a = k * math.pi / 4
        geo.box((math.cos(a) * .55, math.sin(a) * .55, .16), (.4, .06, .02), M('rune'), rot=(0, 0, a), bevel=0.0)
    parts.grass_tufts(0, 0, 2.6, 22, M('grass'), seed=339, h=.24)


# ------------------------------------------------------------------ LORE_11 — sarcófago vazio das dunas
@landmark('nat_sarcophagus_open', group='nature', folder='nature', size=(320, 240), origin=(160, 170), tags=('lore', 'sarcofago', 'deserto', 'camara'),
          footprint=30, collision=circles([(-.4, 0), (.4, 0)], 10), samples=24)
def sarcophagus_open(f):
    """Sarcófago de arenito com a tampa deslocada e o interior vazio: quem dormia aqui já acordou."""
    sand = M('rock_sand')
    parts.rock_mass((0, 0, 0), (2.0, .9, .55), sand, 401, subdiv=3, rough=.1, terrace=0, taper=.08, flat_top=True)
    geo.box((0, 0, .5), (1.6, .55, .12), M('hole'), bevel=0.0)                      # cavidade vazia
    # tampa deslocada, apoiada na borda
    parts.rock_mass((.75, .55, .42), (1.9, .85, .22), sand, 402, subdiv=3, rough=.1, taper=.05, flat_top=True, lean=(.0, -.12))
    geo.box((-.2, .1, .6), (.9, .05, .02), M('cloth_cream'), rot=(0, 0, .2), bevel=0.0)   # tiras de linho soltas
    parts.rubble(0, 0, 1.2, 8, sand, seed=7, rmin=.06, rmax=.16)
    parts.grass_tufts(0, .8, .8, 6, M('leaf_dry'), seed=3, h=.2)
