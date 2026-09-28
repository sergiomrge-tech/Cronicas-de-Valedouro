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
    """Casa medieval estilizada com fundação, vigas, telhas, janela profunda e jardim."""
    dark=(52,40,38,255); timber=(88,55,34,255); timber_hi=(151,101,57,255)
    stone=(97,94,88,255); stone_hi=(141,135,122,255)
    # sombra de contato em duas camadas
    d.ellipse((x-w*.58,y+h*.38,x+w*.64,y+h*.68), fill=(15,18,16,38))
    d.ellipse((x-w*.48,y+h*.43,x+w*.54,y+h*.61), fill=(12,14,13,68))
    # fundação de pedra aparelhada
    d.rectangle((x-w/2-4,y+h*.31,x+w/2+4,y+h*.54), fill=stone, outline=dark, width=3)
    row_y=int(y+h*.34)
    while row_y<int(y+h*.53):
        d.line((x-w/2-1,row_y,x+w/2+1,row_y),fill=(70,68,65,255),width=1)
        offset=0 if ((row_y-int(y+h*.34))//9)%2==0 else 9
        for sx in range(int(x-w/2)+offset,int(x+w/2),18):
            d.line((sx,row_y,sx,row_y+8),fill=(73,70,66,255),width=1)
        row_y+=9
    # reboco
    d.rectangle((x-w/2,y-h/2,x+w/2,y+h*.34), fill=walls, outline=dark, width=4)
    # madeiramento estrutural
    d.line((x-w/2+5,y-h*.08,x+w/2-5,y-h*.08),fill=timber,width=5)
    d.line((x-w/2+5,y+h*.30,x+w/2-5,y+h*.30),fill=timber,width=4)
    for bx in (-w*.34,0,w*.34):
        d.line((x+bx,y-h*.45,x+bx,y+h*.31),fill=timber,width=4)
        d.line((x+bx+2,y-h*.42,x+bx+2,y+h*.27),fill=timber_hi,width=1)
    # travessas diagonais
    d.line((x-w*.49,y-h*.42,x-w*.20,y-h*.09),fill=timber,width=3)
    d.line((x+w*.49,y-h*.42,x+w*.20,y-h*.09),fill=timber,width=3)
    # telhado: beiral escuro + fileiras de telha
    roof_dark=tuple(max(0,c-34) if i<3 else c for i,c in enumerate(roof))
    roof_mid=tuple(max(0,c-14) if i<3 else c for i,c in enumerate(roof))
    roof_hi=tuple(min(255,c+34) if i<3 else c for i,c in enumerate(roof))
    d.polygon([(x-w*.64,y-h*.30),(x,y-h*.94),(x+w*.64,y-h*.30)], fill=dark)
    d.polygon([(x-w*.60,y-h*.34),(x,y-h*.88),(x+w*.60,y-h*.34)], fill=roof_dark)
    # telhas em faixas com deslocamento
    for row in range(5):
        yy=y-h*(.37+row*.105)
        span=w*(.56-row*.075)
        d.line((x-span,yy,x+span,yy),fill=roof_mid,width=4)
        d.line((x-span,yy-2,x+span,yy-2),fill=roof_hi,width=1)
        cell=14
        start=int(x-span)+(row%2)*7
        for sx in range(start,int(x+span),cell):
            d.line((sx,yy-5,sx+2,yy+2),fill=roof_dark,width=1)
    d.line((x-w*.52,y-h*.40,x,y-h*.85),fill=roof_hi,width=2)
    # chaminé e remate
    if int(x) % 2 == 0:
        d.rectangle((x+w*.26,y-h*.79,x+w*.36,y-h*.45),fill=(100,70,58,255),outline=dark,width=2)
        d.rectangle((x+w*.24,y-h*.82,x+w*.38,y-h*.75),fill=(145,101,73,255),outline=dark,width=1)
        d.rectangle((x+w*.27,y-h*.74,x+w*.34,y-h*.69),fill=(78,65,60,255))
    # porta em relevo
    d.rectangle((x-21,y+1,x+21,y+h*.35), fill=dark)
    d.rectangle((x-16,y+5,x+16,y+h*.34), fill=(86,53,35,255))
    for yy in range(int(y+9),int(y+h*.31),9):
        d.line((x-14,yy,x+14,yy),fill=(132,82,45,255),width=1)
    d.line((x-11,y+7,x-11,y+h*.31),fill=(150,96,54,255),width=2)
    d.ellipse((x+8,y+22,x+12,y+26),fill=(241,196,76,255))
    d.rectangle((x-24,y+h*.34,x+25,y+h*.40),fill=stone_hi)
    # janelas recuadas, caixilho, toldo curto e jardineira
    for wx in (-w*.31,w*.31):
        d.rectangle((x+wx-20,y-13,x+wx+20,y+26), fill=dark)
        d.rectangle((x+wx-15,y-8,x+wx+15,y+20), fill=(47,111,135,255))
        d.rectangle((x+wx-12,y-5,x+wx+12,y+17), fill=(92,188,201,255))
        d.line((x+wx,y-6,x+wx,y+18),fill=(238,225,165,255),width=2)
        d.line((x+wx-12,y+6,x+wx+12,y+6),fill=(238,225,165,255),width=2)
        d.line((x+wx-10,y-3,x+wx-2,y+5),fill=(178,236,236,255),width=1)
        d.rectangle((x+wx-20,y+21,x+wx+20,y+29),fill=timber,outline=dark,width=1)
        for fx,fc in [(-11,(244,112,142,255)),(0,(248,206,93,255)),(10,(207,116,217,255))]:
            d.ellipse((x+wx+fx-3,y+17,x+wx+fx+3,y+24),fill=fc)
            d.line((x+wx+fx,y+23,x+wx+fx,y+27),fill=(56,112,51,255),width=1)
    # pequenos canteiros conectam a casa ao chão
    for side in (-1,1):
        gx=x+side*w*.42
        d.rectangle((gx-17,y+h*.43,gx+17,y+h*.49),fill=(92,64,39,255))
        for flower in range(4):
            fx=gx-12+flower*8
            d.line((fx,y+h*.43,fx,y+h*.35),fill=(54,112,48,255),width=2)
            d.ellipse((fx-2,y+h*.33,fx+2,y+h*.37),fill=(247,182 if flower%2 else 103,153,255))


def cobble_area(d, box, seed=1, base=(177,151,101,255)):
    x0,y0,x1,y1=map(int,box)
    d.rectangle((x0,y0,x1,y1),fill=base)
    rnd=random.Random(seed)
    row=0
    for y in range(y0+4,y1-2,12):
        off=0 if row%2==0 else 9
        for x in range(x0+3+off,x1-4,18):
            ww=rnd.randint(12,17); hh=rnd.randint(7,10)
            c=rnd.choice([(190,165,111,255),(164,142,98,255),(201,177,122,255),(149,130,92,255)])
            d.rounded_rectangle((x,y,x+ww,y+hh),2,fill=c,outline=(118,105,78,170),width=1)
            if rnd.random()<.35:
                d.line((x+2,y+2,x+ww-3,y+2),fill=(221,199,145,130),width=1)
        row+=1


def market_stall(d,x,y,cloth):
    dark=(62,43,35,255); wood=(111,70,39,255); wood_hi=(168,108,57,255)
    d.ellipse((x-45,y+18,x+47,y+34),fill=(16,18,16,60))
    d.rectangle((x-34,y,x+34,y+24),fill=wood,outline=dark,width=3)
    d.rectangle((x-30,y+2,x+30,y+8),fill=wood_hi)
    for leg in (-26,26):
        d.rectangle((x+leg-2,y+18,x+leg+2,y+38),fill=dark)
    d.polygon([(x-43,y),(x-33,y-30),(x+33,y-30),(x+43,y)],fill=cloth)
    d.line((x-34,y-25,x+34,y-25),fill=(245,208,143,210),width=2)
    for n in range(4):
        d.ellipse((x-24+n*16,y+5,x-17+n*16,y+12),fill=[(238,112,76,255),(245,196,75,255),(123,180,86,255),(190,110,205,255)][n])


def make_town():
    w,h=1774,887
    im=Image.new('RGBA',(w,h),(70,145,69,255)); pix_noise(im,11,.032)
    d=ImageDraw.Draw(im,'RGBA')
    rnd=random.Random(41)

    # manchas sutis de vegetação evitam um tapete verde plano
    for _ in range(210):
        x=rnd.randint(20,w-20); y=rnd.randint(20,h-20)
        rr=rnd.randint(5,18)
        col=rnd.choice([(61,132,61,40),(103,172,70,32),(43,115,57,32)])
        d.ellipse((x-rr,y-rr*.55,x+rr,y+rr*.55),fill=col)

    # canal principal com margem de pedra e correnteza
    d.rounded_rectangle((676,-10,909,h+10),30,fill=(43,119,145,255),outline=(45,76,83,255),width=5)
    d.line((682,0,682,h),fill=(147,145,126,255),width=8)
    d.line((903,0,903,h),fill=(147,145,126,255),width=8)
    for yy in range(12,h,34):
        offset=10 if (yy//34)%2 else 0
        for xx in (685,892):
            d.rectangle((xx-6+offset*.08,yy,xx+6+offset*.08,yy+18),fill=(105,104,96,255),outline=(73,72,70,255),width=1)
    for yy in range(20,h,42):
        drift=(yy//42)%3*5
        d.line((704+drift,yy,758+drift,yy+6),fill=(157,220,222,125),width=2)
        d.line((816-drift,yy+17,874-drift,yy+11),fill=(109,190,202,110),width=2)

    # muralha modular com blocos/crenelações
    d.rectangle((58,43,w-58,h-53), outline=(68,67,65,255), width=18)
    d.rectangle((68,53,w-68,h-63), outline=(128,125,112,255), width=6)
    for xx in range(76,w-75,36):
        d.rectangle((xx,37,xx+20,55),fill=(107,105,99,255),outline=(63,62,61,255),width=2)
        d.rectangle((xx,h-58,xx+20,h-40),fill=(107,105,99,255),outline=(63,62,61,255),width=2)
    for yy in range(73,h-72,36):
        d.rectangle((50,yy,68,yy+20),fill=(107,105,99,255),outline=(63,62,61,255),width=2)
        d.rectangle((w-68,yy,w-50,yy+20),fill=(107,105,99,255),outline=(63,62,61,255),width=2)

    # vias principais em pedra irregular
    cobble_area(d,(724,0,856,h),17,(181,154,105,255))
    cobble_area(d,(0,398,w,522),18,(181,154,105,255))
    # vielas que ligam prédios
    cobble_area(d,(245,275,645,337),23,(170,145,99,255))
    cobble_area(d,(1010,276,1448,337),24,(170,145,99,255))
    cobble_area(d,(245,596,645,660),25,(170,145,99,255))
    cobble_area(d,(1010,592,1455,660),26,(170,145,99,255))

    # pontes: tábuas, corrimões e postes
    for i,yy in enumerate((300,470,650)):
        d.rectangle((648,yy-31,937,yy+31),fill=(72,50,38,255))
        d.rectangle((654,yy-27,931,yy+27),fill=(130,87,50,255))
        for xx in range(660,930,20):
            d.rectangle((xx,yy-25,xx+14,yy+25),fill=(174 if (xx//20)%2 else 153,108,62,255))
            d.line((xx+2,yy-23,xx+12,yy-23),fill=(205,146,81,170),width=1)
        for side in (-1,1):
            ry=yy+side*34
            d.line((655,ry,930,ry),fill=(77,51,37,255),width=4)
            for xx in range(665,930,45):
                d.line((xx,yy+side*25,xx,yy+side*42),fill=(78,52,37,255),width=3)
        if i==1:
            for lx in (670,915):
                d.ellipse((lx-7,yy-48,lx+7,yy-34),fill=(238,162,53,95))
                d.ellipse((lx-3,yy-45,lx+3,yy-39),fill=(255,213,90,255))

    # prédios principais
    houses=[
        (280,220,210,132,(80,84,137,255),(205,172,125,255)),
        (1150,210,230,136,(62,105,122,255),(196,164,116,255)),
        (300,650,238,138,(126,70,57,255),(207,168,115,255)),
        (1190,650,238,140,(72,82,123,255),(196,164,116,255)),
        (1510,270,184,116,(103,64,79,255),(210,177,128,255)),
        (1510,640,190,120,(65,93,91,255),(196,166,119,255)),
    ]
    for x,y,ww,hh,roof,walls in houses:
        house(d,x,y,ww,hh,roof,walls)

    # mercado e pequenos anexos
    market_stall(d,560,455,(159,57,64,255))
    market_stall(d,1035,455,(49,85,145,255))
    market_stall(d,1260,455,(91,128,58,255))

    # praça em anéis de pedra e fonte em camadas
    d.ellipse((685,335,900,550),fill=(111,104,91,255))
    d.ellipse((696,346,889,539),fill=(176,159,118,255))
    for ring in (94,76):
        d.ellipse((792-ring,443-ring,792+ring,443+ring),outline=(119,106,83,255),width=3)
    for a in range(0,360,18):
        rad=math.radians(a)
        cx=792+math.cos(rad)*86; cy=443+math.sin(rad)*86
        d.ellipse((cx-5,cy-3,cx+5,cy+3),fill=(198,182,137,255))
    d.ellipse((744,395,840,491),fill=(83,79,77,255))
    d.ellipse((750,401,834,485),fill=(67,159,180,255))
    d.ellipse((773,424,811,462),fill=(104,207,210,255))
    d.ellipse((786,409,798,457),fill=(218,215,180,255))
    d.ellipse((779,405,805,417),fill=(158,220,220,255))

    # árvores internas e canteiros densos
    tree_positions=[(130,130),(530,145),(1025,100),(1390,110),(1600,170),(150,740),(560,760),(1015,765),(1430,770),(1660,710)]
    for i,(x,y) in enumerate(tree_positions):
        tree_stamp(d,x,y,0.88 if i%3 else .96,autumn=(i%4==0))
        # borda ajardinada sob a árvore
        d.ellipse((x-35,y+4,x+35,y+18),outline=(103,75,45,180),width=2)
        for n in range(5):
            ang=2*math.pi*n/5
            fx=x+math.cos(ang)*29; fy=y+11+math.sin(ang)*6
            d.ellipse((fx-2,fy-2,fx+2,fy+2),fill=(244,189 if n%2 else 110,165,230))

    # bancos, barris e caixas em áreas de serviço
    for bx,by in [(665,360),(920,360),(635,535),(950,535),(1440,440)]:
        d.rectangle((bx-18,by,bx+18,by+7),fill=(104,63,36,255),outline=(58,42,32,255),width=1)
        d.line((bx-13,by+7,bx-13,by+17),fill=(70,48,34,255),width=3)
        d.line((bx+13,by+7,bx+13,by+17),fill=(70,48,34,255),width=3)
    for cx,cy in [(120,420),(1640,440),(1080,720),(390,350)]:
        d.ellipse((cx-10,cy-13,cx+10,cy+13),fill=(103,62,37,255),outline=(57,40,32,255),width=2)
        d.line((cx-10,cy,cx+10,cy),fill=(176,115,58,255),width=2)
    for cx,cy in [(150,450),(1590,480),(1085,750),(420,370)]:
        d.rectangle((cx-12,cy-10,cx+12,cy+10),fill=(113,73,42,255),outline=(60,43,33,255),width=2)
        d.line((cx-10,cy-8,cx+10,cy+8),fill=(162,103,55,255),width=1)

    # postes de luz e bandeiras no eixo principal
    for ly in (160,345,590,760):
        for lx in (704,878):
            d.line((lx,ly,lx,ly+28),fill=(53,42,35,255),width=3)
            d.ellipse((lx-7,ly-5,lx+7,ly+9),fill=(244,168,60,70))
            d.ellipse((lx-3,ly-2,lx+3,ly+4),fill=(255,217,91,255))
    for fx in (185,1580):
        d.line((fx,95,fx,172),fill=(63,46,35,255),width=4)
        col=(126,55,89,255) if fx<500 else (61,82,138,255)
        d.polygon([(fx+3,100),(fx+54,108),(fx+48,148),(fx+3,140)],fill=col)
        d.line((fx+7,108,fx+46,114),fill=(220,185,111,170),width=2)

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
    # zona de trabalho inferior: racks, caixas, carvão, bancada e segundo bigorna
    for rx in (330, 760, 1040):
        d.rectangle((rx,650,rx+150,690),fill=(81,50,32,255),outline=(42,31,26,255),width=4)
        for k in range(3):
            d.line((rx+25+k*45,654,rx+30+k*45,684),fill=(172,184,184,255),width=5)
    for cx,cy in ((245,770),(330,790),(1180,760),(1240,805)):
        d.ellipse((cx-24,cy-14,cx+24,cy+14),fill=(43,39,36,255))
        d.ellipse((cx-18,cy-10,cx+18,cy+10),fill=(72,66,57,255))
    d.rectangle((560,720,900,790),fill=(88,55,34,255),outline=(46,32,26,255),width=5)
    for x in range(580,890,38):
        d.line((x,730,x+20,780),fill=(126,82,46,255),width=2)
    d.polygon([(945,760),(1040,752),(1060,785),(1010,815),(955,805)],fill=(72,78,80,255))
    d.rectangle((990,810,1025,900),fill=(74,49,32,255))
    # lanternas laterais e faíscas congeladas no quadro
    for lx,ly in ((220,600),(1180,600),(510,610)):
        d.rectangle((lx-2,ly,lx+2,ly+24),fill=(54,38,30,255))
        d.ellipse((lx-10,ly-10,lx+10,ly+8),fill=(242,125,47,255))
        d.ellipse((lx-5,ly-8,lx+5,ly+3),fill=(255,212,91,255))
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
