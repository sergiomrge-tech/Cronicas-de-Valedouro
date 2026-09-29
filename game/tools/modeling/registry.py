"""Registro de assets modelados: id persistente, categoria, tamanho, âncora e escala de jogo."""
from dataclasses import dataclass
from typing import Callable, Optional

REGISTRY: list = []


@dataclass
class AssetSpec:
    id: str                 # id persistente (nunca renomear)
    group: str              # nature | city | dungeon | interior
    folder: str             # subpasta (ex.: trees, rocks)
    size: tuple             # (w,h) do sprite
    origin: tuple           # pixel do ponto de apoio no chão
    build: Callable
    scale: float = 60.0     # px por unidade de mundo
    draw_scale: float = .5  # escala no jogo
    frames: int = 1
    blocks: Optional[tuple] = None   # (raio_px_no_jogo,) colisão de base; None = sem colisão
    tags: tuple = ()
    seed: int = 1
    shadow: bool = True
    footprint: float = 0.0  # raio de exclusão da vegetação (px de jogo); 0 = usa blocks


def asset(id, group, folder, size, origin, scale=60.0, draw_scale=.5, frames=1, blocks=None, tags=(), seed=1, shadow=True, footprint=0.0):
    def deco(fn):
        REGISTRY.append(AssetSpec(id, group, folder, size, origin, fn, scale, draw_scale, frames, blocks, tags, seed, shadow, footprint))
        return fn
    return deco
