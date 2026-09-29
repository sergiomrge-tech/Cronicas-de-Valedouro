"""Materiais e helpers compartilhados — paleta derivada dos assets APPROVED (Cidade/Dungeon)."""
import math
import numpy as np
from kit import *

# --- pedra / arquitetura
STONE = Mat(ramp('#3c2e3a', '#6e5a52', '#a08868', '#c8ae82', '#e6d0a0', '#f8ecc4'), tex=tex_stone_blocks(3.2, .2, 7), ambient=.34, bump=(7, .7), name='stone_city')
STONE_PLAIN = Mat(ramp('#3c2e3a', '#6e5a52', '#a08868', '#c8ae82', '#e6d0a0', '#f8ecc4'), tex=tex_speckle(10, .16, 8), ambient=.34, bump=(6, .8), name='stone_plain')
DSTONE = Mat(ramp('#12101e', '#2a2640', '#463e62', '#6a6088', '#948ab0', '#c0b8d8'), tex=tex_stone_blocks(3.2, .22, 9), ambient=.30, bump=(7, .8), name='stone_dungeon')
DSTONE_PLAIN = Mat(ramp('#12101e', '#2a2640', '#463e62', '#6a6088', '#948ab0', '#c0b8d8'), tex=tex_speckle(9, .18, 12), ambient=.30, bump=(6, .9), name='dstone_plain')
ROCK = Mat(ramp('#2a2230', '#4e4250', '#7c6a68', '#a8917e', '#d0bb9a', '#f0e2bc'), tex=tex_speckle(8, .2, 3), ambient=.32, bump=(4, 1.1), name='rock')
ROCK_GREY = Mat(ramp('#1e1c2c', '#3a3a52', '#5e5e78', '#8a8aa0', '#b4b4c6', '#dcdce8'), tex=tex_speckle(8, .2, 4), ambient=.32, bump=(5, 1.0), name='rock_grey')


def moss_tint(ctx, col, tone):
    up = np.clip((ctx.N[:, 2] - .25) * 1.7, 0, 1)[:, None]
    n = noise3(ctx.P, 5.0, 21)[:, None]
    m = np.clip(up * (n * 1.6 - .35), 0, 1)
    moss = np.array([70, 128, 38], dtype=np.float32) * (0.55 + 0.6 * tone[:, None])
    return col * (1 - m) + moss * m


ROCK_MOSS = Mat(ROCK.ramp, tex=tex_speckle(8, .2, 5), ambient=.32, bump=(5, 1.0), tint=moss_tint, name='rock_moss')
STONE_MOSS = Mat(STONE.ramp, tex=tex_stone_blocks(3.2, .2, 7), ambient=.34, bump=(7, .7), tint=moss_tint, name='stone_moss')


def snow_tint(strength=1.0):
    def f(ctx, col, tone):
        up = np.clip((ctx.N[:, 2] - .15) * 1.6, 0, 1)[:, None]
        n = noise3(ctx.P, 4.0, 33)[:, None]
        m = np.clip(up * (.55 + n * .8) * strength, 0, 1)
        sn = np.array([232, 246, 255], dtype=np.float32) * (0.72 + 0.4 * tone[:, None])
        sn = np.minimum(sn, 255)
        return col * (1 - m) + sn * m
    return f


ROCK_ICE = Mat(ramp('#1a2a58', '#2e4c88', '#5a86bc', '#8ec0e0', '#c4e8f6', '#f2fcff'), tex=tex_speckle(8, .18, 6), ambient=.36, bump=(5, .9), name='rock_ice')
ROCK_SNOW = Mat(ROCK_GREY.ramp, tex=tex_speckle(8, .2, 4), ambient=.34, bump=(5, 1.0), tint=snow_tint(), name='rock_snow')
ROCK_SAND = Mat(ramp('#4a2a28', '#7e4a36', '#b87a4a', '#dea866', '#f4d08c', '#fff0be'), tex=tex_speckle(8, .2, 7), ambient=.36, bump=(5, .9), name='rock_sand')
SANDSTONE = Mat(ramp('#4a2a28', '#7e4a36', '#b87a4a', '#dea866', '#f4d08c', '#fff0be'), tex=tex_stone_blocks(3.0, .2, 11), ambient=.36, bump=(7, .7), name='sandstone')

# --- madeira
WOOD = Mat(ramp('#2a1410', '#54301c', '#82502a', '#b07838', '#dca458', '#f8d488'), tex=tex_wood_planks(6, .18, 4, 'x'), ambient=.34, bump=(9, .5), name='wood')
WOOD_Y = Mat(WOOD.ramp, tex=tex_wood_planks(6, .18, 4, 'y'), ambient=.34, bump=(9, .5), name='wood_y')
WOOD_DARK = Mat(ramp('#180c10', '#341a18', '#58301f', '#7e4c2a', '#a8703a', '#d09a54'), tex=tex_wood_planks(6, .16, 5, 'x'), ambient=.32, bump=(9, .5), name='wood_dark')
WOOD_DARK_Y = Mat(WOOD_DARK.ramp, tex=tex_wood_planks(6, .16, 5, 'y'), ambient=.32, bump=(9, .5), name='wood_dark_y')
WOOD_OLD = Mat(ramp('#1c1414', '#3a2c28', '#5e4a3c', '#846a52', '#a89070', '#cfba96'), tex=tex_wood_planks(5, .22, 6, 'x'), ambient=.34, bump=(9, .6), name='wood_old')
WOOD_OLD_Y = Mat(WOOD_OLD.ramp, tex=tex_wood_planks(5, .22, 6, 'y'), ambient=.34, bump=(9, .6), name='wood_old_y')
BARK = Mat(ramp('#1c0c12', '#3a1a16', '#5e3020', '#8a5028', '#c07a34', '#e8a850'), tex=tex_bark(), ambient=.30, bump=(8, .6), name='bark')
BARK_BIRCH = Mat(ramp('#241c26', '#6a6068', '#b0a8a8', '#e0d8d0', '#f8f4ec', '#ffffff'), tex=tex_speckle(11, .5, 9), ambient=.36, bump=(8, .5), name='bark_birch')
BARK_DEAD = Mat(ramp('#181018', '#302430', '#54443f', '#7c6a58', '#a89478', '#d2c0a0'), tex=tex_bark(amp=.36, seed=8), ambient=.32, bump=(8, .8), name='bark_dead')
LOG_END = Mat(ramp('#4a2c18', '#8a5a30', '#c48a48', '#e8b868', '#f8dc98', '#fff0bc'), tex=tex_speckle(14, .12, 3), ambient=.5, name='log_end')

# --- vegetação
GRASS = Mat(ramp('#0c3a24', '#155a26', '#22801e', '#48a824', '#8cd03a', '#d0f060'), tex=tex_speckle(14, .18, 1), ambient=.4, jitter=.08, zshade=.05, name='grass')
GRASS_DRY = Mat(ramp('#3a2a14', '#6a4c1e', '#a07a2a', '#c8a03c', '#e8cc60', '#fff094'), tex=tex_speckle(14, .18, 2), ambient=.42, jitter=.08, zshade=.05, name='grass_dry')
SNOWBASE = Mat(ramp('#3a4a88', '#6a86c0', '#a6c4e6', '#d4ecfa', '#f0faff', '#ffffff'), tex=tex_speckle(14, .10, 3), ambient=.5, jitter=.05, zshade=.05, name='snowbase')
SANDBASE = Mat(ramp('#6a3a26', '#a86a3c', '#d49a56', '#efc476', '#fbe09a', '#fff4c4'), tex=tex_speckle(14, .10, 4), ambient=.5, jitter=.05, zshade=.05, name='sandbase')
DIRTBASE = Mat(ramp('#2a1a16', '#4e3020', '#7a5030', '#a67444', '#c89c5c', '#e8c484'), tex=tex_speckle(14, .16, 5), ambient=.4, jitter=.06, zshade=.05, name='dirtbase')
LEAF = Mat(ramp('#062a26', '#0d4a2c', '#146a24', '#2a8c1a', '#5cb01a', '#c8e83a'), tex=tex_leaf(amp=.34), ambient=.26, jitter=.10, contrast=1.05, name='leaf')
LEAF_AUTUMN = Mat(ramp('#3a1010', '#6e2a10', '#a8501a', '#d08a1e', '#f0c030', '#fff074'), tex=tex_leaf(amp=.34, seed=9), ambient=.28, jitter=.10, name='leaf_autumn')
LEAF_BIRCH = Mat(ramp('#12401e', '#22702a', '#48a02a', '#88c832', '#c4e84a', '#f4fa8a'), tex=tex_leaf(amp=.3, seed=6), ambient=.32, jitter=.10, name='leaf_birch')
LEAF_DRY = Mat(ramp('#3a2a10', '#6a5018', '#9c8624', '#c4b040', '#e2d468', '#f8f0a0'), tex=tex_leaf(amp=.26, seed=4), ambient=.34, jitter=.10, name='leaf_dry')
PINE = Mat(ramp('#04202c', '#0a3a3a', '#12583a', '#22783a', '#48a03e', '#96cc58'), tex=tex_speckle(15, .3, 12), ambient=.26, bump=(11, .8), jitter=.06, name='pine')
PINE_SNOW = Mat(PINE.ramp, tex=tex_speckle(15, .3, 12), ambient=.28, bump=(11, .8), jitter=.06, tint=snow_tint(), name='pine_snow')
PALM = Mat(ramp('#0a3a26', '#12603a', '#22883a', '#4eb03a', '#8ad048', '#d4f27a'), tex=tex_speckle(12, .2, 15), ambient=.32, name='palm')
CACTUS = Mat(ramp('#0c3a2c', '#155a3a', '#248046', '#46a85a', '#84cc78', '#d0f2a6'), tex=tex_speckle(16, .14, 17), ambient=.34, bump=(12, .5), name='cactus')
MUSHROOM_RED = Mat(ramp('#4a0a24', '#8a1638', '#c8264a', '#ec5a6a', '#ff96a0', '#ffe0e0'), tex=tex_speckle(12, .1, 3), ambient=.34, name='mush_red')
MUSHROOM_STEM = Mat(ramp('#5a4a48', '#98887c', '#c8b8a6', '#e8dcc6', '#f8f0e0', '#ffffff'), ambient=.4, name='mush_stem')
REED = Mat(ramp('#12401e', '#26702a', '#4a9c2e', '#84c83c', '#b8e460', '#eefa9c'), tex=tex_speckle(18, .1, 6), ambient=.42, name='reed')
REED_TOP = Mat(ramp('#3a1a10', '#6a3a1a', '#9a5e28', '#c88a3a', '#e8b458', '#fbdc8c'), ambient=.4, name='reed_top')
HAY = Mat(ramp('#5a3a14', '#946020', '#c8901e', '#e4b432', '#f8d456', '#fff29a'), tex=tex_speckle(20, .3, 18), ambient=.4, bump=(16, .5), name='hay')


def flower_mat(kind):
    pals = {
        'pink': ('#7a1a50', '#c83a84', '#ff7ab4', '#ffc4de', '#fff0f6'),
        'yellow': ('#8a5a08', '#e0a418', '#ffd030', '#ffec7a', '#fffac0'),
        'white': ('#8a86a8', '#c8c4dc', '#f0eef8', '#ffffff', '#ffffff'),
        'blue': ('#1a2a90', '#3c5cd8', '#7aa0ff', '#bcd0ff', '#eef4ff'),
        'purple': ('#4a1a80', '#8a3ad0', '#b878ff', '#dcb8ff', '#f6ecff'),
        'red': ('#7a0a1a', '#c81c2c', '#ff4a54', '#ff9090', '#ffd8d0'),
        'orange': ('#8a3008', '#e06a14', '#ff9a28', '#ffc85a', '#ffec9a'),
    }[kind]
    return Mat(ramp(*pals), ambient=.55, emissive=0.0, name='flower_' + kind)


# --- tecidos / metal / fogo
def cloth(c0, c1, c2, c3, c4):
    return Mat(ramp(c0, c1, c2, c3, c4), tex=tex_speckle(22, .14, 19), ambient=.4, bump=(20, .35), name='cloth')


CLOTH_BLUE = cloth('#0c1450', '#1a2a90', '#2c4cd0', '#5a86ff', '#a8c8ff')
CLOTH_RED = cloth('#4a0a18', '#8a1428', '#c8283a', '#f05a54', '#ffa088')
CLOTH_CREAM = cloth('#5a4634', '#a08462', '#d4bc90', '#eedcb0', '#fff6dc')
CLOTH_GREEN = cloth('#0c3a24', '#1a6a34', '#38a044', '#78d060', '#c4f090')
CLOTH_PURPLE = cloth('#2a0a4a', '#521a8a', '#823ac8', '#b070f0', '#e0b8ff')
IRON = Mat(ramp('#14121e', '#2c2a3c', '#4e4c62', '#787890', '#a8a8bc', '#dcdce8'), tex=tex_speckle(14, .1, 20), ambient=.3, bump=(10, .4), name='iron')
GOLD = Mat(ramp('#4a2a08', '#8a5a10', '#c8901c', '#eec040', '#ffe27a', '#fffbc0'), ambient=.4, name='gold')
FIRE = Mat(ramp('#8a1408', '#d0340c', '#ff6a10', '#ffa020', '#ffd048', '#fff6b0'), emissive=1.0, name='fire')
EMBER = Mat(ramp('#2a0a08', '#5a1408', '#a02a0c', '#e0500c', '#ff8a20', '#ffcc50'), emissive=.6, ambient=.4, name='ember')
ASH = Mat(ramp('#14101a', '#2c2630', '#463e46', '#6a5e62', '#8c8080', '#b4a8a4'), tex=tex_speckle(16, .16, 21), ambient=.4, name='ash')
BONE = Mat(ramp('#4a3a34', '#8a7a68', '#c4b498', '#e6d8bc', '#f8f0da', '#ffffff'), tex=tex_speckle(16, .1, 22), ambient=.42, bump=(12, .4), name='bone')
LEATHER = Mat(ramp('#2a1408', '#5a2c14', '#8a4a20', '#b87434', '#dca058', '#f6cc84'), tex=tex_speckle(18, .16, 23), ambient=.36, bump=(14, .4), name='leather')
EARTH = Mat(ramp('#1c1210', '#3c2418', '#664028', '#946040', '#c08c58', '#e6b880'), tex=tex_speckle(12, .2, 24), ambient=.36, bump=(6, .9), name='earth')
GLASS_BLUE = Mat(ramp('#0a1a58', '#1a3aa0', '#3a78e0', '#7ab4ff', '#c0e4ff', '#ffffff'), ambient=.5, emissive=.4, name='glass_blue')
GLOW_PURPLE = Mat(ramp('#2a0a58', '#521aa0', '#8a3ae8', '#b878ff', '#e0b8ff', '#ffffff'), emissive=1.0, name='glow_purple')
GLOW_BLUE = Mat(ramp('#0a2a78', '#1a58c8', '#3a90ff', '#78c4ff', '#c0e8ff', '#ffffff'), emissive=1.0, name='glow_blue')
GLOW_GREEN = Mat(ramp('#0a4a30', '#1a8a4a', '#3ac860', '#78f088', '#c0ffc0', '#ffffff'), emissive=1.0, name='glow_green')
GLOW_GOLD = Mat(ramp('#6a3a08', '#b8741a', '#f0b030', '#ffdc60', '#fff4a0', '#ffffff'), emissive=1.0, name='glow_gold')
WATER = Mat(ramp('#0a2a70', '#1a58b8', '#3a90e0', '#6cc8f4', '#b4ecff', '#f0ffff'), tex=tex_speckle(10, .18, 25), ambient=.6, zshade=0, name='water')
CRYSTAL_ICE = Mat(ramp('#1a3a88', '#3a78d0', '#7ac0f4', '#b4e6ff', '#e4faff', '#ffffff'), tex=tex_speckle(6, .14, 26), ambient=.42, emissive=.35, name='crystal_ice')
CRYSTAL_GREEN = Mat(ramp('#0a4a30', '#1a8a48', '#3cc868', '#84f098', '#c8ffd4', '#ffffff'), ambient=.42, emissive=.5, name='crystal_green')
CRYSTAL_GOLD = Mat(ramp('#6a3a08', '#b8741a', '#f0b030', '#ffdc60', '#fff4a0', '#ffffff'), ambient=.42, emissive=.5, name='crystal_gold')
ORE = Mat(ramp('#1c1a2c', '#3c3a54', '#6a6884', '#9c9ab8', '#d0cee4', '#ffffff'), tex=tex_speckle(10, .2, 27), ambient=.3, bump=(6, .9), name='ore')
PLASTER = Mat(ramp('#4a3a38', '#8a7462', '#c4ac88', '#e6d2a8', '#f8ecc8', '#fffbe6'), tex=tex_speckle(12, .1, 28), ambient=.4, bump=(8, .4), name='plaster')
BRICK = Mat(ramp('#3a1414', '#6e2a20', '#a44a34', '#cc7250', '#e8a074', '#f8d0a4'), tex=tex_stone_blocks(4, .28, 29), ambient=.34, bump=(7, .6), name='brick')
FLOORWOOD = Mat(ramp('#2a1410', '#54301c', '#82502a', '#b07838', '#dca458', '#f8d488'), tex=tex_wood_planks(5, .16, 30, 'y'), ambient=.5, zshade=0, name='floorwood')


# --- helpers de cena
def rng_for(seed):
    return np.random.default_rng(seed)


def add_patch(sc, kind='grass', radius=1.1, n=30, seed=1, height=.1, flowers=('pink', 'yellow', 'white'), nflowers=7, sizescale=1.0):
    """Base orgânica de chão sob o objeto (linguagem dos assets aprovados)."""
    r = rng_for(seed + 900)
    mat = {'grass': GRASS, 'dry': GRASS_DRY, 'snow': SNOWBASE, 'sand': SANDBASE, 'dirt': DIRTBASE}[kind]
    for i in range(n):
        a = r.uniform(0, 6.283)
        d = math.sqrt(r.uniform(.05, 1)) * radius
        sc.add(Ellipsoid((math.cos(a) * d * 1.1, math.sin(a) * d * 1.1, .02), (.34 * sizescale, .34 * sizescale, height * 1.2), mat))
    if kind in ('grass', 'dry') and nflowers and flowers:
        fm = {f: flower_mat(f) for f in flowers}
        for i in range(nflowers):
            a = r.uniform(0, 6.283)
            d = math.sqrt(r.uniform(.2, 1)) * radius * .95
            sc.add(Ellipsoid((math.cos(a) * d * 1.1, math.sin(a) * d * 1.1, .12), (.07, .07, .06), fm[flowers[i % len(flowers)]]))


def limb(sc, p0, p1, r0, r1, mat, step=.55):
    """Ramo/tronco orientado como corrente de elipsoides (orgânico)."""
    p0 = np.array(p0, dtype=np.float32); p1 = np.array(p1, dtype=np.float32)
    L = float(np.linalg.norm(p1 - p0))
    n = max(2, int(L / (min(r0, r1) * step)) + 1)
    for i in range(n + 1):
        t = i / n
        p = p0 + (p1 - p0) * t
        r = r0 + (r1 - r0) * t
        sc.add(Ellipsoid(p, (r, r, r), mat))


def canopy(sc, center, radii, n, mat, seed, size=.38, zsize=.30, lowest=None):
    r = rng_for(seed)
    cx, cy, cz = center
    rx, ry, rz = radii
    pts = []
    for i in range(n):
        for _ in range(20):
            v = r.normal(size=3)
            v /= max(np.linalg.norm(v), 1e-6)
            rad = r.uniform(.15, 1) ** .55
            p = (cx + v[0] * rx * rad, cy + v[1] * ry * rad, cz + v[2] * rz * rad)
            if lowest is None or p[2] >= lowest:
                pts.append(p); break
    for (x, y, z) in sorted(pts, key=lambda p: p[2]):
        k = r.uniform(.85, 1.15)
        sc.add(Ellipsoid((x, y, z), (size * k, size * k, zsize * k), mat))


def facet(sc, c, r, mat, seed, squash=.75, nplanes=13, sx=1.0, sy=1.0, cut=0.0):
    """Poliedro convexo facetado (rocha, cristal bruto, bloco quebrado). c = centro da base."""
    rr = rng_for(seed)
    cx, cy, cz = c
    planes = [((0, 0, -1.0), -cz + cut)]
    for i in range(nplanes):
        z = rr.uniform(-.05, 1.0) if i >= 4 else rr.uniform(.0, .35)
        a = rr.uniform(0, 6.283) if i >= 4 else i / 4 * 6.283 + rr.uniform(-.4, .4)
        h = math.sqrt(max(0.0, 1 - z * z))
        n = np.array([math.cos(a) * h / sx, math.sin(a) * h / sy, z / squash])
        d = r * rr.uniform(.78, 1.02)
        nn = float(np.linalg.norm(n))
        n = n / nn
        cc = np.array([cx, cy, cz + r * squash * .35])
        planes.append((n, d / nn * 1.0 + float(n @ cc)))
    return sc.add(Convex(planes, mat, (cx, cy, cz + r * squash * .5), (r * 2, r * 2, r * squash)))


def rock(sc, c, r, mat, seed, n=4, flat=.75):
    """Aglomerado de rochas facetadas."""
    rr = rng_for(seed)
    cx, cy, cz = c
    facet(sc, (cx, cy, cz), r, mat, seed, squash=flat)
    for i in range(1, n):
        a = rr.uniform(0, 6.283)
        d = r * rr.uniform(.55, .95)
        k = rr.uniform(.35, .62)
        facet(sc, (cx + math.cos(a) * d, cy + math.sin(a) * d * .9, cz), r * k, mat, seed + i * 13, squash=flat * rr.uniform(.8, 1.1), nplanes=10)


def blade(sc, x, y, h, lean, mat, w=.05, seed=0):
    """Folha de capim/junco: cone estreito inclinado."""
    prim = Cylinder((0, 0, 0), h, w, w * .15, mat)
    sc.add(Xform(prim, (lean[0], lean[1], 0), (x, y, 0)))


def tuft(sc, x, y, mat, seed, n=7, h=.5, spread=.12):
    r = rng_for(seed)
    for i in range(n):
        a = r.uniform(0, 6.283)
        d = r.uniform(0, spread)
        blade(sc, x + math.cos(a) * d, y + math.sin(a) * d, h * r.uniform(.7, 1.2), (r.uniform(-28, 28), r.uniform(-28, 28)), mat, w=r.uniform(.035, .055))


def stone_box(sc, c, s, mat=STONE, rot=0):
    return sc.add(box(c, s, mat, rot))


def tex_ripples(freq=9.0, amp=.18):
    def f(ctx):
        P = ctx.P
        d = P[:, 0] * .8 + P[:, 1] * .6 + noise3(P, 1.2, 41) * .5
        return np.sin(d * freq) * amp
    return f


def tex_ridges(n=8, amp=.22):
    def f(ctx):
        th = np.arctan2(ctx.L[:, 1], ctx.L[:, 0])
        return np.cos(th * n) * amp
    return f


SAND_DUNE = Mat(SANDBASE.ramp, tex=tex_ripples(24, .13), ambient=.5, zshade=0, bump=(3, .4), name='sand_dune')
CACTUS_R = Mat(CACTUS.ramp, tex=tex_ridges(10, .25), ambient=.34, name='cactus_ridged')
RUNE_GLOW = Mat(ramp('#3a1a78', '#6a34c8', '#a068ff', '#d0a4ff', '#f0e0ff', '#ffffff'), emissive=1.0, name='rune_glow')


def crystal(sc, c, r, h, mat, seed, sides=6, tilt=0.0, tip=.28):
    """Prisma hexagonal com ponta: cristal/estalagmite. c = centro da base, r = raio, h = altura total."""
    rr = rng_for(seed)
    cx, cy, cz = c
    planes = [((0, 0, -1.0), -cz)]
    off = rr.uniform(0, 6.28)
    apex = np.array([cx + tilt * h, cy, cz + h])
    zt = cz + h * (1 - tip)
    for k in range(sides):
        a = off + k / sides * 6.283
        nh = np.array([math.cos(a), math.sin(a), 0.0])
        rad = r * rr.uniform(.85, 1.1)
        p0 = np.array([cx, cy, cz]) + nh * rad
        planes.append((nh, float(nh @ p0)))
        # água da ponta: passa pela aresta no topo do prisma e pelo ápice
        e = np.array([cx, cy, zt]) + nh * rad
        tan = np.array([-nh[1], nh[0], 0.0])
        v1 = apex - e
        n = np.cross(tan, v1)
        n = n / np.linalg.norm(n)
        if n @ nh < 0:
            n = -n
        planes.append((n, float(n @ e)))
    return sc.add(Convex(planes, mat, (cx, cy, cz + h / 2), (r * 2, r * 2, h)))
