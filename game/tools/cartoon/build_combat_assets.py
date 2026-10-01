"""Original detailed, directional animation sheets for Cartoon v0.24."""
from pathlib import Path
import math, json, hashlib
import build_visual_assets as base
from build_visual_assets import Art
OUT=Path(__file__).resolve().parents[2]/'assets/cartoon/v024'
base.OUT=OUT
STATES={'idle':4,'walk':8,'attack':6,'cast':8,'hurt':4,'death':8}
PALETTES={
 'wolf':('#71889e','#b7ccdb','#ffc75d'),
 'goblin':('#73983e','#b7d65c','#ffbb59'),
 'slime':('#1cadb0','#85f4d0','#ffdf80'),
 'guardian':('#648899','#b2d6d3','#60ffcc'),
 'root_beast':('#79563d','#b5b56a','#81ff96'),
 'ash_general':('#863d58','#df7870','#ffb536'),
 'reed_lady':('#38796f','#9cd1ad','#b0ff67'),
 'frost_captain':('#3667a4','#b9e6f3','#7ef6ff'),
 'black_frost_general':('#454a7f','#94b7dd','#c6a1ff'),
 'tide_general':('#267b92','#76ddd9','#83fbff'),
 'void_general':('#594385','#b983d9','#ef8eff'),
 'void_cartographer':('#415193','#aaa0e6','#e8cbff'),
 'azharel':('#6c325e','#dd6f90','#ffc359')}

def hero(a,direction,state,i,count):
 t=i/count*math.tau
 step=math.sin(t)*10 if state=='walk' else 0
 sway=math.sin(t)*3
 bob=abs(math.sin(t))*2 if state=='walk' else math.sin(t)*1.2
 if state=='hurt': sway=-5*(1-i/count)
 if state=='death':
  a.parts.append(f'<g transform="translate(64 141) rotate({min(88,i*13)}) translate(-64 -141)" opacity="{1-i/count*.8}">')
 a.parts.append(f'<g transform="translate({sway*.35:.2f} {-bob:.2f})">')
 # Closed, gold stitched cape, swaying continuously, different back view.
 cape='#273889' if direction=='back' else '#3657b6'
 a.path(f'M44,59 Q64,49 84,59 L{97+sway:.1f},128 Q75,146 {30+sway:.1f},129 Z',cape,'#172f57',2)
 a.path(f'M44,61 Q43,95 {37+sway:.1f},129 Q67,139 {90+sway:.1f},128', 'none','#edc06a',2)
 for x in [49,59,74]: a.path(f'M{x},70 Q{x-4},102 {x+sway*.7},131','none','#5d80d2',1.2)
 if direction=='back':
  a.path('M59,85 L68,80 L74,88 L66,105 L57,89 Z','#ead393','#a67a45',1)
  a.path('M61,89 l4,9 l5,-10','none','#74d7e9',2)
 # Boots, articulated knee and shin plates, leather straps and laces.
 for x,sgn in [(47,-1),(70,1)]:
  foot=step*sgn
  a.parts.append(f'<g transform="translate(0 {foot:.1f})">')
  a.path(f'M{x},99 l17,0 l-1,35 l6,9 q-12,8 -25,1 l3,-14 Z','#293c55','#142c3d',2)
  a.path(f'M{x+1},104 l12,-1 l-1,21 l-13,1 Z','#8cb4cc','#243b58',1.5)
  a.path(f'M{x},109 l12,-2 m-13,8 l12,-2','none','#dbe8e4',1)
  a.rect(x-2,129,18,6,'#b77941','#49342e',1,2)
  a.path(f'M{x-1},142 l22,0','none','#d7a968',2)
  for y in [135,138]: a.line(x+4,y,x+12,y,'#edcc8c',1)
  a.parts.append('</g>')
 # Segmented breastplate and layered blue tabard.
 a.path('M44,62 Q64,51 84,62 L82,101 L68,114 L46,104 Z','#337fbc','#183650',2)
 a.path('M47,66 L64,60 L79,67 L75,83 L65,94 L49,83 Z','#8bcce1','#20476b',1.5)
 a.path('M48,66 L62,62 L60,84 L49,80 Z','#d0edf0','none')
 a.path('M68,64 L78,68 L74,80 L67,88 Z','#3b96c4','none')
 a.path('M46,87 L65,94 L81,87 L80,102 L65,110 L47,101 Z','#234f94','#193950',1)
 for x in [52,59,69,76]: a.line(x,96,x-1,105,'#759cd4',1)
 a.rect(44,89,40,7,'#775036','#283441',1,2)
 a.rect(60,88,10,10,'#f4cb68','#8a6345',1,2)
 a.ellipse(65,92,2,2,'#51e9e0')
 a.rect(77,93,8,12,'#ab7547','#453b36',1,2)
 a.line(79,97,82,97,'#efd5a0',1)
 # Shoulder plates, bent arms, fingered gauntlets; casting extends an arm.
 for x,sgn in [(36,-1),(84,1)]:
  arm=step*.35*sgn
  if state=='cast':arm=-24-8*math.sin(i/count*math.pi)
  elif state=='attack' and sgn==( -1 if direction=='left' else 1):arm=-20+35*math.sin(i/count*math.pi)
  a.parts.append(f'<g transform="rotate({arm:.1f} {x+7} 67)">')
  a.path(f'M{x},67 l14,-2 l6,24 l-6,15 l-13,-3 l-5,-15 Z','#315676','#183348',1.5)
  a.path(f'M{x-4},61 q10,-14 23,0 l-3,12 l-18,0 Z','#8cb9d3','#244663',2)
  a.path(f'M{x-3},63 q9,-9 19,0','none','#edcb7b',2)
  a.path(f'M{x-1},81 l15,-2 l-1,11 l-13,2 Z','#bfd7e1','#355b71',1)
  a.path(f'M{x},93 l13,-1 l4,10 l-12,7 l-8,-5 Z','#a47b58','#3e3b36',1)
  for off in [3,6,9]:a.line(x+off,98,x+off+1,104,'#e6c99c',1)
  a.parts.append('</g>')
 # Neck, ear and face features; never mirror the light source.
 a.rect(56,49,17,13,'#c58b60','#684638',1,4)
 a.ellipse(64,38,21,24,'#efc294','#623e34',1.8)
 a.ellipse(48,40,4,6,'#d59d76','#694b3d',1)
 a.ellipse(81,40,4,6,'#d59d76','#694b3d',1)
 if direction=='back':
  a.path('M42,42 Q36,15 56,12 Q84,5 87,36 L83,58 L68,61 L58,56 L48,58 Z','#8b542f','#4a382b',2)
  for x in [48,55,65,75]:a.path(f'M{x},25 q-4,18 1,26','none','#dc9e51',2)
 else:
  face=-5 if direction=='left' else (5 if direction=='right' else 0)
  a.path('M43,32 Q37,10 57,11 L67,6 L71,13 Q89,11 85,37 L77,25 L64,28 L57,21 L48,35 Z','#bc7937','#5b3d2c',2)
  a.path('M47,24 L58,15 L56,22 M62,15 l6,-3 l-2,9 M72,20 l7,-2 l1,9','none','#f3cd73',2)
  for x in ([51] if direction=='left' else ([78] if direction=='right' else [55,72])):
   a.path(f'M{x-4},37 q4,-3 8,0','none','#664931',1.6)
   a.ellipse(x,41,3.4,4.1,'#fff4dc','#91684a',.7)
   a.ellipse(x+1,41,1.5,2.8,'#247fa3')
   a.ellipse(x+.5,40,0.8,0.8,'#fffdf0')
  a.path(f'M{(47 if direction=="left" else (81 if direction=="right" else 64))},42 l-2,6 l4,0','none','#bc7e58',1)
  a.path(f'M{59+face},53 q5,3 10,-1','none','#945b48',1.2)
  a.path('M77,46 l3,3','none','#e29a79',1)
 a.path('M49,59 L58,57 L65,63 L72,57 L81,59 L75,66 L56,66 Z','#f4cf7b','#805b37',1)
 a.ellipse(65,64,3,3,'#39d8dc','#246d96',1)
 a.parts.append('</g>')
 if state=='death':a.parts.append('</g>')


def mob(a,kind,i,count):
 dark,light,glow=PALETTES[kind];t=i/count*math.tau
 a.parts.append(f'<g transform="translate(0 {-abs(math.sin(t))*3:.2f})">')
 if kind=='wolf':
  for x,phase in [(30,0),(52,math.pi),(79,math.pi),(99,0)]:
   dy=math.sin(t+phase)*7
   a.path(f'M{x},99 l10,-2 l{math.sin(t+phase)*4:.1f},{27+dy:.1f} l-17,2 l2,-6 Z',dark,'#263649',1.5)
  a.path('M30,91 Q9,83 8,63 Q29,70 43,87 Z',dark,'#263649',2)
  a.path('M27,81 Q42,60 81,75 L102,93 L91,110 L41,112 L26,100 Z',dark,'#263649',2)
  for x,y in [(34,86),(45,82),(56,82),(68,85)]: a.path(f'M{x},{y} l8,-7 l-2,13 l8,1 l-9,5 Z',light,'none')
  a.path('M81,91 L78,52 L84,37 L94,50 L109,34 L115,61 L118,74 L134,82 L121,94 L106,99 L101,109 Z',dark,'#263649',2)
  a.path('M91,64 L102,76 L127,84 L116,94 L99,86 Z',light,'none')
  a.path('M84,50 l1,-7 l5,10 M107,52 l3,-9 l2,12','none','#dc99a0',2)
  a.path('M97,66 l9,-2 l-3,5 l-6,0 Z',glow,'#263649',1)
  a.ellipse(101,66,1,2,'#293649');a.ellipse(128,81,4,3,'#21334c')
  a.path('M109,89 l4,5 l2,-5 m4,0 l3,4','none','#fff5d4',2)
 elif kind=='slime':
  w=42+math.sin(t)*4; h=47-math.sin(t)*5
  a.path(f'M{72-w},124 Q15,85 44,{124-h} Q73,58 102,{124-h+5} Q137,96 {72+w},124 Q72,143 {72-w},124 Z',dark,'#22586c',2)
  a.ellipse(54,91,17,9,light,'none');a.ellipse(46,87,8,4,'#e7fff0')
  for x,y in [(83,108),(97,116),(45,121)]:a.ellipse(x,y,4,3,light)
  for x in [61,84]:a.ellipse(x,107,4,6,'#164850');a.ellipse(x-1,105,1.5,2,'#e9fff1')
  a.path('M66,119 q7,5 15,-1','none','#22586c',2)
 else:
  # Detailed silhouettes, color and regalia remain individual to each enemy.
  organic=kind in ['root_beast','reed_lady','goblin']
  for x,s in [(47,-1),(79,1)]:
   dy=math.sin(t+s)*6
   a.path(f'M{x},{98+dy} l16,0 l3,31 l7,6 l-28,1 Z',dark,'#25334c',2)
   a.path(f'M{x+2},{108+dy} l12,-2 l-1,16 l-12,2 Z',light,'#25334c',1)
  a.path('M44,65 L73,57 L101,67 L99,108 L75,119 L47,110 Z',dark,'#25334c',2)
  a.path('M49,71 L73,66 L93,73 L87,88 L75,99 L54,88 Z',light,'#25334c',1.5)
  a.path('M58,80 L73,75 L83,82 L73,93 Z',dark,'#d7b985',1)
  a.ellipse(73,84,4,5,glow)
  for x in [32,101]:
   a.path(f'M{x},70 l17,-5 l8,32 l-9,14 l-18,-7 l-5,-19 Z',dark,'#25334c',2)
   a.path(f'M{x-4},68 q9,-15 24,-5 l3,12 l-24,8 Z',light,'#25334c',1.5)
   for y in [87,96]:a.line(x+1,y,x+17,y-4,glow,1)
  a.path('M51,25 L76,18 L97,29 L95,54 L78,66 L54,58 L46,42 Z',light,'#25334c',2)
  a.path('M78,21 L95,31 L93,52 L80,59 Z',dark,'none')
  for x in [60,81]:a.path(f'M{x},42 l9,-2 l-1,5 l-8,1 Z',glow,'#25334c',1)
  a.path('M60,54 l23,-1','none','#25334c',2)
  if kind=='goblin':
   a.path('M49,34 L26,24 L47,49 M95,31 L118,22 L95,47',light,'#25334c',2)
   a.path('M56,56 l4,6 l3,-7 m14,0 l4,7 l3,-8','none','#fff0bb',2)
   a.path('M104,101 l12,-17 l10,-18 l5,3 l-16,37 Z','#ab814e','#25334c',1)
  elif kind in ['guardian','root_beast']:
   for x,y in [(54,29),(90,64),(42,84)]:
    a.path(f'M{x},{y} q-13,-18 -18,-9 q0,10 15,13 q-5,-20 6,-19 q10,11 -3,15', '#77aa59','#385541',1)
   a.path('M60,28 l-5,7 l5,4 M79,103 l9,-5 l-2,-6','none',glow,1.5)
  else:
   a.path('M50,28 L40,7 L61,22 L75,3 L84,24 L105,9 L97,31 Z',dark,'#25334c',2)
   a.path('M49,27 L60,25 L75,14 L87,28 L96,26','none',glow,2)
   a.path('M98,99 L119,66 L128,61 L123,77 L106,106 Z',glow,'#25334c',2)
   a.path('M33,78 Q10,61 15,45 Q35,45 43,66',dark,'#25334c',2)
   for x,y in [(40,70),(104,69),(75,23)]:a.ellipse(x,y,2,2,glow)
  # Each boss owns a distinct silhouette, beyond its elemental palette.
  if kind=='root_beast':
   a.path('M39,69 Q23,83 19,108 L8,131 L25,126 L41,103 L45,136 L57,128 L64,104 L75,139 L88,134 L84,106 L113,135 L127,132 L104,102 Q119,79 104,67 L91,79 L79,73 L66,91 L53,80 Z',dark,'#394338',2)
   for x in [38,53,76,93]:a.path(f'M{x},82 q-9,15 2,40','none','#cca776',1.5)
   a.path('M52,28 L42,5 L39,22 L25,10 L33,39 M91,27 L107,6 L102,27 L121,16 L104,40','none','#765532',7)
   for x,y in [(37,22),(109,25),(28,108),(108,100)]:a.path(f'M{x},{y} q-8,-15 8,-15 q12,11 -8,15','#87bd62','#405d38',1)
   a.path('M55,38 L63,44 L59,50 M80,40 l10,-3 l-4,10','none',glow,3)
  elif kind=='reed_lady':
   a.path(f'M54,72 Q71,60 88,71 L{109+math.sin(t)*4},132 Q73,145 36,133 Z','#255d59','#294448',2)
   for x in [52,64,78,90]:a.path(f'M{x},83 q-8,28 -6,46','none','#78bf9a',2)
   a.path('M49,28 Q73,0 99,29 L100,63 L85,56 L91,31 L75,24 L57,34 L57,60 L43,65 Z','#458a73','#294448',2)
   for x,y in [(52,24),(72,16),(91,25)]:a.path(f'M{x},{y} l-6,-12 l12,5 l-4,9 Z','#b9db8b','#335a45',1)
   a.ellipse(75,18,4,4,'#efd59d')
  elif kind=='frost_captain':
   a.path('M100,113 L120,40 L125,41 L106,117 Z','#658ba4','#24384f',1)
   a.path('M118,45 L106,31 L110,17 L120,28 L134,26 L141,42 L130,48 L125,40 Z','#c2f7ff','#47738b',1.5)
   a.path('M53,28 L52,13 L72,9 L92,15 L95,28 Z','#b1dcf2','#284467',2)
   a.line(60,17,83,17,glow,2)
  elif kind=='black_frost_general':
   a.path('M44,29 Q24,14 25,0 Q31,19 49,21 M94,24 Q115,12 116,0 Q111,25 94,34',dark,'#24384f',3)
   a.path('M35,67 L20,112 L32,128 L47,102 M104,66 L130,110 L125,130 L103,103',dark,'#24384f',2)
   for x in [26,117]:a.path(f'M{x},101 l8,8 l-4,13 l-7,-8 Z',light,'#24384f',1)
  elif kind=='tide_general':
   a.path(f'M44,64 Q17,68 12,{115+math.sin(t)*4} L30,107 L39,132 L51,104',dark,'#244b62',2)
   a.path('M53,30 L43,9 L65,19 L72,3 L81,18 L107,6 L95,31 Z',light,'#244b62',2)
   a.path('M99,109 L126,40 M118,51 L111,39 L116,27 M126,42 L127,22 M130,50 L138,37 L139,26','none',glow,3)
   for x,y in [(59,76),(70,72),(82,75)]:a.path(f'M{x},{y} q4,-3 7,1 q-3,7 -7,-1','none','#d4f5ed',1)
  elif kind in ['void_general','azharel']:
   a.path('M43,72 Q25,44 8,29 L19,69 L6,92 L30,85 L38,117 L48,96 M99,71 Q125,40 137,28 L128,70 L143,91 L117,88 L106,121 L96,99',dark,'#3b274b',2)
   for x,y in [(23,62),(126,67)]:a.path(f'M{x},{y} l7,-9 l8,21 l-14,8 Z',light,'#3b274b',1)
   if kind=='azharel':
    a.path('M44,31 L42,8 L54,20 L62,1 L74,19 L87,0 L94,20 L109,9 L104,34 Z','#e3b957','#64425b',2)
    for x in [54,72,95]:a.ellipse(x,24,2.5,3,glow)
    a.path('M54,93 L44,140 L60,130 L75,145 L94,132 L110,141 L97,95 Z','#70365e','#38273f',2)
    for x in [57,72,91]:a.line(x,105,x-2,130,'#e89c99',1.5)
  elif kind=='void_cartographer':
   a.path('M49,77 L28,132 L43,139 L74,143 L108,131 L95,75 Z',dark,'#31304f',2)
   for x in [51,68,87]:a.path(f'M{x},87 q-4,29 -10,43','none',light,1.5)
   a.path('M48,30 Q74,2 100,31 L101,59 L88,56 L87,33 L72,27 L56,37 L56,61 L43,61 Z',dark,'#31304f',2)
   a.path('M17,81 L27,69 L41,77 L39,103 L25,109 L14,102 Z','#abc0e1','#454268',1.5)
   a.path('M25,76 l0,25 M18,86 l6,-2 m3,-1 l9,-3 m-9,11 l8,-2','none',glow,1)
   a.path('M107,116 L122,46 L119,32 L128,29 L132,38 L122,48','none',light,3)
   a.ellipse(125,37,4,5,glow)
  elif kind=='ash_general':
   for x,y in [(38,63),(103,64)]:a.path(f'M{x},{y} l-5,-20 l12,8 l10,-2 l-4,15 Z','#d79460','#593344',1.5)
   a.path('M48,101 L38,136 L56,130 L72,140 L103,133 L98,106 Z','#69354d','#412d43',2)
   for x,y in [(45,127),(80,135),(99,119)]:a.path(f'M{x},{y} q-5,-15 3,-26 q0,13 6,17 q5,9 -9,9',glow,'none')
  for x,y in [(59,75),(85,75),(51,103),(93,101)]:a.ellipse(x,y,1.3,1.3,'#f4dca6')
  a.path('M53,97 l17,8 l19,-8','none','#c8b18e',1)
 a.parts.append('</g>')


def build():
 OUT.mkdir(parents=True,exist_ok=True)
 for direction in ['front','back','left','right']:
  for state,count in STATES.items():
   a=Art(128*count,160)
   for i in range(count):
    a.parts.append(f'<g transform="translate({i*128} 0)">')
    hero(a,direction,state,i,count);a.parts.append('</g>')
   a.save(f'hero_{direction}_{state}')
 for kind in PALETTES:
  a=Art(144*6,160)
  for i in range(6):
   a.parts.append(f'<g transform="translate({i*144} 0)">');mob(a,kind,i,6);a.parts.append('</g>')
  a.save(f'mob_{kind}')
 icon=Art(128,128)
 icon.rect(1,1,126,126,'#173458','#ddbd75',2,28)
 icon.path('M25,31 L64,19 L103,31 L98,79 Q86,105 64,113 Q40,100 30,79 Z','#387faa','#f0cc77',4)
 icon.path('M40,45 L38,28 L51,39 L64,23 L77,40 L91,29 L88,52 L43,52 Z','#f2cb70','#714d3a',2)
 icon.ellipse(64,43,4,5,'#69f4e5','#387c9b',1)
 icon.path('M41,64 L61,91 L85,61','none','#f6e5b4',8)
 icon.path('M30,33 L64,24 L92,34','none','#72c4de',2)
 icon.save('app_icon')
 files=sorted(OUT.glob('*.svg'))
 manifest={'version':'0.24','status':'MODELED_PENDING_GATE','hero_states':STATES,'hero_directions':4,'mob_kinds':list(PALETTES),'files':[{'file':p.name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]}
 (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print(f'Built {len(files)} original sheets: 152 hero frames, 78 monster frames')
if __name__=='__main__':build()
