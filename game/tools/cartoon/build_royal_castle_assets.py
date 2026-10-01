"""Original monumental Cartoon royal castle and palace décor, deterministic SVG."""
from pathlib import Path
import hashlib,json,random,math
import build_visual_assets as base
OUT=Path(__file__).resolve().parents[2]/'assets/cartoon/v023'
base.OUT=OUT
Art=base.Art
I='#34443e'

def art(w,h):
 a=Art(w,h)
 a.parts.append('''<defs><linearGradient id="ivory" x2=".4" y2="1"><stop stop-color="#fcf0d5"/><stop offset=".55" stop-color="#d6c9a6"/><stop offset="1" stop-color="#a69d86"/></linearGradient><linearGradient id="gold" x2=".4" y2="1"><stop stop-color="#ffe5a0"/><stop offset=".5" stop-color="#c9a259"/><stop offset="1" stop-color="#876d39"/></linearGradient><linearGradient id="velvet" x2=".3" y2="1"><stop stop-color="#a14751"/><stop offset=".55" stop-color="#713340"/><stop offset="1" stop-color="#402932"/></linearGradient><linearGradient id="blue" x2=".3" y2="1"><stop stop-color="#75a3b3"/><stop offset=".5" stop-color="#396878"/><stop offset="1" stop-color="#294d60"/></linearGradient><radialGradient id="light"><stop stop-color="#fff2af" stop-opacity=".45"/><stop offset="1" stop-color="#ffe8a0" stop-opacity="0"/></radialGradient></defs>''')
 return a

def crest(a,x,y,s=1):
 a.path(f'M{x-20*s},{y-12*s} L{x+20*s},{y-12*s} L{x+17*s},{y+15*s} L{x},{y+27*s} L{x-17*s},{y+15*s} Z','url(#blue)','#e1c080',2*s)
 a.path(f'M{x-12*s},{y} l3,{9*s} l{18*s},0 l{3*s},{-9*s} l{-9*s},{4*s} l{-6*s},{-10*s} l{-5*s},{10*s} Z','url(#gold)',I,1*s)

def roof(a,x,y,w,h):
 a.path(f'M{x},{y+h} L{x+w*.46},{y} L{x+w},{y+h*.85} L{x+w*.94},{y+h} Z','url(#blue)',I,3)
 for j in range(1,9):
  yy=y+h*j/9;left=x+w*.46*(1-j/9);right=x+w*.46+w*.54*j/9
  a.path(f'M{left},{yy} Q{x+w*.53},{yy+8} {right},{yy-5}','none','#8eacac',1.7)
  for k in range(1,8):
   xx=left+(right-left)*k/8
   a.line(xx,yy,xx-3,yy+h/10,'#244c61',1.3)
 a.path(f'M{x+w*.46},{y-9} L{x+w*.46+6},{y+3} L{x+w*.94},{y+h-5}','none','#ddbf78',4)

def tower(a,x,y,w,h):
 a.ellipse(x+w/2,y+h+16,w*.72,w*.17,'#273c3030')
 a.path(f'M{x},{y+50} Q{x+w/2},{y+28} {x+w},{y+50} L{x+w},{y+h} Q{x+w/2},{y+h+22} {x},{y+h} Z','url(#ivory)',I,3)
 a.path(f'M{x+w*.68},{y+58} L{x+w},{y+50} L{x+w},{y+h} Q{x+w*.85},{y+h+7} {x+w*.68},{y+h+13} Z','#a8a790',I,1)
 for yy in range(int(y+90),int(y+h-15),32):
  a.path(f'M{x+2},{yy} Q{x+w/2},{yy+14} {x+w-2},{yy}','none','#aaa88e',1)
  for j in [1,3,5]:a.line(x+w*j/6,yy+4,x+w*j/6,yy+27,'#b2ad94',1)
 for yy in range(int(y+114),int(y+h-32),100):
  a.path(f'M{x+w*.39},{yy+35} L{x+w*.39},{yy+6} Q{x+w*.5},{yy-8} {x+w*.61},{yy+6} L{x+w*.61},{yy+35} Z','#425c5c','#dfcca1',3)
  a.line(x+w*.5,yy+5,x+w*.5,yy+31,'#c9ba84',2)
 a.ellipse(x+w/2,y+52,w*.6,w*.14,'#e4d3ad',I,3)
 roof(a,x-17,y-115,w+34,155)
 a.line(x+w*.48,y-148,x+w*.48,y-114,'#bda470',4)
 a.path(f'M{x+w*.48},{y-148} l{w*.57},8 l{-w*.12},18 l{-w*.45},-5 Z','#d6b061',I,1)

def exterior():
 a=art(1700,1350)
 base.shadow(a,850,1234,730)
 # One integrated silhouette: foundation, wings, keep, towers, roof and gate.
 a.path('M138,1152 L744,967 L1545,1125 L1564,1221 L835,1330 L144,1264 Z','#8d947f',I,4)
 for k in range(6):a.path(f'M{340-k*23},{1240+k*9} L{1240+k*29},{1210+k*10} L{1261+k*30},{1221+k*10} L{316-k*24},{1254+k*9} Z','#ded1aa',I,2)
 # Rear flanks visible behind central keep.
 for x in [275,1040]:
  a.path(f'M{x},636 L{x+337},584 L{x+420},686 L{x+419},1035 L{x},1100 Z','url(#ivory)',I,4)
  a.path(f'M{x+337},584 L{x+420},686 L{x+419},1035 L{x+340},1003 Z','#aba88e',I,3)
  roof(a,x-15,402,430,246)
  for yy in [718,844,970]:
   for xx in range(x+35,x+325,72):
    a.path(f'M{xx},{yy+48} L{xx},{yy+10} Q{xx+17},{yy-10} {xx+34},{yy+10} L{xx+34},{yy+48} Z','url(#blue)','#eee0b6',4)
    a.line(xx+17,yy+9,xx+17,yy+48,'#d5c28a',2)
  for yy in range(666,1072,33):a.line(x+6,yy,x+330,yy-31,'#c1b79a',1)
 tower(a,92,687,190,525);tower(a,1427,687,175,485)
 tower(a,357,435,150,590);tower(a,1187,422,150,609)
 # Main keep in three-quarter perspective with a shaded east face.
 a.path('M548,454 L992,412 L1145,558 L1145,1087 L556,1166 Z','url(#ivory)',I,5)
 a.path('M992,412 L1145,558 L1145,1087 L996,1046 Z','#aba990',I,3)
 roof(a,513,229,666,279)
 a.path('M582,469 L968,435 L1088,546 L634,595 Z','#e7d9af',I,3)
 for yy in range(589,1094,32):a.line(566,yy,990,yy-52,'#b8af95',1.3)
 for xx in [593,707,824,932]:
  for yy in [597,751]:
   a.path(f'M{xx},{yy+67} L{xx},{yy+7} Q{xx+24},{yy-23} {xx+48},{yy+7} L{xx+48},{yy+67} Z','url(#blue)','#f8e6b4',5)
   a.line(xx+24,yy+5,xx+24,yy+65,'#d4b779',3);a.line(xx,yy+31,xx+48,yy+31,'#d4b779',3)
  a.rect(xx-6,yy+80,62,15,'url(#gold)',I,2,3)
 # Crown tower and its two narrow attendant spires.
 tower(a,704,214,242,404);tower(a,566,335,115,284);tower(a,1002,304,111,299)
 # Grand portal at the foot anchor; no separate floating roof/door assets.
 a.path('M712,1195 L704,1004 Q822,847 951,988 L954,1169 Z','#d3c59b',I,4)
 a.path('M733,1182 L733,1008 Q823,889 929,1001 L932,1168 Z','#34443c','#f6dc9b',8)
 a.path('M752,1178 L750,1014 Q824,921 910,1007 L912,1170 Z','#795338','#cba869',4)
 a.line(832,971,832,1175,'#d6b878',3)
 for xx in [768,788,812,857,881,897]:a.line(xx,1015,xx,1165,'#af8954',3)
 for yy in [1055,1141]:a.line(754,yy,908,yy-6,'#454d42',9)
 a.ellipse(824,1111,7,10,'url(#gold)',I,2);a.ellipse(843,1111,7,10,'url(#gold)',I,2)
 crest(a,831,886,2.1)
 for x in [647,998]:
  a.path(f'M{x},872 l52,-5 l-1,191 l-24,26 l-27,-21 Z','url(#velvet)','#dfc082',3)
  crest(a,x+26,930,0.7)
 for x,y in [(683,1085),(981,1043)]:
  a.path(f'M{x-10},{y} l20,-2 l-4,38 l-14,0 Z','#efce7c',I,3)
  a.ellipse(x,y+18,40,53,'url(#light)')
 a.save('royal_castle')

def floor(name,palette):
 a=art(1240,960)
 a.rect(0,0,1240,960,'#16221f',I,3,12)
 a.rect(22,92,1196,845,'url(#ivory)',I,3,6)
 rng=random.Random(2300+len(name))
 for y in range(100,935,70):
  for x in range(28,1210,70):
   c=rng.choice(['#e1dfc6','#d3d5c0','#c8cebd','#ece5cd'])
   a.rect(x,y,67,67,c,'#b4bba8',1,2)
   a.path(f'M{x+3},{y+44} q20,-16 33,-6 t25,-11','none','#c0c4b2',1)
 for inset in [36,52]:a.rect(inset,105+inset/4,1240-inset*2,800-inset/2,'none','#a48e56',2,3)
 for x in range(75,1175,105):
  a.path(f'M{x},141 l9,-9 l9,9 l-9,9 Z','#bdac75','none')
  a.path(f'M{x},900 l9,-9 l9,9 l-9,9 Z','#bdac75','none')
 a.rect(20,12,1200,90,'url(#ivory)',I,3,6)
 for x in range(30,1200,190):
  a.rect(x,19,178,75,palette,'#d3b67d',3,3)
  a.rect(x+10,29,158,55,'none','#e9d19d',1.5,2)
 for x in [148,962]:
  a.path(f'M{x},104 L{x},35 Q{x+55},-2 {x+110},35 L{x+110},104 Z','url(#blue)','#e6d6a5',6)
  a.line(x+55,25,x+55,103,'#e5d39b',4);a.line(x+9,68,x+101,68,'#e5d39b',3)
  for xx,yy in [(22,130),(1180,130)]:a.rect(xx,yy,38,762,'url(#ivory)','#8a957f',2,4)
 # Central compass inlaid in marble; furniture and runners sit above it.
 for j in range(16):
  ang=math.tau*j/16;ang2=ang+math.pi/16
  a.path(f'M620,500 L{620+math.cos(ang)*105},{500+math.sin(ang)*80} L{620+math.cos(ang2)*47},{500+math.sin(ang2)*35} Z',palette if j%2 else '#c4aa68','#aaa578',1)
 a.ellipse(620,500,108,82,'none','#ae985c',3)
 a.save('floor_'+name)

def prop(name):
 a=art(240,280);base.shadow(a,120,255,76)
 if name=='throne':
  a.path('M40,233 L47,45 L76,30 L89,17 L120,3 L149,17 L162,30 L193,45 L199,233 Z','url(#gold)',I,3)
  a.path('M69,192 L70,65 Q120,32 170,65 L172,193 Z','url(#velvet)','#f5db91',4)
  for y in [80,116,153]:
   for x in [90,120,150]:a.ellipse(x,y,3,3,'#e6c778',I,1)
  a.path('M32,185 L71,168 L76,231 L40,243 Z','url(#gold)',I,3);a.path('M167,168 L207,185 L199,243 L162,231 Z','url(#gold)',I,3)
  a.ellipse(120,206,62,23,'url(#velvet)','#e1bf79',4)
  a.path('M55,236 l-6,30 l15,0 l9,-30 M165,236 l9,30 l15,0 l-6,-30','url(#gold)',I,2)
  crest(a,120,42,0.78)
 elif name=='column':
  a.ellipse(120,255,74,18,'#b3af91',I,3)
  a.rect(67,231,106,22,'url(#ivory)',I,2,5)
  a.path('M84,224 L81,55 L159,55 L157,224 Z','url(#ivory)',I,3)
  for x in [95,109,124,139]:a.line(x,68,x,216,'#b4b399',3)
  a.rect(73,210,94,17,'url(#gold)',I,2,3)
  a.ellipse(120,53,59,17,'url(#ivory)',I,3)
  a.ellipse(86,50,16,13,'url(#gold)',I,2);a.ellipse(154,50,16,13,'url(#gold)',I,2)
  a.rect(57,26,126,15,'url(#ivory)',I,3,3)
 elif name=='royal_banner':
  a.line(59,20,183,20,'#725435',6)
  a.path('M73,26 L171,26 L168,220 L122,257 L76,224 Z','url(#blue)','#e3c57f',4)
  a.path('M84,37 L160,37 L157,214 L122,242 L87,218 Z','none','#bdaa72',2)
  crest(a,122,105,1.5)
  for x in range(90,159,9):a.line(x,221,x,233,'#c7ad69',1)
 elif name=='chandelier':
  a.line(120,5,120,70,'#d8b66d',4)
  a.ellipse(120,170,112,97,'url(#light)')
  a.path('M120,70 L120,182 M57,154 Q69,199 120,189 Q176,197 187,153','none','#806c44',8)
  a.ellipse(120,146,84,25,'none','#e3c87e',7)
  a.ellipse(120,158,62,18,'none','#a8894f',4)
  for x,y in [(36,128),(75,153),(120,158),(167,154),(205,127)]:
   a.rect(x-5,y,10,32,'#fff1c7','#b2975f',1,2)
   a.path(f'M{x},{y-12} q-8,9 0,12 q9,-4 0,-12 Z','#ffdb82','#c3a765',1)
   a.ellipse(x,y+44,5,7,'#cce4dc','#bc9d5a',1)
  a.ellipse(120,206,13,18,'#d9e5d4','#bca05e',2)
 elif name=='statue':
  a.rect(53,222,134,32,'url(#ivory)',I,3,5)
  a.rect(71,200,98,24,'url(#gold)',I,2,3)
  a.path('M85,187 L91,99 L80,68 L110,56 L153,62 L162,99 L146,188 Z','url(#ivory)',I,3)
  a.ellipse(123,42,24,30,'url(#ivory)',I,2)
  a.path('M101,27 L106,13 L137,13 L147,28','url(#gold)',I,2)
  a.path('M89,92 L57,122 L60,158 M155,89 L180,125 L177,157','none','#d6ceb0',14)
  a.path('M76,185 L156,185 L149,202 L88,202 Z','url(#ivory)',I,2)
  a.path('M158,82 l15,114 M165,94 l18,0','none','#a59467',5)
 elif name=='royal_bed':
  a.path('M35,90 L43,243 L198,243 L206,90 Z','url(#gold)',I,3)
  a.rect(37,23,167,67,'url(#ivory)','#c8a56a',4,12)
  crest(a,121,47,.65)
  a.rect(52,84,141,130,'#eee7d0','#b49d67',2,12)
  for x in [60,130]:a.rect(x,87,58,43,'#faf2dd','#bba979',1.5,9)
  a.rect(54,136,138,92,'url(#blue)','#dfc788',3,4)
  for y in [149,161,209]:a.line(65,y,181,y,'#aec0af',2)
  for x in [32,203]:
   a.rect(x,38,9,207,'url(#gold)',I,2,3)
   a.ellipse(x+4,25,9,13,'#e8c984',I,1)
  a.path('M23,28 Q120,4 216,28 L210,64 Q120,38 29,64 Z','url(#velvet)','#e4bd76',3)
 elif name=='royal_sofa':
  a.rect(28,80,190,111,'url(#gold)',I,3,17)
  a.rect(43,91,160,79,'url(#velvet)','#e7c984',2,12)
  for x in [63,99,139,178]:a.ellipse(x,124,3,3,'#cfb77d')
  a.ellipse(120,194,80,25,'url(#velvet)','#dac48a',3)
  for x in [21,198]:a.rect(x,146,27,75,'url(#gold)',I,2,9)
  for x in [43,183]:a.path(f'M{x},220 l-5,36 l13,0 l5,-35','url(#gold)',I,2)
 elif name=='banquet_table':
  for x in [42,175]:a.rect(x,189,19,70,'url(#gold)',I,2,5)
  a.path('M20,72 L213,72 L223,208 L20,208 Z','url(#ivory)','#c8aa6e',4)
  a.rect(35,88,170,103,'#f5edda','#d9c594',2,3)
  a.rect(94,82,50,116,'url(#velvet)','#c9b273',2,2)
  for x in [59,174]:
   for y in [108,153,184]:
    a.ellipse(x,y,18,11,'#fffae6','#bba76d',2)
    a.ellipse(x,y,12,6,'#c1a66a','#e9d9aa',1)
    a.line(x-24,y-8,x-24,y+9,'#948960',2)
  for y in [102,159]:
   a.path(f'M116,{y} l-5,14 l16,0 l-5,-14 Z','#91b4ae',I,1)
   a.ellipse(119,y,8,5,'#dfe4cb','#c8b37a',1)
  a.ellipse(122,143,25,15,'#bd9861',I,1)
  for x,y in [(111,136),(130,134),(122,147)]:a.ellipse(x,y,7,6,'#9a6451','#c9a16d',1)
 elif name=='royal_bookcase':
  a.rect(26,16,189,234,'#6e5942','#c2a268',4,6)
  a.path('M20,18 Q120,-8 221,18 L215,39 L26,39 Z','url(#gold)',I,2)
  rng=random.Random(23)
  for y in [92,155,215]:
   for x in range(40,202,17):
    h=rng.randint(30,44);a.rect(x,y-h,13,h,rng.choice(['#567d81','#a16b62','#7c8060','#b59965']),I,1,2)
    a.line(x+3,y-8,x+10,y-8,'#e4ce8c',2)
   a.rect(32,y+4,176,9,'url(#gold)',I,1)
 elif name=='portrait':
  a.rect(25,20,190,227,'url(#gold)',I,3,9)
  a.rect(39,33,161,199,'url(#blue)','#ffe9ae',2,5)
  a.path('M56,220 Q56,148 119,135 Q183,145 187,220 Z','url(#velvet)',I,3)
  a.ellipse(120,102,34,44,'#d9bb8d',I,2)
  a.path('M86,102 Q82,54 122,58 Q156,57 155,103 L145,81 L111,73 L95,91 Z','#676252',I,2)
  a.path('M94,64 L90,43 L106,51 L120,29 L132,50 L149,43 L146,63 Z','url(#gold)',I,2)
  a.ellipse(110,103,3,3,'#34473e');a.ellipse(133,103,3,3,'#34473e')
  a.path('M113,124 q9,5 17,-1','none','#916749',2)
  a.path('M75,163 L113,194 L162,160','none','#dcc590',5)
 elif name=='royal_vase':
  a.path('M72,132 Q62,158 71,203 Q120,238 171,201 Q179,157 164,132 L164,116 L76,116 Z','url(#ivory)','#b39965',3)
  a.ellipse(120,121,47,14,'url(#gold)',I,2)
  a.path('M77,157 Q120,177 167,156 M76,190 Q120,213 166,190','none','#bea36c',4)
  for x,y in [(74,80),(102,53),(143,58),(172,86),(117,100)]:
   a.path(f'M120,121 Q{x+15},{y+16} {x},{y}','none','#70865b',4)
   a.ellipse(x,y,17,12,'#cfae7a','#81754e',1)
   for ang in range(5):
    a.ellipse(x+math.cos(ang*1.26)*10,y+math.sin(ang*1.26)*9,8,6,'#ead8ad','#bfac7b',.6)
   a.ellipse(x,y,4,4,'#b89b55')
 elif name=='royal_desk':
  a.path('M26,135 L31,247 L72,247 L80,143 M166,140 L176,247 L215,247 L219,133','url(#ivory)','#bd9d60',3)
  a.path('M15,106 L206,91 L229,136 L26,151 Z','url(#gold)',I,3)
  a.path('M61,109 L130,103 L143,128 L69,133 Z','#f9efce','#a6976b',1)
  for y in [114,120,126]:a.line(76,y,125,y-4,'#9e9777',1)
  a.path('M161,128 l12,-31 l13,-8 l-6,15 l-18,24 Z','#d4ddd1',I,1)
  a.rect(162,128,14,10,'#365860',I,1,2)
 elif name=='royal_guard' or name=='king':
  a.path('M91,202 L88,253 L108,257 L121,203 M123,203 L131,257 L153,255 L149,201 Z','#3f4b4c',I,3)
  a.path('M75,114 Q50,153 65,223 L177,224 Q192,150 161,114 Z','url(#velvet)' if name=='king' else 'url(#blue)',I,3)
  a.path('M86,135 L85,208 L157,208 L151,135 Z','url(#gold)' if name=='king' else 'url(#ivory)',I,2)
  a.ellipse(120,84,29,37,'#dcbc8a',I,2.5)
  a.path('M91,84 Q87,42 123,46 Q153,47 150,82 L140,64 L108,59 L97,75 Z','#74644a',I,2)
  a.ellipse(110,86,3,3,'#34473e');a.ellipse(131,86,3,3,'#34473e')
  a.path('M110,105 q12,6 22,-1','none','#95684d',2)
  if name=='king':
   a.path('M92,58 L89,32 L107,42 L120,19 L135,41 L152,30 L147,58 Z','url(#gold)',I,2)
   a.path('M84,119 Q121,151 158,119','none','#ece2bd',9)
   a.ellipse(122,149,7,9,'#7499a1','#c5ae67',2)
  else:
   a.path('M92,77 Q84,39 120,35 Q157,36 149,77 L145,57 L97,57 Z','url(#ivory)',I,2)
   a.path('M178,103 l0,141','none','#d5bd8f',5)
   a.path('M171,108 L178,78 L186,108 Z','url(#ivory)',I,2)
 a.save(name)

def rug():
 a=art(300,600)
 a.rect(12,10,276,574,'url(#velvet)','#e9cc87',4,6)
 for n in [22,31]:a.rect(n,20+n/2,300-n*2,546-n,'none','#c7ac71',2,4)
 for y in range(55,555,57):
  for x in [49,250]:
   a.path(f'M{x},{y-12} l9,12 l-9,12 l-9,-12 Z','#c4a36a','none')
   a.path(f'M{x},{y} q18,-12 21,6 m-20,0 q-15,16 -19,-2','none','#ae9060',1)
 crest(a,150,290,2)
 for x in range(21,280,10):a.line(x,585,x,598,'#d9bb7c',2)
 a.save('royal_runner')

def main():
 exterior()
 for name,pal in [('throne','#779084'),('vestibule','#647b83'),('banquet','#84615e'),('library','#61787c'),('bedroom','#637b89'),('gallery','#75867b'),('council','#6f7b71'),('honor','#7d7861')]:floor(name,pal)
 for name in ['throne','column','royal_banner','chandelier','statue','royal_bed','royal_sofa','banquet_table','royal_bookcase','portrait','royal_vase','royal_desk','royal_guard','king']:prop(name)
 rug()
 entries=[{'file':p.name,'status':'MODELED_PENDING_GATE','sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(OUT.glob('*.svg'))]
 (OUT/'manifest.json').write_text(json.dumps({'style':'2D Cartoon','generator':'game/tools/cartoon/build_royal_castle_assets.py','assets':entries},ensure_ascii=False,indent=2)+'\n')
 print('Generated',len(entries),'original royal castle assets')
if __name__=='__main__':main()
