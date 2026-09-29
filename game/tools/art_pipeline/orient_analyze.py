"""Gera data/orient_kit.json: para cada variante do kit multi-ângulo, a direção de corrida na tela (graus) e o comprimento em px.
Não renderiza: só constrói a geometria e mede (o compositor usa isto para escolher a peça certa para cada trecho)."""
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import build_pro  # noqa: F401  (registra tudo)
import pro_orient as po
from pro_landmarks import REGISTRY
from vk import core

out = {}
for fid in po.FAMILIES:
    if fid not in po._ORIG:
        continue
    variants = [(f'{fid}_a{k}', 'seg', k) for k in range(1, po.N_ANGLES)] + [(f'{fid}_c{q}', 'corner', q) for q in range(4)] + [(fid, 'seg', 0)]
    for vid, kind, k in variants:
        core.reset()
        if vid == fid:
            po._ORIG[fid][0](0)
            po._bake()
            ax = po._screen_axis(po._meshes())
        else:
            b, kw = REGISTRY[vid]
            b(0)
            ax = dict(kw['collision_holder']['axis'])
        ax.update(kind=kind, family=fid, k=k)
        out[vid] = ax
        print('AX', vid, ax, flush=True)
(HERE.parents[1] / 'data' / 'orient_kit.json').write_text(json.dumps(out, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
