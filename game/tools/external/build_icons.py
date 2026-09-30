"""Ícones de inventário/loot a partir de assets gratuitos (CC0), no padrão Valedouro.

Armas e armaduras: OSARE weapon icons (mesmo set que já vai na mão do herói para arco/cajado) — uma família coerente.
Materiais: "Magic/Skill/Item icons" (OpenGameArt), variantes de cor escolhidas pela origem do material.
Adaptação: fundo preto do original trocado pelo roxo-escuro do HUD, redução de área para 28 px, paleta reduzida (leitura
pixel-art), moldura de 2 px na cor do tier (cinza/verde/âmbar/gelo/ouro). Saída: assets/external/icons/*.png (32x32) +
data/external_icons.json (id -> caminho) + proveniência.
"""
import json
import sys

import numpy as np
from PIL import Image

from common import GAME, LIB, LICENSE, OUT, rel, record

OSARE = LIB / 'equipment' / 'oga_osare_weapon_icons' / 'valmis_unpacked' / 'Valmis'
MAGIC = LIB / 'equipment' / 'oga_magic_skill_item_icons' / '64x64_unpacked' / '64x64'
OUTI = OUT / 'icons'
HUD_BG = (26, 16, 34)
TIER = {0: (132, 124, 118), 1: (104, 164, 82), 2: (222, 158, 64), 3: (126, 196, 232), 4: (240, 206, 92)}

# (id, arquivo-fonte, tier da moldura, matiz de destaque opcional (r,g,b, força) aplicado só nas partes metálicas claras)
EQUIP = [
    ('icon_equip_sword_0', OSARE / 'shortsword.png', 0, None),
    ('icon_equip_sword_1', OSARE / 'longsword.png', 1, None),
    ('icon_equip_sword_2', OSARE / 'greatsword.png', 2, (240, 170, 70, .35)),
    ('icon_equip_sword_3', OSARE / 'longsword.png', 3, (150, 210, 255, .55)),
    ('icon_equip_bow_0', OSARE / 'slingshot.png', 0, None),
    ('icon_equip_bow_1', OSARE / 'shortbow.png', 1, None),
    ('icon_equip_bow_2', OSARE / 'longbow.png', 2, (240, 190, 90, .3)),
    ('icon_equip_bow_3', OSARE / 'greatbow.png', 3, (150, 210, 255, .45)),
    ('icon_equip_staff_0', OSARE / 'wand.png', 0, None),
    ('icon_equip_staff_1', OSARE / 'staff.png', 1, None),
    ('icon_equip_staff_2', OSARE / 'rod.png', 2, None),
    ('icon_equip_staff_3', OSARE / 'greatstaff.png', 3, None),
    ('icon_equip_armor_1', OSARE / 'leather_armor.png', 1, None),
    ('icon_equip_armor_2', OSARE / 'steel_armor.png', 2, (200, 110, 60, .8)),
    ('icon_equip_armor_3', OSARE / 'steel_armor.png', 3, (150, 210, 255, .5)),
    ('icon_equip_armor_4', OSARE / 'steel_armor.png', 4, (255, 226, 90, .85)),
]
# material -> (arquivo, tier da moldura) — a escolha segue a origem (lobo = couro, limo = gota, Eco = lua/cristal ...)
MATERIALS = {
    'Couro de lobo': ('Shirt Original.png', 1),
    'Núcleo de limo': ('Potion 2 Mod 1.png', 1),
    'Seda sombria': ('Rip Mod 5.png', 1),
    'Presa musgosa': ('Sharp Mod 4.png', 1),
    'Seiva voraz': ('Leafs 1 Original.png', 1),
    'Minério bruto': ('Moon Mod 7.png', 1),
    'Quitina âmbar': ('Sharp Mod 7.png', 2),
    'Casco de âmbar': ('Shield Mod 2.png', 2),
    'Cristal gelado': ('Water Drop 1 Original.png', 3),
    'Coração de geada': ('Water Drop Original.png', 3),
    'Fragmento de Eco': ('Jewel Original.png', 3),
}
SLUG = {'Couro de lobo': 'couro_lobo', 'Núcleo de limo': 'nucleo_limo', 'Seda sombria': 'seda_sombria', 'Presa musgosa': 'presa_musgosa',
        'Seiva voraz': 'seiva_voraz', 'Minério bruto': 'minerio_bruto', 'Quitina âmbar': 'quitina_ambar', 'Casco de âmbar': 'casco_ambar',
        'Cristal gelado': 'cristal_gelado', 'Coração de geada': 'coracao_geada', 'Fragmento de Eco': 'fragmento_eco'}


def adapt(src, tier, tint=None, key_black=True):
    im = Image.open(src).convert('RGBA')
    a = np.asarray(im, dtype=np.float32)
    rgb = a[..., :3]
    lum = rgb.mean(axis=2)
    if tint is not None:
        r, g, b, k = tint
        metal = (lum > 110) & (rgb.max(axis=2) - rgb.min(axis=2) < 60)          # só o metal claro/neutro recebe o matiz do tier
        w = (k * metal)[..., None]
        rgb = rgb * (1 - w) + (rgb * np.array([r, g, b]) / 200.0) * w
    if key_black:
        bgw = np.clip((40 - lum) / 40, 0, 1)[..., None]                       # fundo preto do OSARE -> roxo-escuro do HUD
        rgb = rgb * (1 - bgw) + np.array(HUD_BG) * bgw
    a[..., :3] = np.clip(rgb, 0, 255)
    a[..., 3] = 255
    im = Image.fromarray(a.astype(np.uint8), 'RGBA').resize((28, 28), Image.LANCZOS)
    im = im.convert('RGB').quantize(40, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert('RGBA')
    out = Image.new('RGBA', (32, 32), (12, 8, 16, 255))
    fr = TIER[tier]
    for i in range(1, 31):
        for j in (1, 30):
            out.putpixel((i, j), fr + (255,))
            out.putpixel((j, i), fr + (255,))
    out.paste(im, (2, 2))
    return out


def main():
    OUTI.mkdir(parents=True, exist_ok=True)
    table, prov = {}, []
    for id, src, tier, tint in EQUIP:
        png = OUTI / f'{id}.png'
        adapt(src, tier, tint).save(png, optimize=True)
        table[id] = 'res://' + png.relative_to(GAME).as_posix()
        prov.append({'id': id, 'category': 'icone_equipamento', 'source_paths': [rel(src)], 'license': LICENSE['oga'],
                     'derived': 'game/' + png.relative_to(GAME).as_posix(),
                     'modifications': 'fundo preto -> roxo-escuro do HUD; redução de área 60->28 px; paleta de 40 cores; moldura de tier 2 px' + ('; metal tingido na cor do tier' if tint else ''),
                     'used_in': 'inventário (botões de equipar), slots de equipamento do HUD, aviso de loot', 'status': 'MODELED_PENDING_GATE'})
    mats = {}
    for name, (fname, tier) in MATERIALS.items():
        id = f'icon_mat_{SLUG[name]}'
        png = OUTI / f'{id}.png'
        adapt(MAGIC / fname, tier, None, key_black=False).save(png, optimize=True)
        table[id] = 'res://' + png.relative_to(GAME).as_posix()
        mats[name] = id
        prov.append({'id': id, 'category': 'icone_material', 'source_paths': [rel(MAGIC / fname)], 'license': LICENSE['oga'],
                     'derived': 'game/' + png.relative_to(GAME).as_posix(),
                     'modifications': 'redução de área 64->28 px; paleta de 40 cores; moldura de tier 2 px',
                     'used_in': f'bolsa de materiais e aviso de coleta ({name})', 'status': 'MODELED_PENDING_GATE'})
    (GAME / 'data' / 'external_icons.json').write_text(json.dumps({'note': 'ícones de inventário/loot adaptados (tools/external/build_icons.py)', 'icons': table, 'materials': mats},
                                                                  ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
    record(prov)
    if len(sys.argv) > 1:                                    # prévia opcional: python3 build_icons.py <saida.png>
        sheet = Image.new('RGBA', (32 * 9, 32 * 3), (40, 30, 50, 255))
        for i, id in enumerate(table):
            sheet.paste(Image.open(OUTI / f'{id}.png'), ((i % 9) * 32, (i // 9) * 32))
        sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(sys.argv[1])
    print('ícones:', len(table))


if __name__ == '__main__':
    main()
