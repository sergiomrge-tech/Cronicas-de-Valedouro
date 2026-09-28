#!/usr/bin/env python3
"""Build the stable v0.6 asset catalog without changing gameplay assets."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
MAIN = ROOT / "scripts" / "main.gd"
OUT = ROOT / "data" / "asset_catalog.json"

CATALOG_EXTENSIONS = {".png", ".ttf"}


def stable_id(relative: Path) -> str:
    token = relative.with_suffix("").as_posix().upper()
    token = re.sub(r"[^A-Z0-9]+", "_", token).strip("_")
    return f"AST_V06_{token}"


def classify(relative: Path) -> str:
    path = relative.as_posix()
    stem = relative.stem
    if path.startswith("world_sources/"):
        return "source_art"
    if relative.suffix.lower() == ".ttf":
        return "font"
    if stem.startswith(("ui_", "btn_", "icon_")):
        return "ui"
    if stem.startswith("equip_"):
        return "equipment_icon"
    if stem.startswith("hero_") or stem == "hero":
        return "hero"
    if stem.endswith(("_full", "_anim")) or stem in {
        "wolf", "slime", "boss", "scorpion", "ice_wolf"
    }:
        return "enemy"
    if stem in {"deer", "fox", "hare", "goat", "camel", "bird", "fish"}:
        return "fauna"
    if stem in {"watchtower", "windmill", "desert_outpost", "ice_lodge", "shrine", "ruin_arch", "bridge", "wall", "roof"}:
        return "structure"
    if stem in {"valedouro_art", "valedouro_blended", "forest_art", "forge_art", "outskirts_ground", "path_ground"}:
        return "environment_art"
    return "terrain_prop"


def runtime_loaded_names() -> set[str]:
    text = MAIN.read_text(encoding="utf-8")
    match = re.search(r'for name in \[(.*?)\]:\n\s*textures\[name\]', text, re.S)
    if not match:
        raise SystemExit("Could not find the main texture preload list")
    names = set(re.findall(r'"([^"]+)"', match.group(1)))
    for family in ("sword", "bow", "staff"):
        for tier in range(4):
            names.add(f"equip_{family}_{tier}")
            names.add(f"hero_{family}_{tier}")
    for tier in range(1, 5):
        names.add(f"equip_armor_{tier}")
        names.add(f"hero_armor_{tier}")
    return names


def main() -> None:
    runtime_names = runtime_loaded_names()
    files = sorted(
        p for p in ASSETS.rglob("*")
        if p.is_file() and p.suffix.lower() in CATALOG_EXTENSIONS
    )
    rows = []
    for path in files:
        relative = path.relative_to(ASSETS)
        runtime_loaded = (
            relative.suffix.lower() == ".ttf" and relative.as_posix() == "fonts/PixelifySans.ttf"
        ) or (relative.suffix.lower() == ".png" and relative.parent == Path(".") and relative.stem in runtime_names)
        rows.append({
            "id": stable_id(relative),
            "path": f"res://assets/{relative.as_posix()}",
            "category": classify(relative),
            "runtime_status": "LEGACY_RUNTIME" if runtime_loaded else "SOURCE_ONLY" if relative.parts[0] == "world_sources" else "UNREFERENCED_LEGACY",
            "visual_status": "LEGACY_V0_6_UNREVIEWED",
            "source_version": "v0.6.0"
        })

    payload = {
        "schema_version": 1,
        "catalog_id": "CAT_ASSETS_V06_001",
        "source_build": "v0.6.0",
        "policy": {
            "ids_are_persistent": True,
            "visual_status_is_not_claude_gate": True,
            "claude_lote01_integrated": False
        },
        "counts": {
            "total": len(rows),
            "legacy_runtime": sum(r["runtime_status"] == "LEGACY_RUNTIME" for r in rows),
            "source_only": sum(r["runtime_status"] == "SOURCE_ONLY" for r in rows),
            "unreferenced_legacy": sum(r["runtime_status"] == "UNREFERENCED_LEGACY" for r in rows)
        },
        "assets": rows
    }
    OUT.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"CATALOG PASS: {len(rows)} assets -> {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
