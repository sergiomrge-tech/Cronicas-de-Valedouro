#!/usr/bin/env python3
"""Quantify visible grid/chunk artifacts in baked Valedouro terrain.

The REG_001 screenshots exposed rectangular biome/terrain blocks. This tool
measures whether image gradients are disproportionately concentrated on regular
32/64px cell lines or 512px chunk seams.

It is a QA signal, not an aesthetic approval.
"""

from __future__ import annotations
import argparse
import json
from pathlib import Path
import numpy as np
from PIL import Image


def rgb(path):
    return np.asarray(Image.open(path).convert("RGB"),dtype=np.float32)/255.0


def luminance(a):
    return a[...,0]*.2126+a[...,1]*.7152+a[...,2]*.0722


def gradients(a):
    l=luminance(a)
    gx=np.abs(l[:,1:]-l[:,:-1])
    gy=np.abs(l[1:,:]-l[:-1,:])
    return gx,gy


def line_energy(gx,gy,period,offset=0):
    xs=[x for x in range(period+offset,gx.shape[1],period)]
    ys=[y for y in range(period+offset,gy.shape[0],period)]
    vx=np.concatenate([gx[:,x:x+1].ravel() for x in xs]) if xs else np.array([],dtype=np.float32)
    vy=np.concatenate([gy[y:y+1,:].ravel() for y in ys]) if ys else np.array([],dtype=np.float32)
    vals=np.concatenate([vx,vy]) if vx.size or vy.size else np.array([0],dtype=np.float32)
    return float(vals.mean()),float(np.percentile(vals,95))


def baseline_energy(gx,gy,period):
    # Sample halfway between grid lines as a comparable baseline.
    return line_energy(gx,gy,period,period//2)


def metric(a,period):
    gx,gy=gradients(a)
    mean,p95=line_energy(gx,gy,period)
    bmean,b95=baseline_energy(gx,gy,period)
    return {
        "period":period,
        "grid_mean":round(mean,6),
        "baseline_mean":round(bmean,6),
        "mean_ratio":round(mean/max(bmean,1e-6),4),
        "grid_p95":round(p95,6),
        "baseline_p95":round(b95,6),
        "p95_ratio":round(p95/max(b95,1e-6),4),
    }


def seam_pairs(a,period=512):
    # Directly compare first/last columns around each chunk seam.
    l=luminance(a)
    vals=[]
    for x in range(period,l.shape[1],period):
        vals.append(np.abs(l[:,x]-l[:,x-1]))
    for y in range(period,l.shape[0],period):
        vals.append(np.abs(l[y,:]-l[y-1,:]))
    if not vals:
        return {"mean":0.0,"p95":0.0}
    v=np.concatenate([x.ravel() for x in vals])
    return {"mean":round(float(v.mean()),6),"p95":round(float(np.percentile(v,95)),6)}


def micro_noise(a):
    gx,gy=gradients(a)
    allg=np.concatenate([gx.ravel(),gy.ravel()])
    return {
        "gradient_mean":round(float(allg.mean()),6),
        "gradient_p95":round(float(np.percentile(allg,95)),6),
        "high_gradient_fraction":round(float((allg>.12).mean()),6),
    }


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("image")
    ap.add_argument("--out")
    ap.add_argument("--fail-grid-ratio",type=float,default=1.38)
    ap.add_argument("--fail-chunk-mean",type=float,default=.055)
    args=ap.parse_args()

    a=rgb(args.image)
    report={
        "image":str(args.image),
        "size":[int(a.shape[1]),int(a.shape[0])],
        "grid":[metric(a,p) for p in (32,64,128,512)],
        "chunk_seams":seam_pairs(a,512),
        "micro_noise":micro_noise(a),
        "failures":[],
        "warnings":[]
    }

    for m in report["grid"]:
        if m["period"] in (32,64) and m["mean_ratio"]>args.fail_grid_ratio:
            report["failures"].append(f"visible regular grid energy at {m['period']}px: ratio {m['mean_ratio']}")
        elif m["mean_ratio"]>1.22:
            report["warnings"].append(f"elevated grid energy at {m['period']}px: ratio {m['mean_ratio']}")

    if report["chunk_seams"]["mean"]>args.fail_chunk_mean:
        report["failures"].append(f"512px chunk seam mean {report['chunk_seams']['mean']} exceeds {args.fail_chunk_mean}")

    if report["micro_noise"]["high_gradient_fraction"]>.18:
        report["warnings"].append("surface may be excessively noisy at single-pixel scale")

    report["status"]="FAIL" if report["failures"] else ("WARN" if report["warnings"] else "PASS")

    if args.out:
        p=Path(args.out); p.parent.mkdir(parents=True,exist_ok=True)
        p.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
    print(json.dumps(report,ensure_ascii=False,indent=2))
    return 1 if report["failures"] else 0


if __name__=="__main__":
    raise SystemExit(main())
