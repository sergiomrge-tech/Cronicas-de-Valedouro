"""Árvores do REG_001 — Remapeamento Etapa 3 (referência aprovada pelo Diretor: Karsiori tree/spruce pack), no padrão Valedouro.

Linguagem Karsiori traduzida para o pipeline Blender (mesma câmera, escala e acabamento pixel-art dos demais assets):
  * COPA EM TUFOS: cada tufo é uma massa arredondada com relevo de folhagem (couve-flor), luz no alto-esquerdo e sombra na base;
    os tufos ficam SEPARADOS por um miolo escuro visível (volume e leitura de silhueta), sem poeira de folhinhas soltas;
  * TRONCO CURVO com forquilhas visíveis que levam aos tufos; raízes que abrem no chão + relva/pedrinhas na base (contato);
  * SILHUETAS VARIADAS por ecologia: nuvem densa (carvalho), guarda-chuva (colinas secas), andares (vale), pirulito alto
    (bosque claro), bétula; SPRUCE em saias pendentes com borda de agulhas (fria = azul-acinzentada com neve).
Escala coerente com as casas de dois andares (árvore adulta ≈ 6–7,5 u)."""
import math
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import bpy
from vk import geo, mats, parts
from vk.parts import M
from pro_landmarks import landmark
from ato1_common import X, ball

PAL = {
    # (miolo/sombra, tufo) — 5 tons cada, do mais escuro ao realce
    'verde': (('#06210c', '#0b3614', '#124a1a', '#1a5c20', '#226a24'), ('#0f4a18', '#1c6a20', '#328a26', '#5aaa2e', '#9ccc44')),
    'verde2': (('#07220f', '#0c3818', '#134c1e', '#1b5e24', '#246c28'), ('#124e1e', '#1f7026', '#3a922c', '#66b236', '#aad24e')),
    'teal': (('#05201a', '#093428', '#0f4834', '#165a3e', '#1e6848'), ('#0e4a3a', '#1a6a4a', '#2e8a58', '#52aa66', '#92cc7a')),
    'oliva': (('#1a1e08', '#2a300c', '#3a4212', '#4a5418', '#5a641e'), ('#3a4412', '#56621a', '#768424', '#98a430', '#c4c84c')),
    'outono': (('#2a0e06', '#44180a', '#62260e', '#803614', '#9a461a'), ('#6a2a0c', '#a04416', '#cc6a22', '#e8963a', '#f8c866')),
    'dourada': (('#2a1c06', '#46300a', '#644610', '#825e16', '#9a721c'), ('#6a4a10', '#9e7418', '#c8a026', '#e2c63c', '#f4e47a')),
}
BARK = ('#1e0e06', '#3a1c0c', '#5a3016', '#7a4822', '#96602e')


def _mat_pair(pal):
    dark = X('kt_mass_' + pal, lambda: mats.foliage('kt_mass_' + pal, PAL[pal][0]))
    light = X('kt_tuft_' + pal, lambda: mats.foliage('kt_tuft_' + pal, PAL[pal][1]))
    return dark, light


def _bark():
    return X('kt_bark', lambda: mats.foliage('kt_bark', BARK))


def tuft(x, y, z, r, light, seed, squash=.82):
    """Tufo Karsiori: esfera com relevo de folhagem (deslocamento em nuvem), sombreada pela luz da cena."""
    o = ball((x, y, z), r, light, squash=squash)
    geo.displace_mesh(o, strength=r * .38, scale=max(.16, r * .28), subdiv=2, depth=3)
    return o


def crown(tufts, pal, seed, core=.62):
    """Copa: miolo escuro menor (aparece nas fendas) + tufos separados; alguns tufos pequenos na borda quebram o contorno."""
    dark, light = _mat_pair(pal)
    rr = random.Random(seed)
    for i, (x, y, z, r) in enumerate(tufts):
        ball((x, y, z - r * .25), r * core, dark, squash=.8)
    for i, (x, y, z, r) in enumerate(tufts):
        tuft(x, y, z, r, light, seed + i)
        for k in range(3):                                          # franja: tufinhos na borda inferior (contorno de folhas, não bola)
            a = rr.uniform(0, 6.28)
            tuft(x + math.cos(a) * r * .8, y + math.sin(a) * r * .8, z - r * .45, r * .32, light, seed + 200 + i * 5 + k, squash=.7)
    for k in range(max(3, len(tufts) // 2)):
        x, y, z, r = tufts[rr.randrange(len(tufts))]
        a = rr.uniform(0, 6.28)
        tuft(x + math.cos(a) * r * .95, y + math.sin(a) * r * .95, z - r * rr.uniform(.1, .35), r * rr.uniform(.35, .5), light, seed + 50 + k)


def curved_trunk(h, r0, r1, bark, seed, bend=(.35, .1), wiggle=.18, n=7):
    """Tronco curvo (S suave) — os pontos são usados para prender as forquilhas."""
    rr = random.Random(seed)
    ph = rr.uniform(0, 6.28)
    pts = []
    for i in range(n + 1):
        t = i / n
        pts.append((bend[0] * t * t + wiggle * math.sin(t * 3.2 + ph) * t, bend[1] * t * t + wiggle * .6 * math.cos(t * 2.7 + ph) * t, h * t))
    for i in range(n):
        geo.cyl_between(pts[i], pts[i + 1], r0 + (r1 - r0) * i / n, bark, sides=9, r2=r0 + (r1 - r0) * (i + 1) / n)
    return pts


def roots_base(r0, bark, seed, n=5, spread=2.0):
    rr = random.Random(seed)
    for k in range(n):
        a = k * (6.28 / n) + rr.uniform(-.3, .3)
        L = r0 * spread * rr.uniform(1.4, 2.2)
        geo.cyl_between((math.cos(a) * r0 * .4, math.sin(a) * r0 * .4, r0 * 1.2), (math.cos(a) * r0 * 1.1, math.sin(a) * r0 * 1.1, r0 * .35), r0 * .42, bark, sides=6, r2=r0 * .28)
        geo.cyl_between((math.cos(a) * r0 * 1.1, math.sin(a) * r0 * 1.1, r0 * .35), (math.cos(a) * L, math.sin(a) * L, -.02), r0 * .28, bark, sides=6, r2=r0 * .06)
    ground_detail(seed, r0 * 3.2)


def ground_detail(seed, rad):
    """Contato com o chão: relva em tufos, pedrinhas e folhas caídas (a árvore nunca fica 'pousada')."""
    rr = random.Random(seed + 7)
    parts.grass_tufts(0, 0, rad, 16, M('grass'), seed=seed, h=.3)
    for k in range(3):
        a = rr.uniform(0, 6.28)
        parts.boulder((math.cos(a) * rad * .8, math.sin(a) * rad * .8, .02), rr.uniform(.1, .18), M('rock_grey'), seed=seed + k, squash=.6)


def fork(p0, p1, r0, r1, bark):
    geo.cyl_between(p0, p1, r0, bark, sides=7, r2=r1)


# ------------------------------------------------------------------ silhuetas
def oak(seed, h, r0, pal, n_tufts=9, spread=1.9, tuft_r=(1.0, 1.35)):
    """Nuvem densa (Karsiori tree 7/15): forquilhas de um tronco curvo abrem uma cúpula de tufos."""
    rr = random.Random(seed)
    bark = _bark()
    pts = curved_trunk(h * .52, r0, r0 * .55, bark, seed)
    top = pts[-1]
    tufts = []
    for k in range(n_tufts - 2):
        a = k * (6.28 / (n_tufts - 2)) + rr.uniform(-.25, .25)
        d = spread * rr.uniform(.6, 1.0)
        z = h * rr.uniform(.6, .78)
        end = (top[0] + math.cos(a) * d, top[1] + math.sin(a) * d, z)
        fork(pts[4 + k % 3], end, r0 * .38, r0 * .12, bark)
        tufts.append((end[0], end[1], end[2] + .2, rr.uniform(*tuft_r)))
    tufts.append((top[0] + .1, top[1] - .1, h * .92, tuft_r[1] * 1.05))
    tufts.append((top[0] - .5, top[1] + .4, h * .84, tuft_r[1] * .95))
    crown(tufts, pal, seed)
    roots_base(r0, bark, seed)


def umbrella(seed, h, pal):
    """Guarda-chuva (Karsiori tree 1/9): tronco alto que se divide em 2–3 braços; copa larga e achatada em uma camada."""
    rr = random.Random(seed)
    bark = _bark()
    pts = curved_trunk(h * .55, .34, .2, bark, seed, bend=(.2, .05), wiggle=.25)
    top = pts[-1]
    tufts = []
    for k in range(3):
        a = k * 2.1 + rr.uniform(-.3, .3)
        end = (top[0] + math.cos(a) * 1.6, top[1] + math.sin(a) * 1.6, h * .78)
        fork(top, end, .16, .07, bark)
        for j in range(3):
            b = a + (j - 1) * .7
            tufts.append((end[0] + math.cos(b) * .9, end[1] + math.sin(b) * .9, h * .8 + rr.uniform(-.1, .15), rr.uniform(.8, 1.0)))
    tufts.append((top[0], top[1], h * .84, 1.05))
    crown(tufts, pal, seed, core=.55)
    roots_base(.34, bark, seed, n=4)


def tiered(seed, h, pal):
    """Andares (Karsiori tree 10): dois ou três 'pratos' de tufos em alturas diferentes, presos em galhos laterais."""
    rr = random.Random(seed)
    bark = _bark()
    pts = curved_trunk(h * .8, .36, .16, bark, seed, bend=(-.25, .15), wiggle=.3)
    tufts = []
    for lvl, (ti, rad, z) in enumerate(((3, 1.9, .42), (5, 1.4, .64), (7, .6, .86))):
        p = pts[ti]
        for k in range(4 if lvl < 2 else 3):
            a = k * (6.28 / 4) + lvl * .7 + rr.uniform(-.2, .2)
            end = (p[0] + math.cos(a) * rad, p[1] + math.sin(a) * rad, h * z)
            fork(p, end, .14 - lvl * .03, .05, bark)
            tufts.append((end[0], end[1], end[2] + .1, rr.uniform(.7, .9) * (1.0 - lvl * .12)))
    crown(tufts, pal, seed, core=.58)
    roots_base(.36, bark, seed, n=4)


def lollipop(seed, h, pal):
    """Pirulito alto (Karsiori tree 8): tronco fino e sinuoso, copa compacta e alta de tufos."""
    rr = random.Random(seed)
    bark = _bark()
    pts = curved_trunk(h * .66, .26, .15, bark, seed, bend=(.3, -.1), wiggle=.35)
    top = pts[-1]
    tufts = [(top[0] + math.cos(a) * .8, top[1] + math.sin(a) * .8, h * .76 + rr.uniform(-.1, .2), rr.uniform(.8, 1.0)) for a in (0, 2.1, 4.2)]
    tufts += [(top[0] + .1, top[1], h * .95, 1.0), (top[0] - .3, top[1] + .2, h * .62, .75)]
    crown(tufts, pal, seed)
    roots_base(.26, bark, seed, n=4)


def birch(seed, h):
    rr = random.Random(seed)
    bark = X('kt_birch', lambda: mats.foliage('kt_birch', ('#3a3632', '#8a8478', '#c8c2b4', '#e4e0d4', '#f6f4ec')))
    tufts = []
    for s, (dx, dy) in enumerate(((0, 0), (.55, .35))):
        pts = curved_trunk(h * .78, .16, .07, bark, seed + s, bend=(.25 + dx * .3, .1 - dy), wiggle=.12)
        for k in range(2):
            p = pts[4 + k * 2]
            a = rr.uniform(0, 6.28)
            end = (p[0] + math.cos(a) * .7, p[1] + math.sin(a) * .7, p[2] + .5)
            fork(p, end, .05, .02, bark)
            tufts.append((end[0], end[1], end[2] + .2, rr.uniform(.6, .75)))
        tufts.append((pts[-1][0], pts[-1][1], pts[-1][2] + .3, .75))
    crown(tufts, 'dourada' if seed % 2 else 'verde2', seed, core=.55)
    ground_detail(seed, .8)


def spruce(seed, h, cold=False, snow=False):
    """Spruce Karsiori: saias de galhos PENDENTES (cone achatado caindo nas pontas) com borda de agulhas recortada; luz no topo de
    cada saia e baixo escuro; ponta afilada. Variante fria azul-acinzentada, com neve acumulada no topo das saias."""
    rr = random.Random(seed)
    trunk_m = _bark()
    geo.cyl_between((0, 0, -.02), (0, 0, h * .98), .26, trunk_m, sides=8, r2=.05)
    cols = (('#0a1c24', '#123040', '#1e4658', '#3a6878', '#7aa0aa') if cold else ('#041a0e', '#0a2e18', '#124422', '#1e5c2c', '#3a7a3a'))
    needle = X('kt_spruce_' + ('cold' if cold else 'green'), lambda: mats.foliage('kt_spruce_' + ('cold' if cold else 'green'), cols))
    snow_m = M('snow_ground') if snow else None
    dark = X('kt_spruce_core_' + ('cold' if cold else 'green'), lambda: mats.foliage('kt_spruce_core_' + ('cold' if cold else 'green'), tuple(cols[:3]) + (cols[1], cols[2])))
    tiers = 7
    for i in range(tiers):
        t = i / (tiers - 1)
        z = h * (.16 + .74 * t)
        r = 1.45 * (1 - t) ** .85 + .2
        geo.cyl((0, 0, z - .5), r * .55, .7, dark, sides=10, r2=r * .1)           # miolo escuro da saia
        n = int(8 + r * 7)
        for k in range(n):                                        # ramo pendente ALONGADO na direção radial + pontas de agulha
            a = 2 * math.pi * k / n + rr.uniform(-.14, .14) + i * .45
            d = r * rr.uniform(.5, .7)
            c = ball((math.cos(a) * d, math.sin(a) * d, z - .3 - d * .18), r * .3 + .1, needle, squash=.4)
            c.scale = (1.9, .75, .4)
            c.rotation_euler = (0, math.radians(12), a)
            geo.displace_mesh(c, strength=.12, scale=.12, subdiv=2, depth=2)
            tip = (math.cos(a) * (d + r * .55), math.sin(a) * (d + r * .55), z - .55 - d * .2)
            for j in (-1, 1):
                b = a + j * .12
                geo.cyl_between((math.cos(b) * (d + r * .25), math.sin(b) * (d + r * .25), z - .35 - d * .18), (tip[0] + math.cos(b) * .1, tip[1] + math.sin(b) * .1, tip[2] - .12), .09, needle, sides=5, r2=.01)
            if snow_m is not None and k % 2 == 0:
                s2 = ball((math.cos(a) * d * .95, math.sin(a) * d * .95, z - .14 - d * .18), r * .18 + .05, snow_m, squash=.3)
                s2.scale = (1.7, .8, .3)
                s2.rotation_euler = (0, 0, a)
    geo.cyl((0, 0, h * .9), .22, h * .12, needle, sides=6, r2=.01)
    ground_detail(seed, 1.2)


TREE = dict(group='nature', folder='trees', size=(820, 980), origin=(410, 820), footprint=26, samples=24)


def _reg(tid, fn, tags, coll=12.0):
    landmark(tid, tags=('arvore', 'karsiori_valedouro', 'remap_etapa3') + tags, collision=((0.0, 0.0, coll),), **TREE)(fn)


# IDs existentes (mesmos IDs, remodelados)
_reg('nat_oak_a', lambda f: oak(401, 7.0, .42, 'verde', n_tufts=10), ('carvalho', 'verde'))
_reg('nat_oak_b', lambda f: oak(433, 6.2, .36, 'verde2', n_tufts=8, spread=1.6), ('carvalho', 'verde'))
_reg('nat_oak_c', lambda f: oak(467, 7.6, .46, 'teal', n_tufts=11, spread=2.1, tuft_r=(1.05, 1.45)), ('carvalho', 'grande'))
_reg('nat_oak_autumn', lambda f: oak(491, 6.6, .4, 'outono', n_tufts=9), ('carvalho', 'outono'))
_reg('nat_oak_golden', lambda f: oak(509, 6.0, .36, 'dourada', n_tufts=8, spread=1.6), ('carvalho', 'dourada'))
_reg('nat_pine_tall_a', lambda f: spruce(521, 7.4), ('pinheiro', 'spruce'), coll=10.0)
_reg('nat_pine_tall_b', lambda f: spruce(547, 6.2), ('pinheiro', 'spruce'), coll=10.0)
_reg('nat_pine_tall_snow', lambda f: spruce(563, 6.8, cold=True, snow=True), ('pinheiro', 'neve', 'spruce_frio'), coll=10.0)
_reg('nat_birch_tall', lambda f: birch(577, 6.0), ('betula',), coll=9.0)
# silhuetas novas para ecologia e transições de bioma
_reg('nat_tree_umbrella', lambda f: umbrella(611, 6.4, 'oliva'), ('guarda_chuva', 'colinas_secas', 'transicao_deserto'), coll=10.0)
_reg('nat_tree_tiered', lambda f: tiered(631, 6.2, 'teal'), ('andares', 'vale'), coll=10.0)
_reg('nat_tree_lollipop', lambda f: lollipop(653, 6.6, 'verde2'), ('pirulito', 'bosque_claro'), coll=9.0)
_reg('nat_spruce_cold', lambda f: spruce(677, 6.6, cold=True), ('spruce_frio', 'transicao_gelo'), coll=10.0)
_reg('nat_spruce_small', lambda f: spruce(691, 4.4), ('spruce', 'jovem', 'transicao_gelo'), coll=8.0)
