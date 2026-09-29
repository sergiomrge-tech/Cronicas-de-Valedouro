"""Elevações e terreno: colinas, planaltos (mesas), cordilheiras, escarpas, degraus naturais, paredões, arcos e cachoeira frontal."""
from mats import *
from registry import asset

S = 60.0


# ------------------------------------------------------------------ materiais de estrato (falésia)
def tex_strata(bands=5, amp=.22, seed=3, crack=.16):
    def f(ctx):
        z = ctx.P[:, 2]
        n = fbm(ctx.P * np.array([1.0, 1.0, 3.0], dtype=np.float32), 3.0, seed, 3)
        band = np.floor(z * bands + n * 1.6) % 3
        base = (band - 1) * amp * .5
        # fissuras verticais
        cx = (ctx.P[:, 0] * ctx.right[0] + ctx.P[:, 1] * ctx.right[1]) * 4.0
        cr = (noise3(np.stack([cx, np.zeros_like(cx), z * .5], -1), 1.0, seed + 5) > .72)
        return base + (n - .5) * .3 - cr * crack
    return f


def _vine_tint(strength=.7):
    def f(ctx, col, tone):
        top = np.clip((ctx.P[:, 2] - .6) * .8, 0, 1)[:, None]
        n = noise3(ctx.P, 4.0, 61)[:, None]
        m = np.clip(top * (n * 1.5 - .5) * strength, 0, 1)
        moss = np.array([64, 122, 36], dtype=np.float32) * (0.55 + 0.6 * tone[:, None])
        return col * (1 - m) + moss * m
    return f


STRATA_EARTH = Mat(ramp('#2a1610', '#4e2c1c', '#7a4c2c', '#a8743c', '#d09a58', '#efc07c'), tex=tex_strata(5, .26, 3), ambient=.36, bump=(5, 1.2), tint=_vine_tint(.55), name='strata_earth')
STRATA_ROCK = Mat(ramp('#1a1826', '#34324a', '#54506e', '#7a7694', '#a4a0ba', '#cecae0'), tex=tex_strata(6, .22, 4), ambient=.34, bump=(5, 1.4), tint=_vine_tint(.35), name='strata_rock')
STRATA_SAND = Mat(ramp('#4a2418', '#7c4a2c', '#b4763e', '#d8a058', '#f0c880', '#fde8b0'), tex=tex_strata(7, .3, 5), ambient=.4, bump=(5, 1.1), name='strata_sand')
STRATA_ICE = Mat(ramp('#1a2a5a', '#2e4c8c', '#5684bc', '#8cbce0', '#c4e4f6', '#f4fcff'), tex=tex_strata(6, .2, 6, .1), ambient=.42, bump=(5, 1.2), name='strata_ice')

CAPS = {'earth': ('grass', GRASS), 'rock': ('grass', GRASS), 'sand': ('sand', SANDBASE), 'ice': ('snow', SNOWBASE)}
SIDES = {'earth': STRATA_EARTH, 'rock': STRATA_ROCK, 'sand': STRATA_SAND, 'ice': STRATA_ICE}
ROCKS = {'earth': ROCK, 'rock': ROCK_GREY, 'sand': ROCK_SAND, 'ice': ROCK_ICE}


def prism(cx, cy, sx, sy, h, mat, taper=.0, cut=.32, z0=0.0):
    """Prisma octogonal (caixa com cantos chanfrados) com leve afunilamento no topo."""
    planes = [((0, 0, -1.0), -z0), ((0, 0, 1.0), z0 + h)]
    for sgn, ax in ((1, 0), (-1, 0), (1, 1), (-1, 1)):
        n = np.zeros(3)
        half = (sx if ax == 0 else sy) / 2
        n[ax] = sgn
        n[2] = taper
        nn = np.linalg.norm(n)
        p0 = np.array([cx, cy, z0])
        p0[ax] += sgn * half
        planes.append((n / nn, float((n / nn) @ p0)))
    c = min(sx, sy) * cut
    for sx_, sy_ in ((1, 1), (1, -1), (-1, 1), (-1, -1)):
        n = np.array([sx_, sy_, taper * .7])
        nn = np.linalg.norm(n)
        corner = np.array([cx + sx_ * (sx / 2 - c), cy + sy_ * (sy / 2 - c), z0])
        planes.append((n / nn, float((n / nn) @ corner) + c * .7))
    return Convex(planes, mat, (cx, cy, z0 + h / 2), (sx, sy, h))


def footprint_circles(sx, sy, step=.85, shrink=.9):
    """Círculos de colisão (px de jogo, relativos ao pé) cobrindo o retângulo de chão sx x sy (unidades)."""
    out = []
    nx = max(1, int(math.ceil(sx / step)))
    ny = max(1, int(math.ceil(sy / step)))
    for i in range(nx):
        for j in range(ny):
            X = -sx / 2 + (i + .5) * sx / nx
            Y = -sy / 2 + (j + .5) * sy / ny
            dx = .7071 * (Y - X) * S * .5
            dy = .5 * .7071 * (X + Y) * S * .5
            r = max(sx / nx, sy / ny) * .5 * .7071 * S * .5 * 1.55 * shrink
            out.append((round(dx, 1), round(dy, 1), round(r, 1)))
    return tuple(out)


def outcrops(sc, cx, cy, sx, sy, h, rockmat, seed, n=8):
    rr = rng_for(seed + 77)
    for i in range(n):
        side = rr.integers(0, 4)
        t = rr.uniform(-.45, .45)
        r = rr.uniform(.16, .3)
        if side == 0:
            x, y = cx + sx / 2 * .98, cy + t * sy
        elif side == 1:
            x, y = cx + t * sx, cy + sy / 2 * .98
        elif side == 2:
            x, y = cx - sx / 2 * .98, cy + t * sy
        else:
            x, y = cx + t * sx, cy - sy / 2 * .98
        z = rr.uniform(0, h * .8)
        facet(sc, (x, y, z), r, rockmat, seed + i * 11, squash=.9, nplanes=9)
    # entulho na base
    for i in range(int(n * 1.2)):
        a = rr.uniform(0, 6.283)
        d = rr.uniform(.95, 1.12)
        facet(sc, (cx + math.cos(a) * sx / 2 * d * (.9 if abs(math.cos(a)) > .3 else 1), cy + math.sin(a) * sy / 2 * d, 0), rr.uniform(.1, .2), rockmat, seed + 200 + i, squash=.7, nplanes=8)


def cap_details(sc, cx, cy, sx, sy, z, kind, seed):
    rr = rng_for(seed + 5)
    if kind in ('earth', 'rock'):
        for i in range(int(sx * sy * 3)):
            x, y = cx + rr.uniform(-.42, .42) * sx, cy + rr.uniform(-.42, .42) * sy
            if i % 2 == 0:
                tuft(sc, x, y, GRASS, seed + i, n=5, h=.25, spread=.06)
        fm = [flower_mat('white'), flower_mat('yellow'), flower_mat('pink')]
        for i in range(int(sx * sy * 1.5)):
            x, y = cx + rr.uniform(-.4, .4) * sx, cy + rr.uniform(-.4, .4) * sy
            sc.add(Ellipsoid((x, y, z + .1), (.05, .05, .045), fm[i % 3]))
        for i in range(int(sx * sy * .4)):
            x, y = cx + rr.uniform(-.35, .35) * sx, cy + rr.uniform(-.35, .35) * sy
            canopy(sc, (x, y, z + .22), (.3, .3, .12), 5, LEAF, seed + 30 + i, size=.18, zsize=.14)
    elif kind == 'sand':
        for i in range(int(sx * sy * 1.2)):
            x, y = cx + rr.uniform(-.4, .4) * sx, cy + rr.uniform(-.4, .4) * sy
            tuft(sc, x, y, GRASS_DRY, seed + i, n=4, h=.22, spread=.05)
    elif kind == 'ice':
        for i in range(int(sx * sy * .8)):
            x, y = cx + rr.uniform(-.4, .4) * sx, cy + rr.uniform(-.4, .4) * sy
            sc.add(Ellipsoid((x, y, z + .06), (.22, .16, .07), SNOWBASE))


def build_mesa(sc, sx, sy, h, kind, seed, taper=.04):
    side = SIDES[kind]
    capmat = CAPS[kind][1]
    sc.add(prism(0, 0, sx, sy, h, side, taper=taper))
    sc.add(prism(0, 0, sx * 1.04, sy * 1.04, .1, capmat, taper=0, z0=h))
    outcrops(sc, 0, 0, sx, sy, h, ROCKS[kind], seed)
    cap_details(sc, 0, 0, sx, sy, h + .1, kind, seed)


def _mesa_asset(id, sx, sy, h, kind, seed, size, origin, tags):
    @asset(id, 'nature', 'elevation', size, origin, seed=seed, collision=footprint_circles(sx, sy), tags=tags, contact=(max(sx, sy) * .75, max(sx, sy) * .75, .42), footprint=max(sx, sy) * 22)
    def build(sc, f):
        build_mesa(sc, sx, sy, h, kind, seed)
    return build


for _k, _tag in (('earth', 'colinas'), ('rock', 'rio'), ('sand', 'deserto'), ('ice', 'gelo')):
    _mesa_asset('nat_plateau_%s_s' % _k, 2.0, 2.0, 1.5, _k, 401 + len(_k), (300, 290), (150, 236), ('elevacao', 'planalto', _tag))
    _mesa_asset('nat_plateau_%s_m' % _k, 3.2, 3.2, 2.0, _k, 411 + len(_k), (420, 380), (210, 300), ('elevacao', 'planalto', _tag))
    _mesa_asset('nat_ridge_%s_a' % _k, 4.6, 1.8, 1.6, _k, 421 + len(_k), (400, 330), (200, 260), ('elevacao', 'cordilheira', _tag))
    _mesa_asset('nat_ridge_%s_b' % _k, 1.8, 4.6, 1.6, _k, 431 + len(_k), (400, 330), (200, 260), ('elevacao', 'cordilheira', _tag))


# ------------------------------------------------------------------ colinas suaves (sem cliff): montes com grama/neve/areia
def _hill_asset(id, kind, r, h, seed, size, origin):
    @asset(id, 'nature', 'elevation', size, origin, seed=seed, collision=footprint_circles(r * 1.5, r * 1.5, shrink=.7), tags=('elevacao', 'colina', kind), contact=(r * .9, r * .9, .4), footprint=r * 22)
    def build(sc, f):
        capname, capmat = CAPS[kind]
        rr = rng_for(seed)
        sc.add(Ellipsoid((0, 0, 0), (r, r * .9, h), capmat))
        for i in range(5):
            a = rr.uniform(0, 6.283)
            d = rr.uniform(.2, .7) * r
            sc.add(Ellipsoid((math.cos(a) * d, math.sin(a) * d, 0), (r * rr.uniform(.4, .6), r * rr.uniform(.4, .6), h * rr.uniform(.5, .85)), capmat))
        for i in range(4):
            a = rr.uniform(0, 6.283)
            facet(sc, (math.cos(a) * r * .8, math.sin(a) * r * .75, 0), rr.uniform(.18, .32), ROCKS[kind], seed + i, squash=.8, nplanes=9)
        cap_details(sc, 0, 0, r * 1.4, r * 1.4, h * .6, kind, seed)
    return build


_hill_asset('nat_hill_earth', 'earth', 1.5, .9, 441, (300, 210), (150, 150))
_hill_asset('nat_hill_sand', 'sand', 1.6, .85, 442, (300, 210), (150, 150))
_hill_asset('nat_hill_ice', 'ice', 1.5, .9, 443, (300, 210), (150, 150))


# ------------------------------------------------------------------ escarpa alta (paredão) e formações
def rock_wall(sc, length, axis, kind, seed, h=2.6):
    """Paredão de estratos com coroa irregular de blocos (escarpa alta, sem grama)."""
    rr = rng_for(seed)
    sx, sy = (length, 1.15) if axis == 'a' else (1.15, length)
    sc.add(prism(0, 0, sx, sy, h, SIDES[kind], taper=.05, cut=.16))
    n = int(length / .55)
    for i in range(n):
        u = -length / 2 + (i + .5) * length / n
        x, y = (u, rr.uniform(-.3, .3)) if axis == 'a' else (rr.uniform(-.3, .3), u)
        hh = rr.uniform(.25, .7)
        sc.add(prism(x, y, rr.uniform(.45, .7), rr.uniform(.45, .7), hh, SIDES[kind], taper=.08, cut=.3, z0=h - .05))
        facet(sc, (x + rr.uniform(-.15, .15), y + rr.uniform(-.15, .15), h + hh - .1), rr.uniform(.16, .26), ROCKS[kind], seed + i, squash=.8, nplanes=9)
    for i in range(n):
        u = -length / 2 + (i + .5) * length / n
        x, y = (u, sy / 2 * 1.05) if axis == 'a' else (sx / 2 * 1.05, u)
        facet(sc, (x, y, 0), rr.uniform(.14, .26), ROCKS[kind], seed + 100 + i, squash=.8, nplanes=8)


for _k in ('rock', 'sand', 'ice'):
    for _ax in ('a', 'b'):
        @asset('nat_wall_cliff_%s_%s' % (_k, _ax), 'nature', 'elevation', (360, 360), (180, 300), seed=451, tags=('elevacao', 'paredao', _k), collision=footprint_circles(3.6 if _ax == 'a' else 1.15, 1.15 if _ax == 'a' else 3.6, .8), contact=(2.4, 1.0, .4), footprint=70)
        def _rw(sc, f, _k=_k, _ax=_ax):
            rock_wall(sc, 3.6, _ax, _k, 451 + ord(_k[0]))


@asset('nat_steps_stone', 'nature', 'elevation', (300, 240), (150, 190), seed=461, tags=('elevacao', 'degraus'), contact=(1.8, 1.4, .35), footprint=40)
def steps_stone(sc, f):
    for k in range(6):
        sc.add(prism(-.9 + k * .32, 0, .34, 2.0 - k * .1, .18 * (k + 1), STRATA_EARTH, taper=.02, cut=.12))
        sc.add(prism(-.9 + k * .32, 0, .36, 2.05 - k * .1, .05, GRASS, taper=0, cut=.1, z0=.18 * (k + 1)))
    for sgn in (-1, 1):
        for k in range(3):
            facet(sc, (-.6 + k * .55, sgn * 1.15, 0), .3 - k * .04, ROCK, 461 + k + (sgn + 1) * 3, squash=.9, nplanes=9)


@asset('nat_rock_arch_natural', 'nature', 'elevation', (340, 360), (170, 300), seed=471, tags=('elevacao', 'arco', 'passagem'), collision=((-34, 6, 20), (34, 6, 20)), contact=(1.8, .9, .38), footprint=50)
def rock_arch_natural(sc, f):
    for sgn in (-1, 1):
        crystal(sc, (sgn * 1.1, 0, 0), .55, 2.4, ROCK_GREY, 471 + sgn, sides=7, tip=.15, tilt=-sgn * .04)
        facet(sc, (sgn * 1.15, .3, 0), .4, ROCK_GREY, 472 + sgn, squash=1.1, nplanes=10)
    for k in range(6):
        a = 3.14 * k / 5
        facet(sc, (-math.cos(a) * 1.1, 0, 2.15 + math.sin(a) * .55), .34, ROCK_GREY, 475 + k, squash=.9, nplanes=9)


@asset('nat_rock_pillars', 'nature', 'elevation', (280, 300), (140, 250), seed=481, tags=('elevacao', 'pilares', 'passagem'), collision=((0, 0, 16), (30, 10, 12), (-26, 8, 12)), contact=(1.4, 1.0, .38), footprint=34)
def rock_pillars(sc, f):
    for i, (x, y, h, r) in enumerate([(0, 0, 2.6, .5), (.9, .35, 1.7, .36), (-.8, .3, 1.4, .34), (.3, -.7, 1.1, .28)]):
        crystal(sc, (x, y, 0), r, h, ROCK_GREY, 481 + i, sides=7, tip=.25)


# ------------------------------------------------------------------ cachoeira frontal (câmera frontal, az=0): cabeceira do rio
# Com az=0 a horizontal da tela é o eixo Y do mundo e a profundidade é X (X maior = mais perto do observador).
def _fall_hi():
    return Mat(ramp('#3a7cc8', '#5ea4e8', '#8cc8f8', '#c4ecff', '#f4ffff'), emissive=1.0, name='fall_hi')


@asset('nat_waterfall_front', 'nature', 'water', (420, 330), (210, 268), seed=491, frames=8, az=0.0, scale=60.0, tags=('agua', 'cachoeira', 'penhasco'), draw_scale=.5,
       collision=((-70, -10, 30), (-38, -8, 30), (38, -8, 30), (70, -10, 30)), footprint=90)
def waterfall_front(sc, f):
    for sgn in (-1, 1):
        sc.add(prism(-.2, sgn * 1.85, 1.5, 1.7, 3.0, STRATA_ROCK, taper=.05, cut=.2))
        sc.add(prism(-.2, sgn * 1.85, 1.6, 1.8, .12, GRASS, taper=0, cut=.2, z0=3.0))
    sc.add(prism(-.35, 0, 1.0, 2.0, 2.2, STRATA_ROCK, taper=0, cut=.05))
    rr = rng_for(491)
    hi = _fall_hi()
    sc.add(box((-.1, 0, 2.25), (1.0, 2.0, .1), WATER, 0))
    for k in range(9):
        y = -.85 + k * .21
        sc.add(box((.22, y, 1.15), (.12, .18, 2.2), GLOW_BLUE, 0))
        for sg in range(3):
            z = 2.15 - ((f / 8 + sg / 3 + k * .07) % 1.0) * 2.0
            sc.add(box((.27, y, z), (.1, .16, .42), hi, 0))
    for k in range(10):
        ph = (f / 8 + k * .11) % 1.0
        sc.add(Ellipsoid((.32, rr.uniform(-.95, .95), .22 + ph * .45), (.09, .1, .08), Mat(ramp('#c4ecff', '#eaffff', '#ffffff'), emissive=1.0, name='mist')))
    sc.add(box((1.25, 0, .05), (1.5, 2.8, .1), WATER, 0))
    for k in range(10):
        sc.add(Ellipsoid((.7 + rr.uniform(0, 1.0), rr.uniform(-1.2, 1.2), .14), (.12, .2, .06), Mat(ramp('#dff6ff', '#f4ffff', '#ffffff'), ambient=.7, name='foam')))
    for y in (-1.75, 1.75):
        facet(sc, (.9, y, 0), .5, ROCK_GREY, 495 + int(y * 2), squash=.9, nplanes=10)
    sc.glow.append((.4, 0, .8, 90, (150, 210, 255), .3))
