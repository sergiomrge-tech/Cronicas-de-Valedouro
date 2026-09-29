#!/usr/bin/env python3
"""Valedouro pixel-art asset QA.

Checks objective technical signals that often reveal unfinished pre-render output:
- alpha/background integrity;
- anti-aliased alpha fringes;
- canvas-edge collisions;
- uncontrolled palette growth;
- empty/near-empty sprites;
- manifest frame/foot consistency.

This script does NOT approve art. It only catches technical problems before the
Director visual gate.

Usage:
    python3 asset_qc.py game/assets/modeled/nature
    python3 asset_qc.py path/to/a.png --manifest game/data/modeled_assets_manifest.json
    python3 asset_qc.py game/assets/modeled --json-out artifacts/art_qc.json
"""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Iterable, Optional

from PIL import Image


@dataclass
class CheckResult:
    path: str
    width: int
    height: int
    bbox: Optional[tuple[int, int, int, int]]
    opaque_pixels: int
    soft_alpha_pixels: int
    soft_alpha_ratio: float
    unique_opaque_rgb: int
    edge_touch_pixels: int
    occupancy_ratio: float
    manifest_id: Optional[str]
    status: str
    warnings: list[str]
    failures: list[str]


def iter_pngs(paths: Iterable[str]) -> list[Path]:
    out: list[Path] = []
    for raw in paths:
        p = Path(raw)
        if p.is_dir():
            out.extend(sorted(x for x in p.rglob("*.png") if x.is_file()))
        elif p.is_file() and p.suffix.lower() == ".png":
            out.append(p)
    # deterministic + deduplicated
    return list(dict.fromkeys(x.resolve() for x in out))


def load_manifest(path: Optional[str]) -> tuple[dict[str, dict], dict[str, str]]:
    if not path:
        return {}, {}
    p = Path(path)
    if not p.exists():
        raise FileNotFoundError(path)
    raw = json.loads(p.read_text(encoding="utf-8"))
    entries = raw.get("assets", raw.get("entries", []))
    if isinstance(entries, dict):
        entries = list(entries.values())

    by_id: dict[str, dict] = {}
    by_name: dict[str, str] = {}
    for e in entries:
        if not isinstance(e, dict) or not e.get("id"):
            continue
        aid = str(e["id"])
        by_id[aid] = e
        asset_path = str(e.get("path", ""))
        if asset_path:
            by_name[Path(asset_path).name] = aid
    return by_id, by_name


def edge_touch_count(alpha: Image.Image) -> int:
    w, h = alpha.size
    if w == 0 or h == 0:
        return 0
    px = alpha.load()
    count = 0
    for x in range(w):
        count += int(px[x, 0] > 0)
        if h > 1:
            count += int(px[x, h - 1] > 0)
    for y in range(1, max(1, h - 1)):
        count += int(px[0, y] > 0)
        if w > 1:
            count += int(px[w - 1, y] > 0)
    return count


def inspect_png(path: Path, manifest: dict[str, dict], by_name: dict[str, str], shadow_alpha: int = 104) -> CheckResult:
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    alpha = im.getchannel("A")
    bbox = alpha.getbbox()
    hist = alpha.histogram()

    opaque = hist[255]
    # o VK grava a sombra de contato com UM valor de alpha (pontilhada); não é halo de antialiasing
    soft = sum(hist[1:255]) - (hist[shadow_alpha] if 0 < shadow_alpha < 255 else 0)
    visible = opaque + soft
    soft_ratio = (soft / visible) if visible else 0.0
    edge = edge_touch_count(alpha)

    if visible:
        colors = {
            (r, g, b)
            for r, g, b, a in im.getdata()
            if a == 255
        }
    else:
        colors = set()

    occupancy = visible / float(max(1, w * h))
    aid = by_name.get(path.name)
    entry = manifest.get(aid, {}) if aid else {}

    warnings: list[str] = []
    failures: list[str] = []

    if visible == 0:
        failures.append("sprite is fully transparent")

    if edge > 0:
        warnings.append(f"{edge} visible pixels touch the canvas boundary; check crop/bleed")

    # Pixel-art sprites should normally have hard alpha. A tiny allowance is kept
    # for intentionally soft emission/shadow passes.
    if soft_ratio > 0.02:
        warnings.append(f"soft-alpha fringe is high ({soft_ratio:.2%}); inspect anti-aliasing/halo")

    if len(colors) > 128:
        warnings.append(f"opaque palette has {len(colors)} RGB colors; inspect uncontrolled gradients/noise")

    if occupancy < 0.01 and visible > 0:
        warnings.append(f"very low canvas occupancy ({occupancy:.2%}); crop/scale may be wrong")

    if bbox is not None:
        left, top, right, bottom = bbox
        margins = (left, top, w - right, h - bottom)
        if min(margins) < 2:
            warnings.append(f"tight margin {margins}; risk of animation/render clipping")

    if entry:
        frame_size = entry.get("frame_size")
        frames = int(entry.get("frames", 1) or 1)
        rows = int(entry.get("rows", 1) or 1)
        foot = entry.get("foot")

        if isinstance(frame_size, list) and len(frame_size) == 2:
            fw, fh = int(frame_size[0]), int(frame_size[1])
            expected = (fw * frames, fh * rows)
            if expected != (w, h):
                failures.append(f"manifest expects sheet {expected}, file is {(w, h)}")
            if isinstance(foot, list) and len(foot) == 2:
                fx, fy = float(foot[0]), float(foot[1])
                if not (0 <= fx <= fw and 0 <= fy <= fh):
                    failures.append(f"foot anchor {foot} lies outside frame {frame_size}")

    status = "FAIL" if failures else ("WARN" if warnings else "PASS")
    return CheckResult(
        path=str(path),
        width=w,
        height=h,
        bbox=tuple(bbox) if bbox else None,
        opaque_pixels=opaque,
        soft_alpha_pixels=soft,
        soft_alpha_ratio=round(soft_ratio, 6),
        unique_opaque_rgb=len(colors),
        edge_touch_pixels=edge,
        occupancy_ratio=round(occupancy, 6),
        manifest_id=aid,
        status=status,
        warnings=warnings,
        failures=failures,
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="+", help="PNG files and/or directories")
    ap.add_argument("--manifest", help="modeled_assets_manifest.json")
    ap.add_argument("--json-out", help="optional JSON report output")
    ap.add_argument("--shadow-alpha", type=int, default=104, help="alpha único da sombra de contato baked (ignorado no cálculo de halo; 0 = desliga)")
    args = ap.parse_args()

    files = iter_pngs(args.paths)
    if not files:
        print("No PNG files found.")
        return 2

    manifest, by_name = load_manifest(args.manifest)
    results = [inspect_png(p, manifest, by_name, args.shadow_alpha) for p in files]

    for r in results:
        suffix = ""
        if r.failures:
            suffix = " | " + "; ".join(r.failures)
        elif r.warnings:
            suffix = " | " + "; ".join(r.warnings)
        print(f"{r.status:4} {r.path}{suffix}")

    summary = {
        "total": len(results),
        "pass": sum(r.status == "PASS" for r in results),
        "warn": sum(r.status == "WARN" for r in results),
        "fail": sum(r.status == "FAIL" for r in results),
    }
    print("SUMMARY", json.dumps(summary, ensure_ascii=False))

    if args.json_out:
        out = Path(args.json_out)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(
            json.dumps(
                {"summary": summary, "results": [asdict(r) for r in results]},
                ensure_ascii=False,
                indent=2,
            ),
            encoding="utf-8",
        )

    return 1 if summary["fail"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
