"""Vegetação e rochas de cenário produzidas em Blender (árvores principais, cactos, arbustos, pedras).

Mantém os IDs persistentes, tamanhos de quadro, âncoras, colisão e pegada de vegetação dos assets anteriores (lidos de kit.json),
para que a troca seja transparente para o mundo REG_001.
"""
import json
import math
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import bpy
from mathutils import Vector
from vk import geo, mats, parts
from vk.parts import M
from pro_landmarks import landmark

KIT = HERE / 'legacy_kit_snapshot.json'      # metadados dos protótipos substituídos (id, quadro, âncora, colisão, pegada)
_LEGACY = {e['id']: e for e in json.loads(KIT.read_text(encoding='utf-8'))} if KIT.exists() else {}


def legacy(id, **over):
    """Registra o gerador `fn(f)` para `id` herdando metadados do asset anterior."""
    e = _LEGACY[id]
    kw = dict(group=e['group'], folder=e['folder'], size=tuple(e['frame_size']), origin=tuple(e['foot']), frames=e['frames'], tags=tuple(e['tags']), footprint=e['footprint'],
              blocks=e['blocks_radius'], samples=24)
    if e.get('collision'):
        kw['collision'] = tuple(tuple(c) for c in e['collision'])
    kw.update(over)
    return landmark(id, **kw)


# ------------------------------------------------------------------ troncos e galhos
def trunk(h, r0, r1, mat, lean=(0, 0), seed=0, flare=True):
    """Tronco cônico com raízes aparentes e ligeira curvatura (segmentos)."""
    rr = random.Random(seed)
    n = 5
    pts = []
    for i in range(n + 1):
        t = i / n
        pts.append((lean[0] * t * t + rr.uniform(-.02, .02), lean[1] * t * t + rr.uniform(-.02, .02), h * t))
    for i in range(n):
        ra = r0 + (r1 - r0) * i / n
        rb = r0 + (r1 - r0) * (i + 1) / n
        geo.cyl_between(pts[i], pts[i + 1], ra, mat, sides=10, r2=rb)
    if flare:
        for k in range(4):
            a = k * 1.6 + rr.uniform(-.3, .3)
            geo.cyl_between((math.cos(a) * r0 * 1.9, math.sin(a) * r0 * 1.9, 0), (math.cos(a) * r0 * .7, math.sin(a) * r0 * .7, h * .18), r0 * .28, mat, sides=6, r2=r0 * .12)
    return pts


def branch(p0, p1, r0, r1, mat):
    return geo.cyl_between(p0, p1, r0, mat, sides=7, r2=r1)


def canopy_clumps(centers, radius, mat, seed, n_each=26, size=(.13, .2), flat=.6):
    for i, c in enumerate(centers):
        parts.leaf_cluster(c[0], c[1], c[2], radius * (1 + .1 * math.sin(i * 2.3)), n_each, mat, seed + i * 7, size=size, flat=flat)


# ------------------------------------------------------------------ pinheiros
def pine(f, snow=False, seed=1):
    rr = random.Random(seed)
    tr = M('bark_pine')
    trunk(3.9, .2, .07, tr, seed=seed)
    needle = M('needle_snow' if snow else 'needle')
    tiers = [(.9, 1.15, 1.5), (1.5, .98, 1.4), (2.1, .82, 1.2), (2.7, .64, 1.0), (3.25, .44, .8), (3.7, .24, .6)]
    for i, (z, r, s) in enumerate(tiers):
        # cada camada = anel de tufos de agulhas (ramos) em queda, com folgas
        n = int(10 + r * 8)
        for k in range(n):
            a = 2 * math.pi * k / n + rr.uniform(-.2, .2) + i * .5
            d = r * rr.uniform(.55, 1.0)
            bx, by = math.cos(a) * d, math.sin(a) * d
            bz = z - d * .28 + rr.uniform(-.06, .06)
            geo.cyl_between((0, 0, z + .12), (bx, by, bz), .035, tr, sides=5, r2=.012)
            parts.leaf_cluster(bx, by, bz, .34 + r * .12, 5, needle, seed + i * 31 + k, size=(.11, .19), flat=.34)
    parts.leaf_cluster(0, 0, 4.0, .22, 6, needle, seed + 99, size=(.1, .16), flat=.5)
    geo.cyl((0, 0, 4.0), .04, .4, tr, sides=5, r2=.0)
    parts.grass_tufts(0, 0, .8, 5, M('grass'), seed=seed + 5, h=.2)
    parts.rubble(0, 0, .55, 3, M('rock'), seed=seed + 3, rmin=.06, rmax=.12)


legacy('nat_tree_pine')(lambda f: pine(f, False, 11))
legacy('nat_tree_pine_snow')(lambda f: pine(f, True, 12))


# ------------------------------------------------------------------ bétula
@legacy('nat_tree_birch')
def birch(f):
    bark = M('bark_birch')
    lean = (.2, .12)
    pts = trunk(3.0, .16, .07, bark, lean=lean, seed=21)
    leaf = M('leaf_birch')
    rr = random.Random(23)
    tops = []
    for k in range(5):
        t = .5 + k * .12
        p = pts[min(len(pts) - 1, int(t * len(pts)))]
        a = k * 2.2 + .4
        end = (p[0] + math.cos(a) * .8, p[1] + math.sin(a) * .8, p[2] + .5 + k * .1)
        branch(p, end, .045, .015, bark)
        tops.append(end)
    tops.append((pts[-1][0], pts[-1][1], pts[-1][2] + .4))
    canopy_clumps([(t[0], t[1], t[2] + .15) for t in tops], .55, leaf, 3, n_each=24, size=(.11, .17), flat=.5)
    parts.grass_tufts(0, 0, .8, 6, M('grass'), seed=6, h=.2)
    parts.flowers(0, 0, .8, 4, seed=7)


# ------------------------------------------------------------------ árvore seca
@legacy('nat_tree_dead')
def dead(f):
    bark = M('bark_dead')
    rr = random.Random(31)
    pts = trunk(2.3, .22, .08, bark, lean=(.25, -.1), seed=31)
    top = pts[-1]
    def limb(p, ang, length, r, depth):
        if depth == 0:
            return
        end = (p[0] + math.cos(ang) * length * .8, p[1] + math.sin(ang) * length * .8, p[2] + length * rr.uniform(.35, .7))
        branch(p, end, r, r * .55, bark)
        limb(end, ang + rr.uniform(-.9, .9), length * .68, r * .55, depth - 1)
        limb(end, ang + rr.uniform(-.9, .9) + 1.6, length * .55, r * .5, depth - 1)
    for k, z in enumerate((1.3, 1.75, 2.15)):
        p = pts[min(len(pts) - 1, int(z / 2.3 * (len(pts) - 1)))]
        limb(p, k * 2.1 + .5, 1.0 - k * .15, .06, 3)
    limb(top, .3, .8, .06, 3)
    for k in range(3):
        parts.leaf_cluster(rr.uniform(-.5, .5), rr.uniform(-.5, .5), 0, .2, 4, M('leaf_dry'), 40 + k, size=(.06, .1), flat=.4)
    parts.grass_tufts(0, 0, .9, 6, M('leaf_dry'), seed=9, h=.2)
    parts.rubble(0, 0, .6, 3, M('rock'), seed=5, rmin=.06, rmax=.14)


# ------------------------------------------------------------------ palmeira
@legacy('nat_tree_palm')
def palm(f):
    bark = M('bark_tree')
    rr = random.Random(41)
    pts = trunk(3.2, .17, .1, bark, lean=(.5, .25), seed=41)
    for i, p in enumerate(pts[1:], 1):
        geo.cyl((p[0], p[1], p[2] - .03), .17 - i * .012, .05, mats.flat('ring', '#5a3a26', rough=1.0, bevel_wear=0), sides=10)
    top = Vector(pts[-1])
    leaf = M('palm')
    for k in range(9):
        a = k * 0.7 + rr.uniform(-.15, .15)
        droop = rr.uniform(.5, 1.0)
        L = rr.uniform(1.2, 1.6)
        prev = top
        for s in range(1, 6):
            t = s / 5
            p = Vector((top.x + math.cos(a) * L * t, top.y + math.sin(a) * L * t, top.z + math.sin(t * math.pi * .55) * .55 - t * t * droop))
            geo.cyl_between(tuple(prev), tuple(p), .04 * (1 - t * .8), M('bark_tree'), sides=4, r2=.03 * (1 - (t + .2) * .8))
            # folha larga: elipsoide achatado alinhado ao arco (sobreposição forma a fronde)
            mid = (prev + p) / 2
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0)
            o = bpy.context.object
            seg = (p - prev).length
            o.scale = (seg * .78, .27 * (1 - t * .55), .028)
            o.location = mid
            d = (p - prev).normalized()
            o.rotation_euler = (0, -math.asin(max(-1, min(1, d.z))), math.atan2(d.y, d.x))
            o.data.materials.append(leaf)
            prev = p
    for k in range(3):
        bpy.ops.mesh.primitive_uv_sphere_add(radius=.1, location=(top.x + math.cos(k * 2.1) * .15, top.y + math.sin(k * 2.1) * .15, top.z - .1))
        bpy.context.object.data.materials.append(mats.flat('coco', '#5a3a1c', rough=.7, bevel_wear=0))
    parts.grass_tufts(0, 0, .9, 6, M('leaf_dry'), seed=3, h=.2)
    parts.rubble(0, 0, .6, 3, M('rock_sand'), seed=6, rmin=.06, rmax=.12)


# ------------------------------------------------------------------ cactos
def ribbed_stem(base, top, r, mat, ribs=8):
    for k in range(ribs):
        a = 2 * math.pi * k / ribs
        geo.cyl_between((base[0] + math.cos(a) * r * .8, base[1] + math.sin(a) * r * .8, base[2]), (top[0] + math.cos(a) * r * .55, top[1] + math.sin(a) * r * .55, top[2]), r * .32, mat, sides=6, r2=r * .18)
    geo.cyl_between(base, top, r * .9, mat, sides=ribs, r2=r * .7)


@legacy('nat_cactus_tall')
def cactus_tall(f):
    mc = M('cactus')
    ribbed_stem((0, 0, 0), (0, 0, 1.9), .2, mc)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=.19, location=(0, 0, 1.92))
    bpy.context.object.data.materials.append(mc)
    for sgn, z, ln in ((1, .95, .6), (-1, 1.25, .5)):
        a = (0, sgn * .55, z)
        b = (0, sgn * (.55 + .25), z + ln * .7)
        geo.cyl_between((0, 0, z), a, .11, mc, sides=8)
        ribbed_stem(a, b, .1, mc, ribs=6)
    for i in range(3):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.05, location=(math.cos(i * 2.1) * .09, math.sin(i * 2.1) * .09, 2.05))
        bpy.context.object.data.materials.append(mats.flat('cflower', '#ff7aa8', rough=.7, bevel_wear=0))
    parts.rubble(0, 0, .5, 5, M('rock_sand'), seed=4, rmin=.06, rmax=.14)
    parts.grass_tufts(0, 0, .7, 4, M('leaf_dry'), seed=2, h=.18)


@legacy('nat_cactus_round')
def cactus_round(f):
    mc = M('cactus')
    for i, (x, y, r) in enumerate(((0, 0, .34), (.4, .2, .22), (-.32, .22, .18))):
        bpy.ops.mesh.primitive_uv_sphere_add(radius=r, location=(x, y, r * .85), segments=16, ring_count=10)
        o = bpy.context.object
        o.scale = (1, 1, .85)
        o.data.materials.append(mc)
        for p in o.data.polygons:
            p.use_smooth = True
        for k in range(8):
            a = k * .785
            geo.cyl_between((x + math.cos(a) * r * .85, y + math.sin(a) * r * .85, r * .25), (x + math.cos(a) * r * .55, y + math.sin(a) * r * .55, r * 1.55), r * .12, mats.flat('rib', '#2f8a4e', rough=.9, bevel_wear=0), sides=4, r2=r * .02)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.07, location=(0, 0, .72))
    bpy.context.object.data.materials.append(mats.flat('cflower', '#ff7aa8', rough=.7, bevel_wear=0))
    parts.rubble(0, 0, .55, 4, M('rock_sand'), seed=5, rmin=.05, rmax=.12)


# ------------------------------------------------------------------ arbustos
def bush(seed, leaf, n_clumps=6, radius=.55, berries=None, flowers=None, snow=False, height=.5):
    rr = random.Random(seed)
    for i in range(n_clumps):
        a = rr.uniform(0, 6.28)
        d = rr.uniform(0, radius * .8)
        parts.leaf_cluster(math.cos(a) * d, math.sin(a) * d, height * (.5 + rr.random() * .5), radius * .55, 20, leaf, seed + i * 5, size=(.1, .16), flat=.6)
    parts.leaf_cluster(0, 0, height * .6, radius * .9, 14, leaf, seed + 77, size=(.12, .18), flat=.6)
    if berries:
        bm = mats.flat('berry', berries, rough=.4, spec=.5, bevel_wear=0)
        for i in range(14):
            a = rr.uniform(0, 6.28)
            d = rr.uniform(.2, radius)
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.045, location=(math.cos(a) * d, math.sin(a) * d, height * rr.uniform(.4, 1.1)))
            bpy.context.object.data.materials.append(bm)
    if flowers:
        fm = [mats.flat('bf%d' % k, c, rough=.7, bevel_wear=0) for k, c in enumerate(flowers)]
        for i in range(16):
            a = rr.uniform(0, 6.28)
            d = rr.uniform(.1, radius)
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.055, location=(math.cos(a) * d, math.sin(a) * d, height * rr.uniform(.6, 1.15)))
            bpy.context.object.data.materials.append(rr.choice(fm))
    if snow:
        for i in range(5):
            a = rr.uniform(0, 6.28)
            d = rr.uniform(0, radius * .6)
            parts.leaf_cluster(math.cos(a) * d, math.sin(a) * d, height * 1.0, radius * .35, 8, M('snow_ground'), seed + 200 + i, size=(.1, .15), flat=.45)
    parts.grass_tufts(0, 0, radius * 1.1, 5, M('grass') if not snow else M('needle_snow'), seed=seed + 9, h=.16)


legacy('nat_bush_green')(lambda f: bush(51, M('leaf')))
legacy('nat_bush_berry')(lambda f: bush(52, M('leaf'), berries='#d02040'))
legacy('nat_bush_flowering')(lambda f: bush(53, M('leaf'), flowers=('#ff7aa8', '#f6f0d8', '#ffd23a')))
legacy('nat_bush_frost')(lambda f: bush(54, M('needle_snow'), snow=True))
legacy('nat_bush_dry')(lambda f: bush(55, M('leaf_dry'), n_clumps=5, radius=.5))


# ------------------------------------------------------------------ pedras
def rock_pile(seed, mat, r, n=1, moss=False, snow=False, squash=.7, grass=True, spread=.5, crystals=None):
    rr = random.Random(seed)
    parts.rock_mass((0, 0, 0), (r * 2.0, r * 1.8, r * 1.5 * squash * 1.3), mat, seed, subdiv=4, rough=.32, freq=1.3, terrace=.3, step=.3, taper=.25, flat_top=False, squash_base=.02)
    for i in range(n - 1):
        a = rr.uniform(0, 6.28)
        d = r * rr.uniform(.8, 1.3) * (1 + spread)
        parts.rock_mass((math.cos(a) * d, math.sin(a) * d, 0), (r * rr.uniform(.6, 1.0), r * rr.uniform(.6, .9), r * rr.uniform(.5, .9) * squash), mat, seed + i + 1, subdiv=3, rough=.3, taper=.25)
    if grass:
        parts.grass_tufts(0, 0, r * 1.5, int(4 + r * 3), M('grass') if not snow else M('needle_snow'), seed=seed + 4, h=.18)
    if crystals:
        for i in range(4):
            a = i * 1.6
            geo.cyl_between((math.cos(a) * r * .5, math.sin(a) * r * .5, r * .6), (math.cos(a) * r * .8, math.sin(a) * r * .8, r * 1.2 + i * .1), .08, crystals, sides=5, r2=.01)


legacy('nat_rock_boulder')(lambda f: rock_pile(61, M('rock_grey'), 1.05, 2))
legacy('nat_rock_medium')(lambda f: rock_pile(62, M('rock_grey'), .65, 2))
legacy('nat_rock_small')(lambda f: rock_pile(63, M('rock_grey'), .38, 3, grass=False))
legacy('nat_rock_mossy')(lambda f: rock_pile(64, M('rock_grey'), .7, 2))
legacy('nat_rock_snow')(lambda f: rock_pile(65, M('rock_snow'), .7, 2, snow=True))
legacy('nat_rock_ice')(lambda f: rock_pile(66, M('rock_ice'), .7, 2, snow=True, crystals=M('glass_ice')))
legacy('nat_rock_sand')(lambda f: rock_pile(67, M('rock_sand'), .7, 2, grass=False))
legacy('nat_boulder_ice')(lambda f: rock_pile(68, M('rock_ice'), 1.0, 2, snow=True))
legacy('nat_boulder_sand')(lambda f: rock_pile(69, M('rock_sand'), 1.0, 2, grass=False))


@legacy('nat_ice_spire')
def ice_spire(f):
    rr = random.Random(71)
    ic = M('glass_ice')
    for i, (x, y, h, r) in enumerate(((0, 0, 2.1, .28), (.35, .12, 1.3, .2), (-.32, .2, 1.0, .18), (.1, -.35, .8, .16))):
        geo.cyl((x, y, 0), r, h, ic, sides=6, r2=.015)
        geo.cyl((x, y, 0), r * 1.05, h * .3, M('rock_ice'), sides=6, r2=r * .6)
    parts.rubble(0, 0, .55, 6, M('rock_ice'), seed=8, rmin=.08, rmax=.2)
    for i in range(5):
        a = rr.uniform(0, 6.28)
        parts.leaf_cluster(math.cos(a) * .5, math.sin(a) * .5, .1, .2, 5, M('snow_ground'), 80 + i, size=(.1, .16), flat=.4)


# ------------------------------------------------------------------ dunas orientadas pelo vento e neve
def barchan(length, height, width, seed=0, ripples=True, mat=None, res=120):
    """Duna crescente: barlavento suave, crista afiada e sotavento íngreme; cornos alongados a favor do vento."""
    mat = mat or M('sand_ground')
    verts, faces = [], []
    span_x, span_y = length * 1.5, width * 1.6
    for i in range(res + 1):
        for j in range(res + 1):
            x = (i / res - .5) * span_x
            y = (j / res - .5) * span_y
            t = x - 0.55 * (y * y) / max(width, .1) * .9
            up = max(0.0, min(1.0, (t + length * .8) / (length * .8))) ** 1.35
            down = max(0.0, min(1.0, 1.0 - max(t, 0.0) / (length * .22)))
            lat = math.exp(-((y / (width * .55)) ** 2))
            h = height * up * down * lat
            if ripples and h > .02:
                across = -x * .38 + y * .92
                h += .035 * math.sin(across * 9.0 + math.sin(x * 2.0) * .8) * min(1, h / (height * .3))
            verts.append((x, y, max(0.0, h)))
    for i in range(res):
        for j in range(res):
            a = i * (res + 1) + j
            if max(verts[a][2], verts[a + res + 1][2], verts[a + res + 2][2], verts[a + 1][2]) < .02:
                continue
            faces.append((a, a + res + 1, a + res + 2, a + 1))
    o = geo.mesh_from(verts, faces, mat, 'dune', smooth=True)
    return o


def dune_mound(L, W, H, seed=0, mat=None, ripples=True):
    """Duna/monte: hemisfério deformado — barlavento longo e suave, sotavento curto e íngreme, ondulações a favor do vento."""
    mat = mat or M('sand_ground')
    bpy.ops.mesh.primitive_uv_sphere_add(segments=72, ring_count=40, radius=1.0)
    o = bpy.context.object
    from mathutils import noise
    for v in o.data.vertices:
        p = v.co
        z = max(p.z, 0.0)
        x = p.x * L
        y = p.y * W
        x = x * (1.0 - .5 * max(0.0, p.x)) if p.x > 0 else x * 1.15
        h = z * H * (1.0 + .18 * max(0.0, -p.x))
        if ripples:
            rip = math.sin((x * -.4 + y * .9) * 10.0 + noise.noise(Vector((x * 1.4, y * 1.4, seed))) * 2.2) * .06 * min(1.0, z * 3)
            h += rip
        v.co = Vector((x, y * (1 - .25 * z), h))
    for pp in o.data.polygons:
        pp.use_smooth = True
    o.data.materials.append(mat)
    return o


@legacy('nat_dune_large')
def dune_large(f):
    dune_mound(1.9, 1.5, 1.05, 1)
    small = dune_mound(1.1, .8, .55, 2)
    small.location = (-1.1, 1.0, 0)
    parts.rubble(-.3, .5, 1.5, 4, M('rock_sand'), seed=3, rmin=.07, rmax=.16, ring=False)
    parts.grass_tufts(-1.6, -1.0, .8, 4, M('leaf_dry'), seed=4, h=.26)


@legacy('nat_dune_small')
def dune_small(f):
    dune_mound(1.3, 1.0, .6, 3)
    parts.rubble(-.2, .5, .9, 3, M('rock_sand'), seed=5, rmin=.06, rmax=.12, ring=False)


@legacy('nat_snow_mound')
def snow_mound(f):
    dune_mound(1.2, 1.0, .55, 4, mat=M('snow_ground'), ripples=False)
    for i in range(3):
        parts.boulder((.4 * i - .5, .3 * (i - 1), .05), .16, M('rock_snow'), 60 + i, squash=.6, detail=1)


# ------------------------------------------------------------------ tendas
def tent(mat_main, mat_trim, w=1.5, l=1.9, h=1.3, door=True, fur=False, seed=0):
    mwd = M('wood_dark')
    hw = w / 2
    # cumeeira e duas águas com caimento e dobras
    geo.beam((-l / 2, 0, h), (l / 2, 0, h), .09, .09, mwd, bevel=0.01)
    for sx in (-1, 1):
        geo.beam((sx * l / 2, 0, h + .05), (sx * l / 2, 0, 0), .07, .07, mwd, bevel=0.01)
    parts.cloth_sheet((-l / 2 - .1, -hw - .08, .05), (l / 2 + .1, -hw - .08, .05), (-l / 2, 0, h), (l / 2, 0, h), mat_main, nu=12, nv=8, sag=.06, folds=.05, fold_n=5, thickness=.03, name='tent_a')
    parts.cloth_sheet((-l / 2 - .1, hw + .08, .05), (l / 2 + .1, hw + .08, .05), (-l / 2, 0, h), (l / 2, 0, h), mat_main, nu=12, nv=8, sag=.06, folds=.05, fold_n=5, thickness=.03, name='tent_b', phase=1.4)
    # bandas decorativas e aba da entrada com fresta escura
    for sx in (-1, 1):
        geo.mesh_from([(sx * (l / 2 + .1), -hw - .08, .05), (sx * (l / 2 + .1), hw + .08, .05), (sx * (l / 2), 0, h)], [(0, 1, 2)], mat_main, 'gable').modifiers.new('sol', 'SOLIDIFY').thickness = .03
    if door:
        geo.box((l / 2 + .12, 0, .38), (.04, .4, .6), mats.flat('doorflap', '#241814', rough=1.0, bevel_wear=0), bevel=0)
    for sy in (-1, 1):
        for sx in (-1, 1):
            geo.cyl_between((sx * (l / 2 + .1), sy * (hw + .1), .05), (sx * (l / 2 + .5), sy * (hw + .6), .0), .012, M('rope'), sides=4)
            geo.cyl((sx * (l / 2 + .5), sy * (hw + .6), 0), .03, .13, mwd, sides=5)


@legacy('nat_tent_red')
def tent_red(f):
    tent(M('stripe_amber'), M('cloth_red'), seed=1)
    geo.cyl((.9, -.9, 0), .3, .5, M('wood_old'), sides=12, r2=.27)
    geo.box((1.1, .8, .2), (.5, .4, .4), M('wood_old'), rot=(0, 0, 25), bevel=0.03)
    parts.rubble(0, 0, 1.6, 6, M('rock_sand'), seed=2)


@legacy('nat_tent_frost')
def tent_frost(f):
    tent(mats.striped_cloth('stripe_frost', '#3a5aa8', '#e8f0fa', freq=2.6), M('cloth_blue'), fur=True, seed=2)
    for i in range(4):
        parts.boulder((math.cos(i * 1.6) * 1.6, math.sin(i * 1.6) * 1.3, 0), .3, M('snow_ground'), 90 + i, squash=.5, detail=1)
    parts.cloth_sheet((-.8, -.9, 1.2), (.8, -.9, 1.2), (-.7, -.05, 1.34), (.7, -.05, 1.34), M('snow_ground'), nu=8, nv=3, sag=0, folds=.04, thickness=.08, name='snowtop')


@legacy('nat_tent_small')
def tent_small(f):
    tent(M('cloth_cream'), M('cloth_green'), w=1.3, l=1.6, h=1.05, seed=3)
    geo.box((.9, .7, .15), (.4, .3, .3), M('wood_old'), rot=(0, 0, 20), bevel=0.03)
    parts.grass_tufts(0, 0, 1.6, 8, M('grass'), seed=5)


# ------------------------------------------------------------------ poço, carroça, fogueira, placas, troncos, feno, cercas
@legacy('nat_well_stone')
def well(f):
    ms, mwd = M('stone'), M('wood_dark')
    geo.cyl((0, 0, 0), .95, .75, ms, sides=14, r2=.9, bevel=0.03)
    geo.cyl((0, 0, .7), .82, .12, ms, sides=14, bevel=0.02)
    geo.cyl((0, 0, .72), .66, .02, M('hole'), sides=14)
    for sy in (-.85, .85):
        geo.box((0, sy, 1.35), (.14, .14, 1.3), mwd, bevel=0.02)
    geo.cyl_between((0, -.85, 2.0), (0, .85, 2.0), .07, mwd, sides=6)
    for sy in (-1, 1):
        geo.beam((0, sy * .85, 1.95), (0, sy * .35, 2.5), .09, .08, mwd, bevel=0.01)
    geo.beam((0, -.4, 2.5), (0, .4, 2.5), .1, .1, mwd, bevel=0.01)
    geo.roof_gable(0, 0, 2.42, .5, 1.5, .5, M('roof_red'), overhang=.15, ridge_axis='y', thickness=.08)
    geo.cyl_between((0, 0, 1.95), (0, 0, 1.15), .012, M('rope'), sides=4)
    geo.cyl((0, 0, .9), .12, .16, M('wood'), sides=10, r2=.1)
    parts.grass_tufts(0, 0, 1.3, 8, M('grass'), seed=3)
    parts.rubble(0, 0, 1.1, 5, M('rock'), seed=4)


@legacy('nat_cart_wood')
def cart(f):
    mw, mwd, mo = M('wood'), M('wood_dark'), M('wood_old')
    geo.box((0, 0, .7), (1.7, 1.0, .12), mw, bevel=0.02)
    for sy in (-.5, .5):
        geo.box((0, sy, .95), (1.7, .07, .45), mo, bevel=0.02)
    for sx in (-.85, .85):
        geo.box((sx, 0, .95), (.07, 1.0, .45), mo, bevel=0.02)
    for sy in (-.62, .62):
        for k in range(8):
            a = k * math.pi / 4
            geo.cyl_between((0, sy, .45), (math.cos(a) * .42, sy, .45 + math.sin(a) * .42), .025, mwd, sides=4)
        bpy.ops.mesh.primitive_torus_add(major_radius=.42, minor_radius=.05, location=(0, sy, .45), rotation=(math.pi / 2, 0, 0))
        bpy.context.object.data.materials.append(mwd)
        geo.cyl((0, sy, .45), .07, .1, M('iron'), sides=8, rot=(90, 0, 0))
    geo.beam((.85, 0, .8), (1.9, .2, .55), .1, .08, mwd, bevel=0.01)
    geo.beam((.85, -.35, .8), (1.9, -.15, .55), .1, .08, mwd, bevel=0.01)
    for i, (x, y, z) in enumerate(((-.3, 0, 1.0), (.3, .1, 1.0), (0, -.2, 1.0))):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=.32)
        o = bpy.context.object
        o.scale = (1.1, 1.0, .6)
        o.location = (x, y, z + .1)
        o.data.materials.append(M('hay'))
    parts.grass_tufts(0, 0, 1.2, 6, M('grass'), seed=2)


@legacy('nat_campfire')
def campfire(f):
    ph = f / 4
    for k in range(9):
        a = k * .7
        parts.boulder((math.cos(a) * .55, math.sin(a) * .55, 0), .16, M('rock'), 30 + k, squash=.7, detail=1)
    for k in range(4):
        a = k * 1.57 + .4
        geo.cyl_between((math.cos(a) * .4, math.sin(a) * .4, .1), (0, 0, .28), .07, M('bark_log'), sides=6)
    fm = mats.emissive('flame%d' % f, '#ff9a30', 12.0)
    fm2 = mats.emissive('flame2%d' % f, '#ffe070', 14.0)
    for i, (x, y, h) in enumerate(((0, 0, .7), (.12, .06, .5), (-.1, .08, .45), (.02, -.12, .4))):
        sway = math.sin((ph + i * .25) * 6.283) * .05
        geo.cyl_between((x, y, .2), (x + sway, y + sway * .5, .2 + h * (1 + .12 * math.sin((ph + i * .3) * 6.283))), .11 - i * .012, fm, sides=6, r2=.005)
    geo.cyl_between((0, 0, .22), (0, 0, .5), .06, fm2, sides=6, r2=.005)
    for i in range(3):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.02)
        o = bpy.context.object
        o.location = (math.cos(i * 2 + ph * 6) * .15, math.sin(i * 2 + ph * 6) * .15, .5 + ((ph + i / 3) % 1.0) * .8)
        o.data.materials.append(fm2)
    parts.grass_tufts(0, 0, .9, 5, M('leaf_dry'), seed=3, h=.16)


@legacy('nat_signpost')
def signpost(f):
    mwd, mw = M('wood_dark'), M('wood')
    geo.box((0, 0, .95), (.16, .16, 1.9), mwd, bevel=0.02)
    for z, ang, ln in ((1.5, 20, .95), (1.12, -14, .8)):
        geo.box((.02, 0, z), (.06, ln, .26), mw, rot=(0, 0, 0), bevel=0.02)
    for i in range(3):
        geo.box((.06, -.32 + i * .32, 1.5), (.04, .16, .02), M('iron'), bevel=0)
    geo.cyl((0, 0, 0), .16, .1, mwd, sides=6)
    parts.grass_tufts(0, 0, .5, 4, M('grass'), seed=2)
    parts.rubble(0, 0, .4, 3, M('rock'), seed=3, rmin=.06, rmax=.12)


@legacy('nat_stump')
def stump(f):
    bark = M('bark_tree')
    geo.cyl((0, 0, 0), .42, .5, bark, sides=14, r2=.36)
    geo.cyl((0, 0, .5), .36, .03, mats.planks('rings', ('#8a5a30', '#b88448', '#dcae6c', '#f0d094'), along='x', width=.06, length=1.0), sides=14)
    for k in range(4):
        a = k * 1.6
        geo.cyl_between((math.cos(a) * .4, math.sin(a) * .4, 0), (math.cos(a) * .7, math.sin(a) * .7, .05), .07, bark, sides=5, r2=.02)
    parts.grass_tufts(0, 0, .7, 6, M('grass'), seed=4, h=.2)
    parts.flowers(0, 0, .7, 3, seed=5)


@legacy('nat_log_fallen')
def log_fallen(f):
    bark = M('bark_tree')
    geo.cyl_between((-1.4, 0, .34), (1.4, .1, .32), .34, bark, sides=12, r2=.3)
    for k in range(3):
        geo.cyl_between((-.6 + k * .6, 0, .5), (-.4 + k * .6, -.3 + k * .1, .9), .05, bark, sides=5, r2=.02)
    geo.cyl((1.4, .1, .32), .3, .02, mats.planks('lrings', ('#8a5a30', '#b88448', '#dcae6c', '#f0d094'), along='x', width=.06, length=1.0), sides=12, rot=(0, 90, 0))
    parts.leaf_cluster(-.3, .1, .62, .32, 10, M('leaf'), 5, size=(.08, .13), flat=.5)
    parts.grass_tufts(0, 0, 1.4, 8, M('grass'), seed=6, h=.22)
    parts.flowers(0, 0, 1.2, 4, seed=7)


@legacy('nat_log_pile')
def log_pile(f):
    bark = M('bark_tree')
    for row in range(3):
        for i in range(3 - row):
            geo.cyl_between((-.55 + i * .4 + row * .2, -.7, .17 + row * .3), (-.55 + i * .4 + row * .2, .7, .17 + row * .3), .17, bark, sides=10)
    parts.grass_tufts(0, 0, 1.0, 5, M('grass'), seed=2, h=.2)


@legacy('nat_hay_bale')
def hay_bale(f):
    hm = M('hay')
    geo.box((0, 0, .32), (.9, .6, .6), hm, rot=(0, 0, 10), bevel=0.07)
    for k in range(9):
        geo.cyl_between((-.4 + k * .1, -.3, .62), (-.35 + k * .1, -.5, .5), .012, hm, sides=3, r2=.003)
    parts.grass_tufts(0, 0, .7, 4, M('grass'), seed=2, h=.2)


@legacy('nat_hay_stack')
def hay_stack(f):
    hm = M('hay')
    geo.cyl((0, 0, 0), .75, 1.1, hm, sides=14, r2=.6)
    geo.cyl((0, 0, 1.05), .6, .7, hm, sides=14, r2=.02)
    for k in range(10):
        a = k * .63
        geo.cyl_between((math.cos(a) * .6, math.sin(a) * .6, .5 + (k % 3) * .3), (math.cos(a) * .78, math.sin(a) * .78, .3 + (k % 3) * .3), .012, hm, sides=3, r2=.003)
    parts.grass_tufts(0, 0, 1.0, 5, M('grass'), seed=3, h=.2)


def fence(axis, broken=False, seed=0):
    mw, mwd = M('wood'), M('wood_dark')
    rr = random.Random(seed)
    L = 1.5
    for k in (-1, 1):
        x, y = (k * L / 2, 0) if axis == 'a' else (0, k * L / 2)
        h = .95 - (.35 if (broken and k == 1) else 0)
        geo.cyl((x, y, 0), .07, h, mwd, sides=7, r2=.06)
        geo.cyl((x, y, h), .075, .03, M('wood_y'), sides=7)
    for z in (.4, .72):
        if broken and z > .5:
            geo.beam((-L / 2, 0, z), (0, .04, z - .12), .1, .06, mw, bevel=0.01) if axis == 'a' else geo.beam((0, -L / 2, z), (.04, 0, z - .12), .1, .06, mw, bevel=0.01)
        else:
            a = (-L / 2, 0, z + rr.uniform(-.02, .02)) if axis == 'a' else (0, -L / 2, z + rr.uniform(-.02, .02))
            b = (L / 2, 0, z + rr.uniform(-.02, .02)) if axis == 'a' else (0, L / 2, z + rr.uniform(-.02, .02))
            geo.beam(a, b, .11, .06, mw, bevel=0.01)
    parts.grass_tufts(0, 0, .9, 5, M('grass'), seed=seed + 2, h=.24)


legacy('nat_fence_wood_a')(lambda f: fence('a', False, 1))
legacy('nat_fence_wood_b')(lambda f: fence('b', False, 2))
legacy('nat_fence_broken_a')(lambda f: fence('a', True, 3))
legacy('nat_fence_broken_b')(lambda f: fence('b', True, 4))
