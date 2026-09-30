"""Estruturas e props de masmorra a partir de assets gratuitos Kenney (CC0), adaptados ao padrão Valedouro.

Curadoria (ver docs/relatorios/remap/ETAPA4_7_RELATORIO_FINAL.md):
  * Kenney Sketch Town Expansion — é o único pacote de construções Kenney em projeção 3/4 isométrica (compatível com o
    jogo). Usadas as peças de pedra em ruína (muro arruinado, toco de torre, fim de muro), redesenhadas: redução de área,
    pedra fria -> pedra Valedouro com fiadas de tijolo, contorno escuro, paleta reduzida. Poço/trigo/telhados testados e
    REJEITADOS (ficam chapados perto das casas modeladas).
  * Kenney Tiny Dungeon — props 16 px (lápides, gárgula-fonte, bigorna, grade; espinhos e estandarte rejeitados: o estandarte
    vem colado ao tijolo do tile e os espinhos duplicariam o APPROVED dungeon_spikes) ampliados em escala
    inteira (nearest), graduados para a paleta das masmorras oficiais e com o ácido verde trocado pelo ciano do Eco.
  * Kenney Medieval RTS e Tiny Town — vista de cima/ortogonal: REJEITADOS (quebrariam a projeção 3/4 aprovada).
Saída: assets/external/structures/*.png + data/modeled_parts/external_structures.json + proveniência.
"""
import colorsys

import numpy as np
from PIL import Image

from common import LIB, LICENSE, OUT, entry, outline, record, rel, write_part

SKETCH = LIB / 'buildings' / 'kenney_sketch_town_expansion' / 'Tiles'
TINY = LIB / 'dungeons' / 'kenney_tiny_dungeon' / 'Tilemap' / 'tilemap_packed.png'
OUTS = OUT / 'structures'


def sketch_ruin(names, scale=.42, sand=False, seed=1):
    base = None
    for n in names:
        im = Image.open(SKETCH / f'{n}.png').convert('RGBA')
        base = im if base is None else Image.alpha_composite(base, im)
    im = base.crop(base.getbbox())
    im = im.resize((int(im.width * scale), int(im.height * scale)), Image.LANCZOS)
    a = np.asarray(im).astype(np.float32)
    rgb, al = a[..., :3] / 255.0, a[..., 3]
    out = rgb.copy()
    rng = np.random.default_rng(seed)
    hue, sat = (.1, .3) if sand else (.08, .12)
    H, W = al.shape
    for y in range(H):
        for x in range(W):
            if al[y, x] < 30:
                continue
            hh, ss, vv = colorsys.rgb_to_hsv(*rgb[y, x])
            if ss < .28 or .5 < hh < .72:                                   # pedra: fiadas + variação por bloco
                brick = (y % 6) == 0 or ((x + (y // 6) * 4) % 9) == 0
                v = vv * (.86 if sand else .78) * (.82 if brick else 1.0) * (1 + rng.uniform(-.06, .06))
                out[y, x] = colorsys.hsv_to_rgb(hue, sat, v)
            elif .15 < hh < .45:                                            # musgo no topo
                out[y, x] = colorsys.hsv_to_rgb(.24, .5, vv * .6 * (1 + rng.uniform(-.08, .08)))
            else:                                                           # terra/madeira
                out[y, x] = colorsys.hsv_to_rgb(.07, .5, vv * .6 * (1 + rng.uniform(-.07, .07)))
    a[..., :3] = np.clip(out * 255, 0, 255)
    a[..., 3] = np.where(al > 100, 255, 0)
    im = Image.fromarray(a.astype(np.uint8), 'RGBA')
    q = im.convert('RGB').quantize(28, dither=Image.Dither.NONE).convert('RGBA')
    q.putalpha(im.getchannel('A'))
    return outline(q, (22, 16, 20, 255))


def tiny(tiles, cols, k, eco=False, grade_to=(.62, .18)):
    """Compõe tiles do Tiny Dungeon (índices no tilemap 12x11 de 16 px) numa grade `cols` e amplia ×k (nearest)."""
    sheet = Image.open(TINY).convert('RGBA')
    rows = (len(tiles) + cols - 1) // cols
    im = Image.new('RGBA', (16 * cols, 16 * rows))
    for i, t in enumerate(tiles):
        if t is None:
            continue
        tx, ty = (t % 12) * 16, (t // 12) * 16
        im.alpha_composite(sheet.crop((tx, ty, tx + 16, ty + 16)), ((i % cols) * 16, (i // cols) * 16))
    a = np.asarray(im).astype(np.float32)
    for y in range(a.shape[0]):
        for x in range(a.shape[1]):
            if a[y, x, 3] < 10:
                continue
            hh, ss, vv = colorsys.rgb_to_hsv(*(a[y, x, :3] / 255.0))
            if .03 < hh < .13 and ss > .3 and vv > .6:                      # piso de areia do tile -> transparente (só o prop)
                a[y, x, 3] = 0
                continue
            if eco and .25 < hh < .5 and ss > .3:                           # ácido verde -> brilho ciano do Eco
                hh, ss, vv = .5, min(1, ss * 1.05), min(1, vv * 1.1)
            elif ss < .35 and .5 < hh < .75:                                # pedra azulada -> pedra das masmorras oficiais
                hh, ss, vv = grade_to[0], grade_to[1], vv * .9
            a[y, x, :3] = np.array(colorsys.hsv_to_rgb(hh, ss, vv)) * 255
    im = Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), 'RGBA')
    im = im.crop(im.getbbox())
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


def frames_strip(frames):
    w = max(f.width for f in frames)
    h = max(f.height for f in frames)
    s = Image.new('RGBA', (w * len(frames), h))
    for i, f in enumerate(frames):
        s.alpha_composite(f, (i * w + (w - f.width) // 2, h - f.height))
    return s, w, h


def main():
    OUTS.mkdir(parents=True, exist_ok=True)
    entries, prov = [], []

    def put(id, frames, tags, sources, mods, used, block=0.0, collision=None):
        strip, w, h = frames_strip(frames)
        png = OUTS / f'{id}.png'
        strip.save(png, optimize=True)
        entries.append(entry(id, png, 'dungeon' if 'dg' in id else 'nature', 'external_structures', (w, h), len(frames), (w / 2, h - 2), tags,
                             rel(sources[0]), block=block, footprint=block, collision=collision))
        prov.append({'id': id, 'category': 'estrutura' if 'ruin' in id else 'prop_masmorra', 'source_paths': [rel(s) for s in sources],
                     'license': LICENSE['kenney'], 'derived': 'game/' + png.relative_to(OUTS.parents[2]).as_posix(),
                     'modifications': mods, 'used_in': used, 'status': 'MODELED_PENDING_GATE'})

    ruin_mod = 'Sketch Town (vetorial) redesenhado em pixel art: redução de área 0,42, pedra fria -> pedra Valedouro com fiadas de tijolo e variação por bloco, musgo no topo, paleta 28 cores, contorno escuro'
    for id, names, sand in (('ext_ruin_wall_broken', ['castle_endRuined_S'], False), ('ext_ruin_wall_broken_e', ['castle_endRuined_E'], False),
                            ('ext_ruin_tower_stump', ['castle_towerBrownBase_S'], False), ('ext_ruin_wall_end', ['castle_end_W'], False),
                            ('ext_ruin_wall_broken_sand', ['castle_endRuined_W'], True), ('ext_ruin_tower_stump_sand', ['castle_towerBeigeBase_S'], True)):
        put(id, [sketch_ruin(names, sand=sand, seed=len(id))], ['ruin', 'stone', 'kenney'], [SKETCH / f'{n}.png' for n in names],
            ruin_mod + ('; matiz de arenito' if sand else ''), 'perímetro arruinado das Ruínas do Primeiro Vento / das Dunas (exploração)', block=16.0,
            collision=[[0.0, 0.0, 14.0]])
    tmod = 'Tiny Dungeon 16 px ampliado em escala inteira (nearest), pedra azulada -> pedra das masmorras oficiais'
    put('ext_dg_tomb_cross', [tiny([64], 1, 3)], ['grave'], [TINY], tmod, 'cripta (Galeria Antiga): lápides do ossuário', block=9.0)
    put('ext_dg_tombstone', [tiny([65], 1, 3)], ['grave'], [TINY], tmod, 'cripta (Galeria Antiga): lápides do ossuário', block=9.0)
    put('ext_dg_iron_fence', [tiny([76, 77], 2, 3)], ['fence'], [TINY], tmod, 'cripta: grade que separa o ossuário', block=10.0)
    put('ext_dg_anvil_old', [tiny([74], 1, 3)], ['anvil'], [TINY], tmod, 'Mina do Eco zona 1: bigorna dos mineiros', block=10.0)
    still = tiny([7, 19, 31], 1, 2, eco=True)
    drip = tiny([8, 20, 32], 1, 2, eco=True)
    put('ext_dg_gargoyle_eco', [still, still, drip, drip], ['fountain', 'eco'], [TINY],
        tmod + '; 3 tiles empilhados (cabeça/rosto/bacia) em 2 estados -> animação de 4 quadros; ácido verde -> Eco ciano',
        'Mina do Eco zona 2 e cripta: gárgula que verte Eco', block=12.0)
    write_part('external_structures', entries)
    record(prov)
    print('estruturas:', [e['id'] for e in entries])


if __name__ == '__main__':
    main()
