"""Landmarks REG_001 produzidos com o pipeline profissional (Blender): mesmos IDs persistentes dos protótipos str_*/nat_*.

Uso (Python do bpy):  python pro_landmarks.py [id ...] [--preview DIR]
"""
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from vk import asset, core, geo, mats, parts
from vk.parts import M

REGISTRY = {}


def landmark(id, **kw):
    def deco(fn):
        REGISTRY[id] = (fn, kw)
        return fn
    return deco


def fpc(sx, sy, step=.85, shrink=.9):
    from terrain_forms_data import footprint_circles
    return footprint_circles(sx, sy, step, shrink)


# ------------------------------------------------------------------ torre de vigia
def build_watchtower(f, stone='stone', roof='roof_red', snowy=False):
    ms, mw, mwd, mwo, mr = M(stone), M('wood'), M('wood_dark'), M('wood_old'), M(roof)
    base, top, H = 2.5, 2.0, 3.5
    # fundação: pedras grandes irregulares + entulho + grama
    geo.box((0, 0, 0.09), (base + .5, base + .5, .2), ms, bevel=0.05)
    parts.rubble(0, 0, base * .78, 11, M('rock' if not snowy else 'rock_snow'), seed=3, rmin=.14, rmax=.34)
    # fuste em talude + cantoneiras
    parts.tapered_shaft(0, 0, .18, H, base, top, ms, seed=1)
    parts.quoins(0, 0, .18, H, base, top, ms, seed=2)
    # frestas de arqueiro com vergas e ombreiras
    for z in (1.2, 2.3):
        for (ax, ay, w, d) in ((1, 0, .12, .5), (0, 1, .5, .12)):
            ix, iy = ax * (top / 2 + (base - top) * (1 - (z - .18) / (H - .18)) / 2 + .0), ay * (top / 2 + (base - top) * (1 - (z - .18) / (H - .18)) / 2)
            geo.box((ix + ax * .02, iy + ay * .02, z), (w, d, .55), M('hole'), bevel=0.0)
            geo.box((ix + ax * .05, iy + ay * .05, z + .34), (w + (0.34 if ax == 0 else .16), d + (0.34 if ay == 0 else .16), .1), ms, bevel=0.02)
    # porta em arco com batente de pedra na face +y, degrau e ferragens
    dy = base / 2 - .02
    geo.box((0, dy + .06, .78), (.86, .18, 1.5), ms, bevel=0.03)
    geo.box((0, dy + .1, .72), (.62, .16, 1.3), mwd, bevel=0.02)
    geo.box((0, dy + .12, 1.45), (.72, .18, .16), ms, bevel=0.04)
    for zz in (.35, 1.0):
        geo.box((0, dy + .21, zz), (.6, .03, .07), M('iron'), bevel=0.005)
    geo.box((.18, dy + .22, .7), (.07, .04, .07), M('gold'), bevel=0.01)
    geo.box((0, dy + .55, .05), (1.2, .6, .12), ms, bevel=0.03)
    geo.box((0, dy + .85, .02), (1.4, .4, .06), ms, bevel=0.03)
    # mísulas / friso sob a plataforma
    for i in range(-4, 5):
        geo.box((i * .3, base / 2 - .16 - (0.06), H - .08), (.2, .28, .2), ms, bevel=0.03)
        geo.box((base / 2 - .16 - .06, i * .3, H - .08), (.28, .2, .2), ms, bevel=0.03)
    geo.box((0, 0, H + .02), (top + .5, top + .5, .12), ms, bevel=0.04)
    # plataforma de madeira com vigas
    zd = H + .16
    parts.deck(0, 0, zd, 3.15, 3.15, mw, mwd)
    # cabine de madeira: 4 postes, travessas, painéis nos fundos, mãos-francesas
    zt = zd + .07
    hp = 1.4
    for x, y in ((-1.2, -1.2), (1.2, -1.2), (1.2, 1.2), (-1.2, 1.2)):
        geo.box((x, y, zt + hp / 2), (.2, .2, hp), mwd, bevel=0.03)
        geo.box((x, y, zt + .06), (.28, .28, .14), mwd, bevel=0.03)
    for sgn in (-1, 1):
        geo.box((0, sgn * 1.2, zt + hp - .1), (2.6, .16, .2), mwd, bevel=0.025)
        geo.box((sgn * 1.2, 0, zt + hp - .1), (.16, 2.6, .2), mwd, bevel=0.025)
    # painéis fechados nas faces traseiras (x-, y-)
    geo.box((0, -1.2, zt + .52), (2.4, .1, 1.0), mw, bevel=0.02)
    geo.box((-1.2, 0, zt + .52), (.1, 2.4, 1.0), M('wood_y'), bevel=0.02)
    # parapeito nas faces frontais (x+, y+) e mãos-francesas
    parts.railing(0, 0, zt, 2.4, 2.4, mwd, sides=('x+', 'y+'), h=.58)
    for (x, y, dx, dy2) in ((1.2, 1.2, -.7, 0), (1.2, 1.2, 0, -.7), (-1.2, 1.2, .7, 0), (1.2, -1.2, 0, .7)):
        geo.beam((x + dx, y + dy2, zt + hp - .1), (x, y, zt + hp - .7), .1, .08, mwd, bevel=0.015)
    # telhado: pirâmide com beiral, cumeeiras nas quatro quinas e ponteira
    zr = zt + hp + .1
    geo.box((0, 0, zr - .03), (3.05, 3.05, .12), mwd, bevel=0.03)
    parts.geo.roof_pyramid(0, 0, zr, 2.05, 1.45, mr, sides=4, rot=45, overhang=.18, thickness=.1)
    for k in range(4):
        a = math.radians(45 + 90 * k)
        geo.beam((math.cos(a) * 2.2, math.sin(a) * 2.2, zr - .05), (0, 0, zr + 1.5), .14, .1, mwd, up=(0, 0, 1), bevel=0.02)
    geo.cyl((0, 0, zr + 1.35), .05, .75, mwd, sides=6)
    geo.cyl((0, 0, zr + 2.0), .09, .16, M('gold'), sides=8, r2=.02)
    # escada de mão na face +x até a plataforma
    lx = base / 2 - .02
    for sy in (-1, 1):
        geo.beam((lx + .35, .7 + sy * .22, 0), (lx + .1, .7 + sy * .22, zd + .55), .07, .06, mwd, up=(0, 1, 0), bevel=0.01)
    for i in range(1, int((zd + .3) / .36)):
        t = i * .36 / (zd + .55)
        geo.box((lx + .35 - .25 * t, .7, i * .36), (.05, .44, .05), mw, bevel=0.008)
    # lampião pendurado e tocha
    geo.cyl_between((1.2, 1.2, zt + hp - .1), (1.2, 1.2, zt + hp - .42), .015, M('iron'), sides=4)
    geo.box((1.2, 1.2, zt + hp - .62), (.2, .2, .28), M('glass'), bevel=0.02)
    geo.box((1.2, 1.2, zt + hp - .44), (.26, .26, .05), M('iron'), bevel=0.01)
    # bandeira
    geo.cyl((-.8, -.8, zr + .9), .035, 1.1, mwd, sides=6)
    parts.flag(-.8, -.8, zr + 1.25, .95, .5, M('cloth_red'), phase=f * 0.0 + 0.6)
    # barris e caixas ao pé + hera na face sombreada
    geo.cyl((-1.55, 1.25, 0), .3, .58, mwo, sides=14, r2=.27)
    geo.cyl((-1.55, 1.25, .55), .04, .02, M('iron'), sides=14)
    geo.box((1.55, -1.3, .22), (.5, .5, .44), mwo, rot=(0, 0, 14), bevel=0.03)
    geo.box((1.62, -1.05, .5), (.36, .36, .3), mwo, rot=(0, 0, -20), bevel=0.03)
    parts.ivy(-base / 2 + .1, base / 2 - .1, -base / 2 + .1, -.4, .3, 2.6, M('leaf'), seed=5, n=26)
    parts.grass_tufts(0, 0, 2.0, 20, M('grass'), seed=9)
    parts.flowers(0, 0, 2.0, 10, seed=11)


@landmark('str_watchtower_stone', group='city', folder='structures', size=(360, 520), origin=(180, 430), tags=('estrutura', 'torre', 'campos', 'vigia'), footprint=50, coll=(2.2, 2.2))
def tower_stone(f):
    build_watchtower(f, 'stone', 'roof_red')


@landmark('str_watchtower_frost', group='city', folder='structures', size=(360, 520), origin=(180, 430), tags=('estrutura', 'torre', 'gelo', 'vigia'), footprint=50, coll=(2.2, 2.2))
def tower_frost(f):
    build_watchtower(f, 'stone_frost', 'roof_snow', snowy=True)


# ------------------------------------------------------------------ moinho de vento
def ngon_shaft(cx, cy, z0, z1, r0, r1, sides, mat, rot=22.5, name='shaft', segs=3):
    from mathutils import Vector
    verts, faces = [], []
    for k in range(segs + 1):
        t = k / segs
        z = z0 + (z1 - z0) * t
        r = r0 + (r1 - r0) * t
        for i in range(sides):
            a = math.radians(rot + 360 * i / sides)
            verts.append((cx + math.cos(a) * r, cy + math.sin(a) * r, z))
    for k in range(segs):
        for i in range(sides):
            a, b = k * sides + i, k * sides + (i + 1) % sides
            faces.append((a, b, b + sides, a + sides))
    faces.append(tuple(reversed(range(sides))))
    faces.append(tuple(range(segs * sides, segs * sides + sides)))
    return geo.mesh_from(verts, faces, mat, name)


def ring_pt(cx, cy, z, r, sides, i, rot=22.5):
    a = math.radians(rot + 360 * i / sides)
    return (cx + math.cos(a) * r, cy + math.sin(a) * r, z)


@landmark('str_windmill', group='city', folder='structures', size=(500, 600), origin=(250, 500), frames=8, tags=('estrutura', 'moinho', 'fazenda', 'animado'), footprint=56, coll=(2.6, 2.6), samples=24)
def windmill(f):
    from mathutils import Matrix, Vector
    mp, ms, mw, mwd, mr = M('plaster'), M('stone'), M('wood'), M('wood_dark'), M('roof_thatch')
    sides, z0, z1, r0, r1 = 8, .3, 4.0, 1.75, 1.25
    # fundação de pedra + degraus
    geo.cyl((0, 0, 0), 1.98, .34, ms, sides=8, r2=1.9, bevel=0.03)
    ngon_shaft(0, 0, .3, 1.15, 1.85, 1.66, sides, ms, name='base_stone')
    parts.rubble(0, 0, 1.95, 12, M('rock'), seed=4, rmin=.12, rmax=.3)
    # corpo em taipa (afunilado) com madeirame
    ngon_shaft(0, 0, 1.1, z1, 1.66, r1, sides, mp, name='body')
    for i in range(sides):
        for z_a, r_a, z_b, r_b in ((1.1, 1.66, z1, r1),):
            pa, pb = ring_pt(0, 0, z_a, r_a + .03, sides, i), ring_pt(0, 0, z_b, r_b + .03, sides, i)
            geo.beam(pa, pb, .16, .13, mwd, bevel=0.02)
    for z in (1.1, 2.1, 3.1, z1 - .1):
        r = 1.66 + (r1 - 1.66) * (z - 1.1) / (z1 - 1.1)
        for i in range(sides):
            geo.beam(ring_pt(0, 0, z, r + .04, sides, i), ring_pt(0, 0, z, r + .04, sides, i + 1), .13, .12, mwd, bevel=0.02)
    # diagonais (mãos-francesas de taipa) nas faces visíveis
    for i in (0, 1, 2, 3, 4):
        r_lo = 1.66 - .06
        a0 = ring_pt(0, 0, 1.2, 1.68, sides, i)
        a1 = ring_pt(0, 0, 2.05, 1.6, sides, i + 1)
        geo.beam(a0, a1, .09, .1, mwd, bevel=0.015)
        b0 = ring_pt(0, 0, 2.2, 1.55, sides, i + 1)
        b1 = ring_pt(0, 0, 3.05, 1.46, sides, i)
        geo.beam(b0, b1, .09, .1, mwd, bevel=0.015)
    # porta com viga e alpendre, janelas com venezianas
    da = math.radians(22.5 + 360 * 1.5 / sides)          # face +x/+y (voltada ao observador)
    dx, dy = math.cos(da), math.sin(da)
    rr_ = 1.66 * math.cos(math.radians(22.5))
    def onface(u, z, out=0.0, face=1.5):
        a = math.radians(22.5 + 360 * face / sides)
        nx, ny = math.cos(a), math.sin(a)
        rad = 1.66 + (r1 - 1.66) * (z - 1.1) / (z1 - 1.1)
        rad *= math.cos(math.radians(22.5))
        return (nx * (rad + out) - ny * u, ny * (rad + out) + nx * u, z)
    def face_box(u, z, w, h, d, mat, face=1.5, bevel=0.02):
        a = math.radians(22.5 + 360 * face / sides)
        c = onface(u, z, d / 2, face)
        return geo.box(c, (d, w, h), mat, rot=(0, 0, math.degrees(a)), bevel=bevel)
    face_box(0, 1.05 + .0, .95, 1.5, .16, mwd, bevel=0.03)                         # porta
    face_box(0, 1.05, .78, 1.3, .2, mw, bevel=0.02)
    face_box(0, 1.85, 1.15, .14, .26, mwd, bevel=0.02)                              # verga
    face_box(0, 1.98, 1.4, .12, .4, mwd, bevel=0.02)                                # aba do alpendre
    for zz in (.55, 1.4):
        face_box(0, zz + .1 - .0, .66, .05, .24, M('iron'), bevel=0.005)
    face_box(.28, 1.05, .07, .07, .26, M('gold'), bevel=0.01)
    for u, fc in ((0, 0.5), (0, 2.5)):
        face_box(u, 2.8, .58, .72, .1, mwd, face=fc, bevel=0.02)
        face_box(u, 2.8, .46, .6, .14, M('glass'), face=fc, bevel=0.01)
        face_box(u - .36, 2.8, .26, .72, .16, mw, face=fc, bevel=0.015)
        face_box(u + .36, 2.8, .26, .72, .16, mw, face=fc, bevel=0.015)
    # galeria em balanço com guarda-corpo (mísulas, tábuas, corrimão)
    zg = 3.1
    rg = 1.6 * math.cos(math.radians(22.5))
    for i in range(sides):
        for k in range(2):
            p0 = ring_pt(0, 0, zg, 1.44, sides, i)
            p1 = ring_pt(0, 0, zg, 1.44, sides, i + 1)
            geo.beam(p0, p1, .22, .1, mw, bevel=0.02)
        pa = ring_pt(0, 0, zg + .5, 1.62, sides, i)
        geo.box((pa[0], pa[1], zg + .3), (.08, .08, .6), mwd, bevel=0.01)
        geo.beam(ring_pt(0, 0, zg + .6, 1.62, sides, i), ring_pt(0, 0, zg + .6, 1.62, sides, i + 1), .07, .06, mwd, bevel=0.01)
        geo.beam(ring_pt(0, 0, zg + .3, 1.62, sides, i), ring_pt(0, 0, zg + .3, 1.62, sides, i + 1), .05, .05, mwd, bevel=0.01)
        geo.beam(ring_pt(0, 0, zg - .05, 1.5, sides, i), ring_pt(0, 0, zg - .35, 1.32, sides, i), .1, .09, mwd, bevel=0.01)
    # cúpula de telhas/palha girante + friso
    geo.cyl((0, 0, z1 - .05), 1.34, .2, mwd, sides=16, bevel=0.02)
    parts.geo.roof_pyramid(0, 0, z1 + .12, 1.34, 1.35, mr, sides=16, rot=0, overhang=.22, thickness=.12)
    geo.cyl((0, 0, z1 + 1.42), .16, .3, mwd, sides=8, r2=.03)
    # eixo, cubo e rabo de orientação (leme + escora)
    ang = math.radians(78)
    ax = Vector((math.cos(ang), math.sin(ang), 0))
    hub = Vector((0, 0, 4.55)) + ax * 1.25
    geo.beam((0, 0, 4.55), tuple(hub + ax * .22), .28, .28, mwd, bevel=0.03)
    geo.cyl_between(tuple(hub - ax * .05), tuple(hub + ax * .38), .2, M('iron'), sides=10, r2=.14)
    tail = -ax
    geo.beam((0, 0, 4.45), tuple(Vector((0, 0, 3.55)) + tail * 2.2), .12, .12, mwd, bevel=0.02)
    geo.beam((0, 0, 4.7), tuple(Vector((0, 0, 3.75)) + tail * 2.1), .09, .09, mwd, bevel=0.02)
    # velas: 2 vigas cruzadas (4 braços) com treliça + lona no lado de fuga; rotação por quadro
    phase = f / 8 * 90.0
    up = Vector((0, 0, 1))
    side = ax.cross(up).normalized()
    def P(u, v, w=0.0, th=0.0):
        # u ao longo do braço, v transversal, w para fora do eixo; th = ângulo de rotação
        c, s_ = math.cos(math.radians(th)), math.sin(math.radians(th))
        return hub + side * (u * c - v * s_) + up * (u * s_ + v * c) + ax * w
    for k in range(4):
        th = phase + k * 90
        geo.beam(tuple(P(0.1, 0, .05, th)), tuple(P(3.55, 0, .05, th)), .12, .11, mwd, bevel=0.015)
        # lados do quadro da vela
        for v0 in (.34, .96):
            geo.beam(tuple(P(.75, v0, .1, th)), tuple(P(3.5, v0, .1, th)), .06, .06, mwd, bevel=0.01)
        for u in (.75, 1.25, 1.75, 2.25, 2.75, 3.25, 3.5):
            geo.beam(tuple(P(u, .32, .1, th)), tuple(P(u, .98, .1, th)), .05, .05, mwd, bevel=0.01)
        # lona
        verts = [tuple(P(.8, .38, .12, th)), tuple(P(3.3, .38, .12, th)), tuple(P(3.3, .92, .16, th)), tuple(P(.8, .92, .16, th))]
        geo.mesh_from(verts, [(0, 1, 2, 3)], M('sail'), 'canvas', smooth=True).modifiers.new('sol', 'SOLIDIFY').thickness = .02
        geo.beam(tuple(P(3.55, -.05, .05, th)), tuple(P(3.55, .98, .05, th)), .06, .08, mwd, bevel=0.01)
    # adereços: sacas, carroça com feno, barris, trigo, escada de degraus de pedra
    for i, (x, y) in enumerate(((-1.8, 1.0), (-1.55, 1.35), (-2.05, 1.45))):
        geo.box((x, y, .24 + (i == 2) * .04), (.5, .38, .46), M('cloth_cream'), rot=(0, 0, 20 * i), bevel=0.09)
    geo.cyl((1.75, -1.4, 0), .3, .6, M('wood_old'), sides=14, r2=.27)
    parts.grass_tufts(0, 0, 2.6, 26, M('grass'), seed=12, h=.34)
    parts.flowers(0, 0, 2.5, 8, seed=14)


def run(ids, preview_dir=None, write=True):
    from terrain_forms_data import footprint_circles
    ents = []
    for id in ids:
        fn, kw = REGISTRY[id]
        kw = dict(kw)
        kw.setdefault('inner', 0.0 if kw.get('group') in ('terrain', 'fx', 'interior') else 0.4)
        pad = kw.pop('pad', None)
        if pad is None:
            pad = 0 if kw.get('group') in ('interior', 'npc', 'fx') else (14 if id.startswith('fau_') else 26)     # folga anti-clipping (sombra/copas/bandeiras)
        if pad:
            w0, h0 = kw['size']
            ox, oy = kw['origin']
            kw['size'] = (w0 + 2 * pad, h0 + 2 * pad)
            kw['origin'] = (ox + pad, oy + pad)
        coll = kw.pop('coll', None)
        collision = footprint_circles(coll[0], coll[1], .85, .9) if coll else kw.pop('collision', None)
        e = asset.produce(id, kw.pop('group'), kw.pop('folder'), kw.pop('size'), kw.pop('origin'), fn, collision=collision,
                          preview=(str(Path(preview_dir) / f'{id}.png') if preview_dir else None), out_dir=(preview_dir if (not write and preview_dir) else None), **kw)
        ents.append(e)
        print('OK', id, e['frame_size'], flush=True)
    if write:
        asset.save_part([e for e in ents if not e.get('preview_only')])
    return ents


if __name__ == '__main__':
    args = sys.argv[1:]
    prev = None
    if '--preview' in args:
        i = args.index('--preview')
        prev = args[i + 1]
        args = args[:i] + args[i + 2:]
    write = '--nowrite' not in args
    args = [a for a in args if a != '--nowrite']
    ids = [i for i in REGISTRY if not args or any(i.startswith(a) for a in args)]
    run(ids, prev, write)
