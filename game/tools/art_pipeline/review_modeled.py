#!/usr/bin/env python3
"""Revisão A/B/C/D dos assets MODELED_PENDING_GATE (sem promover nenhum a APPROVED).

A = qualidade suficiente para o padrão atual; B = refinamento leve; C = remodelagem; D = substituir/aposentar.
Assets já remodelados no pipeline Blender entram como PRO (candidatos novos, aguardam o gate do Diretor).
Saída: docs/art/PRO_ART_REVIEW_MODELED.md e game/data/reg001_art_review.json
"""
import json
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / 'game'
MAN = json.loads((GAME / 'data' / 'modeled_assets_manifest.json').read_text(encoding='utf-8'))

A = {
    'city_fountain': 'volume, água animada e pedra coerentes com a Cidade APPROVED', 'city_stall_blue': 'toldo listrado e balcão legíveis', 'city_stall_striped': 'toldo listrado e balcão legíveis',
    'city_monument': 'silhueta clara e degraus', 'dg_pillar': 'coerente com a paleta de Dungeon', 'dg_pillar_broken': 'ruína legível', 'dg_brazier': 'brilho e silhueta', 'dg_crystal_checkpoint': 'foco visual forte',
    'dg_rune_circle': 'leitura de piso rúnico', 'dg_boss_gate': 'arco e portão com volume', 'dg_portcullis': 'grade legível', 'dg_sarcophagus': 'bloco esculpido com tampa', 'dg_stairs': 'degraus claros',
    'dg_stalagmites': 'silhueta natural', 'dg_altar_dark': 'foco com brilho', 'dg_mushroom_glow': 'emissivo legível', 'int_bookshelf': 'estante com lombadas', 'int_shelf_goods': 'prateleira com itens',
    'int_shelf_potions': 'frascos coloridos', 'int_bed': 'cama com colcha', 'int_cauldron': 'caldeirão com fogo', 'int_fireplace': 'lareira de pedra com brilho', 'int_forge': 'forja com brasa', 'int_anvil': 'bigorna',
    'int_armor_stand': 'armadura em suporte', 'int_weapon_rack': 'suporte de armas', 'int_quest_board': 'quadro de missões', 'int_desk_guild': 'mesa da guilda', 'int_alchemy_table': 'mesa de alquimia', 'int_workbench': 'bancada',
    'int_counter': 'balcão de loja', 'int_candle_stand': 'vela com brilho', 'nat_res_crystal': 'cristal legível', 'nat_res_herb': 'erva legível', 'nat_res_ore': 'minério legível',
}
B = {
    'city_sign_hanging': 'placa simples: acrescentar corrente/desgaste', 'city_stairs': 'degraus lisos: adicionar quebra de aresta', 'dg_barrel_old': 'barril pequeno: ferragens e desgaste', 'dg_crate_old': 'caixa simples',
    'dg_bones_pile': 'osso genérico', 'int_chair': 'cadeira simples: acrescentar almofada/junta', 'int_stool': 'banco simples', 'int_table_long': 'mesa: adicionar itens e desgaste', 'int_table_round': 'mesa: idem',
    'int_sacks': 'sacas com pouca dobra', 'int_rug_round': 'tapete liso: acrescentar padrão/franjas', 'int_floor_carpet': 'tapete de piso liso', 'nat_bedroll': 'rolo de dormir simples', 'nat_bones_desert': 'ossos genéricos',
    'nat_flowers_blue': 'moita de flores: aumentar variação', 'nat_flowers_meadow': 'idem', 'nat_flowers_red': 'idem', 'nat_grass_dry': 'tufo simples', 'nat_grass_tall': 'tufo simples', 'nat_mushrooms': 'cogumelos simples',
    'nat_reeds': 'juncos finos: adensar', 'nat_pit_trap': 'fosso: aprofundar', 'nat_trap_plate': 'placa de pressão simples', 'nat_fissure': 'fissura pequena: alongar e aprofundar', 'nat_ford_stones': 'pedras do vau: mais volume',
    'nat_ice_stones': 'pedras de gelo: facetas', 'nat_wall_low_b': 'variante espelhada', 'nat_scarecrow': 'substituído por str_scarecrow',
}
D = {
    **{f'nat_decal_{n}': 'manchas planas: aposentado (chão assado e props já cobrem a transição)' for n in ('dirt_a', 'dry_a', 'grass_a', 'grass_b', 'mud_bank', 'sand_a', 'sand_b', 'snow_a', 'snow_b')},
    'int_floor_carpet': 'substituído por rugs modelados', 'nat_scarecrow': 'substituído por str_scarecrow',
}


def main():
    rows = []
    for e in MAN['assets']:
        i = e['id']
        if i.startswith('ter_'):
            cls, why = 'PRO', 'chão assado / textura contínua (terreno) — pipeline de terreno'
        elif e.get('pipeline') == 'blender-pro':
            cls, why = 'PRO', 'remodelado em Blender (volume real, materiais, contorno, sombra de contato)'
        elif e.get('pipeline') == 'pixel-sim':
            cls, why = 'PRO', 'FX em pixel art por simulação de partículas'
        elif i in D:
            cls, why = 'D', D[i]
        elif i in A:
            cls, why = 'A', A[i]
        elif i in B:
            cls, why = 'B', B[i]
        else:
            cls, why = 'C', 'primitivas visíveis / detalhe insuficiente: remodelar'
        rows.append({'id': i, 'group': e['group'], 'class': cls, 'reason': why, 'status': e['status'], 'pipeline': e.get('pipeline', 'kit')})
    cnt = Counter(r['class'] for r in rows)
    (GAME / 'data' / 'reg001_art_review.json').write_text(json.dumps({'counts': dict(cnt), 'rows': rows}, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
    lines = ['# Revisão A/B/C/D — assets MODELED_PENDING_GATE', '',
             'Nenhum asset foi promovido a APPROVED. PRO = remodelado no pipeline profissional (Blender / simulação de pixel art) nesta rodada.', '',
             '| classe | quantidade |', '|---|---|'] + [f'| {k} | {v} |' for k, v in sorted(cnt.items())] + ['']
    by = defaultdict(list)
    for r in rows:
        by[r['class']].append(r)
    for cls in ('PRO', 'A', 'B', 'C', 'D'):
        if cls not in by:
            continue
        lines += [f'## {cls} ({len(by[cls])})', '']
        if cls == 'PRO':
            lines.append(', '.join(r['id'] for r in by[cls]) + '\n')
        else:
            lines += [f"- `{r['id']}` — {r['reason']}" for r in by[cls]] + ['']
    (ROOT / 'docs' / 'art' / 'PRO_ART_REVIEW_MODELED.md').write_text('\n'.join(lines), encoding='utf-8')
    print(dict(cnt))


if __name__ == '__main__':
    main()
