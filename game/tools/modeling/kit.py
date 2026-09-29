"""Kit de modelagem pixel-art volumétrica para Crônicas de Valedouro.

Renderiza primitivas 3D (elipsoides, convexos, cilindros/cones) com câmera
isométrica 2:1 (mesma projeção dos assets APPROVED de Cidade/Dungeon), sombreamento
em rampas de cor de 5-6 tons, sombras projetadas, contorno escuro seletivo e
recorte 1:1 em pixels (sem antialiasing, sem suavização).

Determinístico: mesma cena + mesma seed => mesmos pixels.
"""
from __future__ import annotations
import math
from dataclasses import dataclass, field
from typing import Callable, Optional
import numpy as np
from PIL import Image

OUTLINE = np.array([28, 16, 40], dtype=np.float32)
AZ = math.radians(45.0)
EL = math.radians(30.0)
CAM = np.array([math.cos(EL) * math.cos(AZ), math.cos(EL) * math.sin(AZ), math.sin(EL)], dtype=np.float32)
RIGHT = np.array([-math.sin(AZ), math.cos(AZ), 0.0], dtype=np.float32)
UP = np.array([-math.sin(EL) * math.cos(AZ), -math.sin(EL) * math.sin(AZ), math.cos(EL)], dtype=np.float32)
_L = -RIGHT * 0.78 + np.array([math.cos(AZ), math.sin(AZ), 0.0], dtype=np.float32) * 0.30 + np.array([0, 0, 1.25], dtype=np.float32)
LIGHT = (_L / np.linalg.norm(_L)).astype(np.float32)

BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]], dtype=np.float32) / 16.0 - 0.5


def hexc(h: str) -> tuple:
    h = h.lstrip('#')
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))


def ramp(*hexes: str) -> np.ndarray:
    return np.array([hexc(h) for h in hexes], dtype=np.float32)


# ----------------------------------------------------------------------------- ruído
def _hash3(ix, iy, iz, seed):
    n = (ix * 374761393 + iy * 668265263 + iz * 2147483647 + seed * 1274126177) & 0xFFFFFFFF
    n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
    n = n ^ (n >> 16)
    return (n & 0xFFFF).astype(np.float32) / 65535.0


def noise3(p: np.ndarray, freq: float = 1.0, seed: int = 0) -> np.ndarray:
    """Ruído de valor 3D em [0,1]; p tem shape (N,3)."""
    q = p * freq
    i = np.floor(q).astype(np.int64)
    f = (q - i).astype(np.float32)
    f = f * f * (3 - 2 * f)
    out = 0
    for dx in (0, 1):
        for dy in (0, 1):
            for dz in (0, 1):
                w = (f[:, 0] if dx else 1 - f[:, 0]) * (f[:, 1] if dy else 1 - f[:, 1]) * (f[:, 2] if dz else 1 - f[:, 2])
                out = out + w * _hash3(i[:, 0] + dx, i[:, 1] + dy, i[:, 2] + dz, seed)
    return out


def fbm(p, freq=1.0, seed=0, octaves=3):
    total, amp, norm = 0, 1.0, 0
    for o in range(octaves):
        total = total + amp * noise3(p, freq * (2 ** o), seed + o * 17)
        norm += amp
        amp *= .5
    return total / norm


# ----------------------------------------------------------------------------- materiais
@dataclass
class Mat:
    ramp: np.ndarray                         # (K,3) do mais escuro ao mais claro
    tex: Optional[Callable] = None           # tex(ctx) -> deslocamento de tom (N,) (~[-.5,.5]) ou (tone, color_mix)
    emissive: float = 0.0                    # 0..1: ignora sombra/luz e sobe na rampa
    ambient: float = .32
    contrast: float = 1.0
    zshade: float = .18                      # escurece perto do chão (oclusão de contato)
    jitter: float = 0.0                      # variação de tom por primitiva
    zgrad: Optional[tuple] = None            # (z0, z1, quantidade): escurece abaixo de z1
    no_shadow: bool = False
    tint: Optional[Callable] = None          # tint(ctx, col)->col (N,3): pinta neve, musgo, etc.
    bump: Optional[tuple] = None             # (freq, amp): rugosidade da normal
    name: str = ''


@dataclass
class Ctx:
    P: np.ndarray        # (N,3) posição mundo
    N: np.ndarray        # (N,3) normal
    L: np.ndarray        # (N,3) coordenadas locais normalizadas na primitiva
    prim: int
    seed: int


# ----------------------------------------------------------------------------- primitivas
class Prim:
    mat: Mat
    tag: int = 0

    def hit(self, O, D):  # -> t (N,), normal (N,3), local (N,3)
        raise NotImplementedError


class Ellipsoid(Prim):
    def __init__(self, c, r, mat, seed=0):
        self.c = np.array(c, dtype=np.float32)
        self.r = np.array(r if hasattr(r, '__len__') else (r, r, r), dtype=np.float32)
        self.mat = mat
        self.seed = seed

    def hit(self, O, D):
        o = (O - self.c) / self.r
        d = D / self.r
        a = (d * d).sum(-1)
        b = (o * d).sum(-1)
        cc = (o * o).sum(-1) - 1
        disc = b * b - a * cc
        ok = disc >= 0
        sq = np.sqrt(np.where(ok, disc, 0))
        t = (-b - sq) / a
        t = np.where(ok & (t > 1e-3), t, np.inf)
        P = O + D * np.where(np.isfinite(t), t, 0)[:, None]
        loc = (P - self.c) / self.r
        n = loc / self.r
        n = n / np.maximum(np.linalg.norm(n, axis=-1, keepdims=True), 1e-6)
        return t, n, loc


class Convex(Prim):
    """Interseção de semiespaços n·p <= d (caixas, telhados, prismas, pirâmides)."""

    def __init__(self, planes, mat, center=(0, 0, 0), size=(1, 1, 1)):
        self.n = np.array([p[0] for p in planes], dtype=np.float32)
        self.n /= np.linalg.norm(self.n, axis=1, keepdims=True)
        self.d = np.array([p[1] for p in planes], dtype=np.float32)
        self.mat = mat
        self.center = np.array(center, dtype=np.float32)
        self.size = np.array(size, dtype=np.float32)

    def hit(self, O, D):
        N = O.shape[0]
        tin = np.full(N, -np.inf, dtype=np.float32)
        tout = np.full(N, np.inf, dtype=np.float32)
        nin = np.zeros((N, 3), dtype=np.float32)
        for n, d in zip(self.n, self.d):
            den = D @ n
            num = d - O @ n
            with np.errstate(divide='ignore', invalid='ignore'):
                t = num / den
            enter = den < -1e-8
            leave = den > 1e-8
            parallel = ~(enter | leave)
            upd = enter & (t > tin)
            tin = np.where(upd, t, tin)
            nin[upd] = n
            tout = np.where(leave, np.minimum(tout, t), tout)
            tout = np.where(parallel & (num < 0), -np.inf, tout)
        ok = (tin <= tout) & (tin > 1e-3)
        t = np.where(ok, tin, np.inf)
        P = O + D * np.where(ok, tin, 0)[:, None]
        loc = (P - self.center) / np.maximum(self.size * .5, 1e-6)
        return t, nin, loc


def box(c, s, mat, rot=0.0):
    """Caixa centrada em c, tamanho s=(sx,sy,sz), rotação em torno de Z (graus)."""
    ca, sa = math.cos(math.radians(rot)), math.sin(math.radians(rot))
    ax = np.array([ca, sa, 0.0]); ay = np.array([-sa, ca, 0.0]); az = np.array([0.0, 0.0, 1.0])
    c = np.array(c, dtype=np.float64)
    planes = []
    for axis, half in ((ax, s[0] / 2), (ay, s[1] / 2), (az, s[2] / 2)):
        planes.append((axis, float(axis @ c) + half))
        planes.append((-axis, float(-axis @ c) + half))
    return Convex(planes, mat, c, s)


def prism_roof(c, s, mat, rot=0.0, ridge=1.0, pitch=None):
    """Telhado de duas águas: base retangular s=(sx,sy), altura sz, cumeeira ao longo de X local."""
    ca, sa = math.cos(math.radians(rot)), math.sin(math.radians(rot))
    ax = np.array([ca, sa, 0.0]); ay = np.array([-sa, ca, 0.0]); az = np.array([0.0, 0.0, 1.0])
    c = np.array(c, dtype=np.float64)
    hx, hy, hz = s[0] / 2, s[1] / 2, s[2]
    planes = [(ax, float(ax @ c) + hx), (-ax, float(-ax @ c) + hx), (-az, float(-az @ c))]
    # águas: plano passa pela aresta (y=±hy, z=0) e pela cumeeira (y=0, z=hz)
    for sign in (1, -1):
        n = ay * sign * hz + az * hy
        n = n / np.linalg.norm(n)
        p0 = c + ay * sign * hy
        planes.append((n, float(n @ p0)))
    return Convex(planes, mat, c + az * hz / 2, s)


def pyramid(c, base, height, mat, rot=45.0, sides=4):
    c = np.array(c, dtype=np.float64)
    planes = [(np.array([0, 0, -1.0]), float(-c[2]))]
    for k in range(sides):
        ang = math.radians(rot + 360.0 * k / sides)
        nh = np.array([math.cos(ang), math.sin(ang), 0.0])
        # plano passa por (base ao longo de nh, z=0) e ápice (0,0,height)
        n = nh * height + np.array([0, 0, base])
        n = n / np.linalg.norm(n)
        p0 = c + nh * base
        planes.append((n, float(n @ p0)))
    return Convex(planes, mat, c + np.array([0, 0, height / 2]), (base * 2, base * 2, height))


class Xform(Prim):
    """Aplica rotação/translação a uma primitiva definida em espaço local."""

    def __init__(self, inner, rot=(0, 0, 0), pos=(0, 0, 0)):
        self.inner = inner
        self.mat = inner.mat
        rx, ry, rz = (math.radians(a) for a in rot)
        Rx = np.array([[1, 0, 0], [0, math.cos(rx), -math.sin(rx)], [0, math.sin(rx), math.cos(rx)]])
        Ry = np.array([[math.cos(ry), 0, math.sin(ry)], [0, 1, 0], [-math.sin(ry), 0, math.cos(ry)]])
        Rz = np.array([[math.cos(rz), -math.sin(rz), 0], [math.sin(rz), math.cos(rz), 0], [0, 0, 1]])
        self.R = (Rz @ Ry @ Rx).astype(np.float32)
        self.p = np.array(pos, dtype=np.float32)

    def hit(self, O, D):
        Ol = (O - self.p) @ self.R
        Dl = D @ self.R
        t, n, loc = self.inner.hit(Ol, Dl)
        return t, n @ self.R.T, loc


class Cylinder(Prim):
    """Cilindro/cone truncado com eixo em Z (r0 embaixo, r1 em cima)."""

    def __init__(self, c, h, r0, r1, mat, cap_bottom=False):
        self.c = np.array(c, dtype=np.float32)
        self.h = h
        self.r0 = r0
        self.r1 = r1
        self.mat = mat
        self.cap_bottom = cap_bottom

    def hit(self, O, D):
        c = self.c
        k = (self.r1 - self.r0) / self.h
        ox, oy, oz = O[:, 0] - c[0], O[:, 1] - c[1], O[:, 2] - c[2]
        dx, dy, dz = D[:, 0], D[:, 1], D[:, 2]
        rr = self.r0 + k * oz
        a = dx * dx + dy * dy - k * k * dz * dz
        b = 2 * (ox * dx + oy * dy - k * dz * rr)
        cc = ox * ox + oy * oy - rr * rr
        with np.errstate(divide='ignore', invalid='ignore'):
            disc = b * b - 4 * a * cc
            ok = disc >= 0
            sq = np.sqrt(np.where(ok, disc, 0))
            t1 = (-b - sq) / (2 * a)
            t2 = (-b + sq) / (2 * a)
        best = np.full(O.shape[0], np.inf, dtype=np.float32)
        for t in (t1, t2):
            z = oz + t * dz
            good = ok & (t > 1e-3) & (z >= 0) & (z <= self.h) & (t < best)
            best = np.where(good, t, best)
        # tampa superior (e inferior opcional)
        caps = [(self.h, self.r1, 1.0)]
        if self.cap_bottom:
            caps.append((0.0, self.r0, -1.0))
        cap_n = None
        for zc, rc, sgn in caps:
            with np.errstate(divide='ignore', invalid='ignore'):
                t = (zc - oz) / dz
            x = ox + t * dx
            y = oy + t * dy
            good = (t > 1e-3) & (x * x + y * y <= rc * rc) & (t < best) & (np.abs(dz) > 1e-6)
            if cap_n is None:
                cap_n = np.zeros(O.shape[0], dtype=np.float32)
            cap_n = np.where(good, sgn, cap_n)
            best = np.where(good, t, best)
        hitm = np.isfinite(best)
        tt = np.where(hitm, best, 0)
        px = ox + tt * dx
        py = oy + tt * dy
        pz = oz + tt * dz
        rz = self.r0 + k * pz
        n = np.stack([px, py, -k * rz], axis=-1)
        n = n / np.maximum(np.linalg.norm(n, axis=-1, keepdims=True), 1e-6)
        is_cap = (cap_n != 0) & hitm
        n[is_cap] = np.stack([np.zeros(is_cap.sum()), np.zeros(is_cap.sum()), cap_n[is_cap]], axis=-1)
        rmax = max(self.r0, self.r1, 1e-6)
        loc = np.stack([px / rmax, py / rmax, pz / self.h * 2 - 1], axis=-1)
        return best, n, loc


# ----------------------------------------------------------------------------- cena
class Scene:
    def __init__(self, w: int, h: int, origin: tuple, scale: float = 64.0, seed: int = 1):
        self.w, self.h = w, h
        self.origin = origin      # pixel de (0,0,0)
        self.s = scale
        self.seed = seed
        self.prims: list[Prim] = []
        self.rng = np.random.default_rng(seed)
        self.glow: list[tuple] = []          # (x,y,z,raio_px,cor,intensidade)
        self.ground_shadow = True
        self.shadow_alpha = .36
        self.outline_depth = .10
        self.shadow_range = 3.0
        self.shadow_radius = 2.6

    # -- construção
    def add(self, prim: Prim, tag: int = 0):
        prim.tag = tag
        self.prims.append(prim)
        return prim

    def project(self, P):
        P = np.asarray(P, dtype=np.float32)
        return (self.origin[0] + self.s * (P @ RIGHT), self.origin[1] - self.s * (P @ UP))

    # -- render
    def render(self) -> Image.Image:
        w, h, s = self.w, self.h, self.s
        yy, xx = np.mgrid[0:h, 0:w]
        sx = (xx.reshape(-1) + .5 - self.origin[0]) / s
        sy = (self.origin[1] - (yy.reshape(-1) + .5)) / s
        T = 60.0
        O = RIGHT[None] * sx[:, None] + UP[None] * sy[:, None] + CAM[None] * T
        D = np.broadcast_to(-CAM, O.shape).astype(np.float32)
        n_px = O.shape[0]
        best = np.full(n_px, np.inf, dtype=np.float32)
        which = np.full(n_px, -1, dtype=np.int32)
        normal = np.zeros((n_px, 3), dtype=np.float32)
        local = np.zeros((n_px, 3), dtype=np.float32)
        for i, prim in enumerate(self.prims):
            t, n, loc = prim.hit(O, D)
            upd = t < best
            best = np.where(upd, t, best)
            which = np.where(upd, i, which)
            normal[upd] = n[upd]
            local[upd] = loc[upd]
        hit = which >= 0
        P = O + D * np.where(hit, best, 0)[:, None]
        # sombras projetadas nas superfícies e no chão
        shadow = np.zeros(n_px, dtype=bool)
        idx = np.where(hit)[0]
        if len(idx):
            shadow[idx] = self._in_shadow(P[idx] + normal[idx] * 0.02)
        # chão (z=0) para pixels sem hit
        ground_shadow = np.zeros(n_px, dtype=bool)
        if self.ground_shadow:
            with np.errstate(divide='ignore', invalid='ignore'):
                tg = (0 - O[:, 2]) / D[:, 2]
            gp = O + D * tg[:, None]
            gidx = np.where(~hit)[0]
            if len(gidx):
                gs = self._in_shadow(gp[gidx] + np.array([0, 0, 0.01], dtype=np.float32))
                near = np.hypot(gp[gidx, 0], gp[gidx, 1]) < self.shadow_radius
                ground_shadow[gidx] = gs & near
        # cor
        rgb = np.zeros((n_px, 3), dtype=np.float32)
        alpha = np.zeros(n_px, dtype=np.float32)
        for i, prim in enumerate(self.prims):
            m = which == i
            if not m.any():
                continue
            mat = prim.mat
            nm = normal[m]
            if mat.bump:
                fq, am = mat.bump
                pm = P[m]
                e = 0.02
                g0 = fbm(pm, fq, self.seed + 31, 2)
                gx = fbm(pm + np.array([e, 0, 0], dtype=np.float32), fq, self.seed + 31, 2) - g0
                gy = fbm(pm + np.array([0, e, 0], dtype=np.float32), fq, self.seed + 31, 2) - g0
                gz = fbm(pm + np.array([0, 0, e], dtype=np.float32), fq, self.seed + 31, 2) - g0
                nm = nm - np.stack([gx, gy, gz], -1) / e * am * .05
                nm = nm / np.maximum(np.linalg.norm(nm, axis=-1, keepdims=True), 1e-6)
            ctx = Ctx(P[m], nm, local[m], i, self.seed)
            ndl = np.clip((nm * LIGHT).sum(-1), 0, 1)
            tone = self._shade(mat, ctx, ndl, shadow[m])
            K = len(mat.ramp)
            fidx = tone * (K - 1)
            xs = (np.where(m)[0] % w)
            ys = (np.where(m)[0] // w)
            fidx = fidx + BAYER[ys % 4, xs % 4] * .34
            lo = np.clip(np.round(fidx), 0, K - 1).astype(int)
            col = mat.ramp[lo]
            if mat.tint is not None:
                col = mat.tint(ctx, col, tone)
            rgb[m] = col
            alpha[m] = 1.0
        # sombra no chão: pixels translúcidos
        gs_mask = ground_shadow
        rgb[gs_mask] = np.array([22, 12, 40], dtype=np.float32)
        alpha[gs_mask] = self.shadow_alpha
        # contorno interno por descontinuidade de profundidade
        depth = np.where(hit, best, np.inf).reshape(h, w)
        edge = np.zeros((h, w), dtype=bool)
        wh = which.reshape(h, w)
        for dy, dx in ((0, 1), (1, 0), (0, -1), (-1, 0)):
            nb = np.roll(np.roll(depth, dy, axis=0), dx, axis=1)
            nw = np.roll(np.roll(wh, dy, axis=0), dx, axis=1)
            edge |= (np.isfinite(depth) & np.isfinite(nb) & (depth > nb + self.outline_depth) & (nw != wh))
        rgb = rgb.reshape(h, w, 3)
        alpha = alpha.reshape(h, w)
        rgb[edge] = rgb[edge] * .42 + OUTLINE * .58
        img = np.zeros((h, w, 4), dtype=np.float32)
        img[..., :3] = rgb
        img[..., 3] = alpha * 255
        # brilho (glow) atrás de emissivos
        base = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), 'RGBA')
        base = self._add_glow(base)
        return outline_selective(base)

    def _in_shadow(self, Pts):
        Ls = np.broadcast_to(LIGHT, Pts.shape).astype(np.float32)
        sh = np.zeros(len(Pts), dtype=bool)
        for prim in self.prims:
            if getattr(prim.mat, 'no_shadow', False):
                continue
            t, _, _ = prim.hit(Pts, Ls)
            sh |= (t < self.shadow_range)
        return sh

    def _shade(self, mat: Mat, ctx: Ctx, ndl, shadow):
        if mat.emissive > 0:
            base = .55 + .45 * ndl
        else:
            lit = np.where(shadow, 0.0, ndl)
            base = mat.ambient + (1 - mat.ambient) * lit
            base = np.where(shadow, np.minimum(base, mat.ambient + .12), base)
        if mat.tex is not None:
            off = mat.tex(ctx)
            base = base + off
        if mat.jitter:
            base = base + (_hash3(np.full(len(base), ctx.prim, dtype=np.int64), np.full(len(base), 5, dtype=np.int64), np.full(len(base), 9, dtype=np.int64), ctx.seed) - .5) * 2 * mat.jitter
        if mat.zgrad:
            z0, z1, amt = mat.zgrad
            base = base - amt * np.clip((z1 - ctx.P[:, 2]) / max(z1 - z0, 1e-6), 0, 1)
        # escurece perto do chão
        base = base - mat.zshade * np.clip((0.35 - ctx.P[:, 2]) / 0.35, 0, 1)
        base = (base - .5) * mat.contrast + .5
        return np.clip(base, 0, 1)

    def _add_glow(self, im: Image.Image) -> Image.Image:
        if not self.glow:
            return im
        arr = np.array(im).astype(np.float32)
        yy, xx = np.mgrid[0:self.h, 0:self.w]
        for (x, y, z, rad, col, inten) in self.glow:
            px, py = self.project((x, y, z))
            d = np.hypot(xx - px, yy - py) / rad
            g = np.clip(1 - d, 0, 1) ** 2 * inten
            a = arr[..., 3] / 255.0
            # halo aditivo sobre o que existe e leve halo no vazio
            for c in range(3):
                arr[..., c] = arr[..., c] * (1 - g * .0) + col[c] * g * (1 - a * .6) * .0 + col[c] * g * .35 * a
            empty = 1 - a
            new_a = np.clip(g * .55 * empty, 0, 1)
            for c in range(3):
                arr[..., c] = np.where(new_a > 0, (arr[..., c] * a + col[c] * new_a) / np.maximum(a + new_a, 1e-6), arr[..., c])
            arr[..., 3] = np.clip((a + new_a) * 255, 0, 255)
        return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), 'RGBA')


def outline_selective(im: Image.Image, strength=.78) -> Image.Image:
    """Contorno externo de 1px: cor do vizinho escurecida e puxada ao roxo-noite."""
    a = np.array(im).astype(np.float32)
    h, w = a.shape[:2]
    alpha = a[..., 3]
    solid = alpha > 140
    out = a.copy()
    empty = alpha < 40
    best = np.zeros((h, w, 3), dtype=np.float32)
    got = np.zeros((h, w), dtype=bool)
    for dy, dx in ((0, 1), (1, 0), (0, -1), (-1, 0)):
        nb = np.roll(np.roll(a, dy, axis=0), dx, axis=1)
        ns = np.roll(np.roll(solid, dy, axis=0), dx, axis=1)
        take = ns & ~got & empty
        best[take] = nb[take][:, :3]
        got |= take
    edge = got
    col = best * (1 - strength) + OUTLINE * strength
    out[edge, :3] = col[edge]
    out[edge, 3] = 255
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), 'RGBA')


# ----------------------------------------------------------------------------- texturas úteis
def tex_stone_blocks(scale=3.0, mortar=.22, seed=3, grain=.16, joints=True):
    def f(ctx: Ctx):
        P = ctx.P
        g = (fbm(P, 6, seed, 2) - .5) * grain * 2
        if not joints:
            return g
        # cortes horizontais em Z e verticais alternados por fileira
        row = np.floor(P[:, 2] * scale)
        pos = (P[:, 0] * RIGHT[0] + P[:, 1] * RIGHT[1]) * scale + (row % 2) * .5
        fz = P[:, 2] * scale - row
        fx = pos - np.floor(pos)
        line = (fz < .09) | (fx < .07)
        top = ctx.N[:, 2] > .9
        return g - np.where(line & ~top, mortar, 0)
    return f


def tex_speckle(freq=9.0, amp=.25, seed=1):
    def f(ctx: Ctx):
        return (noise3(ctx.P, freq, seed) - .5) * amp * 2
    return f


def tex_bark(freq=5.0, amp=.3, seed=2):
    def f(ctx: Ctx):
        P = ctx.P
        q = np.stack([P[:, 0] * 8, P[:, 1] * 8, P[:, 2] * freq * .35], axis=-1)
        return (noise3(q, 1.0, seed) - .5) * amp * 2
    return f


def tex_wood_planks(scale=6.0, amp=.2, seed=4, along='x'):
    def f(ctx: Ctx):
        P = ctx.P
        u = P[:, 1] if along == 'x' else P[:, 0]
        k = u * scale
        gap = (k - np.floor(k)) < .08
        grain = (noise3(np.stack([P[:, 0] * (1.5 if along == 'x' else 14), P[:, 1] * (14 if along == 'x' else 1.5), P[:, 2] * 3], -1), 1, seed) - .5) * amp
        tone = (np.floor(k) % 3 - 1) * .07
        return grain + tone - np.where(gap, .22, 0)
    return f


def tex_leaf(petals=5, spread=.72, amp=.42, seed=5):
    """Aglomerado de folhas com realce em estrela (linguagem dos assets aprovados)."""
    def f(ctx: Ctx):
        loc = ctx.L
        px = loc @ RIGHT
        py = loc @ UP
        rad = np.hypot(px, py)
        th = np.arctan2(py, px)
        ph = _hash3((ctx.P[:, 0] * 3).astype(np.int64) * 0 + ctx.prim, ctx.prim * 7 + 3, ctx.prim, seed) * 6.28
        star = (0.5 + 0.5 * np.cos(petals * th + ph)) * np.clip(1 - rad / spread, 0, 1)
        return star * amp - .10
    return f
