"""Natureza / Overworld — árvores, arbustos, flores, rochas, troncos."""
from mats import *
from registry import asset

GS = .5


@asset('nat_tree_pine', 'nature', 'trees', (200, 270), (100, 238), seed=11, blocks=(15,), tags=('floresta', 'vale', 'arvore'))
def tree_pine(sc, f):
    add_patch(sc, 'grass', 1.0, 26, 11, nflowers=4)
    sc.add(Cylinder((0, 0, 0), 1.2, .26, .17, BARK))
    r = rng_for(11)
    for k in range(5):
        z0 = .55 + .58 * k
        rad = 1.12 - .17 * k
        sc.add(Cylinder((0, 0, z0), .82, rad, .10, PINE))
        for j in range(11):
            a = j / 11 * 6.283 + k * .7
            sc.add(Ellipsoid((math.cos(a) * rad * .9, math.sin(a) * rad * .9, z0 + .04), (.26, .26, .17), PINE))
    sc.add(Cylinder((0, 0, 3.35), .55, .16, .01, PINE))


@asset('nat_tree_pine_snow', 'nature', 'trees', (200, 270), (100, 238), seed=12, blocks=(15,), tags=('gelo', 'arvore'))
def tree_pine_snow(sc, f):
    add_patch(sc, 'snow', 1.0, 26, 12)
    sc.add(Cylinder((0, 0, 0), 1.2, .26, .17, BARK))
    for k in range(5):
        z0 = .55 + .58 * k
        rad = 1.12 - .17 * k
        sc.add(Cylinder((0, 0, z0), .82, rad, .10, PINE_SNOW))
        for j in range(11):
            a = j / 11 * 6.283 + k * .7
            sc.add(Ellipsoid((math.cos(a) * rad * .9, math.sin(a) * rad * .9, z0 + .04), (.26, .26, .17), PINE_SNOW))
    sc.add(Cylinder((0, 0, 3.35), .55, .16, .01, PINE_SNOW))


@asset('nat_tree_birch', 'nature', 'trees', (200, 260), (100, 228), seed=13, blocks=(13,), tags=('campos', 'vale', 'arvore'))
def tree_birch(sc, f):
    add_patch(sc, 'grass', 1.0, 24, 13, nflowers=6, flowers=('white', 'yellow', 'blue'))
    limb(sc, (0, 0, 0), (.05, 0, 1.5), .2, .13, BARK_BIRCH)
    limb(sc, (.05, 0, 1.2), (.55, .1, 1.95), .1, .06, BARK_BIRCH)
    limb(sc, (.03, 0, 1.3), (-.5, -.15, 2.0), .1, .06, BARK_BIRCH)
    canopy(sc, (0, 0, 2.15), (.95, .95, .85), 44, LEAF_BIRCH, 13, size=.32, zsize=.26, lowest=1.4)


@asset('nat_tree_dead', 'nature', 'trees', (200, 260), (100, 232), seed=14, blocks=(12,), tags=('ruinas', 'deserto', 'arvore'))
def tree_dead(sc, f):
    add_patch(sc, 'dirt', .9, 22, 14)
    limb(sc, (0, 0, 0), (.05, .05, 1.6), .27, .12, BARK_DEAD)
    for (p, q, a, b) in [((.05, .05, 1.1), (.9, .3, 1.9), .12, .05), ((.05, .05, 1.3), (-.8, -.2, 2.2), .11, .045), ((.06, .05, 1.6), (.3, -.5, 2.6), .09, .04), ((.06, .05, 1.7), (-.2, .5, 2.55), .08, .035), ((.9, .3, 1.9), (1.3, .2, 2.5), .05, .025), ((-.8, -.2, 2.2), (-1.15, -.3, 2.85), .045, .02)]:
        limb(sc, p, q, a, b, BARK_DEAD)


@asset('nat_tree_palm', 'nature', 'trees', (220, 270), (110, 242), seed=15, blocks=(12,), tags=('deserto', 'oasis', 'arvore'))
def tree_palm(sc, f):
    add_patch(sc, 'sand', 1.0, 24, 15, nflowers=0)
    limb(sc, (0, 0, 0), (.35, .1, 2.2), .22, .13, BARK, step=.5)
    top = (.35, .1, 2.25)
    r = rng_for(15)
    for i in range(10):
        a = i / 10 * 6.283 + .3
        dx, dy = math.cos(a), math.sin(a)
        for j in range(1, 8):
            t = j / 7
            p = (top[0] + dx * t * 1.5, top[1] + dy * t * 1.5, top[2] + .42 * math.sin(t * 3.14 * .62) - t * t * .5)
            sc.add(Xform(Ellipsoid((0, 0, 0), (.3 * (1 - t * .45), .1 * (1 - t * .3), .05), PALM), (0, 0, math.degrees(a)), p))
            for sgn in (-1, 1):
                q = (p[0] - dy * sgn * .09, p[1] + dx * sgn * .09, p[2] - .04)
                sc.add(Xform(Ellipsoid((0, 0, 0), (.16 * (1 - t * .5), .06, .035), PALM), (0, 0, math.degrees(a) + sgn * 30), q))
    sc.add(Ellipsoid((top[0], top[1], top[2] - .1), (.2, .2, .2), BARK))
    for a in (.5, 2.4, 4.4):
        sc.add(Ellipsoid((top[0] + math.cos(a) * .16, top[1] + math.sin(a) * .16, top[2] - .22), (.1, .1, .1), LEATHER))


@asset('nat_bush_green', 'nature', 'bushes', (140, 110), (70, 82), seed=21, footprint=14, tags=('todos', 'arbusto'))
def bush_green(sc, f):
    canopy(sc, (0, 0, .42), (.6, .6, .3), 16, LEAF, 21, size=.3, zsize=.24, lowest=.12)
    add_patch(sc, 'grass', .6, 8, 21, nflowers=0)


@asset('nat_bush_flowering', 'nature', 'bushes', (140, 110), (70, 82), seed=22, footprint=14, tags=('campos', 'vale', 'arbusto'))
def bush_flowering(sc, f):
    canopy(sc, (0, 0, .42), (.6, .6, .3), 16, LEAF, 22, size=.3, zsize=.24, lowest=.12)
    r = rng_for(22)
    fm = [flower_mat('pink'), flower_mat('white'), flower_mat('yellow')]
    for i in range(14):
        a = r.uniform(0, 6.28); d = r.uniform(.1, .62); z = .35 + r.uniform(0, .3)
        sc.add(Ellipsoid((math.cos(a) * d, math.sin(a) * d, z + (.62 - d) * .35), (.09, .09, .08), fm[i % 3]))


@asset('nat_bush_berry', 'nature', 'bushes', (140, 110), (70, 82), seed=23, footprint=14, tags=('floresta', 'recurso', 'arbusto'))
def bush_berry(sc, f):
    canopy(sc, (0, 0, .42), (.6, .6, .3), 16, LEAF_BIRCH, 23, size=.3, zsize=.24, lowest=.12)
    r = rng_for(23)
    fm = flower_mat('red')
    for i in range(12):
        a = r.uniform(0, 6.28); d = r.uniform(.1, .6); z = .4 + r.uniform(0, .2)
        sc.add(Ellipsoid((math.cos(a) * d, math.sin(a) * d, z + (.62 - d) * .3), (.07, .07, .07), fm))


@asset('nat_bush_dry', 'nature', 'bushes', (140, 110), (70, 82), seed=24, footprint=12, tags=('deserto', 'arbusto'))
def bush_dry(sc, f):
    canopy(sc, (0, 0, .4), (.6, .6, .28), 15, LEAF_DRY, 24, size=.28, zsize=.2, lowest=.12)
    limb(sc, (0, 0, .1), (.3, .2, .6), .03, .02, BARK_DEAD)
    limb(sc, (0, 0, .1), (-.3, -.15, .55), .03, .02, BARK_DEAD)


@asset('nat_bush_frost', 'nature', 'bushes', (140, 110), (70, 82), seed=25, footprint=12, tags=('gelo', 'arbusto'))
def bush_frost(sc, f):
    m = Mat(LEAF.ramp, tex=tex_leaf(amp=.3, seed=7), ambient=.3, jitter=.1, tint=snow_tint(1.0), name='bush_frost')
    canopy(sc, (0, 0, .4), (.6, .6, .28), 15, m, 25, size=.28, zsize=.22, lowest=.12)


def _flower_patch(sc, seed, kinds, n=14):
    r = rng_for(seed)
    for k in range(4):
        a = r.uniform(0, 6.28); d = r.uniform(0, .45)
        tuft(sc, math.cos(a) * d, math.sin(a) * d, GRASS, seed + k, n=6, h=.32, spread=.1)
    fm = [flower_mat(k) for k in kinds]
    for i in range(n):
        a = r.uniform(0, 6.28); d = math.sqrt(r.uniform(0, 1)) * .55
        x, y = math.cos(a) * d, math.sin(a) * d
        h = r.uniform(.22, .42)
        blade(sc, x, y, h, (r.uniform(-10, 10), r.uniform(-10, 10)), GRASS, w=.02)
        sc.add(Ellipsoid((x, y, h + .02), (.075, .075, .06), fm[i % len(fm)]))
        sc.add(Ellipsoid((x, y, h + .06), (.03, .03, .03), GOLD))


@asset('nat_flowers_meadow', 'nature', 'flora', (110, 90), (55, 66), seed=31, tags=('campos', 'pradaria', 'flor'), shadow=False)
def flowers_meadow(sc, f):
    add_patch(sc, 'grass', .55, 12, 31, nflowers=0)
    _flower_patch(sc, 31, ['white', 'yellow', 'pink'])


@asset('nat_flowers_blue', 'nature', 'flora', (110, 90), (55, 66), seed=32, tags=('vale', 'flor'), shadow=False)
def flowers_blue(sc, f):
    add_patch(sc, 'grass', .55, 12, 32, nflowers=0)
    _flower_patch(sc, 32, ['blue', 'purple', 'white'])


@asset('nat_flowers_red', 'nature', 'flora', (110, 90), (55, 66), seed=33, tags=('floresta', 'flor'), shadow=False)
def flowers_red(sc, f):
    add_patch(sc, 'grass', .55, 12, 33, nflowers=0)
    _flower_patch(sc, 33, ['red', 'orange', 'yellow'])


@asset('nat_grass_tall', 'nature', 'flora', (110, 100), (55, 76), seed=34, tags=('todos', 'capim'), shadow=False)
def grass_tall(sc, f):
    r = rng_for(34)
    for k in range(6):
        a = r.uniform(0, 6.28); d = r.uniform(0, .4)
        tuft(sc, math.cos(a) * d, math.sin(a) * d, GRASS, 34 + k, n=8, h=.7, spread=.14)


@asset('nat_grass_dry', 'nature', 'flora', (110, 100), (55, 76), seed=35, tags=('deserto', 'capim'), shadow=False)
def grass_dry(sc, f):
    r = rng_for(35)
    for k in range(5):
        a = r.uniform(0, 6.28); d = r.uniform(0, .4)
        tuft(sc, math.cos(a) * d, math.sin(a) * d, GRASS_DRY, 35 + k, n=8, h=.6, spread=.14)


@asset('nat_reeds', 'nature', 'flora', (110, 130), (55, 108), seed=36, tags=('rio', 'junco'), shadow=False)
def reeds(sc, f):
    r = rng_for(36)
    for k in range(9):
        a = r.uniform(0, 6.28); d = r.uniform(0, .36)
        x, y = math.cos(a) * d, math.sin(a) * d
        h = r.uniform(.9, 1.5)
        blade(sc, x, y, h, (r.uniform(-8, 8), r.uniform(-8, 8)), REED, w=.045)
        if k % 2 == 0:
            sc.add(Ellipsoid((x, y, h - .04), (.06, .06, .18), REED_TOP))


@asset('nat_mushrooms', 'nature', 'flora', (110, 90), (55, 68), seed=37, tags=('floresta', 'cogumelo'), shadow=False)
def mushrooms(sc, f):
    add_patch(sc, 'grass', .5, 9, 37, nflowers=0)
    for (x, y, h, r) in [(0, 0, .34, .28), (.32, .12, .22, .18), (-.28, .2, .26, .2), (.1, -.3, .18, .14)]:
        sc.add(Cylinder((x, y, 0), h, .06, .045, MUSHROOM_STEM))
        sc.add(Ellipsoid((x, y, h), (r, r, r * .6), MUSHROOM_RED))
        sc.add(Ellipsoid((x + r * .3, y - r * .2, h + r * .45), (r * .16, r * .16, r * .08), MUSHROOM_STEM))


# ---------------------------------------------------------------- rochas
def _rock_asset(id, mat, size, origin, seed, radius, n, blocks, tags, patch=None, flat=.75):
    @asset(id, 'nature', 'rocks', size, origin, seed=seed, blocks=blocks, tags=tags)
    def build(sc, f):
        if patch:
            add_patch(sc, patch, radius * 1.1, 14, seed, nflowers=0)
        rock(sc, (0, 0, 0), radius, mat, seed, n=n, flat=flat)
    return build


_rock_asset('nat_rock_small', ROCK, (110, 90), (55, 68), 41, .38, 3, None, ('todos', 'pedra'), 'grass')
_rock_asset('nat_rock_medium', ROCK, (160, 130), (80, 100), 42, .65, 4, (13,), ('todos', 'pedra'), 'grass')
_rock_asset('nat_rock_boulder', ROCK_GREY, (230, 190), (115, 152), 43, 1.1, 5, (24,), ('obstaculo', 'pedra'), 'grass', flat=.85)
_rock_asset('nat_rock_mossy', ROCK_MOSS, (170, 140), (85, 108), 44, .72, 4, (14,), ('floresta', 'vale', 'pedra'), 'grass')
_rock_asset('nat_rock_ice', ROCK_ICE, (170, 140), (85, 108), 45, .72, 4, (14,), ('gelo', 'pedra'), 'snow')
_rock_asset('nat_rock_snow', ROCK_SNOW, (170, 140), (85, 108), 46, .72, 4, (14,), ('gelo', 'pedra'), 'snow')
_rock_asset('nat_rock_sand', ROCK_SAND, (170, 140), (85, 108), 47, .72, 4, (14,), ('deserto', 'pedra'), 'sand')
_rock_asset('nat_boulder_sand', ROCK_SAND, (230, 190), (115, 152), 48, 1.1, 5, (24,), ('deserto', 'obstaculo', 'pedra'), 'sand', flat=.9)
_rock_asset('nat_boulder_ice', ROCK_ICE, (230, 190), (115, 152), 49, 1.1, 5, (24,), ('gelo', 'obstaculo', 'pedra'), 'snow', flat=.9)


@asset('nat_log_fallen', 'nature', 'wood', (230, 130), (115, 96), seed=51, blocks=(16,), tags=('floresta', 'obstaculo', 'tronco'))
def log_fallen(sc, f):
    add_patch(sc, 'grass', .9, 10, 51, nflowers=0)
    rot = (0, 90, 30)
    pos = (-.85, -.35, .3)
    sc.add(Xform(Cylinder((0, 0, 0), 1.9, .3, .27, BARK), rot, pos))
    sc.add(Xform(Cylinder((0, 0, 1.9), .03, .27, .27, LOG_END), rot, pos))
    sc.add(Xform(Cylinder((0, 0, -.02), .03, .3, .3, LOG_END), rot, pos))
    for (x, y) in [(.0, -.05), (.35, .12)]:
        sc.add(Ellipsoid((x, y, .58), (.15, .12, .07), MUSHROOM_RED))


@asset('nat_stump', 'nature', 'wood', (130, 110), (65, 84), seed=52, blocks=(9,), tags=('floresta', 'tronco'))
def stump(sc, f):
    add_patch(sc, 'grass', .6, 8, 52, nflowers=0)
    sc.add(Cylinder((0, 0, 0), .45, .34, .28, BARK))
    sc.add(Cylinder((0, 0, .44), .02, .28, .28, LOG_END))
    for a in (.4, 2.2, 4.2):
        sc.add(Ellipsoid((math.cos(a) * .3, math.sin(a) * .3, .08), (.16, .12, .1), BARK))


@asset('nat_log_pile', 'nature', 'wood', (170, 130), (85, 100), seed=53, blocks=(14,), tags=('vila', 'floresta', 'tronco'))
def log_pile(sc, f):
    rot = (0, 90, 25)
    for (u, z) in [(-.36, .2), (0, .2), (.36, .2), (-.18, .56), (.18, .56), (0, .92)]:
        pos = (-.7 - u * -.42, u * .9 - .3, z)
        sc.add(Xform(Cylinder((0, 0, 0), 1.4, .19, .19, BARK), rot, pos))
        sc.add(Xform(Cylinder((0, 0, 1.4), .03, .19, .19, LOG_END), rot, pos))
