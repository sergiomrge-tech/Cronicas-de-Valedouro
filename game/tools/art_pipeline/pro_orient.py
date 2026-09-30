"""Kit modular multi-ângulo (correção estrutural, categoria A): módulos lineares deixam de existir só numa diagonal.

Para cada FAMÍLIA linear (muros, muralhas, paliçadas, barricadas, cercas, paredes vivas, muros de ruína) gera automaticamente:
  * `<id>_a1 … <id>_a7`: a mesma peça girada em passos de 22,5° (o base é a0) → retas em 8 direções na tela e curvas suaves por encadeamento;
  * `<id>_c0 … <id>_c3`: peça de CANTO em L (dois segmentos que se encontram no pé/âncora), nos 4 quadrantes.
A rotação é feita no Blender (renderização real, luz e sombra corretas): NÃO é espelhamento de sprite.
A colisão é recalculada da geometria girada (círculos ao longo do eixo de corrida, projetados como a projeção 2:1 do jogo)."""
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import bpy
from vk import geo
from pro_landmarks import REGISTRY, landmark

# id da família → True se o base tem colisão (mantém o comportamento do original)
FAMILIES = {
    'val_wall_segment': True, 'val_wall_repaired': True, 'val_wall_breach': True,
    'val_palisade_broken': True, 'flo_palisade_organic': True, 'flo_palisade_broken': True,
    'val_barricade_a': True, 'val_barricade_b': True, 'flo_barricade_improvised': True,
    'nat_fence_wood_a': False, 'nat_fence_wood_b': False, 'nat_fence_broken_a': False, 'nat_fence_broken_b': False,
    'nat_wall_low_a': False, 'nat_wall_low_b': False,
    'flo_hollow_wall_active': False, 'flo_hollow_wall_dormant': False, 'flo_heart_wall': False,
    'val_ruin_inscription_wall': True, 'flo_cart_ruin_wall': True, 'nat_ruin_wall': False,
    'val_crypt_wall': False, 'val_mine_rock_wall': False, 'val_mine_rock_wall_eco': False, 'val_mine_rock_wall_eco_dormant': False,
}
STEP = 22.5
N_ANGLES = 8


def _meshes():
    return [o for o in bpy.data.objects if o.type == 'MESH']


def _bake():
    """Assa matrix_world na malha (sem operadores: robusto a dados de malha compartilhados) e zera os transforms."""
    from mathutils import Matrix
    objs = _meshes()
    for o in objs:
        if o.data.users > 1:
            o.data = o.data.copy()
        o.data.transform(o.matrix_world)
        o.matrix_world = Matrix.Identity(4)
    bpy.context.view_layer.update()
    return objs


def _verts_xy(objs):
    pts = []
    for o in objs:
        for v in o.data.vertices:
            pts.append((v.co.x, v.co.y))
    return pts


def _axis(objs):
    """Eixo de corrida = direção que MINIMIZA a largura perpendicular (varredura de 1°); devolve centro, u, w, extensões (t0,t1) e (d0,d1)."""
    pts = _verts_xy(objs)
    best = None
    for a in range(0, 180):
        r = math.radians(a)
        u = (math.cos(r), math.sin(r))
        w = (-u[1], u[0])
        ds = [p[0] * w[0] + p[1] * w[1] for p in pts]
        span = max(ds) - min(ds)
        if best is None or span < best[0] - 1e-6:
            best = (span, u, w)
    _, u, w = best
    ts = [p[0] * u[0] + p[1] * u[1] for p in pts]
    ds = [p[0] * w[0] + p[1] * w[1] for p in pts]
    t0, t1, d0, d1 = min(ts), max(ts), min(ds), max(ds)
    tc, dc = (t0 + t1) / 2, (d0 + d1) / 2
    c = (u[0] * tc + w[0] * dc, u[1] * tc + w[1] * dc)
    return c, u, w, (t0, t1), (d0, d1)


def _rotate(objs, deg):
    from mathutils import Matrix
    m = Matrix.Rotation(math.radians(deg), 4, 'Z')
    for o in objs:
        if o.data.users > 1:
            o.data = o.data.copy()
        o.data.transform(m)


def _shift(objs, dx, dy):
    from mathutils import Matrix
    m = Matrix.Translation((dx, dy, 0))
    for o in objs:
        if o.data.users > 1:
            o.data = o.data.copy()
        o.data.transform(m)


def _duplicate(objs):
    out = []
    for o in objs:
        n = o.copy()
        n.data = o.data.copy()
        bpy.context.collection.objects.link(n)
        out.append(n)
    return out


def _iso(x, y):
    """Projeção do jogo (60 px/u de render, 30 px/u em jogo): mesmo mapa de `circ()` nos scripts de asset."""
    return (round(.7071 * (y - x) * 30, 1), round(.5 * .7071 * (x + y) * 30, 1))


def _collision(objs, footprint_scale=1.0):
    """Círculos ao longo do eixo de corrida, na geometria já girada."""
    _, u, w, (t0, t1), (d0, d1) = _axis(objs)
    (mx, my) = _axis(objs)[0]
    L = t1 - t0
    depth = max(d1 - d0, .5)
    n = max(1, int(math.ceil(L / .9)))
    r = round(max(9.0, depth * 30 * .5 * .7071 * 1.05) * footprint_scale, 1)
    out = []
    for i in range(n):
        t = t0 + (i + .5) * L / n
        x, y = mx + u[0] * t, my + u[1] * t
        sx, sy = _iso(x, y)
        out.append((sx, sy, r))
    return tuple(out)


def _screen_axis(objs):
    """Direção de corrida NA TELA (graus, 0 = →, 90 = ↓, módulo 180) e comprimento em px de jogo."""
    (cx, cy), u, w, (t0, t1), (d0, d1) = _axis(objs)
    a = _iso(u[0], u[1])
    ang = math.degrees(math.atan2(a[1], a[0])) % 180.0
    return {'deg': round(ang, 1), 'len_px': round((t1 - t0) * math.hypot(*a), 1), 'depth_px': round((d1 - d0) * 15, 1)}


def _resize(kw, bigger):
    w, h = kw['size']
    ox, oy = kw['origin']
    w2 = int(max(w, h) * (1.95 if bigger else 1.4))
    h2 = int(h + w * (.9 if bigger else .45))
    kw['size'] = (w2, h2)
    kw['origin'] = (w2 // 2, h2 - (h - oy))


def _register(base_id, fn, kw, suffix, builder, collide, bigger=False):
    nk = dict(kw)
    nk['tags'] = tuple(kw.get('tags', ())) + ('orientacao', 'kit_modular')
    _resize(nk, bigger)
    nk.pop('coll', None)
    if not collide:
        nk['collision'] = ()
    REGISTRY[f'{base_id}_{suffix}'] = (builder, nk)


def _make_angle(fn, k, collide, holder):
    def build(f):
        fn(f)
        objs = _bake()
        _rotate(objs, STEP * k)
        import os
        if os.environ.get('ORIENT_DEBUG'):
            print('DBG angle', STEP * k, len(objs), _axis(_bake())[1], flush=True)
        holder['coll'] = _collision(_bake()) if collide else ()
        holder['axis'] = _screen_axis(_bake())
    return build


def _make_corner(fn, q, collide, holder):
    def build(f):
        fn(f)
        objs = _bake()
        (cx, cy), u, w, (t0, t1), (d0, d1) = _axis(objs)
        L = t1 - t0
        # centro do segmento na origem, depois UMA extremidade no pé (canto do L)
        _shift(objs, -cx + u[0] * L / 2, -cy + u[1] * L / 2)
        dup = _duplicate(objs)
        _rotate(dup, 90)
        allo = _bake()
        if q:
            _rotate(allo, 90 * q)
        holder['coll'] = _collision(_bake()) if collide else ()
        holder['axis'] = _screen_axis(_bake())
    return build


_ORIG = dict(REGISTRY)
for _id, _collide in FAMILIES.items():
    if _id not in _ORIG:
        continue
    _fn, _kw = _ORIG[_id]
    for _k in range(1, N_ANGLES):
        _holder = {}
        _b = _make_angle(_fn, _k, _collide, _holder)
        _register(_id, _fn, _kw, f'a{_k}', _b, _collide)
        REGISTRY[f'{_id}_a{_k}'][1]['collision_holder'] = _holder
    for _q in range(4):
        _holder = {}
        _b = _make_corner(_fn, _q, _collide, _holder)
        _register(_id, _fn, _kw, f'c{_q}', _b, _collide, bigger=True)
        REGISTRY[f'{_id}_c{_q}'][1]['collision_holder'] = _holder
