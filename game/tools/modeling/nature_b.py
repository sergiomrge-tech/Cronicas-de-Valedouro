"""Natureza / Overworld — construções rurais, acampamentos, ruínas, marcos, recursos, obstáculos."""
from mats import *
from registry import asset


def fence(sc, length, mat_p, mat_r, axis='x', broken=False, h=.62):
    """Segmento de cerca de madeira centrado na origem, ao longo de X (axis='x') ou Y."""
    rot = 0 if axis == 'x' else 90
    ca, sa = math.cos(math.radians(rot)), math.sin(math.radians(rot))

    def P(u, v=0, z=0):
        return (u * ca - v * sa, u * sa + v * ca, z)
    for u in (-length / 2, length / 2):
        lean = 8 if (broken and u > 0) else 0
        sc.add(Xform(box((0, 0, 0), (.13, .13, h + .12), mat_p), (lean, 0, rot), P(u, 0, (h + .12) / 2)))
        sc.add(Ellipsoid(P(u, 0, h + .13), (.09, .09, .05), mat_p))
    for z in (.22, .46):
        if broken and z > .4:
            sc.add(box(P(-length * .32, 0, z), (length * .34, .07, .07) if axis == 'x' else (.07, length * .34, .07), mat_r, 0))
            continue
        sc.add(box(P(0, 0, z), (length, .07, .07) if axis == 'x' else (.07, length, .07), mat_r, 0))


for _ax, _sfx in (('x', 'a'), ('y', 'b')):
    @asset(f'nat_fence_wood_{_sfx}', 'nature', 'fences', (170, 110), (85, 88), seed=61, blocks=(10,), tags=('campos', 'vila', 'cerca'))
    def _f(sc, f, _ax=_ax):
        fence(sc, 1.5, WOOD, WOOD, _ax)

    @asset(f'nat_fence_broken_{_sfx}', 'nature', 'fences', (170, 110), (85, 88), seed=62, blocks=(8,), tags=('ruinas', 'cerca'))
    def _g(sc, f, _ax=_ax):
        fence(sc, 1.5, WOOD_OLD, WOOD_OLD, _ax, broken=True)

    @asset(f'nat_wall_low_{_sfx}', 'nature', 'fences', (180, 120), (90, 96), seed=63, blocks=(12,), tags=('campos', 'ruinas', 'muro'))
    def _w(sc, f, _ax=_ax):
        rot = 0 if _ax == 'x' else 90
        ca, sa = math.cos(math.radians(rot)), math.sin(math.radians(rot))
        for u, hh in [(-.55, .42), (0, .5), (.55, .38)]:
            sc.add(box((u * ca, u * sa, hh / 2), (.56, .32, hh), STONE_MOSS, rot))
        add_patch(sc, 'grass', .8, 8, 63, nflowers=2)


@asset('nat_gate_wood', 'nature', 'fences', (190, 130), (95, 104), seed=64, blocks=(10,), tags=('campos', 'portao'))
def gate_wood(sc, f):
    for u in (-.75, .75):
        sc.add(box((u, 0, .5), (.17, .17, 1.0), WOOD_DARK, 0))
        sc.add(Ellipsoid((u, 0, 1.03), (.12, .12, .07), WOOD_DARK))
    sc.add(box((0, 0, .95), (1.6, .14, .12), WOOD_DARK, 0))
    for u in (-.36, .36):
        for z in (.25, .45, .65):
            sc.add(box((u, 0, z), (.62, .06, .06), WOOD, 0))
    for u in (-.64, 0, .64):
        sc.add(box((u, 0, .45), (.06, .06, .5), WOOD, 0))


@asset('nat_signpost', 'nature', 'props', (120, 140), (60, 116), seed=65, blocks=(6,), tags=('rota', 'placa'))
def signpost(sc, f):
    add_patch(sc, 'grass', .5, 6, 65, nflowers=0)
    sc.add(box((0, 0, .7), (.13, .13, 1.4), WOOD_DARK, 0))
    sc.add(box((.22, 0, 1.15), (.72, .07, .26), WOOD, 0))
    sc.add(box((-.2, 0, .82), (.6, .07, .22), WOOD, 0))
    for u, z in ((.05, 1.15), (-.1, .82)):
        sc.add(box((u + .05, -.045, z), (.34, .01, .04), IRON, 0))


@asset('nat_hay_bale', 'nature', 'farm', (130, 100), (65, 76), seed=66, blocks=(11,), tags=('campos', 'fazenda'))
def hay_bale(sc, f):
    pos = (-.32, -.18, .42)
    sc.add(Xform(Cylinder((0, 0, 0), .8, .42, .42, HAY), (0, 90, 30), pos))
    sc.add(Xform(Cylinder((0, 0, .8), .02, .42, .42, HAY), (0, 90, 30), pos))
    for t in (.2, .6):
        sc.add(Xform(Cylinder((0, 0, t), .04, .43, .43, LEATHER), (0, 90, 30), pos))


@asset('nat_hay_stack', 'nature', 'farm', (150, 140), (75, 112), seed=67, blocks=(14,), tags=('campos', 'fazenda'))
def hay_stack(sc, f):
    add_patch(sc, 'dry', .8, 10, 67, nflowers=0)
    sc.add(Cylinder((0, 0, 0), .8, .68, .62, HAY))
    sc.add(Cylinder((0, 0, .78), .6, .66, .18, HAY))
    sc.add(Ellipsoid((0, 0, 1.38), (.2, .2, .16), HAY))


@asset('nat_cart_wood', 'nature', 'farm', (190, 140), (95, 108), seed=68, blocks=(16,), tags=('campos', 'vila', 'carroca'))
def cart_wood(sc, f):
    sc.add(box((0, 0, .42), (1.3, .8, .12), WOOD, 0))
    for sgn in (-1, 1):
        sc.add(box((0, sgn * .4, .62), (1.3, .07, .34), WOOD_DARK, 0))
    sc.add(box((.65, 0, .62), (.07, .8, .34), WOOD_DARK, 0))
    sc.add(box((-.65, 0, .62), (.07, .8, .34), WOOD_DARK, 0))
    for sgn in (-1, 1):
        sc.add(Xform(Cylinder((0, 0, 0), .07, .34, .34, WOOD_DARK, cap_bottom=True), (90, 0, 0), (0, sgn * .47 + .04, .34)))
        sc.add(Xform(Cylinder((0, 0, .06), .03, .07, .07, IRON), (90, 0, 0), (0, sgn * .47 + .04, .34)))
    sc.add(Xform(Cylinder((0, 0, 0), 1.0, .05, .05, WOOD), (0, 90, 0), (-1.55, 0, .45)))
    for x, y, z in [(.2, .1, .55), (-.25, -.1, .55), (.1, -.2, .6)]:
        sc.add(Ellipsoid((x, y, z + .1), (.22, .2, .2), HAY))


@asset('nat_scarecrow', 'nature', 'farm', (140, 190), (70, 166), seed=69, blocks=(7,), tags=('campos', 'fazenda', 'espantalho'))
def scarecrow(sc, f):
    add_patch(sc, 'dirt', .55, 9, 69)
    sc.add(box((0, 0, .8), (.09, .09, 1.6), WOOD_DARK, 0))
    sc.add(box((0, 0, 1.15), (1.15, .08, .08), WOOD_DARK, 0))
    sc.add(Ellipsoid((0, 0, 1.0), (.26, .2, .32), CLOTH_RED))
    sc.add(Ellipsoid((0, 0, 1.55), (.2, .2, .2), CLOTH_CREAM))
    sc.add(Cylinder((0, 0, 1.68), .16, .2, .14, LEATHER))
    sc.add(Cylinder((0, 0, 1.66), .03, .34, .34, LEATHER))
    for sgn in (-1, 1):
        sc.add(Ellipsoid((sgn * .55, 0, 1.1), (.14, .1, .16), HAY))


@asset('nat_campfire', 'nature', 'camp', (150, 150), (75, 112), seed=71, frames=4, blocks=(12,), tags=('acampamento', 'fogo'), footprint=18)
def campfire(sc, f):
    for i in range(8):
        a = i / 8 * 6.283
        facet(sc, (math.cos(a) * .55, math.sin(a) * .5, 0), .2, ROCK_GREY, 71 + i, squash=.8, nplanes=8)
    for a in (20, 100, 200):
        sc.add(Xform(Cylinder((0, 0, 0), .9, .1, .09, BARK_DEAD), (0, 80, a), (0, 0, .15)))
    sc.add(Ellipsoid((0, 0, .1), (.38, .38, .12), EMBER))
    ph = f / 4 * 6.283
    for k, (dx, dy, h) in enumerate([(0, 0, .8), (.12, .08, .55), (-.12, -.06, .5), (.02, -.14, .42)]):
        hh = h * (1 + .18 * math.sin(ph + k * 1.7))
        sc.add(Ellipsoid((dx + .05 * math.sin(ph + k), dy, .18 + hh * .5), (.17 - k * .015, .17 - k * .015, hh * .55), FIRE))
    sc.add(Ellipsoid((0, 0, .32), (.12, .12, .2), GLOW_GOLD))
    sc.glow.append((0, 0, .4, 62, (255, 160, 60), .9))


TENT_DOOR = Mat(ramp('#0a0610', '#140c1a', '#24162a'), ambient=.5, name='tent_door')


def tent(sc, cloth_main, cloth_alt, size=1.0):
    W, L, H = 1.5 * size, 1.7 * size, 1.2 * size
    sc.add(prism_roof((0, 0, 0), (L, W, H), cloth_main))
    sc.add(Ellipsoid((L * .5, 0, .34 * size), (.05, .32 * size, .34 * size), TENT_DOOR))
    for u in (-1, 1):
        sc.add(Cylinder((u * L * .5, 0, 0), H + .25 * size, .04, .03, WOOD_DARK))
    sc.add(box((0, 0, H + .02), (L * 1.05, .09, .08), cloth_alt, 0))


@asset('nat_tent_small', 'nature', 'camp', (200, 170), (100, 138), seed=72, blocks=(16,), tags=('acampamento', 'tenda'), footprint=26)
def tent_small(sc, f):
    add_patch(sc, 'dirt', 1.1, 16, 72)
    tent(sc, CLOTH_CREAM, CLOTH_RED)


@asset('nat_tent_red', 'nature', 'camp', (220, 190), (110, 152), seed=73, blocks=(18,), tags=('acampamento', 'tenda', 'deserto'), footprint=30)
def tent_red(sc, f):
    add_patch(sc, 'sand', 1.2, 16, 73, nflowers=0)
    tent(sc, CLOTH_RED, GOLD, 1.15)


@asset('nat_tent_frost', 'nature', 'camp', (200, 170), (100, 138), seed=74, blocks=(16,), tags=('acampamento', 'tenda', 'gelo'), footprint=26)
def tent_frost(sc, f):
    add_patch(sc, 'snow', 1.1, 16, 74)
    tent(sc, CLOTH_BLUE, CLOTH_CREAM)


@asset('nat_bedroll', 'nature', 'camp', (140, 100), (70, 78), seed=75, tags=('acampamento',), footprint=8)
def bedroll(sc, f):
    sc.add(Xform(box((0, 0, 0), (.9, .46, .07), CLOTH_GREEN, 0), (0, 0, 25), (0, 0, .04)))
    sc.add(Xform(Cylinder((0, 0, 0), 1.0, .2, .2, CLOTH_GREEN), (0, 90, 25), (-.5, -.3, .22)))
    sc.add(Xform(Ellipsoid((0, 0, 0), (.2, .26, .14), CLOTH_CREAM), (0, 0, 25), (.42, .1, .25)))


def chest(sc, opened=False, mat_body=WOOD_DARK):
    sc.add(box((0, 0, .21), (1.0, .62, .42), mat_body, 0))
    for u in (-.32, .32):
        sc.add(box((u, 0, .215), (.09, .65, .44), IRON, 0))
    if not opened:
        sc.add(box((0, 0, .48), (1.0, .62, .14), mat_body, 0))
        sc.add(Ellipsoid((0, 0, .55), (.5, .31, .16), mat_body))
        for u in (-.32, .32):
            sc.add(Ellipsoid((u, 0, .56), (.06, .32, .13), IRON))
        sc.add(box((.02, .33, .42), (.13, .05, .17), GOLD, 0))
    else:
        sc.add(Ellipsoid((0, 0, .44), (.44, .26, .05), GLOW_GOLD))
        for x, y, z, m in [(-.2, .02, .5, GOLD), (.15, -.05, .52, GLOW_GOLD), (0, .08, .55, GOLD)]:
            sc.add(Ellipsoid((x, y, z), (.1, .1, .07), m))
        sc.add(Xform(box((0, 0, 0), (1.0, .05, .5), mat_body, 0), (-70, 0, 0), (0, -.38, .78)))
        sc.glow.append((0, 0, .6, 46, (255, 210, 90), .7))


@asset('nat_chest_closed', 'nature', 'props', (150, 130), (75, 100), seed=76, blocks=(13,), tags=('bau',), footprint=14)
def chest_closed(sc, f):
    chest(sc, False)


@asset('nat_chest_open', 'nature', 'props', (150, 130), (75, 100), seed=77, blocks=(13,), tags=('bau',), footprint=14)
def chest_open(sc, f):
    chest(sc, True)


CHEST_RARE = Mat(ramp('#2a0a48', '#4a1a80', '#6a34b8', '#9a64e8', '#c8a0ff', '#f0e0ff'), tex=tex_wood_planks(6, .14, 31), ambient=.34, name='chest_rare')


@asset('nat_chest_rare', 'nature', 'props', (150, 130), (75, 100), seed=78, blocks=(13,), tags=('bau', 'raro'), footprint=14)
def chest_rare(sc, f):
    chest(sc, False, mat_body=CHEST_RARE)
    sc.glow.append((0, 0, .5, 56, (170, 110, 255), .7))


@asset('nat_well_stone', 'nature', 'props', (190, 220), (95, 184), seed=79, blocks=(18,), tags=('vila', 'poco'), footprint=26)
def well_stone(sc, f):
    add_patch(sc, 'grass', 1.0, 14, 79, nflowers=3)
    sc.add(Cylinder((0, 0, 0), .5, .62, .58, STONE_MOSS))
    sc.add(Cylinder((0, 0, .5), .02, .5, .5, WATER))
    for sgn in (-1, 1):
        sc.add(box((0, sgn * .55, .95), (.12, .12, 1.0), WOOD_DARK, 0))
    sc.add(prism_roof((0, 0, 1.4), (1.1, 1.6, .6), CLOTH_BLUE, rot=0))


def _flag(sc, f, mat):
    sc.add(Cylinder((0, 0, 0), 2.6, .08, .05, WOOD_DARK))
    sc.add(Ellipsoid((0, 0, 2.68), (.09, .09, .09), GOLD))
    sc.add(Cylinder((0, 0, 0), .12, .16, .13, STONE))
    ph = f / 4 * 6.283
    for i in range(9):
        t = i / 8
        y = .1 + t * 1.15
        z = 2.35 - t * .08 + math.sin(ph - t * 4.0) * .07 * (t + .2)
        x = math.sin(ph - t * 4.0 + 1.0) * .1 * t
        sc.add(box((x, y, z - .05 * t), (.05, .18, .62 - .12 * t), mat, 0))
    sc.add(box((0, .1, 2.35), (.03, .12, .64), GOLD, 0))


@asset('nat_flag_blue', 'nature', 'props', (150, 240), (75, 214), seed=81, frames=4, blocks=(6,), tags=('bandeira',), footprint=10)
def flag_blue(sc, f):
    _flag(sc, f, CLOTH_BLUE)


@asset('nat_flag_red', 'nature', 'props', (150, 240), (75, 214), seed=82, frames=4, blocks=(6,), tags=('bandeira',), footprint=10)
def flag_red(sc, f):
    _flag(sc, f, CLOTH_RED)


# --------------------------------------------------------------------------- ruínas
@asset('nat_ruin_column', 'nature', 'ruins', (150, 250), (75, 220), seed=91, blocks=(11,), tags=('ruinas', 'coluna'), footprint=18)
def ruin_column(sc, f):
    sc.add(box((0, 0, .12), (.9, .9, .24), STONE_MOSS, 0))
    sc.add(Cylinder((0, 0, .24), 1.9, .33, .29, STONE_MOSS))
    sc.add(box((0, 0, 2.28), (.78, .78, .18), STONE_MOSS, 0))
    sc.add(box((0, 0, 2.42), (.6, .6, .1), STONE_MOSS, 0))


@asset('nat_ruin_column_broken', 'nature', 'ruins', (190, 190), (95, 158), seed=92, blocks=(11,), tags=('ruinas', 'coluna'), footprint=18)
def ruin_column_broken(sc, f):
    add_patch(sc, 'grass', .9, 10, 92, nflowers=2)
    sc.add(box((0, 0, .12), (.9, .9, .24), STONE_MOSS, 0))
    sc.add(Cylinder((0, 0, .24), .95, .33, .3, STONE_MOSS))
    facet(sc, (0, 0, .95), .3, STONE_MOSS, 92, squash=.5, nplanes=8)
    sc.add(Xform(Cylinder((0, 0, 0), .8, .3, .3, STONE_MOSS), (0, 90, 40), (.6, .5, .3)))
    facet(sc, (-.6, .4, 0), .22, ROCK_MOSS, 93, squash=.8, nplanes=8)


@asset('nat_ruin_wall', 'nature', 'ruins', (240, 206), (120, 172), seed=93, blocks=(16,), tags=('ruinas', 'muro'), footprint=24)
def ruin_wall(sc, f):
    add_patch(sc, 'grass', 1.2, 10, 93, nflowers=2)
    rr = rng_for(93)
    for row in range(4):
        u = -.9
        while u < .9:
            w = rr.uniform(.3, .5)
            if row * .32 + rr.uniform(0, .25) < (1.35 - abs(u) * .7) and (row < 3 or rr.random() > .35):
                sc.add(box((u + w / 2, 0, row * .3 + .15), (w - .02, .34, .29), STONE_MOSS, 0))
            u += w
    for x, z in [(-.7, .02), (.75, .02)]:
        facet(sc, (x, .5, z), .2, ROCK_MOSS, 94 + int(x * 10), squash=.8, nplanes=8)


@asset('nat_ruin_arch', 'nature', 'ruins', (260, 282), (130, 248), seed=95, blocks=(14,), tags=('ruinas', 'arco'), footprint=30)
def ruin_arch(sc, f):
    add_patch(sc, 'grass', 1.4, 12, 95, nflowers=3)
    for u in (-.95, .95):
        sc.add(box((u, 0, .12), (.62, .62, .24), STONE_MOSS, 0))
        sc.add(box((u, 0, 1.2), (.44, .44, 2.0), STONE_MOSS, 0))
    for k in range(7):
        a = 3.14 * k / 6
        if k == 3:
            continue
        sc.add(Xform(box((0, 0, 0), (.36, .44, .26), STONE_MOSS, 0), (0, math.degrees(a) - 90, 0), (-math.cos(a) * .95, 0, 2.2 + math.sin(a) * .62)))
    facet(sc, (.5, .7, 0), .25, ROCK_MOSS, 96, squash=.8, nplanes=8)


@asset('nat_altar_ancient', 'nature', 'ruins', (200, 190), (100, 158), seed=97, blocks=(16,), tags=('ruinas', 'altar'), footprint=28, frames=2)
def altar_ancient(sc, f):
    sc.add(box((0, 0, .1), (1.7, 1.7, .2), STONE_MOSS, 0))
    sc.add(box((0, 0, .3), (1.3, 1.3, .2), STONE_MOSS, 0))
    sc.add(box((0, 0, .68), (.8, .8, .56), STONE_MOSS, 0))
    sc.add(box((0, 0, .98), (1.0, 1.0, .1), STONE, 0))
    g = .85 + .15 * math.sin(f * 3.14)
    sc.add(Ellipsoid((0, 0, 1.12), (.28 * g, .28 * g, .12), RUNE_GLOW))
    for a in (0, 1.57, 3.14, 4.71):
        sc.add(box((math.cos(a) * .55, math.sin(a) * .55, .38), (.1, .1, .05), RUNE_GLOW, 0))
    sc.glow.append((0, 0, 1.1, 60, (150, 100, 255), .9 * g))


@asset('nat_obelisk_rune', 'nature', 'ruins', (150, 290), (75, 256), seed=98, blocks=(10,), tags=('ruinas', 'obelisco'), footprint=20, frames=2)
def obelisk_rune(sc, f):
    sc.add(box((0, 0, .1), (.95, .95, .2), STONE_MOSS, 0))
    sc.add(Convex([((1, 0, 0), .28), ((-1, 0, 0), .28), ((0, 1, 0), .28), ((0, -1, 0), .28), ((0, 0, 1), 2.7), ((0, 0, -1), -.2), ((1, 0, .12), .35), ((-1, 0, .12), .35), ((0, 1, .12), .35), ((0, -1, .12), .35)], DSTONE, (0, 0, 1.4), (.6, .6, 2.6)))
    g = .85 + .15 * math.sin(f * 3.14)
    for z in (.7, 1.1, 1.5, 1.9):
        sc.add(box((0, -.26, z), (.14 * g, .03, .2), RUNE_GLOW, 0))
        sc.add(box((-.26, 0, z + .08), (.03, .14 * g, .2), RUNE_GLOW, 0))
    sc.add(Ellipsoid((0, 0, 2.65), (.1, .1, .12), RUNE_GLOW))
    sc.glow.append((0, 0, 1.6, 70, (150, 100, 255), .55))


@asset('nat_statue_guardian', 'nature', 'ruins', (170, 270), (85, 236), seed=99, blocks=(12,), tags=('ruinas', 'estatua'), footprint=20)
def statue_guardian(sc, f):
    sc.add(box((0, 0, .18), (.95, .95, .36), STONE_MOSS, 0))
    sc.add(box((-.14, 0, .85), (.2, .22, .9), STONE_MOSS, 0))
    sc.add(box((.14, 0, .85), (.2, .22, .9), STONE_MOSS, 0))
    sc.add(box((0, 0, 1.55), (.55, .34, .62), STONE_MOSS, 0))
    sc.add(Ellipsoid((0, 0, 2.05), (.2, .2, .22), STONE_MOSS))
    sc.add(Cylinder((0, 0, 2.2), .12, .22, .18, STONE_MOSS))
    for sgn in (-1, 1):
        sc.add(box((sgn * .38, 0, 1.55), (.16, .2, .55), STONE_MOSS, 0))
    sc.add(box((-.5, .1, 1.35), (.12, .5, .7), STONE_MOSS, 0))
    sc.add(box((.5, 0, 1.6), (.1, .1, 1.3), STONE_MOSS, 0))
    sc.add(Ellipsoid((.5, 0, 2.3), (.08, .08, .14), STONE_MOSS))
    sc.add(Ellipsoid((0, -.15, 2.05), (.16, .05, .05), RUNE_GLOW))


# --------------------------------------------------------------------------- deserto / gelo
@asset('nat_dune_small', 'nature', 'desert', (330, 190), (165, 112), seed=101, tags=('deserto', 'duna'), shadow=False)
def dune_small(sc, f):
    add_patch(sc, 'sand', 1.9, 30, 101, nflowers=0, sizescale=1.3)
    sc.add(Ellipsoid((0, 0, 0), (1.6, 1.0, .5), SAND_DUNE))
    sc.add(Ellipsoid((.8, .3, 0), (.9, .7, .32), SAND_DUNE))


@asset('nat_dune_large', 'nature', 'desert', (500, 270), (250, 160), seed=102, tags=('deserto', 'duna', 'obstaculo'), blocks=(40,), shadow=False)
def dune_large(sc, f):
    add_patch(sc, 'sand', 3.0, 46, 102, nflowers=0, sizescale=1.7)
    sc.add(Ellipsoid((0, 0, 0), (2.4, 1.6, .95), SAND_DUNE))
    sc.add(Ellipsoid((1.1, .5, 0), (1.3, 1.0, .62), SAND_DUNE))
    sc.add(Ellipsoid((-1.0, -.4, 0), (1.1, .8, .5), SAND_DUNE))


@asset('nat_cactus_tall', 'nature', 'desert', (170, 240), (85, 212), seed=103, blocks=(9,), tags=('deserto', 'cacto'), footprint=14)
def cactus_tall(sc, f):
    add_patch(sc, 'sand', .7, 10, 103, nflowers=0)
    sc.add(Cylinder((0, 0, 0), 1.9, .24, .22, CACTUS_R))
    sc.add(Ellipsoid((0, 0, 1.9), (.22, .22, .22), CACTUS_R))
    for sgn, z in ((-1, 1.0), (1, 1.35)):
        sc.add(Xform(Cylinder((0, 0, 0), .5, .13, .13, CACTUS_R), (0, 90, 0 if sgn > 0 else 180), (0, 0, z)))
        sc.add(Cylinder((sgn * .55, 0, z - .02), .7, .13, .12, CACTUS_R))
        sc.add(Ellipsoid((sgn * .55, 0, z + .68), (.12, .12, .12), CACTUS_R))
    sc.add(Ellipsoid((.05, -.05, 2.1), (.07, .07, .05), flower_mat('pink')))


@asset('nat_cactus_round', 'nature', 'desert', (130, 120), (65, 92), seed=104, blocks=(8,), tags=('deserto', 'cacto'), footprint=12)
def cactus_round(sc, f):
    add_patch(sc, 'sand', .5, 8, 104, nflowers=0)
    sc.add(Ellipsoid((0, 0, .28), (.34, .34, .3), CACTUS_R))
    sc.add(Ellipsoid((.36, .12, .2), (.2, .2, .19), CACTUS_R))
    sc.add(Ellipsoid((0, 0, .58), (.09, .09, .05), flower_mat('yellow')))


@asset('nat_bones_desert', 'nature', 'desert', (170, 120), (85, 92), seed=105, tags=('deserto', 'ossos'), footprint=10)
def bones_desert(sc, f):
    add_patch(sc, 'sand', .8, 10, 105, nflowers=0)
    limb(sc, (-.5, -.2, .1), (.5, .2, .12), .05, .05, BONE)
    for k in range(5):
        u = -.35 + k * .2
        cx, cy = u, u * .4
        for t in range(7):
            a = 3.14 * t / 6
            sc.add(Ellipsoid((cx - math.sin(a) * .14, cy + math.cos(a) * .32 - .12, .1 + math.sin(a) * .34), (.04, .04, .04), BONE))
    sc.add(Ellipsoid((.7, .3, .18), (.2, .17, .16), BONE))
    sc.add(Ellipsoid((.85, .37, .12), (.1, .1, .09), BONE))


@asset('nat_snow_mound', 'nature', 'ice', (250, 150), (125, 90), seed=111, tags=('gelo', 'neve'), shadow=False)
def snow_mound(sc, f):
    add_patch(sc, 'snow', 1.3, 22, 111, sizescale=1.2)
    sc.add(Ellipsoid((0, 0, 0), (1.0, .7, .4), SNOWBASE))
    sc.add(Ellipsoid((.5, .2, 0), (.6, .45, .3), SNOWBASE))


@asset('nat_ice_spire', 'nature', 'ice', (170, 230), (85, 194), seed=112, blocks=(12,), tags=('gelo', 'cristal'), footprint=18)
def ice_spire(sc, f):
    add_patch(sc, 'snow', .9, 12, 112)
    for k, (x, y, r, h, t) in enumerate([(0, 0, .3, 2.1, 0), (.5, .22, .2, 1.3, .1), (-.45, .2, .22, 1.5, -.1), (.1, -.48, .16, .9, .05)]):
        crystal(sc, (x, y, 0), r, h, CRYSTAL_ICE, 112 + k, tilt=t, tip=.3)


@asset('nat_ice_stones', 'nature', 'ice', (200, 130), (100, 100), seed=116, tags=('gelo', 'rio', 'travessia'), shadow=False)
def ice_stones(sc, f):
    for x, y, r in [(-.9, -.5, .42), (-.3, -.1, .4), (.3, .2, .4), (.9, .55, .42)]:
        facet(sc, (x, y, 0), r, ROCK_ICE, int(x * 100) + 116, squash=.35, nplanes=8)


@asset('nat_ford_stones', 'nature', 'rocks', (220, 140), (110, 100), seed=117, tags=('rio', 'travessia', 'vau'), shadow=False)
def ford_stones(sc, f):
    for x, y in [(-.7, -.1), (.1, .5), (.6, -.1)]:
        sc.add(Ellipsoid((x, y, .03), (.35, .28, .04), WATER))
    for x, y, r in [(-1.0, -.55, .4), (-.35, -.15, .42), (.3, .2, .4), (.95, .55, .38)]:
        facet(sc, (x, y, 0), r, ROCK_MOSS, int(x * 100) + 117, squash=.45, nplanes=8)


# --------------------------------------------------------------------------- recursos / armadilhas
@asset('nat_res_ore', 'nature', 'resources', (150, 140), (75, 108), seed=121, blocks=(12,), tags=('recurso', 'minerio'), footprint=14)
def res_ore(sc, f):
    add_patch(sc, 'grass', .8, 8, 121, nflowers=0)
    facet(sc, (0, 0, 0), .55, ORE, 121, squash=.85)
    for k, (x, y, r, h) in enumerate([(.08, -.1, .14, .9), (-.22, .1, .1, .6), (.28, .18, .09, .5)]):
        crystal(sc, (x, y, .18), r, h, CRYSTAL_GOLD, 122 + k, tip=.35)
    sc.glow.append((0, 0, .5, 46, (255, 200, 90), .5))


@asset('nat_res_herb', 'nature', 'resources', (130, 130), (65, 100), seed=123, tags=('recurso', 'erva'), footprint=10, shadow=False)
def res_herb(sc, f):
    add_patch(sc, 'grass', .55, 9, 123, nflowers=0)
    r = rng_for(123)
    for k in range(7):
        a = r.uniform(0, 6.28)
        d = r.uniform(0, .3)
        limb(sc, (math.cos(a) * d, math.sin(a) * d, 0), (math.cos(a) * (d + .15), math.sin(a) * (d + .15), .45), .035, .03, GRASS)
        sc.add(Ellipsoid((math.cos(a) * (d + .15), math.sin(a) * (d + .15), .5), (.11, .11, .09), GLOW_BLUE if k % 2 else flower_mat('white')))
    tuft(sc, 0, 0, GRASS, 124, n=8, h=.45, spread=.15)
    sc.glow.append((0, 0, .5, 40, (120, 200, 255), .5))


@asset('nat_res_crystal', 'nature', 'resources', (150, 150), (75, 118), seed=125, blocks=(12,), tags=('recurso', 'cristal'), footprint=14)
def res_crystal(sc, f):
    add_patch(sc, 'dirt', .8, 9, 125)
    facet(sc, (0, 0, 0), .45, ROCK_GREY, 125, squash=.7)
    for k, (x, y, r, h) in enumerate([(.0, -.05, .17, 1.3), (-.25, .12, .12, .8), (.3, .12, .11, .7), (.1, .3, .09, .5)]):
        crystal(sc, (x, y, .12), r, h, CRYSTAL_GREEN, 126 + k, tip=.35)
    sc.glow.append((0, 0, .6, 50, (100, 255, 150), .55))


VOID = Mat(ramp('#040208', '#0a0612', '#160c22'), ambient=1.0, name='void')


@asset('nat_fissure', 'nature', 'traps', (240, 140), (120, 100), seed=131, tags=('fenda', 'obstaculo'), shadow=False, blocks=(20,))
def fissure(sc, f):
    for k in range(9):
        t = k / 8
        x = -1.1 + t * 2.2
        y = math.sin(t * 5) * .2
        sc.add(Ellipsoid((x, y, -.02), (.34 - abs(t - .5) * .25, .16 - abs(t - .5) * .1, .05), VOID))
        sc.add(Ellipsoid((x, y, 0), (.16, .05, .05), GLOW_PURPLE))
    for x, y, r in [(-1.1, .2, .2), (.2, .3, .22), (1.0, -.1, .2), (-.3, -.3, .18)]:
        facet(sc, (x, y, 0), r, ROCK_GREY, int(x * 10) + 131, squash=.6, nplanes=7)


@asset('nat_pit_trap', 'nature', 'traps', (200, 130), (100, 96), seed=132, tags=('armadilha',), shadow=False, footprint=16)
def pit_trap(sc, f):
    sc.add(Ellipsoid((0, 0, -.02), (.7, .62, .05), VOID))
    for k in range(10):
        a = k / 10 * 6.283
        facet(sc, (math.cos(a) * .65, math.sin(a) * .6, 0), .26, ROCK, 132 + k, squash=.5, nplanes=7)
    for k in range(5):
        a = k / 5 * 6.283
        sc.add(Cylinder((math.cos(a) * .28, math.sin(a) * .26, 0), .34, .05, .008, IRON))
    sc.add(Cylinder((0, 0, 0), .4, .05, .008, IRON))


@asset('nat_trap_plate', 'nature', 'traps', (160, 100), (80, 72), seed=133, tags=('armadilha',), shadow=False, footprint=10, frames=2)
def trap_plate(sc, f):
    sc.add(box((0, 0, .04), (.95, .95, .08), DSTONE_PLAIN, 0))
    g = .8 + .2 * f
    sc.add(box((0, 0, .1), (.6, .6, .04), RUNE_GLOW if f else DSTONE, 0))
    sc.add(Ellipsoid((0, 0, .12), (.14 * g, .14 * g, .03), RUNE_GLOW))
