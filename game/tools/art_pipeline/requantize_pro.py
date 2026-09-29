#!/usr/bin/env python3
"""Reduz a paleta dos assets Blender/pixel-sim já gerados (K-means em Oklab, alpha preservado) — sem re-renderizar.

Uso: python3 requantize_pro.py [--colors 64] [--dry-run]
Só toca PNGs com pipeline 'blender-pro' em data/modeled_parts/pro.json (os quadros de uma folha compartilham a mesma paleta).
Depois rode: python3 game/tools/modeling/build_assets.py  (atualiza SHA-256 do manifesto).
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
GAME = HERE.parents[1]
sys.path.insert(0, str(HERE))
from vk import post  # noqa: E402


def main():
    colors = 64
    if '--colors' in sys.argv:
        colors = int(sys.argv[sys.argv.index('--colors') + 1])
    dry = '--dry-run' in sys.argv
    entries = json.loads((GAME / 'data' / 'modeled_parts' / 'pro.json').read_text(encoding='utf-8'))
    changed = 0
    for e in entries:
        if e.get('pipeline') != 'blender-pro':
            continue
        path = GAME / e['path'][6:]
        im = np.asarray(Image.open(path).convert('RGBA')).copy()
        mask = im[..., 3] == 255
        before = len(np.unique(im[mask][:, :3], axis=0))
        if before <= colors:
            continue
        out = post.quantize_oklab(im[..., :3], mask, colors)
        after = len(np.unique(out[mask], axis=0))
        if not dry:
            im[..., :3] = np.where(mask[..., None], out, im[..., :3])
            Image.fromarray(im, 'RGBA').save(path)
        changed += 1
        print(f"{e['id']}: {before} -> {after}")
    print('OK', changed, 'assets', '(dry-run)' if dry else '')


if __name__ == '__main__':
    main()
