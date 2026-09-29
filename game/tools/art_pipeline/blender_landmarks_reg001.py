# Run inside Blender 4.x.
# Crônicas de Valedouro — professional landmark geometry generator.
#
# Produces detailed 3D source geometry for high-priority REG_001 landmarks.
# Output is intended for the locked Valedouro dimetric render rig and a later
# pixel-art cleanup pass. Objects are intentionally built from layered forms,
# not from one primitive pretending to be a final sprite.

import bpy
import math
import random
from mathutils import Vector

ROOT = "VALEDOURO_LANDMARKS"
SEED = 117


def mat(name, color, roughness=0.82, metallic=0.0):
    m = bpy.data.materials.get(name)
    if m is None:
        m = bpy.data.materials.new(name)
        m.diffuse_color = (*color, 1.0)
        m.roughness = roughness
        m.metallic = metallic
    return m


WOOD_DARK = mat("VD_Wood_Dark", (0.17, 0.075, 0.035))
WOOD = mat("VD_Wood", (0.30, 0.14, 0.065))
WOOD_LIGHT = mat("VD_Wood_Light", (0.43, 0.23, 0.10))
STONE = mat("VD_Stone", (0.28, 0.30, 0.34))
STONE_DARK = mat("VD_Stone_Dark", (0.13, 0.15, 0.19))
ROOF = mat("VD_Roof", (0.14, 0.17, 0.24))
METAL = mat("VD_Metal", (0.22, 0.24, 0.28), roughness=0.42, metallic=0.65)
CLOTH = mat("VD_Cloth", (0.22, 0.30, 0.45), roughness=0.9)
MOSS = mat("VD_Moss", (0.18, 0.28, 0.12), roughness=1.0)


def ensure_collection(name, parent=None):
    c = bpy.data.collections.get(name)
    if c is None:
        c = bpy.data.collections.new(name)
        if parent is None:
            bpy.context.scene.collection.children.link(c)
        else:
            parent.children.link(c)
    return c


def unlink_to(obj, collection):
    for c in list(obj.users_collection):
        c.objects.unlink(obj)
    collection.objects.link(obj)


def box(name, loc, scale, material, collection, rot_z=0.0, bevel=0.035):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=(0, 0, math.radians(rot_z)))
    o = bpy.context.object
    o.name = name
    o.scale = (scale[0] / 2, scale[1] / 2, scale[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if material:
        o.data.materials.append(material)
    if bevel > 0:
        mod = o.modifiers.new("edge_wear", "BEVEL")
        mod.width = bevel
        mod.segments = 1
    unlink_to(o, collection)
    return o


def cylinder(name, loc, radius, depth, material, collection, vertices=12, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices,
        radius=radius,
        depth=depth,
        location=loc,
        rotation=tuple(math.radians(v) for v in rot),
    )
    o = bpy.context.object
    o.name = name
    if material:
        o.data.materials.append(material)
    unlink_to(o, collection)
    return o


def cone(name, loc, r1, r2, depth, material, collection, vertices=12, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cone_add(
        vertices=vertices,
        radius1=r1,
        radius2=r2,
        depth=depth,
        location=loc,
        rotation=tuple(math.radians(v) for v in rot),
    )
    o = bpy.context.object
    o.name = name
    if material:
        o.data.materials.append(material)
    unlink_to(o, collection)
    return o


def beam_between(name, a, b, width, depth, material, collection):
    a = Vector(a)
    b = Vector(b)
    mid = (a + b) * 0.5
    d = b - a
    length = d.length
    bpy.ops.mesh.primitive_cube_add(location=mid)
    o = bpy.context.object
    o.name = name
    o.scale = (width / 2, depth / 2, length / 2)
    o.rotation_mode = "QUATERNION"
    o.rotation_quaternion = d.to_track_quat("Z", "Y")
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(material)
    bev = o.modifiers.new("worn_edges", "BEVEL")
    bev.width = min(width, depth) * 0.12
    bev.segments = 1
    unlink_to(o, collection)
    return o


def add_rubble(collection, center, count=18, radius=1.2, z=0.10, seed=SEED):
    rng = random.Random(seed)
    for i in range(count):
        ang = rng.random() * math.tau
        rr = radius * (0.25 + rng.random() * 0.75)
        x = center[0] + math.cos(ang) * rr
        y = center[1] + math.sin(ang) * rr
        s = 0.08 + rng.random() * 0.17
        box(
            f"rubble_{i:02d}",
            (x, y, z + s * 0.45),
            (s * 1.5, s, s * 0.8),
            STONE if i % 3 else STONE_DARK,
            collection,
            rot_z=rng.uniform(0, 180),
            bevel=s * 0.12,
        )


def build_watchtower(parent):
    c = ensure_collection("LM_Watchtower", parent)

    # Stone foundation: irregular two-tier platform.
    for i, (sx, sy, sz, z) in enumerate([
        (3.15, 3.05, 0.38, 0.19),
        (2.75, 2.65, 0.26, 0.51),
    ]):
        box(f"tower_foundation_{i}", (0, 0, z), (sx, sy, sz), STONE_DARK if i == 0 else STONE, c, bevel=0.08)
    add_rubble(c, (0, 0), count=22, radius=1.9, z=0.04, seed=31)

    # Four structural posts, slightly non-perfect for hand-built feel.
    posts = [(-1.03, -0.98), (1.00, -1.01), (-1.00, 1.02), (1.04, 0.98)]
    for i, (x, y) in enumerate(posts):
        box(f"tower_post_{i}", (x, y, 2.55), (0.24, 0.24, 4.10), WOOD_DARK, c, rot_z=(i % 2) * 2.0, bevel=0.035)

    # Cross braces on all visible construction planes.
    braces = [
        ((-1.0,-1.0,1.0),(1.0,-1.0,2.9)),
        ((1.0,-1.0,1.0),(-1.0,-1.0,2.9)),
        ((1.0,-1.0,1.0),(1.0,1.0,2.9)),
        ((1.0,1.0,1.0),(1.0,-1.0,2.9)),
        ((-1.0,1.0,1.0),(-1.0,-1.0,2.9)),
        ((-1.0,-1.0,1.0),(-1.0,1.0,2.9)),
    ]
    for i, (a, b) in enumerate(braces):
        beam_between(f"tower_brace_{i}", a, b, 0.12, 0.10, WOOD, c)

    # Platform floor boards with deliberate slight offsets.
    rng = random.Random(202)
    for i in range(11):
        y = -1.25 + i * 0.25
        box(
            f"tower_deck_{i:02d}",
            (rng.uniform(-0.025, 0.025), y, 3.72 + rng.uniform(-0.012, 0.012)),
            (2.75, 0.21, 0.10),
            WOOD_LIGHT if i % 4 == 0 else WOOD,
            c,
            rot_z=rng.uniform(-0.7, 0.7),
            bevel=0.018,
        )

    # Guard rails and corner posts.
    rail_z = 4.20
    for x, y in [(-1.25,-1.25),(1.25,-1.25),(-1.25,1.25),(1.25,1.25)]:
        box("rail_post", (x, y, rail_z), (0.13,0.13,0.92), WOOD_DARK, c, bevel=0.025)
    for a, b in [
        ((-1.25,-1.25,4.42),(1.25,-1.25,4.42)),
        ((1.25,-1.25,4.42),(1.25,1.25,4.42)),
        ((-1.25,1.25,4.42),(1.25,1.25,4.42)),
    ]:
        beam_between("guard_rail", a, b, 0.10, 0.11, WOOD, c)

    # Ladder at front-left.
    for i in range(10):
        z = 0.92 + i * 0.30
        box(f"ladder_step_{i}", (-0.65, -1.33, z), (0.68, 0.12, 0.08), WOOD_LIGHT, c, bevel=0.015)
    beam_between("ladder_side_l", (-1.02,-1.33,0.75), (-1.02,-1.33,3.70), 0.10, 0.10, WOOD_DARK, c)
    beam_between("ladder_side_r", (-0.28,-1.33,0.75), (-0.28,-1.33,3.70), 0.10, 0.10, WOOD_DARK, c)

    # Roof posts and layered roof.
    for x, y in [(-1.02,-1.02),(1.02,-1.02),(-1.02,1.02),(1.02,1.02)]:
        box("roof_post", (x,y,4.78), (0.12,0.12,1.28), WOOD_DARK, c, bevel=0.025)
    cone("tower_roof", (0,0,5.58), 2.0, 0.15, 1.08, ROOF, c, vertices=4, rot=(0,0,45))
    cone("tower_roof_cap", (0,0,6.17), 0.18, 0.03, 0.42, METAL, c, vertices=8)

    # Small hanging banner to break symmetry.
    pole = beam_between("banner_pole", (1.20,-1.16,4.35),(1.20,-1.16,5.25),0.06,0.06,METAL,c)
    box("banner_cloth", (1.20,-1.19,4.78), (0.06,0.48,0.62), CLOTH, c, rot_z=0, bevel=0.01)

    return c


def build_windmill(parent):
    c = ensure_collection("LM_Windmill", parent)

    # Stone plinth and tapered mill body.
    box("mill_plinth", (0,0,0.23), (3.4,3.25,0.46), STONE_DARK, c, bevel=0.10)
    add_rubble(c, (0,0), count=16, radius=1.9, z=0.04, seed=77)

    # Layer the body to avoid a single cone silhouette.
    cone("mill_body_lower", (0,0,1.75), 1.42, 1.16, 2.80, STONE, c, vertices=12)
    cone("mill_body_upper", (0,0,3.48), 1.17, 0.98, 0.85, STONE, c, vertices=12)

    # Timber bands and vertical accents.
    for z in (0.78, 2.55, 3.62):
        cylinder("mill_band", (0,0,z), 1.26 if z < 3 else 1.04, 0.10, WOOD_DARK, c, vertices=12)
    for ang in range(0,360,45):
        a=math.radians(ang)
        x,y=math.cos(a)*1.18, math.sin(a)*1.18
        box("mill_timber", (x,y,2.25), (0.12,0.12,2.75), WOOD_DARK, c, rot_z=ang, bevel=0.02)

    # Door + lintel + small steps.
    box("mill_door", (0,-1.23,1.05), (0.78,0.12,1.45), WOOD_DARK, c, bevel=0.025)
    box("mill_lintel", (0,-1.33,1.82), (0.95,0.18,0.16), WOOD_LIGHT, c, bevel=0.02)
    for i in range(3):
        box(f"mill_step_{i}", (0,-1.45-i*0.18,0.20+i*0.10), (1.10+i*0.18,0.45,0.16), STONE, c, bevel=0.04)

    # Roof.
    cone("mill_roof", (0,0,4.38), 1.58, 0.06, 1.58, ROOF, c, vertices=12)
    cone("mill_roof_cap", (0,0,5.23), 0.14, 0.02, 0.34, METAL, c, vertices=8)

    # Mill axle and hub on camera-facing side.
    axle_center = Vector((0,-1.28,3.35))
    cylinder("mill_axle", axle_center, 0.16, 0.62, METAL, c, vertices=12, rot=(90,0,0))
    cylinder("mill_hub", (0,-1.61,3.35), 0.32, 0.22, WOOD_DARK, c, vertices=12, rot=(90,0,0))

    # Four blades built as beams + slats, giving visible construction.
    for blade in range(4):
        angle = math.radians(blade*90 + 12)
        dx, dz = math.cos(angle), math.sin(angle)
        start = Vector((0,-1.74,3.35)) + Vector((dx,0,dz))*0.25
        end = Vector((0,-1.74,3.35)) + Vector((dx,0,dz))*2.45
        beam_between(f"blade_spine_{blade}", start, end, 0.14, 0.11, WOOD_DARK, c)
        perp = Vector((-dz,0,dx))
        for j in range(1,7):
            p = Vector((0,-1.76,3.35)) + Vector((dx,0,dz))*(0.48+j*0.28)
            half = 0.12 + j*0.045
            beam_between(
                f"blade_slat_{blade}_{j}",
                p-perp*half,
                p+perp*half,
                0.065,
                0.055,
                WOOD_LIGHT if j%2==0 else WOOD,
                c,
            )

    # Nearby farm props establish scale and storytelling.
    box("mill_crate", (1.58,-0.95,0.34), (0.62,0.58,0.60), WOOD, c, rot_z=-12, bevel=0.04)
    cylinder("mill_barrel", (-1.52,-0.75,0.48), 0.34, 0.80, WOOD, c, vertices=10)
    return c


def build_cave_gate(parent):
    c = ensure_collection("LM_CaveEntrance", parent)
    rng = random.Random(404)

    # Back darkness plane/cavity gives real depth behind the rock mouth.
    box("cave_darkness", (0,0.65,1.70), (2.55,0.18,2.70), STONE_DARK, c, bevel=0.20)

    # Rock arch made from asymmetrical masses, not a placed portal.
    rocks = [
        (-1.45,0.22,0.72,1.15,0.85,1.25,-12),
        ( 1.38,0.30,0.68,1.10,0.92,1.20, 10),
        (-1.23,0.28,1.70,0.90,0.82,1.10,-18),
        ( 1.15,0.38,1.82,0.82,0.88,1.20, 16),
        (-0.78,0.35,2.62,0.90,0.85,0.78, -8),
        ( 0.10,0.42,2.85,1.20,0.95,0.72,  5),
        ( 0.95,0.38,2.62,0.82,0.80,0.72, 14),
    ]
    for i,(x,y,z,sx,sy,sz,rz) in enumerate(rocks):
        box(f"cave_rock_{i}", (x,y,z), (sx,sy,sz), STONE if i%3 else STONE_DARK, c, rot_z=rz, bevel=0.14)

    # Foreground boulders + moss break the silhouette.
    for i in range(12):
        ang = rng.uniform(math.radians(165), math.radians(375))
        rr = rng.uniform(1.0,2.1)
        x,y=math.cos(ang)*rr, -0.20+math.sin(ang)*rr*0.55
        s=rng.uniform(0.18,0.48)
        box(f"cave_fore_rock_{i}",(x,y,s*0.48),(s*1.4,s,s),STONE,c,rot_z=rng.uniform(0,180),bevel=s*0.16)
        if i%4==0:
            box(f"cave_moss_{i}",(x,y-0.02,s*0.93),(s*1.0,s*0.65,0.06),MOSS,c,rot_z=rng.uniform(0,180),bevel=0.02)

    # Broken old lintel/wood supports imply history without reading as a door frame.
    beam_between("cave_beam_l",(-0.96,0.02,0.20),(-0.82,0.10,2.18),0.15,0.12,WOOD_DARK,c)
    beam_between("cave_beam_r",(0.96,0.04,0.20),(0.82,0.12,2.00),0.15,0.12,WOOD_DARK,c)
    beam_between("cave_beam_top",(-0.86,0.08,2.02),(0.82,0.12,1.91),0.15,0.12,WOOD_DARK,c)
    return c


def build_waterfall_cliff(parent):
    c = ensure_collection("LM_WaterfallCliff", parent)
    rng = random.Random(808)

    # Layered cliff masses with stepped profile.
    tiers = [
        (0,0.55,0.55,5.5,2.5,1.1),
        (0,0.68,1.45,4.9,2.25,1.0),
        (0,0.78,2.35,4.35,2.0,0.95),
        (0,0.88,3.16,3.75,1.75,0.82),
    ]
    for i,(x,y,z,sx,sy,sz) in enumerate(tiers):
        box(f"cliff_tier_{i}",(x,y,z),(sx,sy,sz),STONE_DARK if i%2 else STONE,c,rot_z=(-2+i*1.5),bevel=0.14)

    # Rock teeth around cascade opening.
    for i in range(18):
        x = rng.uniform(-2.45,2.45)
        if abs(x) < 0.72 and i < 12:
            x += 1.1 if x >= 0 else -1.1
        y = rng.uniform(-0.20,0.85)
        z = rng.uniform(0.25,3.65)
        s = rng.uniform(0.18,0.46)
        box(f"cliff_detail_{i}",(x,y,z),(s*1.6,s,s*1.25),STONE,c,rot_z=rng.uniform(-25,25),bevel=s*0.15)

    # Water sheets use flat geometry intentionally; final foam/VFX are 2D pixel pass.
    water = mat("VD_Water", (0.20,0.48,0.66), roughness=0.24)
    box("waterfall_sheet", (0,-0.64,2.15), (1.15,0.10,3.35), water, c, bevel=0.02)
    box("waterfall_upper_river", (0,0.28,3.78), (1.35,1.75,0.08), water, c, bevel=0.02)
    box("waterfall_pool", (0,-1.23,0.13), (3.10,2.10,0.10), water, c, bevel=0.06)

    # Lower rocks establish impact basin.
    for i in range(14):
        ang=rng.uniform(math.pi*0.05, math.pi*0.95)
        rr=rng.uniform(0.7,1.75)
        x=math.cos(ang)*rr
        y=-1.18-math.sin(ang)*rr*0.42
        s=rng.uniform(0.12,0.33)
        box(f"basin_rock_{i}",(x,y,0.18+s*0.35),(s*1.5,s,s*0.8),STONE_DARK if i%3==0 else STONE,c,rot_z=rng.uniform(0,180),bevel=s*0.18)

    return c


def build_all():
    root = ensure_collection(ROOT)
    # Clean only generated landmark subcollections.
    for name in ["LM_Watchtower","LM_Windmill","LM_CaveEntrance","LM_WaterfallCliff"]:
        old = bpy.data.collections.get(name)
        if old:
            for obj in list(old.objects):
                bpy.data.objects.remove(obj, do_unlink=True)
            bpy.data.collections.remove(old)

    build_watchtower(root)
    build_windmill(root)
    build_cave_gate(root)
    build_waterfall_cliff(root)

    bpy.context.scene["valedouro_landmark_generator_version"] = 1
    print("Generated: watchtower, windmill, cave entrance, waterfall/cliff.")
    print("Next: render each collection separately with blender_valedouro_setup.py, then pixel_finish + hand cleanup.")


if __name__ == "__main__":
    build_all()
