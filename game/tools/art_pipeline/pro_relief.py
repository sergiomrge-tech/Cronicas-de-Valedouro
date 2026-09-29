"""Assets dedicados de relevo: colinas amplas e baixas (casam com o piso), fins e cantos de paredão, rampas de acesso.
IDs persistentes nat_hill_wide_*, nat_hill_low_*, nat_cliff_end_*, nat_cliff_corner_*, nat_ramp_*."""
import math
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import bpy
from vk import geo, parts
from vk.parts import M
from pro_landmarks import landmark
from pro_terrain import KINDS, strata_block, dress_cap

FAMS = ('earth', 'rock', 'sand', 'ice')
WALL_FAMS = ('rock', 'sand', 'ice')
GROUND_CAP = {'earth': 'turf', 'rock': 'turf', 'sand': 'sand_ground', 'ice': 'snow_ground'}


def _dressing(kind, r, hgt, seed, density=1.0):
    rr = random.Random(seed)
    rock_key = KINDS[kind][0]
    for i in range(int(4 * density) + 2):
        a = rr.uniform(0, 6.283)
        d = rr.uniform(.55, .95)
        parts.boulder((math.cos(a) * r * d, math.sin(a) * r * .9 * d, hgt * (1 - d) * .55), rr.uniform(.16, .3), M(rock_key), seed + i, squash=.7)
    if kind in ('earth', 'rock'):
        for i in range(int(4 * density)):
            a = rr.uniform(0, 6.283)
            d = rr.uniform(.1, .55) * r
            parts.leaf_cluster(math.cos(a) * d, math.sin(a) * d * .9, hgt * (1 - d / r) * .9, rr.uniform(.26, .4), 22, M('leaf'), seed + 30 + i, size=(.1, .18), flat=.6)
        parts.flowers(0, 0, r * .75, int(20 * density), seed=seed + 4)
        parts.grass_tufts(0, 0, r * .92, int(r * r * 4.5 * density), M('grass'), seed=seed + 5, h=.24)
    elif kind == 'sand':
        parts.grass_tufts(0, 0, r * .9, int(r * r * 3 * density), M('leaf_dry'), seed=seed + 5, h=.3)
    else:
        for i in range(int(3 * density) + 1):
            a = rr.uniform(0, 6.283)
            d = rr.uniform(.2, .7) * r
            geo.cyl((math.cos(a) * d, math.sin(a) * d, hgt * (1 - d / r) * .8), .07, rr.uniform(.3, .5), M('glass_ice'), sides=5, r2=.0)


def _mound(kind, r, hgt, seed, rough=.22, elong=1.0):
    """Colina rolante: esfera suavizada, base larga que morre no chão (sem paredão), cap do material do piso."""
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=5, radius=1.0)
    o = bpy.context.object
    from mathutils import Vector, noise
    for v in o.data.vertices:
        p = v.co
        n = noise.fractal(Vector((p.x * 1.3 + seed, p.y * 1.3, p.z * 1.3)), .8, 2.0, 4)
        k = 1 + n * rough
        z = max(p.z, -0.02)
        base = 1 - .18 * (1 - z)                                   # base alargada (pé da colina)
        rip = (math.sin((p.x * .7 + p.y * .5) * 8.0 + n * 3.0) * .05 * hgt * max(p.z, 0)) if kind == 'sand' else 0.0
        v.co = Vector((p.x * r * k * base * elong, p.y * r * .9 * k * base, z * hgt * k + rip))
    o.data.materials.append(M(GROUND_CAP[kind]))
    for pp in o.data.polygons:
        pp.use_smooth = True
    return o


def _hill(name, kind, r, hgt, seed, blocking, size, origin, tags):
    kw = dict(group='nature', folder='elevation', size=size, origin=origin, tags=tags, footprint=r * 22, samples=24)
    if blocking:
        kw['coll'] = (r * 1.45, r * 1.3)
    else:
        kw['collision'] = ()

    @landmark(name, **kw)
    def _b(f):
        rr = random.Random(seed)
        rock_key = KINDS[kind][0]
        if blocking:
            # colina em patamares: 3 níveis com lábio de rocha/solo nas faces voltadas ao jogador (leitura de volume)
            for lvl, (k, hf) in enumerate(((1.0, .5), (.7, .82), (.42, 1.0))):
                o = _mound(kind, r * k, hgt * hf, seed + lvl, rough=.2)
                o.location.z = 0
                if lvl < 2:
                    for j in range(9):
                        a = math.radians(-25 + 150 * j / 8 + rr.uniform(-6, 6))
                        rad = r * k * rr.uniform(.72, .86)
                        parts.rock_mass((math.cos(a) * rad, math.sin(a) * rad * .9, hgt * hf * .3), (rr.uniform(.5, .9), rr.uniform(.4, .7), hgt * hf * rr.uniform(.35, .5)),
                                        M(rock_key), seed + 50 + lvl * 20 + j, subdiv=3, rough=.3, taper=.1, flat_top=False)
        else:
            _mound(kind, r, hgt, seed)
        _dressing(kind, r, hgt, seed, density=1.4 if blocking else .8)
        # manchas de vegetação/areia/neve que quebram o cap uniforme
        for i in range(14 if blocking else 8):
            a = rr.uniform(0, 6.283)
            d = rr.uniform(.05, .8) * r
            z = hgt * (1 - (d / r) ** 2) * (1.0 if blocking else .9) * .9
            if kind in ('earth', 'rock'):
                parts.leaf_cluster(math.cos(a) * d, math.sin(a) * d * .9, z, rr.uniform(.22, .36), 16, M('leaf' if i % 3 else 'grass'), seed + 90 + i, size=(.08, .15), flat=.5)
            elif kind == 'sand':
                parts.boulder((math.cos(a) * d, math.sin(a) * d * .9, z), rr.uniform(.1, .2), M('rock_sand'), seed + 90 + i, squash=.5, detail=1)
            else:
                parts.boulder((math.cos(a) * d, math.sin(a) * d * .9, z), rr.uniform(.12, .24), M('snow_ground'), seed + 90 + i, squash=.5, detail=1)
    return _b


for _k in FAMS:
    _hill('nat_hill_wide_%s' % _k, _k, 3.0, 1.35, 501 + len(_k), True, (560, 360), (280, 250), ('elevacao', 'colina', 'ampla', _k))
    _hill('nat_hill_low_%s' % _k, _k, 2.3, .55, 511 + len(_k), False, (440, 260), (220, 180), ('elevacao', 'ondulacao', 'caminhavel', _k))


# ------------------------------------------------------------------ fins de paredão (descem até o chão)
def _end(kind, axis, sgn, seed):
    rock_key = KINDS[kind][0]
    L = 3.0
    name = 'nat_cliff_end_%s_%s%s' % (kind, axis, 'p' if sgn > 0 else 'm')

    @landmark(name, group='nature', folder='elevation', size=(380, 340), origin=(190, 270), tags=('elevacao', 'paredao', 'fim', kind),
              footprint=60, coll=((L * .7, 1.15) if axis == 'a' else (1.15, L * .7)), samples=24)
    def _b(f):
        rr = random.Random(seed)
        n = 5
        for i in range(n):
            t = i / (n - 1)
            h = 2.5 * (1 - t) ** 1.35 + .28
            u = sgn * (-L / 2 + (i + .5) * L / n) * .85 + (-sgn * .0)
            u = -sgn * (L / 2) + sgn * (i + .5) * (L / n)      # do topo (u<0 no sentido do sinal) até a ponta baixa
            w = 1.15 - .18 * t
            sx, sy = (L / n * 1.18, w) if axis == 'a' else (w, L / n * 1.18)
            x, y = (u, 0) if axis == 'a' else (0, u)
            strata_block_at(x, y, sx, sy, h, M(rock_key), seed + i, layers=max(2, int(h * 2.2)))
        # blocos soltos e cascalho na ponta baixa
        for j in range(5):
            u = sgn * (L / 2) * rr.uniform(.35, 1.0)
            x, y = (u, rr.uniform(-.5, .5)) if axis == 'a' else (rr.uniform(-.5, .5), u)
            parts.boulder((x, y, 0), rr.uniform(.14, .3), M(rock_key), seed + 40 + j, squash=.75)
        if kind == 'ice':
            parts.leaf_cluster(-sgn * .9 if axis == 'a' else 0, 0 if axis == 'a' else -sgn * .9, 2.7, .3, 10, M('snow_ground'), seed + 8, size=(.16, .24), flat=.6)
        elif kind == 'rock':
            parts.leaf_cluster(-sgn * .9 if axis == 'a' else 0, 0 if axis == 'a' else -sgn * .9, 2.7, .3, 12, M('leaf'), seed + 8, size=(.1, .17), flat=.6)
    return _b


def strata_block_at(x, y, sx, sy, h, mat, seed, layers=4):
    """strata_block deslocado: cria o bloco na origem, move os objetos novos e os junta à cena."""
    before = set(bpy.data.objects)
    strata_block(sx, sy, h, mat, seed, layers=layers, taper=.1, rough=.34)
    for o in set(bpy.data.objects) - before:
        o.location.x += x
        o.location.y += y


for _k in WALL_FAMS:
    for _ax in ('a', 'b'):
        for _s in (1, -1):
            _end(_k, _ax, _s, 601 + ord(_k[0]) + ord(_ax) + (0 if _s > 0 else 7))


# ------------------------------------------------------------------ cantos de paredão (L)
def _circles(cx, cy, sx, sy):
    from terrain_forms_data import footprint_circles, S
    out = []
    for (dx, dy, r) in footprint_circles(sx, sy, .85, .9):
        ox = .7071 * (cy - cx) * S * .5
        oy = .5 * .7071 * (cx + cy) * S * .5
        out.append((round(dx + ox, 1), round(dy + oy, 1), r))
    return tuple(out)


def _corner(kind, seed):
    rock_key = KINDS[kind][0]
    L = 2.6
    coll = _circles(-.7, 0, L, 1.15) + _circles(.7 + .0, -L / 2 + .58, 1.15, L - 1.15)

    @landmark('nat_cliff_corner_%s' % kind, group='nature', folder='elevation', size=(420, 380), origin=(210, 300), tags=('elevacao', 'paredao', 'canto', kind),
              footprint=70, collision=coll, samples=24)
    def _b(f):
        rr = random.Random(seed)
        strata_block_at(-.7, 0, L, 1.15, 2.6, M(rock_key), seed, layers=8)
        strata_block_at(.7, -L / 2 + .58, 1.15, L - 1.15, 2.6, M(rock_key), seed + 3, layers=8)
        parts.boulder((.7, .58 - .3, 2.6), .42, M(rock_key), seed + 9, squash=.9, detail=1)
        for i in range(5):
            a = rr.uniform(0, 6.283)
            parts.boulder((math.cos(a) * 1.5, math.sin(a) * 1.3, 2.4 + rr.uniform(0, .3)), rr.uniform(.2, .32), M(rock_key), seed + 20 + i, squash=.9, detail=1)
        parts.rubble(0, 0, 1.7, 10, M(rock_key), seed=seed + 5, rmin=.12, rmax=.3)
        if kind == 'ice':
            parts.icicles(-.7 - L * .3, .58, -.7 + L * .3, .58, 2.5, 6, M('glass_ice'), seed + 3)
        elif kind == 'rock':
            parts.hanging_vines(-.7 - L * .35, .58, -.7 + L * .35, .58, 2.5, 1.5, 5, M('leaf'), seed + 4)
    return _b


for _k in WALL_FAMS:
    _corner(_k, 701 + ord(_k[0]))


# ------------------------------------------------------------------ rampas de acesso (caminháveis)
def _ramp(kind, seed):
    rock_key = KINDS[kind][0]
    cap = GROUND_CAP[kind]

    @landmark('nat_ramp_%s' % kind, group='nature', folder='elevation', size=(560, 420), origin=(280, 300), tags=('elevacao', 'rampa', 'caminhavel', kind),
              footprint=60, collision=(), samples=24)
    def _b(f):
        rr = random.Random(seed)
        n = 8
        for k in range(n):
            h = .21 * (k + 1) + .06
            x = 1.5 - k * .43                       # a ponta alta fica em -x (junto ao platô); a baixa em +x
            w = 2.7 - k * .05
            parts.rock_mass((x, 0, 0), (.5, w, h), M(rock_key), seed + k, subdiv=3, rough=.14, terrace=0, taper=.03, flat_top=True)
            parts.slab_blob(x, 0, h + .02, .52, w - .12, .07, M(cap), seed + 20 + k, wobble=.05)
        for sgn in (-1, 1):
            for k in range(5):
                parts.boulder((-1.2 + k * .6, sgn * (1.5 + rr.uniform(-.05, .12)), .05 * k), .4 - k * .04, M(rock_key), seed + 40 + k + (sgn + 1), squash=.7)
        parts.grass_tufts(-.6, 0, 1.2, 16, M('grass') if kind in ('earth', 'rock') else M('leaf_dry'), seed=seed + 5, h=.22)
    return _b


for _k in FAMS:
    _ramp(_k, 801 + len(_k))
