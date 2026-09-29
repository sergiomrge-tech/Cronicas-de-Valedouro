#!/usr/bin/env python3
"""Pack Valedouro NPC/fauna directional animation frames into Godot sprite sheets.

Expected input:
  ROOT/<asset_id>/<animation>/dir_00/frame_00.png
  ROOT/<asset_id>/<animation>/dir_00/frame_01.png
  ...
  ROOT/<asset_id>/<animation>/dir_07/frame_XX.png

Fallback for static directional sources:
  ROOT/<asset_id>/dir_00.png ... dir_07.png

Output layout matches the current hero convention:
  columns = animation frames
  rows    = 8 directions

All resampling is NEAREST. Alpha is preserved.
"""

from __future__ import annotations
import argparse
import json
from pathlib import Path
from PIL import Image

DIRECTIONS=8

def load_rgba(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")

def fit_nearest(im: Image.Image, size: tuple[int,int]) -> Image.Image:
    if im.size == size:
        return im
    return im.resize(size,Image.Resampling.NEAREST)

def frame_paths(root: Path, asset_id: str, animation: str, direction: int) -> list[Path]:
    d=root/asset_id/animation/f"dir_{direction:02d}"
    if d.is_dir():
        return sorted(d.glob("frame_*.png"))
    static=root/asset_id/f"dir_{direction:02d}.png"
    return [static] if static.exists() else []

def pack(root: Path, asset_id: str, animation: str, frame_size: tuple[int,int], expected_frames: int, out: Path):
    dirs=[]
    for direction in range(DIRECTIONS):
        files=frame_paths(root,asset_id,animation,direction)
        if not files:
            raise FileNotFoundError(f"{asset_id}/{animation}: missing direction {direction}")
        if expected_frames and len(files)!=expected_frames:
            raise ValueError(f"{asset_id}/{animation}/dir_{direction:02d}: expected {expected_frames} frames, got {len(files)}")
        dirs.append(files)

    frames=len(dirs[0])
    if any(len(x)!=frames for x in dirs):
        raise ValueError("all directions must contain the same frame count")

    fw,fh=frame_size
    sheet=Image.new("RGBA",(fw*frames,fh*DIRECTIONS),(0,0,0,0))
    for row,files in enumerate(dirs):
        for col,path in enumerate(files):
            im=fit_nearest(load_rgba(path),(fw,fh))
            sheet.alpha_composite(im,(col*fw,row*fh))

    out.parent.mkdir(parents=True,exist_ok=True)
    sheet.save(out,optimize=True)
    return {
        "asset_id":asset_id,
        "animation":animation,
        "frame_size":[fw,fh],
        "frames":frames,
        "rows":DIRECTIONS,
        "sheet_size":list(sheet.size),
        "path":str(out)
    }

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("root")
    ap.add_argument("spec")
    ap.add_argument("output_dir")
    ap.add_argument("--report")
    args=ap.parse_args()

    root=Path(args.root)
    spec=json.loads(Path(args.spec).read_text(encoding="utf-8"))
    outdir=Path(args.output_dir)
    results=[]

    for family in spec["npcs"]["families"]:
        fw,fh=spec["npcs"]["target_frame_px"]
        for anim,adata in spec["npcs"]["animations"].items():
            results.append(pack(root,family,anim,(fw,fh),int(adata["frames"]),outdir/f"{family}_{anim}.png"))

    for species,sdata in spec["fauna"]["species"].items():
        fw,fh=sdata["frame_px"]
        for anim in ("idle","walk","fly","swim"):
            n=int(sdata.get(anim,0) or 0)
            if n:
                results.append(pack(root,f"fauna_{species}",anim,(fw,fh),n,outdir/f"fauna_{species}_{anim}.png"))

    report={"schema_version":1,"sheets":results}
    if args.report:
        p=Path(args.report); p.parent.mkdir(parents=True,exist_ok=True)
        p.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
    print("OK",len(results),"sheets")
    return 0

if __name__=="__main__":
    raise SystemExit(main())
