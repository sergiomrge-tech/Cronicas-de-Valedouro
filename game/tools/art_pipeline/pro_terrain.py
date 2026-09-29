"""Elevações, falésias, colinas, cavernas e cachoeira produzidas em Blender (IDs persistentes dos protótipos nat_*/str_*)."""
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import bpy
from vk import geo, mats, parts
from vk.parts import M
from pro_landmarks import landmark

KINDS = {
    #  rock mat, cap mat, vegetation, tag
    'earth': ('rock', 'turf', 'colinas'),
    'rock': ('rock_grey', 'turf', 'rio'),
    'sand': ('rock_sand', 'sand_ground', 'deserto'),
    'ice': ('rock_ice', 'snow_ground', 'gelo'),
}


def dress_cap(kind, cx, cy, z, sx, sy, seed):
    """Vegetação/neve/areia sobre o topo: agrupamentos e área livre, não espalhamento uniforme."""
    import random
    rr = random.Random(seed)
    if kind in ('earth', 'rock'):
        for i in range(3):
            x, y = cx + rr.uniform(-.32, .32) * sx, cy + rr.uniform(-.32, .32) * sy
            parts.leaf_cluster(x, y, z + .2, rr.uniform(.22, .34), 22, M('leaf'), seed + i, size=(.1, .17), flat=.6)
        parts.grass_tufts(cx, cy, min(sx, sy) * .42, int(sx * sy * 2.4), M('grass'), seed=seed + 5, h=.26)
        parts.flowers(cx, cy, min(sx, sy) * .4, int(sx * sy * 1.2), seed=seed + 7)
        # tufos pendurados na borda frontal (lábio)
        for sgn_axis in (0, 1):
            edge = sx / 2 * .96 if sgn_axis == 0 else sy / 2 * .96
            for k in range(int((sy if sgn_axis == 0 else sx) * 1.6)):
                t = rr.uniform(-.45, .45)
                px, py = (cx + edge, cy + t * sy) if sgn_axis == 0 else (cx + t * sx, cy + edge)
                parts.leaf_cluster(px, py, z + .05, .13, 4, M('leaf'), seed + 40 + k + sgn_axis * 17, size=(.08, .13), flat=.5)
    elif kind == 'sand':
        for i in range(4):
            x, y = cx + rr.uniform(-.34, .34) * sx, cy + rr.uniform(-.34, .34) * sy
            parts.boulder((x, y, z), rr.uniform(.12, .22), M('rock_sand'), seed + i, squash=.6, detail=1)
        parts.grass_tufts(cx, cy, min(sx, sy) * .42, int(sx * sy * 1.6), mats_dry(), seed=seed + 3, h=.3)
    elif kind == 'ice':
        for i in range(5):
            x, y = cx + rr.uniform(-.34, .34) * sx, cy + rr.uniform(-.34, .34) * sy
            parts.boulder((x, y, z), rr.uniform(.14, .26), M('snow_ground'), seed + i, squash=.55, detail=1)
        for i in range(3):
            x, y = cx + rr.uniform(-.3, .3) * sx, cy + rr.uniform(-.3, .3) * sy
            geo.cyl((x, y, z), .07, rr.uniform(.3, .55), M('glass_ice'), sides=5, r2=.0)


def mats_dry():
    return M('leaf_dry')


def cliff_block(kind, sx, sy, h, seed, taper=0.07, rubble_n=9):
    rock_key, cap_key, _ = KINDS[kind]
    parts.rock_mass((0, 0, 0), (sx, sy, h), M(rock_key), seed, subdiv=5, rough=.34, freq=1.05, terrace=.55, step=.42, taper=taper, flat_top=True, squash_base=.03)
    cap = parts.slab_blob(0, 0, h + .04, sx * (1 - taper) * 1.02, sy * (1 - taper) * 1.02, .28, M(cap_key), seed + 2)
    dress_cap(kind, 0, 0, h + .04, sx * (1 - taper), sy * (1 - taper), seed + 9)
    parts.rubble(0, 0, max(sx, sy) * .5 * 1.02, rubble_n, M(rock_key), seed=seed + 11, rmin=.12, rmax=.3)
    if kind in ('earth', 'rock'):
        parts.hanging_vines(sx / 2 * .92, -sy * .4, sx / 2 * .92, sy * .4, h * .92, h * .55, 4, M('leaf'), seed + 21)
        parts.hanging_vines(-sx * .4, sy / 2 * .92, sx * .4, sy / 2 * .92, h * .92, h * .5, 3, M('leaf'), seed + 25)
        parts.grass_tufts(0, 0, max(sx, sy) * .62, int(sx * sy * .9), M('grass'), seed=seed + 4, h=.24)
    elif kind == 'ice':
        parts.icicles(sx / 2 * .95, -sy * .35, sx / 2 * .95, sy * .35, h * .96, 5, M('glass_ice'), seed + 31)
        parts.icicles(-sx * .35, sy / 2 * .95, sx * .35, sy / 2 * .95, h * .96, 4, M('glass_ice'), seed + 33)


def _reg(kind, name, sx, sy, h, seed, size, origin, coll, tags, taper=.07):
    @landmark(name, group='nature', folder='elevation', size=size, origin=origin, tags=tags, footprint=max(sx, sy) * 22, coll=coll, samples=24)
    def _b(f, kind=kind, sx=sx, sy=sy, h=h, seed=seed, taper=taper):
        cliff_block(kind, sx, sy, h, seed, taper)
    return _b


for _k in KINDS:
    _tag = KINDS[_k][2]
    _reg(_k, 'nat_plateau_%s_s' % _k, 2.0, 2.0, 1.6, 401 + len(_k), (300, 300), (150, 240), (2.0, 2.0), ('elevacao', 'planalto', _tag))
    _reg(_k, 'nat_plateau_%s_m' % _k, 3.2, 3.2, 2.1, 411 + len(_k), (420, 400), (210, 310), (3.2, 3.2), ('elevacao', 'planalto', _tag))
    _reg(_k, 'nat_ridge_%s_a' % _k, 4.6, 1.8, 1.7, 421 + len(_k), (420, 340), (210, 270), (4.6, 1.8), ('elevacao', 'cordilheira', _tag))
    _reg(_k, 'nat_ridge_%s_b' % _k, 1.8, 4.6, 1.7, 431 + len(_k), (420, 340), (210, 270), (1.8, 4.6), ('elevacao', 'cordilheira', _tag))


# ------------------------------------------------------------------ colinas suaves
def _hill(name, kind, r, hgt, seed):
    cap_key = KINDS[kind][1]
    rock_key = KINDS[kind][0]

    @landmark(name, group='nature', folder='elevation', size=(320, 240), origin=(160, 170), tags=('elevacao', 'colina', kind), footprint=r * 22, coll=(r * 1.5, r * 1.5), samples=24)
    def _b(f):
        import random
        rr = random.Random(seed)
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=4, radius=1.0)
        o = bpy.context.object
        from mathutils import Vector, noise
        for v in o.data.vertices:
            p = v.co
            n = noise.fractal(Vector((p.x * 1.6 + seed, p.y * 1.6, p.z * 1.6)), .8, 2.0, 4)
            k = 1 + n * .28
            rip = (math.sin((p.x * .8 + p.y * .6) * 9.0 + n * 3.0) * .06 * hgt) if kind == 'sand' else 0.0
            v.co = Vector((p.x * r * k, p.y * r * .92 * k, max(p.z, -0.05) * hgt * k + rip * max(p.z, 0)))
        o.data.materials.append(M(cap_key))
        for pp in o.data.polygons:
            pp.use_smooth = True
        for i in range(4):
            a = rr.uniform(0, 6.283)
            parts.boulder((math.cos(a) * r * .82, math.sin(a) * r * .78, 0), rr.uniform(.18, .32), M(rock_key), seed + i, squash=.7)
        if kind == 'earth':
            for i in range(3):
                a = rr.uniform(0, 6.283)
                d = rr.uniform(.15, .5) * r
                parts.leaf_cluster(math.cos(a) * d, math.sin(a) * d, hgt * .75, .3, 20, M('leaf'), seed + 30 + i, size=(.1, .17), flat=.6)
            parts.flowers(0, 0, r * .8, 14, seed=seed + 4)
        parts.grass_tufts(0, 0, r * .9, int(r * r * 4), M('grass') if kind == 'earth' else M('leaf_dry'), seed=seed + 5, h=.24)
    return _b


_hill('nat_hill_earth', 'earth', 1.5, .95, 441)
_hill('nat_hill_sand', 'sand', 1.6, .85, 442)
_hill('nat_hill_ice', 'ice', 1.5, .95, 443)


# ------------------------------------------------------------------ paredões (escarpas altas)
def _wall(kind, axis, seed):
    rock_key = KINDS[kind][0]
    L = 3.6

    @landmark('nat_wall_cliff_%s_%s' % (kind, axis), group='nature', folder='elevation', size=(380, 380), origin=(190, 310), tags=('elevacao', 'paredao', kind),
              footprint=70, coll=((L, 1.15) if axis == 'a' else (1.15, L)), samples=24)
    def _b(f):
        sx, sy = (L, 1.15) if axis == 'a' else (1.15, L)
        parts.rock_mass((0, 0, 0), (sx, sy, 2.7), M(rock_key), seed, subdiv=5, rough=.42, freq=1.15, terrace=.6, step=.45, taper=.14, flat_top=False, squash_base=.05)
        import random
        rr = random.Random(seed)
        n = int(L / .55)
        for i in range(n):
            u = -L / 2 + (i + .5) * L / n
            x, y = (u, rr.uniform(-.25, .25)) if axis == 'a' else (rr.uniform(-.25, .25), u)
            parts.boulder((x, y, 2.35 + rr.uniform(0, .3)), rr.uniform(.22, .36), M(rock_key), seed + i, squash=.9, detail=1)
        parts.rubble(0, 0, max(sx, sy) * .5, 9, M(rock_key), seed=seed + 5, rmin=.12, rmax=.3)
        if kind == 'ice':
            parts.icicles(-sx * .3, sy / 2, sx * .3, sy / 2, 2.4, 6, M('glass_ice'), seed + 3)
            parts.leaf_cluster(0, 0, 2.6, .3, 10, M('snow_ground'), seed + 8, size=(.16, .24), flat=.6)
        elif kind == 'rock':
            parts.hanging_vines(-sx * .35, sy / 2, sx * .35, sy / 2, 2.4, 1.4, 5, M('leaf'), seed + 4)
    return _b


for _k in ('rock', 'sand', 'ice'):
    for _ax in ('a', 'b'):
        _wall(_k, _ax, 451 + ord(_k[0]))


# ------------------------------------------------------------------ degraus, arco e pilares naturais
@landmark('nat_steps_stone', group='nature', folder='elevation', size=(320, 260), origin=(160, 200), tags=('elevacao', 'degraus'), footprint=40, samples=24)
def steps_stone(f):
    for k in range(6):
        parts.rock_mass((-.9 + k * .34, 0, 0), (.42, 2.0 - k * .06, .2 * (k + 1)), M('rock'), 461 + k, subdiv=3, rough=.16, terrace=0, taper=.03, flat_top=True)
        parts.slab_blob(-.9 + k * .34, 0, .2 * (k + 1) + .02, .42, 1.85, .05, M('turf'), 470 + k, wobble=.05)
    for sgn in (-1, 1):
        for k in range(3):
            parts.boulder((-.6 + k * .55, sgn * 1.2, 0), .32 - k * .04, M('rock'), 480 + k + (sgn + 1), squash=.75)


@landmark('nat_rock_arch_natural', group='nature', folder='elevation', size=(360, 380), origin=(180, 300), tags=('elevacao', 'arco', 'passagem'), footprint=50, collision=((-34, 6, 20), (34, 6, 20)), samples=24)
def rock_arch(f):
    parts.rock_mass((0, 0, 0), (3.0, 1.3, 2.7), M('rock_grey'), 471, subdiv=5, rough=.36, terrace=.4, step=.5, taper=.1, flat_top=False)
    cut = geo.box((0, 0, 1.0), (1.35, 2.2, 1.9), M('hole'), bevel=0)
    geo.boolean_cut(bpy.data.objects[0] if bpy.data.objects[0].name.startswith('rock') else [o for o in bpy.data.objects if o.name.startswith('rock')][0], cut, M('hole'))
    parts.rubble(0, 0, 1.6, 9, M('rock_grey'), seed=7)
    parts.hanging_vines(-1.2, .55, 1.2, .55, 2.5, 1.0, 4, M('leaf'), 3)
    parts.grass_tufts(0, 0, 1.6, 12, M('grass'), seed=5)


@landmark('nat_rock_pillars', group='nature', folder='elevation', size=(300, 320), origin=(150, 260), tags=('elevacao', 'pilares', 'passagem'), footprint=34, collision=((0, 0, 16), (30, 10, 12), (-26, 8, 12)), samples=24)
def rock_pillars(f):
    for i, (x, y, h, w) in enumerate([(0, 0, 2.7, .55), (.95, .35, 1.8, .42), (-.85, .3, 1.5, .4), (.3, -.75, 1.1, .34)]):
        parts.rock_mass((x, y, 0), (w * 1.6, w * 1.5, h), M('rock_grey'), 481 + i, subdiv=4, rough=.3, terrace=.5, step=.4, taper=.2, flat_top=False)
    parts.rubble(0, 0, 1.2, 8, M('rock_grey'), seed=9)
    parts.grass_tufts(0, 0, 1.3, 8, M('grass'), seed=3)


# ------------------------------------------------------------------ entrada de caverna (talhada na rocha)
@landmark('str_cave_entrance', group='dungeon', folder='structures', size=(440, 420), origin=(220, 330), tags=('estrutura', 'caverna', 'entrada'), footprint=52,
          collision=((-56, 8, 24), (-20, 14, 24), (20, 14, 24), (56, 8, 24)), samples=24)
def cave_entrance(f):
    import random
    rr = random.Random(571)
    rock = parts.rock_mass((0, 0, 0), (3.4, 3.8, 2.9), M('rock'), 571, subdiv=5, rough=.36, freq=1.0, terrace=.5, step=.45, taper=.12, flat_top=True, squash_base=.05)
    # abertura: caixa + meio-cilindro (arco irregular) atravessando a frente
    cut = geo.box((.9, 0, .8), (3.4, 1.35, 1.6), M('hole'), bevel=0)
    top = geo.cyl((-.8, 0, 1.62), .68, 3.4, M('hole'), rot=(0, 90, 0), sides=14)
    top.location = (top.location[0], top.location[1], top.location[2])
    geo.join([cut, top], 'cutter')
    cutter = bpy.data.objects['cutter']
    geo.boolean_cut(rock, cutter, M('hole'))
    # tampa de relva com vegetação e raízes penduradas no lábio da entrada
    parts.slab_blob(-.1, 0, 2.94, 3.1, 3.4, .3, M('turf'), 573)
    for i in range(4):
        parts.leaf_cluster(rr.uniform(-1.0, 1.0), rr.uniform(-1.2, 1.2), 3.15, rr.uniform(.25, .38), 24, M('leaf'), 580 + i, size=(.1, .17), flat=.6)
    parts.grass_tufts(-.1, 0, 1.4, 12, M('grass'), seed=8)   # só no topo
    parts.grass_tufts(1.9, -1.1, .9, 6, M('grass'), seed=9)
    parts.grass_tufts(1.9, 1.1, .9, 6, M('grass'), seed=10)
    parts.hanging_vines(1.2, -.9, 1.2, .9, 2.85, 1.0, 6, M('leaf'), 590)
    # madeiramento antigo na boca (postes, verga, escoras) + lanternas
    mwd, mw = M('wood_dark'), M('wood_old')
    for sy in (-.78, .78):
        geo.box((1.72, sy, .95), (.2, .2, 1.9), mwd, bevel=0.03)
        geo.beam((1.74, sy, .55), (1.74, sy * .55, 1.75), .1, .1, mwd, bevel=0.02)
    geo.box((1.74, 0, 1.92), (.24, 1.9, .22), mwd, bevel=0.03)
    for sy in (-.9, .9):
        geo.cyl_between((1.85, sy, 1.8), (1.85, sy, 1.55), .012, M('iron'), sides=4)
        geo.box((1.85, sy, 1.42), (.16, .16, .22), M('glass'), bevel=0.02)
    # pedras caídas, degrau e entulho em torno; cristais azuis tênues no fundo
    parts.rubble(.4, 0, 2.2, 14, M('rock'), seed=13, rmin=.14, rmax=.38)
    geo.box((2.05, 0, .06), (.6, 1.3, .12), M('rock'), bevel=0.04)
    for i in range(3):
        geo.cyl((-.5 + i * .12, -.3 + i * .3, .0), .09, .5, mats_crystal(), sides=5, r2=.0)
    geo.rotate_all(45)


def mats_crystal():
    return M('glass_ice')


# ------------------------------------------------------------------ Cachoeira da Aurora (landmark)
@landmark('nat_waterfall_front', group='nature', folder='water', size=(520, 460), origin=(260, 370), frames=8, tags=('agua', 'cachoeira', 'penhasco'), footprint=90,
          collision=((-78, -6, 34), (-40, -4, 30), (40, -4, 30), (78, -6, 34)), samples=24)
def waterfall_landmark(f):
    import random
    from mathutils import Vector
    rr = random.Random(491)
    rock = M('rock')
    # maciço com garganta central; dois patamares (queda em duas etapas)
    body = parts.rock_mass((-.2, 0, 0), (2.4, 4.4, 3.5), rock, 491, subdiv=6, rough=.34, freq=.95, terrace=.55, step=.5, taper=.1, flat_top=True, squash_base=.04)
    notch = geo.box((.2, 0, 3.0), (3.0, 1.15, 1.6), M('hole'), bevel=0)
    geo.boolean_cut(body, notch, rock)
    ledge = parts.rock_mass((1.25, 0, 0), (1.3, 2.4, 1.35), rock, 497, subdiv=4, rough=.26, terrace=.4, step=.4, taper=.1, flat_top=True)
    ledge_top = 1.35
    # topo de relva nas margens da garganta
    for sgn in (-1, 1):
        parts.slab_blob(-.2, sgn * 1.62, 3.54, 2.2, 1.9, .3, M('turf'), 499 + sgn, wobble=.08)
        for i in range(3):
            parts.leaf_cluster(rr.uniform(-.7, .3), sgn * rr.uniform(1.2, 1.9), 3.8, rr.uniform(.22, .34), 22, M('leaf'), 510 + i + sgn * 5, size=(.1, .17), flat=.6)
    parts.grass_tufts(-.2, 0, 2.0, 24, M('grass'), seed=17)
    # leito do rio sobre a garganta e lábio
    geo.box((-.4, 0, 2.42), (2.6, 1.02, .16), M('water'), bevel=0)
    wf = mats.waterfall('wf%d' % f, phase=f / 8.0, period=0.55)
    # cortina superior (do lábio ao patamar) e inferior (patamar -> lagoa), com leve abaulamento
    def sheet(x0, z0, x1, z1, w0, w1, name):
        nz = 8
        verts, faces = [], []
        for j in range(nz + 1):
            t = j / nz
            z = z0 + (z1 - z0) * t
            x = x0 + (x1 - x0) * (t ** 1.6)
            w = w0 + (w1 - w0) * t
            for i in range(5):
                u = i / 4 - .5
                verts.append((x + .05 * math.sin(t * 3.14), u * w, z))
        for j in range(nz):
            for i in range(4):
                a = j * 5 + i
                faces.append((a, a + 5, a + 6, a + 1))
        return geo.mesh_from(verts, faces, wf, name, smooth=True)
    sheet(1.05, 2.42, 1.62, ledge_top + .05, 1.0, 1.15, 'fall_hi')
    sheet(1.9, ledge_top, 2.35, .14, 1.15, 1.35, 'fall_lo')
    # água do patamar e da lagoa, espuma e névoa (periódicas)
    geo.box((1.62, 0, ledge_top + .02), (.85, 1.15, .06), M('water'), bevel=0)
    geo.cyl((2.6, 0, .0), 1.55, .12, M('water'), sides=24)
    foam = mats.flat('foam', '#f4ffff', rough=0.6, spec=0.2, bevel_wear=0.0)
    for i in range(18):
        a = rr.uniform(-1.4, 1.4)
        geo.cyl((2.4 + rr.uniform(0, .35), a * .55, .1), rr.uniform(.08, .18), .07, foam, sides=6, r2=.05)
    for i in range(10):
        ph = (f / 8 + i / 10) % 1.0
        r = (.06 + (1 - ph) * .1)
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=r)
        o = bpy.context.object
        o.location = (2.35 + rr.uniform(-.2, .3), rr.uniform(-.55, .55), .2 + ph * .95)
        o.data.materials.append(foam)
    # pedras e musgo à volta da lagoa, entulho sob a queda
    for i in range(9):
        a = math.pi * (0.1 + 0.8 * i / 8)
        x, y = 2.65 + math.cos(a) * 1.75, math.sin((a - math.pi / 2) * 1.6) * 1.9
        parts.boulder((x, y, 0), rr.uniform(.22, .42), M('rock'), 520 + i, squash=.75)
    parts.hanging_vines(-.3, -1.05, -.3, 1.05, 3.4, 1.0, 5, M('leaf'), 530)
    parts.grass_tufts(2.6, 0, 2.6, 16, M('grass'), seed=21)
    geo.rotate_all(45)
