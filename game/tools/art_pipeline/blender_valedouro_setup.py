# Run inside Blender's Scripting workspace.
# Crônicas de Valedouro — fixed 2:1 dimetric pre-render rig.
#
# This rig mirrors the current Valedouro modeler projection:
# AZ = 45 degrees, camera elevation = 30 degrees.
# The approved in-game assets remain the final visual authority.

import bpy
import math
from mathutils import Vector

COLLECTION_NAME = "VALEDOURO_RENDER_RIG"
CAMERA_NAME = "Valedouro_Dimetric_Camera"
KEY_NAME = "Valedouro_Key"
FILL_NAME = "Valedouro_Fill"

OUTPUT_W = 256
OUTPUT_H = 256
ORTHO_SCALE = 5.0
AZIMUTH_DEG = 45.0
ELEVATION_DEG = 30.0
CAMERA_RADIUS = 10.0
LOOK_AT = Vector((0.0, 0.0, 1.25))


def remove_named_object(name: str) -> None:
    obj = bpy.data.objects.get(name)
    if obj is not None:
        bpy.data.objects.remove(obj, do_unlink=True)


def ensure_collection(name: str):
    col = bpy.data.collections.get(name)
    if col is None:
        col = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(col)
    return col


def link_only_to(obj, collection):
    for col in list(obj.users_collection):
        col.objects.unlink(obj)
    collection.objects.link(obj)


def camera_position(radius: float, azimuth_deg: float, elevation_deg: float) -> Vector:
    az = math.radians(azimuth_deg)
    el = math.radians(elevation_deg)
    horizontal = radius * math.cos(el)
    return Vector((
        horizontal * math.cos(az),
        horizontal * math.sin(az),
        radius * math.sin(el),
    ))


def point_camera_at(cam, target: Vector) -> None:
    direction = target - cam.location
    cam.rotation_mode = "QUATERNION"
    cam.rotation_quaternion = direction.to_track_quat("-Z", "Y")


def create_camera(collection):
    remove_named_object(CAMERA_NAME)
    cam_data = bpy.data.cameras.new(CAMERA_NAME)
    cam = bpy.data.objects.new(CAMERA_NAME, cam_data)
    collection.objects.link(cam)

    # Matches game/tools/modeling/kit.py: AZ=45°, EL=30°.
    cam.location = camera_position(CAMERA_RADIUS, AZIMUTH_DEG, ELEVATION_DEG)
    point_camera_at(cam, LOOK_AT)
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = ORTHO_SCALE
    cam.data.lens = 50.0
    cam.data.dof.use_dof = False
    bpy.context.scene.camera = cam
    return cam


def create_sun(name, rotation_deg, energy, collection):
    remove_named_object(name)
    data = bpy.data.lights.new(name=name, type="SUN")
    data.energy = energy
    data.angle = math.radians(3.0)
    obj = bpy.data.objects.new(name, data)
    collection.objects.link(obj)
    obj.rotation_mode = "XYZ"
    obj.rotation_euler = tuple(math.radians(v) for v in rotation_deg)
    return obj


def create_fill(collection):
    remove_named_object(FILL_NAME)
    data = bpy.data.lights.new(name=FILL_NAME, type="AREA")
    data.energy = 120.0
    data.shape = "DISK"
    data.size = 8.0
    obj = bpy.data.objects.new(FILL_NAME, data)
    collection.objects.link(obj)
    obj.location = (-4.0, 2.0, 6.0)

    direction = Vector((0.0, 0.0, 1.2)) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    return obj


def configure_scene():
    scene = bpy.context.scene

    scene.render.film_transparent = True
    scene.render.resolution_x = OUTPUT_W
    scene.render.resolution_y = OUTPUT_H
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.image_settings.color_depth = "8"

    if hasattr(scene.render, "use_motion_blur"):
        scene.render.use_motion_blur = False

    try:
        scene.view_settings.view_transform = "Standard"
    except Exception:
        pass
    try:
        scene.view_settings.look = "Medium High Contrast"
    except Exception:
        pass

    world = scene.world
    if world is None:
        world = bpy.data.worlds.new("Valedouro_World")
        scene.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes.get("Background")
    if bg:
        bg.inputs["Color"].default_value = (0.055, 0.045, 0.07, 1.0)
        bg.inputs["Strength"].default_value = 0.28


def make_contact_plane(collection):
    name = "Valedouro_Shadow_Catcher"
    remove_named_object(name)
    bpy.ops.mesh.primitive_plane_add(size=20.0, location=(0.0, 0.0, 0.0))
    plane = bpy.context.object
    plane.name = name
    link_only_to(plane, collection)

    mat = bpy.data.materials.get("Valedouro_Shadow_Plane_Mat")
    if mat is None:
        mat = bpy.data.materials.new("Valedouro_Shadow_Plane_Mat")
        mat.diffuse_color = (0.18, 0.20, 0.18, 1.0)
        mat.roughness = 1.0
    plane.data.materials.append(mat)
    plane.hide_render = True
    return plane


def make_projection_calibration(collection):
    # Ground diamond / unit cross. Keep disabled for final render.
    name = "Valedouro_Projection_Calibration"
    old = bpy.data.objects.get(name)
    if old is not None:
        bpy.data.objects.remove(old, do_unlink=True)

    mesh = bpy.data.meshes.new(name + "_Mesh")
    verts = [
        (-1.0, 0.0, 0.01),
        (0.0, 1.0, 0.01),
        (1.0, 0.0, 0.01),
        (0.0, -1.0, 0.01),
    ]
    mesh.from_pydata(verts, [], [(0, 1, 2, 3)])
    mesh.update()

    obj = bpy.data.objects.new(name, mesh)
    collection.objects.link(obj)
    obj.display_type = "WIRE"
    obj.hide_render = True

    # Hero-scale pole: a stable height cue for doors/NPCs/props.
    pole_name = "Valedouro_HeroScale_Reference"
    remove_named_object(pole_name)
    bpy.ops.mesh.primitive_cube_add(location=(-1.7, -1.7, 0.9))
    pole = bpy.context.object
    pole.name = pole_name
    pole.scale = (0.06, 0.06, 0.9)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    link_only_to(pole, collection)
    pole.hide_render = True

    return obj, pole


def create_rig():
    col = ensure_collection(COLLECTION_NAME)
    configure_scene()
    create_camera(col)

    create_sun(KEY_NAME, (38.0, -28.0, -42.0), 2.0, col)
    create_fill(col)
    make_contact_plane(col)
    make_projection_calibration(col)

    scene = bpy.context.scene
    scene["valedouro_projection"] = "2:1_dimetric_locked"
    scene["valedouro_camera_azimuth_deg"] = AZIMUTH_DEG
    scene["valedouro_camera_elevation_deg"] = ELEVATION_DEG
    scene["valedouro_projection_source"] = "game/tools/modeling/kit.py"
    scene["valedouro_output_px"] = f"{OUTPUT_W}x{OUTPUT_H}"

    print("Valedouro render rig ready: AZ=45°, EL=30°, orthographic.")
    print("Calibrate ORTHO_SCALE/object scale against an APPROVED asset before production.")


if __name__ == "__main__":
    create_rig()
