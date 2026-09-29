# Run inside Blender 4.x AFTER generating Valedouro source geometry.
# Applies a material treatment calibrated to the APPROVED City/Hub + Dungeon sheet.
#
# This does not make an asset APPROVED. It only moves the pre-render source
# closer to the official color/material language before pixel cleanup.

import bpy

def make(name, hex_color, roughness=.82, metallic=0.0, emission=None, emission_strength=0.0):
    h=hex_color.lstrip("#")
    rgb=tuple(int(h[i:i+2],16)/255.0 for i in (0,2,4))
    m=bpy.data.materials.get(name)
    if m is None:
        m=bpy.data.materials.new(name)
    m.diffuse_color=(*rgb,1.0)
    m.roughness=roughness
    m.metallic=metallic
    m.use_nodes=True
    bsdf=m.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value=(*rgb,1.0)
        bsdf.inputs["Roughness"].default_value=roughness
        bsdf.inputs["Metallic"].default_value=metallic
        if emission:
            eh=emission.lstrip("#")
            ergb=tuple(int(eh[i:i+2],16)/255.0 for i in (0,2,4))
            # Blender 4.x renamed emission sockets.
            if "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value=(*ergb,1.0)
            elif "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value=(*ergb,1.0)
            if "Emission Strength" in bsdf.inputs:
                bsdf.inputs["Emission Strength"].default_value=emission_strength
    return m

# Dark outline-compatible structural values.
OUTLINE=make("VA_Outline","#171526",.92)
WOOD_DARK=make("VA_Wood_Dark","#4D241A",.90)
WOOD_MID=make("VA_Wood_Mid","#9A4A25",.86)
WOOD_LIGHT=make("VA_Wood_Light","#D77B36",.80)

CITY_STONE_DARK=make("VA_CityStone_Dark","#704A4C",.92)
CITY_STONE_MID=make("VA_CityStone_Mid","#C9825A",.90)
CITY_STONE_LIGHT=make("VA_CityStone_Light","#F2C98C",.86)

DUNGEON_DARK=make("VA_Dungeon_Dark","#242441",.94)
DUNGEON_MID=make("VA_Dungeon_Mid","#4E5278",.92)
DUNGEON_LIGHT=make("VA_Dungeon_Light","#8E92B7",.86)

ROOF_BLUE_DARK=make("VA_RoofBlue_Dark","#103B8C",.84)
ROOF_BLUE=make("VA_RoofBlue","#0D67C7",.80)
ROOF_BLUE_LIGHT=make("VA_RoofBlue_Light","#39B7ED",.72)
ROOF_RED=make("VA_RoofRed","#C42F2E",.82)

GOLD=make("VA_Gold","#E5901B",.42,.58)
GOLD_LIGHT=make("VA_Gold_Light","#FFD05B",.35,.62)
IRON=make("VA_Iron","#343A51",.43,.68)

FOLIAGE_DARK=make("VA_Foliage_Dark","#17622B",.98)
FOLIAGE=make("VA_Foliage","#39A438",.98)
FOLIAGE_LIGHT=make("VA_Foliage_Light","#9ACC32",.96)

SAND=make("VA_Sand","#C8863C",.96)
SAND_LIGHT=make("VA_Sand_Light","#EABB69",.94)
SNOW=make("VA_Snow","#C7D7E3",.92)
SNOW_LIGHT=make("VA_Snow_Light","#EDF5F8",.88)

WATER=make("VA_Water","#168CC5",.32)
CYAN=make("VA_Cyan","#20D5FF",.30,0.05,emission="#20D5FF",emission_strength=.65)
PURPLE=make("VA_Purple","#8F36E8",.32,0.05,emission="#9B47FF",emission_strength=.55)

CLOTH_BLUE=make("VA_ClothBlue","#1453A6",.92)
CLOTH_RED=make("VA_ClothRed","#B83232",.92)
CLOTH_GREEN=make("VA_ClothGreen","#27833D",.94)
CLOTH_PURPLE=make("VA_ClothPurple","#623A91",.92)
CLOTH_TAN=make("VA_ClothTan","#A26637",.94)
LEATHER=make("VA_Leather","#5B2D1C",.90)

SKIN_A=make("VA_SkinA","#C88662",.93)
SKIN_B=make("VA_SkinB","#8E553E",.93)
HAIR_DARK=make("VA_HairDark","#2A1820",.96)
HAIR_BROWN=make("VA_HairBrown","#64301F",.96)

FUR_DEER=make("VA_FurDeer","#8F4D25",.98)
FUR_DEER_LIGHT=make("VA_FurDeerLight","#D19555",.98)
FUR_FOX=make("VA_FurFox","#D4541D",.98)
FUR_FOX_LIGHT=make("VA_FurFoxLight","#F1C47C",.98)
FUR_HARE=make("VA_FurHare","#827468",.98)
FUR_GOAT=make("VA_FurGoat","#B7AA91",.98)
FUR_CAMEL=make("VA_FurCamel","#B5793D",.98)
FEATHER=make("VA_Feather","#28537B",.96)
FISH=make("VA_Fish","#2487A5",.72)
FISH_LIGHT=make("VA_FishLight","#65C8C7",.65)

def swap(obj, material):
    if obj.type!="MESH":
        return
    if len(obj.data.materials)==0:
        obj.data.materials.append(material)
    else:
        obj.data.materials[0]=material

def all_objects(collection_name):
    c=bpy.data.collections.get(collection_name)
    return list(c.all_objects) if c else []

def apply_landmarks():
    for name in ("LM_Watchtower","LM_Windmill"):
        for o in all_objects(name):
            n=o.name.lower()
            if "roof" in n:
                swap(o,ROOF_BLUE if "cap" not in n else GOLD)
            elif "banner" in n:
                swap(o,CLOTH_BLUE if "cloth" in n else GOLD)
            elif any(k in n for k in ("foundation","plinth","body","step","rubble")):
                swap(o,CITY_STONE_LIGHT if ("body" in n or "step" in n) else CITY_STONE_MID)
            elif any(k in n for k in ("metal","axle","hub")):
                swap(o,GOLD if "hub" in n else IRON)
            elif any(k in n for k in ("wood","post","brace","deck","rail","ladder","blade","door","lintel","crate","barrel")):
                swap(o,WOOD_LIGHT if any(k in n for k in ("deck","slat","lintel")) else WOOD_MID)

    for name in ("LM_CaveEntrance","LM_WaterfallCliff"):
        for o in all_objects(name):
            n=o.name.lower()
            if "water" in n:
                swap(o,WATER)
            elif "moss" in n:
                swap(o,FOLIAGE)
            elif "beam" in n:
                swap(o,WOOD_MID)
            elif "darkness" in n:
                swap(o,DUNGEON_DARK)
            elif any(k in n for k in ("rock","cliff","tier","basin")):
                swap(o,DUNGEON_LIGHT if ("detail" in n and o.name[-1:].isdigit() and int(o.name[-1])%4==0) else DUNGEON_MID)

def apply_terrain():
    root=bpy.data.collections.get("VALEDOURO_TERRAIN_MODULES")
    if not root:
        return
    for c in root.children:
        biome="snow" if "snow" in c.name.lower() else "sand" if "sand" in c.name.lower() else "grass"
        for o in c.all_objects:
            n=o.name.lower()
            if "cap" in n or "top" in n:
                swap(o,SNOW_LIGHT if biome=="snow" else SAND_LIGHT if biome=="sand" else FOLIAGE)
            elif "strata" in n or "chip" in n:
                swap(o,DUNGEON_LIGHT if biome=="snow" else CITY_STONE_LIGHT if biome=="sand" else CITY_STONE_MID)
            else:
                swap(o,DUNGEON_MID if biome=="snow" else CITY_STONE_MID if biome=="sand" else CITY_STONE_DARK)

def apply_characters():
    root=bpy.data.collections.get("VALEDOURO_NPC_FAUNA")
    if not root:
        return
    for c in root.children:
        cn=c.name
        for o in c.all_objects:
            n=o.name.lower()
            if cn.startswith("NPC_"):
                if any(k in n for k in ("head","neck","arm_")) and "armor" not in n:
                    swap(o,SKIN_B if cn in ("NPC_Guard","NPC_Blacksmith") else SKIN_A)
                elif "hair" in n:
                    swap(o,HAIR_BROWN if cn in ("NPC_Villager","NPC_Blacksmith","NPC_Guild") else HAIR_DARK)
                elif any(k in n for k in ("armor","helmet","hammer_head","spear_tip","coin")):
                    swap(o,GOLD if "coin" in n else IRON)
                elif any(k in n for k in ("boot","belt","satchel","strap","pack","case","harness","glove")):
                    swap(o,LEATHER)
                elif any(k in n for k in ("staff","spear","handle")):
                    swap(o,WOOD_MID)
                elif any(k in n for k in ("vial",)):
                    swap(o,CYAN if o.name.endswith("_0") else PURPLE if o.name.endswith("_1") else FOLIAGE_LIGHT)
                else:
                    cloth={
                        "NPC_Villager":CLOTH_GREEN,
                        "NPC_Merchant":CLOTH_PURPLE,
                        "NPC_Traveler":CLOTH_TAN,
                        "NPC_Guard":CLOTH_RED,
                        "NPC_Blacksmith":CLOTH_TAN,
                        "NPC_Alchemist":CLOTH_PURPLE,
                        "NPC_Guild":CLOTH_BLUE,
                    }.get(cn,CLOTH_BLUE)
                    swap(o,cloth)
            else:
                species=cn.replace("FAUNA_","")
                fur={
                    "Deer":FUR_DEER,"Fox":FUR_FOX,"Hare":FUR_HARE,
                    "Goat":FUR_GOAT,"Camel":FUR_CAMEL,"Bird":FEATHER,"Fish":FISH
                }.get(species,FUR_DEER)
                if "light" in n or "muzzle" in n or "tail_tip" in n or "chest" in n:
                    light={
                        "Deer":FUR_DEER_LIGHT,"Fox":FUR_FOX_LIGHT,
                        "Bird":FISH_LIGHT,"Fish":FISH_LIGHT
                    }.get(species,fur)
                    swap(o,light)
                elif any(k in n for k in ("antler","horn","beak","leg_")) and species in ("Deer","Goat","Bird"):
                    swap(o,WOOD_MID)
                else:
                    swap(o,fur)

def main():
    apply_landmarks()
    apply_terrain()
    apply_characters()
    bpy.context.scene["valedouro_material_pass"]="APPROVED_STYLE_CALIBRATED_V1"
    print("Applied APPROVED-style material calibration to Valedouro generated sources.")

if __name__=="__main__":
    main()
