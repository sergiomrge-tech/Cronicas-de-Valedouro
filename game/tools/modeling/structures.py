"""Estruturas de mundo REG_001: torres, moinho, postos, santuário, cais, barcos, fazenda, caverna.

Todas usam a câmera isométrica padrão (az 45). `collision` (px de jogo, relativo ao pé) descreve a base sólida.
"""
from mats import *
from registry import asset
from terrain_forms import prism, footprint_circles, STRATA_ROCK, STRATA_SAND, STRATA_ICE

ROOF_RED = Mat(ramp('#2a0c10', '#5e1a1c', '#943024', '#c85a34', '#e88a52', '#ffc088'), tex=tex_stone_blocks(5.0, .3, 41), ambient=.34, bump=(8, .6), name='roof_red')
ROOF_SLATE = Mat(ramp('#12141e', '#2a2e40', '#464c62', '#686e88', '#8e94ac', '#bcc2d6'), tex=tex_stone_blocks(5.0, .3, 42), ambient=.34, bump=(8, .6), name='roof_slate')
ROOF_SNOW = Mat(WOOD_DARK.ramp, tex=tex_speckle(8, .16, 43), ambient=.42, bump=(6, .5), tint=snow_tint(1.0), name='roof_snow')
TENT = Mat(ramp('#3a2810', '#7a5a24', '#b88c3c', '#dcb45c', '#f2d488', '#fff0b8'), tex=tex_speckle(18, .14, 44), ambient=.44, bump=(14, .4), name='tent')
CLOTH_RED = cloth('#3a0a14', '#7a1626', '#b82c3c', '#e85a5a', '#ffa08c')
CLOTH_BLUE = cloth('#0c1450', '#1a2a90', '#2c4cd0', '#5a86ff', '#a8c8ff')
CLOTH_WHITE = cloth('#4a4658', '#98949a', '#d0ccc8', '#f0ece4', '#ffffff')
SOIL = Mat(ramp('#1c100c', '#3a2214', '#5e3a20', '#84562e', '#a8763e', '#cc9a58'), tex=tex_ridges(9, .34), ambient=.4, bump=(4, 1.0), name='soil_furrow')
WHEAT = Mat(ramp('#5a3c10', '#94661a', '#c8941e', '#e6b830', '#f8da58', '#fff39a'), tex=tex_speckle(20, .3, 45), ambient=.42, bump=(16, .5), name='wheat')
CABBAGE = Mat(ramp('#0a3a28', '#1a6a3a', '#3a9a4a', '#78c85a', '#b4ec7c', '#eaffb4'), tex=tex_leaf(amp=.3, seed=7), ambient=.4, name='cabbage')
HOLE = Mat(ramp('#020206', '#04040c', '#080812', '#0c0c1a', '#12121f', '#1a1a2a'), ambient=.2, name='cave_dark')
SAIL = Mat(ramp('#5a5060', '#a49aa0', '#dcd4cc', '#f6f0e6', '#ffffff', '#ffffff'), tex=tex_speckle(16, .08, 46), ambient=.55, name='sail')
HULL = Mat(ramp('#1a0e10', '#3a2018', '#5e3826', '#86583a', '#b08050', '#d8ae76'), tex=tex_wood_planks(7, .2, 47, 'x'), ambient=.34, bump=(9, .5), name='hull')
HULL_BLUE = Mat(ramp('#0a1440', '#183080', '#2a54c0', '#5a88f0', '#94b8ff', '#d0e0ff'), tex=tex_wood_planks(7, .2, 48, 'x'), ambient=.36, bump=(9, .5), name='hull_blue')
AMBER = Mat(ramp('#5a2a04', '#a05a0c', '#e09018', '#ffbc30', '#ffde70', '#fff8c0'), ambient=.44, emissive=.55, name='amber')


def tower_body(sc, base, height, mat, taper=.03):
    sc.add(prism(0, 0, base, base, height, mat, taper=taper, cut=.12))


def railing(sc, sx, sy, z, mat=WOOD_DARK, h=.42):
    for x in (-sx / 2, sx / 2):
        sc.add(box((x, 0, z + h / 2), (.08, sy, .08), mat, 0))
        for y in (-sy / 2, sy / 2):
            sc.add(box((x, y, z + h / 2), (.09, .09, h), mat, 0))
    for y in (-sy / 2, sy / 2):
        sc.add(box((0, y, z + h / 2 + .1), (sx, .08, .08), mat, 0))
        sc.add(box((0, y, z + h * .2), (sx, .06, .06), mat, 0))


def torch(sc, x, y, z, ember=True):
    sc.add(box((x, y, z), (.07, .07, .5), WOOD_DARK, 0))
    sc.add(Ellipsoid((x, y, z + .32), (.12, .12, .18), FIRE))
    sc.glow.append((x, y, z + .32, 60, (255, 170, 70), .6))


# ------------------------------------------------------------------ torre de vigia
def watchtower(sc, mat_base, mat_roof, seed):
    tower_body(sc, 2.0, 3.0, mat_base)
    for i in range(3):
        sc.add(box((0, 1.02, .6 + i * .85), (.16, .04, .38), HOLE, 0))
    sc.add(box((0, 0, 3.08), (2.7, 2.7, .16), WOOD_DARK, 0))
    for sgn in (-1, 1):
        for k in range(3):
            sc.add(box((sgn * 1.05, -.9 + k * .9, 2.98), (.12, .12, .25), WOOD_DARK, 0))
    railing(sc, 2.6, 2.6, 3.16)
    for x in (-.8, .8):
        for y in (-.8, .8):
            sc.add(box((x, y, 4.05), (.14, .14, 1.85), WOOD, 0))
    sc.add(box((0, 0, 3.6), (1.7, 1.7, .9), WOOD, 0))
    sc.add(box((0, .86, 3.72), (.6, .04, .5), HOLE, 0))
    sc.add(box((.86, 0, 3.72), (.04, .6, .5), HOLE, 0))
    sc.add(pyramid((0, 0, 4.9), 1.55, 1.15, mat_roof, rot=45.0))
    sc.add(box((0, 0, 6.35), (.05, .05, .9), WOOD_DARK, 0))
    sc.add(box((.3, 0, 6.6), (.55, .04, .32), CLOTH_RED, 0))
    torch(sc, 1.28, 1.28, 3.3)
    for i in range(6):
        a = i * 1.05
        facet(sc, (math.cos(a) * 1.35, math.sin(a) * 1.35, 0), .2 + .06 * (i % 3), ROCK, seed + i, squash=.7, nplanes=8)


@asset('str_watchtower_stone', 'city', 'structures', (340, 480), (170, 402), seed=501, tags=('estrutura', 'torre', 'campos', 'vigia'), collision=footprint_circles(2.0, 2.0, .8, .95), contact=(1.7, 1.7, .42), footprint=50)
def watchtower_stone(sc, f):
    watchtower(sc, STONE, ROOF_RED, 501)


@asset('str_watchtower_frost', 'city', 'structures', (340, 480), (170, 402), seed=502, tags=('estrutura', 'torre', 'gelo', 'vigia'), collision=footprint_circles(2.0, 2.0, .8, .95), contact=(1.7, 1.7, .42), footprint=50)
def watchtower_frost(sc, f):
    watchtower(sc, ROCK_SNOW, ROOF_SNOW, 502)


# ------------------------------------------------------------------ moinho animado
@asset('str_windmill', 'city', 'structures', (400, 520), (200, 420), seed=511, frames=8, tags=('estrutura', 'moinho', 'fazenda', 'animado'), collision=footprint_circles(2.6, 2.6, .85, .95), contact=(2.0, 2.0, .42), footprint=56)
def windmill(sc, f):
    sc.add(Cylinder((0, 0, 0), 3.0, 1.45, 1.05, PLASTER, cap_bottom=True))
    for k in range(3):
        sc.add(Cylinder((0, 0, .5 + k * .8), .07, 1.42 - k * .15, 1.42 - k * .15, WOOD_DARK))
    sc.add(box((.9, .9, .6), (.55, .55, 1.1), WOOD_DARK, 45))
    sc.add(box((.66, .66, 1.9), (.3, .3, .4), GLASS_BLUE, 45))
    sc.add(Cylinder((0, 0, 3.0), .16, 1.2, 1.2, WOOD_DARK))
    sc.add(Cylinder((0, 0, 3.16), 1.05, 1.05, .12, ROOF_RED))
    sc.add(Cylinder((0, 0, 4.21), .5, .12, .02, WOOD_DARK))
    ax = np.array([.7071, .7071, 0.0])
    hub = ax * 1.15 + np.array([0, 0, 3.55])
    sc.add(Ellipsoid(tuple(hub), (.2, .2, .2), IRON))
    for k in range(4):
        th = f / 8 * 90.0 + k * 90.0
        blade = box((0, 0, 1.3), (.1, .1, 2.6), WOOD_DARK, 0)
        sc.add(Xform(blade, rot=(th, 0, 45), pos=tuple(hub)))
        lat = box((0, .23, 1.85), (.05, .42, 1.3), CLOTH_WHITE, 0)
        sc.add(Xform(lat, rot=(th, 0, 45), pos=tuple(hub)))
    for i in range(5):
        a = i * 1.3 + .4
        sc.add(Ellipsoid((math.cos(a) * 1.3, math.sin(a) * 1.3, .1), (.22, .18, .16), LEAF))


# ------------------------------------------------------------------ postos e abrigos
@asset('str_outpost_amber', 'city', 'structures', (400, 340), (200, 268), seed=521, tags=('estrutura', 'posto', 'deserto', 'ambar'), collision=footprint_circles(2.6, 2.4, .8, .9), contact=(2.0, 1.9, .4), footprint=52)
def outpost_amber(sc, f):
    sc.add(prism(0, 0, 2.4, 2.2, 1.1, SANDSTONE, taper=.04, cut=.1))
    sc.add(box((0, 1.12, .6), (.7, .06, .9), HOLE, 0))
    for x in (-1.3, 1.3):
        for y in (-1.05, 1.05):
            sc.add(box((x, y, 1.05), (.12, .12, 2.1), WOOD, 0))
    sc.add(pyramid((0, 0, 2.05), 1.75, .8, TENT, rot=45.0, sides=4))
    for k in range(-1, 2):
        sc.add(box((k * .85, -1.25, .35), (.5, .5, .5), WOOD_DARK, 0))
    for i in range(4):
        a = 2.4 + i * .5
        sc.add(Cylinder((math.cos(a) * 1.5, math.sin(a) * 1.5, 0), .35 + i * .05, .16, .13, AMBER))
    sc.add(Cylinder((1.35, -.4, 1.05), .5, .12, .12, AMBER))
    sc.glow.append((1.35, -.4, 1.4, 60, (255, 190, 60), .55))
    sc.add(box((-1.3, .2, 1.65), (.04, .4, .5), CLOTH_RED, 0))
    for i in range(3):
        rock(sc, (1.7 - i * .4, 1.3 + i * .15, 0), .2, ROCK_SAND, 521 + i, n=3)


@asset('str_lodge_ice', 'city', 'structures', (400, 340), (200, 268), seed=522, tags=('estrutura', 'abrigo', 'gelo'), collision=footprint_circles(2.6, 2.2, .8, .9), contact=(2.0, 1.8, .4), footprint=52)
def lodge_ice(sc, f):
    sc.add(prism(0, 0, 2.5, 2.1, 1.35, WOOD_OLD, taper=.02, cut=.08))
    sc.add(prism_roof((0, 0, 1.3), (2.9, 2.5, 1.15), ROOF_SNOW, rot=0))
    sc.add(box((.4, 1.07, .55), (.6, .05, .95), WOOD_DARK, 0))
    sc.add(box((-.75, 1.07, .8), (.5, .05, .4), GLASS_BLUE, 0))
    sc.add(box((1.05, -.5, 2.05), (.4, .4, .9), STONE, 0))
    sc.add(Ellipsoid((1.05, -.5, 2.5), (.3, .3, .1), SNOWBASE))
    sc.add(Ellipsoid((.9, -.4, 2.8), (.14, .14, .2), Mat(ramp('#7a7a90', '#a4a4b8', '#c8c8d8', '#e6e6f0', '#ffffff'), ambient=.7, name='smoke')))
    torch(sc, -1.4, 1.25, .1)
    for i in range(3):
        sc.add(Cylinder((-1.55 + i * .28, -1.2, 0), .55, .1, .1, LOG_END))
    for i in range(5):
        sc.add(Ellipsoid((math.cos(i * 1.4) * 1.6, math.sin(i * 1.4) * 1.5, .06), (.35, .28, .13), SNOWBASE))


@asset('str_shelter_wood', 'city', 'structures', (300, 250), (150, 190), seed=523, tags=('estrutura', 'abrigo', 'estrada'), collision=footprint_circles(1.7, 1.4, .8, .9), contact=(1.4, 1.2, .4), footprint=36)
def shelter_wood(sc, f):
    for x in (-.8, .8):
        sc.add(box((x, -.5, .8), (.12, .12, 1.6), WOOD_DARK, 0))
        sc.add(box((x, .5, .55), (.12, .12, 1.1), WOOD_DARK, 0))
    sc.add(prism_roof((0, 0, 1.1), (2.0, 1.7, .5), ROOF_RED, rot=0))
    sc.add(box((0, -.5, .5), (1.7, .1, 1.0), WOOD_OLD, 0))
    sc.add(box((-.4, .1, .18), (.7, .5, .36), HAY, 0))
    sc.add(Cylinder((.5, .3, 0), .3, .2, .18, WOOD))
    torch(sc, .95, .7, .2)


# ------------------------------------------------------------------ santuário / altar
@asset('str_shrine_stone', 'city', 'structures', (320, 340), (160, 262), seed=531, frames=4, tags=('estrutura', 'santuario', 'altar', 'animado'), collision=footprint_circles(1.6, 1.6, .8, .9), contact=(1.6, 1.6, .4), footprint=40)
def shrine_stone(sc, f):
    sc.add(prism(0, 0, 2.4, 2.4, .25, STONE, taper=0, cut=.3))
    sc.add(prism(0, 0, 1.9, 1.9, .2, STONE, taper=0, cut=.3, z0=.25))
    for sgn_x in (-1, 1):
        for sgn_y in (-1, 1):
            sc.add(Cylinder((sgn_x * .75, sgn_y * .75, .45), 1.7, .2, .16, STONE_MOSS))
            sc.add(box((sgn_x * .75, sgn_y * .75, 2.2), (.4, .4, .12), STONE, 0))
    sc.add(prism(0, 0, 1.0, 1.0, .5, STONE_PLAIN, taper=0, cut=.15, z0=.45))
    ph = f / 4 * 6.283
    sc.add(Ellipsoid((0, 0, 1.3 + .05 * math.sin(ph)), (.22, .22, .32 + .04 * math.sin(ph)), GLOW_BLUE))
    for k in range(6):
        a = ph + k
        sc.add(Ellipsoid((math.cos(a) * .55, math.sin(a) * .55, 1.0 + .5 * ((k / 6 + f / 4) % 1)), (.05, .05, .05), GLOW_BLUE))
    sc.glow.append((0, 0, 1.3, 90, (120, 190, 255), .5 + .1 * math.sin(ph)))
    for i in range(4):
        sc.add(Ellipsoid((math.cos(i * 1.7) * 1.35, math.sin(i * 1.7) * 1.3, .1), (.3, .25, .14), LEAF))


# ------------------------------------------------------------------ cais, docas e barcos
def dock_planks(sc, length, axis):
    sx, sy = (length, 1.5) if axis == 'a' else (1.5, length)
    n = int(length / .32)
    for i in range(n):
        u = -length / 2 + (i + .5) * length / n
        c = (u, 0, .5) if axis == 'a' else (0, u, .5)
        s = (.29, 1.5, .09) if axis == 'a' else (1.5, .29, .09)
        sc.add(box(c, s, WOOD if i % 2 else WOOD_Y, 0))
    for sgn in (-1, 1):
        c = (0, sgn * .68, .42) if axis == 'a' else (sgn * .68, 0, .42)
        s = (length, .1, .12) if axis == 'a' else (.1, length, .12)
        sc.add(box(c, s, WOOD_DARK, 0))
    k = int(length / 1.2) + 1
    for i in range(k):
        u = -length / 2 + .1 + i * (length - .2) / max(1, k - 1)
        for sgn in (-1, 1):
            x, y = (u, sgn * .68) if axis == 'a' else (sgn * .68, u)
            sc.add(Cylinder((x, y, -.2), .95, .11, .1, WOOD_DARK))
            sc.add(Cylinder((x, y, .74), .04, .11, .08, LOG_END))


@asset('str_dock_a', 'city', 'structures', (340, 200), (170, 120), seed=541, tags=('estrutura', 'cais', 'agua'), collision=footprint_circles(3.2, 1.3, .9, .8), contact=(1.6, .8, .3), footprint=30)
def dock_a(sc, f):
    dock_planks(sc, 3.2, 'a')


@asset('str_dock_b', 'city', 'structures', (340, 200), (170, 120), seed=542, tags=('estrutura', 'cais', 'agua'), collision=footprint_circles(1.3, 3.2, .9, .8), contact=(.8, 1.6, .3), footprint=30)
def dock_b(sc, f):
    dock_planks(sc, 3.2, 'b')


@asset('str_dock_end', 'city', 'structures', (260, 240), (130, 168), seed=543, tags=('estrutura', 'cais', 'lampiao'), collision=footprint_circles(1.6, 1.6, .9, .8), contact=(1.0, 1.0, .3), footprint=24)
def dock_end(sc, f):
    for i in range(5):
        sc.add(box((-.7 + i * .35, 0, .5), (.32, 1.6, .09), WOOD if i % 2 else WOOD_Y, 0))
    for x in (-.8, .8):
        for y in (-.75, .75):
            sc.add(Cylinder((x, y, -.2), .95, .11, .1, WOOD_DARK))
    sc.add(Cylinder((.7, .7, .55), 1.5, .07, .06, WOOD_DARK))
    sc.add(box((.7, .7, 2.0), (.2, .2, .3), LANTERN_GLASS_LOCAL, 0))
    sc.glow.append((.7, .7, 2.0, 60, (255, 190, 80), .7))
    sc.add(Cylinder((-.6, -.4, .58), .3, .14, .14, WOOD))
    sc.add(Ellipsoid((-.2, -.5, .58), (.3, .12, .05), Mat(ramp('#3a2a10', '#7a5a24', '#b88c3c', '#dcb45c'), ambient=.4, name='rope')))


LANTERN_GLASS_LOCAL = Mat(ramp('#8a5a08', '#e0a418', '#ffd030', '#ffec7a', '#fffac0', '#ffffff'), emissive=1.0, name='lantern_glass2')


def boat_hull(sc, length, beam, mat, bob):
    n = 9
    for i in range(n):
        u = -length / 2 + (i + .5) * length / n
        t = abs(u) / (length / 2)
        w = beam * (1 - t ** 2.2) * .5 + .08
        z = .12 + .3 * t ** 2 + bob
        sc.add(box((u, 0, z + .16), (length / n * 1.1, w * 2, .32), mat, 0))
    for sgn in (-1, 1):
        sc.add(box((0, sgn * beam * .48, .48 + bob), (length * .78, .07, .1), WOOD_DARK, 0))
    for k in (-1, 0, 1):
        sc.add(box((k * .55, 0, .32 + bob), (.08, beam * .95, .06), WOOD_DARK, 0))


@asset('str_boat_row', 'city', 'structures', (280, 200), (140, 120), seed=551, frames=4, tags=('estrutura', 'barco', 'agua', 'animado'), collision=footprint_circles(1.9, .9, .9, .8), contact=(1.1, .6, .28), footprint=26)
def boat_row(sc, f):
    bob = .04 * math.sin(f / 4 * 6.283)
    boat_hull(sc, 2.4, .95, HULL, bob)
    sc.add(box((.1, .55, .62 + bob), (.05, .05, .9), WOOD_DARK, 25))
    sc.add(box((.1, -.55, .62 + bob), (.05, .05, .9), WOOD_DARK, -25))
    sc.add(Ellipsoid((-.5, 0, .5 + bob), (.16, .16, .1), BONE))


@asset('str_boat_sail', 'city', 'structures', (340, 380), (170, 190), seed=552, frames=4, tags=('estrutura', 'barco', 'agua', 'animado'), collision=footprint_circles(2.6, 1.1, .9, .8), contact=(1.5, .8, .28), footprint=34)
def boat_sail(sc, f):
    bob = .05 * math.sin(f / 4 * 6.283)
    boat_hull(sc, 3.1, 1.2, HULL_BLUE, bob)
    sc.add(Cylinder((.2, 0, .3 + bob), 2.7, .07, .05, WOOD_DARK))
    sc.add(box((.2, 0, 1.5 + bob), (.9, .03, 1.7), SAIL, 135))
    sc.add(box((.2, 0, 2.95 + bob), (.05, .05, .5), WOOD_DARK, 0))
    sc.add(box((.2, -.05, 3.05 + bob), (.4, .03, .22), CLOTH_RED, 135))
    sc.add(Ellipsoid((-1.0, 0, .55 + bob), (.2, .2, .12), LEATHER))


# ------------------------------------------------------------------ fazenda
@asset('str_barn', 'city', 'structures', (460, 400), (230, 330), seed=561, tags=('estrutura', 'celeiro', 'fazenda'), collision=footprint_circles(3.2, 2.4, .8, .92), contact=(2.4, 1.9, .42), footprint=60)
def barn(sc, f):
    sc.add(prism(0, 0, 3.2, 2.4, 1.7, WOOD_DARK, taper=0, cut=.04))
    sc.add(prism_roof((0, 0, 1.68), (3.5, 2.7, 1.4), ROOF_RED, rot=0))
    sc.add(box((.3, 1.22, .8), (1.3, .06, 1.5), WOOD, 0))
    sc.add(box((.3, 1.26, .8), (.07, .04, 1.5), WOOD_DARK, 0))
    sc.add(box((.3, 1.26, .8), (1.3, .04, .07), WOOD_DARK, 0))
    for sgn in (-1, 1):
        sc.add(box((.3 + sgn * .33, 1.26, .8), (.05, .04, 1.4), IRON, 0))
    sc.add(box((.3, 1.22, 2.0), (.7, .05, .5), HOLE, 0))
    sc.add(box((-1.1, 1.22, 1.0), (.4, .05, .4), GLASS_BLUE, 0))
    for k in range(4):
        sc.add(Cylinder((1.6 + (k % 2) * .4, -.8 + k * .5, 0), .55, .28, .26, HAY))
    sc.add(Cylinder((-1.75, .9, 0), .7, .3, .3, WOOD))
    torch(sc, -.6, 1.3, .9)


def crop_plot(sc, kind, seed):
    rr = rng_for(seed)
    sc.add(prism(0, 0, 3.0, 3.0, .08, DIRTBASE, taper=0, cut=.06))
    for r in range(5):
        y = -1.1 + r * .55
        sc.add(box((0, y, .13), (2.7, .3, .09), SOIL, 0))
        for i in range(9):
            x = -1.2 + i * .3 + rr.uniform(-.03, .03)
            if kind == 'wheat':
                for s in range(3):
                    sc.add(Cylinder((x + rr.uniform(-.05, .05), y + rr.uniform(-.06, .06), .15), .5 + rr.uniform(0, .18), .03, .012, WHEAT))
                sc.add(Ellipsoid((x, y, .68), (.05, .05, .1), WHEAT))
            elif kind == 'corn':
                sc.add(Cylinder((x, y, .15), .9 + rr.uniform(0, .25), .04, .03, LEAF_BIRCH))
                sc.add(Ellipsoid((x + .06, y, .68), (.06, .05, .14), CROP_GOLD))
            else:
                sc.add(Ellipsoid((x, y, .3), (.16, .15, .13), CABBAGE))
                sc.add(Ellipsoid((x, y, .34), (.09, .09, .09), LEAF_BIRCH))
    for sgn in (-1, 1):
        sc.add(box((sgn * 1.55, 0, .3), (.06, 3.1, .5), WOOD_OLD, 0))
        sc.add(box((0, sgn * 1.55, .3), (3.1, .06, .5), WOOD_OLD_Y, 0))


CROP_GOLD = Mat(ramp('#8a5a08', '#c8901c', '#eec040', '#ffe27a', '#fff6a8'), ambient=.44, name='corn_gold')


for _kind in ('wheat', 'corn', 'cabbage'):
    @asset('str_crop_%s' % _kind, 'city', 'structures', (340, 200), (170, 100), seed=562, tags=('estrutura', 'plantacao', 'fazenda', _kind), collision=None, contact=None, footprint=40)
    def _crop(sc, f, _kind=_kind):
        crop_plot(sc, _kind, 562)


@asset('str_scarecrow', 'city', 'structures', (140, 240), (70, 186), seed=563, tags=('estrutura', 'fazenda', 'espantalho'), blocks=(6,), footprint=10)
def scarecrow(sc, f):
    sc.add(Cylinder((0, 0, 0), 1.6, .05, .05, WOOD_DARK))
    sc.add(box((0, 0, 1.2), (.05, 1.1, .06), WOOD_DARK, 0))
    sc.add(Ellipsoid((0, 0, 1.75), (.17, .17, .19), HAY))
    sc.add(Cylinder((0, 0, 1.86), .22, .24, .1, LEATHER))
    sc.add(Cylinder((0, 0, 1.84), .04, .28, .28, LEATHER))
    sc.add(box((0, 0, .95), (.3, .45, .6), CLOTH_BLUE, 0))
    for sgn in (-1, 1):
        sc.add(Ellipsoid((0, sgn * .55, 1.12), (.1, .12, .05), HAY))
        sc.add(Ellipsoid((0, sgn * .2, .58), (.09, .09, .18), HAY))


# ------------------------------------------------------------------ entrada de caverna
@asset('str_cave_entrance', 'dungeon', 'structures', (400, 360), (200, 290), seed=571, tags=('estrutura', 'caverna', 'entrada'), collision=((-54, 6, 22), (-18, 12, 22), (18, 12, 22), (54, 6, 22)), contact=(2.2, 1.6, .42), footprint=52)
def cave_entrance(sc, f):
    sc.add(prism(0, 0, 3.0, 2.6, 2.4, STRATA_ROCK, taper=.08, cut=.3))
    sc.add(prism(0, .1, 2.4, 2.1, .35, GRASS, taper=0, cut=.3, z0=2.4))
    sc.add(box((0, 1.28, .85), (1.25, .12, 1.5), HOLE, 0))
    for sgn in (-1, 1):
        sc.add(box((sgn * .75, 1.36, .85), (.26, .3, 1.7), STONE_MOSS, 0))
        sc.add(box((sgn * .5, 1.4, .1), (.3, .2, .2), STONE_MOSS, 0))
    sc.add(box((0, 1.36, 1.72), (1.9, .3, .26), STONE_MOSS, 0))
    torch(sc, -1.05, 1.42, .55)
    torch(sc, 1.05, 1.42, .55)
    for i in range(5):
        facet(sc, (math.cos(i * 1.4 + .3) * 1.7, 1.05 + math.sin(i * 1.2) * .5, 0), .22, ROCK_MOSS, 571 + i, squash=.75, nplanes=8)
    for i in range(4):
        tuft(sc, -1.0 + i * .7, 1.75, GRASS, 580 + i, n=5, h=.3, spread=.08)
