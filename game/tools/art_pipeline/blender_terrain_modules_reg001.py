# Run inside Blender 4.x.
# Crônicas de Valedouro — REG_001 terrain/elevation production modules.
#
# Generates source geometry for cliff/elevation modules intended to be rendered
# with blender_valedouro_setup.py and cleaned as pixel art afterwards.

import bpy
import math
import random
from mathutils import Vector

ROOT = "VALEDOURO_TERRAIN_MODULES"

def mat(name, color, roughness=0.95):
    m = bpy.data.materials.get(name)
    if m is None:
        m = bpy.data.materials.new(name)
        m.diffuse_color = (*color, 1.0)
        m.roughness = roughness
    return m

ROCK_DARK = mat("VT_Rock_Dark", (0.16, 0.17, 0.20))
ROCK_MID = mat("VT_Rock_Mid", (0.28, 0.29, 0.31))
ROCK_LIGHT = mat("VT_Rock_Light", (0.40, 0.40, 0.39))
DIRT = mat("VT_Dirt", (0.24, 0.15, 0.09))
GRASS = mat("VT_Grass", (0.22, 0.34, 0.16))
SNOW = mat("VT_Snow", (0.72, 0.78, 0.82))
SAND = mat("VT_Sand", (0.48, 0.35, 0.19))


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


def cube(name, loc, scale, material, c, rz=0.0, bevel=0.06):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=(0, 0, math.radians(rz)))
    o = bpy.context.object
    o.name = name
    o.scale = (scale[0]/2, scale[1]/2, scale[2]/2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(material)
    if bevel:
        b=o.modifiers.new("rock_edge","BEVEL"); b.width=bevel; b.segments=1
    relink(o,c)
    return o


def make_irregular_block(name, center, size, material, c, seed):
    rng=random.Random(seed)
    x,y,z=center
    sx,sy,sz=size
    # Central mass.
    cube(name+"_core",(x,y,z),(sx,sy,sz),material,c,rz=rng.uniform(-2.5,2.5),bevel=min(sx,sy,sz)*0.05)
    # Added rock shelves break the rectangular silhouette.
    for i in range(5):
        px=x+rng.uniform(-sx*0.48,sx*0.48)
        py=y+rng.uniform(-sy*0.48,sy*0.48)
        pz=z+rng.uniform(-sz*0.35,sz*0.40)
        ss=rng.uniform(0.20,0.42)
        cube(
            f"{name}_chip_{i}",(px,py,pz),
            (sx*ss,sy*rng.uniform(0.14,0.32),sz*rng.uniform(0.10,0.28)),
            ROCK_LIGHT if i%3==0 else material,c,
            rz=rng.uniform(-18,18),bevel=0.05
        )


def top_cap(name, center, size, material, c, seed=1):
    rng=random.Random(seed)
    x,y,z=center
    sx,sy=size
    cube(name,(x,y,z),(sx,sy,0.12),material,c,rz=rng.uniform(-1.2,1.2),bevel=0.025)
    # Edge clumps stop the cap from looking like a perfect plate.
    for i in range(7):
        side=rng.choice(("x-","x+","y-","y+"))
        if side[0]=="x":
            px=x+(-1 if side=="x-" else 1)*sx*0.48
            py=y+rng.uniform(-sy*0.40,sy*0.40)
        else:
            px=x+rng.uniform(-sx*0.40,sx*0.40)
            py=y+(-1 if side=="y-" else 1)*sy*0.48
        cube(f"{name}_edge_{i}",(px,py,z+0.05),(rng.uniform(.16,.34),rng.uniform(.16,.34),.12),material,c,rz=rng.uniform(0,180),bevel=.025)


def cliff_straight(parent, biome="grass", seed=100):
    c=ensure_collection(f"TM_Cliff_Straight_{biome}",parent)
    cap={"grass":GRASS,"snow":SNOW,"sand":SAND}[biome]
    # Stepped vertical face.
    make_irregular_block("face_low",(0,0,0.55),(4.0,1.7,1.10),ROCK_DARK,c,seed)
    make_irregular_block("face_high",(0,0.18,1.38),(3.75,1.45,0.75),ROCK_MID,c,seed+1)
    top_cap("top",(0,0.22,1.82),(3.72,1.42),cap,c,seed+2)
    # Strata ledges.
    rng=random.Random(seed+3)
    for i in range(8):
        x=rng.uniform(-1.65,1.65)
        y=-0.73+rng.uniform(-0.05,0.14)
        z=rng.uniform(0.28,1.55)
        cube(f"strata_{i}",(x,y,z),(rng.uniform(.36,.82),.18,rng.uniform(.10,.19)),ROCK_LIGHT if i%4==0 else ROCK_MID,c,rz=rng.uniform(-10,10),bevel=.025)
    return c


def cliff_outer_corner(parent, biome="grass", seed=200):
    c=ensure_collection(f"TM_Cliff_OuterCorner_{biome}",parent)
    cap={"grass":GRASS,"snow":SNOW,"sand":SAND}[biome]
    # L-shaped mass from two interlocking rock bodies.
    make_irregular_block("arm_x",(-0.65,0.25,0.78),(2.9,1.55,1.55),ROCK_MID,c,seed)
    make_irregular_block("arm_y",(0.55,0.85,0.78),(1.55,2.75,1.55),ROCK_DARK,c,seed+1)
    top_cap("cap_x",(-0.65,0.28,1.62),(2.75,1.45),cap,c,seed+2)
    top_cap("cap_y",(0.58,0.86,1.62),(1.45,2.60),cap,c,seed+3)
    return c


def cliff_inner_corner(parent, biome="grass", seed=300):
    c=ensure_collection(f"TM_Cliff_InnerCorner_{biome}",parent)
    cap={"grass":GRASS,"snow":SNOW,"sand":SAND}[biome]
    # Two faces meeting while leaving a readable concave recess.
    make_irregular_block("wall_x",(0,-0.55,0.78),(4.0,1.25,1.55),ROCK_MID,c,seed)
    make_irregular_block("wall_y",(1.35,0.72,0.78),(1.25,2.55,1.55),ROCK_DARK,c,seed+1)
    top_cap("cap_x",(0,-0.52,1.62),(3.88,1.15),cap,c,seed+2)
    top_cap("cap_y",(1.38,0.72,1.62),(1.15,2.44),cap,c,seed+3)
    return c


def natural_steps(parent, biome="grass", seed=400):
    c=ensure_collection(f"TM_NaturalSteps_{biome}",parent)
    cap={"grass":GRASS,"snow":SNOW,"sand":SAND}[biome]
    rng=random.Random(seed)
    for i in range(5):
        z=.18+i*.30
        y=.85-i*.36
        width=2.45-i*.12
        cube(f"step_{i}",(rng.uniform(-.035,.035),y,z),(width,.78,.32),ROCK_MID if i%2 else ROCK_DARK,c,rz=rng.uniform(-2,2),bevel=.06)
        cube(f"step_cap_{i}",(0,y-.10,z+.18),(width*.96,.66,.08),cap,c,rz=rng.uniform(-1,1),bevel=.018)
    return c


def canyon_wall(parent, biome="snow", seed=500):
    c=ensure_collection(f"TM_CanyonWall_{biome}",parent)
    cap={"grass":GRASS,"snow":SNOW,"sand":SAND}[biome]
    rng=random.Random(seed)
    for i in range(6):
        x=-1.65+i*.66
        h=rng.uniform(1.5,2.35)
        make_irregular_block(f"spire_{i}",(x,rng.uniform(-.06,.12),h/2),(rng.uniform(.72,1.05),1.15,h),ROCK_DARK if i%2 else ROCK_MID,c,seed+i)
        cube(f"spire_cap_{i}",(x,0,h+.03),(rng.uniform(.58,.92),.90,.09),cap,c,rz=rng.uniform(-5,5),bevel=.02)
    return c


def build_all():
    root=ensure_collection(ROOT)
    # Clear generated module collections.
    for col in list(root.children):
        for o in list(col.objects):
            bpy.data.objects.remove(o,do_unlink=True)
        bpy.data.collections.remove(col)

    for biome in ("grass","snow","sand"):
        cliff_straight(root,biome,100+len(root.children)*11)
        cliff_outer_corner(root,biome,200+len(root.children)*11)
        cliff_inner_corner(root,biome,300+len(root.children)*11)
        natural_steps(root,biome,400+len(root.children)*11)

    canyon_wall(root,"snow",501)
    canyon_wall(root,"sand",511)

    bpy.context.scene["valedouro_terrain_modules_version"]=1
    print("Generated terrain module source geometry: straight/inner/outer/steps + canyon walls.")
    print("Render modules separately with the locked Valedouro rig; pixel-clean before integration.")


if __name__=="__main__":
    build_all()
