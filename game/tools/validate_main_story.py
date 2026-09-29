#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
STORY_PATH = ROOT / "game" / "data" / "main_story_v1.json"
LOCATIONS_PATH = ROOT / "game" / "data" / "story_locations_v1.json"


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def main() -> int:
    story = json.loads(STORY_PATH.read_text(encoding="utf-8"))
    locations = json.loads(LOCATIONS_PATH.read_text(encoding="utf-8"))

    errors: list[str] = []
    warnings: list[str] = []

    quests = story.get("quests", [])
    locs = locations.get("locations", [])
    qmap = {q.get("id"): q for q in quests}
    lmap = {loc.get("id"): loc for loc in locs}

    if len(qmap) != len(quests):
        fail("Há IDs de quest duplicados.", errors)
    if len(lmap) != len(locs):
        fail("Há IDs de local duplicados.", errors)

    for q in quests:
        qid = q.get("id", "<sem-id>")
        loc_id = q.get("loc")
        next_id = q.get("next", "")
        if loc_id not in lmap:
            fail(f"Quest {qid} aponta para local ausente: {loc_id}", errors)
        if next_id and next_id not in qmap:
            fail(f"Quest {qid} aponta para next ausente: {next_id}", errors)

    for loc in locs:
        loc_id = loc.get("id", "<sem-id>")
        for qid in loc.get("missions", []):
            if qid not in qmap:
                fail(f"Local {loc_id} referencia missão ausente: {qid}", errors)
                continue
            if qmap[qid].get("loc") != loc_id:
                fail(
                    f"Backlink divergente: {loc_id} lista {qid}, "
                    f"mas a quest usa {qmap[qid].get('loc')}",
                    errors,
                )

    for q in quests:
        qid = q.get("id", "<sem-id>")
        loc_id = q.get("loc")
        loc = lmap.get(loc_id)
        if loc is not None and qid not in loc.get("missions", []):
            warnings.append(
                f"Quest {qid} usa {loc_id}, mas o local não lista a quest em missions."
            )

    start = story.get("start_quest")
    final = story.get("final_quest")
    current = start
    chain: list[str] = []
    seen: set[str] = set()

    while current:
        if current in seen:
            fail(f"Loop detectado na cadeia principal em {current}", errors)
            break
        seen.add(current)
        chain.append(current)
        quest = qmap.get(current)
        if quest is None:
            fail(f"Cadeia interrompida em quest ausente: {current}", errors)
            break
        current = quest.get("next", "")

    if chain and chain[-1] != final:
        fail(f"Cadeia termina em {chain[-1]}, esperado final {final}", errors)

    unreachable = [qid for qid in qmap if qid not in seen]
    if unreachable:
        warnings.append("Quests fora da cadeia principal: " + ", ".join(unreachable))

    act_counts: dict[int, int] = {}
    for q in quests:
        act = int(q.get("act", 0))
        act_counts[act] = act_counts.get(act, 0) + 1

    print("MAIN STORY DATA AUDIT")
    print(f"story_id: {story.get('story_id')}")
    print(f"acts: {len(story.get('acts', []))}")
    print(f"quests: {len(quests)}")
    print(f"locations: {len(locs)}")
    print(
        f"chain: {len(chain)} "
        f"({chain[0] if chain else '-'} -> {chain[-1] if chain else '-'})"
    )
    print(
        "quests_per_act: "
        + ", ".join(f"{k}:{v}" for k, v in sorted(act_counts.items()))
    )

    for warning in warnings:
        print(f"WARN: {warning}")
    for error in errors:
        print(f"ERROR: {error}")

    if errors:
        print(f"FAIL: {len(errors)} erro(s), {len(warnings)} aviso(s)")
        return 1

    print(f"PASS: 0 erros, {len(warnings)} aviso(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
