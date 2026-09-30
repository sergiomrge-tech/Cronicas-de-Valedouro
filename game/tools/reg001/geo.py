"""Geografia da REG_001 para o gerador de conteúdo. Remapeamento Etapa 1: estradas, cidade, biomas e estruturas vêm de
data/reg001_layout.json via layout.py (a MESMA fonte que gera a grade lida por scripts/world_map.gd). O rio segue analítico."""
import math

import layout

SIZE = (3072, 2304)
TOWN = (650, 680)
TOWN_SIZE = (1774, 887)
BRIDGE_YS = [760.0, 1250.0, 1840.0]
STRUCTURES = [(tuple(e['pos']), e['radius']) for e in layout.L['structures']]


def river_x(y):
    return 2220.0 + math.sin(y * 0.006) * 78.0 + math.sin(y * 0.017) * 23.0 + math.sin(y * 0.0024 + 1.3) * 34.0


def river_hw(y):
    return 48.0 + math.sin(y * 0.0041 + .6) * 8.0 + math.sin(y * 0.013) * 5.0


def town_area(x, y):
    return layout.town_area(x, y)


def bridge_at(x, y):
    for by in BRIDGE_YS:
        if abs(y - by) < 50.0 and abs(x - river_x(by)) < river_hw(by) + 68.0:
            return True
    return False


def river_at(x, y):
    return y > 242 and abs(x - river_x(y)) < river_hw(y)


def shallow_at(x, y):
    if y <= 242 or bridge_at(x, y):
        return False
    d = abs(x - river_x(y))
    return river_hw(y) <= d < river_hw(y) + 12.0


def bank_at(x, y):
    if y <= 242 or bridge_at(x, y):
        return False
    d = abs(x - river_x(y))
    return river_hw(y) + 12.0 <= d < river_hw(y) + 39.0


def biome(x, y):
    return layout.biome(x, y)


def path_at(x, y):
    return layout.path_at(x, y)


def near_structure(x, y, pad=0.0):
    return any(math.hypot(x - c[0], y - c[1]) < r + pad for c, r in STRUCTURES)


def terrain(x, y):
    if bridge_at(x, y):
        return 'bridge'
    if river_at(x, y):
        return 'water'
    if shallow_at(x, y):
        return 'shallow'
    if path_at(x, y):
        return 'path'
    if bank_at(x, y):
        return 'bank'
    return biome(x, y)


if __name__ == '__main__':
    glyph = {'bridge': '=', 'water': '~', 'shallow': ',', 'path': '.', 'bank': ':', 'cidade': '#', 'floresta': 'F', 'pradaria': 'p', 'campos': 'c', 'vale': 'v', 'gelo': 'I', 'deserto': 'D'}
    for gy in range(0, 2304, 48):
        print('%4d ' % gy + ''.join(glyph[terrain(gx + 12, gy + 12)] for gx in range(0, 3072, 32)))
