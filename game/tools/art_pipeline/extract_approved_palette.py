#!/usr/bin/env python3
"""Extract a controlled Valedouro palette from APPROVED visual assets.

This tool is intentionally data-driven: it scans approved PNGs, ignores
transparent pixels, weights frequent colors, quantizes them to a requested
palette size and writes a JSON palette usable by art tooling.

It does not overwrite artwork.

Usage:
  python3 extract_approved_palette.py game/assets/approved --colors 48 --out game/data/valedouro_palette.json
"""

from __future__ import annotations
import argparse
import json
from collections import Counter
from pathlib import Path
from PIL import Image


def collect(paths):
    counts=Counter()
    total=0
    for root in paths:
        p=Path(root)
        files=list(p.rglob("*.png")) if p.is_dir() else [p]
        for f in files:
            if not f.is_file() or f.suffix.lower()!=".png":
                continue
            im=Image.open(f).convert("RGBA")
            for r,g,b,a in im.getdata():
                if a < 200:
                    continue
                counts[(r,g,b)] += 1
                total += 1
    return counts,total


def quantize_counter(counts, colors):
    # Build a compact weighted image so PIL's median-cut respects frequency
    # without allocating one pixel per source pixel.
    samples=[]
    max_count=max(counts.values(), default=1)
    for rgb,n in counts.items():
        weight=max(1, round(1 + 63*(n/max_count)**0.45))
        samples.extend([rgb]*weight)
    if not samples:
        return []
    im=Image.new("RGB",(len(samples),1))
    im.putdata(samples)
    q=im.quantize(colors=max(2,min(256,colors)),method=Image.Quantize.MEDIANCUT)
    palette=q.getpalette() or []
    used=sorted(set(q.getdata()))
    out=[]
    for idx in used:
        base=idx*3
        if base+2 < len(palette):
            out.append(tuple(palette[base:base+3]))
    return out


def rgb_hex(c):
    return "#%02X%02X%02X" % c


def luminance(c):
    r,g,b=[x/255.0 for x in c]
    return 0.2126*r+0.7152*g+0.0722*b


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("paths",nargs="+")
    ap.add_argument("--colors",type=int,default=48)
    ap.add_argument("--out",required=True)
    args=ap.parse_args()

    counts,total=collect(args.paths)
    palette=quantize_counter(counts,args.colors)
    palette=sorted(palette,key=luminance)

    data={
      "source":"APPROVED Valedouro PNGs",
      "requested_colors":args.colors,
      "source_opaque_pixels":total,
      "colors":[
        {"rgb":list(c),"hex":rgb_hex(c),"luminance":round(luminance(c),6)}
        for c in palette
      ]
    }
    out=Path(args.out)
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding="utf-8")
    print("OK",out,"colors",len(palette),"source_pixels",total)


if __name__=="__main__":
    main()
