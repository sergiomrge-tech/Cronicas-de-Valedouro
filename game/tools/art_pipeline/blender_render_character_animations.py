# Run inside Blender 4.x after blender_npc_fauna_reg001.py + render rig.
# Renders deterministic 8-direction animation frame sources for the character packer.
#
# This is a low-amplitude source-animation pass intended for later hand pixel
# cleanup. It gives coherent body motion while preserving the modeled silhouette.

import bpy
import math
from pathlib import Path
from mathutils import Matrix, Vector

DIRECTIONS=8
ANGLE_STEP=45.0

NPC_ANIMS={"idle":4,"walk":8,"interact":6}
FAUNA_ANIMS={
    "FAUNA_Deer":{"idle":5,"walk":8},
    "FAUNA_Fox":{"idle":5,"walk":8},
    "FAUNA_Hare":{"idle":4,"walk":7},
    "FAUNA_Goat":{"idle":5,"walk":8},
    "FAUNA_Camel":{"idle":5,"walk":8},
    "FAUNA_Bird":{"idle":4,"fly":8},
    "FAUNA_Fish":{"swim":8},
}
NPC_COLLECTIONS=[
    "NPC_Villager","NPC_Merchant","NPC_Traveler","NPC_Guard",
    "NPC_Blacksmith","NPC_Alchemist","NPC_Guild"
]

def character_collections():
    return NPC_COLLECTIONS + list(FAUNA_ANIMS.keys())

def set_visible(target):
    for name in character_collections():
        c=bpy.data.collections.get(name)
        if c:
            hide=name!=target
            c.hide_render=hide
            c.hide_viewport=hide

def objects(name):
    c=bpy.data.collections.get(name)
    return [o for o in c.all_objects if o.type in {"MESH","EMPTY"}] if c else []

def bounds_center(objs):
    pts=[]
    for o in objs:
        if o.type!="MESH": continue
        for corner in o.bound_box:
            pts.append(o.matrix_world @ Vector(corner))
    if not pts:return Vector((0,0,0))
    mn=pts[0].copy();mx=pts[0].copy()
    for p in pts[1:]:
        mn.x=min(mn.x,p.x);mn.y=min(mn.y,p.y);mn.z=min(mn.z,p.z)
        mx.x=max(mx.x,p.x);mx.y=max(mx.y,p.y);mx.z=max(mx.z,p.z)
    c=(mn+mx)*.5
    c.z=0
    return c

def create_roots(name,objs):
    center=bounds_center(objs)
    bpy.ops.object.empty_add(type="PLAIN_AXES",location=center)
    direction_root=bpy.context.object
    direction_root.name=f"TMP_DIR_{name}"
    bpy.ops.object.empty_add(type="PLAIN_AXES",location=center)
    pose_root=bpy.context.object
    pose_root.name=f"TMP_POSE_{name}"
    pose_root.parent=direction_root

    for o in objs:
        mw=o.matrix_world.copy()
        o.parent=pose_root
        o.matrix_world=mw

    base={o:o.matrix_basis.copy() for o in objs}
    pose_base=pose_root.matrix_basis.copy()
    return direction_root,pose_root,base,pose_base

def restore_base(objs,base,pose_root,pose_base):
    pose_root.matrix_basis=pose_base.copy()
    for o in objs:
        o.matrix_basis=base[o].copy()

def delta_local(obj,translation=(0,0,0),rot_deg=(0,0,0),scale=(1,1,1)):
    # Applied around object origin; amplitudes intentionally small because
    # final silhouette cleanup happens at pixel-art stage.
    rx,ry,rz=(math.radians(v) for v in rot_deg)
    M=Matrix.Translation(Vector(translation))
    M=M @ Matrix.Rotation(rz,4,"Z") @ Matrix.Rotation(ry,4,"Y") @ Matrix.Rotation(rx,4,"X")
    M=M @ Matrix.Diagonal(Vector((scale[0],scale[1],scale[2],1.0)))
    obj.matrix_basis=M @ obj.matrix_basis

def name_has(o,*tokens):
    n=o.name.lower()
    return any(t in n for t in tokens)

def pose_npc(objs,pose_root,anim,frame,count):
    phase=(frame/count)*math.tau
    if anim=="idle":
        bob=math.sin(phase)*.018
        delta_local(pose_root,translation=(0,0,bob))
        for o in objs:
            if name_has(o,"head","hair","hood","helmet"):
                delta_local(o,rot_deg=(0,math.sin(phase)*1.2,0))
            if name_has(o,"banner","cloak"):
                delta_local(o,rot_deg=(0,0,math.sin(phase+.7)*1.4))
    elif anim=="walk":
        swing=math.sin(phase)
        bob=(1-math.cos(phase*2))*.025
        delta_local(pose_root,translation=(0,0,bob))
        for o in objs:
            if name_has(o,"leg_l","boot_l"):
                delta_local(o,translation=(swing*.035,0,0),rot_deg=(0,swing*8,0))
            elif name_has(o,"leg_r","boot_r"):
                delta_local(o,translation=(-swing*.035,0,0),rot_deg=(0,-swing*8,0))
            elif name_has(o,"arm_l"):
                delta_local(o,rot_deg=(0,-swing*7,0))
            elif name_has(o,"arm_r"):
                delta_local(o,rot_deg=(0,swing*7,0))
            elif name_has(o,"pack","satchel","cloak","bedroll"):
                delta_local(o,rot_deg=(0,0,-swing*1.8))
    elif anim=="interact":
        # Smooth reach-and-return cycle.
        reach=math.sin(min(1.0,frame/max(1,count-1))*math.pi)
        delta_local(pose_root,translation=(0,0,reach*.012))
        for o in objs:
            if name_has(o,"arm_r","glove_r","hammer_handle","hammer_head","staff"):
                delta_local(o,rot_deg=(0,-reach*18,reach*5))
            if name_has(o,"head","hair","hood","helmet"):
                delta_local(o,rot_deg=(reach*3,0,0))

def pose_quadruped(objs,pose_root,anim,frame,count,species):
    phase=(frame/count)*math.tau
    if anim=="idle":
        delta_local(pose_root,translation=(0,0,math.sin(phase)*.012))
        for o in objs:
            if name_has(o,"head","muzzle","ear"):
                delta_local(o,rot_deg=(0,math.sin(phase)*1.8,0))
            if name_has(o,"tail"):
                delta_local(o,rot_deg=(0,0,math.sin(phase+.8)*2.8))
    elif anim=="walk":
        s=math.sin(phase)
        delta_local(pose_root,translation=(0,0,(1-math.cos(phase*2))*.018))
        for o in objs:
            n=o.name.lower()
            if "leg" in n:
                sign=-1.0 if ("_r_" in n or n.endswith("_1")) else 1.0
                delta_local(o,rot_deg=(0,s*sign*9,0),translation=(s*sign*.025,0,0))
            elif "head" in n or "neck" in n:
                delta_local(o,rot_deg=(0,-s*2,0))
            elif "tail" in n:
                delta_local(o,rot_deg=(0,0,-s*4))

def pose_bird(objs,pose_root,anim,frame,count):
    phase=(frame/count)*math.tau
    if anim=="idle":
        delta_local(pose_root,translation=(0,0,math.sin(phase)*.014))
        for o in objs:
            if name_has(o,"head","beak"):
                delta_local(o,rot_deg=(0,math.sin(phase)*2,0))
    elif anim=="fly":
        flap=math.sin(phase)
        delta_local(pose_root,translation=(0,0,math.sin(phase*2)*.025))
        for o in objs:
            if name_has(o,"wing_l"):
                delta_local(o,rot_deg=(flap*28,0,0))
            elif name_has(o,"wing_r"):
                delta_local(o,rot_deg=(-flap*28,0,0))

def pose_fish(objs,pose_root,frame,count):
    phase=(frame/count)*math.tau
    wag=math.sin(phase)
    delta_local(pose_root,translation=(0,math.sin(phase*.5)*.01,math.sin(phase)*.01))
    for o in objs:
        if name_has(o,"tail"):
            delta_local(o,rot_deg=(0,0,wag*16))
        elif name_has(o,"body","head"):
            delta_local(o,rot_deg=(0,0,-wag*2.5))

def pose(name,objs,pose_root,anim,frame,count):
    if name.startswith("NPC_"):
        pose_npc(objs,pose_root,anim,frame,count)
    elif name=="FAUNA_Bird":
        pose_bird(objs,pose_root,anim,frame,count)
    elif name=="FAUNA_Fish":
        pose_fish(objs,pose_root,frame,count)
    else:
        pose_quadruped(objs,pose_root,anim,frame,count,name)

def animation_map(name):
    if name.startswith("NPC_"): return NPC_ANIMS
    return FAUNA_ANIMS[name]

def out_id(name):
    return name.lower()

def render_character(name,out_root):
    objs=objects(name)
    if not objs:
        print("SKIP missing",name)
        return
    set_visible(name)
    droot,proot,base,pbase=create_roots(name,objs)
    scene=bpy.context.scene
    root=Path(out_root)/out_id(name)

    try:
        for direction in range(DIRECTIONS):
            droot.rotation_euler[2]=math.radians(direction*ANGLE_STEP)
            for anim,count in animation_map(name).items():
                folder=root/anim/f"dir_{direction:02d}"
                folder.mkdir(parents=True,exist_ok=True)
                for frame in range(count):
                    restore_base(objs,base,proot,pbase)
                    pose(name,objs,proot,anim,frame,count)
                    scene.render.filepath=str(folder/f"frame_{frame:02d}.png")
                    bpy.ops.render.render(write_still=True)
                    print("OK",name,anim,direction,frame)
    finally:
        # restore object parenting/world transforms
        restore_base(objs,base,proot,pbase)
        for o in objs:
            mw=o.matrix_world.copy()
            o.parent=None
            o.matrix_world=mw
        bpy.data.objects.remove(proot,do_unlink=True)
        bpy.data.objects.remove(droot,do_unlink=True)

def main():
    out_root=bpy.path.abspath("//art_renders/character_animation")
    for name in character_collections():
        render_character(name,out_root)
    print("Character animation source renders complete.")
    print("Next: pixel_finish/manual cleanup -> pack_character_sheets.py -> candidate manifest.")

if __name__=="__main__":
    main()
