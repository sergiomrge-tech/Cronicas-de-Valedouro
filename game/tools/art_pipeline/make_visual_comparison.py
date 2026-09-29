#!/usr/bin/env python3
"""Build before/after contact sheets for Valedouro visual reviews.

Pairs old/legacy and candidate art by a small JSON mapping so the Director can
judge actual improvement at both 100% and gameplay scale.

Mapping format:
{
  "pairs": [
    {
      "id": "watchtower",
      "before": "path/old.png",
      "after": "path/new.png",
      "reference": "optional/approved.png"
    }
  ]
}
"""

from __future__ import annotations
import argparse
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


def load_rgba(path: str) -> Image.Image:
    return Image.open(path).convert("RGBA")


def fit(im: Image.Image, box_w: int, box_h: int, scale_mode="nearest") -> Image.Image:
    if im.width == 0 or im.height == 0:
        return im
    ratio = min(box_w / im.width, box_h / im.height)
    ratio = max(ratio, 1.0 / max(im.width, im.height))
    nw = max(1, int(round(im.width * ratio)))
    nh = max(1, int(round(im.height * ratio)))
    resample = Image.Resampling.NEAREST if scale_mode == "nearest" else Image.Resampling.BILINEAR
    return im.resize((nw, nh), resample)


def checker(w, h, cell=8):
    a = (56, 60, 66, 255)
    b = (72, 77, 84, 255)
    out = Image.new("RGBA", (w, h), a)
    d = ImageDraw.Draw(out)
    for y in range(0, h, cell):
        for x in range(0, w, cell):
            if ((x // cell) + (y // cell)) % 2:
                d.rectangle((x, y, min(w-1,x+cell-1), min(h-1,y+cell-1)), fill=b)
    return out


def composite_center(bg: Image.Image, im: Image.Image, x0: int, y0: int, w: int, h: int):
    scaled = fit(im, w, h)
    x = x0 + (w - scaled.width)//2
    y = y0 + (h - scaled.height)//2
    bg.alpha_composite(scaled, (x,y))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("mapping")
    ap.add_argument("output")
    ap.add_argument("--cell", type=int, default=260)
    ap.add_argument("--gameplay-scale", type=float, default=0.5)
    args = ap.parse_args()

    data = json.loads(Path(args.mapping).read_text(encoding="utf-8"))
    pairs = data.get("pairs", [])
    if not pairs:
        raise SystemExit("mapping has no pairs")

    cols = 3
    cell = args.cell
    title_h = 28
    row_h = cell + title_h + 105
    width = cols * cell
    height = len(pairs) * row_h + 32
    sheet = checker(width, height, 12)
    d = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()

    headers = ["BEFORE", "AFTER", "APPROVED REF"]
    for c, header in enumerate(headers):
        d.text((c*cell+8, 8), header, fill=(255,255,255,255), font=font)

    y = 32
    for p in pairs:
        pid = p.get("id","unnamed")
        d.rectangle((0,y,width-1,y+title_h-1), fill=(27,29,35,235))
        d.text((8,y+7), pid, fill=(245,245,245,255), font=font)

        paths = [p.get("before"), p.get("after"), p.get("reference")]
        ims = []
        for path in paths:
            if path and Path(path).exists():
                ims.append(load_rgba(path))
            else:
                ims.append(None)

        for c, im in enumerate(ims):
            x0=c*cell
            by=y+title_h
            if im:
                composite_center(sheet, im, x0, by, cell, cell)
            else:
                d.text((x0+12, by+cell//2), "N/A", fill=(210,210,210,255), font=font)

        # Gameplay-scale strip under the main cells.
        gy = y + title_h + cell + 4
        d.rectangle((0,gy,width-1,gy+96), fill=(36,40,46,230))
        d.text((8, gy+5), "GAMEPLAY SCALE", fill=(225,225,225,255), font=font)
        for c, im in enumerate(ims):
            if not im:
                continue
            scaled = im.resize(
                (max(1,int(im.width*args.gameplay_scale)), max(1,int(im.height*args.gameplay_scale))),
                Image.Resampling.NEAREST,
            )
            x0=c*cell
            maxw=cell-12
            maxh=68
            scaled=fit(scaled,maxw,maxh)
            sheet.alpha_composite(scaled,(x0+(cell-scaled.width)//2,gy+24+(maxh-scaled.height)//2))

        y += row_h

    Path(args.output).parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.output, quality=95)
    print("OK", args.output)


if __name__ == "__main__":
    main()
