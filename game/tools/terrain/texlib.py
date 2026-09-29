"""Biblioteca de texturas de terreno contínuas (tileable) em pixel-art para Crônicas de Valedouro.

Mesma paleta/linguagem dos assets modelados (rampas saturadas, contorno leve, pixels sem AA).
Cada textura é 256x256 e repete sem costura; a assadura do mundo (bake_ground.py) mistura-as com dithering.
"""
from __future__ import annotations
import numpy as np
from PIL import Image

N = 256
BAYER8 = (np.array([
    [0, 32, 8, 40, 2, 34, 10, 42], [48, 16, 56, 24, 50, 18, 58, 26],
    [12, 44, 4, 36, 14, 46, 6, 38], [60, 28, 52, 20, 62, 30, 54, 22],
    [3, 35, 11, 43, 1, 33, 9, 41], [51, 19, 59, 27, 49, 17, 57, 25],
    [15, 47, 7, 39, 13, 45, 5, 37], [63, 31, 55, 23, 61, 29, 53, 21]], dtype=np.float32) + .5) / 64.0


def hexc(h):
    h = h.lstrip('#')
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=np.float32)


def ramp(*hexes):
    return np.stack([hexc(h) for h in hexes])


def tile_noise(size, beta, seed, lowcut=5):
    """Ruído contínuo (periódico) 1/f^beta em [0,1] via FFT."""
    rng = np.random.default_rng(seed)
    white = rng.normal(size=(size, size))
    f = np.fft.fft2(white)
    fy = np.fft.fftfreq(size)[:, None]
    fx = np.fft.fftfreq(size)[None, :]
    r = np.sqrt(fx ** 2 + fy ** 2)
    r[0, 0] = 1.0
    f = f / (r ** beta)
    f[r * size < lowcut] = 0
    f[0, 0] = 0
    out = np.real(np.fft.ifft2(f))
    out = (out - out.min()) / (out.max() - out.min() + 1e-9)
    return out.astype(np.float32)


def map_ramp(v, colors, bias=0.0, contrast=1.0, dither=True):
    """Mapeia v em [0,1] para uma rampa com dithering ordenado leve (pixel-art)."""
    k = len(colors)
    v = np.clip((v - .5) * contrast + .5 + bias, 0, 1)
    h, w = v.shape
    bay = np.tile(BAYER8, (h // 8 + 1, w // 8 + 1))[:h, :w]
    f = v * (k - 1) + ((bay - .5) * .55 if dither else 0)
    idx = np.clip(np.round(f), 0, k - 1).astype(int)
    return colors[idx]


def wrap_put(img, x, y, color):
    h, w = img.shape[:2]
    img[y % h, x % w] = color


def scatter(img, rng, count, fn):
    h, w = img.shape[:2]
    for _ in range(count):
        fn(img, int(rng.integers(0, w)), int(rng.integers(0, h)), rng)


def tuft(colors_dark, colors_light):
    """Tufo em 'Y' (2-3 lâminas) — leitura de folhas em vez de riscos verticais."""
    def f(img, x, y, rng):
        h = int(rng.integers(1, 3))
        wrap_put(img, x - 1, y, colors_dark); wrap_put(img, x, y, colors_dark); wrap_put(img, x + 1, y, colors_dark)
        wrap_put(img, x, y - 1, colors_light)
        wrap_put(img, x - 1, y - 1 - (h - 1), colors_light)
        wrap_put(img, x + 1, y - 1 - (h - 1) * 0, colors_light)
        if h > 1:
            wrap_put(img, x - 1, y - 1, colors_dark)
    return f


def pebble(cols):
    def f(img, x, y, rng):
        wrap_put(img, x, y, cols[3]); wrap_put(img, x + 1, y, cols[2]); wrap_put(img, x, y + 1, cols[1]); wrap_put(img, x + 1, y + 1, cols[0])
        wrap_put(img, x - 1, y + 1, cols[0])
    return f


def flower(colors):
    def f(img, x, y, rng):
        c = colors[int(rng.integers(0, len(colors)))]
        for ox, oy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
            wrap_put(img, x + ox, y + oy, c)
        wrap_put(img, x, y, hexc('#ffc830'))
    return f


# ------------------------------------------------------------------ paletas
GRASS = ramp('#1a5a26', '#2a7c2a', '#3f9a36', '#5db648', '#86d060', '#b2e878')
GRASS_D = ramp('#123f22', '#1c5a26', '#2a7a2c', '#419a3a', '#62b64a', '#8ad064')
MEADOW = ramp('#2c7a30', '#42983c', '#5fb448', '#82cc5c', '#a8e072', '#ccf294')
VALLEY = ramp('#1a5a3a', '#2a7c48', '#3f9a58', '#5cb46a', '#82ce7e', '#aae49a')
FOREST = ramp('#0e3220', '#164a28', '#1f6a2c', '#2f8a34', '#46a442', '#6cbf58')
DIRT = ramp('#4a2c1c', '#6e4428', '#946038', '#b88348', '#d4a462', '#eac686')
ROAD = ramp('#5a3a22', '#7e5430', '#a4743e', '#c49452', '#dcb46c', '#f0d08c')
MUD = ramp('#2a1c16', '#3e2a1e', '#583e2a', '#74543a', '#90704c', '#ac8c62')
SAND = ramp('#b87a44', '#d29a58', '#e6b872', '#f2ce8c', '#fbe0a4', '#fff0c4')
SAND_D = ramp('#a06a3c', '#bc8848', '#d4a862', '#e8c47e', '#f6dc9c', '#fdeebe')
SNOW = ramp('#8aa6d4', '#a8c4e8', '#c6dcf4', '#deecfa', '#f0f8ff', '#ffffff')
ICE = ramp('#5a86c4', '#7aa6dc', '#9cc4ee', '#bedcf8', '#dcf0ff', '#f4fcff')
STONE = ramp('#3a3448', '#54506a', '#726c86', '#928ca2', '#b0aabe', '#cec8d8')
COBBLE = ramp('#4a3c3c', '#6a5850', '#8c7864', '#b09a7c', '#ccb896', '#e4d4b0')
WATER_DEEP = ramp('#0a2a6a', '#12408a', '#1e5aa8', '#2e78c4', '#4494dc', '#66b0ee')
WATER_SH = ramp('#1e6ea8', '#2e8cc8', '#48a8dc', '#6cc4ec', '#98dcf6', '#c4f0fc')
BED = ramp('#5a4a3a', '#7a6650', '#9c8464', '#bca280', '#d6bc9c', '#eed6b8')
WOOD_DECK = ramp('#3a2014', '#5e3820', '#84542c', '#a87438', '#c89448', '#e6b466')
STONE_DECK = ramp('#4a3c3c', '#6e5c52', '#927e68', '#b29a7e', '#ceb89a', '#e6d4b4')


def _speckle(img, rng, cols, n):
    def f(im, x, y, r):
        wrap_put(im, x, y, cols[int(r.integers(0, len(cols)))])
    scatter(img, rng, n, f)


def make_grass(seed, colors=GRASS, flowers=True, tufts=900, clover=False):
    rng = np.random.default_rng(seed)
    base = .55 * tile_noise(N, 2.2, seed) + .3 * tile_noise(N, 1.2, seed + 1) + .15 * tile_noise(N, 3.0, seed + 2)
    img = map_ramp(base, colors, bias=.03, contrast=1.7)
    scatter(img, rng, tufts // 2, tuft(colors[1], colors[-2]))
    scatter(img, rng, tufts // 3, tuft(colors[2], colors[-1]))
    _speckle(img, rng, [colors[1], colors[4]], 300)
    if flowers:
        scatter(img, rng, 14, flower([hexc('#ffffff'), hexc('#ffe45a'), hexc('#ff8ab8'), hexc('#b8a4ff')]))
    return img


def make_dirt(seed, colors=DIRT, pebbles=70, ruts=False):
    rng = np.random.default_rng(seed)
    base = .5 * tile_noise(N, 1.6, seed) + .35 * tile_noise(N, 2.6, seed + 1) + .15 * tile_noise(N, 3.4, seed + 2)
    img = map_ramp(base, colors, contrast=1.7)
    if ruts:
        # sulcos de carroça suaves ao longo do eixo x (repetem sem costura)
        yy = np.arange(N)[:, None]
        ru = np.sin(yy / N * np.pi * 2 * 4) * .5 + .5
        ru = np.repeat(ru, N, axis=1) * (.6 + .4 * tile_noise(N, 2.0, seed + 7))
        img = np.where((ru > .93)[..., None], colors[1], img)
    scatter(img, rng, pebbles, pebble([colors[0], colors[1], colors[3], colors[5]]))
    _speckle(img, rng, [colors[1], colors[4]], 500)
    return img


def make_sand(seed, colors=SAND, ripples=True):
    rng = np.random.default_rng(seed)
    base = .5 * tile_noise(N, 1.8, seed) + .3 * tile_noise(N, 2.8, seed + 1) + .2 * tile_noise(N, 3.4, seed + 2)
    if ripples:
        yy, xx = np.mgrid[0:N, 0:N]
        warp = tile_noise(N, 1.4, seed + 3) * 18
        rip = np.sin((yy * 1.0 + xx * .4 + warp) / N * np.pi * 2 * 10)
        base = base * .65 + (rip * .5 + .5) * .35
    img = map_ramp(base, colors, contrast=1.5)
    _speckle(img, rng, [colors[1], colors[5]], 700)
    scatter(img, rng, 30, pebble([colors[0], colors[1], colors[3], colors[4]]))
    return img


def make_snow(seed, colors=SNOW):
    rng = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:N, 0:N]
    warp = tile_noise(N, 1.5, seed + 3) * 26
    drift = np.sin((yy * 1.0 + xx * .4 + warp) / N * np.pi * 2 * 5) * .5 + .5
    base = .45 * tile_noise(N, 2.0, seed) + .25 * tile_noise(N, 2.8, seed + 2) + .3 * drift
    img = map_ramp(base, colors, bias=.16, contrast=1.15)
    def sparkle(im, x, y, r):
        wrap_put(im, x, y, colors[5]); wrap_put(im, x + 1, y, colors[4]); wrap_put(im, x, y + 1, colors[4])
    scatter(img, rng, 90, sparkle)
    _speckle(img, rng, [colors[1], colors[2]], 500)
    scatter(img, rng, 10, pebble([hexc('#6a6a80'), hexc('#8a8aa0'), hexc('#aab0c4'), hexc('#dfe4f0')]))
    return img


def make_ice(seed):
    rng = np.random.default_rng(seed)
    base = .6 * tile_noise(N, 1.8, seed) + .4 * tile_noise(N, 2.6, seed + 1)
    img = map_ramp(base, ICE, contrast=1.7)
    # rachaduras finas
    for _ in range(16):
        x, y = int(rng.integers(0, N)), int(rng.integers(0, N))
        ang = rng.uniform(0, 6.28)
        for s in range(int(rng.integers(14, 42))):
            ang += rng.normal(0, .25)
            x += int(round(np.cos(ang))); y += int(round(np.sin(ang)))
            wrap_put(img, x, y, ICE[0])
            wrap_put(img, x + 1, y, ICE[5])
    return img


def make_stone(seed, colors=STONE):
    rng = np.random.default_rng(seed)
    base = .5 * tile_noise(N, 1.4, seed) + .5 * tile_noise(N, 2.4, seed + 1)
    img = map_ramp(base, colors, contrast=1.9)
    for _ in range(30):
        x, y = int(rng.integers(0, N)), int(rng.integers(0, N))
        ang = rng.uniform(0, 6.28)
        for s in range(int(rng.integers(8, 26))):
            ang += rng.normal(0, .3)
            x += int(round(np.cos(ang))); y += int(round(np.sin(ang)))
            wrap_put(img, x, y, colors[0])
            wrap_put(img, x + 1, y + 1, colors[4])
    return img


def make_cobble(seed, colors=COBBLE):
    """Pedra da cidade/estrada calçada (irregular)."""
    rng = np.random.default_rng(seed)
    img = map_ramp(tile_noise(N, 2.0, seed), colors, contrast=1.2)
    for _ in range(140):
        cx, cy = int(rng.integers(0, N)), int(rng.integers(0, N))
        rx, ry = int(rng.integers(5, 9)), int(rng.integers(4, 7))
        tone = rng.integers(2, 5)
        for y in range(-ry, ry + 1):
            for x in range(-rx, rx + 1):
                d = (x / rx) ** 2 + (y / ry) ** 2
                if d < 1:
                    c = colors[tone] if d < .6 else colors[max(tone - 1, 0)]
                    if x < -rx * .3 and y < -ry * .3:
                        c = colors[min(tone + 1, 5)]
                    wrap_put(img, cx + x, cy + y, c)
                elif d < 1.35:
                    wrap_put(img, cx + x, cy + y, colors[0])
    return img


def make_water(seed, colors=WATER_DEEP, shallow=False):
    rng = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:N, 0:N]
    warp = tile_noise(N, 1.6, seed) * 30
    band = np.sin((yy * 1.0 + xx * .5 + warp) / N * np.pi * 2 * 6) * .5 + .5
    base = .55 * tile_noise(N, 2.0, seed + 1) + .45 * band
    img = map_ramp(base, colors, contrast=1.6)
    def glint(im, x, y, r):
        for i in range(int(r.integers(2, 5))):
            wrap_put(im, x + i, y, colors[5])
        wrap_put(im, x, y + 1, colors[4])
    scatter(img, rng, 26 if not shallow else 34, glint)
    return img


def make_bed(seed):
    """Leito pedregoso visível em água rasa."""
    rng = np.random.default_rng(seed)
    img = map_ramp(tile_noise(N, 2.0, seed), BED, contrast=1.4)
    scatter(img, rng, 90, pebble([BED[0], BED[1], BED[3], BED[5]]))
    return img


def make_deck(seed, colors=WOOD_DECK, horizontal=True):
    """Tábuas de ponte (fios paralelos)."""
    rng = np.random.default_rng(seed)
    img = np.zeros((N, N, 3), dtype=np.float32)
    plank = 16
    for i in range(N // plank):
        tone = rng.integers(2, 5)
        band = np.full((plank, N, 3), colors[tone], dtype=np.float32)
        grain = tile_noise(N, 2.4, seed + i)[:plank, :]
        band = map_ramp(grain * .6 + tone / 6 * .4, colors, contrast=1.1)
        band[0] = colors[0]
        band[1] = colors[max(tone - 1, 0)]
        band[-1] = colors[1]
        # pregos
        for nx in (6, N - 7):
            band[plank // 2, nx] = colors[5]
        img[i * plank:(i + 1) * plank] = band
    return img if horizontal else np.transpose(img, (1, 0, 2))


LIB = {
    'grass_a': lambda: make_grass(11, GRASS),
    'grass_b': lambda: make_grass(12, GRASS, tufts=1300),
    'meadow': lambda: make_grass(13, MEADOW, flowers=True, tufts=700),
    'valley': lambda: make_grass(14, VALLEY, tufts=900),
    'forest_floor': lambda: make_grass(15, FOREST, flowers=False, tufts=1100),
    'dirt': lambda: make_dirt(21, DIRT),
    'road': lambda: make_dirt(22, ROAD, pebbles=90, ruts=True),
    'mud': lambda: make_dirt(23, MUD, pebbles=40),
    'sand': lambda: make_sand(31, SAND),
    'sand_dune': lambda: make_sand(32, SAND_D, ripples=True),
    'snow': lambda: make_snow(41, SNOW),
    'ice': lambda: make_ice(42),
    'stone': lambda: make_stone(51),
    'cobble': lambda: make_cobble(52),
    'road_sand': lambda: make_dirt(24, ramp('#8a5a30', '#a87440', '#c4924e', '#dcae68', '#eec686', '#fadea4'), pebbles=60, ruts=True),
    'road_snow': lambda: make_dirt(25, ramp('#6a5a56', '#8a7a70', '#aa9c8c', '#c8bcae', '#e0d8cc', '#f2eee6'), pebbles=50, ruts=True),
    'water_deep': lambda: make_water(61, WATER_DEEP),
    'water_shallow': lambda: make_water(62, WATER_SH, shallow=True),
    'riverbed': lambda: make_bed(63),
    'deck_wood': lambda: make_deck(71, WOOD_DECK),
    'deck_stone': lambda: make_deck(72, STONE_DECK),
}


def build_all():
    return {k: np.clip(v(), 0, 255).astype(np.uint8) for k, v in LIB.items()}


def sheet(tex, cols=6, scale=2):
    names = list(tex)
    rows = (len(names) + cols - 1) // cols
    sh = Image.new('RGB', (cols * N * scale, rows * N * scale))
    for i, n in enumerate(names):
        im = Image.fromarray(tex[n]).resize((N * scale, N * scale), Image.NEAREST)
        sh.paste(im, ((i % cols) * N * scale, (i // cols) * N * scale))
    return sh


if __name__ == '__main__':
    import sys
    t = build_all()
    sheet(t, scale=1).save(sys.argv[1] if len(sys.argv) > 1 else '/tmp/texlib.png')
    print('OK', len(t))
