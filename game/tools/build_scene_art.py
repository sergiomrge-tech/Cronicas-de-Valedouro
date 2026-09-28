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


def pix_noise(im, seed, amount=0.05, step=4):
    """Dither suave: acrescenta textura sem criar o efeito de 'sal e pimenta'."""
    rnd = random.Random(seed)
    d = ImageDraw.Draw(im, "RGBA")
    w, h = im.size
    count = int(w*h*amount/(step*step))
    for _ in range(count):
        x = rnd.randrange(0, max(1, w//step))*step
        y = rnd.randrange(0, max(1, h//step))*step
        sample = im.getpixel((min(x,w-1), min(y,h-1)))
        rgb = sample[:3]
        delta = rnd.choice((-1,1))*rnd.randint(4,11)
        tint = tuple(max(0,min(255,c+delta)) for c in rgb)
        d.rectangle((x,y,min(w-1,x+step-1),min(h-1,y+step-1)), fill=(*tint,rnd.randint(16,34)))
        if rnd.random() < .13:
            d.point((min(w-1,x+rnd.randrange(step)),min(h-1,y+rnd.randrange(step))), fill=(225,239,177,42))
    return im


def tree_stamp(d, x, y, s=1.0, autumn=False):
    """Árvore de cenário com luz superior-esquerda, massa de copa e sombra de contato."""
    d.ellipse((x-27*s,y-5*s,x+31*s,y+13*s), fill=(18,24,20,52))
    d.ellipse((x-19*s,y-2*s,x+24*s,y+9*s), fill=(12,18,14,80))
    trunk_dark=(78,47,28,255); trunk=(112,69,34,255); trunk_hi=(155,103,52,255)
    d.polygon([(x-7*s,y),(x-5*s,y-42*s),(x+7*s,y-41*s),(x+8*s,y)], fill=trunk_dark)
    d.polygon([(x-4*s,y-2*s),(x-3*s,y-42*s),(x+3*s,y-41*s),(x+3*s,y-3*s)], fill=trunk)
    d.line((x-2*s,y-37*s,x-1*s,y-9*s), fill=trunk_hi, width=max(1,int(s*2)))
    d.polygon([(x-6*s,y-5*s),(x-14*s,y+3*s),(x-3*s,y+2*s)], fill=trunk_dark)
    d.polygon([(x+6*s,y-5*s),(x+15*s,y+3*s),(x+2*s,y+2*s)], fill=trunk_dark)
    dark=(24,66,33,255) if not autumn else (101,48,31,255)
    mid=(44,118,49,255) if not autumn else (168,76,38,255)
    light=(86,168,67,255) if not autumn else (223,126,49,255)
    hi=(174,226,102,255) if not autumn else (255,194,80,255)
    clusters=[(-23,-54,19,15),(-7,-67,22,17),(14,-66,22,17),(29,-52,17,14),(-25,-39,17,14),(-5,-44,23,17),(17,-42,21,16)]
    for i,(cx,cy,rx,ry) in enumerate(clusters):
        d.ellipse((x+(cx-rx)*s,y+(cy-ry)*s,x+(cx+rx)*s,y+(cy+ry)*s), fill=dark)
        d.ellipse((x+(cx-rx+3)*s,y+(cy-ry+3)*s,x+(cx+rx-2)*s,y+(cy+ry-2)*s), fill=mid)
        if i % 2 == 0 or cy < -50:
            d.ellipse((x+(cx-rx+8)*s,y+(cy-ry+5)*s,x+(cx+rx-7)*s,y+(cy+ry-7)*s), fill=light)
    for cx,cy,rx,ry in [(-16,-72,11,6),(4,-78,12,6),(20,-68,9,5),(-29,-53,7,4)]:
        d.ellipse((x+(cx-rx)*s,y+(cy-ry)*s,x+(cx+rx)*s,y+(cy+ry)*s), fill=hi)
    # pequenos vazios/sombras internas quebram a silhueta de "bola"
    for cx,cy in [(-15,-48),(8,-53),(22,-43),(-5,-32)]:
        d.ellipse((x+(cx-5)*s,y+(cy-3)*s,x+(cx+5)*s,y+(cy+4)*s), fill=dark)


def house(d, x, y, w=180, h=120, roof=(76,85,120,255), walls=(194,164,118,255)):
    """Casa com fundação, madeiramento, telhas, janelas e sombra coerente."""
    dark=(63,48,43,255); timber=(101,63,39,255); timber_hi=(151,99,53,255)
    d.ellipse((x-w*.57,y+h*.36,x+w*.62,y+h*.65), fill=(18,23,20,68))
    # fundação de pedra
    d.rectangle((x-w/2-3,y+h*.36,x+w/2+3,y+h*.53), fill=(94,88,79,255))
    for sx in range(int(x-w/2),int(x+w/2),18):
        d.line((sx,y+h*.39,sx+10,y+h*.49),fill=(132,123,104,255),width=2)
    # paredes + vigas
    d.rectangle((x-w/2,y-h/2,x+w/2,y+h/2), fill=walls, outline=dark, width=4)
    d.line((x-w/2+6,y-h*.05,x+w/2-6,y-h*.05),fill=timber,width=4)
    for bx in (-w*.34, w*.34):
        d.line((x+bx,y-h*.45,x+bx,y+h*.42),fill=timber,width=4)
        d.line((x+bx+2,y-h*.42,x+bx+2,y+h*.38),fill=timber_hi,width=1)
    # telhado com beiral e linhas de telha
    roof_dark=tuple(max(0,c-28) if i<3 else c for i,c in enumerate(roof))
    roof_hi=tuple(min(255,c+28) if i<3 else c for i,c in enumerate(roof))
    d.polygon([(x-w*.62,y-h*.32),(x,y-h*.90),(x+w*.62,y-h*.32)], fill=dark)
    d.polygon([(x-w*.58,y-h*.35),(x,y-h*.85),(x+w*.58,y-h*.35)], fill=roof)
    for k in (0.15,0.30,0.45):
        yy=y-h*(.35+k)
        span=w*(.58-k*.42)
        d.line((x-span,yy,x+span,yy), fill=roof_dark, width=2)
    d.line((x-w*.48,y-h*.42,x,y-h*.82),fill=roof_hi,width=2)
    # chaminé
    if int(x) % 2 == 0:
        d.rectangle((x+w*.27,y-h*.77,x+w*.36,y-h*.47),fill=(111,76,60,255),outline=dark,width=2)
        d.rectangle((x+w*.25,y-h*.80,x+w*.38,y-h*.74),fill=(146,100,70,255))
    # porta
    d.rectangle((x-19,y+5,x+19,y+h/2), fill=dark)
    d.rectangle((x-15,y+8,x+15,y+h/2), fill=(91,56,39,255))
    d.line((x-10,y+11,x-10,y+h*.43),fill=(139,87,49,255),width=2)
    d.ellipse((x+8,y+27,x+11,y+30),fill=(232,190,82,255))
    d.rectangle((x-23,y+h/2-2,x+24,y+h/2+5),fill=(118,94,69,255))
    # janelas com moldura e jardineira
    for wx in (-w*.3,w*.3):
        d.rectangle((x+wx-18,y-9,x+wx+18,y+25), fill=dark)
        d.rectangle((x+wx-14,y-5,x+wx+14,y+21), fill=(88,177,196,255))
        d.line((x+wx,y-4,x+wx,y+20),fill=(224,222,164,255),width=2)
        d.line((x+wx-13,y+7,x+wx+13,y+7),fill=(224,222,164,255),width=2)
        d.rectangle((x+wx-18,y+23,x+wx+18,y+29),fill=timber)
        for fx in (-10,0,9):
            d.ellipse((x+wx+fx-2,y+19,x+wx+fx+3,y+25),fill=(236,124 if fx else 196,115,255))


def make_town():
    w,h=1774,887
    im=Image.new('RGBA',(w,h),(72,146,70,255)); pix_noise(im,11,.055)
    d=ImageDraw.Draw(im,'RGBA')
    # água/canais
    d.rounded_rectangle((680,0,905,h),30,fill=(58,140,159,255))
    for yy in range(20,h,55): d.line((690,yy,895,yy+20),fill=(164,224,218,110),width=3)
    # muralha e vias
    d.rectangle((60,45,w-60,h-55), outline=(102,96,83,255), width=14)
    d.rectangle((730,0,850,h), fill=(191,157,103,255))
    d.rectangle((0,405,w,515), fill=(191,157,103,255))
    d.line((731,0,731,h),fill=(126,108,76,170),width=3)
    d.line((849,0,849,h),fill=(126,108,76,170),width=3)
    d.line((0,406,w,406),fill=(126,108,76,170),width=3)
    d.line((0,514,w,514),fill=(126,108,76,170),width=3)
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
    im=Image.new('RGBA',(w,h),(54,124,59,255)); pix_noise(im,22,.065)
    d=ImageDraw.Draw(im,'RGBA')
    # caminho sinuoso
    pts=[]
    for x in range(-40,w+50,30):
        y=h*.55 + math.sin(x*.008)*80 + math.sin(x*.018)*25
        pts.append((x,y))
    d.line(pts, fill=(105,91,62,255), width=104)
    d.line(pts, fill=(160,126,74,255), width=78)
    d.line(pts, fill=(193,156,91,255), width=54)
    # riacho
    stream=[]
    for y in range(-20,h+20,20):
        x=w*.82 + math.sin(y*.015)*35
        stream.append((x,y))
    d.line(stream,fill=(54,133,153,255),width=75)
    d.line(stream,fill=(107,190,188,120),width=8)
    rnd=random.Random(71)
    for i in range(78):
        x=rnd.randint(55,w-55); y=rnd.randint(95,h-15)
        # evita caminho/água aproximados
        pathy=h*.55 + math.sin(x*.008)*80 + math.sin(x*.018)*25
        if abs(y-pathy)<75 or abs(x-(w*.82+math.sin(y*.015)*35))<65: continue
        tree_stamp(d,x,y,rnd.uniform(.72,1.05),autumn=(i%13==0))
    # pedras, arbustos e flores
    for _ in range(165):
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
