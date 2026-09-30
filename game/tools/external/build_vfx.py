"""VFX gratuitos (CC0) adaptados: recorte em quadros, tingimento para a linguagem Valedouro (Eco = ciano, Coroa Oca = violeta,
fogo = âmbar), tira horizontal única por efeito (atlas simples, carregado uma vez) + data/external_vfx.json."""
import glob
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import GAME, LIB, LICENSE, rel, record  # noqa

V = LIB / 'vfx'
OUT = GAME / 'assets' / 'external' / 'vfx'


def grid(path, fw, fh, n=None):
    im = Image.open(path).convert('RGBA')
    fr = []
    for y in range(0, im.height - fh + 1, fh):
        for x in range(0, im.width - fw + 1, fw):
            f = im.crop((x, y, x + fw, y + fh))
            if f.getbbox():
                fr.append(f)
    return fr[:n] if n else fr


def seq(folder, n=None):
    g = sorted(glob.glob(str(folder / '*.png')), key=lambda s: int(''.join(c for c in Path(s).stem.split('_')[-1] if c.isdigit()) or 0))
    fr = [Image.open(f).convert('RGBA') for f in g]
    return fr[:n] if n else fr


def tint(fr, rgb, keep=.35):
    """Mantém a luminância do efeito (forma e brilho) e aplica a cor da linguagem Valedouro."""
    out = []
    for f in fr:
        a = np.asarray(f, dtype=np.float32)
        lum = (a[..., 0] * .3 + a[..., 1] * .59 + a[..., 2] * .11)[..., None] / 255.0
        col = np.array(rgb, dtype=np.float32)[None, None, :]
        hi = np.clip((lum - .7) / .3, 0, 1)
        rgbn = (col * lum * (1 - hi) + 255 * hi) * (1 - keep) + a[..., :3] * keep
        a[..., :3] = np.clip(rgbn, 0, 255)
        out.append(Image.fromarray(a.astype(np.uint8), 'RGBA'))
    return out


def pick(fr, n):
    idx = np.round(np.linspace(0, len(fr) - 1, n)).astype(int)
    return [fr[i] for i in idx]


def strip(fr):
    w = max(f.width for f in fr)
    h = max(f.height for f in fr)
    s = Image.new('RGBA', (w * len(fr), h))
    for i, f in enumerate(fr):
        s.paste(f, (i * w + (w - f.width) // 2, (h - f.height) // 2))
    return s, w, h


FZ = V / 'foozle_lucifer_effects' / 'Foozle_2DE0002_Lucifer_Effects_Pixel_Art' / 'Effects'
GV = V / 'oga_gothicvania_magic_9' / 'magic_pack_9_files_unpacked' / 'Magic Pack 9 files' / 'spritesheets'
LPC = V / 'oga_lpc_explosions_2' / 'Pix2_unpacked'
SP2 = V / 'oga_2d_spell_effects' / 'FX_unpacked'
EFFECTS = [
    # id, (loader), tint rgb|None, fps, escala de desenho, uso, fonte, licença
    ('vfx_hit', lambda: grid(FZ / 'VFX' / 'Destroy Effect.png', 48, 48), (255, 236, 190), 18, 1.5, 'impacto do golpe em inimigos (todas as armas)', FZ / 'VFX', 'foozle'),
    ('vfx_hit_eco', lambda: grid(FZ / 'VFX' / 'Destroy Effect.png', 48, 48), (110, 230, 255), 18, 2.0, 'impacto/morte de criaturas do Eco', FZ / 'VFX', 'foozle'),
    ('vfx_wave_right', lambda: grid(FZ / 'Wave' / 'Big' / 'Right' / 'WaveBigRight.png', 64, 64), (130, 235, 255), 12, 2.0, 'onda de choque direcional (Guardião, investida)', FZ / 'Wave', 'foozle'),
    ('vfx_wave_left', lambda: grid(FZ / 'Wave' / 'Big' / 'Left' / 'WaveBigLeft.png', 64, 64), (130, 235, 255), 12, 2.0, 'idem', FZ / 'Wave', 'foozle'),
    ('vfx_wave_up', lambda: grid(FZ / 'Wave' / 'Big' / 'Up' / 'WaveBigUp.png', 64, 64), (130, 235, 255), 12, 2.0, 'idem', FZ / 'Wave', 'foozle'),
    ('vfx_wave_down', lambda: grid(FZ / 'Wave' / 'Big' / 'Down' / 'WaveBigDown.png', 64, 64), (130, 235, 255), 12, 2.0, 'idem', FZ / 'Wave', 'foozle'),
    ('vfx_dark_bolt', lambda: grid(GV / 'Dark-Bolt.png', 88, 88), (190, 110, 255), 14, 1.2, 'feitiço do Cultista da Coroa Oca (impacto após marca no chão)', GV, 'oga'),
    ('vfx_lightning_eco', lambda: grid(GV / 'Lightning.png', 128, 128), (120, 235, 255), 14, 1.1, 'golpe especial do Guardião do Eco (raios nas marcas)', GV, 'oga'),
    ('vfx_firebomb', lambda: grid(GV / 'Fire-bomb.png', 64, 64), (255, 170, 70), 18, 1.3, 'impacto + área do cajado (explosão)', GV, 'oga'),
    ('vfx_fireball', lambda: pick(grid(LPC / 'fireball1.png', 32, 32), 8), (255, 190, 90), 16, 1.2, 'projétil do cajado (viagem)', LPC, 'oga'),
    ('vfx_sparkles_cast', lambda: pick(grid(LPC / 'sparkles-1.png', 32, 32), 8), (255, 220, 140), 16, 1.2, 'conjuração/carga do cajado na mão do herói', LPC, 'oga'),
    ('vfx_sparks', lambda: pick(grid(LPC / 'sparks-1.png', 32, 32), 8), None, 18, 1.0, 'impacto de flecha/pedra', LPC, 'oga'),
    ('vfx_smoke', lambda: pick(grid(LPC / 'smoke-1.png', 32, 32), 10), (200, 200, 190), 14, 1.4, 'dissipação de feitiços e queda de monstros', LPC, 'oga'),
    ('vfx_energy_orb', lambda: pick(seq(SP2 / 'fx7_energyBall'), 12), (120, 235, 255), 16, .8, 'orbe do Eco (flechas do Arqueiro Ossudo / Possesso)', SP2 / 'fx7_energyBall', 'oga'),
    ('vfx_fire', lambda: pick(grid(V / 'oga_animated_fire' / 'fire1_64.png', 64, 64), 12), None, 12, .8, 'fogueiras/tochas do mundo (emissor de fogo)', V / 'oga_animated_fire', 'oga'),
    ('vfx_black_burst', lambda: pick(seq(SP2 / 'fx10_blackExplosion'), 10), (150, 70, 200), 16, 1.4, 'morte de Cultista/Possesso (dissipação sombria)', SP2 / 'fx10_blackExplosion', 'oga'),
    ('vfx_slash_claw', lambda: grid(V / 'oga_pixel_sword_slash' / 'pixel_art_sword_slash_sprites.png', 64, 47), (255, 120, 110), 20, 1.0, 'golpe corpo a corpo dos inimigos acertando o herói', V / 'oga_pixel_sword_slash', 'oga'),
]


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    meta, prov = {}, []
    for id, load, rgb, fps, scale, use, src, lic in EFFECTS:
        fr = load()
        if rgb:
            fr = tint(fr, rgb)
        s, w, h = strip(fr)
        png = OUT / f'{id}.png'
        s.save(png, optimize=True)
        meta[id] = {'path': 'res://' + png.relative_to(GAME).as_posix(), 'w': w, 'h': h, 'frames': len(fr), 'fps': fps, 'scale': scale}
        prov.append({'id': id, 'category': 'vfx', 'source_paths': [rel(src)], 'license': LICENSE[lic], 'derived': 'game/' + png.relative_to(GAME).as_posix(),
                     'modifications': 'recorte em %d quadros (tira única), %s, velocidade/escala ajustadas' % (len(fr), 'tingido para a linguagem de cor Valedouro' if rgb else 'cores originais'),
                     'used_in': use, 'status': 'MODELED_PENDING_GATE'})
    (GAME / 'data' / 'external_vfx.json').write_text(json.dumps({'note': 'VFX gratuitos adaptados (tools/external/build_vfx.py)', 'vfx': meta}, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
    record(prov)
    print('vfx:', len(meta))


if __name__ == '__main__':
    main()
