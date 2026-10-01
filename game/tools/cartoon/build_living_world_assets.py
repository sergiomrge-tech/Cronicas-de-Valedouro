"""Original Cartoon furniture, rooms, people and wildlife; deterministic SVG source."""
from pathlib import Path
import hashlib,json,random
import build_visual_assets as base
OUT=Path(__file__).resolve().parents[2]/'assets/cartoon/v022'
base.OUT=OUT
Art=base.Art
I=base.INK

def art(w,h):
 a=Art(w,h)
 a.parts.append('''<defs><linearGradient id="wood" x2=".2" y2="1"><stop stop-color="#be8751"/><stop offset="1" stop-color="#684832"/></linearGradient><linearGradient id="metal" x2=".6" y2="1"><stop stop-color="#a3b4b0"/><stop offset=".5" stop-color="#586d70"/><stop offset="1" stop-color="#2d424a"/></linearGradient><radialGradient id="glow"><stop stop-color="#ffdd80" stop-opacity=".6"/><stop offset="1" stop-color="#ee7b42" stop-opacity="0"/></radialGradient></defs>''')
 return a

def room(kind):
 a=art(1440,1000);a.rect(0,0,1440,1000,'#182523','none')
 a.rect(28,72,1384,872,'#27302a',I,3,12)
 a.rect(55,116,1330,808,'#796342' if kind!='forge' else '#777b69',I,4)
 rng=random.Random(22)
 if kind=='forge':
  for y in range(125,920,52):
   for x in range(58,1380,82):
    a.rect(x+(40 if (y//52)%2 else 0),y,78,47,rng.choice(['#777c70','#858775','#93937e','#6a7268']), '#626b61',1.5,4)
 else:
  for y in range(125,918,34):
   for x in range(58,1380,180):
    offset=90 if (y//34)%2 else 0
    xx=x+offset
    if xx+175>1385:continue
    a.rect(xx,y,175,31,rng.choice(['#99754d','#a68155','#8b6945','#ae8759']), '#674e37',1,2)
    a.path(f'M{xx+12},{y+8} q44,-3 83,1 m-75,14 q57,4 141,-2','none','#c09a61',1)
    a.ellipse(xx+120,y+19,9,2,'none','#785339',1)
 a.rect(28,30,1384,108,'url(#wood)',I,4,8)
 for x in range(48,1400,160):
  a.rect(x,34,146,78,'#90794f' if kind=='tavern' else '#697d72',I,1.5,4)
  a.line(x+4,108,x+136,108,'#c3ae78',2)
 for x in [56,1330]:
  a.rect(x,130,52,750,'url(#wood)',I,3,5)
  for y in range(153,860,116):a.line(x+6,y,x+46,y-10,'#cc9960',2)
 a.rect(109,139,1220,26,'#3c3d30','none')
 for x in [250,1100]:
  a.rect(x,52,102,96,'#3b4c46',I,4,8);a.rect(x+9,60,84,70,'#a4c3b4','#d4bf88',3,5)
  a.line(x+51,60,x+51,130,'#d4bf88',5);a.line(x+9,90,x+93,90,'#d4bf88',4)
  a.path(f'M{x+12},139 L{x-38},410 L{x+132},365 L{x+92},139 Z','#f3dfaa','none',extra='fill-opacity=".07"')
 # Open threshold visibly tied to the external building.
 a.rect(620,890,200,54,'#4e5a4c',I,3,4)
 for x in range(624,818,22):a.line(x,895,x,940,'#a6aa8a',2)
 a.rect(636,859,168,27,'#ccb16d','#6d583a',2,4)
 a.path('M690,880 l30,0 l-8,7 m8,-7 l-8,-7','none','#f0dfab',3)
 a.save('room_'+kind)

def furniture(name):
 a=art(230,210);base.shadow(a,115,187,80)
 if name=='table':
  for x in [46,174]:a.path(f'M{x},116 l-5, sixty'.replace('sixty','60')+f' l15,0 l6,-60 Z','url(#wood)',I,2)
  a.ellipse(114,128,99,43,'#63452f',I,3);a.ellipse(114,113,99,43,'url(#wood)',I,3)
  for y in [88,106,125]:a.path(f'M34,{y} q80,9 163,0','none','#d6a66c',2)
  a.ellipse(90,101,17,10,'#ebe0bf',I,1);a.ellipse(91,99,9,5,'#af6e3d')
  for x,y in [(130,104),(73,121)]:a.rect(x,y,11,14,'#d4b883',I,1,3);a.ellipse(x+6,y,5,3,'#55392c')
  a.ellipse(143,128,17,8,'#c8a570',I,1);a.path('M133,126 q8,-17 21,0','#be763a',I,1)
 elif name=='chair':
  a.rect(70,48,86,72,'url(#wood)',I,3,7)
  for x in [84,105,126,147]:a.line(x,58,x,108,'#e0ad6f',3)
  a.path('M66,132 L73,190 L86,190 L84,130 M143,130 L151,190 L164,190 L158,132','url(#wood)',I,3)
  a.ellipse(113,128,53,20,'url(#wood)',I,3);a.ellipse(113,120,48,15,'#53756b',I,2)
 elif name in ['counter','workbench']:
  a.rect(20,89,190,96,'url(#wood)',I,3,4)
  for x in range(24,206,31):a.rect(x,105,27,70,'#8f6240','#533d2e',1,3)
  a.path('M12,70 L198,64 L221,86 L22,94 Z','#d0a375',I,3)
  a.line(23,83,200,77,'#edcd92',2)
  if name=='counter':
   for x in [46,65,113,131,155]:a.rect(x,49,11,26,'#547d69',I,1,3);a.rect(x+3,41,5,12,'#709780',I,1,1)
  else:
   a.path('M51,62 l19,-28 l8,5 l-19,28 Z','url(#metal)',I,2);a.rect(84,48,53,13,'url(#metal)',I,2,2)
   a.path('M165,67 l-3,-27 l12,-5 l10,8 l-5,15 Z','#9f774e',I,2)
 elif name=='board':
  a.rect(32,8,168,162,'url(#wood)',I,4,7);a.rect(43,19,146,136,'#56422f',I,2,3)
  for x,y,rot in [(52,30,-5),(117,27,4),(67,92,5),(132,93,-6)]:
   a.parts.append(f'<g transform="rotate({rot} {x} {y})">');a.path(f'M{x},{y} l47,0 l-2,53 l-43,4 Z','#eee2b5',I,1)
   a.ellipse(x+22,y+4,3,3,'#b15f47',I,1)
   for i in range(4):a.line(x+7,y+15+i*7,x+34-(i%2)*8,y+15+i*7,'#958865',1)
   a.parts.append('</g>')
  a.path('M48,170 l-5,25 l15,0 l4,-25 M168,170 l2,25 l15,0 l-3,-25','url(#wood)',I,3)
 elif name=='bookshelf':
  a.rect(41,8,150,177,'url(#wood)',I,3,4)
  rng=random.Random(18)
  for y in [53,103,153]:
   for x in range(53,182,15):
    h=rng.randrange(27,40);a.rect(x,y-h,11,h,rng.choice(['#717d68','#a7714d','#496b78','#b69758','#925e68']),I,1,2);a.line(x+2,y-7,x+9,y-7,'#d0ba82',1)
   a.rect(44,y+3,143,7,'#d4a16c',I,1)
 elif name in ['furnace','fireplace']:
  a.path('M40,177 L34,83 L60,42 L171,42 L197,82 L190,178 Z','#77796a',I,4)
  for y in [51,78,106,140]:
   for x in [47,84,121,158]:a.rect(x+(12 if y%2 else 0),y,32,21,'#939481','#5e665c',1,3)
  a.path('M63,173 L64,111 Q114,50 166,111 L166,173 Z','#26332f',I,3)
  a.ellipse(115,151,84,60,'url(#glow)')
  a.path('M74,168 Q64,147 88,129 Q87,149 111,103 Q109,141 137,124 Q160,155 154,168 Z','#d76d36',I,1)
  a.path('M93,164 Q91,140 112,126 Q106,147 132,137 L141,164 Z','#ffc566','none')
  a.rect(31,174,166,18,'#b6b093',I,3,4)
 elif name=='anvil':
  a.path('M76,140 L67,189 L162,189 L151,139 Z','url(#wood)',I,3)
  a.path('M21,83 L179,77 L205,91 L159,107 L140,137 L78,140 L66,110 L26,104 Z','url(#metal)',I,4)
  a.path('M40,84 L169,81 L187,89 L45,94 Z','#b4c4bb',I,1)
  a.path('M85,127 L130,124 L150,147 L68,148 Z','#556b6b',I,2)
 elif name=='weapon_rack':
  a.path('M37,179 L44,20 L58,20 L53,179 M177,179 L172,20 L186,20 L195,179','url(#wood)',I,3)
  a.rect(42,47,142,13,'url(#wood)',I,2,2);a.rect(40,146,151,12,'url(#wood)',I,2,2)
  for x in [68,105,142]:
   a.path(f'M{x},129 l-5,-77 l5,-22 l6,22 l-1,77 Z','url(#metal)',I,1.5)
   a.line(x-12,125,x+12,125,'#c2a360',5);a.line(x,129,x,148,'#785037',5)
 elif name=='bed':
  a.path('M39,52 L51,188 L179,188 L190,52 Z','url(#wood)',I,3)
  a.rect(46,43,140,36,'url(#wood)',I,3,5);a.rect(57,80,119,89,'#d1c49c',I,2,9)
  a.rect(64,79,102,31,'#f0e7c9',I,2,9);a.rect(58,113,118,63,'#637d7c',I,2,5)
  a.line(65,125,166,125,'#b8b996',3);a.line(65,136,165,136,'#8fa39b',1.5)
 elif name=='plant':
  a.path('M72,131 L83,185 L147,185 L159,131 Z','#ad7049',I,3);a.ellipse(115,132,43,13,'#d8a16a',I,2)
  for x,y in [(77,73),(109,46),(137,66),(147,106),(93,105)]:
   a.path(f'M115,136 Q{x},{y+10} {x},{y}','none','#537655',4)
   a.ellipse(x,y,20,10,'#799356',I,1)
 elif name=='crates':
  for x,y,w,h in [(25,100,90,80),(108,75,96,105),(64,22,88,61)]:
   a.rect(x,y,w,h,'url(#wood)',I,2,4)
   a.rect(x+8,y+8,w-16,h-16,'#b08251','#5f4531',1,2)
   a.line(x+8,y+8,x+w-8,y+h-8,'#deb27a',8)
   for xx,yy in [(x+6,y+6),(x+w-6,y+6),(x+6,y+h-6),(x+w-6,y+h-6)]:a.ellipse(xx,yy,2,2,'#45493c')
 elif name=='cask':
  base.barrel(a,115,177,3.3)
  a.ellipse(114,141,8,8,'#b8b9a2',I,2);a.path('M114,143 l0,15 l14,0','none','#6a7874',5)
 elif name=='coal':
  a.path('M27,130 L201,123 L187,184 L43,189 Z','url(#wood)',I,3)
  for x,y in [(54,121),(87,111),(127,109),(165,120),(79,138),(124,137),(162,140)]:
   a.path(f'M{x-17},{y} l10,-16 l19,4 l8,15 l-22,12 Z','#3e4e4b',I,2)
   a.path(f'M{x-9},{y-6} l11,-6 l8,5','none','#657169',2)
 elif name=='wall_map':
  a.rect(27,16,180,162,'url(#wood)',I,3,6)
  a.path('M39,29 L195,25 L189,161 L44,165 Z','#e3d1a0',I,2)
  a.path('M89,36 Q159,58 110,82 T135,155','none','#84a9a0',7)
  a.path('M56,52 L83,80 L64,115 L146,130 L179,102','none','#ac8254',3)
  for x,y in [(58,51),(82,80),(66,114),(146,130),(179,102)]:a.ellipse(x,y,5,5,'#95634d',I,1)
  for x,y in [(135,44),(156,50),(143,66),(72,138)]:a.path(f'M{x-7},{y+8} l7,-13 l9,13 Z','#91a080','#788772',1)
 elif name=='banner':
  a.line(66,16,170,16,'#674d35',7)
  a.path('M75,20 L160,20 L161,148 L118,180 L74,151 Z','#4d7386',I,3)
  a.path('M83,30 L151,30 L151,143 L118,166 L83,145 Z','none','#d0b477',3)
  a.path('M116,69 L139,91 L117,125 L96,91 Z','#d9bf78',I,2)
  a.path('M106,82 L117,98 L130,81','none','#546c73',2)
 elif name=='lantern':
  a.ellipse(115,114,79,81,'url(#glow)')
  a.path('M113,18 q-30,-16 -35,13 M113,18 l0,25','none','#3c5149',5)
  a.path('M77,68 L112,42 L149,69 L143,135 L83,135 Z','#9b865b',I,3)
  a.path('M86,75 L138,75 L133,124 L91,124 Z','#f1cb7a',I,2)
  a.path('M104,74 L104,124 M125,74 L125,124','none','#697062',3)
  a.path('M102,113 Q99,103 112,92 Q121,109 116,114 Z','#ffe7a2','none')
  a.rect(80,132,64,10,'#737e6c',I,2,3)
 elif name=='rug':
  a.path('M15,27 L200,23 L218,181 L22,187 Z','#92544d',I,2)
  a.path('M28,39 L187,36 L201,170 L35,174 Z','none','#d1ae6b',4)
  a.path('M116,49 L167,105 L116,162 L66,107 Z','#c2a267',I,2)
  a.path('M116,70 L148,106 L116,142 L84,107 Z','#557369',I,1)
  for x in range(22,212,10):a.line(x,185,x,197,'#d9bb7c',2)
 a.save(name)

def person(name,shirt,hair):
 a=art(90,125);base.shadow(a,46,111,26)
 a.path('M30,87 L28,109 L40,112 L46,88 M49,88 L54,111 L67,110 L60,86','#35483f',I,2.5)
 a.path('M26,53 Q15,64 21,90 L68,91 Q77,66 62,54 Z',shirt,I,2.5)
 a.path('M30,68 L26,91 L65,92 L61,68 Z','#d5b888' if name=='innkeeper' else shirt,I,1.5)
 a.line(45,68,45,92,'#a6895a',1.5)
 a.path('M22,60 L12,81 L21,86 L30,68 M63,62 L77,81 L70,88 L60,71','#d9b38b',I,2)
 a.ellipse(44,39,19,23,'#e2bc8e',I,2.5)
 a.path('M24,40 Q20,14 44,13 Q68,14 65,40 L59,30 L44,24 L31,29 Z',hair,I,2)
 a.ellipse(38,40,2,2,'#263d36');a.ellipse(51,40,2,2,'#263d36');a.path('M39,50 q6,4 12,-1','none','#8e5e46',1.5)
 if name=='smith':a.path('M26,81 L31,59 L59,58 L64,85 Z','#665348',I,1.5);a.path('M31,51 Q45,69 58,51 L52,59 L39,61 Z',hair,I,1)
 if name=='clerk':a.rect(51,70,24,21,'#d3bf86',I,2,2);a.line(56,76,69,76,'#8c8262',1)
 a.save('npc_'+name)

def animal(kind,step=0):
 a=art(150,115);base.shadow(a,75,101,43)
 colors={'deer':('#aa7850','#ecd3a2'),'boar':('#786958','#b29c7a'),'rabbit':('#c5baa2','#ece0c1')};fur,belly=colors[kind]
 if kind=='rabbit':
  a.ellipse(71,78,34,24,fur,I,2);a.ellipse(105,73,20,21,fur,I,2)
  a.path('M96,59 Q78,10 92,15 Q104,21 104,54 Z',fur,I,2);a.path('M108,57 Q110,11 122,16 Q130,25 118,62 Z',fur,I,2)
  a.path('M94,48 L90,27 M116,48 L119,28','none','#c89584',4)
  a.ellipse(43,78,12,13,belly,I,1.5);a.ellipse(73+step,97,19,6,fur,I,1.5);a.ellipse(117-step,98,12,5,fur,I,1.5)
  a.ellipse(116,70,3,3,'#25332f');a.ellipse(125,81,3,2,'#9e7167')
 else:
  for x in [46,72,98,115]:
   s=step if x in [46,98] else -step
   a.path(f'M{x},75 L{x+s-4},101 L{x+s+6},102 L{x+8},75 Z',fur,I,2)
   a.line(x+s-3,101,x+s+6,101,'#384239',4)
  a.ellipse(72,64,45,19 if kind=='deer' else 26,fur,I,2.5);a.ellipse(75,70,31,10 if kind=='deer' else 16,belly,'none')
  if kind=='deer':
   a.path('M103,70 Q92,52 108,29 L122,27 L131,61 Z',fur,I,2)
   a.ellipse(124,31,19,13,fur,I,2);a.ellipse(137,34,4,3,'#36443d');a.ellipse(126,26,2.5,2.5,'#26372f')
   a.path('M111,23 L99,16 L110,13 L117,22 M123,20 L136,9 L138,18 L129,25',fur,I,1.5)
   a.path('M118,17 L113,2 M114,10 L104,4 M115,8 L125,2','none','#d8c091',3)
   a.path('M28,61 l-10,-12 l-2,15',belly,I,2)
   for x,y in [(42,54),(55,48),(69,51),(82,49)]:a.ellipse(x,y,3,2,'#f5dbab')
  else:
   a.ellipse(119,70,24,20,fur,I,2);a.ellipse(139,76,9,7,'#aa8c72',I,1.5)
   a.ellipse(130,65,2.5,2.5,'#26372f');a.path('M108,57 l-3,-15 l15,11 Z',fur,I,2)
   a.path('M129,85 q-1,12 9,2','#ece0b5',I,1)
   a.path('M32,56 l5,-8 l7,4 l9,-8 l7,5 l6,-8 l8,7','none','#403f37',3)
   a.path('M29,66 q-20,-9 -15,6 q8,9 10,-1','none',fur,3)
 # Layered coat, highlights and readable face at game scale.
 if kind=='rabbit':
  a.path('M52,70 Q68,55 86,65 M60,80 q12,-6 23,-2','none','#ded4b5',2)
  a.path('M115,85 q7,3 12,-1 M120,88 l9,3 m-8,-7 l12,-2','none','#817a67',1)
  a.ellipse(116,69,1,1,'#fff6db')
 else:
  a.path('M41,57 Q65,41 91,51 M47,59 q15,-7 29,-5','none','#ceb48a' if kind=='deer' else '#a99a7e',2)
  a.path('M38,79 q24,12 51,3','none','#81694f' if kind=='deer' else '#595648',2)
  a.ellipse(125 if kind=='deer' else 129,25 if kind=='deer' else 64,1,1,'#fff6db')
  if kind=='deer':
   a.path('M113,48 q6,10 12,12 M110,63 l5,9','none','#cda77a',2)
   a.path('M124,36 q6,5 11,2','none','#70553f',1)
  else:
   for x in [47,57,68,80]:a.path(f'M{x},53 l-3,8','none','#514f43',1.5)
 a.save('animal_'+kind+('_walk' if step else ''))

def main():
 for k in ['tavern','forge','guild']:room(k)
 for k in ['table','chair','counter','workbench','board','bookshelf','furnace','fireplace','anvil','weapon_rack','bed','plant','rug','crates','cask','coal','wall_map','banner','lantern']:furniture(k)
 for n,s,h in [('innkeeper','#648479','#644631'),('smith','#a56745','#443f33'),('clerk','#516d85','#a99b73'),('patron','#898a55','#655a43'),('ranger','#637349','#854d36')]:person(n,s,h)
 for k in ['deer','boar','rabbit']:animal(k);animal(k,5)
 entries=[{'file':p.name,'status':'MODELED_PENDING_GATE','sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(OUT.glob('*.svg'))]
 (OUT/'manifest.json').write_text(json.dumps({'style':'2D Cartoon','generator':'game/tools/cartoon/build_living_world_assets.py','assets':entries},ensure_ascii=False,indent=2)+'\n')
 print('Generated',len(entries),'original living-world assets')
if __name__=='__main__':main()
