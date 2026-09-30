"""Lote 2 / Ato II — Floresta Ancestral, PARTE 2C: Árvore-Memória (LOC_MEMORY_TREE, Q_MS02_MEMORY_TREE).
Landmark dominante do ato: reconhecível à distância; raízes formam arcos e passagens; cavidade/coração acessível na missão.
Estados: SEALED (antes das três raízes: cavidade fechada organicamente) e OPEN (raízes afastadas, luz suave no coração; permanece como codex depois)."""
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
from pro_nature import branch
from ato2_common import *


def m_memory_light():
    """Luz de memória: dourado-esverdeado suave (não é o azul do Eco nem o roxo da corrupção)."""
    return X('mem_light', lambda: mats.emissive('mem_light', '#d8f0a0', 2.6))


def m_memory_light_dim():
    return X('mem_light_dim', lambda: mats.emissive('mem_light_dim', '#a8cc7c', 1.0))


def _tree(open_state):
    bark = m_bark_old()
    rr = random.Random(310)
    H = 12.5
    # tronco colossal (cônico, com leve torção) e contrafortes que descem como arcos
    pts = []
    n = 7
    for i in range(n + 1):
        t = i / n
        pts.append((.4 * t * t, .2 * math.sin(t * 2.2), H * t))
    segs = []
    for i in range(n):
        ra = 3.4 - 1.7 * i / n
        rb = 3.4 - 1.7 * (i + 1) / n
        segs.append(geo.cyl_between(pts[i], pts[i + 1], ra, bark, sides=14, r2=rb))
    # CAVIDADE REAL (passe final): corte booleano no tronco em arco ogival orgânico — o interior tem paredes, teto e fundo de madeira
    # viva escura (não um retângulo preto recortado). Faixas do cortador em degraus ficam atrás das ombreiras de raiz.
    if open_state:                                                            # interior da madeira iluminado de dentro (luz de memória)
        cav = X('mem_cavity_lit', lambda: mats.flat('mem_cavity_lit', '#5a3c1e', rough=1.0, spec=0.0, emission='#8a6a30', emission_strength=.22, bevel_wear=.15))
    else:                                                                     # fechado: penumbra quente, nunca preto chapado
        cav = X('mem_cavity', lambda: mats.flat('mem_cavity', '#4a3018', rough=1.0, spec=0.0, emission='#4a3418', emission_strength=.12, bevel_wear=.15))
    prof = ((0.0, 2.3, 3.0), (2.3, 2.8, 2.5), (2.8, 3.2, 1.8), (3.2, 3.5, 1.0))
    for sg in segs[:2]:
        cutter = geo.join([geo.box((3.55, 0, (z0 + z1) / 2 - (.1 if z0 == 0 else 0)), (3.7, w, z1 - z0 + (.2 if z0 == 0 else .02)), None, bevel=0) for z0, z1, w in prof])
        geo.boolean_cut(sg, cutter, cav)
    for k in range(7):                                                        # nervuras internas (fibras de raiz) dão profundidade
        y = -1.25 + k * .42
        root((1.75, y, .05), (1.8 + (k % 2) * .2, y * .6, 3.2 - abs(y) * .5), .12, .07, cav, sag=-.1, sides=6)
    for k in range(4):
        root((1.8, -1.2 + k * .8, .06), (3.0, -1.4 + k * .9, .04), .16, .08, bark, sag=.02, sides=6)   # piso de raízes da cavidade
    for k in range(9):
        a = 2 * math.pi * k / 9 + rr.uniform(-.15, .15)
        L = 5.6 * rr.uniform(.85, 1.15)
        if abs(math.atan2(math.sin(a), math.cos(a))) < .75:                     # a frente (+x) fica livre: a cavidade é o foco
            a += .75 if math.sin(a) >= 0 else -.75
        root((math.cos(a) * 2.2, math.sin(a) * 2.2, 3.4), (math.cos(a) * L, math.sin(a) * L, .05), 1.0, .22, bark, sag=-.3, sides=9)
    # arcos de raiz frontais (+x): passagens em nível
    for sy in (-1, 1):
        root((2.0, sy * 1.9, 2.9), (4.2, sy * 3.9, .05), .75, .25, bark, sag=-.25, sides=9)
        root((1.6, sy * 2.2, 3.0), (3.4, sy * 5.2, .05), .55, .2, bark, sag=-.2, sides=8)
    for sy in (-1.75, 1.75):                                                      # ombreiras de raiz emoldurando o vão
        root((3.1, sy, .05), (3.1, sy * .8, 3.5), .42, .3, bark, sag=.05, sides=8)
    root((3.15, -1.5, 3.5), (3.15, 1.5, 3.5), .3, .3, bark, sag=-.3, sides=8)
    if open_state:
        ball((1.95, 0, 1.3), .55, m_memory_light(), squash=1.5)                          # coração aceso NO FUNDO da cavidade
        geo.box((1.85, 0, 1.6), (.04, 1.6, 2.2), m_memory_light_dim(), bevel=0)
        for k in range(5):                                                                 # veios de luz subindo pelas fibras
            geo.box((1.9, -1.0 + k * .5, 2.3 + (k % 2) * .3), (.04, .06, 1.1), m_memory_light_dim(), bevel=0)
        glow_mushrooms(3.8, -.6, 6, 21, spread=.6, h=.2)                                 # cogumelos de memória marcando a entrada aberta
        for k in range(4):                                                                # raízes recolhidas para os lados
            root((3.4, (k - 1.5) * 1.0, .05), (3.9, (k - 1.5) * 2.4, .05), .3, .12, bark, sag=-.05, sides=6)
    else:
        for k in range(11):                                                               # emaranhado de raízes fechando a cavidade
            y = -1.5 + k * .3
            root((3.2, y, .05), (3.3, y + rr.uniform(-.25, .25), 3.5 + rr.uniform(-.3, .2) - abs(y) * .3), .3, .16, bark, sag=.06, sides=6)
        for k in range(5):
            root((3.3, -1.6, .5 + k * .8), (3.4, 1.6, .7 + k * .8), .22, .18, bark, sag=.15, sides=6)
    # inscrições antigas quase engolidas pela casca (linhas emissivas discretas) e plataformas naturais
    for r_i in range(4):
        z = 3.9 + r_i * .5
        x0 = -1.6
        while x0 < 1.2:
            L = rr.uniform(.18, .46)
            geo.box((2.75 - r_i * .02, x0 + L / 2, z), (.04, L, .06), m_memory_light_dim(), bevel=0)
            x0 += L + rr.uniform(.08, .16)
    for z, ang in ((4.6, .8), (6.4, -.9)):
        geo.cyl((math.cos(ang) * 2.5, math.sin(ang) * 2.5, z), 1.3, .28, bark, sides=10, r2=1.0)      # plataformas naturais
    # galhos-mestres e copa monumental
    centers = []
    for k in range(8):
        a = k * .78 + rr.uniform(-.1, .1)
        z0 = 9.5 + rr.uniform(0, 1.6)
        p0 = (pts[6][0], pts[6][1], z0)
        p1 = (p0[0] + math.cos(a) * 5.4, p0[1] + math.sin(a) * 5.4, z0 + rr.uniform(.8, 2.0))
        branch(p0, p1, .75, .22, bark)
        centers.append((p1[0] * 1.02, p1[1] * 1.02, p1[2] + 1.3))
    centers += [(0, 0, H + 1.4), (2.6, -1.8, H + .5), (-2.4, 1.8, H + .8)]
    canopy_mass(centers, 2.5, 314, n_leaf=44, size=(.3, .44), light=False, tuft=m_leaf_mass())
    parts.hanging_vines(2.6, -2.4, 2.6, 2.4, 8.0, 3.4, 8, m_leaf_deep(), 5)
    parts.leaf_cluster(0, 0, .1, 4.4, 34, m_fern(), 9, size=(.16, .4), flat=.35)
    glow_mushrooms(3.4, -3.6, 8, 4, spread=.8, h=.32)
    if open_state:
        parts.flowers(3.4, 2.4, 1.6, 8, seed=6)
    geo.rotate_all(45)


@landmark('flo_memory_tree_sealed', group='nature', folder='ato2', size=(1700, 1800), origin=(850, 1500), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'landmark', 'estado_fechado'), footprint=140, collision=circ([(0, 0), (1.6, 0), (-1.6, 0), (0, 1.6), (0, -1.6), (1.1, 1.1), (-1.1, -1.1), (1.1, -1.1), (-1.1, 1.1)], 30), samples=24)
def memory_tree_sealed(f):
    _tree(False)


@landmark('flo_memory_tree_open', group='nature', folder='ato2', size=(1700, 1800), origin=(850, 1500), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'landmark', 'estado_aberto'), footprint=140, collision=circ([(0, -1.9), (0, 1.9), (-1.6, 0), (1.1, 1.1), (-1.1, -1.1), (1.1, -1.1), (-1.1, 1.1)], 30), samples=24)
def memory_tree_open(f):
    _tree(True)


@landmark('flo_memory_root_arch', group='nature', folder='ato2', size=(760, 640), origin=(380, 500), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'raiz_monumental', 'passagem', 'modular'), footprint=50, collision=circ([(0, -3.1), (0, 3.1)], 18), samples=24)
def memory_root_arch(f):
    """Arco monumental de raiz (passagem na clareira da Árvore-Memória)."""
    bark = m_bark_old()
    for sy in (-1, 1):
        root((0, sy * 3.2, .05), (0, sy * .6, 4.6), .95, .4, bark, sag=.35, sides=10)
    for k in range(5):
        y = -.7 + k * .35
        branch((0, y, 4.5), (0, y * 1.6, 5.0 + (k % 2) * .3), .2, .08, bark)
    parts.hanging_vines(0, -1.4, 0, 1.4, 4.5, 1.9, 6, m_leaf_deep(), 3)
    glow_mushrooms(.4, 3.4, 4, 3, spread=.3)
    parts.leaf_cluster(0, -3.2, .1, 1.2, 12, m_fern(), 5, size=(.12, .28), flat=.35)
    geo.rotate_all(45)


@landmark('flo_memory_stone', group='nature', folder='ato2', size=(220, 340), origin=(110, 280), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'pedra_memorial'), footprint=14, collision=circ([(0, 0)], 10), samples=24)
def memory_stone(f):
    """Pedra memorial com inscrição suave (luz de memória dourada), musgo e raiz."""
    st = m_stone_moss()
    parts.tapered_shaft(0, 0, 0, 2.1, .7, .5, st, seed=12)
    geo.box((.3, 0, 1.4), (.04, .3, .9), m_memory_light_dim(), bevel=0)
    for k in range(4):
        geo.box((.31, -.1 + (k % 2) * .2, 1.7 - k * .2), (.03, .1, .05), m_memory_light(), bevel=0)
    root((-.5, .3, .05), (0, 0, 1.3), .08, .05, m_bark_old(), sag=.06, sides=5)
    parts.leaf_cluster(0, 0, .08, .6, 8, m_fern(), 3, size=(.1, .2), flat=.4)
    geo.rotate_all(45)


@landmark('flo_memory_pool', group='nature', folder='ato2', size=(720, 400), origin=(360, 200), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'espelho_dagua', 'chao'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def memory_pool(f):
    """Espelho d'água parcial aos pés da árvore: lâmina rasa com pedras e nenúfares (piso, sem colisão)."""
    rr = random.Random(7)
    geo.cyl((0, 0, 0), 5.6, .03, m_pool(False), sides=32, r2=5.6)
    geo.cyl((0, 0, .02), 5.9, .015, m_moss_flat(), sides=32, r2=5.9)
    geo.cyl((0, 0, .04), 5.4, .02, m_pool(False), sides=32, r2=5.4)
    for k in range(8):
        a = rr.uniform(0, 6.28)
        d = rr.uniform(1.0, 4.6)
        ball((math.cos(a) * d, math.sin(a) * d, .06), rr.uniform(.18, .34), m_leaf_light(), squash=.25)


@landmark('flo_heart_floor', group='nature', folder='ato2', size=(860, 460), origin=(430, 230), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'coracao', 'piso', 'decalque'), footprint=0, collision=(), samples=16, catcher=False, outline=0)
def heart_floor(f):
    """Piso do coração da árvore: raízes entrelaçadas, musgo e anel de luz de memória (decalque)."""
    rr = random.Random(11)
    geo.cyl((0, 0, 0), 7.0, .03, m_moss_flat(), sides=36)
    for k in range(9):
        a = k * 2 * math.pi / 9
        root((math.cos(a) * 6.4, math.sin(a) * 6.4, .04), (math.cos(a + .4) * 1.2, math.sin(a + .4) * 1.2, .04), .16, .07, m_bark_old(), sag=-.05, sides=6)
    for ring in (5.0, 3.4):
        for k in range(40):
            a = k * 2 * math.pi / 40
            if rr.random() < .3:
                continue
            geo.box((math.cos(a) * ring, math.sin(a) * ring, .06), (.4, .07, .02), m_memory_light_dim(), rot=(0, 0, a + math.pi / 2), bevel=0)
    geo.cyl((0, 0, .05), 1.2, .02, m_memory_light_dim(), sides=24)


@landmark('flo_heart_seed', group='nature', folder='ato2', size=(360, 460), origin=(180, 340), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'coracao', 'nucleo', 'inativo'), footprint=30, collision=circ([(0, 0)], 14), samples=24)
def heart_seed(f):
    _seed(False)


@landmark('flo_heart_seed_active', group='nature', folder='ato2', size=(360, 460), origin=(180, 340), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'coracao', 'nucleo', 'ativo_memoria'), footprint=30, collision=circ([(0, 0)], 14), samples=24)
def heart_seed_active(f):
    _seed(True)


def _seed(active):
    """Semente-memória sobre pedestal de raízes: dormente (opaca, fraca) ou ativa (durante a cena de memória)."""
    bark = m_bark_old()
    geo.cyl((0, 0, 0), 1.0, .3, m_stone_moss(), sides=12, r2=.85)
    for k in range(6):
        a = k * math.pi / 3
        root((math.cos(a) * 1.3, math.sin(a) * 1.3, .05), (math.cos(a) * .3, math.sin(a) * .3, 1.3), .14, .06, bark, sag=.1, sides=6)
    mat = m_memory_light() if active else m_memory_light_dim()
    ball((0, 0, 1.55), .5 if not active else .6, mat, squash=1.25)
    if active:
        for h, r in ((1.0, .9), (1.6, .75), (2.3, .6)):
            geo.cyl((0, 0, h), r, .03, m_memory_light_dim(), sides=20, r2=r)
        for k in range(8):
            a = k * math.pi / 4
            geo.cyl_between((math.cos(a) * .8, math.sin(a) * .8, .5), (math.cos(a) * .35, math.sin(a) * .35, 1.5), .02, m_memory_light(), sides=4)
    parts.leaf_cluster(0, 0, .08, .9, 8, m_fern(), 4, size=(.1, .2), flat=.4)
    geo.rotate_all(45)


@landmark('flo_heart_wall', group='nature', folder='ato2', size=(420, 520), origin=(210, 420), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'coracao', 'parede', 'modular'), footprint=0, collision=(), samples=24)
def heart_wall(f):
    """Parede viva do coração da árvore: casca em sulcos, raízes em relevo, inscrições de memória e vinhas (segmento modular de 4 u)."""
    bark = m_bark_old()
    rr = random.Random(77)
    geo.box((0, 0, 2.0), (1.4, 4.0, 4.0), bark, bevel=0.1)
    for k in range(6):                                                    # raízes em relevo verticais, de espessuras diferentes
        y = -1.7 + k * .68 + rr.uniform(-.1, .1)
        root((.65, y, .05), (.7, y + rr.uniform(-.25, .25), 3.9), .24 + rr.uniform(0, .1), .12, bark, sag=.05, sides=7)
    for r_i in range(3):                                                  # inscrições de memória (luz suave, quase engolidas)
        z = 1.5 + r_i * .55
        y0 = -1.5
        while y0 < 1.3:
            L = rr.uniform(.2, .5)
            geo.box((.74, y0 + L / 2, z), (.04, L, .06), m_memory_light_dim(), bevel=0)
            y0 += L + rr.uniform(.1, .2)
    parts.hanging_vines(.72, -1.9, .72, 1.9, 3.9, 1.6, 6, m_leaf_deep(), 4)
    glow_mushrooms(.9, 1.6, 3, 5, spread=.25)
    geo.rotate_all(45)


@landmark('flo_heart_wall_diag', group='nature', folder='ato2', size=(600, 620), origin=(300, 470), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'coracao', 'parede', 'modular', 'diagonal'), footprint=0, collision=(), samples=24)
def heart_wall_diag(f):
    """Mesma parede viva do coração, mas correndo ao longo de um eixo isométrico (angulada), para fechar o espaço em V."""
    bark = m_bark_old()
    rr = random.Random(77)
    geo.box((0, 0, 2.0), (1.4, 4.0, 4.0), bark, bevel=0.1)
    for k in range(6):
        y = -1.7 + k * .68 + rr.uniform(-.1, .1)
        root((.65, y, .05), (.7, y + rr.uniform(-.25, .25), 3.9), .24 + rr.uniform(0, .1), .12, bark, sag=.05, sides=7)
    for r_i in range(3):
        z = 1.5 + r_i * .55
        y0 = -1.5
        while y0 < 1.3:
            L = rr.uniform(.2, .5)
            geo.box((.74, y0 + L / 2, z), (.04, L, .06), m_memory_light_dim(), bevel=0)
            y0 += L + rr.uniform(.1, .2)
    parts.hanging_vines(.72, -1.9, .72, 1.9, 3.9, 1.6, 6, m_leaf_deep(), 4)
    glow_mushrooms(.9, 1.6, 3, 5, spread=.25)


@landmark('flo_heart_wall_diagb', group='nature', folder='ato2', size=(600, 620), origin=(300, 470), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'coracao', 'parede', 'modular', 'diagonal'), footprint=0, collision=(), samples=24)
def heart_wall_diagb(f):
    heart_wall_diag(f)
    geo.rotate_all(90)


# ============================================================== PASSE FINAL (Parte E): câmara do Coração em PEÇA ÚNICA (sem módulos repetidos)
def chamber_wall(R, th0, th1, seed, bark, fiber, h=(3.6, 6.4), alcoves=(), moss=True, sap=None, rune=None, n=64, layer_off=0.0, lean_in=.25, spikes=None, spike_n=0):
    """Parede orgânica de câmara ao longo de um arco (graus) de raio R (u): colunas-tronco de raio/altura variáveis, fundidas por
    fibras horizontais, contrafortes que entram no piso, NICHOS (alcoves: lista de (θ, largura°)) recuados com luz própria, seiva
    e inscrições. Assimetria por ruído; nenhum trecho se repete."""
    rr = random.Random(seed)
    cols = []
    for i in range(n):
        th = math.radians(th0 + (th1 - th0) * (i + rr.uniform(.1, .9)) / n)
        deg = math.degrees(th)
        niche = any(abs(deg - a) < w / 2 for a, w in alcoves)
        rad = R + layer_off + rr.uniform(-.35, .35) + (1.5 if niche else 0)
        x, y = math.cos(th) * rad, math.sin(th) * rad
        hh = rr.uniform(*h) * (1 + .18 * math.sin(th * 3 + seed)) * (.8 if niche else 1)
        r0 = rr.uniform(.45, 1.05)
        ix, iy = -math.cos(th) * lean_in, -math.sin(th) * lean_in
        rt = r0 * rr.uniform(.55, .75)
        geo.cyl_between((x, y, -.05), (x + ix, y + iy, hh), r0, bark, sides=9, r2=rt)
        # topo: a coluna continua e se CURVA para dentro/para o lado, afinando — nunca um toco de topo chato
        bx, by = x + ix * 3 + math.sin(th) * rr.uniform(-.8, .8), y + iy * 3 - math.cos(th) * rr.uniform(-.8, .8)
        root((x + ix, y + iy, hh - .1), (bx, by, hh + rr.uniform(1.2, 2.4)), rt, .08, bark, sag=-.3, sides=8)
        cols.append((x, y, hh, r0, th, niche))
        if rr.random() < .55:                                            # contraforte entrando no piso (funde a parede ao chão)
            root((x - math.cos(th) * r0 * .5, y - math.sin(th) * r0 * .5, hh * .25), (x - math.cos(th) * (1.4 + r0), y - math.sin(th) * (1.4 + r0), .05), r0 * .5, r0 * .22, bark, sag=.25, sides=7)
        if niche:
            glow_mushrooms(x - math.cos(th) * .8, y - math.sin(th) * .8, 4, seed + i, spread=.35, h=.28)
    for (x0, y0, h0, r0, t0, _), (x1, y1, h1, r1, t1, _) in zip(cols[:-1], cols[1:]):   # fibras horizontais entre colunas vizinhas
        for k in range(rr.randint(1, 3)):
            z = rr.uniform(.6, min(h0, h1) * .9)
            root((x0, y0, z), (x1, y1, z + rr.uniform(-.4, .4)), rr.uniform(.12, .26), rr.uniform(.1, .2), fiber, sag=rr.uniform(-.2, .25), sides=6)
    for x, y, hh, r0, th, niche in cols:
        if sap is not None and rr.random() < .12:                        # seiva escorrendo
            geo.box((x - math.cos(th) * r0 * .9, y - math.sin(th) * r0 * .9, hh * .45), (.06, .06, hh * .5), sap, bevel=0)
        if rune is not None and rr.random() < .1:                        # inscrições/veios de luz
            for k in range(3):
                geo.box((x - math.cos(th) * r0 * .95, y - math.sin(th) * r0 * .95, hh * (.35 + k * .15)), (.04, .25, .05), rune, rot=(0, 0, th), bevel=0)
        if moss and rr.random() < .35:
            parts.leaf_cluster(x, y, hh * rr.uniform(.3, .8), r0 * .8, 8, m_leaf_deep(), int(th * 100), size=(.1, .2), flat=.5)
        if spikes is not None and rr.random() < spike_n:
            geo.cyl_between((x - math.cos(th) * r0, y - math.sin(th) * r0, rr.uniform(.4, 1.6)), (x - math.cos(th) * (r0 + 1.2), y - math.sin(th) * (r0 + 1.2), rr.uniform(1.4, 2.6)), .16, spikes, sides=5, r2=.01)
    return cols


def _arc_coll(R, th0, th1, n, r):
    return circ([(math.cos(math.radians(th0 + (th1 - th0) * i / (n - 1))) * R, math.sin(math.radians(th0 + (th1 - th0) * i / (n - 1))) * R) for i in range(n)], r)


@landmark('flo_heart_chamber', group='nature', folder='ato2', size=(1960, 1020), origin=(980, 890), tags=('ato2', 'floresta_ancestral', 'arvore_memoria', 'coracao', 'parede', 'passe_final', 'peca_unica'),
          footprint=0, collision=_arc_coll(14.2, 130, 320, 24, 22), samples=24)
def heart_chamber(f):
    """Parede viva do Coração (interior da Árvore-Memória) em UMA peça: colunas de madeira viva com fibras, nichos com cogumelos,
    seiva dourada, inscrições de memória e raízes que se arqueiam para dentro no fundo (teto sugerido)."""
    bark = m_bark_old()
    sap = X('mem_sap', lambda: mats.emissive('mem_sap', '#e0a040', 1.4))
    cols = chamber_wall(14.2, 128, 322, 77, bark, bark, h=(3.6, 6.2), alcoves=((180, 14), (232, 10), (275, 12)), sap=sap, rune=m_memory_light_dim(), n=66)
    rr = random.Random(78)
    for k in range(6):                                                   # raízes-arco para dentro no fundo (teto sugerido, sem cobrir o piso)
        th = math.radians(rr.uniform(195, 255))
        x, y = math.cos(th) * 14.2, math.sin(th) * 14.2
        root((x, y, 5.6), (x * .72, y * .72, 7.4 + rr.uniform(0, 1)), .5, .15, bark, sag=-.6, sides=7)
    for th in (128, 322):                                                # pontas do arco descem em contrafortes grandes (sem corte seco)
        t = math.radians(th)
        for k in range(3):
            root((math.cos(t) * 14.2, math.sin(t) * 14.2, 4.5 - k), (math.cos(t + (.12 if th == 128 else -.12)) * (11.5 - k), math.sin(t + (.12 if th == 128 else -.12)) * (11.5 - k), .02), 1.0 - k * .2, .2, bark, sag=-.5, sides=8)
