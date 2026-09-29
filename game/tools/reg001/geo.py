"""Porta em Python da geografia de scripts/world_map.gd (para o gerador de conteúdo REG_001).
A fonte de verdade continua sendo o GDScript; os testes nativos validam o resultado final."""
import math

SIZE = (3072, 2304)
TOWN = (650, 680)
TOWN_SIZE = (1774, 887)
BRIDGE_YS = [760.0, 1250.0, 1840.0]
STRUCTURES = [
    ((360, 1110), 42), ((790, 365), 38), ((1320, 345), 42), ((1110, 1880), 50),
    ((1660, 2010), 38), ((2690, 1820), 54), ((2420, 2070), 40), ((2700, 600), 54),
]


def river_x(y):
    return 2220.0 + math.sin(y * 0.006) * 78.0 + math.sin(y * 0.017) * 23.0 + math.sin(y * 0.0024 + 1.3) * 34.0


def river_hw(y):
    return 48.0 + math.sin(y * 0.0041 + .6) * 8.0 + math.sin(y * 0.013) * 5.0


def town_area(x, y):
    return TOWN[0] <= x < TOWN[0] + TOWN_SIZE[0] and TOWN[1] <= y < TOWN[1] + TOWN_SIZE[1]


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
    if town_area(x, y):
        return 'cidade'
    if x > 2010 and y < 860:
        return 'gelo'
    if x > 1980 and y > 1370:
        return 'deserto'
    if y > 1570:
        return 'campos' if x < 760 else 'vale'
    if x < 1040 or y < 680:
        return 'floresta'
    return 'pradaria'


def path_at(x, y):
    if town_area(x, y):
        qx, qy = x - TOWN[0], y - TOWN[1]
        return abs(qx - 890.0) < 80.0 or abs(qy - 478.0) < 65.0 or (qy < 478.0 and abs(qx - 448.0) < 47.0) or (qy > 478.0 and abs(qx - 1300.0) < 46.0)
    if x < 650 and abs(y - 1160.0) < 49:
        return True
    if y < 680 and abs(x - 1536.0) < 46:
        return True
    if y > 1567 and abs(x - 1536.0) < 48:
        return True
    if x > 2320 and abs(y - BRIDGE_YS[1]) < 49:
        return True
    if x > 2280 and abs(x - 2560.0) < 43 and y < 1280:
        return True
    if 700 < y < 820 and x > 1700:
        return True
    if 2470 < x < 2550 and y < 820:
        return True
    if 1790 < y < 1890 and x > 1450:
        return True
    return False


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
