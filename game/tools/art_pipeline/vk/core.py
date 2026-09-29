"""VK — núcleo do pipeline Blender de Valedouro.

Câmera ortográfica dimétrica 2:1 (AZ 45°, EL 30°), luz global upper-left, render em resolução final (60 px por unidade de mundo,
mesma convenção dos assets modelados) com sombra de contato em passada separada.

Executar com o Python do bpy (ver README): `python -m ...` a partir de um script que importe `vk.core`.
"""
import math
import sys
from pathlib import Path

import bpy
import numpy as np
from mathutils import Vector
from PIL import Image

PX_PER_UNIT = 60.0
AZ = 45.0
EL = 30.0

# direção PARA a luz (mundo): esquerda da tela + um pouco em direção à câmera + alto (luz principal upper-left)
def _light_vec():
    az = math.radians(AZ)
    right = Vector((-math.sin(az), math.cos(az), 0.0))
    toward_cam = Vector((math.cos(az), math.sin(az), 0.0))
    return (-right * 0.78 + toward_cam * 0.34 + Vector((0, 0, 1.15))).normalized()


LIGHT_VEC = _light_vec()


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    for coll in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for item in list(coll):
            coll.remove(item)


def _configure_render(w, h, samples):
    sc = bpy.context.scene
    r = sc.render
    r.engine = 'CYCLES'
    sc.cycles.device = 'CPU'
    sc.cycles.samples = samples
    sc.cycles.use_denoising = False
    sc.cycles.filter_width = 0.01          # sem antialiasing suave: bordas duras (alpha endurecido depois)
    sc.cycles.max_bounces = 4
    sc.cycles.diffuse_bounces = 3
    sc.cycles.glossy_bounces = 2
    r.resolution_x, r.resolution_y, r.resolution_percentage = w, h, 100
    r.film_transparent = True
    r.image_settings.file_format = 'PNG'
    r.image_settings.color_mode = 'RGBA'
    r.image_settings.color_depth = '8'
    sc.view_settings.view_transform = 'Standard'
    sc.view_settings.look = 'None'
    sc.view_settings.exposure = -0.55
    sc.view_settings.gamma = 1.0


def make_rig(w, h, origin, scale=PX_PER_UNIT, sun_energy=5.2, sky=(0.55, 0.62, 0.86), sky_strength=0.42, light_vec=None, az=None, el=None):
    """Câmera + luz. `origin` = pixel onde cai o ponto (0,0,0) do mundo (âncora do pé)."""
    sc = bpy.context.scene
    _configure_render(w, h, 32)
    az, el = math.radians(AZ if az is None else az), math.radians(EL if el is None else el)
    d = Vector((math.cos(el) * math.cos(az), math.cos(el) * math.sin(az), math.sin(el)))
    cam_data = bpy.data.cameras.new('cam')
    cam_data.type = 'ORTHO'
    cam_data.ortho_scale = max(w, h) / scale
    cam_data.clip_start, cam_data.clip_end = 0.1, 200.0
    cam = bpy.data.objects.new('cam', cam_data)
    sc.collection.objects.link(cam)
    cam.location = d * 60.0
    cam.rotation_mode = 'QUATERNION'
    cam.rotation_quaternion = (-d).to_track_quat('-Z', 'Y')
    # shift: a origem fica no centro do quadro; move para (ox, oy)
    m = max(w, h)
    cam_data.shift_x = (w / 2.0 - origin[0]) / m
    cam_data.shift_y = (origin[1] - h / 2.0) / m
    sc.camera = cam
    lv = light_vec if light_vec is not None else LIGHT_VEC
    sun_data = bpy.data.lights.new('sun', 'SUN')
    sun_data.energy = sun_energy
    sun_data.angle = math.radians(2.5)
    sun = bpy.data.objects.new('sun', sun_data)
    sc.collection.objects.link(sun)
    sun.rotation_mode = 'QUATERNION'
    sun.rotation_quaternion = lv.to_track_quat('Z', 'Y')
    world = bpy.data.worlds.new('w')
    sc.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes['Background']
    bg.inputs['Color'].default_value = (sky[0], sky[1], sky[2], 1.0)
    bg.inputs['Strength'].default_value = sky_strength
    return cam, sun


def add_catcher(size=40.0):
    bpy.ops.mesh.primitive_plane_add(size=size, location=(0, 0, 0))
    plane = bpy.context.object
    plane.name = 'catcher'
    plane.is_shadow_catcher = True
    return plane


def _render_to(path):
    sc = bpy.context.scene
    sc.render.filepath = str(path)
    bpy.ops.render.render(write_still=True)
    return np.asarray(Image.open(path).convert('RGBA'), dtype=np.uint8).copy()


SHADOW_LIGHT = Vector((-0.30, 0.10, 1.0)).normalized()     # sombra de contato compacta (luz alta, levemente da esquerda/atrás)


def render_frame(path_tmp, catcher_shadow=True):
    """Devolve (asset_rgba, shadow_alpha) como arrays uint8. Duas passadas: com e sem o captador de sombra."""
    sc = bpy.context.scene
    sun = bpy.data.objects.get('sun')
    key_q = sun.rotation_quaternion.copy() if sun else None
    catcher = bpy.data.objects.get('catcher')
    if catcher is not None:
        catcher.hide_render = True
    asset = _render_to(path_tmp)
    shadow = np.zeros(asset.shape[:2], dtype=np.uint8)
    if catcher_shadow:
        if catcher is None:
            catcher = add_catcher()
        catcher.hide_render = False
        if sun is not None:
            az = math.radians(AZ)
            right = Vector((-math.sin(az), math.cos(az), 0.0))
            sv = (-right * 0.42 + Vector((math.cos(az), math.sin(az), 0.0)) * 0.12 + Vector((0, 0, 1.0))).normalized()
            sun.rotation_quaternion = sv.to_track_quat('Z', 'Y')
        combo = _render_to(path_tmp)
        catcher.hide_render = True
        if sun is not None and key_q is not None:
            sun.rotation_quaternion = key_q
        sh = combo[..., 3].astype(np.int32)
        sh[asset[..., 3] > 8] = 0
        shadow = np.clip(sh, 0, 255).astype(np.uint8)
    return asset, shadow


def id_pass(path_tmp):
    """Passada de IDs por objeto (emissão com cor aleatória por objeto, sem antialias): serve para linhas internas entre partes."""
    sc = bpy.context.scene
    catcher = bpy.data.objects.get('catcher')
    if catcher is not None:
        catcher.hide_render = True
    m = bpy.data.materials.new('idpass')
    m.use_nodes = True
    t = m.node_tree
    for n in list(t.nodes):
        t.nodes.remove(n)
    oi = t.nodes.new('ShaderNodeObjectInfo')
    out = t.nodes.new('ShaderNodeOutputMaterial')
    em = t.nodes.new('ShaderNodeEmission')
    comb = t.nodes.new('ShaderNodeCombineXYZ')
    for i, k in enumerate((7.13, 13.7, 3.31)):
        mul = t.nodes.new('ShaderNodeMath'); mul.operation = 'MULTIPLY'; mul.inputs[1].default_value = k
        fr = t.nodes.new('ShaderNodeMath'); fr.operation = 'FRACT'
        t.links.new(oi.outputs['Random'], mul.inputs[0]); t.links.new(mul.outputs[0], fr.inputs[0]); t.links.new(fr.outputs[0], comb.inputs[i])
    t.links.new(comb.outputs[0], em.inputs['Color'])
    t.links.new(em.outputs[0], out.inputs['Surface'])
    vl = bpy.context.view_layer
    vl.material_override = m
    old = (sc.cycles.samples, sc.cycles.use_denoising, sc.view_settings.exposure)
    sc.cycles.samples, sc.cycles.use_denoising, sc.view_settings.exposure = 1, False, 0.0
    arr = _render_to(path_tmp)
    sc.cycles.samples, sc.cycles.use_denoising, sc.view_settings.exposure = old
    vl.material_override = None
    return arr


def clear_objects():
    for o in list(bpy.data.objects):
        if o.type in ('MESH', 'CURVE', 'EMPTY', 'SURFACE', 'FONT'):
            bpy.data.objects.remove(o, do_unlink=True)


def apply_all_modifiers(objs=None):
    """Aplica modificadores (necessário antes de juntar/renderizar com exatidão)."""
    dg = bpy.context.evaluated_depsgraph_get()
    for o in list(objs if objs is not None else bpy.data.objects):
        if o.type != 'MESH' or not o.modifiers:
            continue
        ev = o.evaluated_get(dg)
        me = bpy.data.meshes.new_from_object(ev)
        old = o.data
        o.modifiers.clear()
        o.data = me
        if old.users == 0:
            bpy.data.meshes.remove(old)
