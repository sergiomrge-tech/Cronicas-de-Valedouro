"""VK — materiais procedurais de nós (Cycles). Coordenadas de objeto = mundo (malhas construídas com transform aplicado)."""
import bpy


def hexrgb(h):
    h = h.lstrip('#')
    r, g, b = (int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
    # sRGB -> linear
    f = lambda c: c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    return (f(r), f(g), f(b), 1.0)


class N:
    """Construtor de árvores de nós com atalhos."""

    def __init__(self, name):
        self.mat = bpy.data.materials.new(name)
        self.mat.use_nodes = True
        self.t = self.mat.node_tree
        for n in list(self.t.nodes):
            self.t.nodes.remove(n)
        self.out = self.t.nodes.new('ShaderNodeOutputMaterial')
        self.x = -200

    def node(self, kind, **kw):
        n = self.t.nodes.new(kind)
        for k, v in kw.items():
            if k.startswith('in_'):
                n.inputs[k[3:]].default_value = v
            else:
                setattr(n, k, v)
        return n

    def _src(self, a, out):
        if hasattr(a, 'outputs'):
            if a.bl_idname == 'ShaderNodeMix' and out == 0 and a.data_type == 'RGBA':
                return a.outputs[2]
            return a.outputs[out]
        return a            # já é um socket

    def link(self, a, out, b, inp):
        self.t.links.new(self._src(a, out), b.inputs[inp])

    def coord(self):
        return self.node('ShaderNodeTexCoord')

    def mapping(self, vec_from, scale=(1, 1, 1), rot=(0, 0, 0), loc=(0, 0, 0)):
        m = self.node('ShaderNodeMapping')
        m.inputs['Scale'].default_value = scale
        m.inputs['Rotation'].default_value = rot
        m.inputs['Location'].default_value = loc
        self.link(vec_from, 0, m, 'Vector')
        return m

    def ramp(self, fac_from, stops, interp='LINEAR'):
        r = self.node('ShaderNodeValToRGB')
        r.color_ramp.interpolation = interp
        el = r.color_ramp.elements
        while len(el) < len(stops):
            el.new(0.5)
        for e, (pos, col) in zip(el, stops):
            e.position = pos
            e.color = hexrgb(col) if isinstance(col, str) else col
        self.link(fac_from, 0, r, 'Fac')
        return r

    def mix(self, a, b, fac, blend='MIX'):
        m = self.node('ShaderNodeMix', data_type='RGBA', blend_type=blend)
        self.link(fac if not isinstance(fac, (int, float)) else self._val(fac), 0, m, 0)
        self.link(a, 0, m, 6)
        self.link(b, 0, m, 7)
        return m

    def _val(self, v):
        n = self.node('ShaderNodeValue')
        n.outputs[0].default_value = v
        return n

    def math(self, op, a, b=None, clamp=False):
        m = self.node('ShaderNodeMath', operation=op, use_clamp=clamp)
        for i, x in enumerate((a, b)):
            if x is None:
                continue
            if isinstance(x, (int, float)):
                m.inputs[i].default_value = x
            else:
                self.link(x, 0, m, i)
        return m

    def finish(self, color_from, rough=0.85, spec=0.25, bump_from=None, bump_strength=0.6, emission=None, emission_strength=0.0, metallic=0.0):
        bsdf = self.node('ShaderNodeBsdfPrincipled')
        bsdf.inputs['Roughness'].default_value = rough
        bsdf.inputs['Metallic'].default_value = metallic
        if 'Specular IOR Level' in bsdf.inputs:
            bsdf.inputs['Specular IOR Level'].default_value = spec
        self.link(color_from, 0, bsdf, 'Base Color')
        if bump_from is not None:
            b = self.node('ShaderNodeBump')
            b.inputs['Strength'].default_value = bump_strength
            b.inputs['Distance'].default_value = 0.05
            self.link(bump_from, 0, b, 'Height')
            self.link(b, 0, bsdf, 'Normal')
        if emission is not None:
            self.link(emission, 0, bsdf, 'Emission Color')
            bsdf.inputs['Emission Strength'].default_value = emission_strength
        self.link(bsdf, 0, self.out, 'Surface')
        return self.mat

    def bevel(self, radius=0.03, samples=4):
        b = self.node('ShaderNodeBevel')
        b.inputs['Radius'].default_value = radius
        b.samples = samples
        return b


def _obj_coord(n, scale=1.0):
    c = n.coord()
    m = n.mapping(c.outputs['Object'], (scale, scale, scale))
    return c, m


def _edge_wear(n, base_col_node, geom_normal=True, amount=0.55, light='#f4dfb0'):
    """Realce de arestas via Bevel: (bevel normal . normal) -> mais claro nas quinas."""
    geo = n.node('ShaderNodeNewGeometry')
    bev = n.bevel(0.035, 4)
    dot = n.node('ShaderNodeVectorMath', operation='DOT_PRODUCT')
    n.link(bev, 0, dot, 0)
    n.link(geo, 'Normal', dot, 1)
    inv = n.math('SUBTRACT', 1.0, dot)
    edge = n.math('MULTIPLY', inv, 18.0, clamp=True)
    col = n.node('ShaderNodeMix', data_type='RGBA', blend_type='MIX')
    n.link(edge, 0, col, 0)
    n.link(base_col_node, 0, col, 6)
    lc = n.node('ShaderNodeRGB')
    lc.outputs[0].default_value = hexrgb(light)
    n.link(lc, 0, col, 7)
    col.inputs[0].default_value = 0.0
    fac = n.math('MULTIPLY', edge, amount, clamp=True)
    n.link(fac, 0, col, 0)
    return col, bev


def masonry(name='masonry', stones=('#5a4a46', '#8c7a68', '#b49a7c', '#d8bf98'), mortar='#2e2624', scale=1.0, block=(0.75, 0.42), moss=0.0, moss_col=('#1f4a1c', '#4f8a2a'), wear=0.6, rough=0.9):
    """Alvenaria em fiadas. Duas projeções (XZ e YZ) misturadas pela normal para servir as faces visíveis."""
    n = N(name)
    c, m = _obj_coord(n)
    geo = n.node('ShaderNodeNewGeometry')
    sep = n.node('ShaderNodeSeparateXYZ')
    n.link(geo, 'Normal', sep, 0)
    ax = n.math('ABSOLUTE', sep.outputs[0])
    ay = n.math('ABSOLUTE', sep.outputs[1])
    az = n.math('ABSOLUTE', sep.outputs[2])
    side = n.math('GREATER_THAN', ax, ay)           # 1 => face X (usa Y,Z); 0 => face Y (usa X,Z)
    top = n.math('GREATER_THAN', az, 0.7)
    scale_rows = []
    bricks = []
    for proj in ('yz', 'xz', 'xy'):
        sp = n.node('ShaderNodeSeparateXYZ')
        n.link(m, 0, sp, 0)
        cb = n.node('ShaderNodeCombineXYZ')
        a, b = {'yz': (1, 2), 'xz': (0, 2), 'xy': (0, 1)}[proj]
        n.link(sp, a, cb, 0)
        n.link(sp, b, cb, 1)
        br = n.node('ShaderNodeTexBrick', offset=0.5, offset_frequency=2, squash=1.0)
        br.inputs['Scale'].default_value = 1.0
        br.inputs['Mortar Size'].default_value = 0.055
        br.inputs['Mortar Smooth'].default_value = 0.0
        br.inputs['Bias'].default_value = 0.0
        br.inputs['Brick Width'].default_value = block[0]
        br.inputs['Row Height'].default_value = block[1]
        br.inputs['Color1'].default_value = hexrgb(stones[1])
        br.inputs['Color2'].default_value = hexrgb(stones[3])
        br.inputs['Mortar'].default_value = hexrgb(mortar)
        n.link(cb, 0, br, 'Vector')
        bricks.append(br)
    # cor: mistura por projeção
    def pick(port):
        mx1 = n.node('ShaderNodeMix', data_type='RGBA')
        n.link(side, 0, mx1, 0)
        n.link(bricks[1], port, mx1, 6)     # XZ
        n.link(bricks[0], port, mx1, 7)     # YZ
        mx2 = n.node('ShaderNodeMix', data_type='RGBA')
        n.link(top, 0, mx2, 0)
        n.link(mx1, 2, mx2, 6)
        n.link(bricks[2], port, mx2, 7)
        return mx2
    col = pick('Color')
    fac = pick('Fac')
    # variação por pedra: ruído de baixa freq. escurece/clareia
    nz = n.node('ShaderNodeTexNoise')
    nz.inputs['Scale'].default_value = 2.2
    nz.inputs['Detail'].default_value = 6.0
    n.link(m, 0, nz, 'Vector')
    nz2 = n.node('ShaderNodeTexNoise')
    nz2.inputs['Scale'].default_value = 14.0
    nz2.inputs['Detail'].default_value = 3.0
    n.link(m, 0, nz2, 'Vector')
    ramp = n.ramp(nz, [(0.3, stones[0]), (0.5, stones[1]), (0.66, stones[2]), (0.8, stones[3])])
    base = n.mix(ramp, col, 0.78, blend='MIX')
    # sombreado por fiada: base de cada pedra escura, topo claro (lê como blocos com volume)
    sepz = n.node('ShaderNodeSeparateXYZ'); n.link(m, 0, sepz, 0)
    fr = n.math('FRACT', n.math('DIVIDE', sepz.outputs[2], block[1]))
    rowshade = n.ramp(fr, [(0.0, '#5a5a5a'), (0.14, '#c8c8c8'), (0.86, '#e6e6e6'), (1.0, '#ffffff')])
    lit = n.node('ShaderNodeMix', data_type='RGBA', blend_type='MULTIPLY')
    lit.inputs[0].default_value = 0.85
    n.link(base, 0, lit, 6); n.link(rowshade, 0, lit, 7)
    base = lit
    # rachaduras: voronoi distância à aresta
    vor = n.node('ShaderNodeTexVoronoi', feature='DISTANCE_TO_EDGE')
    vor.inputs['Scale'].default_value = 5.0
    n.link(m, 0, vor, 'Vector')
    crack = n.math('LESS_THAN', vor.outputs['Distance'], 0.028)
    cr2 = n.math('MULTIPLY', crack, n.math('GREATER_THAN', nz2, 0.52), clamp=True)
    dark = n.node('ShaderNodeRGB'); dark.outputs[0].default_value = hexrgb(mortar)
    withcrack = n.mix(base, dark, n.math('MULTIPLY', cr2, 0.85))
    # argamassa forte
    mort = n.math('SUBTRACT', 1.0, fac)
    colm = n.mix(withcrack, dark, n.math('MULTIPLY', mort, 1.0, clamp=True))
    # desgaste de aresta
    edged, bev = _edge_wear(n, colm, amount=wear, light=stones[3])
    final = edged
    if moss > 0:
        gnormal = n.node('ShaderNodeNewGeometry')
        sep2 = n.node('ShaderNodeSeparateXYZ')
        n.link(gnormal, 'Normal', sep2, 0)
        up = n.math('MULTIPLY', n.math('ADD', sep2.outputs[2], 0.15), 1.2, clamp=True)
        low = n.math('SUBTRACT', 1.0, n.math('MULTIPLY', n.node('ShaderNodeSeparateXYZ').outputs[0], 0.0))
        mn = n.node('ShaderNodeTexNoise')
        mn.inputs['Scale'].default_value = 5.0
        mn.inputs['Detail'].default_value = 5.0
        n.link(m, 0, mn, 'Vector')
        sepp = n.node('ShaderNodeSeparateXYZ')
        n.link(c, 'Object', sepp, 0)
        lowz = n.math('SUBTRACT', 1.0, n.math('MULTIPLY', sepp.outputs[2], 0.35, clamp=True))   # mais musgo perto do chão
        mm = n.math('MULTIPLY', n.math('MULTIPLY', n.math('SUBTRACT', mn.outputs['Fac'], 0.42), 4.0, clamp=True), n.math('MULTIPLY', n.math('ADD', up, lowz), moss, clamp=True), clamp=True)
        mr = n.ramp(nz2, [(0.3, moss_col[0]), (0.7, moss_col[1])])
        final = n.mix(edged, mr, mm)
    return n.finish(final, rough=rough, spec=0.2, bump_from=fac, bump_strength=1.1)


def planks(name='planks', cols=('#4a2a18', '#7a4a28', '#a8743c', '#c8964e'), along='x', width=0.32, length=2.4, gap='#1c0f0a', scale=1.0, wear=0.6, rough=0.8, aged=0.5):
    """Tábuas: junta entre tábuas, veio longitudinal, desgaste nas quinas e variação por peça."""
    n = N(name)
    c, m = _obj_coord(n)
    geo = n.node('ShaderNodeNewGeometry')
    sep = n.node('ShaderNodeSeparateXYZ')
    n.link(geo, 'Normal', sep, 0)
    ax = n.math('ABSOLUTE', sep.outputs[0])
    ay = n.math('ABSOLUTE', sep.outputs[1])
    az = n.math('ABSOLUTE', sep.outputs[2])
    side = n.math('GREATER_THAN', ax, ay)
    top = n.math('GREATER_THAN', az, 0.7)
    sp = n.node('ShaderNodeSeparateXYZ')
    n.link(m, 0, sp, 0)

    def brick(a, b, along_first):
        cb = n.node('ShaderNodeCombineXYZ')
        if along_first:
            n.link(sp, a, cb, 0)
            n.link(sp, b, cb, 1)
        else:
            n.link(sp, b, cb, 0)
            n.link(sp, a, cb, 1)
        br = n.node('ShaderNodeTexBrick', offset=0.5, offset_frequency=2)
        br.inputs['Scale'].default_value = 1.0
        br.inputs['Mortar Size'].default_value = 0.02
        br.inputs['Brick Width'].default_value = length
        br.inputs['Row Height'].default_value = width
        br.inputs['Color1'].default_value = hexrgb(cols[0])
        br.inputs['Color2'].default_value = hexrgb(cols[3])
        br.inputs['Mortar'].default_value = hexrgb(gap)
        n.link(cb, 0, br, 'Vector')
        return br
    # tábuas horizontais nas faces verticais (comprimento ao longo do eixo horizontal); no topo, ao longo de 'along'
    bx = brick(1, 2, True)      # face X: u=y, v=z
    by = brick(0, 2, True)      # face Y: u=x, v=z
    bt = brick(0, 1, along == 'x')
    m1 = n.node('ShaderNodeMix', data_type='RGBA'); n.link(side, 0, m1, 0); n.link(by, 'Color', m1, 6); n.link(bx, 'Color', m1, 7)
    f1 = n.node('ShaderNodeMix', data_type='RGBA'); n.link(side, 0, f1, 0); n.link(by, 'Fac', f1, 6); n.link(bx, 'Fac', f1, 7)
    m2 = n.node('ShaderNodeMix', data_type='RGBA'); n.link(top, 0, m2, 0); n.link(m1, 2, m2, 6); n.link(bt, 'Color', m2, 7)
    f2 = n.node('ShaderNodeMix', data_type='RGBA'); n.link(top, 0, f2, 0); n.link(f1, 2, f2, 6); n.link(bt, 'Fac', f2, 7)
    # veio: ruído esticado
    gsc = n.mapping(c.outputs['Object'], (2.5, 24.0, 2.5) if along == 'x' else (24.0, 2.5, 2.5))
    grain = n.node('ShaderNodeTexNoise')
    grain.inputs['Scale'].default_value = 1.0
    grain.inputs['Detail'].default_value = 4.0
    n.link(gsc, 0, grain, 'Vector')
    gr = n.ramp(grain, [(0.35, cols[0]), (0.5, cols[1]), (0.62, cols[2]), (0.8, cols[3])])
    base = n.mix(gr, m2, 0.62)
    # envelhecimento: manchas escuras/claras de baixa frequência
    ag = n.node('ShaderNodeTexNoise'); ag.inputs['Scale'].default_value = 3.0; ag.inputs['Detail'].default_value = 5.0
    n.link(m, 0, ag, 'Vector')
    dk = n.node('ShaderNodeRGB'); dk.outputs[0].default_value = hexrgb(cols[0])
    aged_col = n.mix(base, dk, n.math('MULTIPLY', n.math('SUBTRACT', ag.outputs['Fac'], 0.45), aged * 2.0, clamp=True))
    gapm = n.math('SUBTRACT', 1.0, f2)
    dg = n.node('ShaderNodeRGB'); dg.outputs[0].default_value = hexrgb(gap)
    withgap = n.mix(aged_col, dg, n.math('MULTIPLY', gapm, 0.95, clamp=True))
    oi = n.node('ShaderNodeObjectInfo')
    tint = n.ramp(oi.outputs['Random'], [(0.0, '#b8b8b8'), (0.5, '#e8e8e8'), (1.0, '#ffffff')])
    tinted = n.node('ShaderNodeMix', data_type='RGBA', blend_type='MULTIPLY'); tinted.inputs[0].default_value = 1.0
    n.link(withgap, 0, tinted, 6); n.link(tint, 0, tinted, 7)
    edged, bev = _edge_wear(n, tinted, amount=wear, light=cols[3])
    return n.finish(edged, rough=rough, spec=0.18, bump_from=grain, bump_strength=0.35)


def shingles(name='shingles', cols=('#3a1418', '#7a2a22', '#b04a2e', '#e07a4a'), w=0.34, h=0.2, mortar='#241010', rough=0.7):
    """Telhas em fileiras escalonadas em coordenadas UV (u = ao longo do beiral, v = subida da água), com sombra sob cada fileira."""
    n = N(name)
    uv = n.node('ShaderNodeTexCoord')
    br = n.node('ShaderNodeTexBrick', offset=0.5, offset_frequency=2)
    br.inputs['Scale'].default_value = 1.0
    br.inputs['Mortar Size'].default_value = 0.075
    br.inputs['Mortar Smooth'].default_value = 0.0
    br.inputs['Brick Width'].default_value = w
    br.inputs['Row Height'].default_value = h
    br.inputs['Color1'].default_value = hexrgb(cols[0])
    br.inputs['Color2'].default_value = hexrgb(cols[3])
    br.inputs['Mortar'].default_value = hexrgb(mortar)
    n.link(uv, 'UV', br, 'Vector')
    sp = n.node('ShaderNodeSeparateXYZ'); n.link(uv, 'UV', sp, 0)
    fr = n.math('FRACT', n.math('DIVIDE', sp.outputs[1], h))
    rowshade = n.ramp(fr, [(0.0, '#303030'), (0.3, '#b0b0b0'), (0.8, '#eaeaea'), (1.0, '#ffffff')])
    fru = n.math('FRACT', n.math('DIVIDE', n.math('ADD', sp.outputs[0], n.math('MULTIPLY', n.math('FLOOR', n.math('DIVIDE', sp.outputs[1], h)), w * 0.5)), w))
    colshade = n.ramp(fru, [(0.0, '#8a8a8a'), (0.12, '#f0f0f0'), (0.9, '#ffffff'), (1.0, '#a0a0a0')])
    c, m = _obj_coord(n)
    nz = n.node('ShaderNodeTexNoise'); nz.inputs['Scale'].default_value = 3.0; nz.inputs['Detail'].default_value = 4.0
    n.link(m, 0, nz, 'Vector')
    tone = n.ramp(nz, [(0.3, cols[0]), (0.5, cols[1]), (0.65, cols[2]), (0.85, cols[3])])
    base = n.mix(tone, br, 0.7)
    dk = n.node('ShaderNodeRGB'); dk.outputs[0].default_value = hexrgb(mortar)
    withm = n.mix(base, dk, n.math('MULTIPLY', n.math('SUBTRACT', 1.0, br.outputs['Fac']), 0.95, clamp=True))
    lit = n.node('ShaderNodeMix', data_type='RGBA', blend_type='MULTIPLY'); lit.inputs[0].default_value = 0.9
    n.link(withm, 0, lit, 6); n.link(rowshade, 0, lit, 7)
    lit2 = n.node('ShaderNodeMix', data_type='RGBA', blend_type='MULTIPLY'); lit2.inputs[0].default_value = 0.6
    n.link(lit, 0, lit2, 6); n.link(colshade, 0, lit2, 7)
    edged, bev = _edge_wear(n, lit2, amount=0.35, light=cols[3])
    return n.finish(edged, rough=rough, spec=0.3, bump_from=nz, bump_strength=0.4)


def rock(name='rock', cols=('#241c2a', '#4a3c46', '#7a6458', '#a8927a', '#d8c2a2'), strata=(4.0, 0.35), scale=1.0, moss=0.0, moss_col=('#1c4a20', '#4f8f2c'), snow=0.0, rough=0.95, tint_top=None):
    """Rocha: estratos por altura + ruído, facetas claras nas arestas e musgo/neve em faces voltadas para cima."""
    n = N(name)
    c, m = _obj_coord(n)
    sepp = n.node('ShaderNodeSeparateXYZ')
    n.link(c, 'Object', sepp, 0)
    nz = n.node('ShaderNodeTexNoise'); nz.inputs['Scale'].default_value = 2.4 * scale; nz.inputs['Detail'].default_value = 8.0
    n.link(m, 0, nz, 'Vector')
    nz2 = n.node('ShaderNodeTexNoise'); nz2.inputs['Scale'].default_value = 11.0 * scale; nz2.inputs['Detail'].default_value = 4.0
    n.link(m, 0, nz2, 'Vector')
    # estratos: seno em z com perturbação
    zz = n.math('ADD', sepp.outputs[2], n.math('MULTIPLY', nz.outputs['Fac'], strata[1]))
    wave = n.math('SINE', n.math('MULTIPLY', zz, strata[0] * 3.14159))
    band = n.math('ADD', n.math('MULTIPLY', wave, 0.5), 0.5)
    mix_raw = n.math('ADD', n.math('MULTIPLY', band, 0.55), n.math('MULTIPLY', nz2.outputs['Fac'], 0.45))
    mix_f = n.math('ADD', n.math('MULTIPLY', n.math('SUBTRACT', mix_raw, 0.5), 2.3), 0.5, clamp=True)
    base = n.ramp(mix_f, [(0.15, cols[0]), (0.35, cols[1]), (0.55, cols[2]), (0.75, cols[3]), (0.92, cols[4])])
    # fissuras
    vor = n.node('ShaderNodeTexVoronoi', feature='DISTANCE_TO_EDGE'); vor.inputs['Scale'].default_value = 3.6 * scale
    n.link(m, 0, vor, 'Vector')
    crack = n.math('LESS_THAN', vor.outputs['Distance'], 0.035)
    dk = n.node('ShaderNodeRGB'); dk.outputs[0].default_value = hexrgb(cols[0])
    withc = n.mix(base, dk, n.math('MULTIPLY', crack, 0.8))
    edged, bev = _edge_wear(n, withc, amount=0.5, light=cols[4])
    final = edged
    geo = n.node('ShaderNodeNewGeometry')
    sn = n.node('ShaderNodeSeparateXYZ')
    n.link(geo, 'Normal', sn, 0)
    up = n.math('MULTIPLY', n.math('SUBTRACT', sn.outputs[2], 0.35), 2.0, clamp=True)
    if moss > 0:
        mn = n.node('ShaderNodeTexNoise'); mn.inputs['Scale'].default_value = 4.5; mn.inputs['Detail'].default_value = 5.0
        n.link(m, 0, mn, 'Vector')
        mmask = n.math('MULTIPLY', n.math('MULTIPLY', n.math('SUBTRACT', mn.outputs['Fac'], 0.38), 3.5, clamp=True), n.math('MULTIPLY', up, moss, clamp=True), clamp=True)
        mr = n.ramp(nz2, [(0.25, moss_col[0]), (0.7, moss_col[1])])
        final = n.mix(final, mr, mmask)
    if snow > 0:
        sn_c = n.node('ShaderNodeRGB'); sn_c.outputs[0].default_value = hexrgb('#eef8ff')
        sn_n = n.node('ShaderNodeTexNoise'); sn_n.inputs['Scale'].default_value = 6.0; sn_n.inputs['Detail'].default_value = 5.0
        n.link(m, 0, sn_n, 'Vector')
        sm = n.math('MULTIPLY', n.math('MULTIPLY', n.math('ADD', sn_n.outputs['Fac'], 0.45), up, clamp=True), snow * 1.6, clamp=True)
        sm2 = n.math('GREATER_THAN', sm, 0.5)
        shade = n.ramp(nz2, [(0.3, '#b4cdea'), (0.6, '#dbeaf8'), (0.9, '#ffffff')])
        final = n.mix(final, shade, sm2)
    return n.finish(final, rough=rough, spec=0.12, bump_from=nz2, bump_strength=0.9)


def flat(name, color, rough=0.8, spec=0.3, metallic=0.0, emission=None, emission_strength=0.0, bevel_wear=0.35):
    n = N(name)
    col = n.node('ShaderNodeRGB'); col.outputs[0].default_value = hexrgb(color) if isinstance(color, str) else color
    c, m = _obj_coord(n)
    nz = n.node('ShaderNodeTexNoise'); nz.inputs['Scale'].default_value = 9.0; nz.inputs['Detail'].default_value = 4.0
    n.link(m, 0, nz, 'Vector')
    tinted = n.mix(col, n.node('ShaderNodeRGB'), 0.0)
    tone = n.ramp(nz, [(0.35, _scale_col(color, 0.78)), (0.7, color if isinstance(color, str) else color), (0.9, _scale_col(color, 1.18))])
    final = tone
    if bevel_wear > 0:
        final, _ = _edge_wear(n, tone, amount=bevel_wear, light=_hexlight(color))
    em = None
    if emission:
        em = n.node('ShaderNodeRGB'); em.outputs[0].default_value = hexrgb(emission)
    return n.finish(final, rough=rough, spec=spec, metallic=metallic, bump_from=nz, bump_strength=0.25, emission=em, emission_strength=emission_strength)


def _scale_col(c, k):
    if isinstance(c, str):
        h = c.lstrip('#')
        r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
        r, g, b = (max(0, min(255, int(v * k))) for v in (r, g, b))
        return '#%02x%02x%02x' % (r, g, b)
    return (c[0] * k, c[1] * k, c[2] * k, 1.0)


def _hexlight(c):
    return _scale_col(c, 1.5) if isinstance(c, str) else '#ffffff'


def cloth(name='cloth', color='#b8283a', pattern=None, rough=0.95):
    n = N(name)
    c, m = _obj_coord(n)
    w = n.node('ShaderNodeTexWave', wave_type='BANDS', wave_profile='SIN'); w.inputs['Scale'].default_value = 9.0; w.inputs['Distortion'].default_value = 2.5
    n.link(m, 0, w, 'Vector')
    tone = n.ramp(w, [(0.3, _scale_col(color, 0.84)), (0.6, color), (0.9, _scale_col(color, 1.12))])
    return n.finish(tone, rough=rough, spec=0.1, bump_from=w, bump_strength=0.15)


def foliage(name='foliage', cols=('#04301a', '#0a5a22', '#1e8a1c', '#5cb420', '#c6e83a'), rough=0.85):
    """Copa: cor por folha (Object Info Random) + gradiente de altura + realce nas faces para a luz."""
    n = N(name)
    oi = n.node('ShaderNodeObjectInfo')
    c, m = _obj_coord(n)
    sepp = n.node('ShaderNodeSeparateXYZ'); n.link(c, 'Object', sepp, 0)
    hz = n.math('ADD', n.math('ADD', n.math('MULTIPLY', sepp.outputs[2], 0.16), n.math('MULTIPLY', oi.outputs['Random'], 0.45)), 0.22)
    tone = n.ramp(hz, [(0.15, cols[0]), (0.35, cols[1]), (0.55, cols[2]), (0.75, cols[3]), (0.95, cols[4])])
    nz = n.node('ShaderNodeTexNoise'); nz.inputs['Scale'].default_value = 20.0
    n.link(m, 0, nz, 'Vector')
    return n.finish(tone, rough=rough, spec=0.15, bump_from=nz, bump_strength=0.3)


def water(name='water', deep='#0a3f9a', light='#54c8f2', foam='#eaffff'):
    n = N(name)
    c, m = _obj_coord(n)
    nz = n.node('ShaderNodeTexNoise'); nz.inputs['Scale'].default_value = 3.0; nz.inputs['Detail'].default_value = 5.0
    n.link(m, 0, nz, 'Vector')
    tone = n.ramp(nz, [(0.3, deep), (0.55, '#2a80d8'), (0.75, light), (0.92, foam)])
    return n.finish(tone, rough=0.15, spec=0.6, bump_from=nz, bump_strength=0.6)


def emissive(name, color, strength=6.0):
    n = N(name)
    col = n.node('ShaderNodeRGB'); col.outputs[0].default_value = hexrgb(color)
    em = n.node('ShaderNodeEmission'); em.inputs['Strength'].default_value = strength
    n.link(col, 0, em, 'Color')
    n.link(em, 0, n.out, 'Surface')
    return n.mat


def ground(name, cols, scale=5.0, fine=26.0, rough=1.0, dots=None):
    """Terreno com manchas macro + granulação fina (relva, areia, neve, terra), sem quadriculado."""
    n = N(name)
    c, mp = _obj_coord(n)
    a = n.node('ShaderNodeTexNoise'); a.inputs['Scale'].default_value = scale; a.inputs['Detail'].default_value = 5.0
    b = n.node('ShaderNodeTexNoise'); b.inputs['Scale'].default_value = fine; b.inputs['Detail'].default_value = 2.0
    n.link(mp, 0, a, 'Vector'); n.link(mp, 0, b, 'Vector')
    mixf = n.math('ADD', n.math('MULTIPLY', a.outputs['Fac'], 0.72), n.math('MULTIPLY', b.outputs['Fac'], 0.28))
    tone = n.ramp(mixf, [(0.25 + i * (0.5 / max(1, len(cols) - 1)), col) for i, col in enumerate(cols)])
    final = tone
    if dots:
        v = n.node('ShaderNodeTexVoronoi'); v.inputs['Scale'].default_value = 16.0
        n.link(mp, 0, v, 'Vector')
        mask = n.math('LESS_THAN', v.outputs['Distance'], 0.11)
        dc = n.node('ShaderNodeRGB'); dc.outputs[0].default_value = hexrgb(dots)
        rnd = n.math('GREATER_THAN', b.outputs['Fac'], 0.56)
        final = n.mix(tone, dc, n.math('MULTIPLY', mask, rnd))
    return n.finish(final, rough=rough, spec=0.05, bump_from=b, bump_strength=0.5)


def waterfall(name='waterfall', phase=0.0, light='#e8fbff', mid='#5cc0f4', deep='#1a62c0', period=0.55):
    """Cortina d'água com fase periódica (loop perfeito): faixas que descem + veios verticais fixos."""
    n = N(name)
    c, mp = _obj_coord(n)
    sp = n.node('ShaderNodeSeparateXYZ'); n.link(mp, 0, sp, 0)
    bands = n.math('SINE', n.math('MULTIPLY', n.math('ADD', n.math('DIVIDE', sp.outputs[2], period), phase), 6.2831853))
    bands01 = n.math('ADD', n.math('MULTIPLY', bands, 0.5), 0.5)
    w = n.node('ShaderNodeTexNoise'); w.inputs['Scale'].default_value = 7.0; w.inputs['Detail'].default_value = 2.0
    cb = n.node('ShaderNodeCombineXYZ')
    n.link(sp, 0, cb, 0); n.link(sp, 1, cb, 1); cb.inputs[2].default_value = 0.0
    sc = n.node('ShaderNodeMapping'); sc.inputs['Scale'].default_value = (2.0, 1.4, 0.0)
    n.link(cb, 0, sc, 'Vector'); n.link(sc, 0, w, 'Vector')
    f = n.math('ADD', n.math('MULTIPLY', bands01, 0.5), n.math('MULTIPLY', w.outputs['Fac'], 0.55))
    tone = n.ramp(f, [(0.3, deep), (0.5, mid), (0.72, light), (0.9, '#ffffff')])
    em = n.node('ShaderNodeRGB'); em.outputs[0].default_value = hexrgb('#9adcff')
    return n.finish(tone, rough=0.2, spec=0.5, emission=em, emission_strength=0.45)


def striped_cloth(name, c1, c2, freq=5.0, axis=0, rough=0.95):
    n = N(name)
    c, mp = _obj_coord(n)
    sp = n.node('ShaderNodeSeparateXYZ'); n.link(mp, 0, sp, 0)
    bands = n.math('GREATER_THAN', n.math('FRACT', n.math('MULTIPLY', n.math('ADD', sp.outputs[0], sp.outputs[1]), freq)), 0.5)
    a = n.node('ShaderNodeRGB'); a.outputs[0].default_value = hexrgb(c1)
    b = n.node('ShaderNodeRGB'); b.outputs[0].default_value = hexrgb(c2)
    col = n.mix(a, b, bands)
    w = n.node('ShaderNodeTexWave', wave_type='BANDS', wave_profile='SIN'); w.inputs['Scale'].default_value = 8.0; w.inputs['Distortion'].default_value = 2.0
    n.link(mp, 0, w, 'Vector')
    shade = n.ramp(w, [(0.3, '#c8c8c8'), (0.7, '#ffffff')])
    lit = n.node('ShaderNodeMix', data_type='RGBA', blend_type='MULTIPLY'); lit.inputs[0].default_value = 0.5
    n.link(col, 0, lit, 6); n.link(shade, 0, lit, 7)
    return n.finish(lit, rough=rough, spec=0.08, bump_from=w, bump_strength=0.1)


def bark(name='bark', cols=('#1c0e0a', '#3e2418', '#6a4028', '#9a6a44'), birch=False, moss=0.0):
    """Casca: veios verticais fundos (ruído esticado em z) + fissuras; bétula = branca com marcas horizontais escuras."""
    n = N(name)
    c, mp = _obj_coord(n)
    st = n.mapping(c.outputs['Object'], (9.0, 9.0, 1.3))
    a = n.node('ShaderNodeTexNoise'); a.inputs['Scale'].default_value = 1.6; a.inputs['Detail'].default_value = 6.0
    n.link(st, 0, a, 'Vector')
    v = n.node('ShaderNodeTexVoronoi', feature='DISTANCE_TO_EDGE'); v.inputs['Scale'].default_value = 1.4
    n.link(st, 0, v, 'Vector')
    if not birch:
        f = n.math('ADD', n.math('MULTIPLY', a.outputs['Fac'], 0.8), n.math('MULTIPLY', v.outputs['Distance'], 0.9))
        tone = n.ramp(f, [(0.22, cols[0]), (0.42, cols[1]), (0.6, cols[2]), (0.8, cols[3])])
        final = tone
    else:
        hs = n.mapping(c.outputs['Object'], (2.0, 2.0, 16.0))
        b = n.node('ShaderNodeTexNoise'); b.inputs['Scale'].default_value = 1.0; b.inputs['Detail'].default_value = 3.0
        n.link(hs, 0, b, 'Vector')
        base = n.ramp(a, [(0.3, '#c8c4c0'), (0.6, '#eeeae4'), (0.85, '#ffffff')])
        dark = n.node('ShaderNodeRGB'); dark.outputs[0].default_value = hexrgb('#221a1c')
        marks = n.math('GREATER_THAN', b.outputs['Fac'], 0.66)
        final = n.mix(base, dark, marks)
    if moss > 0:
        mn = n.node('ShaderNodeTexNoise'); mn.inputs['Scale'].default_value = 3.0
        n.link(mp, 0, mn, 'Vector')
        mr = n.ramp(a, [(0.3, '#1a4a1c'), (0.7, '#5a9a2c')])
        final = n.mix(final, mr, n.math('MULTIPLY', n.math('GREATER_THAN', mn.outputs['Fac'], 0.58), moss))
    return n.finish(final, rough=0.95, spec=0.05, bump_from=v.outputs['Distance'], bump_strength=1.0)


def plank_piece(name, cols, grain_scale=(1.0, 14.0, 1.0)):
    """Uma tábua: cor por peça (Object Info Random) + veio longitudinal (ruído esticado em y local) + nós."""
    n = N(name)
    oi = n.node('ShaderNodeObjectInfo')
    c, mp = _obj_coord(n)
    st = n.mapping(c.outputs['Object'], (14.0, 1.6, 14.0))
    g = n.node('ShaderNodeTexNoise'); g.inputs['Scale'].default_value = 1.4; g.inputs['Detail'].default_value = 5.0
    n.link(st, 0, g, 'Vector')
    f = n.math('ADD', n.math('MULTIPLY', g.outputs['Fac'], 0.55), n.math('MULTIPLY', oi.outputs['Random'], 0.55))
    tone = n.ramp(f, [(0.2, cols[0]), (0.4, cols[1]), (0.6, cols[2]), (0.85, cols[3])])
    return n.finish(tone, rough=0.75, spec=0.18, bump_from=g, bump_strength=0.4)
