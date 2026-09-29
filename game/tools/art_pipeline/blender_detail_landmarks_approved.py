# Run after blender_landmarks_reg001.py and blender_apply_approved_materials.py.
# Adds the APPROVED Valedouro density/ornament layer to hero-facing landmarks.
#
# The goal is not random detail. Every addition supports construction, material,
# region identity or focal readability.

import bpy
import math
import random
from mathutils import Vector

SEED=2909

def material(name, hex_color, rough=.86, metallic=0.0, emission=None, emission_strength=0.0):
    h=hex_color.lstrip("#")
    rgb=tuple(int(h[i:i+2],16)/255.0 for i in (0,2,4))
    m=bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.diffuse_color=(*rgb,1)
    m.roughness=rough
    m.metallic=metallic
    m.use_nodes=True
    bsdf=m.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value=(*rgb,1)
        bsdf.inputs["Roughness"].default_value=rough
        bsdf.inputs["Metallic"].default_value=metallic
        if emission:
            eh=emission.lstrip("#")
            e=tuple(int(eh[i:i+2],16)/255.0 for i in (0,2,4))
            key="Emission Color" if "Emission Color" in bsdf.inputs else "Emission"
            if key in bsdf.inputs: bsdf.inputs[key].default_value=(*e,1)
            if "Emission Strength" in bsdf.inputs: bsdf.inputs["Emission Strength"].default_value=emission_strength
    return m

STONE_D=material("VD2_StoneDark","#5F4146")
STONE_M=material("VD2_StoneMid","#B36F53")
STONE_L=material("VD2_StoneLight","#EBC18B")
WOOD_D=material("VD2_WoodDark","#4B2419")
WOOD_M=material("VD2_WoodMid","#A65327")
WOOD_L=material("VD2_WoodLight","#D98237")
BLUE_D=material("VD2_BlueDark","#11377D")
BLUE=material("VD2_Blue","#1768C2")
BLUE_L=material("VD2_BlueLight","#3BB5EA")
GOLD=material("VD2_Gold","#E59A20",.45,.55)
GOLD_L=material("VD2_GoldLight","#FFD35B",.38,.65)
GREEN_D=material("VD2_GreenDark","#16552A",.98)
GREEN=material("VD2_Green","#3EA83C",.98)
GREEN_L=material("VD2_GreenLight","#91D646",.97)
ROCK_D=material("VD2_RockDark","#252640",.96)
ROCK_M=material("VD2_RockMid","#505677",.94)
ROCK_L=material("VD2_RockLight","#9298B8",.90)
CYAN=material("VD2_Cyan","#23D6FF",.32,.05,"#23D6FF",.70)
WATER=material("VD2_Water","#268FD0",.30)
FOAM=material("VD2_Foam","#D8F6FF",.48)
CLOTH=material("VD2_ClothBlue","#1658AC",.92)

def col(name):
    return bpy.data.collections.get(name)

def relink(o,c):
    for old in list(o.users_collection): old.objects.unlink(o)
    c.objects.link(o)

def box(name,loc,scale,mat,c,rz=0,bevel=.02):
    bpy.ops.mesh.primitive_cube_add(location=loc,rotation=(0,0,math.radians(rz)))
    o=bpy.context.object;o.name=name;o.scale=(scale[0]/2,scale[1]/2,scale[2]/2)
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    o.data.materials.append(mat)
    if bevel:
        b=o.modifiers.new("pixel_edge","BEVEL");b.width=bevel;b.segments=1
    relink(o,c);return o

def cyl(name,loc,radius,depth,mat,c,vertices=8,rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=radius,depth=depth,location=loc,rotation=tuple(math.radians(v) for v in rot))
    o=bpy.context.object;o.name=name;o.data.materials.append(mat);relink(o,c);return o

def cone(name,loc,r1,r2,depth,mat,c,vertices=6,rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices,radius1=r1,radius2=r2,depth=depth,location=loc,rotation=tuple(math.radians(v) for v in rot))
    o=bpy.context.object;o.name=name;o.data.materials.append(mat);relink(o,c);return o

def beam(name,a,b,w,mat,c):
    a=Vector(a);b=Vector(b);d=b-a
    bpy.ops.mesh.primitive_cube_add(location=(a+b)*.5)
    o=bpy.context.object;o.name=name;o.scale=(w/2,w/2,d.length/2)
    o.rotation_mode="QUATERNION";o.rotation_quaternion=d.to_track_quat("Z","Y")
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    o.data.materials.append(mat);relink(o,c)
    be=o.modifiers.new("beam_edge","BEVEL");be.width=w*.12;be.segments=1
    return o

def glow_lantern(name,loc,c):
    # Small lantern body plus emissive core. Keep it chunky enough to survive downsample.
    box(name+"_frame",loc,(.18,.14,.27),GOLD,c,bevel=.025)
    box(name+"_core",(loc[0],loc[1]-.015,loc[2]),(.10,.09,.17),GOLD_L,c,bevel=.01)
    return

def foliage_cluster(name,loc,c,scale=1.0,seed=1):
    rng=random.Random(seed)
    for i in range(7):
        x=loc[0]+rng.uniform(-.19,.19)*scale
        y=loc[1]+rng.uniform(-.12,.12)*scale
        z=loc[2]+rng.uniform(-.02,.20)*scale
        mat=GREEN_L if i%4==0 else GREEN if i%3 else GREEN_D
        cone(f"{name}_{i}",(x,y,z),.10*scale,.01,.25*scale,mat,c,vertices=6,rot=(rng.uniform(-12,12),rng.uniform(-12,12),rng.uniform(0,360)))

def add_watchtower():
    c=col("LM_Watchtower")
    if not c:return
    rng=random.Random(SEED)
    # Foundation stone block face breakup.
    for side in (-1,1):
        for row in range(3):
            for k in range(4):
                x=-1.12+k*.74+rng.uniform(-.035,.035)
                y=side*1.39
                z=.22+row*.19
                box(f"tower_stone_face_{side}_{row}_{k}",(x,y,z),(.62,.08,.16),STONE_M if (row+k)%3 else STONE_L,c,rz=rng.uniform(-1.5,1.5),bevel=.025)
    # Blue/gold roof trim matching APPROVED hub language.
    for a,b in [
        ((-1.52,-1.52,5.20),(1.52,-1.52,5.20)),
        ((1.52,-1.52,5.20),(1.52,1.52,5.20)),
        ((1.52,1.52,5.20),(-1.52,1.52,5.20)),
        ((-1.52,1.52,5.20),(-1.52,-1.52,5.20))
    ]: beam("tower_roof_gold_trim",a,b,.065,GOLD,c)
    cone("tower_finial",(0,0,6.43),.085,.015,.50,GOLD_L,c,vertices=8)
    # Heraldic banner panel and crest.
    box("tower_banner_panel",(1.27,-1.34,4.73),(.42,.055,.70),CLOTH,c,bevel=.018)
    box("tower_banner_crest",(1.27,-1.375,4.76),(.085,.025,.34),GOLD_L,c,bevel=.008)
    # Lanterns + vines around stone base.
    glow_lantern("tower_lantern_l",(-1.13,-1.34,3.95),c)
    glow_lantern("tower_lantern_r",(1.13,-1.34,3.95),c)
    foliage_cluster("tower_vine_l",(-1.30,-1.38,.34),c,1.0,31)
    foliage_cluster("tower_vine_r",(1.25,-1.38,.30),c,.9,33)
    # Rope coils/utility detail on platform.
    cyl("tower_rope_coil",(-.77,-.88,3.84),.18,.08,WOOD_L,c,vertices=10,rot=(90,0,0))

def add_windmill():
    c=col("LM_Windmill")
    if not c:return
    rng=random.Random(SEED+10)
    # Stone block bands + chipped highlights.
    for row,z in enumerate((.62,1.08,1.54,2.00,2.46,2.92,3.38)):
        radius=1.34-(z/4.2)*.25
        for k in range(10):
            ang=math.radians(k*36+(row%2)*18)
            x,y=math.cos(ang)*radius,math.sin(ang)*radius
            box(f"mill_stone_{row}_{k}",(x,y,z),(0.48,.10,.25),STONE_M if (k+row)%4 else STONE_L,c,rz=k*36+90,bevel=.025)
    # Blue roof accent ring and gold cap.
    cyl("mill_roof_blue_band",(0,0,4.00),1.20,.12,BLUE,c,vertices=12)
    cone("mill_gold_finial",(0,0,5.42),.07,.01,.38,GOLD_L,c,vertices=8)
    # Window frames on side faces.
    for ang in (-90,0):
        a=math.radians(ang)
        x,y=math.cos(a)*1.19,math.sin(a)*1.19
        box(f"mill_window_frame_{ang}",(x,y,2.38),(.42,.09,.54),WOOD_D,c,rz=ang+90,bevel=.03)
        box(f"mill_window_blue_{ang}",(x*1.015,y*1.015,2.39),(.27,.035,.35),BLUE_L,c,rz=ang+90,bevel=.01)
    # Door lantern and sacks/crates storytelling.
    glow_lantern("mill_door_lantern",(.54,-1.36,1.43),c)
    for i,(x,y,s) in enumerate(((1.55,-1.02,.26),(1.82,-.87,.20),(-1.54,-.95,.24))):
        cyl(f"mill_sack_{i}",(x,y,s),.18,.42,STONE_L,c,vertices=8)
    # Blade gold hub ring so the mechanism is a focal point.
    cyl("mill_hub_gold",(0,-1.78,3.35),.38,.08,GOLD,c,vertices=12,rot=(90,0,0))
    # Small grass/flower cluster around base.
    foliage_cluster("mill_base_green",(1.34,.95,.12),c,.8,81)
    foliage_cluster("mill_base_green2",(-1.22,.92,.11),c,.65,82)

def add_cave():
    c=col("LM_CaveEntrance")
    if not c:return
    rng=random.Random(SEED+20)
    # Eroded layered ledges around the opening.
    for i in range(18):
        side=-1 if i%2==0 else 1
        z=.25+(i//2)*.29+rng.uniform(-.08,.07)
        x=side*(1.04+rng.uniform(.04,.38))
        y=.05+rng.uniform(-.12,.18)
        box(f"cave_strata_{i}",(x,y,z),(rng.uniform(.40,.78),rng.uniform(.18,.34),rng.uniform(.12,.23)),ROCK_L if i%5==0 else ROCK_M,c,rz=rng.uniform(-20,20),bevel=.055)
    # Ground threshold stones pull the cave into terrain.
    for i in range(9):
        x=-1.15+i*.30+rng.uniform(-.08,.08)
        y=-.55+rng.uniform(-.14,.10)
        box(f"cave_threshold_{i}",(x,y,.10),(rng.uniform(.24,.42),rng.uniform(.24,.42),rng.uniform(.10,.22)),ROCK_M,c,rz=rng.uniform(0,180),bevel=.045)
    # Sparse moss and cyan crystals as Valedouro dungeon accent.
    foliage_cluster("cave_moss_cluster",(-1.35,-.03,.35),c,.85,120)
    for i,(x,y,z) in enumerate(((1.42,-.05,.30),(1.60,.00,.19),(-1.20,.08,.82))):
        cone(f"cave_crystal_{i}",(x,y,z),.10,.015,.48 if i==0 else .32,CYAN,c,vertices=6,rot=(0,rng.uniform(-10,10),rng.uniform(0,360)))
    # Old gold lantern at mouth: tiny warm focal counterpoint.
    glow_lantern("cave_old_lantern",(-.75,-.16,1.43),c)

def add_waterfall():
    c=col("LM_WaterfallCliff")
    if not c:return
    rng=random.Random(SEED+30)
    # Break the cliff tiers with broad ledges and vertical strata.
    for i in range(24):
        side=-1 if i%2==0 else 1
        z=.25+(i%8)*.43+rng.uniform(-.06,.07)
        x=side*rng.uniform(1.00,2.45)
        y=rng.uniform(-.42,.55)
        box(f"falls_strata_{i}",(x,y,z),(rng.uniform(.48,.95),rng.uniform(.18,.38),rng.uniform(.12,.24)),ROCK_L if i%6==0 else ROCK_M,c,rz=rng.uniform(-18,18),bevel=.055)
    # Upper lip: irregular rock shelves framing the water origin.
    for i in range(7):
        x=-1.34+i*.44+rng.uniform(-.06,.06)
        box(f"falls_lip_{i}",(x,-.42,3.72),(rng.uniform(.34,.58),.45,rng.uniform(.14,.30)),ROCK_M,c,rz=rng.uniform(-8,8),bevel=.05)
    # Foam/impact stones as source geometry for the later pixel FX pass.
    for i in range(13):
        ang=math.radians(18+i*12)
        x=math.cos(ang)*rng.uniform(.55,1.35)
        y=-1.37-math.sin(ang)*rng.uniform(.20,.60)
        cyl(f"falls_foam_{i}",(x,y,.20),rng.uniform(.09,.20),.05,FOAM,c,vertices=8)
    # Vegetation framing instead of grass caps.
    foliage_cluster("falls_green_l",(-2.15,-.12,2.25),c,1.1,181)
    foliage_cluster("falls_green_r",(2.10,-.03,1.65),c,1.0,182)
    foliage_cluster("falls_green_top",(1.32,.16,3.78),c,.8,183)
    # A couple of bright water highlights.
    for i in range(4):
        box(f"falls_water_hi_{i}",(-.34+i*.23,-.72,2.2+rng.uniform(-.8,.8)),(.08,.025,.46),FOAM,c,rz=rng.uniform(-3,3),bevel=.005)

def main():
    add_watchtower()
    add_windmill()
    add_cave()
    add_waterfall()
    bpy.context.scene["valedouro_landmark_detail_pass"]="APPROVED_DENSITY_V2"
    print("Applied APPROVED-density detail pass to hero-facing landmarks.")

if __name__=="__main__":
    main()
