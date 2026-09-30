"""Utilitários de adaptação de assets gratuitos (external_assets/free_reference_library) para Crônicas de Valedouro.
Fluxo: fonte CC0 preservada -> curadoria -> graduação de cor Valedouro + contorno -> escala inteira (nearest) -> PNG derivado em
game/assets/external/... -> ID persistente em data/modeled_parts/external*.json + proveniência em data/external_assets_provenance.json."""
import colorsys
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image

GAME = Path(__file__).resolve().parents[2]
ROOT = GAME.parent
LIB = ROOT / 'external_assets' / 'free_reference_library'
OUT = GAME / 'assets' / 'external'
PROV = GAME / 'data' / 'external_assets_provenance.json'
LICENSE = {'karsiori': 'CC0 (Karsiori, itch.io)', 'foozle': 'CC0 (Foozle, Lucifer series)', 'kenney': 'CC0 (Kenney.nl)', 'oga': 'CC0 (OpenGameArt, ver SOURCE.md)'}


def rel(p):
    return Path(p).resolve().relative_to(ROOT).as_posix()


def load(p):
    return Image.open(p).convert('RGBA')


def grade(im, sat=.88, val=.96, hue_to=None, hue_pull=0.0, shadow=.9, warm=0.0):
    """Graduação de cor para a paleta Valedouro: dessatura levemente os verdes saturados, puxa matizes para `hue_to`,
    aprofunda sombras (luz alto-esquerda do jogo) e opcionalmente aquece. Preserva alfa e a contagem de cores (pixel art)."""
    a = np.asarray(im, dtype=np.float32) / 255.0
    rgb = a[..., :3]
    out = np.empty_like(rgb)
    h, w, _ = rgb.shape
    flat = rgb.reshape(-1, 3)
    res = np.empty_like(flat)
    cache = {}
    for i, px in enumerate(flat):
        k = tuple(np.round(px, 4))
        if k not in cache:
            hh, ss, vv = colorsys.rgb_to_hsv(*px)
            if hue_to is not None and ss > .15:
                d = ((hue_to - hh + .5) % 1.0) - .5
                hh = (hh + d * hue_pull) % 1.0
            ss = min(1.0, ss * sat)
            vv = vv * val
            if vv < .45:
                vv *= shadow
            r, g, b = colorsys.hsv_to_rgb(hh, ss, vv)
            cache[k] = (min(1, r + warm * .06), g, max(0, b - warm * .04))
        res[i] = cache[k]
    out = res.reshape(h, w, 3)
    a[..., :3] = out
    return Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8), 'RGBA')


def outline(im, color=(14, 22, 14, 255), sides='all'):
    """Contorno de 1 px de arte na silhueta (as artes de Valedouro têm contorno escuro)."""
    a = np.asarray(im).copy()
    m = a[..., 3] > 40
    grow = np.zeros_like(m)
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        grow |= np.roll(np.roll(m, dy, 0), dx, 1)
    edge = grow & ~m
    a[edge] = color
    return Image.fromarray(a, 'RGBA')


def pad(im, n=2):
    c = Image.new('RGBA', (im.width + 2 * n, im.height + 2 * n))
    c.paste(im, (n, n))
    return c


def up(im, k):
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


def foot_of(im):
    """Pé = centro das colunas opacas nas 3 linhas mais baixas, na última linha opaca."""
    a = np.asarray(im)[..., 3] > 40
    ys = np.nonzero(a.any(axis=1))[0]
    y1 = int(ys.max())
    band = a[max(0, y1 - 2):y1 + 1]
    xs = np.nonzero(band.any(axis=0))[0]
    return float((xs.min() + xs.max()) / 2), float(y1)


def entry(id, png, group, folder, frame_size, frames, foot, tags, source, block=0.0, footprint=0.0, collision=None, extra=None):
    e = {'id': id, 'path': 'res://' + png.relative_to(GAME).as_posix(), 'group': group, 'folder': folder,
         'frame_size': [int(frame_size[0]), int(frame_size[1])], 'frames': int(frames), 'rows': 1, 'foot': [float(foot[0]), float(foot[1])],
         'draw_scale': 1.0, 'blocks_radius': float(block), 'footprint': float(footprint or block), 'tags': list(tags),
         'sha256': hashlib.sha256(png.read_bytes()).hexdigest(), 'source': source, 'status': 'MODELED_PENDING_GATE', 'pipeline': 'external-adapted'}
    if collision:
        e['collision'] = collision
    if extra:
        e.update(extra)
    return e


def write_part(name, entries):
    p = GAME / 'data' / 'modeled_parts' / f'{name}.json'
    p.write_text(json.dumps(sorted(entries, key=lambda e: e['id']), indent=1, ensure_ascii=False) + '\n', encoding='utf-8')


def record(items):
    """Acrescenta/atualiza linhas de proveniência: {id, category, source_paths, license, derived, modifications, used_in}."""
    doc = json.loads(PROV.read_text(encoding='utf-8')) if PROV.exists() else {'note': 'Proveniência dos assets gratuitos integrados (fonte preservada em external_assets/free_reference_library).', 'items': []}
    by = {i['id']: i for i in doc['items']}
    for it in items:
        by[it['id']] = it
    doc['items'] = sorted(by.values(), key=lambda i: (i['category'], i['id']))
    PROV.write_text(json.dumps(doc, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
