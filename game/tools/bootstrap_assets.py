"""Recria todos os assets derivados usados pelo protótipo e baixa a fonte OFL.
Pode ser executado por humanos, Claude ou GitHub Actions.
"""
from pathlib import Path
import subprocess, sys, urllib.request

ROOT=Path(__file__).resolve().parents[1]
ASSETS=ROOT/'assets'; FONT_DIR=ASSETS/'fonts'; FONT_DIR.mkdir(parents=True,exist_ok=True)
font=FONT_DIR/'PixelifySans.ttf'
if not font.exists():
    url='https://raw.githubusercontent.com/google/fonts/main/ofl/pixelifysans/PixelifySans%5Bwght%5D.ttf'
    print('Downloading Pixelify Sans (OFL)...')
    urllib.request.urlretrieve(url,font)

steps=[
 'generate_world_art.py',
 'generate_creatures.py',
 'generate_enrichment.py',
 'generate_hero_animation.py',
 'build_scene_art.py',
 'build_asset_catalog.py',
]
for step in steps:
    print('>',step)
    subprocess.run([sys.executable,str(ROOT/'tools'/step)],cwd=ROOT,check=True)
print('Asset bootstrap complete')
