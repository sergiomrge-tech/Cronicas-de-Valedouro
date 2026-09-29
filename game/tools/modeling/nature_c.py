"""Natureza / Overworld — variantes de deserto (arenito) e decalques de transição entre biomas."""
from mats import *
from registry import asset
import nature_b as nb


def _swap(fn, old, new):
    """Reexecuta um builder de ruína trocando o material de pedra por arenito."""
    def build(sc, f):
        g = fn.__globals__
        saved = {k: g[k] for k in old}
        try:
            for k in old:
                g[k] = new
            fn(sc, f)
        finally:
            g.update(saved)
    return build


SAND_MOSS = Mat(SANDSTONE.ramp, tex=tex_stone_blocks(3.2, .2, 11), ambient=.36, bump=(7, .7), name='sandstone_blocks')


@asset('nat_ruin_arch_sand', 'nature', 'ruins', (260, 282), (130, 248), seed=141, blocks=(14,), tags=('ruinas', 'arco', 'deserto'), footprint=30)
def ruin_arch_sand(sc, f):
    add_patch(sc, 'sand', 1.4, 12, 141, nflowers=0)
    for u in (-.95, .95):
        sc.add(box((u, 0, .12), (.62, .62, .24), SAND_MOSS, 0))
        sc.add(box((u, 0, 1.2), (.44, .44, 2.0), SAND_MOSS, 0))
    for k in range(7):
        a = 3.14 * k / 6
        if k == 3:
            continue
        sc.add(Xform(box((0, 0, 0), (.36, .44, .26), SAND_MOSS, 0), (0, math.degrees(a) - 90, 0), (-math.cos(a) * .95, 0, 2.2 + math.sin(a) * .62)))
    facet(sc, (.5, .7, 0), .25, ROCK_SAND, 142, squash=.8, nplanes=8)


@asset('nat_ruin_column_sand', 'nature', 'ruins', (150, 262), (75, 232), seed=143, blocks=(11,), tags=('ruinas', 'coluna', 'deserto'), footprint=18)
def ruin_column_sand(sc, f):
    add_patch(sc, 'sand', .8, 8, 143, nflowers=0)
    sc.add(box((0, 0, .12), (.9, .9, .24), SAND_MOSS, 0))
    sc.add(Cylinder((0, 0, .24), 1.9, .33, .29, SAND_MOSS))
    sc.add(box((0, 0, 2.28), (.78, .78, .18), SAND_MOSS, 0))
    sc.add(box((0, 0, 2.42), (.6, .6, .1), SAND_MOSS, 0))


@asset('nat_ruin_wall_sand', 'nature', 'ruins', (240, 206), (120, 172), seed=144, blocks=(16,), tags=('ruinas', 'muro', 'deserto'), footprint=24)
def ruin_wall_sand(sc, f):
    add_patch(sc, 'sand', 1.2, 10, 144, nflowers=0)
    rr = rng_for(144)
    for row in range(4):
        u = -.9
        while u < .9:
            w = rr.uniform(.3, .5)
            if row * .32 + rr.uniform(0, .25) < (1.35 - abs(u) * .7) and (row < 3 or rr.random() > .35):
                sc.add(box((u + w / 2, 0, row * .3 + .15), (w - .02, .34, .29), SAND_MOSS, 0))
            u += w
    for x, z in [(-.7, .02), (.75, .02)]:
        facet(sc, (x, .5, z), .2, ROCK_SAND, 145 + int(x * 10), squash=.8, nplanes=8)


@asset('nat_altar_sand', 'nature', 'ruins', (200, 190), (100, 158), seed=146, blocks=(16,), tags=('ruinas', 'altar', 'deserto'), footprint=28, frames=2)
def altar_sand(sc, f):
    add_patch(sc, 'sand', 1.3, 12, 146, nflowers=0)
    sc.add(box((0, 0, .1), (1.7, 1.7, .2), SAND_MOSS, 0))
    sc.add(box((0, 0, .3), (1.3, 1.3, .2), SAND_MOSS, 0))
    sc.add(box((0, 0, .68), (.8, .8, .56), SAND_MOSS, 0))
    sc.add(box((0, 0, .98), (1.0, 1.0, .1), SANDSTONE, 0))
    g = .85 + .15 * math.sin(f * 3.14)
    sc.add(Ellipsoid((0, 0, 1.12), (.28 * g, .28 * g, .12), GLOW_GOLD))
    sc.glow.append((0, 0, 1.1, 60, (255, 200, 90), .9 * g))


# ------------------------------------------------------------------ decalques de terreno (sem objeto, sem colisão)
def _decal(id, kind, seed, n, radius, size, tags, extras=None):
    @asset(id, 'nature', 'decals', (200, 120), (100, 60), seed=seed, tags=tags, shadow=False)
    def build(sc, f):
        add_patch(sc, kind, radius, n, seed, nflowers=0, height=.05, sizescale=size)
        if extras:
            extras(sc, seed)
    return build


def _pebbles(sc, seed):
    r = rng_for(seed + 5)
    for i in range(7):
        a = r.uniform(0, 6.28)
        d = r.uniform(.1, .8)
        facet(sc, (math.cos(a) * d, math.sin(a) * d * .8, 0), r.uniform(.06, .1), ROCK, seed + i, squash=.6, nplanes=6)


def _tufts(mat):
    def f(sc, seed):
        r = rng_for(seed + 7)
        for i in range(5):
            a = r.uniform(0, 6.28)
            d = r.uniform(.1, .7)
            tuft(sc, math.cos(a) * d, math.sin(a) * d * .8, mat, seed + i, n=5, h=.26, spread=.08)
    return f


_decal('nat_decal_grass_a', 'grass', 151, 14, .8, .85, ('transicao', 'grama'), _tufts(GRASS))
_decal('nat_decal_grass_b', 'grass', 152, 10, .6, .8, ('transicao', 'grama'))
_decal('nat_decal_dry_a', 'dry', 153, 14, .8, .85, ('transicao', 'grama_seca'), _tufts(GRASS_DRY))
_decal('nat_decal_sand_a', 'sand', 154, 14, .8, .85, ('transicao', 'areia'), _pebbles)
_decal('nat_decal_sand_b', 'sand', 155, 10, .6, .8, ('transicao', 'areia'))
_decal('nat_decal_snow_a', 'snow', 156, 14, .8, .85, ('transicao', 'neve'), _pebbles)
_decal('nat_decal_snow_b', 'snow', 157, 10, .6, .8, ('transicao', 'neve'))
_decal('nat_decal_dirt_a', 'dirt', 158, 12, .7, .8, ('transicao', 'terra'), _pebbles)
_decal('nat_decal_mud_bank', 'dirt', 159, 12, .7, .8, ('rio', 'margem'), _tufts(REED))
