#!/usr/bin/env python3
"""Paleta única de referência do Valedouro: K-means em Oklab sobre os 28 PNGs APPROVED (pixels opacos). Saída: game/data/valedouro_palette.json"""
import glob
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
GAME = HERE.parents[1]
sys.path.insert(0, str(HERE))
from vk import post  # noqa: E402

K = int(sys.argv[1]) if len(sys.argv) > 1 else 64
px = []
for f in sorted(glob.glob(str(GAME / 'assets' / 'approved' / '**' / '*.png'), recursive=True)):
    a = np.asarray(Image.open(f).convert('RGBA'))
    px.append(a[a[..., 3] == 255][:, :3])
px = np.concatenate(px)
rng = np.random.default_rng(3)
px = px[rng.choice(len(px), min(len(px), 400000), replace=False)]
img = px.reshape(-1, 1, 3).astype(np.uint8)
mask = np.ones(img.shape[:2], dtype=bool)
q = post.quantize_oklab(img, mask, K)
pal = np.unique(q.reshape(-1, 3), axis=0)
lab = post._to_oklab(pal)
order = np.argsort(lab[:, 0])
out = ['#%02x%02x%02x' % tuple(pal[i]) for i in order]
(GAME / 'data' / 'valedouro_palette.json').write_text(json.dumps({'source': 'APPROVED (28 PNGs)', 'method': 'k-means Oklab', 'k': len(out), 'colors': out}, indent=1) + '\n', encoding='utf-8')
print('OK', len(out))
