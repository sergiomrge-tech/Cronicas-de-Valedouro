"""VK — acabamento pixel-art determinístico: alpha duro, grade de cor, limpeza de ruído, paleta, contorno e sombra pontilhada."""
import numpy as np
from PIL import Image

BAYER4 = (np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]], dtype=np.float32) + .5) / 16.0


def shift(a, dx, dy, fill=0):
    """a deslocado por (dx,dy): out[y,x] = a[y-dy, x-dx]."""
    h, w = a.shape[:2]
    out = np.full_like(a, fill)
    y0, y1 = max(0, dy), min(h, h + dy)
    x0, x1 = max(0, dx), min(w, w + dx)
    out[y0:y1, x0:x1] = a[y0 - dy:y1 - dy, x0 - dx:x1 - dx]
    return out


N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))
N8 = N4 + ((1, 1), (-1, -1), (1, -1), (-1, 1))


def grade(rgb, contrast=1.12, saturation=1.14, shadow_tint=(0.94, 0.94, 1.06), gamma=0.95):
    """Grade de cor para a linguagem APPROVED: contraste firme, saturação alta, sombras levemente frias."""
    x = rgb.astype(np.float32) / 255.0
    x = np.clip(x, 0, 1) ** gamma
    lum = (x * np.array([.299, .587, .114], dtype=np.float32)).sum(-1, keepdims=True)
    x = lum + (x - lum) * saturation
    x = (x - .5) * contrast + .5
    t = np.clip(1.0 - lum * 1.6, 0, 1)
    x = x * (1.0 - t + t * np.array(shadow_tint, dtype=np.float32))
    return (np.clip(x, 0, 1) * 255 + .5).astype(np.uint8)


def fill_small_holes(m, max_size=14):
    """Preenche componentes transparentes pequenos e fechados (furos por alpha parcial), sem tocar vãos ligados ao exterior."""
    h, w = m.shape
    seen = np.zeros_like(m, dtype=bool)
    out = m.copy()
    for y0 in range(h):
        for x0 in range(w):
            if m[y0, x0] or seen[y0, x0]:
                continue
            stack = [(y0, x0)]
            seen[y0, x0] = True
            comp = []
            border = False
            while stack:
                y, x = stack.pop()
                comp.append((y, x))
                if y == 0 or x == 0 or y == h - 1 or x == w - 1:
                    border = True
                for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    yy, xx = y + dy, x + dx
                    if 0 <= yy < h and 0 <= xx < w and not m[yy, xx] and not seen[yy, xx]:
                        seen[yy, xx] = True
                        stack.append((yy, xx))
            if not border and len(comp) <= max_size:
                for y, x in comp:
                    out[y, x] = True
    return out


def clean_alpha(alpha, thr=128, iterations=1):
    m = alpha >= thr
    m = fill_small_holes(m)
    for _ in range(iterations):
        cnt = sum(shift(m.astype(np.uint8), dx, dy) for dx, dy in N8)
        # remove pixels isolados e preenche buracos de 1 px
        m = np.where(m & (cnt <= 1), False, m)
        m = np.where(~m & (cnt >= 7), True, m)
    return m


def _to_oklab(rgb):
    c = rgb.astype(np.float64) / 255.0
    lin = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    M1 = np.array([[0.4122214708, 0.5363325363, 0.0514459929], [0.2119034982, 0.6806995451, 0.1073969566], [0.0883024619, 0.2817188376, 0.6299787005]])
    lms = np.cbrt(lin @ M1.T)
    M2 = np.array([[0.2104542553, 0.7936177850, -0.0040720468], [1.9779984951, -2.4285922050, 0.4505937099], [0.0259040371, 0.7827717662, -0.8086757660]])
    return lms @ M2.T


def _from_oklab(lab):
    M2i = np.linalg.inv(np.array([[0.2104542553, 0.7936177850, -0.0040720468], [1.9779984951, -2.4285922050, 0.4505937099], [0.0259040371, 0.7827717662, -0.8086757660]]))
    M1i = np.linalg.inv(np.array([[0.4122214708, 0.5363325363, 0.0514459929], [0.2119034982, 0.6806995451, 0.1073969566], [0.0883024619, 0.2817188376, 0.6299787005]]))
    lms = (lab @ M2i.T) ** 3
    lin = np.clip(lms @ M1i.T, 0, 1)
    c = np.where(lin <= 0.0031308, lin * 12.92, 1.055 * lin ** (1 / 2.4) - 0.055)
    return (np.clip(c, 0, 1) * 255 + .5).astype(np.uint8)


def quantize_oklab(rgb, mask, colors, iters=10, seed=7):
    """K-means em Oklab (perceptual) sobre as cores únicas ponderadas por frequência; inicialização k-means++ determinística."""
    px = rgb[mask]
    if len(px) == 0:
        return rgb
    uniq, inv, cnt = np.unique(px.reshape(-1, 3), axis=0, return_inverse=True, return_counts=True)
    inv = inv.ravel()
    if len(uniq) <= colors:
        return rgb
    lab = _to_oklab(uniq)
    w = cnt.astype(np.float64)
    rng = np.random.default_rng(seed)
    cent = [lab[int(np.argmax(w))]]
    d2 = np.full(len(lab), np.inf)
    for _ in range(1, colors):
        d2 = np.minimum(d2, ((lab - cent[-1]) ** 2).sum(1))
        p = d2 * w
        cent.append(lab[int(rng.choice(len(lab), p=p / p.sum()))])
    cent = np.array(cent)
    for _ in range(iters):
        idx = ((lab[:, None, :] - cent[None, :, :]) ** 2).sum(2).argmin(1)
        for k in range(colors):
            m = idx == k
            if m.any():
                cent[k] = (lab[m] * w[m, None]).sum(0) / w[m].sum()
    idx = ((lab[:, None, :] - cent[None, :, :]) ** 2).sum(2).argmin(1)
    pal = _from_oklab(cent)
    out = rgb.copy()
    out[mask] = pal[idx[inv]]
    return out


def quantize(rgb, mask, colors):
    if colors <= 0:
        return rgb
    if colors <= 256:
        return quantize_oklab(rgb, mask, colors)
    im = Image.fromarray(rgb, 'RGB')
    alpha = Image.fromarray((mask * 255).astype(np.uint8), 'L')
    base = Image.new('RGB', im.size, (0, 0, 0))
    base.paste(im, mask=alpha)
    q = base.quantize(colors=colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    out = np.asarray(q.convert('RGB'), dtype=np.uint8).copy()
    return out


def despeckle_colors(rgb, mask, passes=1):
    """Remove pixels de cor isolados (ruído): se nenhum vizinho-4 tem a mesma cor, adota a cor mais comum entre os vizinhos."""
    out = rgb.copy()
    for _ in range(passes):
        h, w = mask.shape
        same = np.zeros((h, w), dtype=np.int32)
        for dx, dy in N4:
            nb = shift(out, dx, dy)
            nm = shift(mask, dx, dy)
            same += (nm & mask & (nb == out).all(-1)).astype(np.int32)
        bad = mask & (same == 0)
        ys, xs = np.nonzero(bad)
        for y, x in zip(ys, xs):
            votes = {}
            for dx, dy in N8:
                yy, xx = y + dy, x + dx
                if 0 <= yy < h and 0 <= xx < w and mask[yy, xx]:
                    k = tuple(out[yy, xx])
                    votes[k] = votes.get(k, 0) + 1
            if votes:
                k = max(votes, key=votes.get)
                if votes[k] >= 3:
                    out[y, x] = k
    return out


def outline(rgb, mask, thickness=2, strength=0.22, hue=(0.9, 0.84, 1.0), inner=True):
    """Contorno externo escuro (cor derivada dos vizinhos, levemente arroxeada), como nos APPROVED."""
    out_rgb = rgb.copy()
    out_mask = mask.copy()
    cur = mask.copy()
    for t in range(thickness):
        ring = np.zeros_like(mask)
        acc = np.zeros(mask.shape + (3,), dtype=np.float32)
        cnt = np.zeros(mask.shape, dtype=np.float32)
        for dx, dy in N4:
            nm = shift(cur, dx, dy)
            nc = shift(out_rgb, dx, dy)
            hit = nm & ~cur
            ring |= hit
            acc += nc.astype(np.float32) * hit[..., None]
            cnt += hit
        cnt = np.maximum(cnt, 1)
        base = acc / cnt[..., None]
        k = strength * (1.0 + 0.35 * t)
        col = np.clip(base * k * np.array(hue, dtype=np.float32) + np.array([4, 2, 10], dtype=np.float32), 0, 255).astype(np.uint8)
        out_rgb[ring] = col[ring]
        out_mask |= ring
        cur = out_mask.copy()
    return out_rgb, out_mask


def selective_inner_edges(rgb, mask, depth_edge, strength=0.62):
    """Escurece pixels em descontinuidades de profundidade/ID (bordas internas de formas), sem ruído aleatório."""
    out = rgb.copy()
    m = depth_edge & mask
    out[m] = np.clip(out[m].astype(np.float32) * strength, 0, 255).astype(np.uint8)
    return out


def shadow_layer(shadow, alpha_level=104, dither=True):
    """Sombra pontilhada em dois níveis: núcleo sólido + borda em xadrez Bayer."""
    h, w = shadow.shape
    core = shadow >= 150
    edge = (shadow >= 40) & ~core
    bay = np.tile(BAYER4, (h // 4 + 1, w // 4 + 1))[:h, :w]
    dith = edge & (bay < 0.5) if dither else edge
    m = core | dith
    return m, alpha_level


def compose(asset_rgba, shadow_alpha, colors=128, outline_px=2, do_outline=True, grade_kw=None, shadow_level=104, thr=128, depth_edge=None, inner_strength=0.62):
    a = asset_rgba[..., 3]
    mask = clean_alpha(a, thr)
    rgb = grade(asset_rgba[..., :3], **(grade_kw or {}))
    rgb = quantize(rgb, mask, colors)
    rgb = despeckle_colors(rgb, mask, 1)
    if depth_edge is not None:
        rgb = selective_inner_edges(rgb, mask, depth_edge, inner_strength)
    if do_outline and outline_px > 0:
        rgb, omask = outline(rgb, mask, outline_px)
    else:
        omask = mask
    out = np.zeros(asset_rgba.shape, dtype=np.uint8)
    sh_mask, sh_a = shadow_layer(shadow_alpha, shadow_level)
    sh_mask = sh_mask & ~omask
    out[sh_mask] = (8, 6, 16, sh_a)
    out[omask, :3] = rgb[omask]
    out[omask, 3] = 255
    return out
