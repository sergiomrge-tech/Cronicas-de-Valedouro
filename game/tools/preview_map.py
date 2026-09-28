"""Cartographic overview from the same world coordinates (not a game screenshot)."""
from PIL import Image, ImageDraw, ImageFont
from math import sin
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
FONT='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BOLD='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
small=ImageFont.truetype(FONT,14)
medium=ImageFont.truetype(BOLD,22)
large=ImageFont.truetype(BOLD,27)
W,H=1200,990
O=(24,72)
S=.375
im=Image.new('RGB',(W,H),'#172626');d=ImageDraw.Draw(im)
d.text((30,21),'VALEDOURO  •  MAPA DAS TERRAS DE FRONTEIRA',font=large,fill='#f4deae')
colors={'cidade':'#779460','floresta':'#25513d','campos':'#83ad53','gelo':'#d8e6df','deserto':'#d8b46d','pradaria':'#5f965a'}
def river_x(y):return 2220+sin(y*.006)*78+sin(y*.017)*23
def biome(x,y):
    if 1056<=x<2016 and 704<=y<1600:return 'cidade'
    if x>2010 and y<860:return 'gelo'
    if x>1980 and y>1370:return 'deserto'
    if y>1590:return 'campos'
    if x<1040 or y<680:return 'floresta'
    return 'pradaria'
def P(x,y):return (O[0]+x*S,O[1]+y*S)
for yy in range(72):
    for xx in range(96):
        x,y=xx*32+16,yy*32+16
        color=colors[biome(x,y)]
        if (xx*73+yy*31)%9==0:
            color={'floresta':'#30694b','campos':'#9bbc5d','deserto':'#e6c783','gelo':'#ebf1ed','pradaria':'#72a269','cidade':'#89a86c'}[biome(x,y)]
        px,py=P(xx*32,yy*32)
        d.rectangle((px,py,px+12,py+12),fill=color)
# Broad roads communicate connections without hiding terrain.
road='#d6ba7f'
for a,b,width in [((1536,1520),(1536,2210),15),((1536,690),(1536,58),14),((1030,1160),(50,1160),13),((1980,1250),(2960,1250),13),((2560,1210),(2560,80),11)]:
    d.line((*P(*a),*P(*b)),fill=road,width=width)
for y in range(265,2280,10):
    cx=river_x(y)
    d.line((*P(cx, y),*P(river_x(y+11),y+11)),fill='#328baa',width=38)
    d.line((*P(cx-10,y),*P(river_x(y+11)-10,y+11)),fill='#7cc9cf',width=6)
d.rectangle((*P(river_x(1250)-94,1203),*P(river_x(1250)+94,1296)),fill='#8d6948',outline='#ebd3a4',width=4)
for dy in (-26,0,26):
    d.line((*P(river_x(1250)-80,1250+dy),*P(river_x(1250)+80,1250+dy)),fill='#d4ab72',width=3)
# City outline and internal avenues.
d.rounded_rectangle((*P(1056,704),*P(2016,1600)),radius=18,fill='#8aa579',outline='#403d32',width=6)
d.line((*P(1536,740),*P(1536,1570)),fill='#d8c28c',width=30)
d.line((*P(1090,1150),*P(1980,1150)),fill='#d8c28c',width=26)
city_buildings=[(1240,940,'#755670'),(1510,940,'#824f3f'),(1830,940,'#4d6a68'),(1240,1390,'#667a88'),(1810,1390,'#565463')]
for x,y,col in city_buildings:
    d.rounded_rectangle((*P(x-105,y-70),*P(x+105,y+60)),radius=5,fill='#c3a87e',outline='#49382d',width=3)
    d.polygon([P(x-126,y-30),P(x,y-110),P(x+126,y-30)],fill=col)
# Fountain, cascade, markers and settlements.
d.ellipse((*P(1486,1082),*P(1586,1182)),fill='#4a9aac',outline='#efe1bf',width=5)
fx=river_x(471)
d.line((*P(fx-58,450),*P(fx+50,525)),fill='#f4fbf7',width=16)
for x,y,roof in [(790,1860,'#53675a'),(2670,1740,'#99633d'),(2700,638,'#668194')]:
    for delta in (-75,0,75):
        d.rectangle((*P(x+delta-33,y-16),*P(x+delta+33,y+37)),fill='#c6ac81',outline='#413e35',width=2)
        d.polygon([P(x+delta-39,y-16),P(x+delta,y-57),P(x+delta+39,y-16)],fill=roof)
# Forest groves, rocks, cacti and grass flowers.
for yy in range(3,69):
    for xx in range(2,94):
        x,y=xx*32+16,yy*32+16
        if 1050<x<2040 and 680<y<1630:continue
        h=abs((xx*733+yy*3187+xx*yy*23+41293)*4057)%89
        region=biome(x,y)
        if region=='floresta' and h<15:
            p=P(x,y)
            d.ellipse((p[0]-7,p[1]-10,p[0]+7,p[1]+5),fill='#174133',outline='#427c50',width=2)
        elif region=='gelo' and h<7:
            p=P(x,y)
            d.polygon([(p[0],p[1]-10),(p[0]-6,p[1]+7),(p[0]+6,p[1]+7)],fill='#92b9bc')
        elif region=='deserto' and h<5:
            p=P(x,y)
            d.line((p[0],p[1]-7,p[0],p[1]+7),fill='#458c5e',width=4)
        elif region=='campos' and h<11:
            p=P(x,y)
            d.ellipse((p[0]-2,p[1]-2,p[0]+2,p[1]+2),fill='#f6e2a9' if h%2 else '#d9abd3')
# Labels with dark backing.
def label(text,xy,font=medium):
    x,y=P(*xy); box=d.textbbox((x,y),text,font=font)
    d.rounded_rectangle((box[0]-8,box[1]-5,box[2]+8,box[3]+5),radius=5,fill='#132420')
    d.text((x,y),text,font=font,fill='#f3e5bc')
label('FLORESTA',(160,430))
label('CAMPOS DE LÍRIO',(1000,2020))
label('VALEDOURO',(1190,760))
label('PICOS DE GELO',(2420,230))
label('DUNAS DE ÂMBAR',(2380,1870))
label('CASCATA',(1980,350),small)
label('PONTE',(2220,1300),small)
d.rectangle((O[0],O[1],O[0]+3072*S,O[1]+2304*S),outline='#ead3a0',width=4)
d.text((33,950),'Visão cartográfica do projeto • não é captura do jogo',font=small,fill='#bfcbbe')
d.text((1120,32),'N ↑',font=medium,fill='#e5efdf')
out=ROOT.parent/'Mapa_Valedouro_Visao_Geral.png'
im.save(out)
print(out)
