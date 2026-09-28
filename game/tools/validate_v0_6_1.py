#!/usr/bin/env python3
"""Strict static gate for the v0.6.1 stabilization candidate.

This complements, but does not replace, the native Godot 4.7.2 gate.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def check(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


# Preserve all original v0.6 invariants.
base = subprocess.run([sys.executable, str(ROOT / "tools" / "validate_v0_6.py")], cwd=ROOT, text=True, capture_output=True)
if base.stdout:
    print(base.stdout.strip())
if base.returncode != 0:
    if base.stderr:
        print(base.stderr, file=sys.stderr)
    raise SystemExit(base.returncode)

# Project entrypoint and scene existence.
project_text = (ROOT / "project.godot").read_text(encoding="utf-8")
main_match = re.search(r'run/main_scene="([^"]+)"', project_text)
check(main_match is not None, "project.godot sem run/main_scene")
main_scene = main_match.group(1).replace("res://", "", 1)
check((ROOT / main_scene).is_file(), f"main scene ausente: {main_scene}")

# GDScript stabilization rule: no inferred static assignment left in runtime/tests.
gd_files = sorted(list((ROOT / "scripts").rglob("*.gd")) + list((ROOT / "tests").rglob("*.gd")))
for path in gd_files:
    text = path.read_text(encoding="utf-8")
    check(":=" not in text, f"inferência := restante: {path.relative_to(ROOT)}")

# Literal res:// references must resolve. Dynamic format strings are skipped deliberately.
for path in sorted(ROOT.rglob("*")):
    if not path.is_file() or path.suffix.lower() not in {".gd", ".tscn", ".godot"}:
        continue
    text = path.read_text(encoding="utf-8", errors="replace")
    for ref in re.findall(r'res://[^"\']+', text):
        if "%" in ref or "{" in ref or "}" in ref:
            continue
        target = ROOT / ref.removeprefix("res://")
        check(target.exists(), f"referência quebrada em {path.relative_to(ROOT)}: {ref}")

# Stable asset catalog.
catalog_path = ROOT / "data" / "asset_catalog.json"
check(catalog_path.is_file(), "data/asset_catalog.json ausente")
catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
check(catalog.get("schema_version") == 1, "schema do catálogo inválido")
check(catalog.get("policy", {}).get("claude_lote01_integrated") is False, "lote Claude não pode estar integrado neste candidato")
rows = catalog.get("assets")
check(isinstance(rows, list), "assets deve ser lista")
ids: set[str] = set()
paths: set[str] = set()
for row in rows:
    check(isinstance(row, dict), "entrada de asset não é objeto")
    asset_id = row.get("id")
    asset_path = row.get("path")
    check(isinstance(asset_id, str) and asset_id.startswith("AST_V06_"), f"ID inválido: {asset_id}")
    check(asset_id not in ids, f"ID duplicado: {asset_id}")
    ids.add(asset_id)
    check(isinstance(asset_path, str) and asset_path.startswith("res://assets/"), f"path inválido: {asset_path}")
    check(asset_path not in paths, f"path duplicado: {asset_path}")
    paths.add(asset_path)
    check((ROOT / asset_path.removeprefix("res://")).is_file(), f"asset ausente: {asset_path}")

catalogable = {
    f"res://{p.relative_to(ROOT).as_posix()}"
    for p in (ROOT / "assets").rglob("*")
    if p.is_file() and p.suffix.lower() in {".png", ".ttf"}
}
check(paths == catalogable, f"catálogo incompleto: catalogados={len(paths)} arquivos={len(catalogable)}")
check(catalog.get("counts", {}).get("total") == len(rows), "counts.total divergente")

# Loader/test contract exists.
loader = ROOT / "scripts" / "asset_catalog.gd"
loader_test = ROOT / "tests" / "asset_catalog.gd"
check(loader.is_file(), "loader do catálogo ausente")
check(loader_test.is_file(), "teste nativo do catálogo ausente")
loader_text = loader.read_text(encoding="utf-8")
for token in ["CATALOG_PATH", "load_catalog", "index_by_id", "find"]:
    check(token in loader_text, f"loader incompleto: {token}")

# Hygiene: no editor/temp/patch artifacts in the release tree.
for path in ROOT.rglob("*"):
    if not path.is_file():
        continue
    bad_suffix = path.suffix.lower() in {".pyc", ".tmp", ".log", ".bak", ".orig", ".rej"}
    bad_name = path.name.endswith("~") or path.name == ".DS_Store"
    check(not bad_suffix and not bad_name and "__pycache__" not in path.parts, f"temporário no projeto: {path.relative_to(ROOT)}")

print(f"STRICT STATIC PASS v0.6.1-candidate: {len(gd_files)} GDScripts, {len(rows)} asset IDs, refs e higiene OK")
