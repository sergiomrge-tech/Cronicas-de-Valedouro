"""VK — geometria: primitivas com bevel, peças estruturais e deformações irregulares (assimetria controlada)."""
import math
import random

import bmesh
import bpy
import numpy as np
from mathutils import Euler, Matrix, Vector


def _finish(obj, mat=None, bevel=0.0, bevel_seg=2, smooth=False, name=None):
    if name:
        obj.name = name
    if mat is not None:
        obj.data.materials.clear()
        obj.data.materials.append(mat)
    if bevel > 0:
        m = obj.modifiers.new('bevel', 'BEVEL')
        m.width = bevel
        m.segments = bevel_seg
        m.limit_method = 'ANGLE'
        m.angle_limit = math.radians(35)
    if smooth:
        for p in obj.data.polygons:
            p.use_smooth = True
    return obj


def _apply_xform(obj, loc, rot, scale):
    obj.location = loc
    obj.rotation_euler = Euler(tuple(math.radians(a) for a in rot), 'XYZ')
    obj.scale = scale
    bpy.context.view_layer.update()
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    obj.select_set(False)


def box(loc, size, mat=None, rot=(0, 0, 0), bevel=0.02, name='box'):
    bpy.ops.mesh.primitive_cube_add(size=1)
    o = bpy.context.object
    o.scale = size
    _apply_xform(o, loc, rot, size)
    return _finish(o, mat, bevel, name=name)


def cyl(loc, r, h, mat=None, rot=(0, 0, 0), sides=16, r2=None, bevel=0.0, name='cyl', cap=True):
    bpy.ops.mesh.primitive_cone_add(vertices=sides, radius1=r, radius2=(r if r2 is None else r2), depth=h, end_fill_type='NGON' if cap else 'NOTHING')
    o = bpy.context.object
    _apply_xform(o, (loc[0], loc[1], loc[2] + h / 2), rot, (1, 1, 1))
    return _finish(o, mat, bevel, smooth=sides >= 10, name=name)


def cyl_between(a, b, r, mat=None, sides=8, r2=None, bevel=0.0, name='beam'):
    a, b = Vector(a), Vector(b)
    d = b - a
    L = d.length
    bpy.ops.mesh.primitive_cone_add(vertices=sides, radius1=r, radius2=(r if r2 is None else r2), depth=L)
    o = bpy.context.object
    o.rotation_mode = 'QUATERNION'
    o.rotation_quaternion = d.to_track_quat('Z', 'Y')
    o.location = (a + b) / 2
    bpy.context.view_layer.update()
    bpy.context.view_layer.objects.active = o
    o.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    o.select_set(False)
    return _finish(o, mat, bevel, smooth=sides >= 10, name=name)


def beam(a, b, w, t, mat=None, up=(0, 0, 1), bevel=0.02, name='beam'):
    """Viga retangular entre dois pontos (w = largura no plano 'up', t = espessura)."""
    a, b = Vector(a), Vector(b)
    d = b - a
    L = d.length
    bpy.ops.mesh.primitive_cube_add(size=1)
    o = bpy.context.object
    o.scale = (t, w, L)
    o.rotation_mode = 'QUATERNION'
    z = d.normalized()
    x = Vector(up).cross(z)
    if x.length < 1e-4:
        x = Vector((1, 0, 0))
    x.normalize()
    y = z.cross(x)
    Rm = Matrix((x, y, z)).transposed()
    o.rotation_quaternion = Rm.to_quaternion()
    o.location = (a + b) / 2
    bpy.context.view_layer.update()
    bpy.context.view_layer.objects.active = o
    o.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    o.select_set(False)
    return _finish(o, mat, bevel, name=name)


def mesh_from(verts, faces, mat=None, name='mesh', smooth=False, bevel=0.0, uvs=None):
    """uvs: lista (uma por face) de listas de (u,v) por vértice da face."""
    me = bpy.data.meshes.new(name)
    me.from_pydata([tuple(v) for v in verts], [], [tuple(f) for f in faces])
    me.update()
    if uvs is not None:
        layer = me.uv_layers.new(name='UVMap')
        i = 0
        for poly, fuv in zip(me.polygons, uvs):
            for k, uv in zip(poly.loop_indices, fuv):
                layer.data[k].uv = uv
    o = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(o)
    return _finish(o, mat, bevel, smooth=smooth, name=name)


def roof_gable(cx, cy, z0, sx, sy, h, mat, overhang=0.18, ridge_axis='x', thickness=0.1, name='roof'):
    """Telhado de duas águas com beiral e espessura visível (não é um prisma sólido)."""
    hx, hy = sx / 2 + overhang, sy / 2 + overhang
    if ridge_axis == 'x':
        pts = [(-hx, -hy, 0), (hx, -hy, 0), (hx, 0, h), (-hx, 0, h), (-hx, hy, 0), (hx, hy, 0)]
        faces = [(0, 1, 2, 3), (3, 2, 5, 4)]
    else:
        pts = [(-hx, -hy, 0), (-hx, hy, 0), (0, hy, h), (0, -hy, h), (hx, -hy, 0), (hx, hy, 0)]
        faces = [(0, 1, 2, 3), (3, 2, 5, 4)]
    hs = math.hypot(hy if ridge_axis == 'x' else hx, h)
    L = 2 * (hx if ridge_axis == 'x' else hy)
    uvs = [[(0, 0), (L, 0), (L, hs), (0, hs)], [(0, hs), (L, hs), (L, 0), (0, 0)]]
    o = mesh_from([(cx + p[0], cy + p[1], z0 + p[2]) for p in pts], faces, mat, name, uvs=uvs)
    sol = o.modifiers.new('solid', 'SOLIDIFY')
    sol.thickness = -thickness
    sol.offset = 1
    return o


def roof_pyramid(cx, cy, z0, r, h, mat, sides=4, rot=45, overhang=0.0, curve=0.0, thickness=0.08, name='roof'):
    verts = []
    for i in range(sides):
        a = math.radians(rot + 360 * i / sides)
        verts.append((cx + math.cos(a) * (r + overhang), cy + math.sin(a) * (r + overhang), z0))
    verts.append((cx, cy, z0 + h))
    faces = [(i, (i + 1) % sides, sides) for i in range(sides)]
    uvs = []
    for i in range(sides):
        a, b = Vector(verts[i]), Vector(verts[(i + 1) % sides])
        L = (b - a).length
        mid = (a + b) / 2
        s_len = (Vector(verts[sides]) - mid).length
        uvs.append([(0, 0), (L, 0), (L / 2, s_len)])
    o = mesh_from(verts, faces, mat, name, uvs=uvs)
    sol = o.modifiers.new('solid', 'SOLIDIFY')
    sol.thickness = -thickness
    sol.offset = 1
    return o


def displace_mesh(obj, strength=0.3, scale=1.0, seed=0, subdiv=2, detail=True, noise_type='CLOUDS', depth=3):
    """Deforma a malha com ruído (rocha/terreno): subdivide e desloca vértices ao longo da normal."""
    if subdiv:
        m = obj.modifiers.new('sub', 'SUBSURF')
        m.subdivision_type = 'SIMPLE'
        m.levels = subdiv
        m.render_levels = subdiv
    tex = bpy.data.textures.new('dsp', 'CLOUDS')
    tex.noise_scale = scale
    tex.noise_depth = depth
    tex.noise_basis = 'BLENDER_ORIGINAL'
    d = obj.modifiers.new('disp', 'DISPLACE')
    d.texture = tex
    d.strength = strength
    d.mid_level = 0.5
    d.texture_coords = 'OBJECT'
    return obj


def join(objs, name='joined'):
    objs = [o for o in objs if o is not None]
    if not objs:
        return None
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    o = bpy.context.object
    o.name = name
    return o


def jitter(obj, amount=0.02, seed=0):
    """Assimetria controlada: desloca vértices aleatoriamente (aplique antes dos modificadores)."""
    rr = random.Random(seed)
    me = obj.data
    for v in me.vertices:
        v.co.x += rr.uniform(-amount, amount)
        v.co.y += rr.uniform(-amount, amount)
        v.co.z += rr.uniform(-amount, amount)
    me.update()
    return obj


def rot_z(deg):
    return (0, 0, deg)


def rotate_all(deg, objs=None):
    """Gira todos os objetos de malha em torno do eixo Z na origem (para orientar a frente de um asset ao observador)."""
    objs = [o for o in (objs if objs is not None else bpy.data.objects) if o.type == 'MESH']
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    for o in objs:
        o.rotation_euler = (0, 0, math.radians(deg))
        o.select_set(True)
    # rotaciona em torno da origem do mundo: origem de cada objeto já está em 0 após transform_apply
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    bpy.ops.object.select_all(action='DESELECT')


def boolean_cut(target, cutter, cutter_mat=None):
    """Subtrai `cutter` de `target` (interior recebe o material do cortador) e remove o cortador."""
    if cutter_mat is not None:
        cutter.data.materials.clear()
        cutter.data.materials.append(cutter_mat)
    m = target.modifiers.new('cut', 'BOOLEAN')
    m.operation = 'DIFFERENCE'
    m.object = cutter
    m.solver = 'EXACT'
    try:
        m.material_mode = 'TRANSFER'
    except Exception:
        pass
    bpy.context.view_layer.objects.active = target
    bpy.ops.object.modifier_apply(modifier='cut')
    bpy.data.objects.remove(cutter, do_unlink=True)
    return target
