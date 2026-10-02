"""Verify committed runtime atlases and detect stale city-floor source inputs."""
from pathlib import Path
from hashlib import sha256
import json
import re
from PIL import Image

GAME = Path(__file__).resolve().parents[2]
ART = GAME / "assets/cartoon/v040"


def check() -> None:
    manifest = json.loads((ART / "buildings.json").read_text())
    atlas = ART / manifest["atlas"]
    assert sha256(atlas.read_bytes()).hexdigest() == manifest["sha256"]
    with Image.open(atlas) as image:
        assert list(image.size) == manifest["atlas_size"]
        assert image.mode == "RGBA"
    assert len(manifest["assets"]) == 12
    source = (GAME / "scripts/cartoon/hub_environment.gd").read_text()
    active = re.search(r'const CITY_GROUND = preload\("res://([^"]+)"\)', source).group(1)
    floor = GAME / active
    provenance = json.loads((floor.parent / "ground_provenance.json").read_text())
    assert sha256(floor.read_bytes()).hexdigest() == provenance["sha256"]
    with Image.open(floor) as image:
        assert list(image.size) == provenance["texture_size"]
        assert image.mode == "RGBA"
    for filename, digest in provenance["source_sha256"].items():
        actual = sha256((GAME / filename).read_bytes()).hexdigest()
        assert actual == digest, f"Stale city floor: {filename} changed; rebake and update provenance."
    print("city_art_v040: PASS — original building atlas, floor cache, and generator source checksums")


if __name__ == "__main__":
    check()
