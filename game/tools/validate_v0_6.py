"""Validação estática v0.6 executável sem Godot.
Não substitui os testes nativos do Godot; cobre integridade de assets e geografia nova.
"""
from pathlib import Path
from PIL import Image
import math, re, sys

ROOT=Path(__file__).resolve().parents[1]
A=ROOT/'assets'

SIZE=(3072.0,2304.0)
TOWN=(650.0,680.0,1774.0,887.0)
BRIDGE_YS=[760.0,1250.0,1840.0]
STRUCTURES=[
    ((360,1110),'watchtower'),((790,365),'ruin_arch'),((1320,345),'watchtower'),
    ((1110,1880),'windmill'),((1660,2010),'shrine'),((2690,1820),'desert_outpost'),
    ((2420,2070),'ruin_arch'),((2700,600),'ice_lodge')]

def river_x(y): return 2220.0+math.sin(y*.006)*78+math.sin(y*.017)*23+math.sin(y*.0024+1.3)*34
def river_half_width(y): return 48+math.sin(y*.0041+.6)*8+math.sin(y*.013)*5
def town(p): x,y=p; tx,ty,w,h=TOWN; return tx<=x<tx+w and ty<=y<ty+h
def bridge(p):
    x,y=p
    return any(abs(y-by)<50 and abs(x-river_x(by))<river_half_width(by)+68 for by in BRIDGE_YS)
def river(p):
    x,y=p
    return y>242 and abs(x-river_x(y))<river_half_width(y)
def shallow(p):
    x,y=p
    if y<=242 or bridge(p): return False
    d=abs(x-river_x(y)); return river_half_width(y)<=d<river_half_width(y)+12
def biome(p):
    x,y=p
    if town(p): return 'cidade'
    if x>2010 and y<860: return 'gelo'
    if x>1980 and y>1370: return 'deserto'
    if y>1570: return 'campos' if x<760 else 'vale'
    if x<1040 or y<680: return 'floresta'
    return 'pradaria'

def check(cond,msg):
    if not cond: raise AssertionError(msg)

required=['riverbank','shallow_water','valley_grass','desert_dune','reed','dead_bush','ice_crystal','valley_rock',
          'watchtower','windmill','desert_outpost','ice_lodge','shrine','ruin_arch']
for n in required:
    check((A/f'{n}.png').is_file(),f'asset ausente: {n}')

sizes={'wolf':36,'slime':36,'spider':36,'boar':36,'flower_beast':36,'scorpion':36,'amber_beetle':36,'ice_wolf':36,'ice_golem':40,'boss':64}
for n,s in sizes.items():
    p=A/f'{n}_full.png'; check(p.is_file(),f'folha ausente: {p.name}')
    im=Image.open(p); check(im.size==(s*8,s*5),f'{p.name}: {im.size} != {(s*8,s*5)}')

for (x,y),kind in STRUCTURES:
    check(0<x<SIZE[0] and 0<y<SIZE[1],f'{kind} fora do mapa')
    check(not town((x,y)),f'{kind} dentro da cidade')
    check(not river((x,y)) and not shallow((x,y)),f'{kind} dentro do rio')

for by in BRIDGE_YS:
    cx=river_x(by)
    check(bridge((cx,by)),f'ponte não detectada em {by}')
    check(river((cx,by)),f'eixo do rio ausente em {by}')

check(biome((2700,1900))=='deserto','deserto')
check(biome((2700,250))=='gelo','gelo')
check(biome((300,900))=='floresta','floresta')
check(biome((500,2000))=='campos','campos')
check(biome((1400,2000))=='vale','vale')

main=(ROOT/'scripts/main.gd').read_text()
loot=(ROOT/'scripts/loot_system.gd').read_text()
for kind,sheet in [('Aranha Sombria','spider'),('Javali Musgoso','boar'),('Flor Voraz','flower_beast'),('Escaravelho Âmbar','amber_beetle'),('Golem de Geada','ice_golem')]:
    check(kind in main,f'{kind} ausente em main.gd')
    check(kind in loot,f'{kind} sem perfil de loot')
    check(f'{sheet}_full' in main,f'{sheet}_full não carregado')

# Higiene mínima do pacote.
for bad in ROOT.rglob('*'):
    if bad.is_file() and (bad.suffix in {'.pyc','.tmp','.log'} or '__pycache__' in bad.parts):
        raise AssertionError(f'arquivo temporário: {bad.relative_to(ROOT)}')

print('STATIC PASS v0.6: 3 pontes, 6 terrenos/props novos, 8 marcos, 5 novos monstros e 10 folhas de 40 frames')
