#!/usr/bin/env python3
"""Gera game/data/reg001_world.json — conteúdo manual da REG_001 (Etapa 1: Mundo Rico).

Uso: python3 game/tools/reg001/build_world.py [--preview arquivo.png]
"""
import json
import math
import os
import random
import sys
from pathlib import Path

import geo
from spec import World, GAME, ASSETS

OUT = GAME / 'data' / 'reg001_world.json'
W = World()
P = W.poi


def item(name, kind, tier, req, chapter, atk=0, dfn=0):
    return {'name': name, 'kind': kind, 'tier': tier, 'req': req, 'chapter': chapter, 'atk': atk, 'def': dfn}


TRAILS = []


def trail(tid, pts, half=26.0, note=''):
    TRAILS.append({'id': tid, 'pts': [[round(a, 1), round(b, 1)] for a, b in pts], 'half': half, 'note': note})
    for a, b in zip(pts, pts[1:]):
        W.clear((a[0] + b[0]) / 2, (a[1] + b[1]) / 2, math.hypot(b[0] - a[0], b[1] - a[1]) / 2 + half)


def ford(pid, y, note):
    rx, hw = geo.river_x(y), geo.river_hw(y)
    W.passage(pid, 'ford', [rx - hw - 26, y - 34, 2 * hw + 52, 68], note=note)
    W.emitter('sparkle', rx, y, hw + 20)
    W.clear(rx, y, hw + 60)
    W.obj('nat_ford_stones', rx, y + 6, 'RIO', solid=False, check=False, layer='ground')


# ============================================================================================
# FLORESTA OESTE / BOSQUE DO PRIMEIRO VENTO
# ============================================================================================
trail('REG001_TRAIL_LENHADOR', [(420, 1160), (340, 1030), (262, 930), (250, 800), (285, 620), (300, 470)], note='rota secundária: acampamento -> clareira do ancião')
trail('REG001_TRAIL_CASA', [(520, 1160), (548, 960), (540, 760), (520, 650)], note='rota secundária: casa abandonada')
trail('REG001_TRAIL_MIRANTE', [(300, 1160), (330, 1120), (360, 1085)], note='acesso ao mirante da Torre do Oeste')
trail('REG001_TRAIL_RUINAS', [(1536, 430), (1330, 410), (1100, 395), (880, 378)], note='rota principal ao arco dos antigos')
trail('REG001_TRAIL_ANCIAO', [(1290, 405), (1230, 300), (1180, 215)], note='rota secundária: elite do bosque')

# --- Acampamento abandonado do lenhador
P('REG001_POI_CAMP_LENHADOR', 'camp', 'ACAMPAMENTO ABANDONADO', 345, 860, tier=1, layer='secondary', radius=110, region='floresta',
  data={'heal': True, 'lore': 'REG001_LORE_01', 'hint': 'Um lenhador deixou o fogo aceso... e fugiu às pressas.'})
W.obj('nat_tent_small', 335, 850, 'CAMP', poi='REG001_POI_CAMP_LENHADOR')
W.obj('nat_campfire', 392, 892, 'CAMP', poi='REG001_POI_CAMP_LENHADOR', anim=1)
W.obj('nat_bedroll', 405, 850, 'CAMP', poi='REG001_POI_CAMP_LENHADOR')
W.obj('nat_log_pile', 330, 915, 'CAMP', poi='REG001_POI_CAMP_LENHADOR')
W.obj('nat_stump', 440, 915, 'CAMP', poi='REG001_POI_CAMP_LENHADOR')
W.obj('nat_chest_closed', 372, 815, 'CAMP', poi='REG001_POI_CHEST_LENHADOR')
W.emitter('smoke', 392, 882, 20)
P('REG001_POI_CHEST_LENHADOR', 'chest', 'BAÚ DO LENHADOR', 372, 815, tier=1, layer='secondary', radius=52, region='floresta', show_label=False,
  data={'loot': {'gold': 28, 'materials': {'Couro de lobo': 2}, 'potions': 1}})

# --- Casa abandonada
P('REG001_POI_CASA_ABANDONADA', 'landmark', 'CASA ABANDONADA', 520, 590, tier=1, layer='secondary', radius=120, region='floresta',
  data={'lore': 'REG001_LORE_02', 'hint': 'As janelas estão quebradas; há um baú sob o alpendre.'})
W.house(520, 610, 'city_roof_wood', 'CASA', poi='REG001_POI_CASA_ABANDONADA')
W.obj('nat_tree_dead', 425, 640, 'CASA')
W.iso_run('nat_fence_broken', 'b', 440, 664, 4, 'CASA', skip={2})
W.obj('nat_hay_bale', 630, 640, 'CASA')
W.obj('nat_chest_closed', 590, 648, 'CASA', poi='REG001_POI_CHEST_CASA')
W.obj('nat_signpost', 470, 690, 'CASA')
P('REG001_POI_CHEST_CASA', 'chest', 'BAÚ DA CASA', 590, 648, tier=1, layer='secondary', radius=52, region='floresta', show_label=False,
  data={'loot': {'gold': 40, 'materials': {'Seda sombria': 2}, 'item': item('Arco da Clareira', 'bow', 1, 1, 0, 5, 0)}})

# --- Mirante da Torre do Oeste (estrutura legada em 360,1110)
P('REG001_POI_MIRANTE_OESTE', 'viewpoint', 'MIRANTE DA TORRE DO OESTE', 360, 1110, tier=1, layer='secondary', radius=90, region='floresta',
  data={'text': 'Do alto da torre: fumaça a noroeste (acampamento), ruínas ao norte e o brilho do rio a leste.', 'reveal': ['REG001_POI_CAMP_LENHADOR', 'REG001_POI_ANCIAO_CLAREIRA', 'REG001_POI_RUINAS_PRIMEIRO_VENTO']})
W.obj('nat_flag_blue', 318, 1086, 'MIRANTE', poi='REG001_POI_MIRANTE_OESTE', anim=1)
W.obj('nat_signpost', 400, 1092, 'MIRANTE')
W.obj('nat_flowers_meadow', 300, 1136, 'MIRANTE')

# --- Clareira do Ancião (elite opcional)
P('REG001_POI_ANCIAO_CLAREIRA', 'elite', 'CLAREIRA DO ANCIÃO', 300, 420, tier=2, layer='secondary', radius=170, region='floresta',
  data={'enemy': 'Lobo', 'name': 'Lobo Ancião', 'hp_mult': 3.4, 'dmg_mult': 1.5, 'xp_mult': 4.0, 'gold_mult': 4.0, 'trigger': 210,
        'drop': {'materials': {'Couro de lobo': 3}}, 'chest': 'REG001_POI_CHEST_ANCIAO', 'lore': 'REG001_LORE_03'})
for i in range(9):
    a = .35 + i / 9 * 2 * math.pi
    if abs(math.sin(a - 1.57)) > .93 and math.cos(a) > 0:
        continue
    W.obj('nat_rock_boulder' if i % 2 == 0 else 'nat_rock_mossy', 300 + math.cos(a) * 185, 420 + math.sin(a) * 140, 'ANCIAO')
for i in range(5):
    a = i / 5 * 2 * math.pi + .6
    W.obj('nat_ruin_column_broken', 300 + math.cos(a) * 96, 424 + math.sin(a) * 66, 'ANCIAO')
W.obj('nat_chest_rare', 300, 330, 'ANCIAO', poi='REG001_POI_CHEST_ANCIAO')
W.obj('nat_mushrooms', 250, 470, 'ANCIAO')
W.obj('nat_bones_desert', 350, 478, 'ANCIAO', solid=False)
P('REG001_POI_CHEST_ANCIAO', 'chest', 'BAÚ DO ANCIÃO', 300, 330, tier=2, layer='secondary', radius=52, region='floresta', show_label=False,
  data={'requires_elite': 'REG001_POI_ANCIAO_CLAREIRA', 'loot': {'gold': 90, 'materials': {'Presa musgosa': 2, 'Couro de lobo': 3}, 'item': item('Espada do Ancião', 'sword', 1, 3, 0, 7, 0), 'potions': 2}})

# --- Segredo: passagem atrás da vegetação (noroeste)
P('REG001_POI_SEGREDO_MATA', 'secret', 'PASSAGEM NA MATA', 128, 648, tier=2, layer='secret', radius=100, region='floresta', show_label=False,
  data={'prompt': 'Afastar os galhos', 'found_text': 'Os galhos escondiam uma passagem antiga!', 'lore': 'REG001_LORE_04', 'chest': 'REG001_POI_CHEST_SEGREDO_MATA'})
for i, (bx, by) in enumerate([(98, 700), (146, 704), (190, 690), (204, 655), (192, 615), (150, 598), (98, 606), (80, 650)]):
    if (bx, by) == (146, 704):
        continue
    W.obj(['nat_bush_green', 'nat_bush_flowering', 'nat_bush_berry'][i % 3], bx, by, 'SEG_MATA', hide_when='REG001_POI_SEGREDO_MATA', layer='secret_hide')
    W.collider('circle', bx, by, 26, hide_when='REG001_POI_SEGREDO_MATA')
W.obj('nat_bush_green', 146, 704, 'SEG_MATA', hide_when='REG001_POI_SEGREDO_MATA', layer='secret_hide', solid=False)
W.collider('circle', 146, 704, 26, hide_when='REG001_POI_SEGREDO_MATA')
W.obj('nat_ruin_arch', 140, 640, 'SEG_MATA', show_when='REG001_POI_SEGREDO_MATA', layer='secret_show', solid=False)
W.obj('nat_chest_rare', 132, 656, 'SEG_MATA', poi='REG001_POI_CHEST_SEGREDO_MATA', show_when='REG001_POI_SEGREDO_MATA', layer='secret_show')
P('REG001_POI_CHEST_SEGREDO_MATA', 'chest', 'BAÚ SECRETO', 132, 656, tier=2, layer='secret', radius=52, region='floresta', show_label=False,
  data={'requires_secret': 'REG001_POI_SEGREDO_MATA', 'loot': {'gold': 120, 'materials': {'Fragmento de Eco': 1, 'Seda sombria': 3}, 'item': item('Cajado Sussurrante', 'staff', 1, 4, 0, 6, 0), 'potions': 2}})

# --- Recursos raros (floresta)
for pid, x, y, mat, n in [('REG001_POI_RES_ERVA_A', 470, 880, 'Erva Luminosa', 2), ('REG001_POI_RES_ERVA_B', 190, 1290, 'Erva Luminosa', 2),
                          ('REG001_POI_RES_MINERIO_A', 650, 1390, 'Minério Bruto', 2), ('REG001_POI_RES_CRISTAL_A', 980, 250, 'Cristal Verde', 1)]:
    kind_asset = 'nat_res_herb' if 'ERVA' in pid else 'nat_res_ore' if 'MINERIO' in pid else 'nat_res_crystal'
    P(pid, 'resource', mat.upper(), x, y, tier=1, layer='secondary', radius=56, region='floresta', show_label=False, data={'material': mat, 'amount': n})
    W.obj(kind_asset, x, y, 'RES', poi=pid)

# --- Ruínas do Primeiro Vento (arco dos antigos, 790,365) - marco principal do mistério
P('REG001_POI_RUINAS_PRIMEIRO_VENTO', 'lore', 'RUÍNAS DO PRIMEIRO VENTO', 790, 372, tier=2, layer='main', radius=190, region='floresta',
  data={'lore': 'REG001_LORE_05', 'prompt': 'Examinar o altar', 'reward': {'materials': {'Fragmento de Eco': 1}}})
W.obj('nat_ruin_arch', 790, 345, 'RUINAS', poi='REG001_POI_RUINAS_PRIMEIRO_VENTO', solid=False)
W.collider('circle', 748, 350, 16)
W.collider('circle', 832, 350, 16)
W.obj('nat_altar_ancient', 790, 428, 'RUINAS', poi='REG001_POI_RUINAS_PRIMEIRO_VENTO', anim=1)
W.obj('nat_obelisk_rune', 690, 380, 'RUINAS', anim=1)
W.obj('nat_obelisk_rune', 890, 384, 'RUINAS', anim=1)
W.obj('nat_statue_guardian', 738, 302, 'RUINAS')
# Portão do Primeiro Limiar: entrada da masmorra do Guardião, encaixada na rocha logo além do arco dos antigos
# (rota principal Cidade -> Bosque -> Ruínas -> Dungeon; a sala de baixo é a arena do Guardião)
P('REG001_POI_MASMORRA_ENTRADA', 'entrance', 'PORTÃO DO PRIMEIRO LIMIAR', 790, 298, tier=2, layer='main', radius=56, clear=70, region='floresta',
  data={'zone': 'masmorra', 'entry': [476, 745], 'text': 'Além do arco dos antigos, uma grade de pedra range na rocha. O Guardião aguarda lá embaixo. Entrar?'})
W.obj('dg_portcullis', 790, 296, 'RUINAS', poi='REG001_POI_MASMORRA_ENTRADA', solid=False)
W.obj('nat_statue_guardian', 842, 304, 'RUINAS', flip=True)
W.obj('APP:dungeon_torch', 752, 322, 'RUINAS', scale=.44, solid=False)
W.obj('APP:dungeon_torch', 828, 322, 'RUINAS', scale=.44, solid=False)
W.collider('rect', 745, 268, 34, 26)
W.collider('rect', 800, 268, 34, 26)
# moldura de relevo: paredão atrás e nos flancos (o portão está dentro da rocha, não solto no mato)
for _a, _x, _y in (('nat_cliff_corner_rock', 790, 236), ('nat_wall_cliff_rock_b', 706, 268), ('nat_wall_cliff_rock_a', 874, 268),
                   ('nat_cliff_end_rock_bp', 660, 318), ('nat_cliff_end_rock_am', 920, 322), ('nat_hill_low_rock', 712, 214), ('nat_hill_low_rock', 870, 210)):
    W.obj(_a, _x, _y, 'RUINAS_R', check=False, **({'solid': False} if 'hill_low' in _a else {}))
W.obj('nat_ruin_wall', 700, 470, 'RUINAS')
W.obj('nat_ruin_wall', 880, 476, 'RUINAS')
W.obj('nat_ruin_column', 905, 336, 'RUINAS')
W.obj('nat_ruin_column_broken', 660, 320, 'RUINAS')
W.obj('nat_fissure', 800, 520, 'RUINAS', solid=False)
W.collider('rect', 750, 505, 100, 24)
W.emitter('sparkle', 790, 420, 60)
W.emitter('sparkle', 790, 300, 40)

# --- Área de elite do bosque: Ancião do Bosque (norte)
P('REG001_POI_ELITE_BOSQUE', 'elite', 'ÁREA DO ELITE DO BOSQUE', 1180, 200, tier=2, layer='secondary', radius=170, region='floresta',
  data={'enemy': 'Aranha Sombria', 'name': 'Tecelã do Bosque', 'hp_mult': 3.6, 'dmg_mult': 1.5, 'xp_mult': 4.0, 'gold_mult': 4.0, 'trigger': 220,
        'drop': {'materials': {'Seda sombria': 4}}, 'chest': 'REG001_POI_CHEST_ELITE_BOSQUE', 'lore': 'REG001_LORE_06'})
for i in range(8):
    a = .2 + i / 8 * 2 * math.pi
    W.obj('nat_tree_pine' if i % 2 else 'nat_rock_mossy', 1180 + math.cos(a) * 178, 200 + math.sin(a) * 120, 'ELITE_B')
W.obj('nat_chest_rare', 1180, 140, 'ELITE_B', poi='REG001_POI_CHEST_ELITE_BOSQUE')
W.obj('nat_log_fallen', 1120, 235, 'ELITE_B')
W.obj('nat_mushrooms', 1250, 240, 'ELITE_B')
P('REG001_POI_CHEST_ELITE_BOSQUE', 'chest', 'BAÚ DA TECELÃ', 1180, 140, tier=2, layer='secondary', radius=52, region='floresta', show_label=False,
  data={'requires_elite': 'REG001_POI_ELITE_BOSQUE', 'loot': {'gold': 110, 'materials': {'Seda sombria': 4, 'Seiva voraz': 2}, 'item': item('Gibão do Bosque', 'armor', 1, 4, 0, 0, 3), 'potions': 2}})

# --- Torre do Norte: mirante + viajante
P('REG001_POI_MIRANTE_NORTE', 'viewpoint', 'MIRANTE DA TORRE DO NORTE', 1320, 345, tier=1, layer='secondary', radius=90, region='floresta',
  data={'text': 'Torre do Norte: a estrada segue até o Portal do Bosque. A oeste, ruínas e uma clareira sombria.', 'reveal': ['REG001_POI_RUINAS_PRIMEIRO_VENTO', 'REG001_POI_ELITE_BOSQUE']})
W.obj('nat_flag_red', 1370, 370, 'MIRANTE_N', anim=1)
P('REG001_POI_VIAJANTE_NORTE', 'npc', 'VIAJANTE', 1470, 520, tier=1, layer='secondary', radius=70, region='floresta',
  data={'npc': 'traveler', 'tint': [.78, .9, .7], 'name': 'Mara, a Cartógrafa', 'family': 'traveler',
        'lines': ['Estou mapeando o Bosque do Primeiro Vento.', 'Dizem que uma passagem se esconde atrás dos arbustos a noroeste.', 'Há uma cripta esquecida no Vale dos Lírios.'],
        'path': [[1470, 520], [1500, 545], [1440, 560]]})
W.obj('nat_tent_small', 1425, 505, 'VIAJ_N')
W.obj('nat_campfire', 1440, 545, 'VIAJ_N', anim=1)
W.obj('nat_cart_wood', 1490, 490, 'VIAJ_N')
W.emitter('smoke', 1440, 535, 20)

# --- Cachoeira da Aurora: rochas e neblina (a água/queda continuam efeito animado)
W.obj('nat_boulder_ice', geo.river_x(471) - 96, 452, 'CACHOEIRA')
W.obj('nat_boulder_ice', geo.river_x(471) + 96, 456, 'CACHOEIRA')
W.obj('nat_rock_snow', geo.river_x(471) - 118, 505, 'CACHOEIRA')
W.emitter('spray', geo.river_x(471), 471, 60)

# ============================================================================================
# CAMPOS DE LÍRIO / VALE DOS LÍRIOS
# ============================================================================================
trail('REG001_TRAIL_CAMPOS', [(560, 1180), (585, 1400), (560, 1600), (540, 1770)], note='rota da fronteira oeste até a Vila dos Campos')
trail('REG001_TRAIL_FAZENDA', [(540, 1880), (440, 1950), (310, 1972)], note='rota da vila à fazenda')
trail('REG001_TRAIL_ALDEIA', [(1536, 1770), (1490, 1752), (1440, 1752)], note='ramal da estrada sul à Aldeia do Vale')
trail('REG001_TRAIL_MOINHO', [(1440, 1752), (1330, 1752), (1240, 1850), (1150, 1880)], note='rota da aldeia ao moinho')
trail('REG001_TRAIL_SANTUARIO', [(1536, 1990), (1600, 2000), (1640, 2005)], note='ramal ao santuário')
trail('REG001_TRAIL_CRIPTA', [(1150, 1910), (1170, 2060), (1215, 2150)], note='rota da cripta esquecida (mini-dungeon opcional)')
trail('REG001_TRAIL_VALE_ELITE', [(1590, 2110), (1700, 2165), (1800, 2150)], note='rota ao elite do vale')
trail('REG001_TRAIL_VALE_FORD', [(1590, 1900), (1760, 1890), (1900, 2000), (1965, 2100)], note='rota ao vau do sul')

# --- Vila dos Campos (assentamento com casas APPROVED)
P('REG001_POI_VILA_CAMPOS', 'settlement', 'VILA DOS CAMPOS', 535, 1880, tier=1, layer='main', radius=230, region='campos',
  data={'npc': 'farmer', 'name': 'Dona Alma', 'family': 'farmer', 'lines': ['Os limos andam ariscos nos campos.', 'Meu espantalho cansou de vigiar, mas os corvos têm medo dele.']})
W.house(440, 1900, 'city_roof_wood', 'VILA_C', poi='REG001_POI_VILA_CAMPOS')
W.house(540, 1830, 'city_roof_blue', 'VILA_C', poi='REG001_POI_VILA_CAMPOS')
W.house(650, 1905, 'city_roof_red', 'VILA_C', poi='REG001_POI_VILA_CAMPOS')
W.obj('nat_well_stone', 545, 1955, 'VILA_C', poi='REG001_POI_VILA_CAMPOS')
W.obj('nat_flag_blue', 610, 1960, 'VILA_C', anim=1)
W.obj('nat_hay_bale', 380, 1965, 'VILA_C')
W.obj('nat_cart_wood', 700, 1960, 'VILA_C')
W.obj('nat_signpost', 600, 1780, 'VILA_C')
W.obj('nat_flowers_meadow', 500, 1930, 'VILA_C')
W.obj('nat_flowers_red', 590, 1965, 'VILA_C')

# --- Fazenda cercada (campos)
P('REG001_POI_FAZENDA', 'landmark', 'FAZENDA DO VALE', 300, 2090, tier=1, layer='secondary', radius=180, region='campos', data={'hint': 'Campos cercados; o portão está aberto para quem passa.'})
# losango isométrico: N(300,1990) E(428,2054) S(300,2118) W(172,2054); portão no vértice norte
W.iso_run('nat_fence_wood', 'b', 316, 1998, 4, 'FAZENDA', skip={0})     # NE
W.iso_run('nat_fence_wood', 'a', 188, 2046, 4, 'FAZENDA', skip={3})     # NO
W.iso_run('nat_fence_wood', 'a', 316, 2110, 4, 'FAZENDA')               # SE
W.iso_run('nat_fence_wood', 'b', 188, 2062, 4, 'FAZENDA')               # SO
W.obj('nat_gate_wood', 300, 1994, 'FAZENDA', layer='gate', hide_when='REG001_POI_PORTAO_FAZENDA')
W.obj('nat_scarecrow', 300, 2072, 'FAZENDA')
W.obj('nat_hay_stack', 236, 2086, 'FAZENDA')
W.obj('nat_hay_bale', 352, 2092, 'FAZENDA')
W.obj('nat_cart_wood', 330, 2044, 'FAZENDA')
W.obj('nat_chest_closed', 236, 2050, 'FAZENDA', poi='REG001_POI_CHEST_FAZENDA')
P('REG001_POI_PORTAO_FAZENDA', 'gate', 'PORTÃO DA FAZENDA', 300, 1995, tier=1, layer='shortcut', radius=60, region='campos', show_label=False,
  data={'prompt': 'Abrir o portão', 'passage': 'REG001_PASS_FAZENDA'})
W.passage('REG001_PASS_FAZENDA', 'shortcut', [262, 1975, 76, 40], requires='REG001_POI_PORTAO_FAZENDA', note='atalho: portão da fazenda')
W.collider('rect', 262, 1985, 76, 22, hide_when='REG001_POI_PORTAO_FAZENDA')
P('REG001_POI_CHEST_FAZENDA', 'chest', 'BAÚ DA FAZENDA', 236, 2050, tier=1, layer='secondary', radius=52, region='campos', show_label=False,
  data={'loot': {'gold': 36, 'materials': {'Núcleo de limo': 3}, 'potions': 2}})

# --- Aldeia do Vale + Moinho + Santuário
P('REG001_POI_ALDEIA_VALE', 'settlement', 'ALDEIA DO VALE', 1330, 1760, tier=1, layer='main', radius=200, region='vale',
  data={'npc': 'miller', 'name': 'Tio Bento', 'family': 'miller', 'lines': ['O moinho gira sozinho quando o vento do bosque sopra.', 'A cripta ao sul não é lugar para curiosos... mas há tesouros.']})
W.house(1290, 1690, 'city_roof_blue', 'ALDEIA_V', poi='REG001_POI_ALDEIA_VALE')
W.house(1375, 1840, 'city_roof_red', 'ALDEIA_V', poi='REG001_POI_ALDEIA_VALE')
W.house(1170, 1790, 'city_roof_wood', 'ALDEIA_V', poi='REG001_POI_ALDEIA_VALE')
W.obj('nat_well_stone', 1440, 1750, 'ALDEIA_V')
W.obj('nat_flag_red', 1465, 1700, 'ALDEIA_V', anim=1)
W.iso_run('nat_wall_low', 'a', 1216, 1932, 3, 'ALDEIA_V')
W.iso_run('nat_wall_low', 'b', 1320, 1900, 3, 'ALDEIA_V')
W.obj('city_barrels', 1235, 1740, 'ALDEIA_V')
W.obj('city_crates', 1215, 1710, 'ALDEIA_V')
W.obj('nat_flowers_blue', 1330, 1765, 'ALDEIA_V')
W.obj('nat_cart_wood', 1440, 1880, 'ALDEIA_V')
W.obj('nat_signpost', 1610, 1745, 'ALDEIA_V')

P('REG001_POI_SANTUARIO_VALE', 'shrine', 'SANTUÁRIO DO VALE', 1660, 2010, tier=1, layer='secondary', radius=150, region='vale',
  data={'heal': True, 'lore': 'REG001_LORE_07', 'hint': 'A luz do santuário restaura suas forças.'})
# (o santuário modelado str_shrine_stone já traz seus próprios pilares)
W.obj('nat_flowers_blue', 1620, 2085, 'SANT_V')
W.obj('nat_flowers_blue', 1730, 2080, 'SANT_V')
W.obj('nat_bush_flowering', 1630, 1950, 'SANT_V')

# --- Elite do Vale: Flor Voraz Anciã
P('REG001_POI_ELITE_VALE', 'elite', 'JARDIM DA FLOR ANCIÃ', 1810, 2140, tier=2, layer='secondary', radius=170, region='vale',
  data={'enemy': 'Flor Voraz', 'name': 'Flor Anciã', 'hp_mult': 3.4, 'dmg_mult': 1.4, 'xp_mult': 4.0, 'gold_mult': 4.0, 'trigger': 215,
        'drop': {'materials': {'Seiva voraz': 4}}, 'chest': 'REG001_POI_CHEST_ELITE_VALE'})
for i in range(8):
    a = .4 + i / 8 * 2 * math.pi
    W.obj(['nat_bush_flowering', 'nat_rock_mossy', 'nat_tree_birch'][i % 3], 1810 + math.cos(a) * 176, 2140 + math.sin(a) * 118, 'ELITE_V')
W.obj('nat_chest_rare', 1810, 2090, 'ELITE_V', poi='REG001_POI_CHEST_ELITE_VALE')
W.obj('nat_flowers_red', 1760, 2170, 'ELITE_V')
W.obj('nat_flowers_red', 1860, 2175, 'ELITE_V')
P('REG001_POI_CHEST_ELITE_VALE', 'chest', 'BAÚ DA FLOR ANCIÃ', 1810, 2090, tier=2, layer='secondary', radius=52, region='vale', show_label=False,
  data={'requires_elite': 'REG001_POI_ELITE_VALE', 'loot': {'gold': 130, 'materials': {'Seiva voraz': 4}, 'item': item('Arco do Sol Nascente', 'bow', 2, 6, 3, 9, 0), 'potions': 2}})

# --- Cripta Esquecida: entrada do mini-dungeon opcional
P('REG001_POI_CRIPTA_ENTRADA', 'entrance', 'CRIPTA ESQUECIDA', 1225, 2185, tier=2, layer='secondary', radius=110, region='vale',
  data={'zone': 'cripta', 'entry': [480, 800], 'text': 'Uma grade rangente guarda a Cripta Esquecida. Entrar?'})
W.obj('dg_portcullis', 1225, 2178, 'CRIPTA', poi='REG001_POI_CRIPTA_ENTRADA', solid=False)
W.collider('rect', 1180, 2140, 40, 30)
W.collider('rect', 1236, 2140, 40, 30)
W.obj('nat_statue_guardian', 1145, 2180, 'CRIPTA')
W.obj('nat_statue_guardian', 1305, 2184, 'CRIPTA', flip=True)
W.obj('nat_rock_boulder', 1090, 2160, 'CRIPTA')
W.obj('nat_rock_boulder', 1350, 2150, 'CRIPTA')
W.obj('APP:dungeon_torch', 1188, 2196, 'CRIPTA', scale=.44, solid=False)
W.obj('APP:dungeon_torch', 1262, 2196, 'CRIPTA', scale=.44, solid=False)
W.obj('nat_ruin_column_broken', 1310, 2245, 'CRIPTA')
W.emitter('sparkle', 1225, 2150, 50)
# moldura de relevo: a cripta está escavada num flanco de colina (paredões laterais e ao fundo), a trilha chega pelo vão
for _a, _x, _y in (('nat_wall_cliff_rock_b', 1082, 2176), ('nat_wall_cliff_rock_a', 1372, 2176), ('nat_cliff_end_rock_am', 1050, 2124), ('nat_cliff_end_rock_bp', 1402, 2126), ('nat_hill_low_rock', 1150, 2262), ('nat_hill_low_rock', 1305, 2262)):
    W.obj(_a, _x, _y, 'CRIPTA_R', check=False, **({'solid': False} if 'hill_low' in _a else {}))

# ============================================================================================
# GELO (Picos de Gelo)
# ============================================================================================
trail('REG001_TRAIL_GELO_ELITE', [(2510, 330), (2610, 275), (2720, 255), (2790, 250)], note='rota ao círculo de gelo (elite)')
trail('REG001_TRAIL_POUSO', [(2510, 560), (2470, 560)], note='ramal ao Pouso da Geada')
trail('REG001_TRAIL_ABRIGO', [(2510, 640), (2600, 640), (2660, 610)], note='ramal ao abrigo')

# --- Pouso da Geada (assentamento de tendas)
P('REG001_POI_POUSO_GEADA', 'settlement', 'POUSO DA GEADA', 2460, 560, tier=2, layer='main', radius=190, region='gelo',
  data={'npc': 'hunter', 'name': 'Kaya, Caçadora', 'family': 'hunter', 'lines': ['O golem dorme no círculo de gelo ao norte.', 'Cristais raros crescem onde o vento não chega.']})
W.obj('nat_tent_frost', 2400, 540, 'POUSO', poi='REG001_POI_POUSO_GEADA')
W.obj('nat_tent_frost', 2440, 620, 'POUSO')
W.obj('nat_tent_small', 2380, 610, 'POUSO')
W.obj('nat_campfire', 2440, 570, 'POUSO', anim=1)
W.obj('nat_flag_blue', 2340, 580, 'POUSO', anim=1)
W.obj('nat_log_pile', 2350, 650, 'POUSO')
W.obj('nat_snow_mound', 2470, 480, 'POUSO', solid=False)
W.emitter('smoke', 2440, 560, 20)

# --- Passagem estreita (canyon de gelo) sobre a estrada x=2510 entre y=290 e y=450
for y in (290, 340, 390, 440):
    W.obj('nat_boulder_ice', 2455 + (y % 3) * 4, y, 'CANYON')
    if y != 290:
        W.obj('nat_rock_ice', 2655 + (y % 5) * 3, y + 10, 'CANYON')
W.obj('nat_ice_spire', 2440, 470, 'CANYON')
W.obj('nat_ice_spire', 2660, 480, 'CANYON')
P('REG001_POI_CANYON_GELO', 'landmark', 'PASSAGEM ESTREITA', 2510, 365, tier=1, layer='secondary', radius=80, region='gelo', data={'hint': 'Uma passagem estreita entre rochas de gelo.'}, show_label=False, clear=60)

# --- Círculo de gelo: elite Golem Ancião
P('REG001_POI_ELITE_GELO', 'elite', 'CÍRCULO DE GELO', 2800, 250, tier=3, layer='secondary', radius=180, region='gelo',
  data={'enemy': 'Lobo de Gelo', 'name': 'Lobo Boreal', 'hp_mult': 3.2, 'dmg_mult': 1.4, 'xp_mult': 4.0, 'gold_mult': 4.0, 'trigger': 220,
        'drop': {'materials': {'Cristal gelado': 3}}, 'chest': 'REG001_POI_CHEST_ELITE_GELO', 'lore': 'REG001_LORE_08'})
for i in range(10):
    a = i / 10 * 2 * math.pi
    if i == 5:
        continue
    W.obj('nat_ice_spire' if i % 2 else 'nat_boulder_ice', 2800 + math.cos(a) * 180, 250 + math.sin(a) * 120, 'ELITE_G')
W.obj('APP:dungeon_crystal_blue', 2800, 218, 'ELITE_G', scale=.5, solid=False)
W.obj('nat_chest_rare', 2800, 300, 'ELITE_G', poi='REG001_POI_CHEST_ELITE_GELO')
W.obj('nat_snow_mound', 2700, 300, 'ELITE_G', solid=False)
W.emitter('sparkle', 2800, 250, 90)
P('REG001_POI_CHEST_ELITE_GELO', 'chest', 'BAÚ BOREAL', 2800, 300, tier=3, layer='secondary', radius=52, region='gelo', show_label=False,
  data={'requires_elite': 'REG001_POI_ELITE_GELO', 'loot': {'gold': 160, 'materials': {'Cristal gelado': 4, 'Coração de geada': 1}, 'item': item('Arco Boreal Raro', 'bow', 3, 9, 4, 14, 0), 'potions': 3}})

# --- Segredo: gruta de gelo atrás de arbustos congelados
P('REG001_POI_SEGREDO_GELO', 'secret', 'GRUTA CONGELADA', 3010, 120, tier=3, layer='secret', radius=100, region='gelo', show_label=False,
  data={'prompt': 'Quebrar o gelo', 'found_text': 'O gelo se abriu: uma gruta escondida!', 'lore': 'REG001_LORE_09', 'chest': 'REG001_POI_CHEST_SEGREDO_GELO'})
for i, (bx, by) in enumerate([(2975, 150), (3010, 158), (3045, 150), (3055, 118), (3040, 90), (2980, 90), (2968, 122)]):
    W.obj('nat_bush_frost', bx, by, 'SEG_GELO', hide_when='REG001_POI_SEGREDO_GELO', layer='secret_hide')
    W.collider('circle', bx, by, 26, hide_when='REG001_POI_SEGREDO_GELO')
W.obj('nat_ice_spire', 3010, 108, 'SEG_GELO', show_when='REG001_POI_SEGREDO_GELO', layer='secret_show')
W.obj('nat_chest_rare', 3010, 130, 'SEG_GELO', poi='REG001_POI_CHEST_SEGREDO_GELO', show_when='REG001_POI_SEGREDO_GELO', layer='secret_show')
P('REG001_POI_CHEST_SEGREDO_GELO', 'chest', 'BAÚ DA GRUTA', 3010, 130, tier=3, layer='secret', radius=52, region='gelo', show_label=False,
  data={'requires_secret': 'REG001_POI_SEGREDO_GELO', 'loot': {'gold': 150, 'materials': {'Coração de geada': 2}, 'item': item('Cajado Aurora', 'staff', 3, 9, 4, 12, 0)}})

# --- Recursos raros no gelo
for pid, x, y, mat in [('REG001_POI_RES_CRISTAL_GELO_A', 2620, 700, 'Cristal Gelado Puro'), ('REG001_POI_RES_CRISTAL_GELO_B', 2900, 520, 'Cristal Gelado Puro')]:
    P(pid, 'resource', mat.upper(), x, y, tier=3, layer='secondary', radius=56, region='gelo', show_label=False, data={'material': mat, 'amount': 2})
    W.obj('nat_res_crystal', x, y, 'RES', poi=pid)

# --- Mirante do gelo
P('REG001_POI_MIRANTE_GELO', 'viewpoint', 'MIRANTE DAS GEADAS', 2900, 640, tier=2, layer='secondary', radius=90, region='gelo',
  data={'text': 'Do mirante: o círculo de gelo ao norte, o Pouso a oeste e, a sul, as colinas do leste.', 'reveal': ['REG001_POI_ELITE_GELO', 'REG001_POI_POUSO_GEADA']})
W.obj('nat_flag_blue', 2900, 660, 'MIRANTE_G', anim=1)
W.obj('nat_rock_snow', 2860, 680, 'MIRANTE_G')

# ============================================================================================
# COLINAS DO LESTE (pradaria) - transição Gelo <-> Colinas <-> Deserto
# ============================================================================================
trail('REG001_TRAIL_COLINAS', [(2560, 1250), (2610, 1180), (2680, 1120)], note='ramal à estação das colinas')
P('REG001_POI_ESTACAO_LESTE', 'settlement', 'ESTAÇÃO DAS COLINAS', 2700, 1100, tier=2, layer='secondary', radius=160, region='pradaria',
  data={'npc': 'traveler', 'name': 'Ruan, Mercador Viajante', 'family': 'merchant', 'tint': [.95, .8, .55], 'lines': ['Levo peles do gelo até as caravanas do deserto.', 'Siga as bandeiras: elas marcam os caminhos seguros.'],
        'path': [[2700, 1110], [2740, 1130], [2670, 1140]]})
W.obj('nat_tent_small', 2650, 1080, 'ESTACAO', poi='REG001_POI_ESTACAO_LESTE')
W.obj('nat_campfire', 2710, 1120, 'ESTACAO', anim=1)
W.obj('nat_cart_wood', 2760, 1070, 'ESTACAO')
W.obj('nat_flag_red', 2630, 1100, 'ESTACAO', anim=1)
W.obj('nat_signpost', 2645, 1170, 'ESTACAO')
W.obj('nat_hay_bale', 2780, 1120, 'ESTACAO')
# casa de posta (troca de montarias e carroças): casa, estábulo improvisado de feno e cerca; o comércio de peles é o motivo do lugar
W.house(2735, 1042, 'city_roof_wood', 'ESTACAO', poi='REG001_POI_ESTACAO_LESTE')
W.obj('nat_hay_stack', 2810, 1075, 'ESTACAO')
W.obj('nat_fence_wood_a', 2700, 1155, 'ESTACAO')
W.obj('nat_fence_wood_a', 2732, 1171, 'ESTACAO')
W.obj('nat_fence_wood_b', 2764, 1155, 'ESTACAO')
W.emitter('smoke', 2710, 1110, 20)
for x, y in [(2680, 960), (2790, 940), (2860, 1010), (2960, 900), (2980, 1150), (2830, 1345), (2640, 1330)]:
    W.obj('nat_rock_boulder' if (x + y) % 3 else 'nat_rock_mossy', x, y, 'COLINAS')
W.scatter(['nat_bush_green', 'nat_flowers_meadow', 'nat_rock_small', 'nat_grass_tall'], 2760, 1100, 300, 22, 'COLINAS', min_dist=70, solid=False)

# ============================================================================================
# DESERTO (Dunas de Âmbar)
# ============================================================================================
trail('REG001_TRAIL_CARAVANA', [(2560, 1250), (2540, 1420), (2525, 1550)], note='ramal à caravana')
trail('REG001_TRAIL_DUNAS', [(2450, 1840), (2440, 1960), (2430, 2040)], note='ramal às ruínas das dunas')
trail('REG001_TRAIL_OASIS', [(2690, 1840), (2790, 1900), (2870, 1990), (2900, 2035)], note='rota ao oásis')

P('REG001_POI_CARAVANA', 'settlement', 'CARAVANA DE ÂMBAR', 2520, 1590, tier=2, layer='main', radius=190, region='deserto',
  data={'npc': 'merchant', 'name': 'Sahir, Caravaneiro', 'family': 'merchant', 'lines': ['As dunas engolem os descuidados.', 'O Posto de Âmbar vende água e histórias.']})
W.obj('nat_tent_red', 2470, 1580, 'CARAVANA', poi='REG001_POI_CARAVANA')
W.obj('nat_tent_red', 2560, 1640, 'CARAVANA')
W.obj('nat_tent_small', 2600, 1570, 'CARAVANA')
W.obj('nat_campfire', 2520, 1610, 'CARAVANA', anim=1)
W.obj('nat_cart_wood', 2440, 1650, 'CARAVANA')
W.obj('nat_flag_red', 2500, 1540, 'CARAVANA', anim=1)
W.obj('nat_bones_desert', 2620, 1640, 'CARAVANA', solid=False)
W.emitter('smoke', 2520, 1600, 20)

P('REG001_POI_RUINAS_DUNAS', 'lore', 'RUÍNAS DAS DUNAS', 2420, 2070, tier=3, layer='main', radius=200, region='deserto',
  data={'lore': 'REG001_LORE_10', 'prompt': 'Examinar o altar de areia', 'reward': {'materials': {'Fragmento de Eco': 1}}})
W.obj('nat_ruin_arch_sand', 2420, 2040, 'DUNAS_R', solid=False)
W.collider('circle', 2378, 2044, 16)
W.collider('circle', 2462, 2044, 16)
W.obj('nat_altar_sand', 2420, 2120, 'DUNAS_R', poi='REG001_POI_RUINAS_DUNAS', anim=1)
W.obj('nat_ruin_column_sand', 2340, 2110, 'DUNAS_R')
W.obj('nat_ruin_column_sand', 2500, 2100, 'DUNAS_R')
W.obj('nat_ruin_wall_sand', 2330, 2010, 'DUNAS_R')
W.obj('nat_ruin_wall_sand', 2520, 2170, 'DUNAS_R')
# armadilhas nas ruínas (placas + fossos), sem bloquear o caminho central x=2430
W.obj('nat_pit_trap', 2340, 2170, 'DUNAS_R', solid=False)
W.obj('nat_pit_trap', 2500, 2020, 'DUNAS_R', solid=False)
W.obj('nat_trap_plate', 2380, 2150, 'DUNAS_R', solid=False, anim=1)
W.obj('nat_trap_plate', 2465, 2145, 'DUNAS_R', solid=False, anim=1)
P('REG001_POI_TRAP_DUNAS_A', 'trap', 'ARMADILHA', 2380, 2150, tier=3, layer='secondary', radius=28, region='deserto', show_label=False, data={'damage': 5, 'period': 3.2}, clear=30)
P('REG001_POI_TRAP_DUNAS_B', 'trap', 'ARMADILHA', 2465, 2145, tier=3, layer='secondary', radius=28, region='deserto', show_label=False, data={'damage': 5, 'period': 3.2}, clear=30)
P('REG001_POI_CHEST_DUNAS', 'chest', 'BAÚ DAS RUÍNAS', 2360, 2060, tier=3, layer='secondary', radius=52, region='deserto', show_label=False,
  data={'loot': {'gold': 120, 'materials': {'Quitina âmbar': 3}, 'item': item('Cajado das Dunas Antigas', 'staff', 2, 7, 3, 10, 0), 'potions': 2}})
W.obj('nat_chest_closed', 2360, 2060, 'DUNAS_R', poi='REG001_POI_CHEST_DUNAS')

# --- Oásis + elite Escaravelho
P('REG001_POI_OASIS', 'elite', 'OÁSIS DO ESCARAVELHO', 2900, 2080, tier=3, layer='secondary', radius=190, region='deserto',
  data={'enemy': 'Escaravelho Âmbar', 'name': 'Escaravelho-Rei', 'hp_mult': 3.0, 'dmg_mult': 1.4, 'xp_mult': 4.0, 'gold_mult': 4.0, 'trigger': 220,
        'drop': {'materials': {'Casco de âmbar': 4}}, 'chest': 'REG001_POI_CHEST_OASIS'})
for i, (dx, dy) in enumerate([(-120, -70), (130, -60), (-150, 50), (140, 70), (60, -125)]):
    W.obj('nat_tree_palm', 2900 + dx, 2080 + dy, 'OASIS')
W.obj('nat_reeds', 2860, 2120, 'OASIS', solid=False)
W.obj('nat_reeds', 2950, 2118, 'OASIS', solid=False)
W.obj('nat_chest_rare', 2900, 2040, 'OASIS', poi='REG001_POI_CHEST_OASIS')
W.obj('nat_bones_desert', 2940, 2140, 'OASIS', solid=False)
P('REG001_POI_CHEST_OASIS', 'chest', 'BAÚ DO OÁSIS', 2900, 2040, tier=3, layer='secondary', radius=52, region='deserto', show_label=False,
  data={'requires_elite': 'REG001_POI_OASIS', 'loot': {'gold': 150, 'materials': {'Casco de âmbar': 4, 'Quitina âmbar': 3}, 'item': item('Armadura de Âmbar', 'armor', 2, 8, 3, 0, 5), 'potions': 3}})

# --- Segredo: passagem atrás da duna
P('REG001_POI_SEGREDO_DUNA', 'secret', 'DUNA MÓVEL', 3000, 1500, tier=3, layer='secret', radius=64, region='deserto', show_label=False,
  data={'prompt': 'Cavar na duna', 'found_text': 'A duna cedeu: uma câmara enterrada!', 'lore': 'REG001_LORE_11', 'chest': 'REG001_POI_CHEST_SEGREDO_DUNA'})
W.obj('nat_dune_large', 3000, 1495, 'SEG_DUNA', hide_when='REG001_POI_SEGREDO_DUNA', layer='secret_hide')
W.obj('nat_ruin_column_sand', 2965, 1495, 'SEG_DUNA', show_when='REG001_POI_SEGREDO_DUNA', layer='secret_show')
W.obj('nat_ruin_column_sand', 3035, 1495, 'SEG_DUNA', show_when='REG001_POI_SEGREDO_DUNA', layer='secret_show')
W.obj('nat_chest_rare', 3000, 1520, 'SEG_DUNA', poi='REG001_POI_CHEST_SEGREDO_DUNA', show_when='REG001_POI_SEGREDO_DUNA', layer='secret_show')
P('REG001_POI_CHEST_SEGREDO_DUNA', 'chest', 'BAÚ ENTERRADO', 3000, 1520, tier=3, layer='secret', radius=52, region='deserto', show_label=False,
  data={'requires_secret': 'REG001_POI_SEGREDO_DUNA', 'loot': {'gold': 140, 'materials': {'Quitina âmbar': 4}, 'item': item('Espada do Deserto Antigo', 'sword', 2, 8, 3, 10, 0)}})

# --- Dunas como obstáculos/rotas (corredores livres em x=2450 e y=1840)
for x, y in [(2140, 1470), (2330, 1440), (2640, 1470), (2830, 1440), (2330, 1670), (2960, 1700), (2740, 1980), (2650, 2160), (2200, 2240), (3000, 1960)]:
    W.obj('nat_dune_large', x, y, 'DUNAS')
for x, y in [(2260, 1560), (2400, 1740), (2820, 1620), (2560, 2080), (3010, 1780), (2280, 1930)]:
    W.obj('nat_dune_small', x, y, 'DUNAS', solid=False)
W.scatter(['nat_cactus_tall', 'nat_cactus_round', 'nat_bush_dry', 'nat_rock_sand'], 2650, 1850, 520, 26, 'DESERTO', min_dist=90)
W.scatter(['nat_bones_desert', 'nat_grass_dry'], 2650, 1850, 500, 8, 'DESERTO', min_dist=110, solid=False)

# --- Recursos raros no deserto
for pid, x, y, mat in [('REG001_POI_RES_AMBAR_A', 2250, 1950, 'Âmbar Bruto'), ('REG001_POI_RES_AMBAR_B', 2800, 1450, 'Âmbar Bruto')]:
    P(pid, 'resource', mat.upper(), x, y, tier=2, layer='secondary', radius=56, region='deserto', show_label=False, data={'material': mat, 'amount': 2})
    W.obj('nat_res_ore', x, y, 'RES', poi=pid)

# ============================================================================================
# RIO E TRAVESSIAS
# ============================================================================================
ford('REG001_PASS_VAU_SUL', 2110, 'vau raso ao sul do vale: liga o Vale ao Deserto sem ponte')
ford('REG001_PASS_VAU_CENTRAL', 1520, 'vau raso ao sul da cidade: atalho vale <-> pradaria')
for y in (900, 1080, 1420, 1650, 1990, 2200):
    rx = geo.river_x(y)
    W.obj('nat_reeds', rx - geo.river_hw(y) - 25, y, 'RIO', solid=False)
    W.obj('nat_reeds', rx + geo.river_hw(y) + 25, y + 10, 'RIO', solid=False)
W.obj('nat_decal_mud_bank', geo.river_x(1650) - 90, 1650, 'RIO', layer='ground', solid=False, check=False)

# ============================================================================================
# CIDADE DE VALEDOURO — props modelados (coordenadas do mundo = TOWN + local)
# ============================================================================================
TX, TY = geo.TOWN


def T(x, y):
    return TX + x, TY + y


def town(asset, x, y, group='CIDADE', **kw):
    wx, wy = T(x, y)
    W.obj(asset, wx, wy, group, check=False, **kw)


town('city_banner_blue', 760, 190)
town('city_banner_blue', 1010, 190)
for x, y in [(810, 220), (970, 220), (810, 390), (970, 390), (810, 610), (970, 610), (810, 770), (970, 770)]:
    town('city_lamp_post_a', x, y)
town('city_stall_striped', 735, 590)
town('city_stall_blue', 1070, 590)
town('city_cart_market', 900, 600)
town('city_fountain', 874, 497, anim=1)
town('city_barrels', 1180, 460)
town('city_crates', 1370, 470)
town('city_barrels', 540, 465)
town('city_planter', 430, 395)
town('city_planter', 500, 395)
town('city_planter', 1195, 400)
town('city_planter', 1275, 400)
town('city_planter', 425, 690)
town('city_planter', 500, 690)
town('city_bench', 780, 470)
town('city_bench', 990, 470)
town('city_bench', 780, 545)
town('city_bench', 990, 545)
town('city_monument', 875, 330)
town('city_sign_hanging', 400, 388)
town('city_sign_hanging', 1160, 388)
town('city_sign_hanging', 1360, 676)
town('city_sign_hanging', 396, 682)
town('nat_flag_blue', 1500, 200)
town('nat_flag_red', 250, 200)
town('nat_well_stone', 1400, 520)
town('city_crates', 1480, 720)
# Taverna do Viajante: a casa (1075,345) junto da praça e da estrada principal — placa, barris, bancos e ponto de descanso
town('city_sign_hanging', 1040, 402)
town('city_barrels', 1150, 405)
town('city_bench', 1000, 425)
town('city_bench', 1095, 425)
P('REG001_POI_TAVERNA', 'camp', 'TAVERNA DO VIAJANTE', TX + 1070, TY + 418, tier=1, layer='main', radius=80, region='cidade', show_label=True,
  data={'heal': True, 'hint': 'O taverneiro guarda uma cama e um caldo quente para quem volta da estrada. (descanso e save)'})
town('city_barrels', 300, 720)
# (o antigo portal das ruínas na muralha sul foi movido para as Ruínas do Primeiro Vento: entrada de dungeon não fica solta na cidade)

# ============================================================================================
# INTERIORES (coordenadas locais da zona)
# ============================================================================================


def room(zone, asset, x, y, **kw):
    kw.setdefault('scale', 1.25)
    W.obj(asset, x, y, 'INT_' + zone.upper(), zone=zone, check=False, **kw)


# Guilda dos Exploradores
room('guilda', 'int_desk_guild', 480, 400)
room('guilda', 'int_quest_board', 250, 360)
room('guilda', 'int_bookshelf', 340, 300)
room('guilda', 'int_bookshelf', 620, 300)
room('guilda', 'int_bookshelf', 720, 330)
room('guilda', 'int_rug_round', 480, 560, layer='ground')
room('guilda', 'int_table_long', 790, 470)
room('guilda', 'int_chair', 740, 500)
room('guilda', 'int_chair', 840, 500)
room('guilda', 'int_candle_stand', 190, 470, anim=1)
room('guilda', 'int_candle_stand', 770, 590, anim=1)
room('guilda', 'city_banner_blue', 200, 300)
room('guilda', 'city_banner_red', 760, 290)

# Ferreiro
room('ferreiro', 'int_forge', 760, 430, anim=1)
room('ferreiro', 'int_anvil', 640, 545)
room('ferreiro', 'int_workbench', 930, 560)
room('ferreiro', 'int_weapon_rack', 560, 345)
room('ferreiro', 'int_weapon_rack', 1010, 350)
room('ferreiro', 'int_armor_stand', 460, 420)
room('ferreiro', 'int_armor_stand', 1110, 430)
room('ferreiro', 'city_barrels', 1180, 520)
room('ferreiro', 'city_crates', 480, 610)
room('ferreiro', 'int_candle_stand', 1000, 470, anim=1)

# Alquimia
room('alquimia', 'int_shelf_potions', 300, 320)
room('alquimia', 'int_shelf_potions', 420, 320)
room('alquimia', 'int_shelf_potions', 640, 320)
room('alquimia', 'int_shelf_potions', 760, 330)
room('alquimia', 'int_cauldron', 620, 500, anim=1)
room('alquimia', 'int_alchemy_table', 340, 500)
room('alquimia', 'int_bookshelf', 200, 380)
room('alquimia', 'int_rug_round', 480, 590, layer='ground')
room('alquimia', 'int_candle_stand', 780, 560, anim=1)
room('alquimia', 'int_sacks', 800, 470)

# Loja
room('loja', 'int_counter', 480, 430)
room('loja', 'int_shelf_goods', 250, 320)
room('loja', 'int_shelf_goods', 350, 320)
room('loja', 'int_shelf_goods', 650, 320)
room('loja', 'int_shelf_goods', 750, 330)
room('loja', 'int_sacks', 210, 500)
room('loja', 'city_crates', 780, 500)
room('loja', 'city_barrels', 220, 590)
room('loja', 'int_rug_round', 480, 570, layer='ground')


# composição extra dos interiores: pontos focais, apoio, props pequenos e áreas livres de circulação
room('guilda', 'city_planter', 130, 300)
room('guilda', 'city_planter', 830, 300)
room('guilda', 'int_rug_round', 480, 470, layer='ground', scale=1.9)
room('guilda', 'int_stool', 700, 440)
room('guilda', 'int_stool', 880, 440)
room('guilda', 'city_barrels', 120, 610)
room('guilda', 'city_crates', 860, 620)
room('guilda', 'int_candle_stand', 300, 520, anim=1)
room('ferreiro', 'city_planter', 380, 560)
room('ferreiro', 'int_rug_round', 760, 560, layer='ground', scale=1.8)
room('ferreiro', 'city_barrels', 300, 460)
room('ferreiro', 'city_crates', 1200, 610)
room('ferreiro', 'int_stool', 840, 470)
room('ferreiro', 'int_candle_stand', 540, 500, anim=1)
room('alquimia', 'city_planter', 130, 470)
room('alquimia', 'city_planter', 830, 400)
room('alquimia', 'int_table_round', 470, 400)
room('alquimia', 'int_stool', 400, 440)
room('alquimia', 'int_stool', 540, 440)
room('alquimia', 'city_barrels', 130, 600)
room('loja', 'city_planter', 130, 430)
room('loja', 'city_planter', 830, 430)
room('loja', 'int_stool', 380, 480)
room('loja', 'city_barrels', 840, 610)
room('loja', 'int_candle_stand', 520, 320, anim=1)

# ============================================================================================
# MASMORRA DO GUARDIÃO — ambientação com módulos modelados (layout em coordenadas locais)
# ============================================================================================


def dg(asset, x, y, **kw):
    W.obj(asset, x, y, 'DG', zone='masmorra', check=False, **kw)


for px, py in [(6, 8), (11, 8), (18, 8), (24, 8), (6, 13), (11, 13), (18, 13), (24, 13), (6, 19), (11, 19), (18, 19), (24, 19)]:
    dg('dg_pillar' if (px + py) % 3 else 'dg_pillar_broken', px * 32 + 16, py * 32 + 32, solid=False)
dg('dg_rune_circle', 480, 300, layer='ground', anim=1)
for bx in (285, 675):
    dg('dg_brazier', bx, 275, anim=1)
dg('dg_sarcophagus', 150, 520)
dg('dg_sarcophagus', 810, 520, flip=True)
dg('dg_bones_pile', 300, 600)
dg('dg_bones_pile', 690, 610)
dg('dg_barrel_old', 140, 690)
dg('dg_crate_old', 190, 700)
dg('dg_stalagmites', 120, 400)
dg('dg_stalagmites', 850, 400)
dg('dg_mushroom_glow', 110, 770, anim=1)
dg('dg_mushroom_glow', 860, 770, anim=1)
dg('dg_crystal_checkpoint', 760, 700, anim=1, poi='REG001_POI_DG_CHECKPOINT')
P('REG001_POI_DG_CHECKPOINT', 'checkpoint', 'CRISTAL DE REPOUSO', 760, 700, zone='masmorra', tier=2, layer='main', radius=70, region='masmorra',
  data={'heal': True, 'hint': 'O cristal restaura suas forças.'})
P('REG001_POI_DG_ELITE', 'elite', 'ELITE DA MASMORRA', 250, 470, zone='masmorra', tier=2, layer='secondary', radius=160, region='masmorra',
  data={'enemy': 'Aranha Sombria', 'name': 'Fiandeira da Masmorra', 'hp_mult': 3.2, 'dmg_mult': 1.5, 'xp_mult': 4.0, 'gold_mult': 4.0, 'trigger': 200,
        'drop': {'materials': {'Seda sombria': 3}}, 'chest': 'REG001_POI_DG_CHEST'})
dg('nat_chest_rare', 190, 560, poi='REG001_POI_DG_CHEST')
P('REG001_POI_DG_CHEST', 'chest', 'BAÚ DA MASMORRA', 190, 560, zone='masmorra', tier=2, layer='secondary', radius=52, region='masmorra', show_label=False,
  data={'requires_elite': 'REG001_POI_DG_ELITE', 'loot': {'gold': 100, 'materials': {'Seda sombria': 3}, 'item': item('Espada das Runas', 'sword', 1, 5, 0, 7, 0), 'potions': 2}})

# ============================================================================================
# BOSQUE (instância "floresta", 1825x862) — dressing modelado sobre a arte pintada + elite opcional
# ============================================================================================


def fo(asset, x, y, **kw):
    kw.setdefault('solid', False)
    W.obj(asset, x, y, 'FLORESTA_INT', zone='floresta', check=False, **kw)


for asset, x, y in [('nat_mushrooms', 300, 650), ('nat_flowers_red', 620, 500), ('nat_flowers_meadow', 820, 650), ('nat_bush_berry', 1180, 610),
                    ('nat_mushrooms', 1350, 700), ('nat_log_fallen', 900, 300), ('nat_stump', 1220, 420), ('nat_rock_mossy', 700, 240),
                    ('nat_flowers_blue', 1600, 720), ('nat_bush_flowering', 220, 420), ('nat_grass_tall', 540, 700), ('nat_grass_tall', 1440, 560)]:
    fo(asset, x, y)
fo('nat_campfire', 900, 520, anim=1, solid=None)
fo('nat_bedroll', 950, 500)
fo('nat_log_pile', 850, 500)
W.emitter('smoke', 900, 512, 20, zone='floresta')
P('REG001_POI_BOSQUE_ELITE', 'elite', 'CLAREIRA DO JAVALI ALFA', 1250, 300, zone='floresta', tier=1, layer='secondary', radius=170, region='bosque',
  data={'enemy': 'Javali Musgoso', 'name': 'Javali Alfa', 'hp_mult': 3.0, 'dmg_mult': 1.4, 'xp_mult': 4.0, 'gold_mult': 4.0, 'trigger': 210,
        'drop': {'materials': {'Presa musgosa': 3}}, 'chest': 'REG001_POI_BOSQUE_CHEST'})
fo('nat_chest_rare', 1250, 236, poi='REG001_POI_BOSQUE_CHEST', solid=None)
P('REG001_POI_BOSQUE_CHEST', 'chest', 'BAÚ DO JAVALI', 1250, 236, zone='floresta', tier=1, layer='secondary', radius=52, region='bosque', show_label=False,
  data={'requires_elite': 'REG001_POI_BOSQUE_ELITE', 'loot': {'gold': 70, 'materials': {'Presa musgosa': 2}, 'item': item('Espada do Javali', 'sword', 1, 3, 0, 6, 0), 'potions': 2}})
P('REG001_POI_BOSQUE_CAMP', 'camp', 'FOGUEIRA DO BOSQUE', 900, 520, zone='floresta', tier=1, layer='secondary', radius=90, region='bosque', data={'heal': True, 'hint': 'O fogo aquece e restaura suas forças.'})

# --- Bosque: mata fechada em modelados + APPROVED (trilhas, riacho e clareiras livres); troncos grandes nos obstáculos legados
BOSQUE_TRAILS = [([(1000, 862), (1000, 760), (985, 620), (930, 470), (900, 330), (880, 120)], 60),
                 ([(930, 470), (760, 500), (560, 470), (400, 480)], 46),
                 ([(900, 330), (1080, 300), (1250, 300)], 46),
                 ([(985, 620), (1150, 640), (1330, 700)], 40)]
LEGACY_TRUNKS = [(166, 178), (495, 87), (739, 52), (1397, 127), (1735, 128), (398, 487), (660, 252), (1106, 290)]


def _seg_dist(px, py, ax, ay, bx, by):
    dx, dy = bx - ax, by - ay
    t = max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy or 1)))
    return math.hypot(px - (ax + dx * t), py - (ay + dy * t))


def bosque_free(x, y):
    for pts, wd in BOSQUE_TRAILS:
        for a, b in zip(pts, pts[1:]):
            if _seg_dist(x, y, a[0], a[1], b[0], b[1]) < wd / 2 + 46:
                return False
    if 20 < y < 720 and abs(x - (1515 + math.sin(y * .012) * 38)) < 105:
        return False
    if math.hypot(x - 1000, y - 790) < 160 or math.hypot(x - 900, y - 520) < 100 or math.hypot(x - 1250, y - 300) < 190:
        return False
    return True


for tx, ty in LEGACY_TRUNKS:
    fo('APP:city_tree_green', tx, ty + 30, scale=.78)
_rb = random.Random(88012)
_placed = [(tx, ty) for tx, ty in LEGACY_TRUNKS]
_tries = 0
while len(_placed) < 200 and _tries < 9000:
    _tries += 1
    x, y = _rb.uniform(44, 1780), _rb.uniform(70, 830)
    if not bosque_free(x, y) or any(math.hypot(x - px, y - py) < 78 for px, py in _placed):
        continue
    _placed.append((x, y))
    kind = _rb.random()
    if kind < .42:
        fo('nat_tree_pine', x, y, solid=None)
    elif kind < .62:
        fo('nat_tree_birch', x, y, solid=None)
    elif kind < .9:
        fo('APP:city_tree_green', x, y)
        W.collider('circle', x, y - 6, 13, zone='floresta')
    else:
        fo('APP:city_tree_autumn', x, y)
        W.collider('circle', x, y - 6, 13, zone='floresta')
for _ in range(34):
    for _t in range(30):
        x, y = _rb.uniform(50, 1770), _rb.uniform(80, 820)
        if bosque_free(x, y):
            fo(_rb.choice(['nat_bush_green', 'nat_bush_berry', 'nat_bush_flowering', 'nat_flowers_red', 'nat_flowers_meadow', 'nat_grass_tall', 'nat_mushrooms', 'nat_rock_mossy', 'nat_rock_small']), x, y)
            break

# --- lampiões nas pontes (as vigas/tabuado/sombras estão pintadas no chão assado)
for _by in geo.BRIDGE_YS:
    _rx, _hw = geo.river_x(_by), geo.river_hw(_by)
    for _sx in (-1, 1):
        for _sy in (-1, 1):
            W.obj('city_lamp_post_a', _rx + _sx * (_hw + 66), _by + _sy * 64, 'PONTE', check=False)

# ============================================================================================
# CRIPTA ESQUECIDA — mini-dungeon opcional (zona 'cripta', 960x896)
# ============================================================================================


def cr(asset, x, y, **kw):
    W.obj(asset, x, y, 'CRIPTA_INT', zone='cripta', check=False, **kw)


CRYPT = {
    'entry': [480, 800],
    'walls': [
        {'rect': [40, 590, 400, 34], 'note': 'parede entre salão e câmara central (esq.)'},
        {'rect': [540, 590, 380, 34], 'note': 'parede entre salão e câmara central (dir.)'},
        {'rect': [40, 300, 400, 34], 'note': 'parede entre câmara central e tesouro (esq.)'},
        {'rect': [540, 300, 380, 34], 'note': 'parede entre câmara central e tesouro (dir.)'},
    ],
    'exit_y': 830,
}
for pxx in (170, 780):
    cr('dg_pillar', pxx, 760, solid=False)
cr('APP:dungeon_spikes', 480, 690, scale=.5, solid=False)
cr('APP:dungeon_spikes', 400, 740, scale=.5, solid=False)
cr('APP:dungeon_spikes', 560, 740, scale=.5, solid=False)
cr('dg_brazier', 330, 640, anim=1)
cr('dg_brazier', 630, 640, anim=1)
cr('APP:dungeon_arch', 480, 600, scale=.62, solid=False)
cr('dg_rune_circle', 480, 470, layer='ground', anim=1)
cr('dg_pillar', 250, 470)
cr('dg_pillar', 710, 470)
cr('dg_pillar_broken', 190, 380)
cr('dg_pillar_broken', 770, 380)
cr('dg_bones_pile', 330, 520)
cr('dg_barrel_old', 130, 530)
cr('dg_crate_old', 830, 540)
cr('dg_crystal_checkpoint', 800, 470, anim=1, poi='REG001_POI_CRIPTA_CHECKPOINT')
cr('APP:dungeon_arch', 480, 310, scale=.62, solid=False)
cr('dg_sarcophagus', 220, 200)
cr('dg_sarcophagus', 740, 200, flip=True)
cr('dg_altar_dark', 480, 180, anim=1, poi='REG001_POI_CRIPTA_ALTAR')
cr('nat_chest_rare', 600, 150, poi='REG001_POI_CRIPTA_CHEST')
cr('dg_brazier', 330, 130, anim=1)
cr('dg_brazier', 630, 250, anim=1)
cr('dg_stalagmites', 110, 140)
cr('dg_stalagmites', 860, 130)
cr('dg_mushroom_glow', 100, 330, anim=1, solid=False)
cr('APP:dungeon_crystal_blue', 880, 330, scale=.44, solid=False)
cr('APP:dungeon_crystal_purple', 90, 660, scale=.44, solid=False)
cr('APP:dungeon_torch', 210, 610, scale=.44, solid=False)
cr('APP:dungeon_torch', 750, 610, scale=.44, solid=False)
P('REG001_POI_CRIPTA_CHECKPOINT', 'checkpoint', 'CRISTAL DA CRIPTA', 800, 470, zone='cripta', tier=2, layer='main', radius=70, region='cripta',
  data={'heal': True, 'hint': 'O cristal pulsa em azul. Suas forças retornam.'})
P('REG001_POI_CRIPTA_ELITE', 'elite', 'GUARDIÃO DA CRIPTA', 480, 450, zone='cripta', tier=2, layer='secondary', radius=200, region='cripta',
  data={'enemy': 'Aranha Sombria', 'name': 'Tecelã da Cripta', 'hp_mult': 3.8, 'dmg_mult': 1.6, 'xp_mult': 5.0, 'gold_mult': 5.0, 'trigger': 230,
        'drop': {'materials': {'Seda sombria': 5}}, 'chest': 'REG001_POI_CRIPTA_CHEST'})
P('REG001_POI_CRIPTA_ALTAR', 'lore', 'ALTAR DA CRIPTA', 480, 180, zone='cripta', tier=2, layer='main', radius=80, region='cripta',
  data={'lore': 'REG001_LORE_12', 'prompt': 'Ler as inscrições'})
P('REG001_POI_CRIPTA_CHEST', 'chest', 'BAÚ DA CRIPTA', 600, 150, zone='cripta', tier=2, layer='secondary', radius=52, region='cripta', show_label=False,
  data={'requires_elite': 'REG001_POI_CRIPTA_ELITE', 'loot': {'gold': 180, 'materials': {'Fragmento de Eco': 2, 'Seda sombria': 4}, 'item': item('Lâmina da Cripta', 'sword', 2, 6, 3, 10, 0), 'potions': 3}})
for i, (sx, sy) in enumerate([(480, 690), (400, 740), (560, 740)]):
    P('REG001_POI_CRIPTA_TRAP_%d' % (i + 1), 'trap', 'ARMADILHA', sx, sy, zone='cripta', tier=2, layer='secondary', radius=34, region='cripta', show_label=False, data={'damage': 5, 'period': 2.6, 'phase': i * .8})

# ============================================================================================
# CIDADE DE VALEDOURO — arquitetura com peças APPROVED (casas compostas, muralha, água, lojas, árvores)
# ============================================================================================
# As 4 casas de interior (guilda, ferreiro, loja, alquimia) e a muralha norte/portão são desenhadas em main.gd com as
# mesmas peças; aqui entram as colisões delas e as demais construções, respeitando ruas e portas.
TOWN_ROADS = [(810, 0, 160, 887), (0, 413, 1774, 130), (401, 0, 94, 478), (1254, 478, 92, 409)]   # x, y, w, h (locais)


def _town_free(x, y, w=176, h=44, pad=6):
    rx0, ry0, rx1, ry1 = x - w / 2 - pad, y - 38 - pad, x + w / 2 + pad, y + 6 + pad
    for a, b, c, d in TOWN_ROADS:
        if rx0 < a + c and rx1 > a and ry0 < b + d and ry1 > b:
            return False
    return True


def town_house(x, y, roof, group='CIDADE_CASAS'):
    if not _town_free(x, y):
        W.warnings.append('casa da cidade sobre a rua: (%d,%d)' % (x, y))
    W.house(TX + x, TY + y, roof, group)


for _hx, _hy in ((485, 330), (1245, 340), (470, 615), (1280, 625)):     # casas de interior (desenhadas em main.gd)
    W.collider('rect', TX + _hx - 88, TY + _hy - 38, 176, 44)
W.collider('rect', TX + 1570 - 70, TY + 630 - 36, 140, 40)           # loja decorativa
for _hx, _hy, _roof in ((120, 300, 'city_roof_blue'), (275, 285, 'city_roof_wood'), (640, 335, 'city_roof_red'), (1075, 345, 'city_roof_wood'),
                        (1440, 330, 'city_roof_blue'), (1640, 300, 'city_roof_red'), (120, 640, 'city_roof_wood'), (285, 665, 'city_roof_blue'),
                        (640, 665, 'city_roof_red'), (1100, 690, 'city_roof_blue'), (1470, 690, 'city_roof_wood')):
    town_house(_hx, _hy, _roof)

# muralha sul com vão só na rua sul (x≈1300), fechada no resto; portão aprovado no vão
_WALL_S = 800
for _i in range(15):
    _wx = 60 + _i * 116
    if abs(_wx - 1300) < 110:
        continue
    _wy = TY + _WALL_S
    W.obj('APP:city_wall_vegetation' if _i % 4 == 0 else 'APP:city_wall', TX + _wx, _wy, 'CIDADE_MURO', scale=.58, solid=False, check=False)
    W.collider('rect', TX + _wx - 58, _wy - 26, 116, 24)
W.obj('APP:city_gate', TX + 1300, TY + _WALL_S + 6, 'CIDADE_MURO', scale=.58, solid=False, check=False, sy=TY + _WALL_S - 60)
W.collider('rect', TX + 1300 - 128, TY + _WALL_S - 26, 40, 24)
W.collider('rect', TX + 1300 + 88, TY + _WALL_S - 26, 40, 24)

# lagoas com a peça aprovada water_edge (jardins) e lojas de mercado aprovadas
for _wx, _wy in ((215, 470), (1560, 470)):
    W.obj('APP:city_water_edge', TX + _wx, TY + _wy, 'CIDADE_AGUA', scale=.58, solid=False, check=False)
    W.collider('rect', TX + _wx - 60, TY + _wy - 46, 120, 50)
W.obj('APP:city_store', TX + 1720, TY + 470, 'CIDADE_LOJAS', scale=.58, solid=False, check=False)
W.collider('rect', TX + 1720 - 70, TY + 470 - 36, 140, 40)

# povoados: mais casas compostas APPROVED (Vila dos Campos, Aldeia do Vale, casa da fazenda)
for _x, _y, _roof, _grp, _poi in ((345, 1835, 'city_roof_red', 'VILA_C', 'REG001_POI_VILA_CAMPOS'), (700, 1820, 'city_roof_wood', 'VILA_C', 'REG001_POI_VILA_CAMPOS'),
                                  (1185, 1690, 'city_roof_red', 'ALDEIA_V', 'REG001_POI_ALDEIA_VALE'), (1425, 1700, 'city_roof_wood', 'ALDEIA_V', 'REG001_POI_ALDEIA_VALE'),
                                  (600, 2070, 'city_roof_blue', 'FAZENDA', None)):
    W.house(_x, _y, _roof, _grp, poi=_poi)

# árvores aprovadas: alamedas ao longo das ruas e jardins
_rt = random.Random(4242)
for _tx, _ty in ((370, 250), (525, 250), (760, 255), (1040, 250), (1200, 250), (1330, 250), (60, 470), (60, 700), (340, 520), (560, 560),
                 (760, 720), (1130, 560), (1200, 740), (1400, 520), (1720, 640), (1720, 300), (700, 480), (1060, 470)):
    if _town_free(_tx, _ty, w=60, h=40, pad=0):
        W.obj('APP:city_tree_autumn' if _rt.random() < .25 else 'APP:city_tree_green', TX + _tx, TY + _ty, 'CIDADE_ARV', scale=.5, solid=False, check=False)
        W.collider('circle', TX + _tx, TY + _ty - 4, 14)

# ============================================================================================
# FINALIZAÇÃO DE ASSETS — estruturas modeladas, fazenda, cais, cachoeira e elevações
# ============================================================================================
# marcos que eram sprites legados (STRUCTURES em world_map.gd continua fornecendo colisão/exclusão de vegetação)
W.obj('str_watchtower_stone', 360, 1112, 'MARCO', poi='REG001_POI_MIRANTE_OESTE', check=False)
W.obj('str_watchtower_stone', 1320, 347, 'MARCO', poi='REG001_POI_MIRANTE_NORTE', check=False)
W.obj('str_windmill', 1110, 1882, 'MARCO', anim=1, check=False)
W.obj('str_shrine_stone', 1660, 2022, 'MARCO', anim=1, poi='REG001_POI_SANTUARIO_VALE', check=False)
W.obj('str_outpost_amber', 2690, 1800, 'MARCO', check=False)
W.obj('str_lodge_ice', 2700, 604, 'MARCO', check=False)
W.obj('str_watchtower_frost', 2905, 655, 'MARCO', poi='REG001_POI_MIRANTE_GELO', check=False)
W.obj('str_cave_entrance', 3010, 118, 'SEG_GELO', show_when='REG001_POI_SEGREDO_GELO', layer='secret_show', solid=False, check=False)

# cachoeira frontal na cabeceira do rio (rochas laterais colidem; a água central já é intransitável)
W.obj('nat_waterfall_front', geo.river_x(471), 480, 'CACHOEIRA', anim=1, check=False)

# fazenda: canteiros dentro da cerca em losango + celeiro fora do portão
W.obj('str_crop_wheat', 268, 2050, 'FAZENDA', layer='ground', scale=.62, solid=False, check=False)
W.obj('str_crop_cabbage', 344, 2066, 'FAZENDA', layer='ground', scale=.62, solid=False, check=False)
W.obj('str_crop_corn', 300, 2094, 'FAZENDA', layer='ground', scale=.62, solid=False, check=False)
W.obj('str_scarecrow', 322, 2030, 'FAZENDA', check=False)
W.obj('str_barn', 470, 2150, 'FAZENDA', check=False)

# moinho do vale: trigo em faixa a oeste (vento aberto), feno junto ao moinho e cerca baixa — o moinho existe por causa das lavouras
for _cy in (1832, 1900, 1968):
    W.obj('str_crop_wheat', 1026, _cy, 'MOINHO_L', layer='ground', scale=.62, solid=False, check=False)
W.obj('str_crop_wheat', 1080, 2018, 'MOINHO_L', layer='ground', scale=.62, solid=False, check=False)
W.obj('nat_hay_stack', 1072, 1892, 'MOINHO_L', check=False)
W.obj('nat_hay_bale', 1060, 1934, 'MOINHO_L', check=False)
W.obj('nat_fence_wood_a', 968, 1856, 'MOINHO_L', check=False)
W.obj('nat_fence_wood_b', 968, 1990, 'MOINHO_L', check=False)

# cais e barcos ao longo do rio (margem oeste)
for _y, _kind in ((990, 'str_dock_a'), (1400, 'str_dock_a'), (2000, 'str_dock_b')):
    _rx, _hw = geo.river_x(_y), geo.river_hw(_y)
    W.obj(_kind, _rx - _hw + 4, _y, 'CAIS', check=False)
    W.obj('str_dock_end', _rx - _hw - 4, _y + 46, 'CAIS', check=False)
for _y, _s in ((990, 1), (1400, 1), (2000, 1)):
    _rx, _hw = geo.river_x(_y), geo.river_hw(_y)
    W.obj('city_crates', _rx - _hw - 44, _y - 34, 'CAIS_CARGA', check=False)
    W.obj('city_barrels', _rx - _hw - 74, _y - 8, 'CAIS_CARGA', check=False)
W.obj('str_boat_row', geo.river_x(1400) + 4, 1428, 'CAIS', solid=False, anim=1, check=False)
W.obj('str_boat_sail', geo.river_x(990) + 20, 1030, 'CAIS', solid=False, anim=1, check=False)
W.obj('str_boat_row', geo.river_x(2000) + 6, 2040, 'CAIS', solid=False, anim=1, check=False)


# ── RELEVO E LEVEL DESIGN DAS FORMAÇÕES ─────────────────────────────────────────────────────────────
# Cada formação é composta (cristas, paredões, colinas de pé, platôs com degraus) e colocada peça a peça com
# _elev_ok: onde uma peça bateria em trilha, POI, água ou estrutura ela some — isso abre passagens naturais.
_re = random.Random(60117)
_elev_done = []          # (x, y, raio, grupo)
_ELEV_LOG = {}
ELEV_RAD = {'hill': 55, 'plateau_s': 58, 'plateau_m': 78, 'ridge': 74, 'wall': 62}


def _erad(asset):
    for k, v in (('hill_wide', 88), ('hill_low', 46), ('cliff_end', 56), ('cliff_corner', 72), ('ramp', 40), ('hill', 55), ('plateau_earth_s', 58), ('plateau_rock_s', 58), ('plateau_sand_s', 58), ('plateau_ice_s', 58), ('plateau', 78), ('ridge', 74), ('wall', 62), ('arch', 60), ('pillars', 40), ('steps', 50)):
        if k in asset:
            return v
    return 60


def _elev_ok(x, y, rad, group=None):
    if not (60 < x < 3010 and 60 < y < 2240):
        return False
    for dx, dy in ((0, 0), (rad * .5, 0), (-rad * .5, 0), (0, rad * .3), (0, -rad * .3)):
        if geo.terrain(x + dx, y + dy) in ('water', 'shallow', 'bridge', 'path', 'bank', 'cidade'):
            return False
    if geo.near_structure(x, y, rad * .6 + 10):
        return False
    for cx, cy, cr in W.clear_zones:
        if math.hypot(x - cx, y - cy) < cr * .62 + rad * .25:
            return False
    for t in TRAILS:
        for a, b in zip(t['pts'], t['pts'][1:]):
            if _seg_dist(x, y, a[0], a[1], b[0], b[1]) < t['half'] + rad * .45 + 14:
                return False
    for o in W.objects:
        if o['zone'] != 'cidade':
            continue
        if math.hypot(x - o['pos'][0], y - o['pos'][1]) < (rad * .5 + 16 if o.get('solid') else rad * .3 + 6):
            return False
    for px, py, pr, pg in _elev_done:
        same = group is not None and pg == group
        if math.hypot(x - px, y - py) < ((rad + pr) * .5 if same else rad + pr + 14):
            return False
    return True


_OFF = [0.0, 0.0]
_DRY = [False]
_REGION = [None]
_DRYLOG = []


def _elev_why(x, y, rad, group):
    for px, py, pr, pg in _elev_done:
        if math.hypot(x - px, y - py) < ((rad + pr) * .5 if group == pg else rad + pr + 14):
            return ('elev', round(px), round(py), pg)
    for o in W.objects:
        if o['zone'] == 'cidade' and math.hypot(x - o['pos'][0], y - o['pos'][1]) < (rad * .5 + 16 if o.get('solid') else rad * .3 + 6):
            return ('obj', o['asset'], [round(v) for v in o['pos']])
    for cx, cy, cr in W.clear_zones:
        if math.hypot(x - cx, y - cy) < cr * .62 + rad * .25:
            return ('clear', cx, cy, cr)
    return 'terr/trail/struct'


def _put(asset, x, y, group, solid=None, flip=False):
    x, y = x + _OFF[0], y + _OFF[1]
    rad = _erad(asset)
    if 'hill_low' in asset or 'nat_ramp' in asset:
        solid = False
    if _REGION[0] and geo.biome(x, y) != _REGION[0]:
        return False
    if not _elev_ok(x, y, rad, group):
        if os.environ.get('ELEVDBG2') == group and _OFF == [0.0, 0.0]:
            print('  FAIL', asset, round(x), round(y), _elev_why(x, y, rad, group))
        return False
    if not _DRY[0]:
        W.obj(asset, x, y, 'ELEV', check=False, flip=flip, **({} if solid is None else {'solid': solid}))
    _elev_done.append((x, y, rad, group))
    return True


def best(region, fn, *args, tries=28, spread=90, **kw):
    """Testa deslocamentos da formação e fixa o que coloca mais peças (âncoras são só sugestões)."""
    mark = len(_elev_done)
    _REGION[0] = region
    cands = [(0.0, 0.0)] + [(_re.uniform(-spread, spread), _re.uniform(-spread, spread)) for _ in range(tries)]
    top, top_off = -99.0, (0.0, 0.0)
    for off in cands:
        _OFF[0], _OFF[1] = off
        _DRY[0] = True
        n = int(fn(*args, **kw))
        del _elev_done[mark:]
        if os.environ.get('ELEVDBG'):
            print('  cand', region, fn.__name__, args[-1] if args and isinstance(args[-1], str) else args[-2:], [round(v) for v in off], n)
        score = n - .004 * math.hypot(off[0], off[1])
        if score > top:
            top, top_off = score, off
    _DRY[0] = False
    _OFF[0], _OFF[1] = top_off
    n = int(fn(*args, **kw))
    _OFF[0], _OFF[1] = 0.0, 0.0
    _REGION[0] = None
    return n


def _fam_asset(kind, fam, ori='a'):
    if kind == 'hill':
        return 'nat_hill_' + ('earth' if fam == 'rock' else fam)
    if kind == 'hillw':
        return 'nat_hill_wide_' + fam
    if kind == 'hilll':
        return 'nat_hill_low_' + fam
    if kind == 'ramp':
        return 'nat_ramp_' + fam
    if kind == 'corner':
        return 'nat_cliff_corner_' + ('rock' if fam == 'earth' else fam)
    if kind == 'wall' and fam == 'earth':
        fam = 'rock'
    if kind in ('ridge', 'wall'):
        return 'nat_%s_%s_%s' % ('ridge' if kind == 'ridge' else 'wall_cliff', fam, ori)
    return 'nat_plateau_%s_%s' % (fam, kind[-1])        # 'plat_s' / 'plat_m'


def poly(fam, pts, name, kinds=('ridge', 'wall'), spacing=76, foot=3, gaps=(), cap=True, side=1):
    """Cadeia de cristas/paredões ao longo de uma polilinha, com colinas de pé e tampas nas pontas."""
    n_ok = 0
    idx = 0
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        L = math.hypot(bx - ax, by - ay)
        steps = max(1, int(L / spacing))
        ori = 'a' if (bx - ax) * (by - ay) < 0 else 'b'      # 'a' = '/', 'b' = '\\'
        for i in range(steps + 1):
            t = i / steps
            x, y = ax + (bx - ax) * t, ay + (by - ay) * t
            if idx in gaps:
                idx += 1
                continue
            px, py = -(by - ay) / L, (bx - ax) / L
            j = ((idx * 37) % 5 - 2) * 5.0
            kind = kinds[idx % len(kinds)]
            if _put(_fam_asset(kind, fam, ori), x + px * j, y + py * j, name):
                n_ok += 1
            if foot and idx % foot == 1 and _put(_fam_asset('hilll' if idx % 2 else 'hillw', fam), x + px * 78 * side, y + py * 78 * side * .8, name):
                n_ok += 1
            idx += 1
    if cap:
        wf = 'rock' if fam == 'earth' else fam
        for k, ((x, y), (ox, oy)) in enumerate(((pts[0], pts[1]), (pts[-1], pts[-2]))):
            dx, dy = x - ox, y - oy                      # sentido para fora da formação
            L = math.hypot(dx, dy) or 1.0
            ori = 'a' if dx * dy < 0 else 'b'
            sg = 'p' if dy >= 0 else 'm'
            if _put('nat_cliff_end_%s_%s%s' % (wf, ori, sg), x + dx / L * 48, y + dy / L * 48, name):
                n_ok += 1
    return n_ok


def mesa(fam, x, y, name, steps_dir=1):
    """Platô com colinas de pé e degraus para o lado da trilha."""
    n = 0
    n += _put(_fam_asset('plat_m', fam), x, y, name)
    n += _put(_fam_asset('plat_s', fam), x - 175 * steps_dir, y + 58, name)
    n += _put(_fam_asset('hillw', fam), x + 120 * steps_dir, y + 52, name)
    n += _put(_fam_asset('hilll', fam), x - 24, y - 96, name)
    n += _put('nat_ramp_' + fam, x - 90 * steps_dir, y + 48, name, solid=False, flip=steps_dir < 0)
    return n


def terraces(fam, x, y, name, n=3, dir_=1):
    """Degraus de terreno: platôs pequenos encadeados subindo em diagonal."""
    k = 0
    for i in range(n):
        k += _put(_fam_asset('plat_m' if i == n - 1 else 'plat_s', fam), x + dir_ * i * 104, y - i * 52, name)
    k += _put('nat_ramp_' + fam, x - dir_ * 92, y + 46, name, solid=False, flip=dir_ < 0)
    return k


def arc(fam, cx, cy, r, a0, a1, n, name, kinds=('wall', 'ridge')):
    """Arco de paredões (anfiteatro). Ângulos em graus, 0 = leste, 90 = sul."""
    k = 0
    for i in range(n):
        a = math.radians(a0 + (a1 - a0) * i / max(1, n - 1))
        x, y = cx + math.cos(a) * r, cy + math.sin(a) * r * .62
        ori = 'a' if math.cos(a) * math.sin(a) > 0 else 'b'
        k += _put(_fam_asset(kinds[i % len(kinds)], fam, ori), x, y, name)
    return k


def scatter(region, fam, kinds, n, box_, name, tries=4000):
    placed = 0
    for _ in range(tries):
        if placed >= n:
            break
        kind = kinds[placed % len(kinds)]
        ori = _re.choice('ab')
        x, y = _re.uniform(box_[0], box_[2]), _re.uniform(box_[1], box_[3])
        if geo.biome(x, y) != region:
            continue
        if _put(_fam_asset(kind, fam, ori), x, y, name + str(placed)):
            placed += 1
    return placed


def formations():
    L = _ELEV_LOG
    # ordem: espinhas longas primeiro, depois mesas/terraços, por fim preenchimento pontual
    # ── GELO: muralha glacial a oeste (divisa com o Bosque), anfiteatro do Círculo de Gelo, garganta da Passagem Estreita
    L['gelo_muralha_w'] = best('gelo', poly, 'ice', [(2052, 110), (2060, 260), (2050, 420), (2070, 600)], 'g_mw', kinds=('wall', 'ridge'), foot=3, side=1)
    L['gelo_anfiteatro'] = best('gelo', arc, 'ice', 2800, 250, 270, 205, 335, 8, 'g_anf')
    L['gelo_garganta_e'] = best('gelo', poly, 'ice', [(2690, 120), (2700, 250), (2690, 420), (2700, 520)], 'g_ge', kinds=('ridge', 'wall'), foot=2)
    L['gelo_muralha_n'] = best('gelo', poly, 'ice', [(2200, 90), (2400, 80)], 'g_mn', kinds=('wall', 'ridge'), spacing=92, foot=4)
    L['gelo_mirante'] = best('gelo', mesa, 'ice', 2980, 540, 'g_mir', steps_dir=-1)
    L['gelo_mesa_oeste'] = best('gelo', mesa, 'ice', 2110, 400, 'g_mo')
    L['gelo_fill'] = scatter('gelo', 'ice', ['hillw', 'hilll', 'plat_s', 'ridge', 'hilll'], 8, (2060, 60, 3040, 840), 'g_f')
    # ── PRADARIA (colinas leste): cordilheira baixa ao norte, terraços em degraus, colinas ao sul
    L['prad_cordilheira'] = best('pradaria', poly, 'earth', [(2680, 900), (2800, 880), (2960, 905)], 'p_c', kinds=('ridge', 'wall'), spacing=84, foot=3)
    L['prad_terraco_a'] = best('pradaria', terraces, 'earth', 2640, 1010, 'p_ta', 3, 1)
    L['prad_terraco_b'] = best('pradaria', terraces, 'earth', 2900, 1290, 'p_tb', 3, -1)
    L['prad_sul'] = best('pradaria', poly, 'earth', [(2650, 1350), (2800, 1340), (2960, 1360)], 'p_s', kinds=('ridge', 'wall'), foot=3, side=-1)
    L['prad_fill'] = scatter('pradaria', 'earth', ['hillw', 'hilll', 'plat_s', 'hillw', 'hilll', 'ridge'], 10, (2430, 860, 3040, 1380), 'p_f')
    # ── DESERTO: serra ao sul, cânion (duas paredes com corredor), mesas
    L['des_serra_sul'] = best('deserto', poly, 'sand', [(2060, 2190), (2260, 2230), (2620, 2235), (2960, 2215)], 'd_ss', kinds=('wall', 'ridge'), spacing=90, foot=3, side=-1)
    L['des_canyon_w'] = best('deserto', poly, 'sand', [(2560, 1700), (2680, 1760), (2800, 1820)], 'd_cw', kinds=('wall', 'ridge'), foot=2, side=-1)
    L['des_canyon_e'] = best('deserto', poly, 'sand', [(2680, 1560), (2800, 1620), (2920, 1680)], 'd_ce', kinds=('ridge', 'wall'), foot=2)
    L['des_mesa_1'] = best('deserto', mesa, 'sand', 2130, 1500, 'd_m1')
    L['des_mesa_2'] = best('deserto', mesa, 'sand', 2800, 1960, 'd_m2', steps_dir=-1)
    L['des_mesa_3'] = best('deserto', mesa, 'sand', 2160, 1990, 'd_m3')
    L['des_fill'] = scatter('deserto', 'sand', ['hillw', 'hilll', 'plat_s', 'ridge', 'hilll', 'hillw'], 10, (1990, 1380, 3040, 2260), 'd_f')
    # ── VALE: cristas de pedra, patamares, anel de colinas ao redor do Santuário
    L['vale_crista_n'] = best('vale', poly, 'rock', [(880, 1690), (1000, 1660), (1180, 1650), (1300, 1650)], 'v_cn', kinds=('ridge', 'wall'), foot=3)
    L['vale_anel'] = best('vale', poly, 'rock', [(1560, 2130), (1470, 2090), (1470, 1990)], 'v_a', kinds=('ridge', 'wall'), foot=2)
    L['vale_patamar'] = best('vale', terraces, 'rock', 1040, 2080, 'v_t', 3, 1)
    L['vale_leste'] = best('vale', poly, 'rock', [(1880, 1720), (1920, 1840), (1900, 1960)], 'v_l', kinds=('wall', 'ridge'), foot=2)
    L['vale_fill'] = scatter('vale', 'rock', ['hillw', 'hilll', 'plat_s', 'hilll', 'ridge'], 8, (760, 1570, 2010, 2280), 'v_f')
    # ── CAMPOS: colinas suaves entre as cercas da fazenda
    L['campos_colinas'] = best('campos', poly, 'earth', [(120, 1690), (260, 1650), (420, 1690)], 'c_a', kinds=('ridge', 'hill'), foot=0)
    L['campos_terraco'] = best('campos', terraces, 'earth', 470, 2190, 'c_t', 3, 1)
    L['campos_fill'] = scatter('campos', 'earth', ['hillw', 'hilll', 'hillw', 'hilll'], 7, (40, 1570, 760, 2280), 'c_f')
    # ── FLORESTA: patamares no sul do bosque e cristas de pedra
    L['flor_sul'] = best('floresta', poly, 'rock', [(80, 1300), (240, 1400), (420, 1440)], 'f_s', kinds=('wall', 'ridge'), foot=3, side=-1)
    L['flor_mesa'] = best('floresta', mesa, 'rock', 560, 1340, 'f_m')
    L['flor_norte'] = best('floresta', poly, 'rock', [(1560, 500), (1700, 440), (1880, 470)], 'f_n', kinds=('ridge', 'wall'), foot=3)
    L['flor_fill'] = scatter('floresta', 'rock', ['plat_m', 'hilll', 'ridge', 'hillw', 'hilll'], 8, (40, 900, 1040, 1570), 'f_f')
    for _asset, _x, _y, _sol in (('nat_rock_arch_natural', 2420, 700, None), ('nat_steps_stone', 1580, 1120, False), ('str_shelter_wood', 1420, 640, None), ('nat_rock_pillars', 2350, 1900, None)):
        if _elev_ok(_x, _y, _erad(_asset)):
            W.obj(_asset, _x, _y, 'ELEV', solid=_sol, check=False)
    print('ELEVAÇÕES', sum(_ELEV_LOG.values()), _ELEV_LOG)


formations()

LORE = {
    'REG001_LORE_01': {'title': 'Diário do lenhador', 'text': 'O vento mudou de direção três noites seguidas. Ouvi passos no bosque que não eram de lobo. Deixei o fogo aceso para enganá-los.'},
    'REG001_LORE_02': {'title': 'Bilhete na porta', 'text': '"Partimos para a Vila dos Campos. Se voltar, procure sob o alpendre: escondemos tudo que pudemos."'},
    'REG001_LORE_03': {'title': 'Marcas na clareira', 'text': 'As pedras formam um círculo com símbolos gastos pelo tempo. O Lobo Ancião guarda o lugar desde antes da Guerra da Coroa Oca.'},
    'REG001_LORE_04': {'title': 'Passagem esquecida', 'text': 'Atrás dos galhos, um arco antigo. Alguém o escondeu de propósito — e voltou aqui muitas vezes.'},
    'REG001_LORE_05': {'title': 'Altar do Primeiro Vento', 'text': 'Os Viajantes chegam por onde o vento nasce. O altar vibra quando alguém de outro mundo se aproxima... e vibra agora.'},
    'REG001_LORE_06': {'title': 'Teia antiga', 'text': 'A teia guarda restos de um mapa. Ele aponta para uma cripta ao sul, sob o Vale dos Lírios.'},
    'REG001_LORE_07': {'title': 'Santuário do Vale', 'text': 'Erguido por quem cruzou o Limiar antes de você. A luz responde ao sangue dos Viajantes.'},
    'REG001_LORE_08': {'title': 'Círculo de gelo', 'text': 'O gelo aqui nunca derrete. Dentro dele, o reflexo de um homem de casaco azul: Adrian Vale, ainda humano.'},
    'REG001_LORE_09': {'title': 'Gruta congelada', 'text': 'Cartas seladas em gelo: "Se Azharel me encontrar, diga aos Sete Sigilos que não fui eu quem partiu."'},
    'REG001_LORE_10': {'title': 'Ruínas das Dunas', 'text': 'A areia esconde uma cidade inteira. No altar, a mesma runa que você viu no bosque: um caminho, um Limiar, uma escolha.'},
    'REG001_LORE_11': {'title': 'Câmara enterrada', 'text': 'Uma câmara selada pela duna. Sarcófagos vazios: quem dormia aqui já acordou.'},
    'REG001_LORE_12': {'title': 'Cripta Esquecida', 'text': 'Aqui repousam os que guardaram o Limiar. A última inscrição diz: "O Coração escolhe quem o carrega."'},
}


def check_trails():
    for o in W.objects:
        r = o.get('solid', 0)
        if not r or o['zone'] != 'cidade' or o.get('layer') in ('secret_hide', 'gate'):
            continue
        for t in TRAILS:
            pts = t['pts']
            if min(math.hypot(o['pos'][0] - pts[0][0], o['pos'][1] - pts[0][1]), math.hypot(o['pos'][0] - pts[-1][0], o['pos'][1] - pts[-1][1])) < 130:
                continue
            for a, b in zip(pts, pts[1:]):
                ax, ay, bx, by = a[0], a[1], b[0], b[1]
                dx, dy = bx - ax, by - ay
                L2 = dx * dx + dy * dy or 1
                u = max(0, min(1, ((o['pos'][0] - ax) * dx + (o['pos'][1] - ay) * dy) / L2))
                d = math.hypot(o['pos'][0] - (ax + dx * u), o['pos'][1] - (ay + dy * u))
                if d < t['half'] * .8 + r:
                    W.warnings.append('trilha %s bloqueada por %s %s' % (t['id'], o['asset'], o['pos']))


def build():
    check_trails()
    doc = {
        'schema_version': 1,
        'world_id': 'REG001_WORLD_V1',
        'region_id': 'REG_001',
        'seed': 270901,
        'chunk_size': 512,
        'counts': {'objects': len(W.objects), 'pois': len(W.pois), 'passages': len(W.passages), 'trails': len(TRAILS), 'colliders': len(W.colliders), 'emitters': len(W.emitters), 'lore': len(LORE)},
        'biome_style': {
            'floresta': {'decals': ['nat_decal_grass_a', 'nat_decal_grass_b'], 'edge': ['nat_mushrooms', 'nat_bush_berry', 'nat_flowers_red']},
            'pradaria': {'decals': ['nat_decal_grass_a', 'nat_decal_grass_b'], 'edge': ['nat_flowers_meadow', 'nat_bush_green']},
            'campos': {'decals': ['nat_decal_grass_b', 'nat_decal_dry_a'], 'edge': ['nat_flowers_meadow', 'nat_hay_bale']},
            'vale': {'decals': ['nat_decal_grass_a'], 'edge': ['nat_flowers_blue', 'nat_bush_flowering']},
            'gelo': {'decals': ['nat_decal_snow_a', 'nat_decal_snow_b'], 'edge': ['nat_snow_mound', 'nat_rock_snow', 'nat_bush_frost']},
            'deserto': {'decals': ['nat_decal_sand_a', 'nat_decal_sand_b'], 'edge': ['nat_grass_dry', 'nat_bush_dry', 'nat_rock_sand']},
            'cidade': {'decals': ['nat_decal_dirt_a'], 'edge': ['nat_grass_tall']},
        },
        'transitions': [
            {'id': 'REG001_TR_CIDADE_CAMPOS', 'between': ['cidade', 'campos'], 'width': 130},
            {'id': 'REG001_TR_CAMPOS_FLORESTA', 'between': ['campos', 'floresta'], 'width': 150},
            {'id': 'REG001_TR_FLORESTA_VALE', 'between': ['floresta', 'vale'], 'width': 150},
            {'id': 'REG001_TR_CIDADE_VALE', 'between': ['cidade', 'vale'], 'width': 130},
            {'id': 'REG001_TR_CIDADE_FLORESTA', 'between': ['cidade', 'floresta'], 'width': 130},
            {'id': 'REG001_TR_FLORESTA_GELO', 'between': ['floresta', 'gelo'], 'width': 160},
            {'id': 'REG001_TR_COLINAS_GELO', 'between': ['pradaria', 'gelo'], 'width': 160},
            {'id': 'REG001_TR_COLINAS_DESERTO', 'between': ['pradaria', 'deserto'], 'width': 160},
            {'id': 'REG001_TR_VALE_DESERTO', 'between': ['vale', 'deserto'], 'width': 160},
            {'id': 'REG001_TR_CAMPOS_DESERTO', 'between': ['campos', 'deserto'], 'width': 160},
        ],
        'trails': TRAILS,
        'clear_zones': W.clear_zones,
        'passages': W.passages,
        'pois': W.pois,
        'objects': W.objects,
        'colliders': W.colliders,
        'emitters': W.emitters,
        'lore': LORE,
        'mini_dungeon': CRYPT,
    }
    OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=None, separators=(',', ':')) + '\n', encoding='utf-8')
    return doc


def preview(path):
    from PIL import Image, ImageDraw
    k = .34
    im = Image.new('RGB', (int(3072 * k), int(2304 * k)))
    px = im.load()
    col = {'bridge': (140, 100, 60), 'water': (40, 110, 190), 'shallow': (90, 170, 220), 'path': (190, 150, 90), 'bank': (110, 140, 90),
           'cidade': (150, 130, 110), 'floresta': (30, 90, 50), 'pradaria': (90, 150, 70), 'campos': (120, 170, 80), 'vale': (80, 140, 90), 'gelo': (200, 225, 240), 'deserto': (225, 195, 130)}
    for y in range(im.height):
        for x in range(im.width):
            px[x, y] = col[geo.terrain(x / k, y / k)]
    d = ImageDraw.Draw(im)
    for t in TRAILS:
        pts = [(a * k, b * k) for a, b in t['pts']]
        d.line(pts, fill=(230, 200, 140), width=max(2, int(t['half'] * k)))
    for o in W.objects:
        if o['zone'] != 'cidade':
            continue
        x, y = o['pos'][0] * k, o['pos'][1] * k
        if o['asset'].startswith('nat_') and any(t in o['asset'] for t in ('hill', 'plateau', 'ridge', 'wall_cliff')):
            r = 7 if 'plateau_' in o['asset'] and o['asset'].endswith('_m') else 5
            d.ellipse((x - r, y - r * .6, x + r, y + r * .6), fill=(120, 60, 30), outline=(255, 255, 255))
            continue
        c = (255, 60, 60) if o.get('solid') else (60, 60, 60)
        d.ellipse((x - 1.5, y - 1.5, x + 1.5, y + 1.5), fill=c)
    for p in W.pois:
        if p['zone'] != 'cidade':
            continue
        x, y = p['pos'][0] * k, p['pos'][1] * k
        colr = {'elite': (255, 0, 255), 'chest': (255, 220, 0), 'secret': (0, 255, 255), 'settlement': (255, 255, 255), 'resource': (0, 255, 0)}.get(p['kind'], (255, 128, 0))
        d.ellipse((x - 4, y - 4, x + 4, y + 4), outline=colr, width=2)
    im.save(path)


if __name__ == '__main__':
    doc = build()
    print('objects', len(W.objects), 'pois', len(W.pois), 'passages', len(W.passages), 'colliders', len(W.colliders))
    for w in W.warnings:
        print('AVISO', w)
    if '--preview' in sys.argv:
        preview(sys.argv[sys.argv.index('--preview') + 1])
