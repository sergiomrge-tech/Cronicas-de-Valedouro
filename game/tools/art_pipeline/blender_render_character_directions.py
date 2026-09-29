# Run inside Blender 4.x after loading the Valedouro render rig.
# Batch-render source collections into 8 directional PNGs for pixel cleanup.

import bpy
import math
from pathlib import Path

DIRECTIONS = 8
ANGLE_STEP = 360.0 / DIRECTIONS

COLLECTIONS = [
    "NPC_Villager","NPC_Merchant","NPC_Traveler","NPC_Guard",
    "NPC_Blacksmith","NPC_Alchemist","NPC_Guild",
    "FAUNA_Deer","FAUNA_Fox","FAUNA_Hare","FAUNA_Goat",
    "FAUNA_Camel","FAUNA_Bird","FAUNA_Fish"
]


def set_collection_visible(target_name):
    for c in bpy.data.collections:
        if c.name.startswith("NPC_") or c.name.startswith("FAUNA_"):
            hide = c.name != target_name
            c.hide_render = hide
            c.hide_viewport = hide


def collection_objects(name):
    c=bpy.data.collections.get(name)
    return list(c.all_objects) if c else []


def bounds_center(objects):
    pts=[]
    for o in objects:
        if o.type!="MESH":
            continue
        for corner in o.bound_box:
            pts.append(o.matrix_world @ __import__("mathutils").Vector(corner))
    if not pts:
        return __import__("mathutils").Vector((0,0,0))
    mn=pts[0].copy(); mx=pts[0].copy()
    for p in pts[1:]:
        mn.x=min(mn.x,p.x); mn.y=min(mn.y,p.y); mn.z=min(mn.z,p.z)
        mx.x=max(mx.x,p.x); mx.y=max(mx.y,p.y); mx.z=max(mx.z,p.z)
    return (mn+mx)*.5


def rotate_collection(name, angle_deg):
    objs=collection_objects(name)
    if not objs:
        return []
    # Temporary parent preserves internal construction while rotating facing.
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=bounds_center(objs))
    pivot=bpy.context.object
    pivot.name=f"TMP_ROT_{name}"
    for o in objs:
        o.parent=pivot
    pivot.rotation_euler[2]=math.radians(angle_deg)
    return [pivot]+objs


def restore(rotated):
    if not rotated:
        return
    pivot=rotated[0]
    # Apply parent transform back to children so deleting pivot does not move them.
    for o in rotated[1:]:
        mw=o.matrix_world.copy()
        o.parent=None
        o.matrix_world=mw
    bpy.data.objects.remove(pivot,do_unlink=True)


def render_collection(name, out_root):
    if bpy.data.collections.get(name) is None:
        print("SKIP missing",name)
        return
    set_collection_visible(name)
    scene=bpy.context.scene
    base=Path(out_root)/name.lower()
    base.mkdir(parents=True,exist_ok=True)

    for direction in range(DIRECTIONS):
        rotated=rotate_collection(name,direction*ANGLE_STEP)
        scene.render.filepath=str(base/f"dir_{direction:02d}.png")
        bpy.ops.render.render(write_still=True)
        restore(rotated)
        print("OK",name,direction,scene.render.filepath)


def main():
    out_root=bpy.path.abspath("//art_renders/characters")
    for name in COLLECTIONS:
        render_collection(name,out_root)
    print("Directional source renders complete.")
    print("These images still require pixel_finish + manual animation cleanup.")


if __name__=="__main__":
    main()
