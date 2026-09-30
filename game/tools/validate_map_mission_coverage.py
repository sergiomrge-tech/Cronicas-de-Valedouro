#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
STORY = ROOT / "game" / "data" / "main_story_v1.json"
LOCS = ROOT / "game" / "data" / "story_locations_v1.json"
COVERAGE = ROOT / "game" / "data" / "cartoon_map_mission_coverage_v1.json"
BLUEPRINT = ROOT / "game" / "data" / "cartoon_campaign_map_blueprint_v1.json"

def main() -> int:
    story = json.loads(STORY.read_text(encoding="utf-8"))
    locations = json.loads(LOCS.read_text(encoding="utf-8"))
    coverage = json.loads(COVERAGE.read_text(encoding="utf-8"))
    blueprint = json.loads(BLUEPRINT.read_text(encoding="utf-8"))

    errors: list[str] = []
    source_quests = {q["id"]: q for q in story.get("quests", [])}
    source_locs = {l["id"]: l for l in locations.get("locations", [])}
    cov_quests = {
        q["id"]: q
        for q in coverage.get("canonical_main_story", {}).get("quests", [])
    }

    if len(cov_quests) != len(source_quests):
        errors.append(
            f"coverage quests={len(cov_quests)} != story quests={len(source_quests)}"
        )

    for qid, q in source_quests.items():
        cq = cov_quests.get(qid)
        if cq is None:
            errors.append(f"quest ausente da cobertura do mapa: {qid}")
            continue
        if cq.get("act") != q.get("act"):
            errors.append(f"ato divergente em {qid}")
        if cq.get("location_id") != q.get("loc"):
            errors.append(
                f"local divergente em {qid}: {cq.get('location_id')} != {q.get('loc')}"
            )
        if q.get("loc") not in source_locs:
            errors.append(f"quest {qid} aponta para local inexistente {q.get('loc')}")

    referenced_locs = {q.get("loc") for q in source_quests.values()}
    missing_locs = sorted(referenced_locs - set(source_locs))
    if missing_locs:
        errors.append("locais ausentes: " + ", ".join(missing_locs))

    blueprint_quests = {}
    for region in blueprint.get("regions", []):
        for row in region.get("mandatory_route", []):
            qid = row.get("quest_id")
            if qid:
                blueprint_quests[qid] = row
    if set(blueprint_quests) != set(source_quests):
        missing = sorted(set(source_quests) - set(blueprint_quests))
        extra = sorted(set(blueprint_quests) - set(source_quests))
        if missing:
            errors.append("blueprint sem quests: " + ", ".join(missing))
        if extra:
            errors.append("blueprint com quests desconhecidas: " + ", ".join(extra))
    for qid, q in source_quests.items():
        row = blueprint_quests.get(qid)
        if row is not None and row.get("location_id") != q.get("loc"):
            errors.append(f"blueprint diverge no local de {qid}")

    legacy = coverage.get("legacy_vertical_slice_crosswalk", [])
    expected_legacy = {f"QUEST_A01_REG001_{i:03d}" for i in range(1,9)}
    actual_legacy = {row.get("legacy_id") for row in legacy}
    if actual_legacy != expected_legacy:
        errors.append("crosswalk do vertical slice deve cobrir QUEST_A01_REG001_001..008")

    for row in legacy:
        for qid in row.get("canonical_refs", []):
            if qid not in source_quests:
                errors.append(f"legacy {row.get('legacy_id')} referencia quest canônica ausente {qid}")
        for loc_id in row.get("map_refs", []):
            if loc_id not in source_locs:
                errors.append(f"legacy {row.get('legacy_id')} referencia local ausente {loc_id}")

    print("MAP MISSION COVERAGE GATE")
    print(f"canonical_quests: {len(source_quests)}")
    print(f"canonical_locations: {len(source_locs)}")
    print(f"legacy_crosswalk: {len(legacy)}")
    print(f"blueprint_regions: {len(blueprint.get('regions', []))}")
    print(f"blueprint_quests: {len(blueprint_quests)}")
    if errors:
        for err in errors:
            print("ERROR:", err)
        print(f"FAIL: {len(errors)} erro(s)")
        return 1
    print("PASS: todas as missões canônicas possuem referência de mapa.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
