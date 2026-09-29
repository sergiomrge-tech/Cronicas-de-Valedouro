"""Colisão composta: círculos (px de jogo, relativos ao pé) que cobrem um retângulo de chão sx x sy (unidades de mundo)."""
import math

S = 60.0


def footprint_circles(sx, sy, step=.85, shrink=.9):
    out = []
    nx = max(1, int(math.ceil(sx / step)))
    ny = max(1, int(math.ceil(sy / step)))
    for i in range(nx):
        for j in range(ny):
            X = -sx / 2 + (i + .5) * sx / nx
            Y = -sy / 2 + (j + .5) * sy / ny
            dx = .7071 * (Y - X) * S * .5
            dy = .5 * .7071 * (X + Y) * S * .5
            r = max(sx / nx, sy / ny) * .5 * .7071 * S * .5 * 1.55 * shrink
            out.append((round(dx, 1), round(dy, 1), round(r, 1)))
    return tuple(out)
