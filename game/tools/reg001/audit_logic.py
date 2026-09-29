#!/usr/bin/env python3
"""Auditoria de lógica espacial das construções da REG_001 (skill valedouro-map-logic).

Lê game/data/reg001_world.json e verifica, para cada construção/lugar de história declarado em SITES, regras de sítio:
estrada/trilha próxima, água próxima ou distante, POI, relevo em volta, lavouras, tochas, fora da cidade etc.
Uso: python3 game/tools/reg001/audit_logic.py [--json saída.json]   (código de saída 1 se houver FALHA)
"""
import json
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import geo  # noqa: E402

GAME = HERE.parents[1]
W = json.loads((GAME / 'data' / 'reg001_world.json').read_text(encoding='utf-8'))
OBJ = [o for o in W['objects'] if o['zone'] == 'cidade']
POIS = {p['id']: p for p in W['pois']}
RELIEF_KEYS = ('nat_hill_wide', 'nat_hill_earth', 'nat_hill_sand', 'nat_hill_ice', 'nat_plateau', 'nat_ridge', 'nat_wall_cliff', 'nat_cliff_end', 'nat_cliff_corner')


def seg_dist(px, py, ax, ay, bx, by):
    dx, dy = bx - ax, by - ay
    t = 0 if dx == dy == 0 else max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)))
    return math.hypot(px - (ax + t * dx), py - (ay + t * dy))


def dist_trail(x, y):
    best = 1e9
    for t in W['trails']:
        for a, b in zip(t['pts'], t['pts'][1:]):
            best = min(best, seg_dist(x, y, a[0], a[1], b[0], b[1]) - t['half'])
    return best


def scan(x, y, pred, maxr=500, step=12):
    if pred(x, y):
        return 0.0
    for r in range(step, maxr + 1, step):
        for k in range(24):
            a = k * math.pi / 12
            if pred(x + math.cos(a) * r, y + math.sin(a) * r):
                return float(r)
    return 1e9


def dist_road(x, y, maxr=500):
    return min(max(0.0, dist_trail(x, y)), scan(x, y, lambda a, b: geo.path_at(a, b) or geo.bridge_at(a, b), maxr))


def dist_water(x, y, maxr=500):
    return scan(x, y, lambda a, b: geo.river_at(a, b) or geo.shallow_at(a, b), maxr)


def near(prefixes, x, y, r, key='asset'):
    if isinstance(prefixes, str):
        prefixes = (prefixes,)
    return [o for o in OBJ if o[key].startswith(tuple(prefixes)) and math.hypot(o['pos'][0] - x, o['pos'][1] - y) <= r]


def pos_of(spec):
    if spec in POIS:
        return tuple(POIS[spec]['pos'])
    if '@' in spec:                       # 'asset@x,y' = objeto mais próximo daquele ponto
        a, c = spec.split('@')
        cx, cy = [float(v) for v in c.split(',')]
        m = sorted((o for o in OBJ if o['asset'] == a), key=lambda o: math.hypot(o['pos'][0] - cx, o['pos'][1] - cy))
        if not m or math.hypot(m[0]['pos'][0] - cx, m[0]['pos'][1] - cy) > 220:
            raise SystemExit('objeto não encontrado: ' + spec)
        return tuple(m[0]['pos'])
    a, i = spec.split('#') if '#' in spec else (spec, '0')
    m = [o for o in OBJ if o['asset'] == a]
    if len(m) <= int(i):
        raise SystemExit('objeto não encontrado: ' + spec)
    return tuple(m[int(i)]['pos'])


# (nome, posição [POI id | asset#n | (x,y)], por que aqui, regras)
# regras: ('estrada', max) ('agua_perto', max) ('agua_longe', min) ('relevo', r, n) ('perto', prefixos, r, n) ('fora_cidade',) ('bioma', [...]) ('poi', id, max)
SITES = [
    ('Mina do Eco (entrada da masmorra do Guardião)', 'REG001_POI_CRIPTA_ENTRADA',
     'talude do Vale ao sul de Valedouro: boca de madeira e pedra, trilhos, vagonete, guincho, minério, lampiões',
     [('estrada', 120), ('fora_cidade',), ('relevo', 300, 3), ('perto', 'val_mine_portal', 120, 1), ('perto', 'val_mine_rails', 160, 2), ('perto', 'val_ore_pile', 200, 2), ('perto', 'val_mine_winch', 260, 1)]),
    ('Galeria Antiga (cripta opcional)', 'REG001_POI_GALERIA_ANTIGA',
     'túnel lateral selado do mesmo complexo da mina; grade + tochas + estátuas guardiãs',
     [('estrada', 130), ('relevo', 260, 1), ('perto', 'APP:dungeon_torch', 120, 2), ('perto', 'nat_statue_guardian', 200, 2), ('poi', 'REG001_POI_CRIPTA_ENTRADA', 260)]),
    ('Portão de Valedouro', 'REG001_POI_VAL_GATE',
     'portão norte: torres, barricadas, suprimentos e sentinelas',
     [('perto', 'val_gate_main', 120, 1), ('perto', 'val_gate_tower', 260, 2), ('perto', 'val_barricade', 260, 2), ('perto', 'val_supply_stack', 300, 2)]),
    ('Guilda dos Aventureiros', (1170, 1015),
     'salão de pedra e madeira com pátio de uso real (armas, treino, quadro de contratos)',
     [('perto', 'val_guild_hall', 60, 1), ('perto', 'val_weapon_rack', 260, 1), ('perto', 'val_training_dummy', 260, 1), ('perto', 'val_notice_board', 260, 1)]),
    ('Arquivo das Seis Coroas', 'REG001_POI_ARQUIVO_SEIS_COROAS',
     'prédio de pedra nobre junto do setor da praça, pátio organizado com lâmpadas e monumento',
     [('perto', 'val_archive_hall', 80, 1), ('perto', 'val_archive_lamp', 260, 2), ('perto', 'val_crown_monument', 260, 1)]),
    ('Estrada Norte: sinais de perigo', (1540, 470),
     'carroça destruída, paliçadas quebradas, placas de aviso, ossadas e rastros ao longo da estrada',
     [('perto', 'val_cart_wrecked', 260, 1), ('perto', 'val_palisade_broken', 260, 2), ('perto', 'val_warning_post', 260, 2), ('perto', 'val_paw_tracks', 300, 3), ('perto', 'val_wolf_bones', 260, 1)]),
    ('Ruínas do Primeiro Vento: mecanismo e inscrições', 'REG001_POI_RUINAS_PRIMEIRO_VENTO',
     'mecanismo de pedra com placa de Eco, parede de inscrições, arcos com raízes, piso circular',
     [('perto', 'val_ruin_mechanism', 60, 1), ('perto', 'val_ruin_inscription_wall', 200, 1), ('perto', 'val_ruin_root_arch', 260, 1), ('perto', 'val_ruin_floor_circle', 60, 1)]),
    ('Clareira do Alfa: território da matilha', 'REG001_POI_ANCIAO_CLAREIRA',
     'toca, ossos, solo pisoteado e rastros ao redor do círculo de pedras',
     [('perto', 'val_wolf_den', 260, 1), ('perto', 'val_pack_bones', 200, 2), ('perto', 'val_trampled_earth', 60, 1), ('perto', 'val_paw_tracks', 260, 1)]),
    ('Ruínas do Primeiro Vento (chegada dos Viajantes)', 'REG001_POI_RUINAS_PRIMEIRO_VENTO',
     'marco de chegada dos Viajantes; ponta da rota principal do Bosque, obeliscos e mecanismo',
     [('estrada', 130), ('perto', 'nat_obelisk_rune', 200, 2)]),
    ('Santuário do Vale', 'str_shrine_stone#0',
     'erguido por quem cruzou o Limiar antes; ramal da estrada sul',
     [('estrada', 130), ('relevo', 300, 2)]),
    ('Moinho do Vale', 'str_windmill#0',
     'borda da aldeia, trilha própria, vento aberto; lavouras de trigo e feno em volta',
     [('estrada', 90), ('perto', 'str_crop_wheat', 260, 3), ('perto', 'nat_hay', 260, 1), ('poi', 'REG001_POI_ALDEIA_VALE', 320)]),
    ('Celeiro da Fazenda', 'str_barn#0',
     'encostado nas lavouras da fazenda, cercas e poço da vila perto',
     [('perto', 'str_crop', 300, 3), ('perto', 'nat_fence_wood', 300, 6), ('poi', 'REG001_POI_FAZENDA', 260)]),
    ('Torre do Oeste', 'str_watchtower_stone#0',
     'cruzamento das trilhas da floresta com a estrada oeste, visada sobre o acampamento e as ruínas',
     [('estrada', 110), ('relevo', 260, 1)]),
    ('Torre do Norte', 'str_watchtower_stone#1',
     'junto da estrada norte, vigia o portal do Bosque',
     [('estrada', 130)]),
    ('Torre das Geadas', 'str_watchtower_frost#0',
     'mirante sobre o Pouso e o Círculo de Gelo, em mesa de gelo',
     [('estrada', 260), ('relevo', 260, 2), ('bioma', ['gelo'])]),
    ('Abrigo da Geada', 'str_lodge_ice#0',
     'ramal da estrada norte, abrigo de viajantes; fora do vento',
     [('estrada', 120), ('bioma', ['gelo'])]),
    ('Posto de Âmbar', 'str_outpost_amber#0',
     'bifurcação da estrada sul para o oásis; água e provisões antes das dunas',
     [('estrada', 130), ('bioma', ['deserto']), ('poi', 'REG001_POI_CARAVANA', 320)]),
    ('Estação das Colinas (casa de posta)', 'REG001_POI_ESTACAO_LESTE',
     'ramal da estrada central; casa de posta com carroça, feno e cerca (comércio de peles do gelo ao deserto)',
     [('estrada', 130), ('perto', 'val_town_house', 200, 1), ('perto', 'nat_hay', 200, 1)]),
    ('Taverna do Viajante (cidade)', 'REG001_POI_TAVERNA',
     'junto da praça e da estrada principal; placa, barris, bancos, ponto de descanso (save)',
     [('perto', 'city_sign_hanging', 160, 1), ('perto', 'city_barrels', 220, 1), ('perto', 'city_bench', 260, 2), ('perto', 'val_town_house', 180, 1)]),
    ('Cais norte', 'str_dock_a@2160,990', 'orla do rio junto à ponte norte', [('agua_perto', 70), ('estrada', 320)]),
    ('Cais central', 'str_dock_a@2170,1400', 'orla do rio junto ao porto da cidade', [('agua_perto', 70), ('estrada', 320)]),
    ('Cais sul', 'str_dock_b@2170,2040', 'orla do rio junto ao vau/ponte sul', [('agua_perto', 70), ('estrada', 320)]),
    ('Acampamento do lenhador', 'REG001_POI_CAMP_LENHADOR',
     'clareira na floresta oeste, trilha própria, lenha e tenda',
     [('estrada', 140), ('perto', 'nat_log_pile', 140, 1), ('perto', 'nat_tent', 140, 1)]),
    ('Casa abandonada', 'REG001_POI_CASA_ABANDONADA',
     'família fugiu para a Vila dos Campos; ponta de trilha, cerca quebrada, feno',
     [('estrada', 140), ('perto', 'nat_fence_broken', 160, 1), ('perto', 'val_town_house', 100, 1)]),
    ('Caravana de Âmbar', 'REG001_POI_CARAVANA',
     'entroncamento do ramal do deserto; tendas, carroça, fogueira',
     [('estrada', 130), ('bioma', ['deserto']), ('perto', 'nat_tent', 160, 2)]),
    # ---- Lore (REG001_LORE_*) e missões: o cenário precisa conter o que o texto descreve
    ('LORE_03 Clareira do Ancião: pedras em círculo com símbolos gastos', 'REG001_POI_ANCIAO_CLAREIRA',
     'o círculo de pedras rúnico no centro; o Lobo Ancião guarda o lugar desde antes da guerra',
     [('perto', 'nat_stone_circle', 70, 1)]),
    ('LORE_06 Clareira da Tecelã: teia antiga com resto de mapa', 'REG001_POI_ELITE_BOSQUE',
     'árvores cobertas de seda, casulos e teias no chão',
     [('perto', 'nat_silk_tree', 200, 3), ('perto', 'nat_web_ground', 200, 3)]),
    ('LORE_07 Santuário: erguido por quem cruzou o Limiar', 'REG001_POI_SANTUARIO_VALE',
     'obeliscos com a runa do Limiar ladeando o santuário',
     [('perto', 'nat_obelisk_rune', 150, 2)]),
    ('LORE_08 Círculo de gelo: reflexo de Adrian Vale', 'REG001_POI_ELITE_GELO',
     'Adrian Vale, de casaco azul, preso no gelo no centro do círculo',
     [('perto', 'nat_ice_monolith_adrian', 60, 1)]),
    ('LORE_09 Gruta congelada: cartas seladas em gelo', 'REG001_POI_SEGREDO_GELO',
     'blocos de gelo com cartas seladas ao lado do baú (aparecem com o segredo)',
     [('perto', 'nat_ice_letters', 120, 2)]),
    ('LORE_10 Ruínas das dunas: a mesma runa do bosque', 'REG001_POI_RUINAS_DUNAS',
     'obelisco rúnico igual ao do Primeiro Vento junto ao altar de areia',
     [('perto', 'nat_obelisk_rune', 140, 1), ('perto', 'nat_altar_sand', 120, 1)]),
    ('LORE_11 Câmara enterrada: sarcófagos vazios', 'REG001_POI_SEGREDO_DUNA',
     'sarcófagos abertos e vazios (aparecem com o segredo)',
     [('perto', 'nat_sarcophagus_open', 140, 2)]),
    ('QUEST 03 Contrato dos Lobos: quadro de contratos da Guilda', (1195, 1085),
     'quadro de contratos ao ar livre junto da guilda',
     [('perto', 'val_notice_board', 260, 1)]),
    ('Ruan: bandeiras marcam os caminhos seguros', 'REG001_POI_CARAVANA',
     'bandeiras vermelhas ao longo dos ramais do leste',
     [('perto', 'nat_flag_red', 600, 6)]),
    ('Poço da cidade', 'nat_well_stone@2210,1160', 'abastecimento; nunca dentro d\'água', [('agua_longe', 40)]),
]


def check(rule, x, y, name):
    kind = rule[0]
    if kind == 'estrada':
        d = dist_road(x, y, 500)
        return d <= rule[1], 'estrada/trilha a %s px (máx %d)' % ('∞' if d > 1e8 else int(d), rule[1])
    if kind == 'agua_perto':
        d = dist_water(x, y, 300)
        return d <= rule[1], 'água a %s px (máx %d)' % ('∞' if d > 1e8 else int(d), rule[1])
    if kind == 'agua_longe':
        d = dist_water(x, y, 200)
        return d >= rule[1], 'água a %s px (mín %d)' % ('∞' if d > 1e8 else int(d), rule[1])
    if kind == 'relevo':
        n = sum(1 for o in OBJ if o['asset'].startswith(RELIEF_KEYS) and math.hypot(o['pos'][0] - x, o['pos'][1] - y) <= rule[1])
        return n >= rule[2], '%d peças de relevo em %d px (mín %d)' % (n, rule[1], rule[2])
    if kind == 'perto':
        n = len(near(rule[1], x, y, rule[2]))
        return n >= rule[3], '%d× %s em %d px (mín %d)' % (n, rule[1], rule[2], rule[3])
    if kind == 'fora_cidade':
        return not geo.town_area(x, y), 'fora da área urbana'
    if kind == 'bioma':
        b = geo.biome(x, y)
        return b in rule[1], 'bioma %s (esperado %s)' % (b, '/'.join(rule[1]))
    if kind == 'poi':
        if rule[1] not in POIS:
            return False, 'POI %s inexistente' % rule[1]
        px, py = POIS[rule[1]]['pos']
        d = math.hypot(px - x, py - y)
        return d <= rule[2], 'a %d px de %s (máx %d)' % (d, rule[1][11:], rule[2])
    return False, 'regra desconhecida'


def main():
    rows, fails = [], 0
    for name, spec, why, rules in SITES:
        try:
            x, y = spec if isinstance(spec, tuple) else pos_of(spec)
        except SystemExit:
            rows.append({'site': name, 'pos': None, 'why': why, 'checks': [{'ok': False, 'msg': 'construção/POI ausente no mundo'}]})
            fails += 1
            continue
        checks = []
        for r in rules:
            ok, msg = check(r, x, y, name)
            checks.append({'ok': bool(ok), 'msg': msg})
            fails += 0 if ok else 1
        rows.append({'site': name, 'pos': [round(x), round(y)], 'why': why, 'checks': checks})
    for r in rows:
        bad = [c for c in r['checks'] if not c['ok']]
        print(('FALHA ' if bad else 'OK    ') + r['site'], r['pos'])
        for c in r['checks']:
            print('   ' + ('✔ ' if c['ok'] else '✘ ') + c['msg'])
    print('\nRESUMO: %d construções, %d regras com FALHA' % (len(rows), fails))
    if '--json' in sys.argv:
        Path(sys.argv[sys.argv.index('--json') + 1]).write_text(json.dumps({'sites': rows, 'falhas': fails}, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
    return 1 if fails else 0


if __name__ == '__main__':
    sys.exit(main())
