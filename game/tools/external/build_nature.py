"""Vegetação/rochas Karsiori (CC0) integradas ao jogo: curadoria + graduação Valedouro + contorno + ×3 nearest (densidade única).
Saída: game/assets/external/nature/<id>.png, data/modeled_parts/external_nature.json, proveniência."""
import glob
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import *  # noqa

K = 3
KAR = LIB / 'karsiori'
TP = KAR / 'tree_pack' / 'Pixel Art Tree Pack'
SP = KAR / 'spruce_tree_animated' / 'Pixel Art Spruce Tree Pack'
BP = KAR / 'bush_pack' / 'Pixel Art Bush Pack'
FP = KAR / 'flower_pack' / 'Pixel Art Flower Pack'
RP = KAR / 'rock_pile_pack' / 'Pixel Art Rock Pile Pack'
DST = OUT / 'nature'


def one(folder, pat):
    g = sorted(glob.glob(str(folder / pat)))
    assert g, (folder, pat)
    return g[0]


GREEN_H = 105 / 360.0
# id, fonte, grade kwargs, uso, tags, raio de colisão (px de jogo)
TREES = [
    ('ext_tree_oak_cloud', one(TP / 'Tree 2', '*_GREEN.png'), dict(hue_to=GREEN_H, hue_pull=.15), 'Floresta/Campos/cidade (carvalho em nuvem)', ('carvalho',), 14),
    ('ext_tree_oak_cloud_teal', one(TP / 'Tree 2', '*_TEAL.png'), dict(), 'Floresta Ancestral/vale úmido', ('carvalho', 'teal'), 14),
    ('ext_tree_oak_cloud_sandy', one(TP / 'Tree 2', '*_SANDY GREEN.png'), dict(), 'Colinas/pradaria', ('carvalho', 'seco'), 14),
    ('ext_tree_dense', one(TP / 'Tree 6', '*_GREEN.png'), dict(hue_to=GREEN_H, hue_pull=.1), 'Floresta (árvore alta densa)', ('alta', 'floresta'), 13),
    ('ext_tree_dense_teal', one(TP / 'Tree 6', '*_TEAL.png'), dict(), 'Floresta profunda', ('alta', 'teal'), 13),
    ('ext_tree_round', one(TP / 'Tree 9', '*GREEN.png'), dict(hue_to=GREEN_H, hue_pull=.2, sat=.8), 'Campos/vale (copa redonda clara)', ('redonda',), 12),
    ('ext_tree_autumn', one(TP / 'Tree 15', '*_ORANGE.png'), dict(sat=.92), 'Vale/cidade (outono)', ('outono',), 14),
    ('ext_tree_autumn_red', one(TP / 'Tree 15', '*_RED.png'), dict(sat=.9), 'Vale (outono rubro)', ('outono',), 14),
    ('ext_tree_umbrella', one(TP / 'Tree 1', '*_SANDY GREEN.png'), dict(sat=.9, warm=.6), 'Colinas secas/borda do deserto', ('guarda_chuva', 'seco'), 11),
    ('ext_tree_flat', one(TP / 'Tree 5', '*_GREEN.png'), dict(hue_to=GREEN_H, hue_pull=.15), 'Vale (copa achatada)', ('achatada',), 12),
    ('ext_tree_lollipop', one(TP / 'Tree 4', '*YEL*.png'), dict(sat=.9), 'Bosque claro/vale', ('pirulito',), 9),
    ('ext_tree_small', one(TP / 'Tree 8', '*_GREEN.png'), dict(hue_to=GREEN_H, hue_pull=.2, sat=.82), 'Bordas/ecótonos (árvore jovem)', ('jovem',), 9),
]
SPRUCES = [
    ('ext_spruce_large', 'Large Spruce Tree', 'GREEN', 'Floresta/encostas (spruce animado ao vento)', 12),
    ('ext_spruce_thick', 'Thick Spruce Tree', 'GREEN', 'Floresta/pinhais', 12),
    ('ext_spruce_slim', 'Slim Spruce Tree', 'GREEN_TEAL', 'Transição floresta→gelo', 10),
    ('ext_spruce_cold', 'Large Spruce Tree', 'COLD', 'Montanhas nevadas (spruce frio)', 12),
    ('ext_spruce_thick_cold', 'Thick Spruce Tree', 'COLD', 'Montanhas nevadas', 12),
    ('ext_pine_bubble', 'Bubble Pine Tree', 'GREEN', 'Colinas/pinhal jovem', 10),
]
BUSHES = [('ext_bush_leafy', 'Bush 14', 'GREEN'), ('ext_bush_leafy_small', 'Bush 12', 'GREEN'), ('ext_bush_grass_big', 'Bush 3', 'GREEN'),
          ('ext_bush_grass_wide', 'Bush 1', 'GREEN'), ('ext_bush_fern', 'Bush 5', 'GREEN'), ('ext_bush_hedge', 'Bush 13', 'GREEN'),
          ('ext_bush_leafy_teal', 'Bush 14', 'TEAL'), ('ext_bush_grass_dry', 'Bush 3', 'YELLOW'), ('ext_bush_fern_dry', 'Bush 5', 'YELLOW'),
          ('ext_bush_grass_red', 'Bush 1', 'RED')]
FLOWERS = [('ext_flower_blue', 'Flower 1', 'BLUE'), ('ext_flower_yellow', 'Flower 1', 'YELLOW'), ('ext_flower_daisy', 'Flower 11', 'PINK'),
           ('ext_flower_orchid', 'Flower 3', 'PURPLE'), ('ext_flower_wild', 'Flower 4', 'PINK'), ('ext_flower_sun', 'Flower 9', 'YELLOW'),
           ('ext_flower_pot_colorful', 'Flower Pot 2', 'COLORFUL'), ('ext_flower_pot_purple', 'Flower Pot 5', 'PURPLE'), ('ext_flower_pot_orange', 'Flower Pot 6', 'ORANGE')]
ROCKS = [('ext_rock_mossy_a', 6, 'MOSSY', 'BIG'), ('ext_rock_mossy_b', 7, 'MOSSY', 'BIG'), ('ext_rock_mossy_c', 3, 'MOSSY', 'BIG'), ('ext_rock_mossy_d', 2, 'MOSSY', 'BIG'),
         ('ext_rock_mossy_small', 10, 'MOSSY', 'small'), ('ext_rock_silver_a', 6, 'SILVER', 'BIG'), ('ext_rock_silver_b', 13, 'SILVER', 'BIG'),
         ('ext_rock_white_a', 7, 'WHITE', 'BIG'), ('ext_rock_beige_a', 6, 'BEIGE', 'BIG'), ('ext_rock_beige_b', 3, 'BEIGE', 'BIG'), ('ext_rock_beige_small', 10, 'BEIGE', 'small')]


def adapt(src, gk, oc=(14, 22, 14, 255), k=K):
    im = grade(load(src), **gk)
    return up(outline(pad(im, 2), oc), k)


def main():
    DST.mkdir(parents=True, exist_ok=True)
    entries, prov = [], []

    def add(id, img, frames, tags, use, srcs, block, coll, mods, group='nature', folder='external_nature'):
        png = DST / f'{id}.png'
        img.save(png, optimize=True)
        fw = img.width // frames
        fx, fy = foot_of(img.crop((0, 0, fw, img.height)))
        entries.append(entry(id, png, group, folder, (fw, img.height), frames, (fx, fy), ('externo_adaptado',) + tuple(tags),
                             rel(srcs[0]), block=block, footprint=block, collision=[[0.0, 0.0, float(coll)]] if coll else None))
        prov.append({'id': id, 'category': 'vegetacao' if 'rock' not in id else 'rocha', 'source_paths': [rel(s) for s in srcs], 'license': LICENSE['karsiori'],
                     'derived': 'game/' + png.relative_to(GAME).as_posix(), 'modifications': mods, 'used_in': use, 'status': 'MODELED_PENDING_GATE'})

    base_mods = 'graduação de cor para a paleta Valedouro (saturação/sombra/matiz), contorno escuro 1px de arte, escala inteira nearest por categoria (árvores ×3, spruces/arbustos/flores/rochas ×2, vasos ×1), pé/colisão/sombra projetada do renderer'
    for id, src, gk, use, tags, coll in TREES:
        add(id, adapt(src, gk), 1, ('arvore',) + tags, use, [src], 0.0, coll, base_mods)
    for id, name, pal, use, coll in SPRUCES:
        frames = sorted(glob.glob(str(SP / name / pal / 'Sprites' / '*.png')))
        pick = frames[::max(1, len(frames) // 8)][:8]
        gk = dict(sat=.85, val=.95) if pal != 'COLD' else dict(sat=.8, val=1.0)
        ims = [adapt(f, gk, k=2) for f in pick]
        w, h = max(i.width for i in ims), max(i.height for i in ims)
        strip = Image.new('RGBA', (w * len(ims), h))
        for k, i in enumerate(ims):
            strip.paste(i, (k * w + (w - i.width) // 2, h - i.height))
        add(id, strip, len(ims), ('arvore', 'spruce', 'animado', pal.lower()), use, pick, 0.0, coll,
            base_mods + '; animação de vento preservada (%d de %d quadros, loop)' % (len(pick), len(frames)))
    for id, name, pal in BUSHES:
        src = one(BP / name, f'*_{pal}.png')
        add(id, adapt(src, dict(hue_to=GREEN_H, hue_pull=.1) if pal == 'GREEN' else dict(sat=.9), k=2), 1, ('arbusto',), 'vegetação de chão por bioma', [src], 0.0, None, base_mods)
    for id, name, pal in FLOWERS:
        src = one(FP / name, f'* - {pal}.png')
        add(id, adapt(src, dict(sat=.92), k=1 if 'pot' in id else 2), 1, ('flor',) + (('vaso', 'cidade') if 'pot' in id else ()), 'campos/vale; vasos nas casas da cidade' if 'pot' in id else 'campos, vale, clareiras', [src], 0.0, None, base_mods)
    for id, n, pal, size in ROCKS:
        src = one(RP / f'Rock Pile - {pal} -', f'Rock Pile {n} - {pal} - {size}.PNG')
        img = adapt(src, dict(sat=.9), oc=(20, 20, 22, 255), k=2)
        blk = 11.0 if size == 'BIG' else 0.0
        add(id, img, 1, ('rocha', pal.lower()), {'MOSSY': 'floresta/vale', 'SILVER': 'gelo/montanha', 'WHITE': 'gelo', 'BEIGE': 'deserto/colinas'}[pal], [src], blk, 10 if size == 'BIG' else None, base_mods)
    write_part('external_nature', entries)
    record(prov)
    print('external_nature:', len(entries), 'assets')


if __name__ == '__main__':
    main()
