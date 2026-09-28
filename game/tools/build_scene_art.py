"""Gera/harmoniza as pinturas principais do protótipo.

Se os originais em assets/world_sources existirem, preserva e harmoniza-os.
No CI/repositório limpo, gera fallbacks determinísticos em pixel-art para que o
projeto seja totalmente reproduzível sem arquivos binários externos.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance
import random, math

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
SRC = ASSETS / "world_sources"
ASSETS.mkdir(parents=True, exist_ok=True)
SRC.mkdir(parents=True, exist_ok=True)


def grade(im):
    im = ImageEnhance.Color(im).enhance(1.16)
    im = ImageEnhance.Contrast(im).enhance(1.06)
    return ImageEnhance.Brightness(im).enhance(1.03)


def pix_noise(im, seed, amount=0.08, step=4):
    rnd = random.Random(seed)
    d = ImageDraw.Draw(im, "RGBA")
    w, h = im.size
    for _ in range(int(w*h*amount/(step*step))):
        x = rnd.randrange(0, w//step)*step
        y = rnd.randrange(0, h//step)*step
        a = rnd.randint(8, 22)
        if rnd.random() < .5:
            d.rectangle((x,y,x+step-1,y+step-1), fill=(255,255,220,a))
        else:
            d.rectangle((x,y,x+step-1,y+step-1), fill=(20,45,30,a))
    return im


def tree_stamp(d, x, y, s=1.0, autumn=False):
    # sombra de contato + tronco + copa com 4 níveis tonais
    d.ellipse((x-24*s,y-7*s,x+28*s,y+11*s), fill=(22,28,22,80))
    d.rectangle((x-5*s,y-38*s,x+6*s,y), fill=(89,55,30,255))
    dark=(30,73,38,255) if not autumn else (113,55,35,255)
    mid=(55,126,56,255) if not autumn else (179,85,42,255)
    light=(103,180,76,255) if not autumn else (229,137,55,255)
    hi=(183,226,109,255) if not autumn else (255,201,89,255)
    for cx,cy,rx,ry in [(-15,-46,22,17),(10,-49,24,18),(-2,-63,24,18),(23,-61,17,14),(-25,-60,17,14)]:
        d.ellipse((x+(cx-rx)*s,y+(cy-ry)*s,x+(cx+rx)*s,y+(cy+ry)*s), fill=dark)
        d.ellipse((x+(cx-rx+3)*s,y+(cy-ry+3)*s,x+(cx+rx-3)*s,y+(cy+ry-2)*s), fill=mid)
        d.ellipse((x+(cx-rx+8)*s,y+(cy-ry+5)*s,x+(cx+rx-7)*s,y+(cy+ry-7)*s), fill=light)
    d.ellipse((x-16*s,y-72*s,x+2*s,y-61*s), fill=hi)
    d.ellipse((x+4*s,y-72*s,x+19*s,y-62*s), fill=hi)


def house(d, x, y, w=180, h=120, roof=(76,85,120,255), walls=(194,164,118,255)):
    d.ellipse((x-w*.55,y+h*.35,x+w*.6,y+h*.62), fill=(20,25,22,70))
    d.rectangle((x-w/2,y-h/2,x+w/2,y+h/2), fill=walls, outline=(76,55,43,255), width=4)
    d.polygon([(x-w*.58,y-h*.35),(x,y-h*.85),(x+w*.58,y-h*.35)], fill=roof)
    d.line((x-w*.55,y-h*.34,x+w*.55,y-h*.34), fill=(38,34,47,255), width=5)
    d.rectangle((x-18,y+10,x+18,y+h/2), fill=(76,50,38,255))
    for wx in (-w*.3,w*.3):
        d.rectangle((x+wx-15,y-4,x+wx+15,y+24), fill=(105,188,199,255), outline=(60,52,45,255), width=3)
        d.line((x+wx,y-3,x+wx,y+23),fill=(230,221,160,255),width=2)


def make_town():
    w,h=1774,887
    im=Image.new('RGBA',(w,h),(91,137,78,255)); pix_noise(im,11,.14)
    d=ImageDraw.Draw(im,'RGBA')
    # água/canais
    d.rounded_rectangle((680,0,905,h),30,fill=(58,140,159,255))
    for yy in range(20,h,55): d.line((690,yy,895,yy+20),fill=(164,224,218,110),width=3)
    # muralha e vias
    d.rectangle((60,45,w-60,h-55), outline=(102,96,83,255), width=14)
    d.rectangle((730,0,850,h), fill=(194,171,120,255))
    d.rectangle((0,405,w,515), fill=(194,171,120,255))
    # pontes
    for yy in (300,470,650):
        d.rectangle((650,yy-28,935,yy+28),fill=(128,89,56,255),outline=(72,52,42,255),width=4)
        for xx in range(660,930,24): d.line((xx,yy-24,xx,yy+24),fill=(185,132,78,255),width=3)
    # prédios
    houses=[(280,220,200,125,(87,85,130,255)),(1150,210,220,130,(70,105,118,255)),(300,650,230,130,(116,74,65,255)),(1190,650,230,135,(75,82,115,255)),(1510,270,170,110,(95,65,76,255)),(1510,640,180,115,(73,92,91,255))]
    for x,y,ww,hh,roof in houses: house(d,x,y,ww,hh,roof)
    # praça/fonte
    d.ellipse((700,340,885,525),fill=(160,148,124,255),outline=(95,83,73,255),width=5)
    d.ellipse((748,388,837,477),fill=(72,155,176,255),outline=(217,207,165,255),width=5)
    d.ellipse((773,413,812,452),fill=(104,204,206,255))
    # árvores internas com sombras
    for i,(x,y) in enumerate([(130,130),(530,145),(1025,100),(1390,110),(1600,170),(150,740),(560,760),(1015,765),(1430,770),(1660,710)]):
        tree_stamp(d,x,y,0.85,autumn=(i%4==0))
    # jardins
    rnd=random.Random(33)
    for _ in range(80):
        x=rnd.randint(85,w-85); y=rnd.randint(70,h-70)
        if 640<x<945: continue
        c=rnd.choice([(255,225,111,220),(245,164,200,220),(225,240,220,220)])
        d.ellipse((x-2,y-2,x+2,y+2),fill=c)
    return im


def make_forest():
    w,h=1825,862
    im=Image.new('RGBA',(w,h),(48,103,57,255)); pix_noise(im,22,.22)
    d=ImageDraw.Draw(im,'RGBA')
    # caminho sinuoso
    pts=[]
    for x in range(-40,w+50,30):
        y=h*.55 + math.sin(x*.008)*80 + math.sin(x*.018)*25
        pts.append((x,y))
    d.line(pts, fill=(154,122,76,255), width=110)
    d.line(pts, fill=(186,151,91,255), width=70)
    # riacho
    stream=[]
    for y in range(-20,h+20,20):
        x=w*.82 + math.sin(y*.015)*35
        stream.append((x,y))
    d.line(stream,fill=(54,133,153,255),width=75)
    d.line(stream,fill=(107,190,188,120),width=8)
    rnd=random.Random(71)
    for i in range(62):
        x=rnd.randint(55,w-55); y=rnd.randint(95,h-15)
        # evita caminho/água aproximados
        pathy=h*.55 + math.sin(x*.008)*80 + math.sin(x*.018)*25
        if abs(y-pathy)<75 or abs(x-(w*.82+math.sin(y*.015)*35))<65: continue
        tree_stamp(d,x,y,rnd.uniform(.72,1.05),autumn=(i%13==0))
    # pedras, arbustos e flores
    for _ in range(120):
        x=rnd.randint(20,w-20); y=rnd.randint(20,h-20)
        if rnd.random()<.55:
            d.ellipse((x-8,y-5,x+10,y+6),fill=(78,93,74,170))
        else:
            d.ellipse((x-4,y-4,x+4,y+4),fill=(118,170,77,170))
    return im


def make_forge():
    w,h=1512,1040
    im=Image.new('RGBA',(w,h),(84,64,49,255)); d=ImageDraw.Draw(im,'RGBA')
    # pedra + piso de tábuas
    for y in range(0,h,32):
        for x in range(0,w,64):
            off=32 if (y//32)%2 else 0
            xx=x-off
            d.rectangle((xx,y,xx+62,y+30),fill=(91+(x+y)%13,79,68,255),outline=(48,43,39,255),width=2)
    d.rectangle((250,180,1180,860),fill=(126,88,53,255),outline=(52,41,33,255),width=8)
    for y in range(190,850,34): d.line((260,y,1170,y),fill=(88,58,39,255),width=2)
    # forja
    d.rectangle((960,210,1280,560),fill=(63,56,52,255),outline=(35,32,30,255),width=8)
    d.ellipse((1015,310,1225,510),fill=(54,39,35,255))
    d.ellipse((1050,360,1190,500),fill=(235,92,34,255))
    d.ellipse((1080,400,1160,485),fill=(255,191,64,255))
    # bancadas e bigorna
    d.rectangle((300,260,690,340),fill=(102,65,39,255),outline=(49,33,25,255),width=5)
    d.polygon([(720,510),(835,500),(860,540),(800,570),(735,558)],fill=(75,82,85,255))
    d.rectangle((770,560,815,655),fill=(78,52,34,255))
    # luz quente local
    glow=Image.new('RGBA',(w,h),(0,0,0,0)); gd=ImageDraw.Draw(glow,'RGBA')
    for r,a in [(300,16),(220,24),(150,35),(90,55)]: gd.ellipse((1120-r,420-r*.55,1120+r,420+r*.55),fill=(255,145,60,a))
    im=Image.alpha_composite(im,glow)
    return im


makers={"valedouro_art":make_town,"forest_art":make_forest,"forge_art":make_forge}
for name,maker in makers.items():
    src=SRC/f"{name}_original.png"
    if src.exists():
        out=grade(Image.open(src).convert('RGB'))
    else:
        out=grade(maker().convert('RGB'))
    out.save(ASSETS/f"{name}.png",optimize=True)

town=Image.open(ASSETS/'valedouro_art.png').convert('RGBA')
w,h=town.size
alpha=Image.new('L',town.size,0); px=alpha.load()
for y in range(h):
    for x in range(w):
        t=min(1.,max(0.,min(x,w-1-x,y,h-1-y)/95.))
        px[x,y]=round(255*t*t*(3-2*t))
town.putalpha(alpha)
town.save(ASSETS/'valedouro_blended.png',optimize=True)
print('Scene art ready:', ', '.join(makers))
