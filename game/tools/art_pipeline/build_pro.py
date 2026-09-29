#!/usr/bin/env python
"""Ponto de entrada do pipeline profissional (rodar com o Python do bpy).

Uso: python build_pro.py [prefixo_de_id ...] [--preview DIR] [--nowrite]
Módulos de assets: pro_landmarks, pro_terrain, pro_life (NPCs/fauna), pro_interiors.
"""
import importlib
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import pro_landmarks as base

for mod in ('pro_terrain', 'pro_relief', 'pro_nature', 'pro_ground', 'pro_props', 'pro_structures', 'pro_life', 'pro_interiors'):
    if (HERE / f'{mod}.py').exists():
        importlib.import_module(mod)

import json as _json
_ids = sorted(base.REGISTRY)
_p = HERE.parents[1] / 'data' / 'pro_registry_ids.json'
_p.write_text(_json.dumps(_ids, indent=0) + '\n', encoding='utf-8')

if __name__ == '__main__':
    args = sys.argv[1:]
    prev = None
    if '--preview' in args:
        i = args.index('--preview')
        prev = args[i + 1]
        args = args[:i] + args[i + 2:]
    write = '--nowrite' not in args
    args = [a for a in args if a != '--nowrite']
    ids = [i for i in base.REGISTRY if not args or any(i.startswith(a) for a in args)]
    base.run(ids, prev, write)
