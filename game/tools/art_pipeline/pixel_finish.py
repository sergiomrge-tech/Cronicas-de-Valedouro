#!/usr/bin/env python3
"""Valedouro pixel finish helper.

This is the bridge between a Blender/high-resolution pre-render and the manual
pixel-art cleanup pass. It intentionally performs only deterministic operations:
nearest-neighbor downsample, hard-alpha cleanup and optional palette reduction.

It must NOT be used as an excuse to skip hand cleanup.

Examples:
  python3 pixel_finish.py render.png out.png --size 128 128 --alpha-threshold 128
  python3 pixel_finish.py render.png out.png --scale-div 4 --colors 48
"""

from __future__ import annotations

import argparse
from pathlib import Path
from PIL import Image


def harden_alpha(im: Image.Image, threshold: int) -> Image.Image:
    im = im.convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a < threshold:
                px[x, y] = (0, 0, 0, 0)
            else:
                px[x, y] = (r, g, b, 255)
    return im


def quantize_opaque(im: Image.Image, colors: int) -> Image.Image:
    """Quantize RGB while preserving the already-hardened alpha channel."""
    alpha = im.getchannel("A")
    rgb = Image.new("RGB", im.size, (0, 0, 0))
    rgb.paste(im.convert("RGB"), mask=alpha)

    q = rgb.quantize(colors=max(2, min(colors, 256)), method=Image.Quantize.MEDIANCUT)
    rgb2 = q.convert("RGB")
    out = rgb2.convert("RGBA")
    out.putalpha(alpha)

    # Transparent pixels must have zero RGB to prevent halo on later processing.
    p = out.load()
    a = alpha.load()
    for y in range(out.height):
        for x in range(out.width):
            if a[x, y] == 0:
                p[x, y] = (0, 0, 0, 0)
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("output")
    size = ap.add_mutually_exclusive_group(required=False)
    size.add_argument("--size", nargs=2, type=int, metavar=("W", "H"))
    size.add_argument("--scale-div", type=int, help="integer downsample divisor")
    ap.add_argument("--alpha-threshold", type=int, default=128)
    ap.add_argument("--colors", type=int, default=0, help="optional palette cap (0 = keep colors)")
    args = ap.parse_args()

    src = Path(args.input)
    out = Path(args.output)
    im = Image.open(src).convert("RGBA")

    if args.size:
        target = (args.size[0], args.size[1])
        if target[0] <= 0 or target[1] <= 0:
            raise SystemExit("invalid --size")
        im = im.resize(target, Image.Resampling.NEAREST)
    elif args.scale_div:
        if args.scale_div <= 0:
            raise SystemExit("--scale-div must be > 0")
        if im.width % args.scale_div or im.height % args.scale_div:
            raise SystemExit("input dimensions must divide exactly by --scale-div")
        im = im.resize(
            (im.width // args.scale_div, im.height // args.scale_div),
            Image.Resampling.NEAREST,
        )

    im = harden_alpha(im, max(0, min(args.alpha_threshold, 255)))

    if args.colors:
        im = quantize_opaque(im, args.colors)

    out.parent.mkdir(parents=True, exist_ok=True)
    im.save(out)
    print(f"OK {src} -> {out} {im.size}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
