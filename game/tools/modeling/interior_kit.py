"""Interiores / Serviços — pisos, paredes, mobília e estações de trabalho (guilda, ferreiro, alquimia, loja, taverna)."""
from mats import *
from registry import asset

CARPET = Mat(ramp('#3a0a1a', '#6e1428', '#a42440', '#cc4a5a', '#e8808a', '#ffb4b4'), tex=tex_speckle(24, .12, 40), ambient=.5, zshade=0, name='carpet')
INT_STONE = Mat(ramp('#2a2430', '#4a4050', '#786a70', '#a89488', '#ccb8a0', '#eadcc0'), tex=tex_stone_blocks(2.4, .2, 42, joints=True), ambient=.5, zshade=0, bump=(6, .5), name='int_stone')
BOTTLE_RED = Mat(ramp('#4a0a24', '#8a1638', '#c8264a', '#ff6a7a', '#ffc0c8', '#ffffff'), emissive=.55, ambient=.5, name='bottle_red')
BOTTLE_GREEN = Mat(ramp('#0a4a30', '#1a8a48', '#3cc868', '#84f098', '#c8ffd4', '#ffffff'), emissive=.55, ambient=.5, name='bottle_green')
BOTTLE_BLUE = Mat(ramp('#0a1a58', '#1a3aa0', '#3a78e0', '#7ab4ff', '#c0e4ff', '#ffffff'), emissive=.55, ambient=.5, name='bottle_blue')
BOOK_MATS = [CLOTH_RED, CLOTH_BLUE, CLOTH_GREEN, LEATHER, CLOTH_PURPLE, CLOTH_CREAM]
PAPER = Mat(ramp('#8a7a5a', '#c8b88a', '#eadcae', '#fbf0c8', '#fffbe6', '#ffffff'), ambient=.6, name='paper')


def floor_tile(sc, mat):
    sc.add(box((0, 0, -.15), (2.92, 2.92, .3), mat, 0))


@asset('int_floor_wood', 'interior', 'floors', (248, 140), (124, 70), seed=401, shadow=False, tags=('interior', 'chao'))
def floor_wood(sc, f):
    floor_tile(sc, FLOORWOOD)


@asset('int_floor_wood_dark', 'interior', 'floors', (248, 140), (124, 70), seed=402, shadow=False, tags=('interior', 'chao'))
def floor_wood_dark(sc, f):
    floor_tile(sc, Mat(WOOD_DARK.ramp, tex=tex_wood_planks(5, .16, 32, 'y'), ambient=.5, zshade=0, name='floor_dark'))


@asset('int_floor_stone', 'interior', 'floors', (248, 140), (124, 70), seed=403, shadow=False, tags=('interior', 'chao', 'ferreiro'))
def floor_stone(sc, f):
    floor_tile(sc, INT_STONE)


@asset('int_floor_carpet', 'interior', 'floors', (248, 140), (124, 70), seed=404, shadow=False, tags=('interior', 'chao'))
def floor_carpet(sc, f):
    sc.add(box((0, 0, -.15), (2.92, 2.92, .3), FLOORWOOD, 0))
    sc.add(box((0, 0, .015), (2.3, 2.3, .03), CARPET, 0))
    sc.add(box((0, 0, .03), (1.9, 1.9, .03), Mat(GOLD.ramp, ambient=.6, zshade=0, name='trim'), 0))
    sc.add(box((0, 0, .045), (1.8, 1.8, .03), CARPET, 0))


# --------------------------------------------------------------------------- paredes
def wall(sc, axis='x', kind='plain'):
    L, T, H = 2.92, .3, 2.5
    rot = 0 if axis == 'x' else 90
    ca, sa = math.cos(math.radians(rot)), math.sin(math.radians(rot))

    def P(u, v, z):
        return (u * ca - v * sa, u * sa + v * ca, z)
    sc.add(box(P(0, 0, H / 2), (L, T, H) if axis == 'x' else (T, L, H), PLASTER, 0))
    for u in (-L / 2 + .09, L / 2 - .09):
        sc.add(box(P(u, 0, H / 2), (.18, T + .06, H) if axis == 'x' else (T + .06, .18, H), WOOD_DARK_Y if axis == 'x' else WOOD_DARK, 0))
    for z in (.1, H - .1):
        sc.add(box(P(0, 0, z), (L, T + .06, .2) if axis == 'x' else (T + .06, L, .2), WOOD_DARK, 0))
    sc.add(box(P(0, 0, H * .5), (.14, T + .05, H * .75) if axis == 'x' else (T + .05, .14, H * .75), WOOD_DARK, 0))
    sc.add(box(P(0, 0, .3), (L, T + .04, .06) if axis == 'x' else (T + .04, L, .06), WOOD_DARK, 0))
    if kind == 'window':
        sc.add(box(P(.55, 0, 1.45), (.75, T + .1, .85) if axis == 'x' else (T + .1, .75, .85), WOOD_DARK, 0))
        sc.add(box(P(.55, 0, 1.45), (.6, T + .14, .7) if axis == 'x' else (T + .14, .6, .7), GLASS_BLUE, 0))
        sc.add(box(P(.55, 0, 1.45), (.05, T + .16, .7) if axis == 'x' else (T + .16, .05, .7), WOOD_DARK, 0))
        sc.glow.append((P(.55, 0, 1.45)[0], P(.55, 0, 1.45)[1], 1.45, 40, (120, 170, 255), .25))
    if kind == 'door':
        sc.add(box(P(0, 0, 1.0), (.95, T + .1, 2.0) if axis == 'x' else (T + .1, .95, 2.0), WOOD_DARK, 0))
        sc.add(box(P(0, 0, 1.0), (.8, T + .14, 1.86) if axis == 'x' else (T + .14, .8, 1.86), WOOD, 0))
        sc.add(Ellipsoid(P(.28, .12 if axis == 'x' else 0, 1.0) if axis == 'x' else P(.28, 0, 1.0), (.05, .05, .05), GOLD))


for _ax, _s in (('x', 'a'), ('y', 'b')):
    for _kind in ('plain', 'window', 'door'):
        @asset(f'int_wall_{_kind}_{_s}', 'interior', 'walls', (200, 230), (100, 196), seed=410, shadow=False, tags=('interior', 'parede'), blocks=(12,))
        def _w(sc, f, _ax=_ax, _kind=_kind):
            wall(sc, _ax, _kind)


# --------------------------------------------------------------------------- mobília / estações
@asset('int_counter', 'interior', 'furniture', (230, 170), (115, 138), seed=421, blocks=(20,), tags=('loja', 'guilda', 'balcao'), footprint=24)
def counter(sc, f):
    sc.add(box((0, 0, .45), (2.0, .75, .9), WOOD_DARK, 0))
    sc.add(box((0, 0, .93), (2.15, .9, .1), WOOD, 0))
    sc.add(box((0, -.38, .5), (1.8, .04, .55), WOOD, 0))
    for x in (-.6, .1, .7):
        sc.add(box((x, .05, 1.06), (.3, .25, .16), PAPER, 0))
    sc.add(Cylinder((.85, -.15, .98), .2, .07, .06, GLOW_GOLD))
    sc.add(Cylinder((-.85, .1, .98), .14, .09, .09, BOTTLE_RED))


def shelf_case(sc, mat=WOOD_DARK, zs=(.5, 1.1, 1.7)):
    """Estante aberta: fundo + laterais + tábuas (a frente visível é +Y)."""
    sc.add(box((0, -.17, 1.05), (1.4, .07, 2.1), mat, 0))
    for x in (-.68, .68):
        sc.add(box((x, 0, 1.05), (.07, .42, 2.1), mat, 0))
    sc.add(box((0, 0, 2.08), (1.45, .46, .08), mat, 0))
    for z in zs:
        sc.add(box((0, 0, z), (1.32, .42, .07), WOOD, 0))


@asset('int_shelf_goods', 'interior', 'furniture', (170, 230), (85, 192), seed=422, blocks=(14,), tags=('loja', 'estante'), footprint=18)
def shelf_goods(sc, f):
    shelf_case(sc)
    rr = rng_for(422)
    mats = [CLOTH_RED, CLOTH_BLUE, HAY, LEATHER, CLOTH_GREEN]
    for z in (.55, 1.15, 1.75):
        for i in range(4):
            x = -.5 + i * .33
            sc.add(box((x, .02, z + .13), (.24, .26, .2), mats[int(rr.integers(0, 5))], 0))


@asset('int_shelf_potions', 'interior', 'furniture', (170, 230), (85, 192), seed=423, blocks=(14,), tags=('alquimia', 'estante'), footprint=18)
def shelf_potions(sc, f):
    shelf_case(sc)
    bottle = [BOTTLE_RED, BOTTLE_GREEN, BOTTLE_BLUE]
    for k, z in enumerate((.5, 1.1, 1.7)):
        for i in range(5):
            x = -.55 + i * .275
            m = bottle[(i + k) % 3]
            sc.add(Cylinder((x, .05, z + .04), .2, .07, .07, m))
            sc.add(Ellipsoid((x, .05, z + .27), (.06, .06, .06), m))
            sc.add(Cylinder((x, .05, z + .3), .06, .025, .025, WOOD))


@asset('int_bookshelf', 'interior', 'furniture', (170, 230), (85, 192), seed=424, blocks=(14,), tags=('guilda', 'estante'), footprint=18)
def bookshelf(sc, f):
    shelf_case(sc)
    rr = rng_for(424)
    for z in (.5, 1.1, 1.7):
        x = -.6
        while x < .6:
            w = rr.uniform(.08, .15)
            h = rr.uniform(.32, .5)
            sc.add(box((x + w / 2, .03, z + .04 + h / 2), (w, .28, h), BOOK_MATS[int(rr.integers(0, 6))], 0))
            x += w + .01


@asset('int_table_round', 'interior', 'furniture', (170, 150), (85, 122), seed=425, blocks=(14,), tags=('taverna', 'mesa'), footprint=18)
def table_round(sc, f):
    sc.add(Cylinder((0, 0, 0), .7, .12, .1, WOOD_DARK))
    sc.add(Cylinder((0, 0, .68), .08, .7, .7, WOOD))
    sc.add(Cylinder((.2, .1, .76), .16, .07, .06, GOLD))
    sc.add(Ellipsoid((.2, .1, .96), (.05, .05, .08), FIRE))
    sc.add(Cylinder((-.25, -.1, .76), .12, .09, .08, BOTTLE_RED))


@asset('int_table_long', 'interior', 'furniture', (250, 160), (125, 130), seed=426, blocks=(18,), tags=('taverna', 'mesa'), footprint=22)
def table_long(sc, f):
    sc.add(box((0, 0, .68), (2.2, .8, .1), WOOD, 0))
    for x in (-.9, .9):
        for y in (-.3, .3):
            sc.add(box((x, y, .32), (.1, .1, .64), WOOD_DARK, 0))
    for x in (-.6, .1, .7):
        sc.add(Cylinder((x, 0, .73), .1, .09, .07, WOOD_DARK))
    sc.add(Cylinder((.3, .15, .73), .18, .09, .09, IRON))


@asset('int_chair', 'interior', 'furniture', (110, 140), (55, 112), seed=427, blocks=(7,), tags=('taverna', 'cadeira'), footprint=9)
def chair(sc, f):
    sc.add(box((0, 0, .38), (.5, .5, .08), WOOD, 0))
    for x in (-.2, .2):
        for y in (-.2, .2):
            sc.add(box((x, y, .17), (.07, .07, .34), WOOD_DARK, 0))
    sc.add(box((0, -.23, .72), (.5, .07, .55), WOOD, 0))


@asset('int_stool', 'interior', 'furniture', (90, 100), (45, 80), seed=428, blocks=(6,), tags=('taverna', 'banco'), footprint=8)
def stool(sc, f):
    sc.add(Cylinder((0, 0, 0), .34, .18, .2, WOOD_DARK))
    sc.add(Cylinder((0, 0, .32), .07, .26, .26, WOOD))


@asset('int_bed', 'interior', 'furniture', (200, 170), (100, 138), seed=429, blocks=(18,), tags=('estalagem', 'cama'), footprint=22)
def bed(sc, f):
    sc.add(box((0, 0, .25), (1.0, 1.9, .3), WOOD_DARK, 0))
    sc.add(box((0, -.9, .62), (1.05, .1, .8), WOOD_DARK, 0))
    sc.add(box((0, 0, .5), (.9, 1.75, .2), CLOTH_CREAM, 0))
    sc.add(box((0, .3, .62), (.92, 1.2, .1), CLOTH_BLUE, 0))
    sc.add(Ellipsoid((0, -.62, .66), (.34, .22, .1), CLOTH_CREAM))


@asset('int_anvil', 'interior', 'furniture', (150, 150), (75, 122), seed=430, blocks=(12,), tags=('ferreiro', 'bigorna'), footprint=16)
def anvil(sc, f):
    sc.add(Cylinder((0, 0, 0), .45, .3, .27, BARK))
    sc.add(Cylinder((0, 0, .44), .03, .28, .28, LOG_END))
    sc.add(box((0, 0, .58), (.5, .3, .22), IRON, 0))
    sc.add(box((0, 0, .74), (.85, .3, .1), IRON, 0))
    sc.add(Convex([((1, 0, 0), .6), ((-1, 0, 0), -.4), ((0, 1, 0), .15), ((0, -1, 0), .15), ((0, 0, 1), .79), ((0, 0, -1), -.69), ((.7, 0, .7), .8)], IRON, (.5, 0, .74), (.4, .3, .1)))


@asset('int_forge', 'interior', 'furniture', (250, 280), (125, 226), seed=431, blocks=(24,), tags=('ferreiro', 'forja'), footprint=30, frames=4)
def forge(sc, f):
    sc.add(box((0, 0, .5), (1.9, 1.2, 1.0), STONE, 0))
    sc.add(box((0, 0, 1.05), (2.0, 1.3, .1), STONE_PLAIN, 0))
    sc.add(box((0, -.25, 1.85), (.9, .7, 1.7), STONE, 0))
    sc.add(box((0, -.25, 2.8), (.6, .5, .3), STONE_PLAIN, 0))
    sc.add(box((0, .62, .6), (1.1, .06, .5), VOID_I, 0))
    ph = f / 4 * 6.283
    for k, (x, h) in enumerate([(-.3, .4), (0, .55), (.3, .38)]):
        hh = h * (1 + .15 * math.sin(ph + k * 2))
        sc.add(Ellipsoid((x, .64, .55 + hh * .4), (.13, .06, hh * .5), FIRE))
    sc.add(box((.9, .5, .3), (.05, .05, .5), IRON, 0))
    sc.add(Ellipsoid((0, .0, 1.15), (.5, .35, .07), EMBER))
    sc.glow.append((0, .5, .7, 80, (255, 140, 60), .8))


VOID_I = Mat(ramp('#0a0408', '#160a10', '#241218'), ambient=1.0, name='forge_void')


@asset('int_workbench', 'interior', 'furniture', (220, 160), (110, 130), seed=432, blocks=(18,), tags=('ferreiro', 'bancada'), footprint=22)
def workbench(sc, f):
    sc.add(box((0, 0, .5), (1.8, .8, .1), WOOD, 0))
    for x in (-.8, .8):
        for y in (-.3, .3):
            sc.add(box((x, y, .25), (.1, .1, .5), WOOD_DARK, 0))
    sc.add(box((-.4, 0, .6), (.5, .12, .1), IRON, 0))
    sc.add(Xform(box((0, 0, 0), (.08, .5, .08), WOOD_DARK, 0), (0, 0, 20), (.3, 0, .62)))
    sc.add(box((.3, .05, .65), (.2, .1, .2), IRON, 0))
    sc.add(box((.6, -.1, .58), (.3, .25, .06), LEATHER, 0))


@asset('int_weapon_rack', 'interior', 'furniture', (200, 200), (100, 170), seed=433, blocks=(14,), tags=('ferreiro', 'armas'), footprint=18)
def weapon_rack(sc, f):
    for x in (-.8, .8):
        sc.add(box((x, 0, .75), (.12, .12, 1.5), WOOD_DARK, 0))
    sc.add(box((0, 0, 1.4), (1.7, .12, .1), WOOD_DARK, 0))
    sc.add(box((0, 0, .5), (1.7, .12, .1), WOOD_DARK, 0))
    for k, x in enumerate((-.5, -.15, .2, .55)):
        sc.add(box((x, -.04, 1.0), (.07, .05, 1.0), IRON, 0))
        sc.add(box((x, -.04, .55), (.3, .06, .07), GOLD, 0))
        sc.add(box((x, -.04, .42), (.06, .06, .25), LEATHER, 0))


@asset('int_armor_stand', 'interior', 'furniture', (150, 220), (75, 192), seed=434, blocks=(9,), tags=('ferreiro', 'armadura'), footprint=12)
def armor_stand(sc, f):
    sc.add(box((0, 0, .06), (.7, .7, .12), WOOD_DARK, 0))
    sc.add(Cylinder((0, 0, .1), 1.3, .06, .05, WOOD_DARK))
    sc.add(Ellipsoid((0, 0, 1.4), (.34, .22, .4), IRON))
    sc.add(Ellipsoid((0, 0, 1.9), (.18, .18, .2), IRON))
    for s in (-1, 1):
        sc.add(Ellipsoid((s * .36, 0, 1.6), (.16, .16, .13), IRON))
    sc.add(box((0, .2, 1.55), (.1, .03, .5), GOLD, 0))
    sc.add(Cylinder((0, 0, 1.0), .25, .3, .36, CLOTH_RED))


@asset('int_cauldron', 'interior', 'furniture', (170, 160), (85, 128), seed=435, blocks=(14,), tags=('alquimia', 'caldeirao'), footprint=18, frames=4)
def cauldron(sc, f):
    ph = f / 4 * 6.283
    for i in range(6):
        a = i / 6 * 6.283
        sc.add(Xform(Cylinder((0, 0, 0), .5, .07, .06, BARK_DEAD), (0, 80, math.degrees(a)), (0, 0, .1)))
    sc.add(Ellipsoid((0, 0, .12), (.5, .5, .1), EMBER))
    sc.add(Ellipsoid((0, 0, .72), (.55, .55, .5), IRON))
    sc.add(Cylinder((0, 0, .95), .05, .5, .5, GLOW_GREEN))
    for k in range(4):
        a = ph + k * 1.6
        sc.add(Ellipsoid((math.cos(a) * .22, math.sin(a) * .22, 1.0 + .05 * math.sin(ph * 2 + k)), (.08, .08, .08), GLOW_GREEN))
    sc.add(Cylinder((0, 0, .9), .07, .55, .58, IRON))
    for s in (-1, 1):
        sc.add(Ellipsoid((s * .5, 0, .8), (.06, .06, .06), IRON))
    sc.glow.append((0, 0, 1.0, 54, (110, 255, 150), .5))


@asset('int_alchemy_table', 'interior', 'furniture', (230, 190), (115, 156), seed=436, blocks=(18,), tags=('alquimia', 'mesa'), footprint=22)
def alchemy_table(sc, f):
    sc.add(box((0, 0, .5), (1.9, .85, .1), WOOD, 0))
    for x in (-.8, .8):
        for y in (-.32, .32):
            sc.add(box((x, y, .25), (.1, .1, .5), WOOD_DARK, 0))
    for k, (x, m) in enumerate([(-.65, BOTTLE_RED), (-.3, BOTTLE_GREEN), (.05, BOTTLE_BLUE), (.4, BOTTLE_RED)]):
        sc.add(Ellipsoid((x, 0, .75), (.13, .13, .16), m))
        sc.add(Cylinder((x, 0, .84), .18, .04, .04, m))
    sc.add(Cylinder((.75, .1, .55), .12, .13, .1, STONE))
    sc.add(Cylinder((.75, .1, .66), .02, .1, .1, EARTH))
    sc.add(box((-.05, -.28, .57), (.5, .25, .05), PAPER, 0))
    sc.add(Cylinder((.2, .28, .55), .16, .03, .03, BONE))
    sc.add(Ellipsoid((.2, .28, .74), (.04, .04, .07), FIRE))


@asset('int_rug_round', 'interior', 'furniture', (200, 110), (100, 60), seed=437, shadow=False, tags=('interior', 'tapete'))
def rug_round(sc, f):
    sc.add(Cylinder((0, 0, 0), .02, 1.3, 1.3, CARPET))
    sc.add(Cylinder((0, 0, .02), .015, 1.1, 1.1, Mat(GOLD.ramp, ambient=.6, zshade=0, name='trim')))
    sc.add(Cylinder((0, 0, .035), .015, 1.0, 1.0, CARPET))
    sc.add(Cylinder((0, 0, .05), .015, .5, .5, CLOTH_CREAM))


@asset('int_fireplace', 'interior', 'furniture', (230, 260), (115, 206), seed=438, blocks=(20,), tags=('taverna', 'lareira'), footprint=26, frames=4)
def fireplace(sc, f):
    sc.add(box((0, 0, .95), (1.8, .8, 1.9), STONE, 0))
    sc.add(box((0, -.1, 2.05), (1.2, .6, .5), STONE_PLAIN, 0))
    sc.add(box((0, .42, .6), (1.0, .06, .9), VOID_I, 0))
    sc.add(box((0, .45, 1.75), (2.0, .3, .14), WOOD_DARK, 0))
    ph = f / 4 * 6.283
    for k, (x, h) in enumerate([(-.28, .4), (0, .62), (.28, .36)]):
        hh = h * (1 + .15 * math.sin(ph + k * 2))
        sc.add(Ellipsoid((x, .47, .3 + hh * .5), (.13, .06, hh * .5), FIRE))
    sc.add(Xform(Cylinder((0, 0, 0), .8, .07, .07, BARK_DEAD), (0, 90, 0), (-.4, .46, .18)))
    sc.glow.append((0, .5, .7, 84, (255, 150, 60), .8))


@asset('int_quest_board', 'interior', 'furniture', (200, 220), (100, 186), seed=439, blocks=(14,), tags=('guilda', 'quadro'), footprint=18)
def quest_board(sc, f):
    for x in (-.7, .7):
        sc.add(box((x, 0, .8), (.12, .12, 1.6), WOOD_DARK, 0))
    sc.add(box((0, 0, 1.15), (1.6, .1, 1.2), WOOD, 0))
    sc.add(box((0, 0, 1.78), (1.7, .16, .1), WOOD_DARK, 0))
    rr = rng_for(439)
    for i, (x, z) in enumerate([(-.5, 1.4), (0, 1.25), (.5, 1.4), (-.3, .9), (.35, .95)]):
        sc.add(box((x, .07, z), (.34, .03, .4 - i % 2 * .08), PAPER, 0))
        sc.add(Ellipsoid((x, .09, z + .15), (.03, .03, .03), flower_mat('red')))


@asset('int_desk_guild', 'interior', 'furniture', (230, 170), (115, 138), seed=440, blocks=(18,), tags=('guilda', 'mesa'), footprint=22)
def desk_guild(sc, f):
    sc.add(box((0, 0, .55), (1.9, .95, .1), WOOD_DARK, 0))
    for x in (-.85, .85):
        sc.add(box((x, 0, .27), (.14, .85, .54), WOOD, 0))
    for x, w in [(-.5, .4), (.1, .35)]:
        sc.add(box((x, -.05, .63), (w, .3, .04), PAPER, 0))
    sc.add(Cylinder((.7, .2, .6), .3, .04, .04, WOOD))
    sc.add(Ellipsoid((.7, .2, .92), (.05, .05, .08), FIRE))
    sc.add(Xform(box((0, 0, 0), (.05, .3, .04), BONE, 0), (0, 0, 40), (-.1, .2, .65)))
    sc.glow.append((.7, .2, .9, 30, (255, 190, 90), .4))


@asset('int_sacks', 'interior', 'furniture', (140, 120), (70, 96), seed=441, blocks=(12,), tags=('loja', 'saco'), footprint=14)
def sacks(sc, f):
    for x, y, s in [(-.25, 0, .5), (.28, .06, .46), (0, .28, .42)]:
        sc.add(Ellipsoid((x, y, s * .6), (s * .55, s * .5, s * .62), CLOTH_CREAM))
        sc.add(Ellipsoid((x, y, s * 1.15), (s * .28, s * .26, s * .2), CLOTH_CREAM))
        sc.add(Cylinder((x, y, s * 1.0), .05, s * .3, s * .3, LEATHER))


@asset('int_candle_stand', 'interior', 'furniture', (100, 200), (50, 178), seed=442, blocks=(6,), tags=('interior', 'luz'), footprint=8, frames=4)
def candle_stand(sc, f):
    ph = f / 4 * 6.283
    sc.add(Cylinder((0, 0, 0), .1, .26, .2, IRON))
    sc.add(Cylinder((0, 0, .1), 1.3, .05, .04, IRON))
    sc.add(Cylinder((0, 0, 1.4), .06, .2, .2, IRON))
    sc.add(Cylinder((0, 0, 1.46), .3, .07, .07, CLOTH_CREAM))
    sc.add(Ellipsoid((0, 0, 1.86 + .03 * math.sin(ph)), (.05, .05, .1), FIRE))
    sc.glow.append((0, 0, 1.85, 52, (255, 190, 90), .7))
