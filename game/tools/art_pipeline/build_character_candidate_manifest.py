#!/usr/bin/env python3
"""Create MODELED_PENDING_GATE manifest entries for packed Valedouro character sheets.

This does not approve artwork. It converts a successful pack report into a
separate candidate manifest ready for Director visual review and later merge.
"""

from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path

def sha256(path: Path) -> str:
    h=hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda:f.read(1024*1024),b""):
            h.update(chunk)
    return h.hexdigest()

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("pack_report")
    ap.add_argument("game_root")
    ap.add_argument("out")
    args=ap.parse_args()

    report=json.loads(Path(args.pack_report).read_text(encoding="utf-8"))
    game=Path(args.game_root).resolve()
    assets=[]
    for s in report.get("sheets",[]):
        p=Path(s["path"]).resolve()
        try:
            rel=p.relative_to(game).as_posix()
            res_path="res://"+rel
        except ValueError:
            res_path=str(p)

        fw,fh=s["frame_size"]
        asset_id=f"char_{s['asset_id']}_{s['animation']}"
        assets.append({
            "id":asset_id,
            "path":res_path,
            "group":"character",
            "folder":s["asset_id"],
            "frame_size":[fw,fh],
            "frames":int(s["frames"]),
            "rows":int(s["rows"]),
            "foot":[fw//2,fh-4],
            "draw_scale":1.0,
            "blocks_radius":0.0,
            "footprint":0.0,
            "tags":["character",s["asset_id"],s["animation"],"directional"],
            "sha256":sha256(p),
            "source":"game/tools/art_pipeline/pack_character_sheets.py",
            "status":"MODELED_PENDING_GATE"
        })

    doc={
        "schema_version":1,
        "policy":{
            "director_approval_required":True,
            "default_status":"MODELED_PENDING_GATE"
        },
        "assets":assets
    }
    out=Path(args.out); out.parent.mkdir(parents=True,exist_ok=True)
    out.write_text(json.dumps(doc,ensure_ascii=False,indent=2),encoding="utf-8")
    print("OK",len(assets),"candidate manifest entries")
    return 0

if __name__=="__main__":
    raise SystemExit(main())
