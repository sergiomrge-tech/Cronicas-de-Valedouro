"""VK — personagens e animais: partes orgânicas suaves + cinemática direta (caminhada/idle) construídas por quadro.

Sistema local do corpo: x = direita do personagem, y = frente, z = cima. `Body` converte para o mundo do Blender
girando pelo rumo (heading) desejado.
"""
import math

import bpy
from mathutils import Matrix, Vector

from . import geo, mats
from .parts import M


def screen_to_world(fx, fy):
    """Direção 2D do jogo (x direita, y baixo) -> vetor de mundo do Blender na câmera dimétrica (direita=(-1,1), para a câmera=(1,1))."""
    r = Vector((-1, 1, 0)) / math.sqrt(2)
    c = Vector((1, 1, 0)) / math.sqrt(2)
    v = r * fx + c * fy
    return v.normalized()


class Body:
    def __init__(self, fw, origin=(0, 0, 0), scale=1.0):
        self.fw = Vector(fw).normalized()
        self.right = Vector((self.fw.y, -self.fw.x, 0.0))
        self.o = Vector(origin)
        self.s = scale
        self.heading = math.atan2(self.fw.y, self.fw.x) - math.pi / 2     # local +y -> fw

    def P(self, x, y, z):
        return self.o + (self.right * x + self.fw * y + Vector((0, 0, z))) * self.s

    # ---- primitivas orgânicas
    def ellipsoid(self, c, r, mat, rot=(0, 0, 0), seg=14, rings=9, smooth=True):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=rings, radius=1.0)
        o = bpy.context.object
        o.scale = (r[0] * self.s, r[1] * self.s, r[2] * self.s)
        o.location = self.P(*c)
        o.rotation_euler = (math.radians(rot[0]), math.radians(rot[1]), self.heading + math.radians(rot[2]))
        if smooth:
            for p in o.data.polygons:
                p.use_smooth = True
        o.data.materials.append(mat)
        return o

    def capsule(self, a, b, ra, rb, mat, sides=10):
        pa, pb = self.P(*a), self.P(*b)
        o = geo.cyl_between(pa, pb, ra * self.s, mat, sides=sides, r2=rb * self.s)
        for p in o.data.polygons:
            p.use_smooth = True
        for pt, r in ((pa, ra), (pb, rb)):
            bpy.ops.mesh.primitive_uv_sphere_add(segments=10, ring_count=7, radius=r * self.s, location=pt)
            s = bpy.context.object
            for p in s.data.polygons:
                p.use_smooth = True
            s.data.materials.append(mat)
        return o

    def cone(self, c, r0, r1, h, mat, sides=14, rot=(0, 0, 0)):
        pa = self.P(*c)
        o = geo.cyl(tuple(pa), r0 * self.s, h * self.s, mat, sides=sides, r2=r1 * self.s)
        for p in o.data.polygons:
            p.use_smooth = True
        return o

    def box(self, c, size, mat, rot_z=0, bevel=0.01):
        return geo.box(tuple(self.P(*c)), tuple(v * self.s for v in size), mat, rot=(0, 0, math.degrees(self.heading) + rot_z), bevel=bevel * self.s)

    def beam(self, a, b, w, t, mat):
        return geo.beam(tuple(self.P(*a)), tuple(self.P(*b)), w * self.s, t * self.s, mat, bevel=0.005)

    def line(self, a, b, r, mat, sides=6, r2=None):
        return geo.cyl_between(tuple(self.P(*a)), tuple(self.P(*b)), r * self.s, mat, sides=sides, r2=(None if r2 is None else r2 * self.s))


# ---------------------------------------------------------------- materiais de personagem
_mc = {}


def MC(key, color=None, rough=0.85, cloth=False, metal=False):
    k = (key, color)
    if k in _mc:
        try:
            _mc[k].name
            if _mc[k].name in bpy.data.materials:
                return _mc[k]
        except ReferenceError:
            pass
    if cloth:
        m = mats.cloth('c_' + key, color, rough=rough)
    elif metal:
        m = mats.flat('m_' + key, color, rough=0.4, spec=0.7, metallic=0.85, bevel_wear=0.0)
    else:
        m = mats.flat('f_' + key, color, rough=rough, spec=0.12, bevel_wear=0.0)
    _mc[k] = m
    return m


def reset_mc():
    _mc.clear()


# ---------------------------------------------------------------- humanoide
def ik2(hip, length1, length2, ang1, bend):
    """Perna/braço no plano yz local: retorna (joelho, tornozelo) dado o ângulo do 1º segmento (0 = para baixo, + = para frente) e a flexão."""
    a1 = math.radians(ang1)
    k = (hip[0], hip[1] + math.sin(a1) * length1, hip[2] - math.cos(a1) * length1)
    a2 = math.radians(ang1 - bend)
    f = (k[0], k[1] + math.sin(a2) * length2, k[2] - math.cos(a2) * length2)
    return k, f


def humanoid(b, spec, phase=None, idle=0.0, t_walk=0.0):
    """b = Body. spec: dict de aparência. phase: 0..1 do ciclo de caminhada (None = parado); idle: 0..1 do ciclo de respiração."""
    sk = MC('skin', spec.get('skin', '#e8b48a'))
    hair = MC('hair', spec.get('hair', '#4a2c18'))
    top = MC('top', spec.get('top', '#3a6ab8'), cloth=True)
    top2 = MC('top2', spec.get('top2', '#e8d8a8'), cloth=True)
    bot = MC('bot', spec.get('bottom', '#5a4630'), cloth=True)
    boots = MC('boots', spec.get('boots', '#3a2418'), rough=0.7)
    belt = MC('belt', spec.get('belt', '#5a3a1c'), rough=0.7)
    dark = MC('dark', '#140c10', rough=0.6)
    height = spec.get('height', 1.0)
    build = spec.get('build', 1.0)
    sex = spec.get('sex', 'm')
    robe = spec.get('robe', False)
    k = phase
    bob = 0.0
    lean = 3.0
    swing_l = swing_r = 0.0
    bend_l = bend_r = 0.0
    arm_l = arm_r = 0.0
    if k is not None:
        s = math.sin(2 * math.pi * k)
        swing_r, swing_l = 30 * s, -30 * s
        bend_r = max(0.0, -math.sin(2 * math.pi * k + 0.5)) * 42 + 4
        bend_l = max(0.0, math.sin(2 * math.pi * k + 0.5)) * 42 + 4
        arm_r, arm_l = -24 * s, 24 * s
        bob = abs(math.cos(2 * math.pi * k)) * 0.035
    else:
        breathe = math.sin(2 * math.pi * idle)
        bob = breathe * 0.008
        arm_r = 3 * breathe
        arm_l = -3 * breathe
    H = 0.86 * height
    hip_z = H + bob
    hw = 0.115 * build
    # ---- pernas
    for side, sw, bd in ((1, swing_r, bend_r), (-1, swing_l, bend_l)):
        hip = (side * hw, 0.0, hip_z)
        kn, an = ik2(hip, 0.43 * height, 0.42 * height, sw, bd)
        b.capsule(hip, kn, 0.092 * build, 0.076 * build, bot)
        b.capsule(kn, an, 0.076 * build, 0.06 * build, bot)
        # botas: cano + pé
        b.capsule((an[0], an[1], an[2] + 0.14), (an[0], an[1], an[2] + 0.02), 0.078 * build, 0.082 * build, boots)
        b.ellipsoid((an[0], an[1] + 0.07, max(0.045, an[2] + 0.02 if an[2] < 0.05 else an[2])), (0.078 * build, 0.15, 0.06), boots)
    # ---- tronco: pélvis, cintura, peito; túnica/roupão
    lean_rad = math.radians(lean if k is not None else 0)
    def up(y_off, z):
        return (0.0, y_off + math.sin(lean_rad) * (z - hip_z), z)
    torso_w = 0.27 * build * (0.9 if sex == 'f' else 1.0)
    b.ellipsoid((0, 0, hip_z + 0.06), (0.19 * build, 0.135 * build, 0.14), top if not spec.get('bottom_tunic') else bot)
    chest_c = up(0, hip_z + 0.36)
    b.ellipsoid(chest_c, (torso_w, 0.155 * build, 0.25), top, rot=(0, 0, 0))
    b.ellipsoid((0, chest_c[1] + 0.02, hip_z + 0.19), (0.2 * build, 0.14 * build, 0.16), top)
    if spec.get('collar'):
        b.ellipsoid(up(0, hip_z + 0.6), (0.14, 0.11, 0.05), MC('collar', spec['collar'], cloth=True))
    # saia/roupão
    skirt = spec.get('skirt')                       # comprimento até (0..H)
    if skirt:
        b.cone((0, 0, hip_z - skirt), 0.24 * build + skirt * 0.15, 0.17 * build, skirt + 0.1, top if robe else bot, sides=18)
    # cinto
    b.cone((0, 0, hip_z + 0.06), 0.20 * build, 0.20 * build, 0.06, belt, sides=16)
    b.ellipsoid((0, 0.155 * build, hip_z + 0.09), (0.035, 0.015, 0.03), MC('buckle', '#d8a838', metal=True))
    if spec.get('apron'):
        b.box((0, 0.14 * build, hip_z - 0.12), (0.30 * build, 0.03, 0.55), MC('apron', spec['apron'], rough=0.8, cloth=True), bevel=0.01)
    # ---- braços
    sh_z = hip_z + 0.53
    sh_y = chest_c[1]
    arm_pose = spec.get('arm_pose', None)
    hands = {}
    for side, sw in ((1, arm_r), (-1, arm_l)):
        sh = (side * (torso_w + 0.04), sh_y, sh_z)
        elb, hand = ik2(sh, 0.30 * height, 0.28 * height, sw, -abs(sw) * 0.4 - 22)
        if arm_pose and side == 1:
            elb, hand = arm_pose
        b.ellipsoid(sh, (0.075 * build, 0.075 * build, 0.075 * build), top)
        b.capsule(sh, elb, 0.076 * build, 0.066 * build, top)
        sl = MC('sleeve', spec.get('sleeve', spec.get('top', '#3a6ab8')), cloth=True)
        b.capsule(elb, hand, 0.062 * build, 0.052 * build, sl if spec.get('long_sleeves') else sk)
        b.ellipsoid(hand, (0.06, 0.06, 0.065), sk if not spec.get('gloves') else MC('gloves', spec['gloves'], rough=0.8))
        hands[side] = hand
    # ---- pescoço e cabeça
    head_c = (0, sh_y + 0.02 + math.sin(lean_rad) * 0.1, hip_z + 0.83)
    b.capsule((0, sh_y, hip_z + 0.62), (0, head_c[1], head_c[2] - 0.09), 0.055, 0.05, sk)
    hr = 0.21 * spec.get('head', 1.0)
    b.ellipsoid(head_c, (hr * 0.98, hr * 0.94, hr * 1.06), sk)
    # rosto: olhos, sobrancelhas, nariz, boca
    ey = head_c[1] + hr * 0.86
    b.ellipsoid((0.075, ey, head_c[2] + 0.015), (0.034, 0.02, 0.048), dark)
    b.ellipsoid((-0.075, ey, head_c[2] + 0.015), (0.034, 0.02, 0.048), dark)
    b.ellipsoid((0.075, ey + 0.012, head_c[2] + 0.03), (0.012, 0.008, 0.016), MC('eyeglint', '#ffffff'))
    b.ellipsoid((-0.075, ey + 0.012, head_c[2] + 0.03), (0.012, 0.008, 0.016), MC('eyeglint', '#ffffff'))
    b.ellipsoid((0, ey + 0.02, head_c[2] - 0.035), (0.034, 0.034, 0.034), MC('nose', spec.get('skin_dark', '#d09a74')))
    b.ellipsoid((0, ey + 0.004, head_c[2] - 0.085), (0.04, 0.016, 0.014), MC('mouth', '#a4443c'))
    b.ellipsoid((0.11, head_c[1] - 0.005, head_c[2] - 0.01), (0.022, 0.03, 0.04), sk)      # orelhas
    b.ellipsoid((-0.11, head_c[1] - 0.005, head_c[2] - 0.01), (0.022, 0.03, 0.04), sk)
    # cabelo / chapéus / capuz
    style = spec.get('hair_style', 'short')
    hc = head_c
    if style in ('short', 'long', 'bun', 'curly', 'bald_side'):
        b.ellipsoid((hc[0], hc[1] - 0.02, hc[2] + 0.05), (hr * 1.04, hr * 1.02, hr * 0.95), hair)
        b.ellipsoid((hc[0], hc[1] + hr * 0.62, hc[2] + hr * 0.62), (hr * 0.85, hr * 0.32, hr * 0.28), hair)      # franja
        if style == 'long':
            b.capsule((0.0, hc[1] - hr * 0.7, hc[2] + 0.0), (0.0, hc[1] - hr * 0.9, hc[2] - 0.34), hr * 0.8, hr * 0.5, hair)
        if style == 'bun':
            b.ellipsoid((0, hc[1] - hr * 0.8, hc[2] + hr * 0.7), (0.09, 0.09, 0.08), hair)
        if style == 'curly':
            for ox, oz in ((-.12, .1), (.12, .1), (0, .18), (-.14, -.02), (.14, -.02)):
                b.ellipsoid((hc[0] + ox, hc[1] - 0.02, hc[2] + oz), (0.08, 0.08, 0.08), hair)
    if spec.get('beard'):
        bc = MC('beard', spec['beard'])
        b.ellipsoid((0, hc[1] + hr * 0.62, hc[2] - hr * 0.72), (hr * 0.62, hr * 0.42, hr * 0.5), bc)
        b.ellipsoid((0, hc[1] + hr * 0.9, hc[2] - hr * 0.4), (hr * 0.4, hr * 0.14, hr * 0.12), bc)
    hat = spec.get('hat')
    if hat == 'straw':
        hm = MC('straw', '#d8b45a', rough=0.95)
        b.ellipsoid((hc[0], hc[1], hc[2] + hr * 0.7), (hr * 1.9, hr * 1.9, 0.04), hm)
        b.ellipsoid((hc[0], hc[1], hc[2] + hr * 0.95), (hr * 1.0, hr * 1.0, hr * 0.55), hm)
        b.cone((hc[0], hc[1], hc[2] + hr * 0.78), hr * 1.02, hr * 1.02, 0.03, MC('hatband', '#a03a2a', cloth=True))
    elif hat == 'pointy':
        hm = MC('pointy', spec.get('hat_color', '#5a2a8a'), cloth=True)
        b.ellipsoid((hc[0], hc[1], hc[2] + hr * 0.72), (hr * 1.6, hr * 1.6, 0.03), hm)
        b.cone((hc[0], hc[1] - 0.02, hc[2] + hr * 0.72), hr * 0.98, 0.02, 0.5, hm, sides=14)
    elif hat == 'cap':
        hm = MC('cap', spec.get('hat_color', '#3a6a3a'), cloth=True)
        b.ellipsoid((hc[0], hc[1] - 0.01, hc[2] + hr * 0.5), (hr * 1.08, hr * 1.06, hr * 0.7), hm)
        b.ellipsoid((hc[0], hc[1] + hr * 0.85, hc[2] + hr * 0.5), (hr * 0.8, hr * 0.5, 0.025), hm)
    elif hat == 'hood':
        hm = MC('hood', spec.get('hat_color', '#5a6a4a'), cloth=True)
        b.ellipsoid((hc[0], hc[1] - 0.03, hc[2] + 0.03), (hr * 1.22, hr * 1.2, hr * 1.2), hm)
        b.ellipsoid((hc[0], hc[1] - hr * 0.6, hc[2] - 0.12), (hr * 1.1, hr * 0.8, hr * 1.1), hm)
    elif hat == 'helmet':
        hm = MC('helmet', '#9aa0b4', metal=True)
        b.ellipsoid((hc[0], hc[1], hc[2] + 0.05), (hr * 1.1, hr * 1.08, hr * 0.95), hm)
        b.box((0, hc[1] + hr * 0.95, hc[2] + 0.02), (0.03, 0.03, 0.2), hm)
        b.ellipsoid((0, hc[1], hc[2] + hr * 1.05), (0.03, 0.14, 0.05), MC('plume', '#b83030', cloth=True))
    elif hat == 'bandana':
        b.cone((hc[0], hc[1], hc[2] + hr * 0.35), hr * 1.02, hr * 1.02, 0.09, MC('bandana', spec.get('hat_color', '#b83030'), cloth=True))
    # manto / capa
    if spec.get('cape'):
        cm = MC('cape', spec['cape'], cloth=True)
        z_top = sh_z + 0.02
        verts, faces = [], []
        nz_, nx_ = 6, 6
        for j in range(nz_ + 1):
            t = j / nz_
            for i in range(nx_ + 1):
                u = i / nx_ - .5
                wv = math.sin(u * 5 + t * 2 + (k or idle) * 6.28 * 0.6) * 0.03 * t
                w = (torso_w + 0.06 + 0.16 * t) * 2 * u
                verts.append(tuple(b.P(w, sh_y - 0.13 - 0.06 * t - abs(wv) - lean_rad * 0.1, z_top - t * 0.85)))
        for j in range(nz_):
            for i in range(nx_):
                a = j * (nx_ + 1) + i
                faces.append((a, a + 1, a + nx_ + 2, a + nx_ + 1))
        o = geo.mesh_from(verts, faces, cm, 'cape', smooth=True)
        o.modifiers.new('sol', 'SOLIDIFY').thickness = 0.02
    if spec.get('pack'):
        b.box((0, sh_y - 0.2, sh_z - 0.22), (0.3, 0.14, 0.38), MC('pack', spec['pack'], rough=0.85, cloth=True), bevel=0.04)
        b.ellipsoid((0, sh_y - 0.2, sh_z - 0.02), (0.15, 0.09, 0.07), MC('roll', '#c9a86a', cloth=True))
    # itens na mão direita
    item = spec.get('item')
    if item and 1 in hands:
        hd = hands[1]
        _hold(b, item, hd, spec)
    return hands


def _hold(b, item, hd, spec):
    wood = MC('wood_item', '#7a4a26', rough=0.8)
    iron = MC('iron_item', '#8a8ea4', metal=True)
    if item == 'staff':
        b.line((hd[0], hd[1], hd[2] - 0.75), (hd[0], hd[1] - 0.05, hd[2] + 0.65), 0.028, wood, sides=6)
        b.ellipsoid((hd[0], hd[1] - 0.05, hd[2] + 0.7), (0.06, 0.06, 0.06), MC('orb', '#7ad0ff', rough=0.3))
    elif item == 'spear':
        b.line((hd[0], hd[1], hd[2] - 0.8), (hd[0], hd[1], hd[2] + 0.95), 0.022, wood, sides=6)
        b.cone((hd[0], hd[1], hd[2] + 0.95), 0.05, 0.0, 0.22, iron, sides=6)
    elif item == 'hammer':
        b.line((hd[0], hd[1], hd[2] - 0.05), (hd[0], hd[1] + 0.05, hd[2] + 0.42), 0.03, wood, sides=6)
        b.box((hd[0], hd[1] + 0.05, hd[2] + 0.46), (0.11, 0.11, 0.2), iron, bevel=0.01)
    elif item == 'basket':
        b.cone((hd[0], hd[1] + 0.05, hd[2] - 0.12), 0.13, 0.17, 0.16, MC('wicker', '#b88a48', rough=0.95), sides=12)
    elif item == 'lantern':
        b.line((hd[0], hd[1], hd[2]), (hd[0], hd[1], hd[2] - 0.1), 0.008, iron, sides=4)
        b.box((hd[0], hd[1], hd[2] - 0.2), (0.09, 0.09, 0.13), MC('glass', '#ffcc60', rough=0.4), bevel=0.01)
    elif item == 'book':
        b.box((hd[0] + 0.02, hd[1] + 0.06, hd[2] + 0.04), (0.16, 0.05, 0.21), MC('bookc', '#7a2a2a', cloth=True), bevel=0.01)
    elif item == 'bow':
        b.line((hd[0], hd[1], hd[2] - 0.4), (hd[0], hd[1] + 0.12, hd[2]), 0.018, wood, sides=5)
        b.line((hd[0], hd[1] + 0.12, hd[2]), (hd[0], hd[1], hd[2] + 0.4), 0.018, wood, sides=5)
        b.line((hd[0], hd[1], hd[2] - 0.4), (hd[0], hd[1], hd[2] + 0.4), 0.006, MC('string', '#e8e0c8'), sides=3)
    elif item == 'flask':
        b.ellipsoid((hd[0], hd[1] + 0.03, hd[2] + 0.08), (0.07, 0.07, 0.08), MC('flaskc', '#5adf8a', rough=0.25))
        b.cone((hd[0], hd[1] + 0.03, hd[2] + 0.14), 0.03, 0.03, 0.08, MC('flaskn', '#d8d8e8', rough=0.3))
    elif item == 'scroll':
        b.cone((hd[0], hd[1] + 0.04, hd[2] + 0.02), 0.035, 0.035, 0.24, MC('scrollc', '#eddcaa', cloth=True), sides=10)
    elif item == 'pitchfork':
        b.line((hd[0], hd[1], hd[2] - 0.7), (hd[0], hd[1], hd[2] + 0.8), 0.022, wood, sides=6)
        for dx in (-0.06, 0, 0.06):
            b.line((hd[0] + dx, hd[1], hd[2] + 0.8), (hd[0] + dx, hd[1], hd[2] + 1.02), 0.01, iron, sides=4)
        b.line((hd[0] - 0.06, hd[1], hd[2] + 0.8), (hd[0] + 0.06, hd[1], hd[2] + 0.8), 0.012, iron, sides=4)


# ---------------------------------------------------------------- quadrúpedes
def quadruped(b, sp, phase=None, idle=0.0):
    """Animal de 4 patas (cervo, raposa, lebre, cabra, camelo). sp: dict de forma/cores."""
    fur = MC('fur', sp['fur'], rough=0.95)
    fur2 = MC('fur2', sp.get('belly', sp['fur']), rough=0.95)
    dark = MC('adark', sp.get('dark', '#241812'), rough=0.9)
    hoof = MC('hoof', sp.get('hoof', '#2a2020'), rough=0.6)
    L, Hh = sp['length'], sp['height']            # comprimento do corpo e altura do garrote
    bh = sp.get('body_h', .28)
    leg_up, leg_lo = sp.get('leg1', .32), sp.get('leg2', .30)
    bob = 0.0
    sw = [0, 0, 0, 0]
    bend = [0, 0, 0, 0]
    if phase is not None:
        s = math.sin(2 * math.pi * phase)
        # diagonais em oposição: FL + RR / FR + RL
        sw = [26 * s, -26 * s, -26 * s, 26 * s]
        bend = [max(0, -math.sin(2 * math.pi * phase + .6)) * 40 + 4, max(0, math.sin(2 * math.pi * phase + .6)) * 40 + 4, max(0, math.sin(2 * math.pi * phase + .6)) * 40 + 4, max(0, -math.sin(2 * math.pi * phase + .6)) * 40 + 4]
        bob = abs(math.cos(2 * math.pi * phase)) * 0.02
    else:
        bob = math.sin(2 * math.pi * idle) * 0.006
    zc = leg_up + leg_lo * .9 + bh * .4 + bob                  # centro do corpo
    b.ellipsoid((0, 0, zc), (bh * .95, L * .5, bh), fur)                     # tronco
    b.ellipsoid((0, L * .28, zc + .015), (bh * .95, L * .3, bh * 1.02), fur)   # peito
    b.ellipsoid((0, -L * .3, zc + .02), (bh * .98, L * .28, bh * 1.02), fur)   # anca
    b.ellipsoid((0, 0, zc - bh * .45), (bh * .7, L * .42, bh * .5), fur2)      # barriga
    if sp.get('hump'):
        for hx in sp['hump']:
            b.ellipsoid((0, hx, zc + bh * 1.0), (bh * .7, bh * .8, bh * .85), fur)
    # patas
    hips = [(bh * .55, L * .3), (-bh * .55, L * .3), (bh * .55, -L * .3), (-bh * .55, -L * .3)]
    for i, (hx, hy) in enumerate(hips):
        top = (hx, hy, zc - bh * .3)
        k, f = ik2(top, leg_up, leg_lo, sw[i], bend[i] * (1 if i < 2 else -0.6))
        b.capsule(top, k, sp.get('thick', .05) * 1.25, sp.get('thick', .05), fur)
        b.capsule(k, f, sp.get('thick', .05), sp.get('thick', .05) * .7, fur if sp.get('leg_fur', True) else dark)
        b.ellipsoid((f[0], f[1] + .015, max(f[2], .03)), (.04, .05, .035), hoof)
    # pescoço e cabeça
    nl = sp.get('neck', .35)
    na = math.radians(sp.get('neck_angle', 50))
    nb = (0, L * .42, zc + bh * .5)
    nt = (0, nb[1] + math.sin(na) * 0 + math.cos(na) * nl * .55, nb[2] + math.sin(na) * nl)
    hd_bob = math.sin(2 * math.pi * idle) * .02 if phase is None else math.sin(2 * math.pi * phase * 2) * .015
    b.capsule(nb, (nt[0], nt[1], nt[2] + hd_bob), bh * .65, bh * .42, fur)
    hs = sp.get('head', .13)
    hc = (0, nt[1] + hs * .55, nt[2] + hs * .25 + hd_bob)
    b.ellipsoid(hc, (hs * .75, hs * 1.05, hs * .8), fur)
    b.ellipsoid((0, hc[1] + hs * 1.0, hc[2] - hs * .22), (hs * .48, hs * .72, hs * .48), sp.get('snout_mat') and MC('snout', sp['snout_mat']) or fur2)
    b.ellipsoid((0, hc[1] + hs * 1.65, hc[2] - hs * .3), (.03, .025, .025), dark)          # nariz
    for sx in (-1, 1):
        b.ellipsoid((sx * hs * .68, hc[1] + hs * .4, hc[2] + hs * .2), (.014, .018, .022), dark)   # olhos
        e = sp.get('ear', (.06, .16))
        pa = (sx * hs * .55, hc[1] - hs * .25, hc[2] + hs * .6)
        pb = (sx * (hs * .55 + e[0] * (1.6 if sp.get('ear_out') else .7)), hc[1] - hs * .35, hc[2] + hs * .6 + e[1])
        b.capsule(pa, pb, e[0] * .5, e[0] * .18, fur)
    # chifres/galhada
    horn = sp.get('horns')
    if horn == 'antlers':
        am = MC('antler', '#c8b48a', rough=0.7)
        for sx in (-1, 1):
            base = (sx * hs * .5, hc[1] - hs * .1, hc[2] + hs * .75)
            p1 = (sx * (hs * .8), base[1] - .05, base[2] + .22)
            p2 = (sx * (hs * 1.4), p1[1] + .02, p1[2] + .2)
            b.line(base, p1, .014, am, sides=5)
            b.line(p1, p2, .012, am, sides=5, r2=.004)
            b.line((p1[0], p1[1], p1[2]), (p1[0] + sx * .07, p1[1] + .1, p1[2] + .12), .01, am, sides=4, r2=.004)
            b.line((p1[0] + sx * .04, p1[1] - .03, p1[2] + .1), (p2[0] + sx * .05, p2[1] - .08, p2[2] + .12), .01, am, sides=4, r2=.004)
    elif horn == 'goat':
        am = MC('horn', '#d8caa0', rough=0.6)
        for sx in (-1, 1):
            b.line((sx * hs * .45, hc[1] - hs * .1, hc[2] + hs * .7), (sx * hs * .8, hc[1] - hs * .55, hc[2] + hs * 1.5), .022, am, sides=6, r2=.006)
    # rabo
    tail = sp.get('tail', 'short')
    tc = (0, -L * .5, zc + bh * .3)
    if tail == 'bushy':
        b.ellipsoid((0, tc[1] - .16, tc[2] - .04 + (math.sin(2 * math.pi * (phase or idle)) * .03)), (.06, .2, .06), fur)
        b.ellipsoid((0, tc[1] - .3, tc[2] - .06), (.05, .08, .05), MC('tailtip', sp.get('tail_tip', '#f4ecdc'), rough=.95))
    elif tail == 'short':
        b.ellipsoid((0, tc[1] - .04, tc[2] + .02), (.035, .05, .035), sp.get('tail_mat') and MC('tailm', sp['tail_mat']) or fur2)
    elif tail == 'thin':
        b.line(tc, (0, tc[1] - .16, tc[2] - .1), .014, fur, sides=5, r2=.006)
    # patches de cor (manchas)
    for (px, py, pz, r) in sp.get('spots', ()):
        b.ellipsoid((px, py * L * .5, zc + pz * bh), (r, r * 1.2, r * .5), fur2)
