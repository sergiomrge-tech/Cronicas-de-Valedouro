"""Materiais e peças comuns do Lote 1 (Ato I — Berço de Valedouro): mesma família de pedra, madeira e azul real de Valedouro."""
import math
import random

import bpy
from vk import geo, mats, parts
from vk.parts import M

S = 30.0     # px de jogo por unidade

_MC = {}


def X(key, factory):
    m = _MC.get(key)
    try:
        if m is not None and m.name in bpy.data.materials:
            return m
    except ReferenceError:
        pass
    _MC[key] = factory()
    return _MC[key]


def m_roof_blue():
    return X('roof_blue', lambda: mats.shingles('roof_blue', ('#0c1a44', '#1a3a8a', '#2c62cc', '#78a4f0'), w=.26, h=.15))


def m_noble():
    return X('stone_noble', lambda: mats.masonry('stone_noble', ('#5c5664', '#948c9c', '#c8c0c8', '#f0eaee'), '#2e2a34', block=(.62, .34), moss=.08, wear=.5))


def m_gold():
    return M('gold')


def m_scorch():
    return X('scorch', lambda: mats.flat('scorch', '#3a2c24', rough=1.0, spec=0.0, bevel_wear=0.0))


def m_blood():
    return X('blood', lambda: mats.flat('blood', '#5a1414', rough=1.0, spec=0.05, bevel_wear=0.0))


def m_bone():
    return X('bone', lambda: mats.flat('bone', '#e6dcc0', rough=.85, spec=.1, bevel_wear=.1))


def m_eco():
    return X('eco', lambda: mats.emissive('eco', '#5ae6ff', 7.0))


def m_eco_dim():
    return X('eco_dim', lambda: mats.emissive('eco_dim', '#2aa0c8', 3.0))


def m_ore():
    return X('ore', lambda: mats.rock('ore', ('#1c1c28', '#3c3c52', '#60607c', '#8c8cae', '#c4c8e8'), strata=(3.0, .3)))


def m_dirt_dark():
    return X('dirt_dark', lambda: mats.ground('dirt_dark', ('#241610', '#3e281a', '#5c3c24', '#7a5634', '#9a7448'), scale=4.0))


def m_gravel():
    return X('gravel', lambda: mats.ground('gravel', ('#2a2420', '#4a4038', '#6c6054', '#8e8070', '#b4a48c'), scale=6.0, fine=34.0))


def m_straw():
    return X('straw', lambda: mats.flat('straw', '#d4a840', rough=1.0, spec=.05, bevel_wear=0.0))


def m_canvas():
    return X('canvas', lambda: mats.cloth('canvas', '#c8b48a'))


def m_sack():
    return X('sack', lambda: mats.cloth('sack', '#a88c5c'))


def m_parchment():
    return X('parchment', lambda: mats.flat('parchment', '#e8d8b0', rough=.9, spec=.05, bevel_wear=.1))


def m_ink():
    return X('ink', lambda: mats.flat('ink', '#2a2018', rough=.9, spec=.05, bevel_wear=0.0))


def m_red_rag():
    return X('red_rag', lambda: mats.cloth('red_rag', '#9a1c24'))


def crenels(x, y0, y1, z, mat, n, depth=.5, h=.42):
    step = (y1 - y0) / n
    for i in range(n):
        if i % 2 == 0:
            geo.box((x, y0 + (i + .5) * step, z + h / 2), (depth, step * .92, h), mat, bevel=0.03)


def crenels_x(y, x0, x1, z, mat, n, depth=.5, h=.42):
    step = (x1 - x0) / n
    for i in range(n):
        if i % 2 == 0:
            geo.box((x0 + (i + .5) * step, y, z + h / 2), (step * .92, depth, h), mat, bevel=0.03)


def ball(loc, r, mat, squash=1.0, smooth=True):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=r)
    o = bpy.context.object
    o.location = loc
    o.scale = (1, 1, squash)
    o.data.materials.append(mat)
    if smooth:
        for p in o.data.polygons:
            p.use_smooth = True
    return o


def torch(x, y, z, face=1):
    """Tocha em suporte de ferro: haste, cesto e chama emissiva."""
    geo.box((x - .06 * face, y, z), (.12, .06, .06), M('iron'), bevel=0.01)
    geo.cyl((x, y, z - .04), .05, .5, M('iron'), sides=6)
    geo.cyl((x, y, z + .42), .1, .1, M('iron'), sides=8, r2=.14)
    ball((x, y, z + .62), .13, M('fire'), squash=1.5)


def lantern(x, y, z):
    geo.cyl_between((x, y, z + .3), (x, y, z), .012, M('iron'), sides=4)
    geo.box((x, y, z - .1), (.16, .16, .22), M('glass'), bevel=0.02)
    geo.box((x, y, z + .03), (.2, .2, .04), M('iron'), bevel=0.01)


def banner(x, y, z_top, drop, width, color_mat=None, trim=True, torn=False, seed=0):
    """Estandarte pendente voltado para +x (pano com dobras, faixa dourada; rasgado opcional)."""
    mat = color_mat or M('cloth_blue')
    geo.box((x + .02, y, z_top + .04), (.06, width + .14, .08), M('wood_dark'), bevel=0.01)
    if torn:
        for k, dz in enumerate((drop, drop * .82, drop * .94)):
            yy = y - width / 2 + (k + .5) * width / 3
            parts.cloth_sheet((x, yy - width / 6, z_top), (x, yy + width / 6, z_top), (x + .02, yy - width / 6, z_top - dz), (x + .02, yy + width / 6, z_top - dz), mat, nu=4, nv=6, sag=.02, folds=.03, fold_n=3, phase=seed + k)
    else:
        parts.cloth_sheet((x, y - width / 2, z_top), (x, y + width / 2, z_top), (x + .03, y - width / 2, z_top - drop), (x + .03, y + width / 2, z_top - drop), mat, nu=8, nv=8, sag=.03, folds=.05, fold_n=3, phase=seed)
    if trim:
        geo.box((x + .05, y, z_top - drop * .3), (.03, width * .86, .09), m_gold(), bevel=0.005)
        geo.box((x + .05, y, z_top - drop * .55), (.03, .09, drop * .3), m_gold(), bevel=0.005)


def arch_frame(x, y, z, w, h, mat, depth=.3, glow=True, shutters=False):
    """Janela alta em arco simples: moldura de pedra, vidro emissivo e peitoril."""
    geo.box((x, y, z + h / 2), (depth, w + .3, h + .3), mat, bevel=0.04)
    geo.box((x + .04, y, z + h / 2), (depth * .6, w, h), M('hole'), bevel=0.0)
    if glow:
        geo.box((x + .1, y, z + h / 2), (.05, w - .06, h - .06), M('glass'), bevel=0.01)
    for k in (1, 2):
        geo.box((x + .13, y, z + h * k / 3), (.04, w - .06, .04), M('wood_dark'), bevel=0.005)
    geo.box((x + .13, y, z + h / 2), (.04, .04, h - .06), M('wood_dark'), bevel=0.005)
    geo.box((x + .18, y, z - .05), (depth + .1, w + .4, .08), mat, bevel=0.02)
    geo.cyl((x + .05, y, z + h + .0), (w + .3) / 2, depth * 0.9, mat, rot=(0, 90, 0), sides=12, r2=(w + .3) / 2)
    if shutters:
        for sgn in (-1, 1):
            geo.box((x + .2, y + sgn * (w / 2 + .14), z + h / 2), (.05, .24, h), M('wood'), bevel=0.01)


def steps(x0, y, width, n, rise=.16, run=.32, mat=None):
    """Escada voltada para +x: o degrau mais alto encosta na parede (x0), o mais baixo é o mais longo."""
    mat = mat or M('stone')
    for i in range(n):
        h = rise * (n - i)
        L = run * (i + 1)
        geo.box((x0 + L / 2, y, h / 2), (L, width, h), mat, bevel=0.02)
