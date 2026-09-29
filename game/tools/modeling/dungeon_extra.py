"""Cavernas / Dungeon — módulos complementares (mesma paleta azul-violeta dos assets APPROVED)."""
from mats import *
from registry import asset


@asset('dg_pillar', 'dungeon', 'walls', (150, 250), (75, 222), seed=301, blocks=(11,), tags=('dungeon', 'coluna'), footprint=18)
def pillar(sc, f):
    sc.add(box((0, 0, .14), (.95, .95, .28), DSTONE, 0))
    sc.add(box((0, 0, 1.3), (.6, .6, 2.0), DSTONE, 0))
    sc.add(box((0, 0, 2.4), (.86, .86, .22), DSTONE, 0))
    sc.add(box((0, 0, .5), (.7, .7, .1), DSTONE, 0))
    for z in (1.0, 1.7):
        sc.add(box((0, -.3, z), (.16, .03, .3), GLOW_BLUE, 0))


@asset('dg_pillar_broken', 'dungeon', 'walls', (170, 170), (85, 142), seed=302, blocks=(11,), tags=('dungeon', 'coluna'), footprint=18)
def pillar_broken(sc, f):
    sc.add(box((0, 0, .14), (.95, .95, .28), DSTONE, 0))
    sc.add(box((0, 0, .8), (.6, .6, 1.0), DSTONE, 0))
    facet(sc, (0, 0, 1.3), .36, DSTONE_PLAIN, 302, squash=.5, nplanes=8)
    sc.add(Xform(box((0, 0, 0), (.6, .6, .9), DSTONE, 0), (0, 90, 35), (.5, .6, .3)))
    facet(sc, (-.65, .35, 0), .22, ROCK_GREY, 303, squash=.8, nplanes=8)


@asset('dg_portcullis', 'dungeon', 'walls', (240, 260), (120, 220), seed=304, blocks=(20,), tags=('dungeon', 'grade', 'portao'), footprint=24, frames=1)
def portcullis(sc, f):
    for u in (-.95, .95):
        sc.add(box((u, 0, 1.1), (.5, .6, 2.2), DSTONE, 0))
    for k in range(7):
        a = 3.14 * k / 6
        sc.add(Xform(box((0, 0, 0), (.36, .6, .3), DSTONE, 0), (0, math.degrees(a) - 90, 0), (-math.cos(a) * .95, 0, 2.2 + math.sin(a) * .5)))
    for u in (-.7, -.35, 0, .35, .7):
        sc.add(box((u, 0, 1.0), (.06, .06, 2.0), IRON, 0))
    for z in (.5, 1.1, 1.7):
        sc.add(box((0, 0, z), (1.5, .07, .07), IRON, 0))


SARC = Mat(ramp('#12101e', '#2a2640', '#463e62', '#6a6088', '#948ab0', '#c0b8d8'), tex=tex_speckle(9, .18, 12), ambient=.32, bump=(6, .9), name='sarc')


@asset('dg_sarcophagus', 'dungeon', 'props', (210, 160), (105, 128), seed=305, blocks=(16,), tags=('dungeon', 'sarcofago'), footprint=22)
def sarcophagus(sc, f):
    sc.add(box((0, 0, .3), (1.7, .8, .6), DSTONE, 0))
    sc.add(box((0, 0, .68), (1.8, .9, .16), DSTONE_PLAIN, 0))
    sc.add(Ellipsoid((0, 0, .8), (.8, .34, .14), DSTONE_PLAIN))
    sc.add(Ellipsoid((.6, 0, .95), (.16, .16, .14), BONE))
    for x in (-.4, 0, .4):
        sc.add(box((x, 0, .86), (.1, .5, .03), RUNE_GLOW, 0))
    sc.add(box((-.75, -.4, .74), (.12, .06, .3), BONE, 0))


@asset('dg_bones_pile', 'dungeon', 'props', (150, 110), (75, 82), seed=306, tags=('dungeon', 'ossos'), footprint=10, shadow=False)
def bones_pile(sc, f):
    rr = rng_for(306)
    for i in range(9):
        a = rr.uniform(0, 6.28)
        d = rr.uniform(0, .4)
        p = (math.cos(a) * d, math.sin(a) * d, .06)
        q = (p[0] + rr.uniform(-.3, .3), p[1] + rr.uniform(-.3, .3), .08 + rr.uniform(0, .1))
        limb(sc, p, q, .045, .045, BONE)
        sc.add(Ellipsoid(q, (.07, .07, .06), BONE))
    sc.add(Ellipsoid((.1, .05, .2), (.2, .17, .16), BONE))
    sc.add(Ellipsoid((.1, -.05, .14), (.09, .04, .05), VOID_))


VOID_ = Mat(ramp('#040208', '#0a0612', '#160c22'), ambient=1.0, name='void')


@asset('dg_brazier', 'dungeon', 'lighting', (150, 200), (75, 172), seed=307, frames=4, blocks=(9,), tags=('dungeon', 'fogo'), footprint=14)
def brazier(sc, f):
    sc.add(Cylinder((0, 0, 0), .16, .34, .26, DSTONE))
    sc.add(Cylinder((0, 0, .16), .8, .16, .14, DSTONE))
    sc.add(Cylinder((0, 0, .95), .34, .24, .44, IRON))
    sc.add(Ellipsoid((0, 0, 1.28), (.36, .36, .06), EMBER))
    ph = f / 4 * 6.283
    for k, (dx, dy, h) in enumerate([(0, 0, .7), (.1, .06, .5), (-.1, -.05, .45)]):
        hh = h * (1 + .18 * math.sin(ph + k * 1.7))
        sc.add(Ellipsoid((dx + .04 * math.sin(ph + k), dy, 1.28 + hh * .5), (.15 - k * .015, .15 - k * .015, hh * .55), FIRE))
    sc.glow.append((0, 0, 1.6, 66, (255, 150, 70), .85))


@asset('dg_rune_circle', 'dungeon', 'floors', (248, 140), (124, 70), seed=308, tags=('dungeon', 'runa', 'chao'), shadow=False, frames=2)
def rune_circle(sc, f):
    sc.add(box((0, 0, -.14), (2.9, 2.9, .28), DSTONE_PLAIN, 0))
    g = .8 + .2 * f
    sc.add(Cylinder((0, 0, 0), .02, 1.05, 1.05, DSTONE))
    sc.add(Cylinder((0, 0, .02), .015, .95 * g, .95 * g, RUNE_GLOW))
    sc.add(Cylinder((0, 0, .04), .015, .82 * g, .82 * g, DSTONE_PLAIN))
    sc.add(Cylinder((0, 0, .06), .015, .5 * g, .5 * g, RUNE_GLOW))
    sc.add(Cylinder((0, 0, .08), .015, .38 * g, .38 * g, DSTONE_PLAIN))
    for k in range(8):
        a = k / 8 * 6.283
        sc.add(box((math.cos(a) * .72, math.sin(a) * .72, .06), (.12, .05, .03), RUNE_GLOW, math.degrees(a)))
    sc.glow.append((0, 0, .1, 96, (140, 90, 255), .35 * g))


@asset('dg_stairs', 'dungeon', 'floors', (260, 200), (130, 160), seed=309, tags=('dungeon', 'escada'), blocks=(16,), footprint=24)
def dstairs(sc, f):
    for k in range(6):
        sc.add(box((k * .32 - .8, 0, (k * .16 + .16) / 2), (.32, 1.9, k * .16 + .16), DSTONE, 0))
    for sgn in (-1, 1):
        sc.add(box((0, sgn * 1.0, .5), (2.0, .16, 1.0), DSTONE, 0))


@asset('dg_boss_gate', 'dungeon', 'walls', (300, 300), (150, 256), seed=310, blocks=(26,), tags=('dungeon', 'boss', 'portao'), footprint=36, frames=2)
def boss_gate(sc, f):
    for u in (-1.2, 1.2):
        sc.add(box((u, 0, 1.4), (.7, .8, 2.8), DSTONE, 0))
        sc.add(box((u, 0, .16), (.95, 1.0, .32), DSTONE, 0))
    for k in range(9):
        a = 3.14 * k / 8
        sc.add(Xform(box((0, 0, 0), (.44, .8, .34), DSTONE, 0), (0, math.degrees(a) - 90, 0), (-math.cos(a) * 1.2, 0, 2.8 + math.sin(a) * .8)))
    sc.add(box((0, .12, 1.3), (1.9, .18, 2.5), WOOD_DARK_Y, 0))
    for z in (.5, 1.3, 2.1):
        sc.add(box((0, .0, z), (1.95, .06, .12), IRON, 0))
    sc.add(Ellipsoid((0, 0, 1.3), (.1, .1, .1), BONE))
    g = .8 + .2 * f
    for z in (.7, 1.3, 1.9):
        sc.add(box((-.6, -.0, z), (.4 * g, .05, .06), RUNE_GLOW, 0))
        sc.add(box((.6, 0, z), (.4 * g, .05, .06), RUNE_GLOW, 0))
    sc.add(box((0, -.02, 1.3), (.08, .06, 1.9), RUNE_GLOW, 0))
    sc.glow.append((0, 0, 1.4, 90, (150, 90, 255), .4 * g))


@asset('dg_mushroom_glow', 'dungeon', 'natural', (130, 130), (65, 100), seed=311, tags=('dungeon', 'cogumelo'), footprint=10, frames=2)
def mushroom_glow(sc, f):
    g = .85 + .15 * f
    for x, y, h, r in [(0, 0, .45, .34), (.34, .1, .3, .22), (-.3, .2, .34, .24), (.1, -.3, .22, .16)]:
        sc.add(Cylinder((x, y, 0), h, .07, .05, MUSHROOM_STEM))
        sc.add(Ellipsoid((x, y, h), (r * g, r * g, r * .6), GLOW_BLUE))
        sc.add(Ellipsoid((x + r * .3, y - r * .2, h + r * .4), (r * .18, r * .18, r * .09), GLOW_PURPLE))
    sc.glow.append((0, 0, .4, 56, (110, 150, 255), .6 * g))


@asset('dg_stalagmites', 'dungeon', 'natural', (170, 200), (85, 170), seed=312, blocks=(12,), tags=('dungeon', 'caverna'), footprint=16)
def stalagmites(sc, f):
    for k, (x, y, r, h) in enumerate([(0, 0, .34, 1.9), (.55, .25, .24, 1.2), (-.5, .2, .26, 1.4), (.1, -.5, .2, .9)]):
        crystal(sc, (x, y, 0), r, h, ROCK_GREY, 312 + k, sides=7, tip=.5)


@asset('dg_crystal_checkpoint', 'dungeon', 'lighting', (170, 260), (85, 226), seed=313, blocks=(14,), tags=('dungeon', 'checkpoint', 'cristal'), footprint=22, frames=2)
def crystal_checkpoint(sc, f):
    g = .85 + .15 * f
    sc.add(Cylinder((0, 0, 0), .2, 1.0, .9, DSTONE))
    sc.add(Cylinder((0, 0, .2), .02, .8, .8, RUNE_GLOW))
    sc.add(Cylinder((0, 0, .22), .02, .7, .7, DSTONE_PLAIN))
    crystal(sc, (0, 0, .24), .3, 2.0, GLOW_BLUE, 313, tip=.3)
    crystal(sc, (.36, .1, .24), .17, 1.05, GLOW_BLUE, 314, tip=.35, tilt=.12)
    crystal(sc, (-.34, .14, .24), .15, .9, GLOW_BLUE, 315, tip=.35, tilt=-.12)
    sc.glow.append((0, 0, 1.4, 92, (100, 170, 255), .55 * g))


@asset('dg_altar_dark', 'dungeon', 'props', (200, 190), (100, 156), seed=314, blocks=(16,), tags=('dungeon', 'altar'), footprint=26, frames=2)
def altar_dark(sc, f):
    g = .85 + .15 * f
    sc.add(box((0, 0, .1), (1.7, 1.7, .2), DSTONE, 0))
    sc.add(box((0, 0, .3), (1.3, 1.3, .2), DSTONE, 0))
    sc.add(box((0, 0, .65), (.8, .8, .5), DSTONE, 0))
    sc.add(box((0, 0, .94), (1.0, 1.0, .1), DSTONE_PLAIN, 0))
    for sgn in (-1, 1):
        sc.add(Cylinder((sgn * .7, sgn * .7, .2), .9, .1, .08, BONE))
        sc.add(Ellipsoid((sgn * .7, sgn * .7, 1.15), (.14, .14, .14), FIRE))
    sc.add(Ellipsoid((0, 0, 1.1), (.3 * g, .3 * g, .14), RUNE_GLOW))
    sc.glow.append((0, 0, 1.1, 66, (150, 90, 255), .8 * g))


@asset('dg_barrel_old', 'dungeon', 'props', (130, 130), (65, 104), seed=315, blocks=(10,), tags=('dungeon', 'barril'), footprint=12)
def barrel_old(sc, f):
    sc.add(Ellipsoid((0, 0, .34), (.3, .3, .34), WOOD_OLD))
    sc.add(Cylinder((0, 0, 0), .68, .27, .27, WOOD_OLD, cap_bottom=True))
    for z in (.14, .54):
        sc.add(Cylinder((0, 0, z), .05, .29, .29, IRON))


@asset('dg_crate_old', 'dungeon', 'props', (130, 120), (65, 98), seed=316, blocks=(10,), tags=('dungeon', 'caixa'), footprint=12)
def crate_old(sc, f):
    sc.add(box((0, 0, .3), (.7, .7, .6), WOOD_OLD, 12))
    for sg in (-1, 1):
        sc.add(box((sg * .3, 0, .3), (.08, .72, .62), WOOD_DARK, 12))
