#!/usr/bin/env python3
"""Pós-passo do `val_house_body`: reescala a luminância da pedra renderizada para a paleta bege quente das peças APPROVED de casa
(porta/janela são pintadas à mão e mais claras que qualquer render com a luz do jogo). Preserva juntas/sombras (só remapeia luminância→paleta).
Rodar DEPOIS de build_pro.py val_house_body e ANTES de requantize_pro.py."""
from pathlib import Path
import numpy as np
from PIL import Image

P = Path(__file__).resolve().parents[2] / 'assets' / 'modeled' / 'city' / 'ato1' / 'val_house_body.png'
PAL = np.array([(58, 38, 26), (92, 64, 44), (132, 96, 68), (172, 130, 94), (206, 166, 122)], float)   # parede à sombra entre as peças claras (porta/janela): lê-se como fundo, com juntas visíveis
im = np.array(Image.open(P).convert('RGBA'))
a = im[..., 3] > 0
rgb = im[..., :3].astype(float)
lum = (rgb * [.299, .587, .114]).sum(-1)
lo, hi = np.percentile(lum[a], 1), np.percentile(lum[a], 99)
t = (np.clip((lum - lo) / max(hi - lo, 1), 0, 1) ** 1.4) * (len(PAL) - 1)
i0 = np.floor(t).astype(int).clip(0, len(PAL) - 2)
f = (t - i0)[..., None]
out = PAL[i0] * (1 - f) + PAL[i0 + 1] * f
im[..., :3] = np.where(a[..., None], out, rgb).astype(np.uint8)
Image.fromarray(im).save(P)
print('tint ok', P.name)
