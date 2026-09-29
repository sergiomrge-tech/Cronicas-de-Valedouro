"""VK — peças construtivas reutilizáveis (alvenaria, madeira, escadas, telhados, cordas, bandeiras, vegetação, pedras)."""
import math
import random

import bpy
from mathutils import Vector

from . import geo, mats

# --- paleta de materiais compartilhada (derivada dos APPROVED de Cidade)
_cache = {}


def M(key):
    if key in _cache:
        try:
            if _cache[key].name in bpy.data.materials:
                return _cache[key]
        except ReferenceError:
            pass
    f = {
        'stone': lambda: mats.masonry('stone', ('#4a2c26', '#8e5a44', '#cc8e5a', '#f2c684'), '#2a1a18', block=(0.8, 0.44), moss=0.5, wear=0.7),
        'stone_dark': lambda: mats.masonry('stone_dark', ('#2a2238', '#4c4468', '#7a7296', '#b0a8c8'), '#181426', block=(0.8, 0.44), moss=0.2, wear=0.7),
        'stone_frost': lambda: mats.masonry('stone_frost', ('#3a4460', '#6a7c9c', '#a4b8d0', '#e6f2fc'), '#242c44', block=(0.8, 0.44), wear=0.7),
        'stone_sand': lambda: mats.masonry('stone_sand', ('#5a3a2a', '#9c6a44', '#d49c62', '#f8d896'), '#3c2418', block=(0.8, 0.44), wear=0.7),
        'wood': lambda: mats.planks('wood', ('#3a2014', '#6a3c20', '#9a6438', '#d29a58'), along='x', width=0.3, length=2.2, aged=0.6),
        'wood_y': lambda: mats.planks('wood_y', ('#3a2014', '#6a3c20', '#9a6438', '#d29a58'), along='y', width=0.3, length=2.2, aged=0.6),
        'wood_dark': lambda: mats.planks('wood_dark', ('#20100c', '#48261a', '#74442a', '#a8703e'), along='x', width=0.26, length=2.0, aged=0.7),
        'wood_old': lambda: mats.planks('wood_old', ('#2c2624', '#5a4c42', '#8a7864', '#bcaa90'), along='x', width=0.28, length=2.0, aged=0.8),
        'roof_red': lambda: mats.shingles('roof_red', ('#3a1218', '#7b2a1e', '#b64d2c', '#e4884a')),
        'roof_slate': lambda: mats.shingles('roof_slate', ('#181a2c', '#343a58', '#5a6288', '#98a2c8'), mortar='#0c0e1c'),
        'roof_snow': lambda: mats.shingles('roof_snow', ('#5a6a8c', '#94a8c8', '#d0e0f0', '#ffffff'), mortar='#3c4a6a'),
        'roof_thatch': lambda: mats.shingles('roof_thatch', ('#5a3c14', '#94661e', '#c8961e', '#f0c84a'), w=0.18, h=0.14, mortar='#3a240c'),
        'iron': lambda: mats.flat('iron', '#3a3c4c', rough=0.45, spec=0.7, metallic=0.85),
        'gold': lambda: mats.flat('gold', '#d8a030', rough=0.35, spec=0.9, metallic=0.9),
        'rope': lambda: mats.flat('rope', '#a8884c', rough=0.95, bevel_wear=0.0),
        'leaf': lambda: mats.foliage('leaf', ('#0a3a20', '#146a26', '#2a9a24', '#68c42c', '#d0f04a')),
        'leaf_dry': lambda: mats.foliage('leaf_dry', ('#3a2a08', '#7a5a14', '#b48a1e', '#d8b43a', '#f4e070')),
        'cloth_red': lambda: mats.cloth('cloth_red', '#b8283a'),
        'cloth_blue': lambda: mats.cloth('cloth_blue', '#2450c8'),
        'cloth_cream': lambda: mats.cloth('cloth_cream', '#e8dcc0'),
        'cloth_green': lambda: mats.cloth('cloth_green', '#2a7a3a'),
        'glass': lambda: mats.emissive('glass', '#ffcc60', 5.0),
        'fire': lambda: mats.emissive('fire', '#ff9a30', 12.0),
        'hole': lambda: mats.flat('hole', '#0a0812', rough=1.0, spec=0.0, bevel_wear=0.0),
        'dirt': lambda: mats.flat('dirt', '#6a4a30', rough=1.0, spec=0.05, bevel_wear=0.0),
        'grass': lambda: mats.foliage('grass', ('#0a3a1a', '#1a6a20', '#3a9a24', '#7ac83a', '#c8ee4a')),
        'water': lambda: mats.water(),
        'hay': lambda: mats.flat('hay', '#d8ac38', rough=1.0, spec=0.05, bevel_wear=0.0),
        'sail': lambda: mats.cloth('sail', '#f0e8d4'),
        'plaster': lambda: mats.flat('plaster', '#c9b088', rough=0.95, spec=0.05, bevel_wear=0.4),
        'turf': lambda: mats.ground('turf', ('#0a3818', '#136a22', '#2a8e26', '#58b02e', '#96d244'), scale=4.0, dots='#f4f0c8'),
        'sand_ground': lambda: mats.ground('sand_ground', ('#8a4a2a', '#c07a44', '#e4a860', '#f8cf84', '#fff0b4'), scale=3.0),
        'snow_ground': lambda: mats.ground('snow_ground', ('#5a76b0', '#86a4d6', '#b4cfee', '#dbeaf8', '#f4faff'), scale=3.5),
        'glass_ice': lambda: mats.flat('glass_ice', '#a8dcff', rough=0.1, spec=0.8, emission='#6ab8ff', emission_strength=0.5, bevel_wear=0.0),
        'stripe_amber': lambda: mats.striped_cloth('stripe_amber', '#c8641e', '#f2dca0', freq=2.4),
        'stripe_blue': lambda: mats.striped_cloth('stripe_blue', '#2450c8', '#f0ead8', freq=2.4),
        'amber': lambda: mats.flat('amber', '#ffb030', rough=0.15, spec=0.8, emission='#ff8a10', emission_strength=1.6, bevel_wear=0.0),
        'rune': lambda: mats.emissive('rune', '#7ad8ff', 6.0),
        'bark_log': lambda: mats.planks('bark_log', ('#2a1a14', '#523424', '#7a5236', '#a87a52'), along='x', width=0.26, length=1.4, aged=0.8),
        'hull_wood': lambda: mats.planks('hull_wood', ('#20120c', '#4a2a1a', '#7a4a2a', '#b07a48'), along='x', width=0.16, length=1.6, aged=0.7),
        'hull_blue': lambda: mats.planks('hull_blue', ('#0c1a44', '#1a3a8a', '#2c62cc', '#78a4f0'), along='x', width=0.16, length=1.6, aged=0.5),
        'barn_red': lambda: mats.planks('barn_red', ('#3a0e0c', '#7a2018', '#a8362a', '#d8684a'), along='y', width=0.22, length=2.4, aged=0.6),
        'wheat': lambda: mats.flat('wheat', '#e6b82e', rough=0.85, spec=0.1, bevel_wear=0.0),
        'wheat_stalk': lambda: mats.flat('wheat_stalk', '#b8962a', rough=0.9, spec=0.05, bevel_wear=0.0),
        'cabbage': lambda: mats.foliage('cabbage', ('#0a3a28', '#1a6a3a', '#48a04a', '#96d070', '#d8f4a8')),
        'corn_gold': lambda: mats.flat('corn_gold', '#f0c62e', rough=0.6, spec=0.2, bevel_wear=0.0),
        'straw_hat': lambda: mats.flat('straw_hat', '#d8b45a', rough=0.95, spec=0.05, bevel_wear=0.2),
        'bark_tree': lambda: mats.bark('bark_tree', moss=0.5),
        'bark_pine': lambda: mats.bark('bark_pine', ('#241410', '#4a2a1c', '#7a4a2c', '#a87446')),
        'bark_birch': lambda: mats.bark('bark_birch', birch=True),
        'bark_dead': lambda: mats.bark('bark_dead', ('#221c1c', '#4a4040', '#7a6c62', '#a89a8a')),
        'needle': lambda: mats.foliage('needle', ('#06301e', '#0e5030', '#1e7a3a', '#48a848', '#8ccc60')),
        'needle_snow': lambda: mats.foliage('needle_snow', ('#0a2a2c', '#184a44', '#3a7860', '#c8e0ec', '#ffffff')),
        'leaf_birch': lambda: mats.foliage('leaf_birch', ('#124020', '#2a7028', '#58a830', '#98d040', '#d8ee66')),
        'palm': lambda: mats.foliage('palm', ('#083a24', '#12603a', '#28883a', '#58b83a', '#98da54')),
        'cactus': lambda: mats.foliage('cactus', ('#0a3a2c', '#155a3a', '#248a46', '#54b862', '#98dc8c')),
        'rock': lambda: mats.rock('rock', ('#2c1c22', '#684236', '#a46c40', '#d49a58', '#f6cc82'), moss=0.5),
        'rock_grey': lambda: mats.rock('rock_grey', ('#22203a', '#4a4a70', '#7a7ca4', '#aab0d0', '#e0e4f4'), moss=0.3),
        'rock_sand': lambda: mats.rock('rock_sand', ('#4a2420', '#8a4a2c', '#cc7a3c', '#f0aa5a', '#ffdc94'), strata=(5.0, 0.4)),
        'rock_ice': lambda: mats.rock('rock_ice', ('#1c2c5c', '#38609c', '#6a9ccc', '#a8d0ec', '#e8f6ff'), snow=0.6),
        'rock_snow': lambda: mats.rock('rock_snow', ('#2a2a40', '#54546e', '#88889e', '#bcbccc', '#ecf0f8'), snow=0.9),
    }[key]
    _cache[key] = f()
    return _cache[key]


def reset_cache():
    _cache.clear()


# ------------------------------------------------------------------ alvenaria
def tapered_shaft(cx, cy, z0, z1, base, top, mat, seed=0, wobble=0.015, name='shaft'):
    """Fuste quadrado com talude (mais largo embaixo), com pequena irregularidade nas quinas."""
    rr = random.Random(seed)
    def ring(z, s):
        h = s / 2
        return [(cx - h + rr.uniform(-wobble, wobble), cy - h + rr.uniform(-wobble, wobble), z), (cx + h + rr.uniform(-wobble, wobble), cy - h + rr.uniform(-wobble, wobble), z),
                (cx + h + rr.uniform(-wobble, wobble), cy + h + rr.uniform(-wobble, wobble), z), (cx - h + rr.uniform(-wobble, wobble), cy + h + rr.uniform(-wobble, wobble), z)]
    zs = [z0 + (z1 - z0) * i / 3 for i in range(4)]
    verts = []
    for i, z in enumerate(zs):
        verts += ring(z, base + (top - base) * i / 3)
    faces = []
    for i in range(3):
        for k in range(4):
            a, b = i * 4 + k, i * 4 + (k + 1) % 4
            faces.append((a, b, b + 4, a + 4))
    faces.append((0, 3, 2, 1))
    faces.append((12, 13, 14, 15))
    return geo.mesh_from(verts, faces, mat, name)


def quoins(cx, cy, z0, z1, base, top, mat, seed=0):
    """Cantoneiras: pedras maiores alternadas nas quinas (construção plausível)."""
    rr = random.Random(seed)
    objs = []
    n = int((z1 - z0) / 0.42)
    for i in range(n):
        z = z0 + i * (z1 - z0) / n
        s = base + (top - base) * (z - z0) / (z1 - z0)
        h = s / 2
        for sx, sy in ((1, 1), (1, -1), (-1, 1), (-1, -1)):
            long = 0.55 + rr.uniform(-.08, .12)
            # alterna a direção da pedra longa
            if (i + (sx > 0) + (sy > 0)) % 2:
                objs.append(geo.box((cx + sx * (h - long / 2 + .02), cy + sy * (h - .13 + .02), z + .2), (long, .3, .38), mat, bevel=0.025))
            else:
                objs.append(geo.box((cx + sx * (h - .13 + .02), cy + sy * (h - long / 2 + .02), z + .2), (.3, long, .38), mat, bevel=0.025))
    return objs


def boulder(loc, r, mat, seed=0, squash=0.75, detail=2, rough=0.35):
    rr = random.Random(seed)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=detail, radius=r)
    o = bpy.context.object
    for v in o.data.vertices:
        f = 1.0 + rr.uniform(-rough, rough) * 0.5
        v.co.x *= f * rr.uniform(.85, 1.15)
        v.co.y *= f * rr.uniform(.85, 1.15)
        v.co.z *= f * squash * rr.uniform(.8, 1.1)
    o.location = (loc[0], loc[1], loc[2] + r * squash * .55)
    o.rotation_euler = (0, 0, rr.uniform(0, 6.28))
    bpy.context.view_layer.update()
    bpy.context.view_layer.objects.active = o
    o.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    o.select_set(False)
    m = o.modifiers.new('b', 'BEVEL')
    m.width = r * 0.08
    m.segments = 1
    o.data.materials.append(mat)
    return o


def rubble(cx, cy, radius, n, mat, seed=0, rmin=.1, rmax=.28, ring=True):
    rr = random.Random(seed)
    out = []
    for i in range(n):
        a = rr.uniform(0, 6.283)
        d = radius * (rr.uniform(.85, 1.25) if ring else math.sqrt(rr.random()))
        out.append(boulder((cx + math.cos(a) * d, cy + math.sin(a) * d, 0), rr.uniform(rmin, rmax), mat, seed + i, squash=rr.uniform(.55, .9), detail=1))
    return out


# ------------------------------------------------------------------ madeira
def post_and_braces(x, y, z0, z1, mat, r=0.09):
    return geo.box((x, y, (z0 + z1) / 2), (r * 2, r * 2, z1 - z0), mat, bevel=0.02)


def deck(cx, cy, z, sx, sy, mat, mat_beam, thickness=0.12, overhang_beams=True):
    """Plataforma com tábuas visíveis e vigas de apoio projetando-se sob o piso."""
    out = [geo.box((cx, cy, z), (sx, sy, thickness), mat, bevel=0.02)]
    if overhang_beams:
        n = int(sx / 0.55)
        for i in range(n):
            x = cx - sx / 2 + (i + .5) * sx / n
            out.append(geo.box((x, cy, z - thickness / 2 - 0.09), (0.14, sy + 0.34, 0.16), mat_beam, bevel=0.02))
        for sgn in (-1, 1):
            out.append(geo.box((cx, cy + sgn * (sy / 2 + .04), z - thickness / 2 - 0.02), (sx + .1, .13, .22), mat_beam, bevel=0.02))
            out.append(geo.box((cx + sgn * (sx / 2 + .04), cy, z - thickness / 2 - 0.02), (.13, sy + .1, .22), mat_beam, bevel=0.02))
    return out


def railing(cx, cy, z, sx, sy, mat, sides=('x+', 'y+', 'x-', 'y-'), h=0.62, gaps=()):
    out = []
    posts = []
    for sd in sides:
        if sd in ('x+', 'x-'):
            x = cx + (sx / 2 - .06) * (1 if sd == 'x+' else -1)
            n = max(2, int(sy / 0.42))
            for i in range(n + 1):
                y = cy - sy / 2 + i * sy / n
                out.append(geo.box((x, y, z + h / 2), (.07, .07, h), mat, bevel=0.012))
            out.append(geo.box((x, cy, z + h), (.09, sy, .07), mat, bevel=0.015))
            out.append(geo.box((x, cy, z + h * .5), (.05, sy, .05), mat, bevel=0.01))
        else:
            y = cy + (sy / 2 - .06) * (1 if sd == 'y+' else -1)
            n = max(2, int(sx / 0.42))
            for i in range(n + 1):
                x = cx - sx / 2 + i * sx / n
                out.append(geo.box((x, y, z + h / 2), (.07, .07, h), mat, bevel=0.012))
            out.append(geo.box((cx, y, z + h), (sx, .09, .07), mat, bevel=0.015))
            out.append(geo.box((cx, y, z + h * .5), (sx, .05, .05), mat, bevel=0.01))
    return out


def ladder(x, y, z0, z1, mat, mat_rail, axis='y', spacing=0.34, width=0.44, tilt=0.0):
    """Escada de mão: banzos + degraus + suportes na parede."""
    out = []
    for sgn in (-1, 1):
        if axis == 'y':
            out.append(geo.beam((x + sgn * width / 2, y + tilt * 0, z0), (x + sgn * width / 2, y - tilt, z1), .07, .06, mat_rail, up=(1, 0, 0), bevel=0.01))
        else:
            out.append(geo.beam((x + tilt * 0, y + sgn * width / 2, z0), (x - tilt, y + sgn * width / 2, z1), .07, .06, mat_rail, up=(0, 1, 0), bevel=0.01))
    n = int((z1 - z0) / spacing)
    for i in range(1, n + 1):
        z = z0 + i * spacing - 0.1
        t = (z - z0) / (z1 - z0) * tilt
        if axis == 'y':
            out.append(geo.box((x, y - t, z), (width, .05, .05), mat, bevel=0.008))
        else:
            out.append(geo.box((x - t, y, z), (.05, width, .05), mat, bevel=0.008))
    return out


def rope(p0, p1, sag, r, mat, n=8):
    pts = [(p0[0] + (p1[0] - p0[0]) * t / n, p0[1] + (p1[1] - p0[1]) * t / n, p0[2] + (p1[2] - p0[2]) * t / n - sag * 4 * (t / n) * (1 - t / n)) for t in range(n + 1)]
    return [geo.cyl_between(pts[i], pts[i + 1], r, mat, sides=6) for i in range(n)]


def flag(x, y, z, length, height, mat, phase=0.0, dirv=(0.7071, -0.7071), wave=0.12, name='flag'):
    """Bandeira: malha subdividida com ondulação (dobras e peso) presa a um mastro."""
    nx, nz = 14, 6
    verts, faces = [], []
    for i in range(nx + 1):
        for j in range(nz + 1):
            u = i / nx
            v = j / nz
            off = math.sin(u * 6.0 + phase) * wave * u + math.sin(u * 3.1 + v * 1.7 + phase) * wave * .5 * u
            sag = -u * u * .08 * height
            verts.append((x + dirv[0] * u * length + (-dirv[1]) * off, y + dirv[1] * u * length + dirv[0] * off, z + v * height * (1 - .12 * u) + sag))
    for i in range(nx):
        for j in range(nz):
            a = i * (nz + 1) + j
            faces.append((a, a + nz + 1, a + nz + 2, a + 1))
    o = geo.mesh_from(verts, faces, mat, name, smooth=True)
    sol = o.modifiers.new('sol', 'SOLIDIFY')
    sol.thickness = 0.015
    return o


# ------------------------------------------------------------------ vegetação
def leaf_cluster(cx, cy, cz, radius, n, mat, seed=0, size=(.12, .2), flat=.55):
    """Massa de folhas: muitos ico-esferas achatados com orientação variada (silhueta recortada, não uma bola)."""
    rr = random.Random(seed)
    objs = []
    for i in range(n):
        a = rr.uniform(0, 6.283)
        b = math.acos(rr.uniform(-.2, 1))
        d = radius * (rr.random() ** .35)
        p = (cx + math.sin(b) * math.cos(a) * d, cy + math.sin(b) * math.sin(a) * d, cz + math.cos(b) * d * .8)
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=rr.uniform(*size))
        o = bpy.context.object
        o.scale = (1.0, rr.uniform(.8, 1.2), flat)
        o.location = p
        o.rotation_euler = (rr.uniform(-.7, .7), rr.uniform(-.7, .7), rr.uniform(0, 6.28))
        o.data.materials.append(mat)
        for pp in o.data.polygons:
            pp.use_smooth = False
        objs.append(o)
    return objs


def grass_tufts(cx, cy, radius, n, mat, seed=0, h=.28):
    rr = random.Random(seed)
    out = []
    for i in range(n):
        a = rr.uniform(0, 6.283)
        d = radius * math.sqrt(rr.random())
        x, y = cx + math.cos(a) * d, cy + math.sin(a) * d
        for k in range(rr.randint(5, 8)):
            lean = rr.uniform(-.25, .25)
            hh = h * rr.uniform(.6, 1.2)
            out.append(geo.cyl_between((x + rr.uniform(-.04, .04), y + rr.uniform(-.04, .04), 0), (x + lean, y + rr.uniform(-.2, .2) * .5, hh), .05, mat, sides=4, r2=.006))
    return out


def ivy(x0, y0, x1, y1, z0, z1, mat, seed=0, n=40):
    """Hera colada numa parede entre dois pontos do plano."""
    rr = random.Random(seed)
    out = []
    for i in range(n):
        t = rr.random()
        x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
        z = z0 + (z1 - z0) * rr.random() ** 1.6
        out += leaf_cluster(x, y, z, .16, 3, mat, seed + i, size=(.07, .12), flat=.45)
    return out


def flowers(cx, cy, radius, n, seed=0, colors=('#f6f0d8', '#ffd23a', '#ff7aa8', '#8ab4ff')):
    rr = random.Random(seed)
    out = []
    mm = [mats.flat('fl%d' % i, c, rough=0.7, spec=0.2, bevel_wear=0.0) for i, c in enumerate(colors)]
    for i in range(n):
        a = rr.uniform(0, 6.283)
        d = radius * math.sqrt(rr.random())
        x, y = cx + math.cos(a) * d, cy + math.sin(a) * d
        h = rr.uniform(.14, .26)
        out.append(geo.cyl_between((x, y, 0), (x, y, h), .012, M('grass'), sides=4))
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=rr.uniform(.05, .075))
        o = bpy.context.object
        o.location = (x, y, h)
        o.scale = (1, 1, .7)
        o.data.materials.append(rr.choice(mm))
        out.append(o)
    return out


# ------------------------------------------------------------------ rocha e terreno (massas deslocadas por ruído)
import bmesh
from mathutils import noise as _noise


def rock_mass(center, size, mat, seed=0, subdiv=4, rough=0.28, freq=1.1, terrace=0.0, step=0.5, taper=0.0, flat_top=False, name='rock', lean=(0, 0), squash_base=0.0):
    """Massa rochosa facetada: cubo subdividido, afunilamento, terraços (ledges) e ruído fractal ao longo da normal."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=subdiv, use_grid_fill=True)
    off = Vector((seed * 7.13, seed * 3.71, seed * 1.93))
    for v in bm.verts:
        p = v.co.copy()
        nz = p.z + .5                                   # 0..1
        sx, sy = size[0] * (1 - taper * nz), size[1] * (1 - taper * nz)
        x, y, z = p.x * sx, p.y * sy, nz * size[2]
        d = Vector((p.x, p.y, 0.0))
        dn = d.normalized() if d.length > 1e-6 else Vector((0, 0, 0))
        is_top = p.z > .49
        wp = Vector((x, y, z)) * freq + off
        n1 = _noise.fractal(wp, 0.8, 2.0, 4)
        n2 = _noise.turbulence(wp * 2.3 + Vector((11, 5, 3)), 3, False)
        amt = rough * (n1 * 0.9 + n2 * 0.5)
        if terrace > 0:
            zq = round(z / step) * step
            z = z + (zq - z) * terrace * (1 - nz * 0.3)
        # empurra para fora nas laterais e levemente nos cantos; topo plano se pedido
        if not (is_top and flat_top):
            x += dn.x * amt
            y += dn.y * amt
            z += amt * 0.35 * (0 if p.z < -.49 else 1)
        else:
            z += amt * 0.06
        if p.z < -.49:
            z = 0.0
            x *= 1 + squash_base
            y *= 1 + squash_base
        v.co = Vector((x + lean[0] * nz, y + lean[1] * nz, z))
    bm.normal_update()
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(o)
    o.location = center
    o.data.materials.append(mat)
    bpy.context.view_layer.objects.active = o
    o.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    o.select_set(False)
    return o


def slab_blob(cx, cy, z, sx, sy, thickness, mat, seed=0, wobble=0.12, rounds=14):
    """Tampa de terreno (relva/neve/areia) com contorno irregular e pequena espessura."""
    rr = random.Random(seed)
    n = 28
    verts = []
    for i in range(n):
        a = 2 * math.pi * i / n
        # super-elipse arredondada
        ca, sa = math.cos(a), math.sin(a)
        ex = math.copysign(abs(ca) ** .55, ca) * sx / 2
        ey = math.copysign(abs(sa) ** .55, sa) * sy / 2
        w = 1 + rr.uniform(-wobble, wobble)
        verts.append((cx + ex * w, cy + ey * w))
    vs = [(x, y, z) for x, y in verts] + [(x, y, z - thickness) for x, y in verts]
    faces = [tuple(range(n))[::-1], tuple(range(n, 2 * n))]
    for i in range(n):
        j = (i + 1) % n
        faces.append((i, j, j + n, i + n))
    o = geo.mesh_from(vs, faces, mat, 'slab')
    return o


def hanging_vines(x0, y0, x1, y1, z_top, length, n, mat, seed=0):
    rr = random.Random(seed)
    out = []
    for i in range(n):
        t = rr.random()
        x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
        L = length * rr.uniform(.4, 1.0)
        k = int(L / .16)
        for j in range(k):
            out += leaf_cluster(x + rr.uniform(-.03, .03), y + rr.uniform(-.03, .03), z_top - j * .16, .1, 2, mat, seed + i * 31 + j, size=(.06, .1), flat=.5)
    return out


def icicles(x0, y0, x1, y1, z, n, mat, seed=0):
    rr = random.Random(seed)
    out = []
    for i in range(n):
        t = rr.random()
        x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
        h = rr.uniform(.2, .6)
        out.append(geo.cyl((x, y, z - h), .05, h, mat, sides=5, r2=.0))
    return out


def dune_surface(cx, cy, z, sx, sy, mat, seed=0, wind=(1.0, .35), amp=.14, res=40):
    """Superfície de areia com ondulações orientadas pelo vento (cristas alongadas) — grade deslocada."""
    verts, faces = [], []
    wx, wy = wind
    L = math.hypot(wx, wy)
    wx, wy = wx / L, wy / L
    for i in range(res + 1):
        for j in range(res + 1):
            u, v = i / res - .5, j / res - .5
            x, y = u * sx, v * sy
            along = x * wx + y * wy
            across = -x * wy + y * wx
            rip = math.sin(across * 7.0 + math.sin(along * 1.4) * 1.3) * amp * (1 - (u * u + v * v) * 2.2)
            edge = max(0.0, 1 - (u * u + v * v) * 3.2)
            verts.append((cx + x, cy + y, z + (rip + .04) * (edge ** .5)))
    for i in range(res):
        for j in range(res):
            a = i * (res + 1) + j
            faces.append((a, a + res + 1, a + res + 2, a + 1))
    return geo.mesh_from(verts, faces, mat, 'dune', smooth=True)


# ------------------------------------------------------------------ tecido com dobras (tendas, toldos, velas)
def cloth_sheet(p00, p10, p01, p11, mat, nu=14, nv=8, sag=0.15, folds=0.05, fold_n=5, phase=0.0, thickness=0.02, name='cloth'):
    """Superfície regrada entre 4 cantos com caimento (sag) e dobras senoidais ao longo de u."""
    P = [Vector(p) for p in (p00, p10, p01, p11)]
    verts, faces = [], []
    for j in range(nv + 1):
        v = j / nv
        for i in range(nu + 1):
            u = i / nu
            a = P[0].lerp(P[1], u)
            b = P[2].lerp(P[3], u)
            pt = a.lerp(b, v)
            pt.z -= sag * 4 * u * (1 - u) * (0.4 + 0.6 * v)
            n = (b - a)
            off = math.sin(u * fold_n * math.pi + phase) * folds * (0.4 + v)
            side = Vector((-n.y, n.x, 0.0))
            if side.length > 1e-6:
                side.normalize()
            pt += side * off * 0.5
            pt.z += off * 0.5
            verts.append(tuple(pt))
    for j in range(nv):
        for i in range(nu):
            a = j * (nu + 1) + i
            faces.append((a, a + 1, a + nu + 2, a + nu + 1))
    o = geo.mesh_from(verts, faces, mat, name, smooth=True)
    sol = o.modifiers.new('sol', 'SOLIDIFY')
    sol.thickness = thickness
    return o


def plank_wall(p0, p1, z0, z1, mat, thickness=0.09, plank=0.22, seed=0, gap=0.012):
    """Parede de tábuas verticais individuais (com alturas e folgas levemente variadas)."""
    rr = random.Random(seed)
    a, b = Vector(p0), Vector(p1)
    L = (b - a).length
    n = max(1, int(L / plank))
    d = (b - a).normalized()
    out = []
    for i in range(n):
        c = a + d * ((i + .5) * L / n)
        h = (z1 - z0) - rr.uniform(0, .08)
        w = L / n - gap
        ang = math.degrees(math.atan2(d.y, d.x))
        out.append(geo.box((c.x, c.y, z0 + h / 2), (w, thickness, h), mat, rot=(0, 0, ang), bevel=0.01))
    return out
