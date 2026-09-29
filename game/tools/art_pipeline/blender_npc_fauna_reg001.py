# Run inside Blender 4.x.
# Crônicas de Valedouro — REG_001 NPC and fauna source generator.
#
# Produces art-directed low-poly source geometry for later dimetric pre-render
# and pixel cleanup. These are NOT final APPROVED sprites.
#
# Hero gameplay reference: 48x56 px per frame.
# Character target: roughly 1.75-1.90 Blender units tall before projection.
# New output remains MODELED_PENDING_GATE until Director approval.

import bpy
import math
import random
from mathutils import Vector

ROOT = "VALEDOURO_NPC_FAUNA"

# ---------------------------------------------------------------- materials

def mat(name, color, rough=0.88, metallic=0.0):
    m = bpy.data.materials.get(name)
    if m is None:
        m = bpy.data.materials.new(name)
        m.diffuse_color = (*color, 1.0)
        m.roughness = rough
        m.metallic = metallic
    return m

SKIN_A = mat("VN_Skin_A", (0.55, 0.34, 0.22), .92)
SKIN_B = mat("VN_Skin_B", (0.36, 0.21, 0.14), .92)
HAIR_DARK = mat("VN_Hair_Dark", (0.08, 0.055, 0.045), .95)
HAIR_BROWN = mat("VN_Hair_Brown", (0.19, 0.09, 0.045), .95)
CLOTH_BLUE = mat("VN_Cloth_Blue", (0.16, 0.25, 0.40), .92)
CLOTH_RED = mat("VN_Cloth_Red", (0.39, 0.12, 0.11), .92)
CLOTH_GREEN = mat("VN_Cloth_Green", (0.17, 0.31, 0.18), .92)
CLOTH_TAN = mat("VN_Cloth_Tan", (0.43, 0.31, 0.19), .94)
CLOTH_PURPLE = mat("VN_Cloth_Purple", (0.29, 0.16, 0.36), .92)
LEATHER = mat("VN_Leather", (0.22, 0.11, 0.05), .88)
WOOD = mat("VN_Wood", (0.27, 0.13, 0.06), .90)
METAL = mat("VN_Metal", (0.24, 0.26, 0.29), .38, .72)
METAL_DARK = mat("VN_Metal_Dark", (0.12, 0.13, 0.16), .44, .70)
APRON = mat("VN_Apron", (0.37, 0.30, 0.23), .98)
GLASS = mat("VN_Glass", (0.18, 0.50, 0.48), .25)

FUR_DEER = mat("VF_Deer", (0.42, 0.24, 0.12), .98)
FUR_DEER_LIGHT = mat("VF_Deer_Light", (0.64, 0.44, 0.27), .98)
FUR_FOX = mat("VF_Fox", (0.70, 0.24, 0.07), .98)
FUR_FOX_LIGHT = mat("VF_Fox_Light", (0.78, 0.62, 0.39), .98)
FUR_HARE = mat("VF_Hare", (0.44, 0.38, 0.31), .98)
FUR_GOAT = mat("VF_Goat", (0.56, 0.52, 0.44), .98)
FUR_CAMEL = mat("VF_Camel", (0.58, 0.38, 0.20), .98)
FEATHER = mat("VF_Feather", (0.14, 0.21, 0.29), .95)
FISH = mat("VF_Fish", (0.17, 0.42, 0.50), .60)
FISH_LIGHT = mat("VF_Fish_Light", (0.39, 0.67, 0.67), .55)

# ---------------------------------------------------------------- helpers

def ensure_collection(name, parent=None):
    c = bpy.data.collections.get(name)
    if c is None:
        c = bpy.data.collections.new(name)
        (parent.children if parent else bpy.context.scene.collection.children).link(c)
    return c

def relink(obj, c):
    for old in list(obj.users_collection):
        old.objects.unlink(obj)
    c.objects.link(obj)

def box(name, loc, scale, material, c, rz=0.0, bevel=.02):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=(0,0,math.radians(rz)))
    o=bpy.context.object; o.name=name
    o.scale=(scale[0]/2,scale[1]/2,scale[2]/2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(material)
    if bevel:
        m=o.modifiers.new("soft_edge","BEVEL"); m.width=bevel; m.segments=1
    relink(o,c); return o

def uv(name, loc, scale, material, c, seg=12, rings=6, rot=(0,0,0)):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=seg, ring_count=rings, location=loc,
        rotation=tuple(math.radians(v) for v in rot)
    )
    o=bpy.context.object; o.name=name
    o.scale=scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(material); relink(o,c); return o

def cyl(name, loc, radius, depth, material, c, vertices=10, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices, radius=radius, depth=depth, location=loc,
        rotation=tuple(math.radians(v) for v in rot)
    )
    o=bpy.context.object; o.name=name
    o.data.materials.append(material); relink(o,c); return o

def cone(name, loc, r1, r2, depth, material, c, vertices=10, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(
        vertices=vertices, radius1=r1, radius2=r2, depth=depth,
        location=loc, rotation=tuple(math.radians(v) for v in rot)
    )
    o=bpy.context.object; o.name=name
    o.data.materials.append(material); relink(o,c); return o

def beam(name, a, b, width, material, c):
    a=Vector(a); b=Vector(b); d=b-a
    bpy.ops.mesh.primitive_cube_add(location=(a+b)*.5)
    o=bpy.context.object; o.name=name
    o.scale=(width/2,width/2,d.length/2)
    o.rotation_mode="QUATERNION"; o.rotation_quaternion=d.to_track_quat("Z","Y")
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(material)
    mod=o.modifiers.new("edge","BEVEL"); mod.width=width*.16; mod.segments=1
    relink(o,c); return o

def cloak_mesh(name, z0, z1, top_w, bot_w, depth, material, c):
    verts=[
        (-top_w/2,-depth/2,z1),(top_w/2,-depth/2,z1),
        (-bot_w/2,-depth/2,z0),(bot_w/2,-depth/2,z0),
        (-top_w/2, depth/2,z1),(top_w/2, depth/2,z1),
        (-bot_w/2, depth/2,z0),(bot_w/2, depth/2,z0),
    ]
    faces=[(0,1,3,2),(4,6,7,5),(0,4,5,1),(2,3,7,6),(0,2,6,4),(1,5,7,3)]
    mesh=bpy.data.meshes.new(name+"_Mesh"); mesh.from_pydata(verts,[],faces); mesh.update()
    o=bpy.data.objects.new(name,mesh); c.objects.link(o); o.data.materials.append(material)
    bev=o.modifiers.new("cloth_edge","BEVEL"); bev.width=.015; bev.segments=1
    return o

# ---------------------------------------------------------------- NPCs

def base_human(c, skin=SKIN_A, cloth=CLOTH_BLUE, hair=HAIR_DARK, bulk=1.0, cloak=False):
    # Feet/boots establish ground contact and break the paper-doll feel.
    box("boot_l",(-.13,0,.09),(.17,.26,.18),LEATHER,c,rz=-6,bevel=.025)
    box("boot_r",(.13,0,.09),(.17,.26,.18),LEATHER,c,rz=6,bevel=.025)
    # Legs.
    cyl("leg_l",(-.13,0,.42),.085,.56,cloth,c,vertices=8)
    cyl("leg_r",(.13,0,.42),.085,.56,cloth,c,vertices=8)
    # Tunic/body with wider shoulders than waist.
    cone("torso",(0,0,.98),.31*bulk,.23*bulk,.72,cloth,c,vertices=8)
    # Belt.
    cyl("belt",(0,0,.84),.255*bulk,.08,LEATHER,c,vertices=10)
    # Arms.
    beam("arm_l",(-.22,0,1.23),(-.36,-.02,.84),.11*bulk,skin,c)
    beam("arm_r",(.22,0,1.23),(.36,-.02,.84),.11*bulk,skin,c)
    # Head/neck.
    cyl("neck",(0,0,1.39),.08,.12,skin,c,vertices=8)
    uv("head",(0,0,1.58),(.19,.17,.23),skin,c,seg=12,rings=6)
    # Hair mass, not a recolored scalp.
    uv("hair",(0,.012,1.69),(.205,.178,.14),hair,c,seg=10,rings=5)
    if cloak:
        cloak_mesh("cloak",.58,1.34,.48,.76,.13,CLOTH_TAN if cloth!=CLOTH_TAN else CLOTH_BLUE,c)
    return c

def npc_villager(parent):
    c=ensure_collection("NPC_Villager",parent)
    base_human(c,SKIN_A,CLOTH_GREEN,HAIR_BROWN,.96)
    # Shoulder wrap and basket differentiate silhouette.
    box("wrap",(0,0,1.27),(.58,.28,.12),CLOTH_TAN,c,rz=-4,bevel=.03)
    cyl("basket",(-.46,-.02,.69),.20,.32,WOOD,c,vertices=10)
    return c

def npc_merchant(parent):
    c=ensure_collection("NPC_Merchant",parent)
    base_human(c,SKIN_B,CLOTH_PURPLE,HAIR_DARK,1.08,cloak=True)
    # Satchel + coin belt.
    box("satchel",(.39,-.03,.82),(.31,.15,.37),LEATHER,c,rz=-10,bevel=.04)
    beam("satchel_strap",(-.18,.02,1.28),(.35,-.01,.89),.045,LEATHER,c)
    for i in range(3):
        cyl(f"coin_{i}",(-.12+i*.12,-.24,.82),.035,.025,METAL,c,vertices=8,rot=(90,0,0))
    return c

def npc_traveler(parent):
    c=ensure_collection("NPC_Traveler",parent)
    base_human(c,SKIN_A,CLOTH_TAN,HAIR_DARK,.98,cloak=True)
    # Tall staff + bedroll/backpack.
    beam("staff",(.43,-.02,.10),(.47,-.04,1.78),.045,WOOD,c)
    box("pack",(0,.20,1.08),(.48,.20,.55),LEATHER,c,bevel=.05)
    cyl("bedroll",(0,.28,1.38),.12,.55,CLOTH_BLUE,c,vertices=10,rot=(0,90,0))
    return c

def npc_guard(parent):
    c=ensure_collection("NPC_Guard",parent)
    base_human(c,SKIN_B,CLOTH_RED,HAIR_DARK,1.12)
    # Armor shell, shoulder plates, spear.
    cone("chest_armor",(0,-.015,1.08),.33,.27,.55,METAL,c,vertices=8)
    uv("shoulder_l",(-.32,0,1.31),(.15,.13,.10),METAL,c,seg=8,rings=4)
    uv("shoulder_r",(.32,0,1.31),(.15,.13,.10),METAL,c,seg=8,rings=4)
    cone("helmet",(0,0,1.75),.22,.10,.28,METAL_DARK,c,vertices=10)
    beam("spear",(.47,-.04,.12),(.47,-.04,2.04),.035,WOOD,c)
    cone("spear_tip",(.47,-.04,2.12),.07,0,.18,METAL,c,vertices=6)
    return c

def npc_blacksmith(parent):
    c=ensure_collection("NPC_Blacksmith",parent)
    base_human(c,SKIN_B,CLOTH_TAN,HAIR_BROWN,1.20)
    # Apron, gloves, hammer.
    cloak_mesh("apron",.54,1.26,.43,.58,.10,APRON,c)
    uv("glove_l",(-.36,-.02,.84),(.11,.10,.11),LEATHER,c,seg=8,rings=4)
    uv("glove_r",(.36,-.02,.84),(.11,.10,.11),LEATHER,c,seg=8,rings=4)
    beam("hammer_handle",(.39,-.02,.82),(.55,-.04,.34),.045,WOOD,c)
    box("hammer_head",(.59,-.04,.27),(.34,.14,.14),METAL_DARK,c,rz=8,bevel=.025)
    return c

def npc_alchemist(parent):
    c=ensure_collection("NPC_Alchemist",parent)
    base_human(c,SKIN_A,CLOTH_PURPLE,HAIR_DARK,.92,cloak=True)
    # Hood, potion belt, vial.
    cone("hood",(0,0,1.74),.28,.05,.38,CLOTH_PURPLE,c,vertices=10)
    for i,col in enumerate((GLASS,CLOTH_GREEN,CLOTH_BLUE)):
        cyl(f"vial_{i}",(-.20+i*.20,-.22,.82),.045,.16,col,c,vertices=8)
    return c

def npc_guild(parent):
    c=ensure_collection("NPC_Guild",parent)
    base_human(c,SKIN_A,CLOTH_BLUE,HAIR_BROWN,1.02)
    # Leather shoulder harness, scroll case.
    beam("harness_a",(-.24,-.02,1.32),(.23,-.02,.82),.055,LEATHER,c)
    cyl("scroll_case",(.42,.03,.83),.07,.48,LEATHER,c,vertices=8)
    return c

# ---------------------------------------------------------------- fauna

def leg(c,name,x,y,z_top,z_bottom,matl,thick=.055,forward=0.0):
    beam(name,(x,y,z_top),(x+forward,y,z_bottom),thick,matl,c)

def deer(parent):
    c=ensure_collection("FAUNA_Deer",parent)
    uv("body",(0,0,.72),(.56,.24,.34),FUR_DEER,c,seg=12,rings=6,rot=(0,8,0))
    uv("chest",(.42,0,.86),(.28,.22,.38),FUR_DEER,c,seg=10,rings=5)
    beam("neck",(.46,0,.96),(.62,0,1.32),.14,FUR_DEER,c)
    uv("head",(.66,-.01,1.46),(.25,.16,.20),FUR_DEER_LIGHT,c,seg=10,rings=5)
    cone("muzzle",(.84,-.02,1.42),.10,.045,.26,FUR_DEER_LIGHT,c,vertices=8,rot=(0,90,0))
    # Ears.
    cone("ear_l",(.62,-.11,1.65),.07,.01,.24,FUR_DEER,c,vertices=5,rot=(-18,0,-12))
    cone("ear_r",(.62,.11,1.65),.07,.01,.24,FUR_DEER,c,vertices=5,rot=(18,0,12))
    # Antlers create species silhouette.
    for side in (-1,1):
        beam("antler_main",(.62,side*.07,1.61),(.57,side*.14,1.92),.025,WOOD,c)
        beam("antler_branch",(.59,side*.12,1.78),(.78,side*.18,1.88),.022,WOOD,c)
        beam("antler_branch2",(.58,side*.13,1.86),(.48,side*.24,2.01),.022,WOOD,c)
    for i,x in enumerate((-.34,.28)):
        leg(c,f"leg_f_{i}",x,-.13,.62,.06,FUR_DEER,.052,.04)
        leg(c,f"leg_b_{i}",x,.13,.62,.06,FUR_DEER,.052,-.03)
    cone("tail",(-.58,.02,.85),.09,.015,.30,FUR_DEER_LIGHT,c,vertices=6,rot=(0,72,0))
    return c

def fox(parent):
    c=ensure_collection("FAUNA_Fox",parent)
    uv("body",(0,0,.42),(.48,.20,.24),FUR_FOX,c,seg=12,rings=6)
    uv("head",(.48,-.01,.56),(.23,.18,.22),FUR_FOX,c,seg=10,rings=5)
    cone("muzzle",(.70,-.01,.51),.10,.025,.34,FUR_FOX_LIGHT,c,vertices=8,rot=(0,90,0))
    for side in (-1,1):
        cone(f"ear_{side}",(.43,side*.11,.78),.08,.015,.27,FUR_FOX,c,vertices=5,rot=(side*10,0,side*5))
    # Large tail.
    uv("tail",(-.53,.03,.48),(.38,.16,.18),FUR_FOX,c,seg=10,rings=5,rot=(0,35,0))
    uv("tail_tip",(-.82,.03,.62),(.18,.13,.14),FUR_FOX_LIGHT,c,seg=8,rings=4)
    for i,x in enumerate((-.27,.25)):
        leg(c,f"leg_l_{i}",x,-.11,.36,.04,FUR_FOX,.045,.05)
        leg(c,f"leg_r_{i}",x,.11,.36,.04,FUR_FOX,.045,-.04)
    return c

def hare(parent):
    c=ensure_collection("FAUNA_Hare",parent)
    uv("body",(-.05,0,.28),(.31,.20,.24),FUR_HARE,c,seg=10,rings=5)
    uv("chest",(.22,0,.35),(.19,.17,.25),FUR_HARE,c,seg=10,rings=5)
    uv("head",(.33,0,.52),(.18,.15,.18),FUR_HARE,c,seg=10,rings=5)
    for side in (-1,1):
        cone(f"ear_{side}",(.29,side*.075,.77),.055,.018,.42,FUR_HARE,c,vertices=6,rot=(side*4,0,side*3))
    uv("hind_leg_l",(-.22,-.12,.16),(.20,.12,.13),FUR_HARE,c,seg=8,rings=4)
    uv("hind_leg_r",(-.22,.12,.16),(.20,.12,.13),FUR_HARE,c,seg=8,rings=4)
    uv("tail",(-.35,0,.34),(.10,.10,.10),FUR_DEER_LIGHT,c,seg=8,rings=4)
    return c

def goat(parent):
    c=ensure_collection("FAUNA_Goat",parent)
    uv("body",(0,0,.55),(.48,.22,.30),FUR_GOAT,c,seg=12,rings=6)
    beam("neck",(.36,0,.67),(.51,0,.91),.13,FUR_GOAT,c)
    uv("head",(.58,0,1.03),(.22,.16,.19),FUR_GOAT,c,seg=10,rings=5)
    cone("muzzle",(.76,0,.98),.09,.035,.25,FUR_GOAT,c,vertices=8,rot=(0,90,0))
    for side in (-1,1):
        cone(f"horn_{side}",(.56,side*.07,1.17),.045,.012,.31,WOOD,c,vertices=7,rot=(side*10,-8,side*5))
    for i,x in enumerate((-.28,.28)):
        leg(c,f"leg_l_{i}",x,-.12,.46,.03,FUR_GOAT,.05,.02)
        leg(c,f"leg_r_{i}",x,.12,.46,.03,FUR_GOAT,.05,-.02)
    cone("beard",(.68,0,.86),.06,.015,.25,FUR_DEER_LIGHT,c,vertices=6,rot=(0,0,180))
    return c

def camel(parent):
    c=ensure_collection("FAUNA_Camel",parent)
    uv("body",(0,0,.82),(.70,.30,.38),FUR_CAMEL,c,seg=12,rings=6)
    uv("hump",(-.12,0,1.18),(.34,.27,.36),FUR_CAMEL,c,seg=10,rings=5)
    beam("neck",(.52,0,.96),(.72,0,1.55),.19,FUR_CAMEL,c)
    uv("head",(.78,0,1.68),(.26,.18,.20),FUR_CAMEL,c,seg=10,rings=5)
    cone("muzzle",(.99,0,1.62),.11,.05,.30,FUR_CAMEL,c,vertices=8,rot=(0,90,0))
    for side in (-1,1):
        cone(f"ear_{side}",(.76,side*.11,1.83),.055,.012,.22,FUR_CAMEL,c,vertices=5,rot=(side*8,0,side*6))
    for i,x in enumerate((-.42,.38)):
        leg(c,f"leg_l_{i}",x,-.16,.70,.03,FUR_CAMEL,.065,.03)
        leg(c,f"leg_r_{i}",x,.16,.70,.03,FUR_CAMEL,.065,-.03)
    cone("tail",(-.72,0,.92),.055,.018,.40,FUR_CAMEL,c,vertices=6,rot=(0,70,0))
    return c

def bird(parent):
    c=ensure_collection("FAUNA_Bird",parent)
    uv("body",(0,0,.36),(.24,.14,.18),FEATHER,c,seg=10,rings=5)
    uv("chest",(.16,0,.42),(.16,.13,.17),FISH_LIGHT,c,seg=8,rings=4)
    uv("head",(.29,0,.53),(.13,.12,.13),FEATHER,c,seg=8,rings=4)
    cone("beak",(.43,0,.51),.05,.005,.20,WOOD,c,vertices=6,rot=(0,90,0))
    cone("wing_l",(0,-.11,.40),.11,.02,.32,FEATHER,c,vertices=7,rot=(-78,0,0))
    cone("wing_r",(0,.11,.40),.11,.02,.32,FEATHER,c,vertices=7,rot=(78,0,0))
    beam("leg_l",(.04,-.04,.24),(.04,-.04,.05),.025,WOOD,c)
    beam("leg_r",(.04,.04,.24),(.04,.04,.05),.025,WOOD,c)
    return c

def fish(parent):
    c=ensure_collection("FAUNA_Fish",parent)
    uv("body",(0,0,.20),(.34,.10,.18),FISH,c,seg=12,rings=6)
    cone("head",(.28,0,.20),.13,.03,.28,FISH_LIGHT,c,vertices=10,rot=(0,90,0))
    cone("tail",(-.38,0,.20),.18,.02,.35,FISH,c,vertices=6,rot=(0,-90,0))
    cone("fin_top",(0,0,.39),.10,.01,.22,FISH_LIGHT,c,vertices=5)
    return c

# ---------------------------------------------------------------- build

def build_all():
    root=ensure_collection(ROOT)
    for col in list(root.children):
        for obj in list(col.objects):
            bpy.data.objects.remove(obj,do_unlink=True)
        bpy.data.collections.remove(col)

    npc_villager(root)
    npc_merchant(root)
    npc_traveler(root)
    npc_guard(root)
    npc_blacksmith(root)
    npc_alchemist(root)
    npc_guild(root)

    deer(root); fox(root); hare(root); goat(root); camel(root); bird(root); fish(root)

    scene=bpy.context.scene
    scene["valedouro_character_source_version"]=1
    scene["valedouro_hero_frame_reference"]="48x56"
    scene["valedouro_character_status"]="MODELED_PENDING_GATE"

    print("Generated 7 NPC families + 7 fauna species source geometry.")
    print("Next: render individual collections with the locked AZ45/EL30 rig,")
    print("then author idle/walk frames and perform pixel cleanup before integration.")


if __name__=="__main__":
    build_all()
