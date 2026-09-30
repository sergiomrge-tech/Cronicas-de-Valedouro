"""Personagens animados Foozle (CC0) adaptados a Valedouro — herói, mobs, elites e bosses.
Animações PRESERVADAS (quadros originais reamostrados para 8 por estado); aparência redesenhada por facção via remapeamento
de paleta (matiz/saturação/valor por faixa) e VFX embutido do golpe tingido pela cor da facção.
Saídas:
  game/assets/hero_*.png (contrato 864x448: 8 direções × [8 caminhada + 10 ataque], quadro 48x56) + hero_extra_<tier>.png (idle/hurt/death)
  game/assets/external/mobs/<id>.png (8 colunas × (estados × 3 direções), quadro 48 ou 64) + data/external_mobs.json
  boss_full.png (contrato 512x320) regenerado a partir do Skeleton King (Guardião do Eco)."""
import colorsys
import glob
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import GAME, LIB, LICENSE, rel, record  # noqa

AM = LIB / 'animated_monsters'
AC = LIB / 'animated_characters'
OUTM = GAME / 'assets' / 'external' / 'mobs'


def sheet(base, direction, state):
    pats = [f'{base}/**/{direction}/**/*{direction}{s}.png' for s in (state if isinstance(state, tuple) else (state,))]
    for p in pats:
        g = sorted(glob.glob(str(p), recursive=True))
        if g:
            return g[0]
    raise SystemExit('sem folha %s %s %s' % (base, direction, state))


def frames_of(path):
    im = Image.open(path).convert('RGBA')
    h = im.height
    n = max(1, im.width // h)
    return [im.crop((i * h, 0, i * h + h, h)) for i in range(n)], path


def resample(frames, n=8, hold_last=False):
    idx = np.round(np.linspace(0, len(frames) - 1, n)).astype(int)
    return [frames[i] for i in idx]


def fit(fr, cell):
    """Centraliza o quadro (w=h) numa célula quadrada `cell`, alinhado pelo pé (base)."""
    c = Image.new('RGBA', (cell, cell))
    c.paste(fr, ((cell - fr.width) // 2, cell - fr.height), fr)
    return c


def recolor(im, rules, slash=None, dark_boost=0.0):
    """rules: [(h0, h1, smin, dh_or_target, sat_mul, val_mul)] em graus; primeira regra que casa vence.
    slash: cor RGB para os pixels brancos puros (crescente do golpe/impacto embutidos na animação)."""
    a = np.asarray(im).copy()
    cache = {}
    ys, xs = np.nonzero(a[..., 3] > 0)
    for y, x in zip(ys, xs):
        k = tuple(a[y, x, :3])
        if k not in cache:
            r, g, b = [v / 255.0 for v in k]
            if slash is not None and r > .97 and g > .97 and b > .97:
                cache[k] = slash
            else:
                hh, ss, vv = colorsys.rgb_to_hsv(r, g, b)
                deg = hh * 360
                for h0, h1, smin, tgt, sm, vm in rules:
                    if ss >= smin and (h0 <= deg <= h1 or (h0 > h1 and (deg >= h0 or deg <= h1))):
                        if isinstance(tgt, tuple):
                            hh = tgt[0] / 360.0
                            ss = tgt[1] if len(tgt) > 1 else ss
                        else:
                            hh = ((deg + tgt) % 360) / 360.0
                        ss, vv = min(1, ss * sm), min(1, vv * vm)
                        break
                if vv < .25:
                    vv = max(0.0, vv * (1 - dark_boost))
                cache[k] = tuple(int(c * 255) for c in colorsys.hsv_to_rgb(hh, ss, vv))
        a[y, x, :3] = cache[k]
    return Image.fromarray(a, 'RGBA')


ANY = (0, 360)
GREY = 0.0  # smin=0 casa cinzas

# ------------------------------------------------------------------ facções (aparência Valedouro)
MOBS = [
    # id, nome no jogo, pasta, estados (idle, walk, attack, hurt, death), regras de cor, cor do golpe, célula, usos/facção
    ('mob_goblin_saqueador', 'Goblin Saqueador', 'foozle_goblin_berserker', ('Idle', ('Run', 'Walk'), 'Attack01', 'Hurt', 'Death'),
     [(60, 170, .15, 8, .85, .95), (15, 55, .2, 0, .9, 1.0)], (230, 214, 170), 48, 'Saqueadores da Fronteira — floresta/colinas (Estrada Norte)'),
    ('mob_goblin_fundeiro', 'Goblin Fundeiro', 'foozle_goblin_slinger', ('Idle', ('Run', 'Walk'), 'Attack01', 'Hurt', 'Death'),
     [(60, 170, .15, -10, .8, .95), (15, 55, .2, (28, .55), 1.0, 1.0)], (230, 214, 170), 48, 'Saqueadores da Fronteira — atiradores (colinas/campos)'),
    ('mob_esqueleto_eco', 'Esqueleto do Eco', 'foozle_skeleton_grunt', ('Idle', ('Walk', 'Run'), 'Attack01', 'Hurt', 'Death'),
     [(330, 30, .3, (186, .7), 1.0, 1.1), (160, 230, 0.0, (195,), 1.0, 1.0), (0, 360, 0.0, 0, .9, .95)], (120, 230, 240), 48, 'mineiros mortos reanimados pelo Eco — Mina do Eco/Cripta'),
    ('mob_arqueiro_ossudo', 'Arqueiro Ossudo', 'foozle_skeleton_hunter', ('Idle', ('Walk', 'Run'), 'Attack01', 'Hurt', 'Death'),
     [(330, 30, .3, (186, .7), 1.0, 1.1), (160, 230, 0.0, (195,), 1.0, 1.0), (0, 360, 0.0, 0, .9, .95)], (120, 230, 240), 48, 'Mina do Eco/Cripta — atirador'),
    ('mob_cultista_coroa', 'Cultista da Coroa Oca', 'foozle_cultist', ('Idle', ('Walk', 'Run'), 'Attack01', 'Hurt', 'Death'),
     [(35, 65, .25, (292, .45), 1.0, .8), (330, 20, .4, (300, .8), 1.0, 1.0)], (200, 120, 255), 48, 'agentes da Coroa Oca — vale (Santuário/Mina), ruínas'),
    ('mob_possesso_eco', 'Possesso do Eco', 'foozle_possessed', ('Idle', ('Walk', 'Run'), 'Attack01', 'Hurt', 'Death'),
     [(330, 20, .35, (178, .75), 1.0, 1.1)], (120, 240, 220), 48, 'aldeões tomados pelo Eco — vale/ruínas/deserto'),
    ('mob_brutamontes_goblin', 'Brutamontes Goblin', 'foozle_goblin_beast_boss', ('Idle', ('Walk', 'Run'), 'Attack01', 'Hurt', 'Death', 'Attack03', 'Jump'),
     [(60, 170, .15, 10, .85, .95)], (255, 190, 120), 64, 'elite/chefe dos Saqueadores — acampamento das colinas'),
    ('mob_guardiao_eco', 'Guardião', 'foozle_skeleton_king_boss', ('Idle', ('Walk', 'Run'), 'Attack01', 'Hurt', 'Death', 'Attack03', 'Jump'),
     [(35, 65, .2, (205, .25), 1.0, .95), (250, 320, .15, (215, .35), 1.0, .75), (330, 20, .4, (186, .9), 1.0, 1.2)], (110, 230, 255), 64, 'Guardião do Eco — boss da Mina do Eco (Ato I)'),
]
STATES = ('idle', 'walk', 'attack', 'hurt', 'death', 'special', 'windup')
DIRS = ('Right', 'Down', 'Up')


def build_mob(spec):
    id, name, folder, states, rules, slash, cell, use = spec
    base = AM / folder
    rows, srcs = [], []
    for st in states:
        for d in DIRS:
            frs, src = frames_of(sheet(base, d, st))
            srcs.append(src)
            frs = resample(frs, 8)
            rows.append([recolor(fit(f, cell), rules, slash) for f in frs])
    out = Image.new('RGBA', (cell * 8, cell * len(rows)))
    for r, frs in enumerate(rows):
        for c, f in enumerate(frs):
            out.paste(f, (c * cell, r * cell))
    OUTM.mkdir(parents=True, exist_ok=True)
    png = OUTM / f'{id}.png'
    out.save(png, optimize=True)
    return {'id': id, 'kind': name, 'path': 'res://' + png.relative_to(GAME).as_posix(), 'cell': cell, 'scale': 2.0,
            'states': list(STATES[:len(states)]), 'dirs': ['side', 'down', 'up'], 'frames': 8}, srcs, png, use


# ------------------------------------------------------------------ herói
HERO_RULES = [(100, 170, .15, (218, .55), 1.0, 1.15),       # verdes do traje -> túnica azul do protagonista
              (25, 60, .2, (12, .75), 1.0, 1.1)]            # couro -> capa/cinto vermelho-ferrugem
ARMOR_TINT = {0: None, 1: ('couro', (28, .45), .95), 2: ('ferro', (210, .12), 1.0), 3: ('aço-azul', (212, .35), 1.12), 4: ('ouro', (44, .6), 1.15)}
DIR_MAP = ['Down', 'Right', 'Right', 'Right', 'Up', 'Left', 'Left', 'Left']   # 0 baixo,1 baixo-dir,2 dir,3 cima-dir,4 cima,5 cima-esq,6 esq,7 baixo-esq


def armor(im, tier):
    if not ARMOR_TINT.get(tier):
        return im
    _, (h, s), vm = ARMOR_TINT[tier]
    return recolor(im, [(0, 360, 0.0, (h, s), 1.0, vm)] if tier != 2 else [(0, 360, 0.0, (h, s), 1.0, vm)], None) if False else _tint_greys(im, h, s, vm)


def _tint_greys(im, h, s, vm):
    """Tinge SÓ os cinzas (armadura/elmo/lâmina) para o material do tier; cores do traje ficam."""
    a = np.asarray(im).copy()
    ys, xs = np.nonzero(a[..., 3] > 0)
    cache = {}
    for y, x in zip(ys, xs):
        k = tuple(a[y, x, :3])
        if k not in cache:
            r, g, b = [v / 255.0 for v in k]
            hh, ss, vv = colorsys.rgb_to_hsv(r, g, b)
            if ss < .18 and .2 < vv < .97:
                cache[k] = tuple(int(c * 255) for c in colorsys.hsv_to_rgb(h / 360.0, s, min(1, vv * vm)))
            else:
                cache[k] = k
        a[y, x, :3] = cache[k]
    return Image.fromarray(a, 'RGBA')


def hair(fr):
    """Identidade do protagonista: o topo do elmo (primeiras linhas da cabeça, tons de cinza) vira CABELO RUIVO espetado."""
    a = np.asarray(fr).copy()
    op = a[..., 3] > 0
    body = op & ~((a[..., 0] > 247) & (a[..., 1] > 247) & (a[..., 2] > 247))
    rows = np.nonzero(body.any(axis=1))[0]
    if len(rows) == 0:
        return fr
    top = rows.min()
    HAIR = [(92, 34, 18), (170, 70, 28), (224, 116, 46), (246, 168, 86)]
    for y in range(top, min(top + 8, a.shape[0])):
        for x in np.nonzero(body[y])[0]:
            r, g, b = [int(v) for v in a[y, x, :3]]
            if abs(r - g) < 14 and abs(g - b) < 14:
                v = (r + g + b) / 3
                a[y, x, :3] = HAIR[0 if v < 30 else 1 if v < 80 else 2 if v < 130 else 3]
        if y == top:                                     # mechas espetadas acima do contorno
            xs = np.nonzero(body[y])[0]
            for x in xs[::3]:
                if y - 1 >= 0:
                    a[y - 1, x] = (170, 70, 28, 255)
    return Image.fromarray(a, 'RGBA')


def cell56(fr):
    c = Image.new('RGBA', (48, 56))
    c.paste(hair(fr), (0, 8), hair(fr))
    return c


def hero():
    base = AC / 'foozle_lucifer_warrior'
    srcs = []

    def get(d, st, n):
        frs, src = frames_of(sheet(base, d, st))
        srcs.append(src)
        return resample(frs, n)

    grid = {}
    for r, d in enumerate(DIR_MAP):
        walk = get(d, 'Walk', 8)
        a1, _ = frames_of(sheet(base, d, 'Attack01'))
        a2, _ = frames_of(sheet(base, d, 'Attack02'))
        atk = resample(a1 + a2, 10)
        idle = get(d, 'Idle', 6)
        hurt = get(d, 'Hurt', 4)
        death = get(d, 'Death', 8)
        grid[r] = (walk + atk, idle + hurt + death)
    for tier in range(0, 5):
        main = Image.new('RGBA', (864, 448))
        extra = Image.new('RGBA', (864, 448))
        for r, (m, e) in grid.items():
            for c, f in enumerate(m):
                main.paste(armor(recolor(cell56(f), HERO_RULES, slash=(255, 255, 255)), tier), (c * 48, r * 56))
            for c, f in enumerate(e):
                extra.paste(armor(recolor(cell56(f), HERO_RULES, slash=(255, 255, 255)), tier), (c * 48, r * 56))
        main.save(GAME / 'assets' / ('hero_body.png' if tier == 0 else f'hero_armor_{tier}.png'), optimize=True)
        extra.save(GAME / 'assets' / f'hero_extra_{tier}.png', optimize=True)
    # camadas de arma: o golpe (crescente branco embutido) e o cabo recebem a cor do tier; arco/cajado = sprite na mão
    body = Image.open(GAME / 'assets' / 'hero_body.png').convert('RGBA')
    ba = np.asarray(body)
    white = (ba[..., 0] > 247) & (ba[..., 1] > 247) & (ba[..., 2] > 247) & (ba[..., 3] > 0)
    grip = (np.abs(ba[..., 0].astype(int) - 131) < 3) & (np.abs(ba[..., 1].astype(int) - 107) < 3) | \
           (np.abs(ba[..., 0].astype(int) - 99) < 3) & (np.abs(ba[..., 1].astype(int) - 73) < 3)
    TIERC = {0: ((236, 236, 236), (120, 90, 60)), 1: ((200, 225, 255), (140, 110, 70)), 2: ((255, 214, 110), (200, 150, 40)), 3: ((120, 245, 255), (60, 170, 200))}
    for tier, (sc, gc) in TIERC.items():
        a = np.zeros_like(ba)
        a[white] = list(sc) + [235]
        a[grip] = list(gc) + [255]
        Image.fromarray(a, 'RGBA').save(GAME / 'assets' / f'hero_sword_{tier}.png', optimize=True)
    icons = weapon_icons()
    ys, xs = np.nonzero(grip)
    hand = {}
    for y, x in zip(ys, xs):
        k = (x // 48, y // 56)
        hand.setdefault(k, []).append((x % 48, y % 56))
    for fam in ('bow', 'staff'):
        for tier in range(4):
            out = Image.new('RGBA', (864, 448))
            ic = icons[fam][tier]
            for (c, r), pts in hand.items():
                hx = int(sum(p[0] for p in pts) / len(pts))
                hy = int(sum(p[1] for p in pts) / len(pts))
                out.paste(ic, (c * 48 + hx - ic.width // 2, r * 56 + hy - ic.height // 2), ic)
            if fam == 'staff' and tier >= 1:
                pass
            out.save(GAME / 'assets' / f'hero_{fam}_{tier}.png', optimize=True)
    return srcs


def weapon_icons():
    """Arco/cajado na mão do herói a partir dos ícones Osare (CC0), reduzidos a 16 px."""
    d = LIB / 'equipment' / 'oga_osare_weapon_icons' / 'valmis_unpacked' / 'Valmis'
    names = {'bow': ['slingshot', 'shortbow', 'longbow', 'greatbow'], 'staff': ['wand', 'rod', 'staff', 'greatstaff']}
    out = {'bow': [], 'staff': []}
    for fam in out:
        for tier in range(4):
            im = Image.open(d / f'{names[fam][tier]}.png').convert('RGBA')
            bb = im.getbbox() or (0, 0, im.width, im.height)
            im = im.crop(bb)
            s = 16.0 / max(im.size)
            im = im.resize((max(1, int(im.width * s)), max(1, int(im.height * s))), Image.NEAREST)
            out[fam].append(im)
    return out


def boss_contract(meta):
    """boss_full.png (512x320 = 8×64 × 5 linhas) — contrato legado; regenerado do Guardião do Eco (visão lateral)."""
    src = Image.open(GAME / meta['path'][6:]).convert('RGBA')
    out = Image.new('RGBA', (512, 320))
    for st in range(5):
        row = src.crop((0, (st * 3) * 64, 512, (st * 3) * 64 + 64))
        out.paste(row, (0, st * 64))
    out.save(GAME / 'assets' / 'boss_full.png', optimize=True)


# chefe/elite lidos à distância: o Guardião domina a arena e o Brutamontes (×1,25 de elite no runtime) supera o herói
BIG_SCALE = {'mob_brutamontes_goblin': 2.4, 'mob_guardiao_eco': 3.2}


def main():
    metas, prov = [], []
    for spec in MOBS:
        meta, srcs, png, use = build_mob(spec)
        meta['scale'] = BIG_SCALE.get(meta['id'], meta['scale'])
        metas.append(meta)
        prov.append({'id': meta['id'], 'category': 'monstro' if 'guardiao' not in meta['id'] and 'brutamontes' not in meta['id'] else 'boss/elite',
                     'source_paths': sorted({rel(Path(s).parent.parent.parent) for s in srcs}), 'license': LICENSE['foozle'],
                     'derived': 'game/' + png.relative_to(GAME).as_posix(),
                     'modifications': 'animações originais preservadas (idle/andar/ataque/dano/morte%s, 3 direções: lado/baixo/cima) reamostradas p/ 8 quadros; paleta redesenhada para a facção Valedouro; crescente do golpe tingida; escala ×%s no jogo (nearest)' % ('/especial/preparação' if len(meta['states']) > 5 else '', meta['scale']),
                     'used_in': spec[-1], 'status': 'MODELED_PENDING_GATE'})
        if meta['id'] == 'mob_guardiao_eco':
            boss_contract(meta)
    (GAME / 'data' / 'external_mobs.json').write_text(json.dumps({'note': 'mobs animados Foozle adaptados (tools/external/build_characters.py)', 'mobs': metas}, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
    hs = hero()
    prov.append({'id': 'hero_body', 'category': 'heroi', 'source_paths': sorted({rel(Path(s).parent.parent.parent) for s in hs}), 'license': LICENSE['foozle'],
                 'derived': 'game/assets/hero_body.png, hero_armor_1..4.png, hero_extra_0..4.png, hero_sword_0..3.png',
                 'modifications': 'Foozle Lucifer Warrior como base de animação (andar 8, ataque combo A01+A02 10, idle 6, dano 4, morte 8) em 8 direções; traje recolorido para a identidade do protagonista (túnica azul, capa ferrugem); tiers de armadura = material da armadura (couro/ferro/aço-azul/ouro); tier da espada tinge o golpe e o cabo; contrato 864x448 preservado',
                 'used_in': 'protagonista (todas as zonas)', 'status': 'MODELED_PENDING_GATE'})
    prov.append({'id': 'hero_bow_staff', 'category': 'heroi', 'source_paths': [rel(LIB / 'equipment' / 'oga_osare_weapon_icons')], 'license': LICENSE['oga'],
                 'derived': 'game/assets/hero_bow_0..3.png, hero_staff_0..3.png', 'modifications': 'ícones Osare reduzidos a 16px e ancorados na mão do herói em cada quadro', 'used_in': 'herói com arco/cajado', 'status': 'MODELED_PENDING_GATE'})
    record(prov)
    print('mobs:', [m['id'] for m in metas])


if __name__ == '__main__':
    main()
