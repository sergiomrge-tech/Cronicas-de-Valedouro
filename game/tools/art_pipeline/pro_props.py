"""Props de cenário remodelados (classe C do review): baús, ruínas, altares, estátua, obelisco, bandeiras, lampiões, barris/caixas, portão, muro baixo."""
import math
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import bpy
from vk import geo, mats, parts
from vk.parts import M
from pro_nature import legacy


# ------------------------------------------------------------------ baús
def chest(kind):
    if kind == 'rare':
        body = mats.planks('chest_rare', ('#1c0c3a', '#3c1a72', '#6a34b8', '#a878f0'), along='x', width=.2, length=1.2, aged=.3)
        trim = M('gold')
    else:
        body = M('wood')
        trim = M('iron')
    w, d, h = 1.0, .62, .48
    geo.box((0, 0, h / 2 + .04), (w, d, h), body, bevel=0.04)
    geo.box((0, 0, .04), (w + .06, d + .06, .1), trim, bevel=0.02)
    for sx in (-.38, 0.0, .38):
        geo.box((sx, 0, h / 2 + .04), (.09, d + .04, h + .02), trim, bevel=0.015)
    # tampa em arco
    lid_open = kind == 'open'
    bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=d / 2 + .015, depth=w + .05, rotation=(0, math.pi / 2, 0), end_fill_type='TRIFAN')
    lid = bpy.context.object
    lid.scale = (1, 1, 1)
    lid.data.materials.append(body)
    if not lid_open:
        lid.location = (0, 0, h + .04)
        bpy.context.view_layer.update()
        bpy.context.view_layer.objects.active = lid
        lid.select_set(True)
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        lid.select_set(False)
        for sx in (-.38, 0.0, .38):
            bpy.ops.mesh.primitive_torus_add(major_radius=d / 2 + .01, minor_radius=.025, location=(sx, 0, h + .04), rotation=(0, math.pi / 2, 0))
            bpy.context.object.data.materials.append(trim)
        geo.box((0, d / 2 + .02, h + .0), (.14, .05, .16), M('gold'), bevel=0.01)
    else:
        # tampa aberta: casca em caixa espessa articulada na dobradiça traseira (ângulo ~105°)
        bpy.data.objects.remove(lid, do_unlink=True)
        th = math.radians(-105)
        hy, hz = -d / 2, h + .04
        off_y, off_z = d / 2, .06
        cy = hy + math.cos(th) * off_y - math.sin(th) * off_z
        cz = hz + math.sin(th) * off_y + math.cos(th) * off_z
        bpy.ops.mesh.primitive_cube_add(size=1)
        lid2 = bpy.context.object
        lid2.scale = (w + .04, d + .03, .12)
        lid2.rotation_euler = (th, 0, 0)
        lid2.location = (0, cy, cz)
        lid2.data.materials.append(body)
        bpy.context.view_layer.update()
        bpy.context.view_layer.objects.active = lid2
        lid2.select_set(True)
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        lid2.select_set(False)
        bev = lid2.modifiers.new('b', 'BEVEL')
        bev.width = .03
        # interior com tesouro
        geo.box((0, 0, h + .02), (w - .1, d - .1, .04), M('hole'), bevel=0)
        for i in range(10):
            bpy.ops.mesh.primitive_uv_sphere_add(radius=.06, segments=8, ring_count=6, location=(-.35 + i * .08, (i % 3 - 1) * .1, h + .08 + (i % 2) * .03))
            bpy.context.object.scale = (1, 1, .5)
            bpy.context.object.data.materials.append(M('gold'))
        for i in range(3):
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.06, location=(-.15 + i * .15, .05, h + .14))
            bpy.context.object.data.materials.append(mats.flat('gem%d' % i, ('#ff4a6a', '#4ab8ff', '#7aff9a')[i], rough=.15, spec=.9, emission=('#ff4a6a', '#4ab8ff', '#7aff9a')[i], emission_strength=.6, bevel_wear=0))
        for k in range(6):
            geo.cyl_between((-.3 + k * .12, 0, h + .1), (-.3 + k * .12, 0, h + .55 + (k % 2) * .2), .012, mats.emissive('spark', '#ffe89a', 8.0), sides=4, r2=.003)
    if kind == 'rare':
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=.09, location=(0, d / 2 + .05, h + .02))
        bpy.context.object.data.materials.append(mats.flat('rgem', '#7ad8ff', rough=.1, spec=.9, emission='#4ab8ff', emission_strength=1.2, bevel_wear=0))
    parts.grass_tufts(0, 0, .9, 4, M('grass'), seed=3, h=.16)


legacy('nat_chest_closed')(lambda f: chest('closed'))
legacy('nat_chest_open')(lambda f: chest('open'))
legacy('nat_chest_rare')(lambda f: chest('rare'))


# ------------------------------------------------------------------ ruínas
def ruin_column(mat, h=2.6, broken=False, seed=0, moss=True):
    rr = random.Random(seed)
    geo.box((0, 0, .18), (.9, .9, .36), mat, bevel=0.05)
    geo.box((0, 0, .45), (.7, .7, .2), mat, bevel=0.04)
    n = 6 if not broken else 3
    for i in range(n):
        z = .55 + i * (h - .7) / 6
        geo.cyl((rr.uniform(-.015, .015), rr.uniform(-.015, .015), z), .28 - i * .008, (h - .7) / 6 + .01, mat, sides=10, bevel=0.01)
        geo.cyl((0, 0, z), .3 - i * .008, .04, mat, sides=10)
    if not broken:
        geo.box((0, 0, h + .05), (.72, .72, .16), mat, bevel=0.04)
        geo.box((0, 0, h + .18), (.56, .56, .12), mat, bevel=0.04)
    else:
        parts.boulder((.5, .3, 0), .3, mat, seed + 1, squash=.7)
        geo.cyl((.7, -.3, .0), .27, .5, mat, sides=10, rot=(0, 80, 20))
    if moss:
        parts.ivy(.3, .3, .3, -.3, .5, 2.0 if not broken else 1.2, M('leaf'), seed=seed, n=8)
    parts.rubble(0, 0, .8, 6, mat, seed=seed + 2, rmin=.08, rmax=.2)


legacy('nat_ruin_column')(lambda f: ruin_column(M('stone'), 2.6, False, 1))
legacy('nat_ruin_column_broken')(lambda f: ruin_column(M('stone'), 2.0, True, 2))
legacy('nat_ruin_column_sand')(lambda f: ruin_column(M('stone_sand'), 2.8, False, 3, moss=False))


def ruin_arch(mat, seed=0, moss=True):
    for sgn in (-1, 1):
        geo.box((sgn * 1.15, 0, .2), (.9, .9, .4), mat, bevel=0.05)
        for i in range(7):
            geo.box((sgn * 1.15 + math.sin(i) * .01, 0, .55 + i * .34), (.62, .62, .36), mat, bevel=0.04)
        geo.box((sgn * 1.15, 0, 3.0), (.78, .78, .2), mat, bevel=0.04)
    # arco por aduelas (lado esquerdo completo, direito quebrado)
    n = 9
    for k in range(n):
        if k > 6:
            continue
        a = math.pi * (k + .5) / n
        x = -math.cos(a) * 1.15
        z = 3.1 + math.sin(a) * .9
        geo.box((x, 0, z), (.42, .6, .36), mat, rot=(0, 0, 0), bevel=0.04)
    parts.rubble(0, 0, 1.6, 12, mat, seed=seed + 3, rmin=.1, rmax=.3)
    parts.boulder((1.0, .6, 0), .4, mat, seed + 4, squash=.8)
    if moss:
        parts.ivy(-1.15, .3, -1.15, -.3, .5, 2.8, M('leaf'), seed=seed, n=16)
    parts.grass_tufts(0, 0, 1.5, 10, M('grass') if moss else M('leaf_dry'), seed=seed + 5)


legacy('nat_ruin_arch')(lambda f: ruin_arch(M('stone'), 1))
legacy('nat_ruin_arch_sand')(lambda f: ruin_arch(M('stone_sand'), 2, moss=False))


def ruin_wall(mat, seed=0, moss=True):
    rr = random.Random(seed)
    for i in range(6):
        h = 1.6 - i * .22 + rr.uniform(-.1, .1)
        geo.box((-1.2 + i * .48, 0, h / 2), (.5, .55, h), mat, bevel=0.04)
    parts.rubble(0, 0, 1.4, 9, mat, seed=seed + 1, rmin=.08, rmax=.26)
    if moss:
        parts.leaf_cluster(-.8, 0, 1.5, .3, 12, M('leaf'), seed + 3, size=(.08, .13), flat=.5)
        parts.grass_tufts(0, 0, 1.3, 8, M('grass'), seed=seed + 4)


legacy('nat_ruin_wall')(lambda f: ruin_wall(M('stone'), 1))
legacy('nat_ruin_wall_sand')(lambda f: ruin_wall(M('stone_sand'), 2, moss=False))


# ------------------------------------------------------------------ altares (2 quadros de brilho), obelisco, estátua
def altar(mat, glow_col, f, moss):
    pulse = .5 + .5 * math.sin(f * 3.14159)
    geo.box((0, 0, .12), (1.7, 1.7, .24), mat, bevel=0.05)
    geo.box((0, 0, .38), (1.3, 1.3, .28), mat, bevel=0.05)
    geo.box((0, 0, .95), (.9, .9, .9), mat, bevel=0.06)
    geo.box((0, 0, 1.45), (1.1, 1.1, .14), mat, bevel=0.04)
    gm = mats.flat('altar_glow%d' % f, glow_col, rough=.2, spec=.8, emission=glow_col, emission_strength=1.6 + 3.0 * pulse, bevel_wear=0)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=.26, location=(0, 0, 1.8))
    bpy.context.object.data.materials.append(gm)
    for k in range(4):
        a = k * 1.57 + .8
        geo.box((math.cos(a) * .47, math.sin(a) * .47, .95), (.05, .02, .35), M('rune'), rot=(0, 0, math.degrees(a) + 90), bevel=0)
    parts.rubble(0, 0, 1.2, 8, mat, seed=5, rmin=.08, rmax=.2)
    if moss:
        parts.ivy(.6, .6, .6, -.6, .3, 1.3, M('leaf'), seed=3, n=10)
        parts.grass_tufts(0, 0, 1.3, 8, M('grass'), seed=4)


legacy('nat_altar_ancient')(lambda f: altar(M('stone'), '#7ad8ff', f, True))
legacy('nat_altar_sand')(lambda f: altar(M('stone_sand'), '#ffd060', f, False))


@legacy('nat_obelisk_rune')
def obelisk(f):
    pulse = .5 + .5 * math.sin(f * 3.14159)
    ms = M('stone_dark')
    geo.box((0, 0, .15), (1.0, 1.0, .3), ms, bevel=0.05)
    geo.box((0, 0, .4), (.8, .8, .2), ms, bevel=0.04)
    parts.tapered_shaft(0, 0, .5, 3.4, .62, .3, ms, seed=4)
    parts.geo.roof_pyramid(0, 0, 3.4, .21, .35, ms, sides=4, rot=45, thickness=.1)
    rm = mats.emissive('obrune%d' % f, '#a878ff', 3.0 + 6.0 * pulse)
    for z in (1.0, 1.5, 2.0, 2.5):
        geo.box((.33 - z * .03, .0, z), (.03, .16, .18), rm, bevel=0)
        geo.box((0, .33 - z * .03, z), (.16, .03, .18), rm, bevel=0)
    parts.rubble(0, 0, .8, 5, ms, seed=5)


@legacy('nat_statue_guardian')
def statue(f):
    ms = M('stone')
    geo.box((0, 0, .2), (1.0, 1.0, .4), ms, bevel=0.05)
    geo.box((0, 0, .6), (.72, .72, .4), ms, bevel=0.05)
    # corpo esculpido: pernas, torso, capa, cabeça com elmo, escudo e lança
    for sx in (-.12, .12):
        geo.cyl((sx, 0, .8), .11, .7, ms, sides=8, r2=.09)
    geo.cyl((0, 0, 1.45), .3, .7, ms, sides=8, r2=.22)
    for sy in (-.3, .3):
        geo.cyl_between((0, sy, 2.0), (0, sy * 1.3, 1.4), .09, ms, sides=6, r2=.07)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=.19, location=(0, 0, 2.28))
    bpy.context.object.data.materials.append(ms)
    geo.cyl((0, 0, 2.3), .2, .16, ms, sides=8, r2=.14)
    geo.box((.2, .32, 1.55), (.06, .44, .6), ms, bevel=0.03)
    geo.cyl_between((.1, -.34, .9), (.1, -.34, 2.9), .03, M('wood_dark'), sides=6)
    geo.cyl((.1, -.34, 2.9), .07, .2, ms, sides=6, r2=.0)
    parts.ivy(.3, .3, -.3, .3, .6, 1.8, M('leaf'), seed=6, n=8)
    parts.rubble(0, 0, .8, 5, ms, seed=7)


# ------------------------------------------------------------------ bandeiras animadas, lampiões, barris, caixas, portão, muro baixo
def flag_pole(cloth_key, f):
    geo.box((0, 0, .18), (.5, .5, .36), M('stone'), bevel=0.04)
    geo.cyl((0, 0, .3), .05, 2.7, M('wood_dark'), sides=8, r2=.04)
    geo.cyl((0, 0, 3.0), .09, .1, M('gold'), sides=8)
    parts.flag(0, 0, 2.05, 1.15, .8, M(cloth_key), phase=f / 4 * 6.283, dirv=(0.7071, -0.7071), wave=.16)
    parts.rubble(0, 0, .5, 3, M('stone'), seed=2, rmin=.05, rmax=.1)


legacy('nat_flag_blue')(lambda f: flag_pole('cloth_blue', f))
legacy('nat_flag_red')(lambda f: flag_pole('cloth_red', f))


def banner_stand(cloth_key):
    geo.box((0, 0, .1), (.6, .6, .2), M('stone'), bevel=0.04)
    geo.cyl((0, 0, .2), .05, 3.0, M('wood_dark'), sides=8)
    geo.cyl_between((-.55, 0, 3.0), (.55, 0, 3.0), .035, M('gold'), sides=6)
    parts.cloth_sheet((-.5, 0, 2.95), (.5, 0, 2.95), (-.5, 0, 1.5), (.5, 0, 1.5), M(cloth_key), nu=8, nv=8, sag=0, folds=.06, fold_n=3, thickness=.03, name='banner')
    for x in (-.5, .5):
        bpy.ops.mesh.primitive_uv_sphere_add(radius=.05, location=(x, 0, 3.0))
        bpy.context.object.data.materials.append(M('gold'))
    geo.rotate_all(-45)


legacy('city_banner_blue')(lambda f: banner_stand('cloth_blue'))
legacy('city_banner_red')(lambda f: banner_stand('cloth_red'))


def lamp(dual=False):
    mi = M('iron')
    geo.cyl((0, 0, 0), .26, .3, M('stone'), sides=8, r2=.2)
    geo.cyl((0, 0, .3), .09, 2.5, mi, sides=8, r2=.06)
    geo.cyl((0, 0, .5), .14, .12, mi, sides=8)
    for x in ((-.6, .6) if dual else (0,)):
        if dual:
            geo.beam((0, 0, 2.6), (x, 0, 2.7), .05, .05, mi, bevel=0.005)
        geo.cyl_between((x, 0, 2.7), (x, 0, 2.55), .015, mi, sides=4)
        geo.box((x, 0, 2.4), (.28, .28, .34), M('glass'), bevel=0.02)
        geo.box((x, 0, 2.6), (.34, .34, .05), mi, bevel=0.01)
        geo.cyl((x, 0, 2.62), .18, .16, mi, sides=4, r2=.02)
        bpy.ops.mesh.primitive_torus_add(major_radius=.15, minor_radius=.012, location=(x, 0, 2.4))
        bpy.context.object.data.materials.append(mi)
    if dual:
        geo.cyl((0, 0, 2.55), .07, .12, mi, sides=8)


legacy('city_lamp_post_a')(lambda f: lamp(False))
legacy('city_lamp_post_b')(lambda f: lamp(True))


def barrel(x, y, r=.34, h=.8, mat=None):
    mat = mat or M('wood_old')
    geo.cyl((x, y, 0), r * .92, h * .5, mat, sides=14, r2=r)
    geo.cyl((x, y, h * .5), r, h * .5, mat, sides=14, r2=r * .92)
    for z in (.12, .36, .62):
        bpy.ops.mesh.primitive_torus_add(major_radius=r * (.96 + .03 * math.sin(z * 3)), minor_radius=.025, location=(x, y, z * h / .8 + .04))
        bpy.context.object.data.materials.append(M('iron'))
    geo.cyl((x, y, h - .01), r * .9, .04, M('wood'), sides=14)


@legacy('city_barrels')
def barrels(f):
    barrel(-.3, -.1)
    barrel(.35, .05, r=.32, h=.75)
    barrel(0, .5, r=.3, h=.7, mat=M('wood'))
    geo.cyl_between((-.55, .5, .06), (.9, .55, .06), .04, M('rope'), sides=5)
    parts.grass_tufts(0, 0, .9, 4, M('grass'), seed=2, h=.16)


def crate(x, y, z, s, rot, mat):
    geo.box((x, y, z + s / 2), (s, s, s), mat, rot=(0, 0, rot), bevel=0.03)
    for k in (-1, 1):
        geo.box((x, y, z + s / 2), (s * 1.02, .06, s * 1.02), M('wood_dark'), rot=(0, 0, rot + (0 if k > 0 else 90)), bevel=0.01)


@legacy('city_crates')
def crates(f):
    crate(-.3, 0, 0, .8, 8, M('wood'))
    crate(.5, .1, 0, .65, -14, M('wood_old'))
    crate(-.1, .05, .8, .55, 24, M('wood_old'))
    geo.box((.2, .8, .22), (.55, .38, .44), M('cloth_cream'), rot=(0, 0, 20), bevel=0.09)
    geo.cyl_between((-.55, -.5, .1), (-.2, -.7, .1), .04, M('rope'), sides=5)


@legacy('city_cart_market')
def cart_market(f):
    mw, mwd, mo = M('wood'), M('wood_dark'), M('wood_old')
    geo.box((0, 0, .7), (1.5, .95, .1), mw, bevel=0.02)
    for sy in (-.47, .47):
        geo.box((0, sy, .92), (1.5, .07, .35), mo, bevel=0.02)
    for sx in (-.75, .75):
        geo.box((sx, 0, .92), (.07, .95, .35), mo, bevel=0.02)
    for sy in (-.58, .58):
        bpy.ops.mesh.primitive_torus_add(major_radius=.4, minor_radius=.05, location=(0, sy, .42), rotation=(math.pi / 2, 0, 0))
        bpy.context.object.data.materials.append(mwd)
        for k in range(8):
            a = k * math.pi / 4
            geo.cyl_between((0, sy, .42), (math.cos(a) * .4, sy, .42 + math.sin(a) * .4), .022, mwd, sides=4)
    geo.beam((.75, 0, .8), (1.7, .15, .55), .1, .08, mwd, bevel=0.01)
    geo.beam((.75, -.35, .8), (1.7, -.2, .55), .1, .08, mwd, bevel=0.01)
    fruit = ('#ff5a3a', '#ffcc30', '#7ad84a', '#c0304a')
    rr = random.Random(2)
    for i in range(22):
        bpy.ops.mesh.primitive_uv_sphere_add(radius=.11, segments=10, ring_count=7, location=(rr.uniform(-.6, .6), rr.uniform(-.34, .34), .85 + rr.uniform(0, .12)))
        bpy.context.object.data.materials.append(mats.flat('fruit%d' % (i % 4), fruit[i % 4], rough=.4, spec=.5, bevel_wear=0))


@legacy('city_planter')
def planter(f):
    mw = M('wood')
    geo.box((0, 0, .25), (1.2, .55, .5), mw, bevel=0.04)
    geo.box((0, 0, .5), (1.28, .62, .07), M('wood_dark'), bevel=0.02)
    geo.box((0, 0, .52), (1.1, .46, .02), M('dirt'), bevel=0)
    parts.leaf_cluster(0, 0, .75, .5, 20, M('leaf'), 3, size=(.1, .16), flat=.6)
    parts.flowers(0, 0, .45, 9, seed=4)


@legacy('city_bench')
def bench(f):
    mw, mwd = M('wood'), M('wood_dark')
    for i in range(3):
        geo.box((0, -.18 + i * .18, .5), (1.5, .16, .06), mw, bevel=0.015)
    for sx in (-.6, .6):
        geo.box((sx, 0, .25), (.12, .6, .5), mwd, bevel=0.02)
        geo.box((sx, .28, .8), (.1, .08, .6), mwd, bevel=0.02)
    for i in range(2):
        geo.box((0, .3, .68 + i * .2), (1.4, .06, .13), mw, bevel=0.015)
    for sx in (-.6, .6):
        geo.box((sx, -.25, .12), (.14, .08, .24), M('stone'), bevel=0.02)


@legacy('nat_gate_wood')
def gate_wood(f):
    mw, mwd = M('wood'), M('wood_dark')
    for sy in (-.9, .9):
        geo.box((0, sy, .7), (.18, .18, 1.4), mwd, bevel=0.03)
        geo.box((0, sy, 1.42), (.24, .24, .08), M('wood_y'), bevel=0.02)
    for z in (.35, .7, 1.05):
        geo.beam((0, -.82, z), (0, .82, z), .1, .07, mw, bevel=0.01)
    geo.beam((0, -.8, .3), (0, .8, 1.1), .09, .06, mwd, bevel=0.01)
    geo.box((0, .6, .7), (.07, .1, .1), M('iron'), bevel=0.01)


@legacy('nat_wall_low_a')
def wall_low_a(f):
    ms = M('stone')
    rr = random.Random(3)
    for i in range(9):
        geo.box((-1.2 + i * .3, rr.uniform(-.03, .03), .22 + (i % 2) * .02), (.34, .4, .44 + rr.uniform(0, .08)), ms, bevel=0.04)
    for i in range(7):
        geo.box((-1.0 + i * .33, rr.uniform(-.03, .03), .55), (.3, .38, .2), ms, bevel=0.04)
    parts.leaf_cluster(-.5, 0, .7, .22, 10, M('leaf'), 4, size=(.07, .12), flat=.5)
    parts.grass_tufts(0, 0, 1.2, 6, M('grass'), seed=5, h=.2)
    parts.flowers(0, 0, 1.0, 3, seed=6)


@legacy('nat_wall_low_b')
def wall_low_b(f):
    wall_low_a(f)
    geo.rotate_all(90)
