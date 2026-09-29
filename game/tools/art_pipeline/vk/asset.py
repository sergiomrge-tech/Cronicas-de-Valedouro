"""VK — orquestração: constrói a cena por quadro, renderiza (duas passadas), finaliza em pixel-art e grava PNG + entrada de manifesto."""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from . import core, post

GAME = Path(__file__).resolve().parents[3]
OUT = GAME / 'assets' / 'modeled'
PARTS = GAME / 'data' / 'modeled_parts'
TMP = Path('/tmp/vk_render.png')
sys.path.insert(0, str(GAME / 'tools' / 'modeling'))


def produce(id, group, folder, size, origin, build, frames=1, rows=1, tags=(), collision=None, footprint=0.0, blocks=0.0, draw_scale=0.5,
            colors=160, outline=2, samples=32, catcher=True, scale=core.PX_PER_UNIT, out_dir=None, source='game/tools/art_pipeline/', preview=None, sun_energy=5.2, grade_kw=None, exposure=None, diamond=None):
    """`build(frame, row)` cria a geometria em Blender (a cena é limpa antes de cada quadro)."""
    w, h = size
    sheet = Image.new('RGBA', (w * frames, h * rows), (0, 0, 0, 0))
    for r in range(rows):
        for f in range(frames):
            core.reset()
            core.make_rig(w, h, origin, scale, sun_energy=sun_energy)
            bpy_samples = samples
            import bpy
            bpy.context.scene.cycles.samples = bpy_samples
            bpy.context.scene.cycles.use_denoising = True
            if exposure is not None:
                bpy.context.scene.view_settings.exposure = exposure
            bpy.context.scene.cycles.denoiser = 'OPENIMAGEDENOISE'
            build(f, r) if 'row' in build.__code__.co_varnames[:build.__code__.co_argcount] else build(f)
            core.apply_all_modifiers()
            asset, shadow = core.render_frame(TMP, catcher_shadow=catcher)
            if diamond:
                import numpy as _np
                yy, xx = _np.mgrid[0:h, 0:w]
                inside = (_np.abs(xx + .5 - origin[0]) / diamond[0] + _np.abs(yy + .5 - origin[1]) / diamond[1]) <= 1.0
                asset[..., 3] = _np.where(inside, 255, 0)
            frame = post.compose(asset, shadow, colors=colors, outline_px=outline, grade_kw=grade_kw)
            sheet.paste(Image.fromarray(frame, 'RGBA'), (f * w, r * h))
    folder_path = (Path(out_dir) if out_dir else OUT / group / folder)
    folder_path.mkdir(parents=True, exist_ok=True)
    png = folder_path / f'{id}.png'
    sheet.save(png)
    if preview:
        Path(preview).parent.mkdir(parents=True, exist_ok=True)
        sheet.crop((0, 0, w, h)).save(preview)
    if out_dir:
        return {'id': id, 'preview_only': True, 'frame_size': list(size)}
    import manifest_lib
    e = manifest_lib.make_entry(id, png, group, folder, size, frames, rows, origin, draw_scale, blocks, footprint, tags, source + 'pro_landmarks.py',
                                extra=({'collision': [list(c) for c in collision]} if collision else None))
    e['pipeline'] = 'blender-pro'
    return e


def save_part(entries, name='pro'):
    """Atualiza data/modeled_parts/pro.json preservando entradas anteriores (chave = id)."""
    path = PARTS / f'{name}.json'
    old = {}
    if path.exists():
        for e in json.loads(path.read_text(encoding='utf-8')):
            old[e['id']] = e
    for e in entries:
        old[e['id']] = e
    PARTS.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(sorted(old.values(), key=lambda e: e['id']), indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
