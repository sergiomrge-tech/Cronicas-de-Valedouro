#!/usr/bin/env python3
"""Visual-complexity benchmark for Valedouro pixel-art candidates.

This does NOT decide whether art is good or APPROVED.
It catches a common production failure seen in REG_001: a candidate is
technically valid but substantially simpler/flatter than nearby APPROVED art.

Metrics are normalized inside the visible alpha bounding box:
- quantized palette richness;
- edge density;
- local luminance variation;
- silhouette perimeter/area ratio;
- occupied-shape density.

Usage:
  python visual_complexity_gate.py mapping.json --game-root game --out report.json

Mapping:
{
  "pairs":[
    {"candidate":"res://assets/modeled/...", "references":["res://assets/approved/..."]}
  ]
}
"""

from __future__ import annotations
import argparse
import json
from pathlib import Path
import numpy as np
from PIL import Image

def resolve(path: str, game_root: Path) -> Path:
    if path.startswith("res://"):
        return game_root / path[len("res://"):]
    return Path(path)

def visible_crop(path: Path):
    im=Image.open(path).convert("RGBA")
    alpha=np.asarray(im.getchannel("A"),dtype=np.uint8)
    ys,xs=np.where(alpha>32)
    if len(xs)==0:
        raise ValueError(f"fully transparent: {path}")
    x0,x1=int(xs.min()),int(xs.max())+1
    y0,y1=int(ys.min()),int(ys.max())+1
    arr=np.asarray(im.crop((x0,y0,x1,y1)),dtype=np.uint8)
    return arr

def lum(rgb):
    a=rgb.astype(np.float32)/255.0
    return a[...,0]*.2126+a[...,1]*.7152+a[...,2]*.0722

def palette_count(arr, colors=32):
    a=arr[...,3]
    rgb=Image.fromarray(arr[...,:3],"RGB")
    mask=a>32
    # Quantize the full crop, then only count bins actually used by visible pixels.
    q=np.asarray(rgb.quantize(colors=colors,method=Image.Quantize.MEDIANCUT))
    return int(len(np.unique(q[mask])))

def metrics(path: Path):
    a=visible_crop(path)
    alpha=a[...,3]>32
    l=lum(a[...,:3])
    # Neighbour differences; only count where both sides are visible.
    dx=np.abs(l[:,1:]-l[:,:-1])
    dy=np.abs(l[1:,:]-l[:-1,:])
    mx=alpha[:,1:] & alpha[:,:-1]
    my=alpha[1:,:] & alpha[:-1,:]
    edge_vals=np.concatenate([dx[mx],dy[my]]) if mx.any() or my.any() else np.array([0.0],dtype=np.float32)
    edge_density=float((edge_vals>.075).mean())
    local_variation=float(edge_vals.mean())

    # Silhouette perimeter approximation.
    pad=np.pad(alpha.astype(np.uint8),1)
    c=pad[1:-1,1:-1]
    nbr=pad[:-2,1:-1]+pad[2:,1:-1]+pad[1:-1,:-2]+pad[1:-1,2:]
    perimeter=int(((c==1)&(nbr<4)).sum())
    area=max(1,int(alpha.sum()))

    return {
        "size":[int(a.shape[1]),int(a.shape[0])],
        "visible_pixels":area,
        "occupancy":round(float(alpha.mean()),5),
        "palette32_used":palette_count(a,32),
        "edge_density":round(edge_density,5),
        "local_variation":round(local_variation,5),
        "silhouette_perimeter_area":round(perimeter/area,5)
    }

def aggregate(refs):
    keys=["palette32_used","edge_density","local_variation","silhouette_perimeter_area"]
    return {k:float(np.mean([r[k] for r in refs])) for k in keys}

def score(candidate, ref_avg):
    # Ratios are diagnostic. Complexity > reference is not automatically better.
    ratios={}
    for k in ("palette32_used","edge_density","local_variation","silhouette_perimeter_area"):
        ratios[k]=round(float(candidate[k])/max(float(ref_avg[k]),1e-6),4)
    return ratios

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("mapping")
    ap.add_argument("--game-root",default="game")
    ap.add_argument("--out")
    ap.add_argument("--warn-below",type=float,default=.62,
                    help="warn when edge/local/palette ratio falls below this fraction of references")
    args=ap.parse_args()

    game=Path(args.game_root)
    mapping=json.loads(Path(args.mapping).read_text(encoding="utf-8"))
    results=[]
    for item in mapping.get("pairs",[]):
        cp=resolve(item["candidate"],game)
        if not cp.exists():
            results.append({"id":item.get("id",cp.stem),"status":"MISSING_CANDIDATE","candidate":str(cp)})
            continue
        refs=[]
        missing=[]
        for raw in item.get("references",[]):
            p=resolve(raw,game)
            if p.exists(): refs.append(metrics(p))
            else: missing.append(str(p))
        if not refs:
            results.append({"id":item.get("id",cp.stem),"status":"NO_REFERENCE","candidate":str(cp),"missing_references":missing})
            continue

        cm=metrics(cp)
        ravg=aggregate(refs)
        ratios=score(cm,ravg)
        warnings=[]
        for k in ("palette32_used","edge_density","local_variation"):
            if ratios[k] < args.warn_below:
                warnings.append(f"{k} is only {ratios[k]:.2f}x reference average")
        status="WARN" if warnings else "PASS_DIAGNOSTIC"
        results.append({
            "id":item.get("id",cp.stem),
            "candidate":str(cp),
            "candidate_metrics":cm,
            "reference_average":{k:round(v,5) for k,v in ravg.items()},
            "ratios":ratios,
            "status":status,
            "warnings":warnings,
            "note":"Diagnostic complexity only; Director visual review remains authoritative."
        })

    report={
        "schema_version":1,
        "results":results,
        "summary":{
            "total":len(results),
            "warnings":sum(r.get("status")=="WARN" for r in results),
            "missing":sum(r.get("status") in ("MISSING_CANDIDATE","NO_REFERENCE") for r in results)
        }
    }
    text=json.dumps(report,ensure_ascii=False,indent=2)
    if args.out:
        p=Path(args.out);p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text,encoding="utf-8")
    print(text)
    return 0

if __name__=="__main__":
    raise SystemExit(main())
