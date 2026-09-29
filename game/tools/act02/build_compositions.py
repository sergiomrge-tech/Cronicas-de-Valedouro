#!/usr/bin/env python3
"""Composições do Lote 2 (Ato II — Floresta Ancestral) → data/act02_compositions.json.

Cada composição é uma janela de 960x540 (coordenadas do palco = coordenadas de bosque) com objetos de arte, água, estados e capturas.
NÃO é a implantação final no mapa (essa é do Gerente GPT, ver LOTE02_ATO2_STORY_TO_MAP_v1.md §11): o dado usa coordenadas LOCAIS por LOC_*
e chaves de estado canônicas ("quest:<ID>" = concluída; "quest:<ID>:active" = em curso; "boss:<ID>" = primeira derrota) para o Gerente importar.
Vegetação obedece exclusões (trilhas, rio, portas, arenas, NPCs) e distância mínima (sem grade)."""
import json
import math
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'data' / 'act02_compositions.json'
MAN = json.load(open(ROOT / 'data' / 'modeled_assets_manifest.json'))
IDS = {a['id'] for a in MAN['assets']}


_KIT = {}


def orient_kit():
    """Direção de corrida na tela de cada variante do kit multi-ângulo (gerado por tools/art_pipeline/orient_analyze.py)."""
    if not _KIT:
        _KIT.update(json.load(open(ROOT / 'data' / 'orient_kit.json')))
    return _KIT


class Comp:
    def __init__(self, cid, name, origin, story, tint=(.04, .16, .1, .2), slug=None, terrain='forest'):
        self.d = {'id': cid, 'name': name, 'origin': list(origin), 'story': story, 'ground_tint': list(tint), 'water': [], 'objects': [], 'captures': [], 'light_shafts': [], 'exclusions': [],
                  'slug': slug or cid.lower(), 'terrain': terrain}
        self.o = origin
        self.placed = []

    def add(self, asset, x, y, **kw):
        assert asset in IDS or asset.startswith('APP:'), 'asset inexistente: ' + asset
        obj = {'asset': asset, 'x': round(self.o[0] + x, 1), 'y': round(self.o[1] + y, 1)}
        obj.update({k: v for k, v in kw.items() if v not in (None, False)})
        self.d['objects'].append(obj)
        self.placed.append((x, y))
        return obj

    def run(self, family, pts, step_gap=0.0, **kw):
        """Encadeia peças de uma família modular ao longo de uma POLILINHA (coordenadas locais). Escolhe, para cada trecho, a variante do
        kit multi-ângulo (data/orient_kit.json) cuja direção de corrida na tela é a mais próxima — assim muros/paliçadas fazem curvas e
        recintos em vez de repetir a mesma diagonal. Retorna a lista de objetos criados."""
        kit = orient_kit()
        vs = [(v['deg'], vid, v) for vid, v in kit.items() if v['family'] == family and v['kind'] == 'seg']
        assert vs, 'família sem kit: ' + family
        made = []
        for (x0, y0), (x1, y1) in zip(pts[:-1], pts[1:]):
            dx, dy = x1 - x0, y1 - y0
            dist = math.hypot(dx, dy)
            if dist < 1:
                continue
            want = math.degrees(math.atan2(dy, dx)) % 180.0
            deg, vid, v = min(vs, key=lambda t: min(abs(t[0] - want), 180 - abs(t[0] - want)))
            seg = max(24.0, v['len_px'] + step_gap)
            n = max(1, int(round(dist / seg))) if step_gap else max(1, int(math.ceil(dist / (seg * .88))))   # sem vão: peças sobrepostas
            for i in range(n):
                t = (i + .5) / n
                made.append(self.add(vid, x0 + dx * t, y0 + dy * t, **kw))
        return made

    def exclude_rect(self, x, y, w, h):
        self.d['exclusions'].append({'rect': [x, y, w, h]})

    def exclude_circle(self, x, y, r):
        self.d['exclusions'].append({'circle': [x, y, r]})

    def blocked(self, x, y, pad=0):
        for e in self.d['exclusions']:
            if 'rect' in e:
                rx, ry, rw, rh = e['rect']
                if rx - pad <= x <= rx + rw + pad and ry - pad <= y <= ry + rh + pad:
                    return True
            else:
                cx, cy, r = e['circle']
                if math.hypot(x - cx, y - cy) < r + pad:
                    return True
        return False

    def scatter(self, assets, n, region, seed, min_d=46, tries=400, weights=None, **kw):
        """Espalha n objetos em `region`=(x,y,w,h) respeitando exclusões e distância mínima."""
        rr = random.Random(seed)
        got = 0
        for _ in range(tries):
            if got >= n:
                break
            x, y = region[0] + rr.random() * region[2], region[1] + rr.random() * region[3]
            if self.blocked(x, y, pad=12):
                continue
            if any(math.hypot(x - px, y - py) < min_d for px, py in self.placed):
                continue
            a = rr.choices(assets, weights=weights)[0] if weights else rr.choice(assets)
            self.add(a, x, y, flip=rr.random() < .5, **kw)
            got += 1
        return got

    def trail(self, pts, half=22, seed=1, **state):
        t = {'pts': [[self.o[0] + x, self.o[1] + y] for x, y in pts], 'half': half, 'seed': seed}
        t.update(state)                                  # show_when / hide_when
        self.d.setdefault('trails', []).append(t)
        self._exclude_line(pts, half * .9)

    def _exclude_line(self, pts, r):
        """Exclusão ao longo de uma polilinha (trilha/rio curvos): círculos encadeados em vez de retângulos cartesianos."""
        for (x0, y0), (x1, y1) in zip(pts[:-1], pts[1:]):
            n = max(1, int(math.hypot(x1 - x0, y1 - y0) / (r * .8)))
            for i in range(n + 1):
                self.exclude_circle(x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n, r)

    def river(self, pts, half=60, wobble=.35):
        """Rio/riacho sinuoso de largura variável (assado no chão por tools/act02/bake_act02_ground.py). Nunca retângulo nem largura constante."""
        self.d.setdefault('rivers', []).append({'pts': [[self.o[0] + x, self.o[1] + y] for x, y in pts], 'half': half, 'wobble': wobble})
        self._exclude_line(pts, half * 1.05)

    def bank_scatter(self, assets, pts, off, n, seed, min_d=40, **kw):
        """Espalha na MARGEM de um rio: pontos deslocados perpendicularmente à polilinha, dos dois lados."""
        rr = random.Random(seed)
        got = 0
        for _ in range(n * 30):
            if got >= n:
                break
            i = rr.randrange(len(pts) - 1)
            (x0, y0), (x1, y1) = pts[i], pts[i + 1]
            t = rr.random()
            dx, dy = x1 - x0, y1 - y0
            L = math.hypot(dx, dy) or 1
            side = rr.choice((-1, 1))
            d = off * rr.uniform(.9, 1.25)
            x, y = x0 + dx * t - dy / L * d * side, y0 + dy * t + dx / L * d * side
            if not (10 < x < 950 and 30 < y < 530):
                continue
            if any(math.hypot(x - px, y - py) < min_d for px, py in self.placed):
                continue
            self.add(rr.choice(assets), x, y, flip=rr.random() < .5, **kw)
            got += 1

    def yard(self, pts, half=50, seed=1):
        """Chão batido/pisoteado pela ocupação (assado no chão como trilha larga e irregular)."""
        t = {'pts': [[self.o[0] + x, self.o[1] + y] for x, y in pts], 'half': half, 'seed': seed, 'yard': True}
        self.d.setdefault('trails', []).append(t)

    def shot(self, name, flags=()):
        self.d['captures'].append({'name': name, 'flags': list(flags)})


comps = []

# ============================================================== LOC_FOREST_STONE_BRIDGE (Q_MS02_BORDER)
b = Comp('LOC_FOREST_STONE_BRIDGE', 'Ponte de Pedra da Fronteira', (300, 90),
         'Entrada da região: margem oeste ainda parecida com o Berço; depois da ponte, a floresta antiga (troncos largos, raízes, musgo, luz filtrada).', slug='ponte_fronteira')
b.exclude_circle(800, 500, 60)                     # plataforma de descanso
b.exclude_circle(480, 330, 130)                    # ponte inteira
# rio sinuoso que corre na diagonal isométrica (eixo x da ponte): nasce no alto-direito, passa SOB o arco e se alarga embaixo
_RIO = [(1010, 30), (900, 110), (800, 150), (680, 238), (560, 290), (480, 330), (400, 372), (300, 396), (200, 470), (110, 580)]
b.river(_RIO, half=50, wobble=.34)
# estrada antiga chega em CURVA às cabeceiras (a ponte corre na outra diagonal); do lado leste some sob raízes até a quest
b.trail([(-20, 238), (120, 262), (240, 262), (310, 282), (345, 298)], half=22, seed=3)
b.trail([(535, 410), (610, 432), (700, 430), (790, 440), (880, 426), (980, 396)], half=22, seed=13)
b.add('flo_stone_bridge_arch', 480, 330)
b.add('flo_border_marker', 318, 300)
b.add('flo_border_marker', 628, 356, flip=True)
b.add('flo_rest_platform', 800, 500)
b.add('flo_root_arch', 735, 430, scale=.8)                    # porta natural depois da ponte
for i, (x, y) in enumerate(((680, 416), (790, 440), (850, 432), (910, 418))):
    b.add('flo_root_run', x, y, show_when='!quest:Q_MS02_BORDER', layer='ground', flip=i % 2 == 0)   # antes: trilha interior fechada por raízes
# margem noroeste (Berço): árvores comuns e vegetação leve
for x, y, a in ((60, 170, 'nat_tree_pine'), (150, 100, 'nat_tree_birch'), (250, 170, 'nat_tree_pine'), (110, 420, 'nat_tree_birch'), (190, 330, 'nat_tree_pine'), (340, 100, 'nat_tree_birch'), (440, 200, 'nat_oak_b')):
    b.add(a, x, y)
# margem sudeste (floresta ancestral): árvores largas, pedras engolidas, samambaias
b.add('flo_ancient_tree_a', 800, 300, scale=.72)
b.add('flo_ancient_tree_b', 920, 230, scale=.7)
b.add('flo_ancient_tree_a', 900, 540, flip=True, scale=.72)
b.add('flo_ancient_tree_b', 640, 540, scale=.7)
b.add('flo_stone_moss', 560, 470)
b.add('flo_stone_moss', 250, 470)
b.add('nat_rock_mossy', 405, 272)
b.bank_scatter(['nat_reeds'], _RIO, 74, 10, 3, min_d=46)
b.scatter(['nat_bush_green', 'nat_bush_flowering', 'nat_flowers_meadow', 'nat_grass_tall'], 10, (20, 60, 420, 300), 11, min_d=44)
b.scatter(['flo_fern_patch', 'flo_glow_mushrooms', 'flo_fern_patch'], 10, (520, 300, 430, 230), 12, min_d=50)
b.d['light_shafts'] = [[b.o[0] + 700, b.o[1] + 0], [b.o[0] + 840, b.o[1] + 40]]
b.shot('FLO_2A_PONTE_ANTES', [])
b.shot('FLO_2A_PONTE_DEPOIS', ['quest:Q_MS02_BORDER'])
comps.append(b.d)

# ============================================================== LOC_FOREST_RANGER_LODGE (Q_MS02_RANGERS)
r = Comp('LOC_FOREST_RANGER_LODGE', 'Casa dos Guardas Verdes', (520, 250),
         'Hub leve: clareira defendida com casa, posto de observação, depósito, ervas, mesa de mapas, alvos e arsenal; sinais de ataque até a defesa.', tint=(.05, .15, .08, .18), slug='posto_guardas')
r.exclude_circle(430, 410, 70)                     # pátio de chão batido em frente à varanda
r.exclude_circle(500, 300, 120)                    # casa
r.yard([(360, 400), (430, 420), (520, 410), (600, 420)], half=50, seed=15)     # terreno pisado pela ocupação
r.trail([(-20, 404), (140, 432), (300, 452), (440, 452), (560, 462), (720, 478), (860, 460), (980, 424)], half=20, seed=5)   # patrulha: curva suave
r.trail([(452, 580), (446, 520), (436, 460), (424, 400), (426, 352)], half=21, seed=8)          # acesso aos degraus da varanda
r.trail([(610, 470), (640, 400), (650, 320), (626, 210), (650, 60)], half=15, seed=11)          # picada norte entre a casa e a torre
r.add('flo_ranger_hall', 500, 300)
r.add('flo_ranger_tower', 790, 300)
r.add('flo_ranger_store', 250, 300)
r.add('flo_herb_bench', 330, 380)
r.add('flo_map_table', 600, 405)
r.add('flo_training_target', 840, 455)
r.add('flo_training_target', 895, 420, flip=True)
r.add('flo_weapon_rack_green', 720, 410)
r.add('nat_campfire', 410, 430, anim=1)
r.add('nat_log_fallen', 370, 460, layer='ground')
r.add('flo_claw_tree', 900, 330, scale=.75)                   # árvore arranhada pelo ataque
# paliçada orgânica: trechos parciais em arco, nunca um muro contínuo
_DEF = 'quest:Q_MS02_RANGERS'
_pal_w = [(40, 250), (70, 320), (120, 380), (190, 430), (270, 470), (340, 500)]                # arco oeste da paliçada
_pal_e = [(920, 260), (890, 330), (850, 400), (790, 455), (720, 490), (650, 510)]              # arco leste
for _pts in (_pal_w, _pal_e):
    r.run('flo_palisade_organic', _pts, show_when=_DEF, step_gap=26)        # reparada (pós-defesa)
    r.run('flo_palisade_broken', _pts, hide_when=_DEF, step_gap=26)         # quebrada (pré/durante)
r.run('flo_barricade_improvised', [(330, 505), (400, 520)], hide_when=_DEF)
r.run('flo_barricade_improvised', [(560, 520), (630, 505)], hide_when=_DEF)
# pontos claros de entrada das criaturas (durante a defesa): pegadas de Eco e mato pisoteado
for x, y in ((60, 460), (900, 510)):
    r.add('flo_root_run', x, y, show_when='quest:Q_MS02_RANGERS:active', layer='ground')
r.add('flo_ancient_tree_a', 110, 200, scale=.75)
r.add('flo_ancient_tree_b', 380, 190, scale=.6)       # duas árvores ancestrais abraçam a casa (a construção se apoia nelas)
r.add('flo_ancient_tree_a', 640, 200, flip=True, scale=.6)
r.add('flo_ancient_tree_b', 920, 150, scale=.75)
r.add('flo_ancient_tree_a', 760, 90, flip=True, scale=.7)
for _pts, _sd in ((_pal_w, 61), (_pal_e, 62)):                 # a cerca some na vegetação: moitas e samambaias do lado de fora
    rr_ = random.Random(_sd)
    for (x0, y0), (x1, y1) in zip(_pts[:-1], _pts[1:]):
        if rr_.random() < .7:
            r.add(rr_.choice(['nat_bush_green', 'flo_fern_patch', 'nat_grass_tall']), (x0 + x1) / 2 + (-30 if _sd == 61 else 30), (y0 + y1) / 2 + 18, flip=rr_.random() < .5)
r.scatter(['flo_fern_patch', 'flo_glow_mushrooms', 'nat_bush_green', 'nat_flowers_meadow'], 12, (20, 60, 920, 470), 21, min_d=44)
r.d['light_shafts'] = [[r.o[0] + 380, r.o[1] + 0], [r.o[0] + 560, r.o[1] + 20]]
r.shot('FLO_2A_CASA_PRE', [])
r.shot('FLO_2A_CASA_DURANTE', ['quest:Q_MS02_RANGERS:active'])
r.shot('FLO_2A_CASA_POS', ['quest:Q_MS02_RANGERS'])
comps.append(r.d)

# ============================================================== LOC_FOREST_ROOT_SHRINES (Q_MS02_ROOTS) — três braços (uma composição por microárea)
def shrine_arm(key, name, origin, story, build):
    sd = sum(map(ord, key))                                      # semente determinística (hash() de str varia por processo)
    c = Comp('LOC_FOREST_ROOT_SHRINES', name, origin, story, tint=(.05, .14, .09, .2), slug='santuario_' + key)
    flag = 'quest:Q_MS02_ROOTS:' + key                         # sub-objetivo purificado deste braço (mesma fonte de verdade da quest)
    c.exclude_circle(480, 330, 120)                              # área do santuário
    c.trail([(-20, 512), (130, 498), (260, 470), (380, 446), (470, 404)], half=18, seed=sd % 17)
    c.add('flo_shrine_' + key + '_corrupt', 480, 340, hide_when=flag)
    c.add('flo_shrine_' + key + '_pure', 480, 340, show_when=flag)
    c.add('flo_shrine_path_marker', 330, 470)
    c.add('flo_shrine_path_marker', 640, 450, flip=True)
    # estado corrompido: mato murcho, teias; purificado: flores, samambaias, cogumelos
    for x, y in ((380, 400), (600, 400), (420, 300), (560, 290)):
        c.add('nat_bush_dry', x, y, hide_when=flag)
        c.add('nat_bush_flowering', x + 6, y + 4, show_when=flag)
    c.add('nat_web_ground', 540, 420, hide_when=flag, layer='ground')
    c.add('flo_glow_mushrooms', 610, 380, show_when=flag)
    c.add('flo_fern_patch', 350, 380, show_when=flag)
    build(c, flag)
    c.scatter(['flo_fern_patch', 'flo_glow_mushrooms', 'nat_bush_green'], 8, (20, 60, 920, 470), sd, min_d=48)
    c.d['light_shafts'] = [[c.o[0] + 420, c.o[1] + 0]]
    c.shot('FLO_2B_' + key.upper() + '_CORROMPIDA', [])
    c.shot('FLO_2B_' + key.upper() + '_PURIFICADA', [flag])
    comps.append(c.d)


def build_water(c, flag):
    _st = [(170, 150), (150, 205), (196, 250), (168, 300), (96, 332), (20, 350), (-40, 372)]
    c.river(_st, half=46, wobble=.42)                          # riacho que desce da queda: largura variável, sem espelho retangular
    c.add('nat_waterfall_front', 165, 160)
    for x, y in ((64, 282), (140, 384), (262, 296), (250, 200)):        # pedras nas MARGENS do riacho, não dentro da água
        c.add('nat_rock_mossy', x, y)
    c.bank_scatter(['nat_reeds'], _st, 66, 7, 5, min_d=40)
    c.add('flo_ancient_tree_a', 780, 200, scale=.7)
    c.add('flo_ancient_tree_b', 880, 470, scale=.65)


def build_stone(c, flag):
    c.add('nat_wall_cliff_rock_a', 150, 200)
    c.add('nat_wall_cliff_rock_b', 300, 190)
    c.add('nat_ruin_wall', 700, 250)
    c.add('nat_ruin_column_broken', 770, 330)
    c.add('nat_ruin_column', 640, 250)
    c.add('flo_stone_moss', 250, 400)
    c.add('flo_stone_moss', 780, 430)
    c.add('flo_root_shortcut_blocked', 860, 400, hide_when='quest:Q_MS02_ROOTS:stone')       # atalho destravável ao purificar
    c.add('flo_root_shortcut_open', 860, 400, show_when='quest:Q_MS02_ROOTS:stone')
    c.add('flo_ancient_tree_b', 110, 470, scale=.65)
    c.add('flo_ancient_tree_a', 520, 130, scale=.65)


def build_wind(c, flag):
    c.add('nat_wall_cliff_rock_a', 800, 300)                       # mirante natural (rocha): de lá se vê o topo da Árvore-Memória
    c.add('flo_ancient_tree_a', 130, 230, scale=.7, flip=True)
    c.add('flo_ancient_tree_b', 300, 140, scale=.6)
    for x, y in ((240, 380), (700, 470)):
        c.add('nat_tree_dead', x, y, hide_when=flag)                # árvores secas antes da purificação
    c.add('flo_ancient_tree_b', 900, 150, scale=.65)


shrine_arm('water', 'Santuário — Raiz da Água', (300, 150), "Braço úmido: bacia de pedra sobre um espelho d'água, musgo e pequenas quedas; corrompido = água parada e escura, veios roxos; purificado = água clara e vida.", build_water)
shrine_arm('stone', 'Santuário — Raiz da Pedra', (700, 100), 'Braço rochoso: monólito abraçado por raízes junto a ruínas antigas; atalho destravável ao purificar.', build_stone)
shrine_arm('wind', 'Santuário — Raiz do Vento', (520, 210), 'Braço elevado: patamar de lajes com pórtico de árvores inclinadas, mirante próximo; sinos de folhas quando purificado.', build_wind)

# ============================================================== LOC_MEMORY_TREE (Q_MS02_MEMORY_TREE) — exterior e coração
m = Comp('LOC_MEMORY_TREE', 'Árvore-Memória — exterior', (380, 130),
         'Landmark dominante: tronco colossal, raízes em arcos e passagens, clareira central com espelho d\'água e pedras memoriais. Fechada até purificar as três raízes; depois as raízes se afastam.', tint=(.05, .15, .1, .18), slug='arvore_memoria_exterior')
m.exclude_circle(480, 380, 200)
m.river([(350, 452), (420, 474), (520, 470), (600, 452), (650, 432)], half=32, wobble=.5)   # espelho d'água ORGÂNICO aos pés (raízes da árvore invadem a água)
m.trail([(-20, 500), (120, 484), (240, 460), (320, 440), (370, 420)], half=20, seed=9)           # trilhas CONVERGENTES: oeste,
m.trail([(980, 430), (860, 440), (760, 436), (680, 420), (620, 404)], half=17, seed=19)          # leste
m.trail([(260, 590), (270, 530), (292, 480), (330, 448)], half=14, seed=23)                         # e uma picada do sul que se junta à oeste
m.add('flo_memory_tree_sealed', 480, 390, scale=.68, hide_when='quest:Q_MS02_ROOTS')
m.add('flo_memory_tree_open', 480, 390, scale=.68, show_when='quest:Q_MS02_ROOTS')
m.add('flo_memory_root_arch', 190, 440, scale=.8)
m.add('flo_memory_root_arch', 780, 430, scale=.8, flip=True)
for x, y in ((300, 470), (660, 470), (400, 505), (575, 500)):
    m.add('flo_memory_stone', x, y, flip=x > 480)
m.add('flo_ancient_tree_a', 80, 300, scale=.45)            # vizinhas MENORES: a Árvore-Memória domina pela escala
m.add('flo_ancient_tree_b', 900, 300, scale=.45, flip=True)
m.add('flo_ancient_tree_b', 60, 560, scale=.42)
m.add('flo_stone_moss', 130, 520)
m.scatter(['flo_fern_patch', 'flo_glow_mushrooms'], 10, (20, 60, 920, 470), 33, min_d=52)
m.d['light_shafts'] = [[m.o[0] + 300, m.o[1] + 0], [m.o[0] + 640, m.o[1] + 0]]
m.d['motes'] = {'x': m.o[0] + 480, 'y': m.o[1] + 320, 'rx': 260, 'ry': 160, 'n': 18, 'color': [.85, 1, .6], 'show_when': 'quest:Q_MS02_ROOTS'}   # partículas leves de memória (baratas: 18 pontos)
m.shot('FLO_2C_ARVORE_FECHADA', [])
m.shot('FLO_2C_ARVORE_ABERTA', ['quest:Q_MS02_ROOTS'])
comps.append(m.d)

h = Comp('LOC_MEMORY_TREE', 'Árvore-Memória — coração', (380, 130),
         'Interior/coração acessível na missão: piso de raízes com anel de luz, semente-memória sobre pedestal, inscrições, arcos de raiz como paredes; espaço para as memórias de Adrian.', tint=(.02, .06, .04, .35), terrain='none')
h.d['ground_solid'] = [.05, .09, .06]
h.add('flo_heart_floor', 480, 330, layer='ground', scale=1.15)
h.add('flo_heart_seed', 480, 330, hide_when='quest:Q_MS02_MEMORY_TREE:active')
h.add('flo_heart_seed_active', 480, 330, show_when='quest:Q_MS02_MEMORY_TREE:active')
h.run('flo_heart_wall', [(480 + 380 * math.cos(math.radians(a)), 345 - 200 * math.sin(math.radians(a))) for a in range(10, 171, 10)])   # parede viva CURVA (a árvore por dentro), kit multi-ângulo
h.add('flo_memory_root_arch', 110, 330, scale=.8)
h.add('flo_memory_root_arch', 860, 340, scale=.8, flip=True)
for i, (x, y) in enumerate(((300, 400), (660, 400), (240, 330), (720, 330))):
    h.add('flo_memory_stone', x, y, flip=x > 480)
for x, y in ((150, 420), (820, 430), (330, 470), (620, 470)):
    h.add('flo_glow_mushrooms', x, y)
for x, y in ((110, 330), (850, 330)):
    h.add('flo_fern_patch', x, y)
h.d['vignette'] = .5
h.shot('FLO_2C_CORACAO_DORMENTE', [])
h.shot('FLO_2C_CORACAO_MEMORIA_ATIVA', ['quest:Q_MS02_MEMORY_TREE:active'])
comps.append(h.d)

# ============================================================== LOC_HOLLOW_ROOT_ARENA (Q_MS02_HOLLOW_ROOT, BOSS_RAIZ_OCA_001)
# Regra do Guardião aplicada: primeira derrota = flag persistente "elites:BOSS_RAIZ_OCA_001"; revanche = leitura visual temporária ("rematch:<ID>").
BOSS = 'elites:BOSS_RAIZ_OCA_001'
a = Comp('LOC_HOLLOW_ROOT_ARENA', 'Coração da Raiz Oca — arena', (380, 130),
         'Arena feita para o boss: piso com anéis e cunhas de telegráfico, raízes gigantes delimitando o campo, núcleo ao fundo; circulação livre no campo. Ativa até a primeira derrota; depois dormente/purificada; a revanche reativa só a apresentação.', tint=(.03, .04, .08, .3), terrain='none')
a.d['ground_solid'] = [.06, .05, .09]
a.exclude_circle(480, 340, 250)                        # campo de combate livre de props
# fundo em V angulado (eixos isométricos): lado direito desce em +Y (diagonal ↘), lado esquerdo em -X espelhado (diagonal ↙); frente aberta para a câmera
def arc_pts(cx, cy, rx, ry, a0, a1, n):
    """Polilinha em arco (elipse 2:1 = círculo em perspectiva isométrica), para muros curvos."""
    return [(cx + rx * math.cos(math.radians(a0 + (a1 - a0) * i / n)), cy - ry * math.sin(math.radians(a0 + (a1 - a0) * i / n))) for i in range(n + 1)]


_arena_arc = arc_pts(480, 375, 400, 215, 5, 175, 14)                # muro CURVO envolvendo o fundo do campo (kit multi-ângulo: 8 direções)
a.run('flo_hollow_wall_active', _arena_arc, hide_when=BOSS)
a.run('flo_hollow_wall_dormant', _arena_arc, show_when=BOSS)
a.add('flo_hollow_floor_active', 480, 350, layer='ground', hide_when=BOSS)
a.add('flo_hollow_floor_dormant', 480, 350, layer='ground', show_when=BOSS)
a.add('flo_hollow_core_active', 480, 352, hide_when=BOSS)
a.add('flo_hollow_core_dormant', 480, 352, show_when=BOSS)
for x, y in ((90, 330), (860, 340), (140, 460), (830, 470)):    # espinhos só no estado ativo (nunca dentro do campo)
    a.add('flo_corrupt_root_spike', x, y, hide_when=BOSS)
a.d['vignette'] = .5
a.shot('FLO_2D_ARENA_PRE_BOSS', [])
a.shot('FLO_2D_ARENA_POS_PRIMEIRA_DERROTA', [BOSS])
a.shot('FLO_2D_ARENA_REVANCHE_ATIVA', [BOSS, 'rematch:BOSS_RAIZ_OCA_001'])
comps.append(a.d)

w = Comp('LOC_HOLLOW_ROOT_ARENA', 'Coração da Raiz Oca — aproximação e ferida', (500, 200),
         'Acesso: uma ferida aberta na floresta sob/atrás da Árvore-Memória; a corrupção aumenta no caminho (solo escurecido, veios, espinhos). Depois da derrota a ferida cicatriza.', tint=(.05, .1, .09, .22), slug='raiz_oca_ferida')
w.exclude_circle(740, 330, 130)
w.trail([(-20, 448), (140, 432), (300, 426), (460, 410), (590, 388), (690, 352)], half=18, seed=6)
w.add('flo_hollow_wound_open', 760, 350, hide_when=BOSS)
w.add('flo_hollow_wound_healing', 760, 350, show_when=BOSS)
for x, y in ((400, 400), (480, 410), (350, 380)):
    w.add('flo_corrupt_ground_light', x, y, layer='ground', hide_when=BOSS)
for x, y in ((580, 385), (640, 370), (560, 340), (680, 400)):
    w.add('flo_corrupt_ground_heavy', x, y, layer='ground', hide_when=BOSS)
for x, y in ((560, 430), (690, 300), (620, 455)):
    w.add('flo_corrupt_root_spike', x, y, hide_when=BOSS)
w.add('nat_tree_dead', 610, 260, hide_when=BOSS)
w.add('nat_tree_dead', 470, 250, hide_when=BOSS)
w.add('flo_ancient_tree_a', 110, 230, scale=.7)
w.add('flo_ancient_tree_b', 300, 170, scale=.6)
w.add('flo_ancient_tree_a', 900, 210, scale=.7, flip=True)
w.add('flo_stone_moss', 230, 440)
w.scatter(['flo_fern_patch', 'flo_glow_mushrooms', 'nat_bush_green'], 8, (20, 60, 360, 470), 44, min_d=50)
w.d['vignette'] = .35
w.shot('FLO_2D_FERIDA_PRE_BOSS', [])
w.shot('FLO_2D_FERIDA_POS_PRIMEIRA_DERROTA', [BOSS])
comps.append(w.d)

# ============================================================== LOC_FOREST_CARTOGRAPHER_SHRINE (Q_MS02_VEIL_SHRINE) + saída para o Ato III
# F5 = boss derrotado (elites:BOSS_RAIZ_OCA_001) abre o caminho; F6 = Selo Verde recuperado (quest concluída) acende o anel e projeta a segunda linha.
SEAL = 'quest:Q_MS02_VEIL_SHRINE'
c = Comp('LOC_FOREST_CARTOGRAPHER_SHRINE', 'Santuário dos Cartógrafos', (400, 120),
         'Ruína anterior aos Guardas numa clareira elevada com vista; anel de oito linhas que recebe o Selo Verde; a saída aponta para o deserto (Ato III).', tint=(.06, .13, .08, .16), slug='cartografos')
c.d['ecotone_x'] = 600                               # o solo seca rumo à saída do Ato III
c.exclude_circle(480, 340, 230)
BOSSF = 'elites:BOSS_RAIZ_OCA_001'
c.trail([(-20, 512), (160, 498), (320, 472), (430, 430)], half=18, seed=4, show_when=BOSSF)          # trilha visível só depois do boss
for x, y in ((80, 505), (200, 500), (300, 480)):                                                     # antes: caminho encoberto por raízes e mato
    c.add('flo_cart_path_covered', x, y, hide_when=BOSSF)
    c.add('flo_cart_path_open', x, y, show_when=BOSSF, layer='ground')
c.add('flo_cart_terrace', 480, 210, scale=.85)
c.add('flo_cart_ring_inert', 480, 350, scale=.8, hide_when=SEAL)
c.add('flo_cart_ring_lit', 480, 350, scale=.8, show_when=SEAL)
for x, y in ((130, 300), (830, 290)):
    c.add('flo_cart_pillar', x, y)
c.add('flo_cart_ruin_wall', 230, 240)
c.add('flo_cart_ruin_wall', 730, 250, flip=True)
c.add('flo_ancient_tree_a', 90, 130, scale=.65)
c.add('flo_ancient_tree_b', 880, 130, scale=.6, flip=True)
c.add('flo_stone_moss', 150, 420)
# ecótono para o Ato III: à direita o solo seca (grama seca, arbustos secos, dunas baixas) e o marco de saída aponta o caminho
c.trail([(540, 452), (640, 478), (760, 486), (870, 468), (980, 440)], half=17, seed=8, show_when=BOSSF)
c.add('flo_exit_marker', 900, 450, show_when=BOSSF)
for x, y in ((660, 500), (760, 440), (830, 500), (930, 420)):
    c.add('nat_bush_dry', x, y)
    c.add('nat_grass_dry', x + 30, y + 14)
c.add('nat_dune_small', 940, 380)
c.scatter(['flo_fern_patch', 'flo_glow_mushrooms', 'nat_bush_green'], 8, (20, 60, 560, 380), 55, min_d=50)
c.d['light_shafts'] = [[c.o[0] + 420, c.o[1]]]
c.shot('FLO_2E_CARTOGRAFOS_INERTE', [])
c.shot('FLO_2E_CARTOGRAFOS_CAMINHO_ABERTO', [BOSSF])
c.shot('FLO_2E_CARTOGRAFOS_SELO_ATIVO', [BOSSF, SEAL])
comps.append(c.d)

# ------------------------------------------------------------------ saída
# flags negativas: "!<flag>" em show_when/hide_when é resolvido pelo palco/Gerente como "flag ausente"
json.dump(comps, open(OUT, 'w'), ensure_ascii=False, indent=1)
OUT.write_text(OUT.read_text() + '\n')
print('composições:', len(comps), '| objetos:', sum(len(c['objects']) for c in comps), '->', OUT.relative_to(ROOT))
