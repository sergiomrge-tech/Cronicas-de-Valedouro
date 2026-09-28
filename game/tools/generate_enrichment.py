"""Enriquecimento visual v0.6 para Crônicas de Valedouro.

Mantém a gramática visual v0.5: pixel art nítida, contorno roxo-escuro,
3 tons por material, silhuetas legíveis e paletas por bioma.

Gera:
- terreno refinado (margem de rio, água rasa, vale, dunas);
- vegetação/props extras;
- construções de fronteira;
- folhas de animação completas com 40 quadros (5 estados x 8 frames)
  para monstros antigos e novos.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance
from math import sin, cos, pi
import sys

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets"
sys.path.insert(0, str(Path(__file__).resolve().parent))
from estilo_px import hexc, canvas, outline, rect, dot, line_px, mix
import generate_creatures as C
import generate_world_art as W

P = lambda *h: tuple(hexc(x) for x in h)
DARK = hexc('#20142a')
WHITE = hexc('#ffffff')


def noise_ground(pal, seed, tufts=0, pebbles=0, streaks=0):
    return W.noise_tile(32, pal, seed, tufts=tufts, pebbles=pebbles, speck=.06 if pebbles else .03)


def riverbank_tile():
    pal = P('#b9c47a', '#86945c', '#5d6c45', '#3d4935')
    im = noise_ground(pal, 261, tufts=2, pebbles=3)
    d = ImageDraw.Draw(im)
    for x in (3, 11, 23, 28):
        y = (x * 7 + 5) % 26 + 3
        d.ellipse((x-2, y-1, x+2, y+1), fill=hexc('#b6aa86'))
        dot(d, x-1, y-1, hexc('#e3d7b2'))
    return im


def shallow_tile():
    im = W.water_tile(32, 314)
    d = ImageDraw.Draw(im)
    for y in (7, 18, 27):
        for x in range((y * 3) % 9, 32, 13):
            d.line([(x, y), (min(31, x+6), y)], fill=hexc('#b8f1ec'))
    return im


def valley_tile():
    pal = P('#d5ef8b', '#9bd16a', '#67ad52', '#3f7842')
    im = W.noise_tile(32, pal, 372, tufts=5, flowers=1, pebbles=1)
    d = ImageDraw.Draw(im)
    for x, y in ((6,8),(25,12),(18,26)):
        d.line([(x,y),(x+3,y-2)], fill=hexc('#6c7a48'))
    return im


def dune_tile():
    pal = P('#ffe0a0', '#e7b867', '#c58a45', '#8c5c36')
    im = W.noise_tile(32, pal, 419, speck=.05, pebbles=1)
    d = ImageDraw.Draw(im)
    for y, xoff in ((9,0),(22,7)):
        d.arc((xoff-6, y-5, xoff+26, y+8), 205, 330, fill=pal[0], width=1)
        d.arc((xoff-4, y-2, xoff+28, y+10), 205, 330, fill=pal[2], width=1)
    return im


def reed():
    im,d=canvas(32,32)
    green=P('#b7d86b','#6fa34d','#3f6e3d')
    for x,h,s in ((8,19,-2),(13,23,2),(18,17,-1),(23,21,1)):
        line_px(d,x,29,x+s,29-h,green[1],1)
        line_px(d,x+1,29,x+s+1,29-h,green[2],1)
        d.ellipse((x+s-1,8 if h>20 else 11,x+s+2,13 if h>20 else 16),fill=hexc('#a96a42'))
    return outline(im)


def dead_bush():
    im,d=canvas(32,32)
    c=P('#d1a061','#9a6d3d','#61432d')
    for x0,y0,x1,y1 in ((16,28,15,9),(15,17,6,12),(15,19,25,13),(12,21,6,22),(20,20,27,23)):
        line_px(d,x0,y0,x1,y1,c[1],2)
        dot(d,x1,y1,c[0])
    return outline(im)


def ice_crystal():
    im,d=canvas(32,40)
    c=P('#ffffff','#9eeeff','#50b7e3','#3976aa')
    d.polygon([(7,34),(11,12),(16,34)],fill=c[2]); d.polygon([(10,29),(11,14),(13,29)],fill=c[0])
    d.polygon([(15,34),(20,4),(25,34)],fill=c[1]); d.polygon([(19,28),(20,7),(22,28)],fill=c[0])
    d.polygon([(20,35),(26,15),(30,35)],fill=c[2])
    return outline(im)


def valley_rock():
    return W.rock(P('#d8c7a0','#aa8d69','#796249','#4c4037'))


def draw_building(kind: str):
    if kind == 'watchtower':
        im,d=canvas(80,112); wood=P('#f0bd72','#b97742','#75462c'); stone=P('#b8b0c0','#827b8e','#50495e')
        d.ellipse((12,94,68,106),fill=(20,12,26,80))
        for x in (23,49): rect(d,x,49,x+7,99,wood[2]); rect(d,x+1,49,x+6,96,wood[1])
        rect(d,15,34,65,56,wood[2]); rect(d,17,35,63,53,wood[1]); rect(d,18,36,62,39,wood[0])
        for x in range(18,64,10): rect(d,x,27,x+5,38,stone[1])
        d.polygon([(12,30),(40,8),(68,30)],fill=hexc('#9b4a3b')); d.polygon([(18,28),(40,11),(62,28)],fill=hexc('#d1694d'))
        rect(d,36,56,43,87,wood[0]); line_px(d,24,75,53,75,wood[0],2); line_px(d,25,91,52,91,wood[0],2)
        return outline(im)
    if kind == 'windmill':
        im,d=canvas(112,112); wall=P('#f2dfb1','#c9a66b','#8c6844'); roof=P('#e67a57','#b94e41','#73303a'); wood=P('#e3b069','#a86b3d','#66402a')
        d.ellipse((20,94,88,106),fill=(20,12,26,70)); d.polygon([(31,92),(38,35),(72,35),(82,92)],fill=wall[2]); d.polygon([(34,89),(40,37),(69,37),(78,89)],fill=wall[1]); d.polygon([(39,39),(48,28),(67,28),(73,39)],fill=roof[1])
        rect(d,50,72,61,92,wood[2]); rect(d,41,51,48,59,hexc('#72a8b8')); rect(d,67,51,74,59,hexc('#72a8b8'))
        cx,cy=58,40
        for ang in (0,pi/2,pi,3*pi/2):
            ex,ey=cx+int(cos(ang)*43),cy+int(sin(ang)*43); line_px(d,cx,cy,ex,ey,wood[2],3)
            px,py=cx+int(cos(ang)*20),cy+int(sin(ang)*20); qx,qy=cx+int(cos(ang)*39),cy+int(sin(ang)*39)
            ox,oy=int(-sin(ang)*5),int(cos(ang)*5); d.polygon([(px+ox,py+oy),(qx+ox,qy+oy),(qx-ox,qy-oy),(px-ox,py-oy)],fill=wood[0])
        d.ellipse((53,35,63,45),fill=wood[2]); dot(d,56,38,hexc('#ffe3a0'))
        return outline(im)
    if kind == 'desert_outpost':
        im,d=canvas(112,88); cloth=P('#ffd181','#d98152','#9a4a38'); wood=P('#e0b16e','#9d6840','#5f3c2b')
        d.ellipse((12,72,100,84),fill=(35,20,30,70)); d.polygon([(10,68),(30,25),(82,25),(102,68)],fill=cloth[2]); d.polygon([(17,64),(34,29),(78,29),(95,64)],fill=cloth[1]); d.polygon([(24,48),(56,21),(88,48)],fill=cloth[0])
        for x in (21,91): rect(d,x,36,x+4,73,wood[2])
        rect(d,48,52,64,72,wood[2]); rect(d,52,55,60,72,hexc('#4d2d2b')); d.line([(30,37),(82,37)],fill=hexc('#fff1b8'),width=2)
        return outline(im)
    if kind == 'ice_lodge':
        im,d=canvas(112,88); wall=P('#edf6f7','#a8ced3','#648d9b'); wood=P('#bb8c62','#825a45','#53394a')
        d.ellipse((10,72,103,84),fill=(30,40,65,70)); rect(d,22,38,91,73,wall[2]); rect(d,24,39,89,71,wall[1]); d.polygon([(15,40),(56,10),(99,40)],fill=hexc('#6f7191')); d.polygon([(23,37),(56,15),(91,37)],fill=hexc('#b8dce4'))
        rect(d,48,52,63,73,wood[2]); rect(d,30,48,42,58,hexc('#7ad7ee')); rect(d,71,48,83,58,hexc('#7ad7ee'))
        for x in range(25,90,15): d.line([(x,39),(x+10,39)],fill=WHITE,width=2)
        return outline(im)
    if kind == 'shrine':
        im,d=canvas(72,88); stone=P('#d9cce8','#9586b4','#594c77'); rune=P('#fff0ff','#c886ff','#7c3ed6')
        d.ellipse((8,73,64,84),fill=(25,15,38,80)); rect(d,19,35,53,75,stone[2]); rect(d,22,36,50,72,stone[1]); d.polygon([(16,35),(36,8),(56,35)],fill=stone[2]); d.polygon([(21,33),(36,13),(51,33)],fill=stone[0])
        d.polygon([(36,43),(44,52),(36,62),(28,52)],fill=rune[2]); d.polygon([(36,46),(41,52),(36,58),(31,52)],fill=rune[1]); dot(d,35,49,rune[0])
        return outline(im)
    if kind == 'ruin_arch':
        im,d=canvas(88,88); stone=P('#c9c0b5','#8e817d','#5c5057')
        d.ellipse((8,72,80,84),fill=(20,12,26,70)); rect(d,14,22,29,73,stone[2]); rect(d,59,22,74,73,stone[2]); rect(d,16,21,27,70,stone[1]); rect(d,61,21,72,70,stone[1]);
        d.arc((20,4,68,52),180,360,fill=stone[0],width=8); d.arc((20,5,68,53),180,360,fill=stone[2],width=2)
        for x,y in ((18,31),(65,45),(25,61),(69,26)): dot(d,x,y,hexc('#6fa064'))
        return outline(im)
    raise ValueError(kind)


# ----------------------- monstros 40 frames -----------------------
STATE_ROWS = ['idle','walk','attack','hurt','death']


def pad(im: Image.Image, size: int):
    if im.size == (size,size): return im.copy()
    out=Image.new('RGBA',(size,size),(0,0,0,0)); out.alpha_composite(im,((size-im.width)//2,size-im.height)); return out


def tint(im, col, amount):
    ov=Image.new('RGBA',im.size,col); return Image.blend(im,ov,amount)


def state_frame(base: Image.Image, state: str, f: int, size: int):
    im=pad(base,size)
    canvas_im=Image.new('RGBA',(size,size),(0,0,0,0))
    if state=='idle':
        y=-1 if f in (2,3) else 0; canvas_im.alpha_composite(im,(0,y))
    elif state=='walk':
        y=-1 if f%4 in (1,2) else 0; canvas_im.alpha_composite(im,(0,y))
    elif state=='attack':
        offsets=[0,1,3,6,7,5,2,0]; canvas_im.alpha_composite(im,(offsets[f],0))
    elif state=='hurt':
        offsets=[-2,2,-2,1,0,0,0,0]; shaken=Image.new('RGBA',(size,size),(0,0,0,0)); shaken.alpha_composite(im,(offsets[f],0)); canvas_im=tint(shaken,(255,105,115,255),.38 if f<4 else .12)
    else:
        # queda: afunda e gira 90° no fim, sempre pixel-perfect (NEAREST)
        sink=[0,1,2,4,7,10,13,16][f]
        if f>=5:
            rot=im.rotate(90, resample=Image.Resampling.NEAREST, expand=False)
            canvas_im.alpha_composite(rot,(0,sink))
        else:
            canvas_im.alpha_composite(im,(0,sink))
        if f>=6:
            a=canvas_im.getchannel('A').point(lambda p: int(p*(.68 if f==6 else .38)))
            canvas_im.putalpha(a)
    return canvas_im


def spider(frame):
    im,d=canvas(36,36); body=P('#b97bdd','#70459b','#3b285e'); leg=hexc('#392449'); glow=hexc('#ff7ac8'); phase=frame*pi/4
    for i in range(4):
        y=15+i*3; ext=int(sin(phase+i)*2); line_px(d,13,y,4+ext,y-5 if i<2 else y+4,leg,2); line_px(d,23,y,32-ext,y-5 if i<2 else y+4,leg,2)
    d.ellipse((9,12,27,29),fill=body[2]); d.ellipse((10,11,26,26),fill=body[1]); d.ellipse((13,12,20,17),fill=body[0]); d.ellipse((14,5,24,15),fill=body[1]);
    for x in (16,21): dot(d,x,10,glow); dot(d,x,9,WHITE)
    d.polygon([(14,7),(11,2),(17,6)],fill=body[2]); d.polygon([(23,7),(27,2),(24,8)],fill=body[2])
    return outline(im)


def boar(frame):
    im,d=canvas(36,36); fur=P('#b89268','#79583f','#473747'); phase=frame*pi/4; step=int(sin(phase)*2)
    for x,o in ((10,step),(15,-step),(22,-step),(27,step)): rect(d,x+o,23,x+o+2,31,fur[2])
    d.ellipse((6,12,28,27),fill=fur[2]); d.ellipse((7,11,27,24),fill=fur[1]); d.ellipse((9,12,18,17),fill=fur[0]); d.ellipse((23,12,35,24),fill=fur[1]); d.ellipse((29,17,35,22),fill=hexc('#d6a08b'))
    d.polygon([(24,11),(25,4),(29,12)],fill=fur[2]); dot(d,28,14,hexc('#ffd85b')); dot(d,28,13,WHITE); d.polygon([(31,21),(34,26),(29,23)],fill=WHITE)
    return outline(im)


def flower_monster(frame):
    im,d=canvas(36,36); stem=P('#b8e978','#62a94e','#37653f'); pet=P('#ffb06b','#e65b6c','#8c355e'); sway=int(sin(frame*pi/4)*2)
    line_px(d,18,31,18+sway,18,stem[1],4); d.ellipse((9,27,19,32),fill=stem[1]); d.ellipse((18,25,29,31),fill=stem[2]); cx,cy=19+sway,13
    for a in range(8):
        ang=a*pi/4; px=cx+int(cos(ang)*8); py=cy+int(sin(ang)*7); d.ellipse((px-4,py-3,px+4,py+3),fill=pet[1 if a%2 else 0])
    d.ellipse((13+sway,7,26+sway,20),fill=pet[2]); d.pieslice((13+sway,7,26+sway,21),15,165,fill=hexc('#2d203a')); 
    for x in (16+sway,22+sway): dot(d,x,12,WHITE)
    return outline(im)


def beetle(frame):
    im,d=canvas(36,36); shell=P('#ffd36c','#d88a32','#804426'); horn=hexc('#4a2e38'); step=int(sin(frame*pi/4)*2)
    for i,y in enumerate((16,21,25)): line_px(d,12,y,4+step*(1 if i%2 else -1),y+(-4+i*3),horn,2); line_px(d,24,y,32-step*(1 if i%2 else -1),y+(-4+i*3),horn,2)
    d.ellipse((8,9,28,30),fill=shell[2]); d.ellipse((10,8,27,27),fill=shell[1]); d.pieslice((11,8,27,25),190,350,fill=shell[0]); line_px(d,18,10,18,28,horn,1); d.ellipse((13,5,24,14),fill=horn); d.polygon([(19,8),(27,2),(23,10)],fill=horn); dot(d,22,9,WHITE)
    return outline(im)


def ice_golem(frame):
    im,d=canvas(40,40); ice=P('#ffffff','#a9e6ef','#5ba9c9','#376c98'); bob=-1 if frame in (2,3,4) else 0
    for x in (9,25): d.polygon([(x,25+bob),(x+7,24+bob),(x+9,37),(x-1,37)],fill=ice[3]); d.polygon([(x+1,25+bob),(x+6,25+bob),(x+5,34),(x+1,34)],fill=ice[1])
    d.polygon([(8,11+bob),(31,9+bob),(35,27+bob),(21,32+bob),(6,27+bob)],fill=ice[3]); d.polygon([(10,12+bob),(29,11+bob),(31,25+bob),(20,28+bob),(9,25+bob)],fill=ice[1]); d.polygon([(12,13+bob),(22,11+bob),(18,21+bob)],fill=ice[0])
    for x in (4,32): d.polygon([(x,14+bob),(x+5,9+bob),(x+8,19+bob),(x+4,29+bob),(x,26+bob)],fill=ice[2])
    d.polygon([(15,7+bob),(20,1+bob),(26,7+bob),(28,15+bob),(13,15+bob)],fill=ice[2]); rect(d,17,9+bob,19,10+bob,hexc('#6effff')); rect(d,23,8+bob,25,10+bob,hexc('#6effff'))
    return outline(im)


def old_base(kind, frame):
    f=frame%4
    gray=P('#c8d4e8','#7f8fb0','#48527a'); ice=P('#ffffff','#bfe8f8','#6aa8d4')
    if kind=='wolf': return C.wolf(f,gray,hexc('#e8eef8'),hexc('#ffd23a'))
    if kind=='ice_wolf': return C.wolf(f,ice,hexc('#ffffff'),hexc('#3ae0ff'),P('#ffffff','#8ef4ff','#2e98d0'))
    if kind=='slime': return C.slime(f)
    if kind=='scorpion': return C.scorpion(f)
    if kind=='boss': return C.guardian(f)
    raise ValueError(kind)


def monster_base(kind, frame):
    if kind in ('wolf','ice_wolf','slime','scorpion','boss'): return old_base(kind,frame)
    return {'spider':spider,'boar':boar,'flower_beast':flower_monster,'amber_beetle':beetle,'ice_golem':ice_golem}[kind](frame)


def make_full_sheet(kind, size):
    sheet=Image.new('RGBA',(size*8,size*5),(0,0,0,0))
    for row,state in enumerate(STATE_ROWS):
        for f in range(8):
            base=monster_base(kind,f)
            fr=state_frame(base,state,f,size)
            sheet.alpha_composite(fr,(f*size,row*size))
    return sheet


def main():
    OUT.mkdir(exist_ok=True)
    riverbank_tile().save(OUT/'riverbank.png')
    shallow_tile().save(OUT/'shallow_water.png')
    valley_tile().save(OUT/'valley_grass.png')
    dune_tile().save(OUT/'desert_dune.png')
    reed().save(OUT/'reed.png')
    dead_bush().save(OUT/'dead_bush.png')
    ice_crystal().save(OUT/'ice_crystal.png')
    valley_rock().save(OUT/'valley_rock.png')
    for name in ('watchtower','windmill','desert_outpost','ice_lodge','shrine','ruin_arch'):
        draw_building(name).save(OUT/f'{name}.png')
    sizes={'boss':64,'ice_golem':40}
    for kind in ('wolf','slime','scorpion','ice_wolf','boss','spider','boar','flower_beast','amber_beetle','ice_golem'):
        size=sizes.get(kind,36)
        make_full_sheet(kind,size).save(OUT/f'{kind}_full.png')
    print('ENRICHMENT v0.6: terreno, construções e 10 folhas de 40 frames geradas')

if __name__=='__main__':
    main()
