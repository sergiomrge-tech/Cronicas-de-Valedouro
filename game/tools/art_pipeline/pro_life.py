"""NPCs (famílias com silhueta própria) e fauna animada — produzidos em Blender com rig FK e renderizados em folhas de sprites.

NPC: 5 direções (S, SE, E, NE, N; as outras são espelho) x 12 colunas (4 idle + 8 caminhada), quadro 128x160, pé em (64,132).
Fauna: 10 colunas (4 idle + 6 caminhada) voltada para a direita/frente; o jogo espelha para a esquerda.
"""
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import bpy
from vk import geo, mats, parts, rig
from vk.parts import M
from pro_landmarks import landmark

DIRS = [(0, 1), (1, 1), (1, 0), (1, -1), (0, -1)]       # S, SE, E, NE, N (vetores de tela do jogo)
NPC_COLS, IDLE_N, WALK_N = 12, 4, 8

NPC = {
    'villager_m': dict(skin='#e2ac84', hair='#5a3a20', hair_style='short', top='#4a7a8a', bottom='#6a5038', boots='#3a2418', belt='#5a3a1c', collar='#e8d8b0'),
    'villager_f': dict(sex='f', skin='#efc09a', hair='#8a4a24', hair_style='long', top='#b04a5a', bottom='#b04a5a', skirt=.5, apron='#e8dcc0', boots='#4a2c20', belt='#e8d8b0', build=.92, height=.95),
    'elder': dict(skin='#dca884', hair='#e6e6ee', hair_style='short', beard='#e6e6ee', top='#6a5a8a', bottom='#54486a', robe=True, skirt=.6, boots='#3a2c22', item='staff', build=.95, height=.94, collar='#c8b070'),
    'child': dict(skin='#f0c09a', hair='#a8642c', hair_style='curly', top='#d8a040', bottom='#4a6a9a', boots='#5a3a24', height=.66, head=1.3, build=.85),
    'farmer': dict(skin='#d89a70', hair='#5a3a20', hat='straw', top='#a8a06a', bottom='#5a4a34', apron='#8a6a3a', boots='#3a2a1c', item='pitchfork', build=1.05),
    'merchant': dict(skin='#c88a62', hair='#2a1a10', hat='cap', hat_color='#a03030', top='#7a2a3a', bottom='#3a3040', collar='#e8c860', boots='#2a1c18', pack='#8a5a2c', item='basket', build=1.1, beard='#2a1a10'),
    'traveler': dict(skin='#e0a880', hair='#4a3020', hat='hood', hat_color='#4a6a4a', top='#6a5a3a', bottom='#4a4030', cape='#4a6a4a', pack='#7a5a30', item='staff', boots='#3a2a1c'),
    'hunter': dict(sex='f', skin='#d09a72', hair='#2a1a10', hat='hood', hat_color='#4a5a3a', top='#6a5a3a', bottom='#3a3a2a', cape='#3a4a2a', gloves='#5a3a22', item='bow', boots='#2a2018', build=.92, height=.98),
    'guard': dict(skin='#d8a078', hat='helmet', top='#2a4aa8', bottom='#3a3a4a', cape='#1c2c78', gloves='#8a8ea4', item='spear', boots='#2a2a34', build=1.15, height=1.03, collar='#d8a838', long_sleeves=True, sleeve='#8a8ea4'),
    'smith': dict(skin='#c88a62', hair='#2a1a10', hair_style='bald_side', beard='#3a2418', top='#8a5a3a', bottom='#4a3a30', apron='#5a4030', gloves='#5a3a22', item='hammer', boots='#241814', build=1.22, height=1.0),
    'alchemist': dict(sex='f', skin='#e8b892', hair='#e6d8f4', hair_style='long', hat='pointy', hat_color='#5a2a8a', top='#6a3a9a', bottom='#6a3a9a', robe=True, skirt=.72, item='flask', boots='#2a1c30', collar='#e8c860', long_sleeves=True, sleeve='#8a5aba', build=.95),
    'guildmaster': dict(skin='#d8a078', hair='#8a8a94', hair_style='short', beard='#8a8a94', top='#8a2a2a', bottom='#2a2a3a', cape='#2a4aa8', collar='#e8c860', item='scroll', boots='#2a1c18', build=1.08, height=1.02),
    'miller': dict(skin='#e0a880', hair='#e8e0d0', hat='bandana', hat_color='#e8e0d0', top='#e8dcc0', bottom='#8a7a5a', apron='#c8b48a', boots='#3a2a1c', build=1.18, height=.98, beard='#e8e0d0'),
    'shopkeeper': dict(sex='f', skin='#efc09a', hair='#6a3a20', hair_style='bun', top='#e8dcc0', bottom='#3a7a5a', skirt=.55, apron='#3a7a5a', boots='#4a2c20', build=.95),
}


def _npc_frame(spec):
    def build(f, row):
        rig.reset_mc()
        fx, fy = DIRS[row]
        fw = rig.screen_to_world(fx, fy)
        b = rig.Body(fw)
        if f < IDLE_N:
            rig.humanoid(b, spec, phase=None, idle=f / IDLE_N)
        else:
            rig.humanoid(b, spec, phase=(f - IDLE_N) / WALK_N)
    return build


for _name, _spec in NPC.items():
    landmark('npc_' + _name, group='npc', folder='npc', size=(128, 160), origin=(64, 134), frames=NPC_COLS, rows=5, tags=('npc', 'animado', _name), footprint=10,
             samples=12, colors=112, outline=1, draw_scale=.5, exposure=0.05)(_npc_frame(_spec))


# ------------------------------------------------------------------ fauna
FAUNA_Q = {
    'deer': dict(fur='#a8683a', belly='#ecd8b4', length=.95, height=.95, body_h=.27, leg1=.40, leg2=.40, thick=.045, neck=.5, neck_angle=55, head=.14, horns='antlers', tail='short', tail_mat='#f4ecdc', hoof='#2a2020', ear=(.07, .17), ear_out=True, size=(220, 220), origin=(110, 170)),
    'fox': dict(fur='#dc6a1e', belly='#f6efdd', dark='#241610', length=.55, height=.4, body_h=.15, leg1=.14, leg2=.12, thick=.028, neck=.14, neck_angle=35, head=.1, tail='bushy', ear=(.05, .12), leg_fur=False, size=(170, 150), origin=(85, 120)),
    'hare': dict(fur='#b8996f', belly='#f2e8d2', length=.38, height=.3, body_h=.13, leg1=.1, leg2=.09, thick=.03, neck=.08, neck_angle=30, head=.075, tail='short', tail_mat='#fff8ec', ear=(.045, .22), size=(130, 130), origin=(65, 104)),
    'goat': dict(fur='#eeeadf', belly='#ffffff', dark='#3a2c22', length=.7, height=.62, body_h=.2, leg1=.28, leg2=.26, thick=.035, neck=.3, neck_angle=50, head=.1, horns='goat', tail='short', ear=(.06, .08), ear_out=True, leg_fur=False, hoof='#2a2220', size=(190, 190), origin=(95, 150)),
    'camel': dict(fur='#c9a062', belly='#e8cf9c', length=1.15, height=1.25, body_h=.3, leg1=.56, leg2=.52, thick=.05, neck=.7, neck_angle=62, head=.14, hump=(.14, -.2), tail='thin', ear=(.04, .06), size=(280, 280), origin=(140, 215)),
}


def _quad(sp):
    def build(f):
        rig.reset_mc()
        d = rig.screen_to_world(.95, .55)
        b = rig.Body(d)
        if f < 4:
            rig.quadruped(b, sp, phase=None, idle=f / 4)
        else:
            rig.quadruped(b, sp, phase=(f - 4) / 6)
    return build


for _n, _sp in FAUNA_Q.items():
    landmark('fau_' + _n, group='nature', folder='fauna', size=_sp['size'], origin=_sp['origin'], frames=10, tags=('fauna', 'animado', _n), footprint=8, samples=12, colors=112, outline=1, exposure=0.0)(_quad(_sp))


def build_bird(f):
    rig.reset_mc()
    b = rig.Body(rig.screen_to_world(.95, .3))
    fur = rig.MC('bird', '#3a6ab8', rough=.85)
    belly = rig.MC('bbelly', '#f0e8d0', rough=.85)
    dark = rig.MC('bdark', '#181010')
    beak = rig.MC('beak', '#f0a030', rough=.6)
    ph = f / 6
    flap = math.sin(2 * math.pi * ph)
    z = .55 + math.cos(2 * math.pi * ph) * .03
    b.ellipsoid((0, 0, z), (.07, .16, .07), fur)
    b.ellipsoid((0, .03, z - .03), (.06, .12, .05), belly)
    b.ellipsoid((0, .16, z + .03), (.055, .06, .055), fur)
    b.line((0, .215, z + .03), (0, .28, z + .015), .018, beak, sides=5, r2=.004)
    b.ellipsoid((.03, .19, z + .05), (.008, .008, .01), dark)
    b.ellipsoid((-.03, .19, z + .05), (.008, .008, .01), dark)
    b.ellipsoid((0, -.2, z - .01), (.035, .13, .012), fur)              # cauda
    for sx in (-1, 1):
        ang = math.radians(35 * flap + 15)
        tip = (sx * math.cos(ang) * .36, -.02, z + math.sin(ang) * .3 * sx * sx)
        mid = (sx * .18, 0, z + math.sin(ang) * .12)
        b.capsule((sx * .05, 0, z + .03), mid, .028, .02, fur)
        b.line(mid, tip, .022, rig.MC('wing', '#2a4a90', rough=.85), sides=6, r2=.006)
        b.ellipsoid(((mid[0] + tip[0]) / 2, -.03, (mid[2] + tip[2]) / 2), (.15, .09, .012), rig.MC('wing', '#2a4a90', rough=.85), rot=(0, sx * 12 * flap, 0))


landmark('fau_bird', group='nature', folder='fauna', size=(120, 110), origin=(60, 40), frames=6, tags=('fauna', 'animado', 'ave'), footprint=4, samples=12, colors=96, outline=1)(build_bird)


def build_fish(f):
    rig.reset_mc()
    b = rig.Body(rig.screen_to_world(1, .1))
    fur = rig.MC('fish', '#e8843a', rough=.35)
    belly = rig.MC('fbelly', '#f8e0b0', rough=.4)
    fin = rig.MC('fin', '#f4b060', rough=.5)
    dark = rig.MC('fdark', '#181010')
    ph = f / 6
    s = math.sin(2 * math.pi * ph)
    z = .06
    for i, (y, r) in enumerate(((.16, .05), (.07, .075), (-.02, .075), (-.11, .055))):
        b.ellipsoid((s * .012 * (1 - i * .4), y, z), (r * .85, .1, r), fur)
    b.ellipsoid((0, .0, z - .025), (.05, .16, .035), belly)
    b.ellipsoid((.032, .2, z + .01), (.008, .01, .012), dark)
    b.ellipsoid((-.032, .2, z + .01), (.008, .01, .012), dark)
    tail_x = s * .06
    b.ellipsoid((tail_x, -.27, z), (.012, .09, .075), fin, rot=(0, 0, s * 25))
    b.ellipsoid((s * .02, .0, z + .075), (.008, .09, .05), fin)
    b.ellipsoid((.06, .04, z - .03), (.07, .04, .008), fin, rot=(0, 0, 30 * s))
    # anel de ondulação na superfície
    ripple = mats.flat('ripple', '#bfeaff', rough=.3, spec=.5, bevel_wear=0.0)
    r = .22 + .1 * ph
    geo.cyl((0, 0, -.005), r, .01, ripple, sides=20).scale = (1, .9, 1)


landmark('fau_fish', group='nature', folder='fauna', size=(110, 90), origin=(55, 45), frames=6, tags=('fauna', 'animado', 'peixe'), footprint=4, samples=12, colors=96, outline=1, catcher=False)(build_fish)
