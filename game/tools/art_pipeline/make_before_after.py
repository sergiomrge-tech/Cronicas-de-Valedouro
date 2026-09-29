#!/usr/bin/env python3
"""Folhas ANTES/DEPOIS dos assets remodelados (ANTES = versão no commit de referência; DEPOIS = árvore de trabalho).

Uso: python3 make_before_after.py [--ref HEAD] [--out docs/visual_qa/pro]
"""
import io
import json
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / 'game'
FAMILIES = {
    'estruturas': ('str_',), 'elevacoes': ('nat_plateau', 'nat_ridge', 'nat_hill', 'nat_wall_cliff', 'nat_steps', 'nat_rock_arch', 'nat_rock_pillars'),
    'cachoeira_caverna': ('nat_waterfall', 'str_cave'), 'arvores': ('nat_tree', 'nat_cactus'), 'arbustos_pedras': ('nat_bush', 'nat_rock_', 'nat_boulder', 'nat_ice', 'nat_dune', 'nat_snow'),
    'acampamento_fazenda': ('nat_tent', 'nat_well', 'nat_cart', 'nat_campfire', 'nat_signpost', 'nat_stump', 'nat_log', 'nat_hay', 'nat_fence', 'nat_gate', 'nat_wall_low'),
    'ruinas_baus': ('nat_ruin', 'nat_altar', 'nat_obelisk', 'nat_statue', 'nat_chest', 'nat_flag'), 'cidade_props': ('city_',), 'interiores': ('int_',),
}


def git_show(ref, rel):
    r = subprocess.run(['git', 'show', f'{ref}:{rel}'], cwd=ROOT, capture_output=True)
    return Image.open(io.BytesIO(r.stdout)).convert('RGBA') if r.returncode == 0 and r.stdout else None


def first_frame(im, fw, fh):
    return im.crop((0, 0, fw, fh))


def main():
    ref = 'HEAD'
    out = ROOT / 'docs' / 'visual_qa' / 'pro'
    a = sys.argv[1:]
    if '--ref' in a:
        ref = a[a.index('--ref') + 1]
    if '--out' in a:
        out = Path(a[a.index('--out') + 1])
    out.mkdir(parents=True, exist_ok=True)
    pro = {e['id']: e for e in json.loads((GAME / 'data' / 'modeled_parts' / 'pro.json').read_text(encoding='utf-8'))}
    for fam, prefs in FAMILIES.items():
        ids = [i for i in sorted(pro) if any(i.startswith(p) for p in prefs)]
        rows = []
        for i in ids:
            e = pro[i]
            rel = 'game/' + e['path'][6:]
            new = Image.open(GAME / e['path'][6:]).convert('RGBA')
            fw, fh = e['frame_size']
            old = git_show(ref, rel)
            if old is None:
                continue
            ofw = min(old.width, fw) if old.width < fw * e['frames'] else fw
            rows.append((i, first_frame(old, min(old.width, fw), min(old.height, fh)), first_frame(new, fw, fh)))
        if not rows:
            continue
        W = 1800
        x = y = rh = 0
        cells = []
        for i, o, n in rows:
            cw = o.width + n.width + 24
            if x + cw > W:
                x = 0
                y += rh + 16
                rh = 0
            cells.append((i, o, n, x, y))
            x += cw
            rh = max(rh, o.height, n.height)
        sheet = Image.new('RGBA', (W, y + rh + 24), (70, 104, 62, 255))
        d = ImageDraw.Draw(sheet)
        for i, o, n, cx, cy in cells:
            sheet.alpha_composite(o, (cx, cy + 12))
            sheet.alpha_composite(n, (cx + o.width + 12, cy + 12))
            d.text((cx + 2, cy), i[:30] + '  ANTES | DEPOIS', fill=(255, 255, 255, 255))
        path = out / f'antes_depois_{fam}.png'
        sheet.save(path)
        print('OK', path.relative_to(ROOT), len(rows))


if __name__ == '__main__':
    main()
