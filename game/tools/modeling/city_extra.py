"""Cidade / Hub — props urbanos complementares (mesma linguagem dos assets APPROVED de Cidade)."""
from mats import *
from registry import asset


def stripe_tint(c1, c2, freq=3.2, axis=1):
    a = np.array(c1, dtype=np.float32)
    b = np.array(c2, dtype=np.float32)

    def f(ctx, col, tone):
        k = np.floor(ctx.P[:, axis] * freq).astype(int) % 2
        base = np.where(k[:, None] == 0, a, b)
        return base * (0.55 + 0.6 * tone[:, None])
    return f


AWNING = Mat(ramp('#4a0a18', '#8a1428', '#c8283a', '#f05a54', '#ffa088'), tex=tex_speckle(22, .1, 19), ambient=.42, bump=(20, .3),
             tint=stripe_tint((200, 40, 56), (246, 238, 222)), name='awning_striped')
AWNING_BLUE = Mat(ramp('#0c1450', '#1a2a90', '#2c4cd0', '#5a86ff', '#a8c8ff'), tex=tex_speckle(22, .1, 19), ambient=.42, bump=(20, .3),
                  tint=stripe_tint((44, 76, 208), (246, 238, 222)), name='awning_blue')
LANTERN_GLASS = Mat(ramp('#8a5a08', '#e0a418', '#ffd030', '#ffec7a', '#fffac0', '#ffffff'), emissive=1.0, name='lantern_glass')


def lamp(sc, height=2.6, dual=False):
    sc.add(Cylinder((0, 0, 0), .2, .2, .14, STONE))
    sc.add(Cylinder((0, 0, .2), height - .2, .07, .05, WOOD_DARK))
    arms = [(0, 1)] if not dual else [(-1, 1), (1, 1)]
    for sgn, _ in arms:
        if dual:
            sc.add(box((sgn * .32, 0, height - .25), (.7, .05, .05), IRON, 0))
        z = height - .32
        x = sgn * .62 if dual else 0
        sc.add(box((x, 0, z - .18), (.22, .22, .06), IRON, 0))
        sc.add(box((x, 0, z + .04), (.2, .2, .32), LANTERN_GLASS, 0))
        sc.add(box((x, 0, z + .24), (.26, .26, .05), IRON, 0))
        sc.add(Cylinder((x, 0, z + .28), .1, .12, .01, IRON))
        sc.glow.append((x, 0, z + .04, 46, (255, 190, 80), .7))


@asset('city_lamp_post_a', 'city', 'props', (120, 220), (60, 196), seed=201, blocks=(5,), tags=('vila', 'luz'), footprint=8)
def lamp_a(sc, f):
    lamp(sc, 2.6, False)


@asset('city_lamp_post_b', 'city', 'props', (200, 220), (100, 196), seed=202, blocks=(5,), tags=('vila', 'luz'), footprint=8)
def lamp_b(sc, f):
    lamp(sc, 2.6, True)


@asset('city_banner_blue', 'city', 'props', (130, 250), (65, 226), seed=203, blocks=(5,), tags=('vila', 'bandeira'), footprint=8)
def banner_blue(sc, f):
    _banner(sc, CLOTH_BLUE)


@asset('city_banner_red', 'city', 'props', (130, 250), (65, 226), seed=204, blocks=(5,), tags=('vila', 'bandeira'), footprint=8)
def banner_red(sc, f):
    _banner(sc, CLOTH_RED)


def _banner(sc, mat):
    sc.add(box((0, 0, .1), (.5, .5, .2), STONE, 0))
    sc.add(Cylinder((0, 0, .2), 2.5, .06, .05, WOOD_DARK))
    sc.add(box((0, 0, 2.62), (.9, .07, .07), GOLD, 0))
    sc.add(box((0, -.06, 1.75), (.66, .05, 1.5), mat, 0))
    sc.add(Convex([((0, -1, 0), .09), ((0, 1, 0), -.04), ((1, 0, 0), .33), ((-1, 0, 0), .33), ((0, 0, -1), -.95), ((0, 0, 1), 1.1), ((.6, 0, -1), .12), ((-.6, 0, -1), .12)], mat, (0, -.06, 1.0), (.66, .05, .3)))
    sc.add(box((0, -.1, 1.75), (.12, .02, .5), GOLD, 0))
    sc.add(box((0, -.1, 1.9), (.4, .02, .1), GOLD, 0))
    sc.add(Ellipsoid((0, -.1, 2.2), (.1, .02, .1), GOLD))
    sc.add(Ellipsoid((0, 0, 2.7), (.08, .08, .08), GOLD))


@asset('city_fountain', 'city', 'props', (280, 260), (140, 214), seed=205, blocks=(30,), tags=('vila', 'fonte'), footprint=40, frames=4)
def fountain(sc, f):
    sc.add(Cylinder((0, 0, 0), .5, 1.35, 1.3, STONE))
    sc.add(Cylinder((0, 0, .5), .02, 1.15, 1.15, WATER))
    sc.add(Cylinder((0, 0, .5), .8, .3, .22, STONE))
    sc.add(Cylinder((0, 0, 1.3), .12, .6, .5, STONE))
    sc.add(Cylinder((0, 0, 1.42), .02, .5, .5, WATER))
    sc.add(Cylinder((0, 0, 1.4), .6, .12, .09, STONE))
    ph = f / 4 * 6.283
    for k in range(6):
        a = k / 6 * 6.283
        r = .5 + .1 * math.sin(ph + k)
        sc.add(Ellipsoid((math.cos(a) * r * .8, math.sin(a) * r * .8, 1.7 - r * .5 + .1 * math.sin(ph + k * 1.3)), (.07, .07, .09), GLOW_BLUE))
    sc.add(Ellipsoid((0, 0, 2.05 + .06 * math.sin(ph)), (.1, .1, .16), GLOW_BLUE))
    for a in (.5, 2.6, 4.7):
        sc.add(Ellipsoid((math.cos(a) * 1.05, math.sin(a) * 1.05, .53), (.14, .1, .04), LEAF))
    sc.glow.append((0, 0, 1.5, 70, (120, 190, 255), .35))


@asset('city_planter', 'city', 'props', (150, 120), (75, 96), seed=206, blocks=(11,), tags=('vila', 'jardim'), footprint=14)
def planter(sc, f):
    sc.add(box((0, 0, .22), (1.1, .5, .44), STONE, 0))
    sc.add(box((0, 0, .44), (.96, .38, .04), EARTH, 0))
    canopy(sc, (0, 0, .58), (.45, .18, .16), 10, LEAF, 206, size=.2, zsize=.15)
    r = rng_for(206)
    fm = [flower_mat('red'), flower_mat('pink'), flower_mat('yellow'), flower_mat('white')]
    for i in range(12):
        sc.add(Ellipsoid((r.uniform(-.44, .44), r.uniform(-.14, .14), .7 + r.uniform(0, .12)), (.07, .07, .06), fm[i % 4]))


@asset('city_crates', 'city', 'props', (170, 150), (85, 118), seed=207, blocks=(15,), tags=('vila', 'porto', 'caixas'), footprint=18)
def crates(sc, f):
    def crate(x, y, z, s, rot):
        sc.add(box((x, y, z + s / 2), (s, s, s), WOOD, rot))
        for sg in (-1, 1):
            ca, sa = math.cos(math.radians(rot)), math.sin(math.radians(rot))
            sc.add(box((x + ca * sg * s * .43, y + sa * sg * s * .43, z + s / 2), (.07, s * 1.02, s * 1.02) if False else (s * .12, s * 1.03, s * 1.03), WOOD_DARK, rot))
    crate(-.3, .1, 0, .7, 10)
    crate(.42, -.15, 0, .6, -14)
    crate(0, .0, .7, .5, 25)
    crate(.35, .45, 0, .46, 5)


@asset('city_barrels', 'city', 'props', (170, 150), (85, 118), seed=208, blocks=(14,), tags=('vila', 'porto', 'barris'), footprint=16)
def barrels(sc, f):
    for x, y, r, h in [(-.3, .05, .3, .7), (.34, -.1, .28, .66), (.05, .42, .26, .6)]:
        sc.add(Cylinder((x, y, 0), h, r * .88, r * .88, WOOD, cap_bottom=True))
        sc.add(Ellipsoid((x, y, h * .5), (r, r, h * .5), WOOD))
        for z in (.15, h - .15):
            sc.add(Cylinder((x, y, z), .05, r * 1.0, r * 1.0, IRON))
        sc.add(Cylinder((x, y, h - .01), .02, r * .82, r * .82, WOOD_DARK))


@asset('city_bench', 'city', 'props', (170, 120), (85, 96), seed=209, blocks=(10,), tags=('vila', 'banco'), footprint=12)
def bench(sc, f):
    sc.add(box((0, 0, .4), (1.3, .38, .08), WOOD, 0))
    sc.add(box((0, -.17, .75), (1.3, .06, .34), WOOD, 0))
    for u in (-.55, .55):
        sc.add(box((u, 0, .2), (.08, .3, .4), IRON, 0))
        sc.add(box((u, -.17, .5), (.08, .06, .7), IRON, 0))


@asset('city_cart_market', 'city', 'props', (210, 160), (105, 128), seed=210, blocks=(16,), tags=('vila', 'mercado'), footprint=20)
def cart_market(sc, f):
    sc.add(box((0, 0, .42), (1.4, .85, .12), WOOD, 0))
    for sgn in (-1, 1):
        sc.add(box((0, sgn * .42, .62), (1.4, .07, .3), WOOD_DARK, 0))
        sc.add(Xform(Cylinder((0, 0, 0), .07, .36, .36, WOOD_DARK, cap_bottom=True), (90, 0, 0), (0, sgn * .5 + .04, .36)))
    sc.add(box((.7, 0, .62), (.07, .85, .3), WOOD_DARK, 0))
    fruit = [flower_mat('red'), flower_mat('orange'), flower_mat('yellow'), Mat(LEAF.ramp, ambient=.5, name='fruit_g')]
    rr = rng_for(210)
    for i in range(18):
        sc.add(Ellipsoid((rr.uniform(-.55, .55), rr.uniform(-.3, .3), .58 + rr.uniform(0, .1)), (.12, .12, .11), fruit[i % 4]))
    sc.add(Xform(Cylinder((0, 0, 0), 1.0, .05, .05, WOOD), (0, 90, 0), (-1.65, 0, .45)))


@asset('city_stall_striped', 'city', 'props', (230, 250), (115, 204), seed=211, blocks=(20,), tags=('vila', 'mercado'), footprint=26)
def stall_striped(sc, f):
    for x in (-.8, .8):
        for y in (-.5, .5):
            sc.add(box((x, y, .85), (.09, .09, 1.7), WOOD_DARK, 0))
    sc.add(box((0, .32, .34), (1.7, .5, .68), WOOD, 0))
    sc.add(box((0, .32, .7), (1.8, .58, .06), WOOD_DARK, 0))
    sc.add(prism_roof((0, 0, 1.55), (1.9, 1.5, .55), AWNING, rot=0))
    fruit = [flower_mat('red'), flower_mat('orange'), flower_mat('yellow')]
    rr = rng_for(211)
    for i in range(14):
        sc.add(Ellipsoid((rr.uniform(-.7, .7), .3 + rr.uniform(-.15, .15), .8 + rr.uniform(0, .05)), (.11, .11, .1), fruit[i % 3]))


@asset('city_stall_blue', 'city', 'props', (230, 250), (115, 204), seed=212, blocks=(20,), tags=('vila', 'mercado'), footprint=26)
def stall_blue(sc, f):
    for x in (-.8, .8):
        for y in (-.5, .5):
            sc.add(box((x, y, .85), (.09, .09, 1.7), WOOD_DARK, 0))
    sc.add(box((0, .32, .34), (1.7, .5, .68), WOOD, 0))
    sc.add(box((0, .32, .7), (1.8, .58, .06), WOOD_DARK, 0))
    sc.add(prism_roof((0, 0, 1.55), (1.9, 1.5, .55), AWNING_BLUE, rot=0))
    for i, x in enumerate((-.6, -.2, .2, .6)):
        sc.add(Cylinder((x, .3, .73), .3, .1, .08, GLASS_BLUE if i % 2 else MUSHROOM_RED))


@asset('city_monument', 'city', 'props', (170, 320), (85, 282), seed=213, blocks=(14,), tags=('vila', 'monumento'), footprint=22)
def monument(sc, f):
    sc.add(box((0, 0, .15), (1.2, 1.2, .3), STONE, 0))
    sc.add(box((0, 0, .5), (.9, .9, .4), STONE, 0))
    sc.add(box((0, 0, 1.6), (.5, .5, 1.8), STONE, 0))
    sc.add(box((0, 0, 2.6), (.66, .66, .16), STONE, 0))
    sc.add(Ellipsoid((0, 0, 2.95), (.24, .24, .3), STONE))
    sc.add(Ellipsoid((0, 0, 3.4), (.14, .14, .14), STONE))
    sc.add(box((0, 0, 3.05), (.7, .12, .1), STONE, 0))
    sc.add(box((0, -.27, 1.6), (.16, .03, .5), GOLD, 0))
    sc.add(box((0, -.27, 1.85), (.4, .03, .1), GOLD, 0))


@asset('city_stairs', 'city', 'props', (230, 170), (115, 136), seed=214, tags=('vila', 'escada'), blocks=(14,), footprint=20)
def stairs(sc, f):
    for k in range(5):
        sc.add(box((k * .3 - .6, 0, k * .14 + .07), (.3, 1.4, .14 * (k + 1) if False else .14), STONE, 0))
        sc.add(box((k * .3 - .6, 0, (k * .14 + .14) / 2), (.3, 1.4, k * .14 + .14), STONE, 0))


@asset('city_sign_hanging', 'city', 'props', (200, 170), (100, 140), seed=215, tags=('vila', 'placa'), footprint=6)
def sign_hanging(sc, f):
    sc.add(box((0, 0, .9), (.12, .12, 1.8), WOOD_DARK, 0))
    sc.add(box((.45, 0, 1.7), (1.0, .07, .07), WOOD_DARK, 0))
    sc.add(box((.6, 0, 1.28), (.72, .06, .5), WOOD, 0))
    sc.add(box((.6, -.04, 1.28), (.5, .02, .1), GOLD, 0))
    for x in (.3, .9):
        sc.add(box((x, 0, 1.6), (.03, .03, .16), IRON, 0))
