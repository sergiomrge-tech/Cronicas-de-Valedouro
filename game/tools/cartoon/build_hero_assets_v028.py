"""Original v0.28 hero: finer clothing, face, filigree, archery and evasive poses."""
from pathlib import Path
import math,json,hashlib,inspect
import build_visual_assets as base
import build_combat_assets as previous
from build_visual_assets import Art
OUT=Path(__file__).resolve().parents[2]/'assets/cartoon/v028'
STATES={'idle':8,'walk':12,'attack':6,'cast':8,'hurt':4,'death':8,'shoot':8,'evade':6}
# Preserve historical v024 art and generate a new versioned original sheet family.
source=inspect.getsource(previous.hero)
source=source.replace("if state=='walk' else 0", "if state=='walk' else 0")
source=source.replace("if state=='hurt':", "if state=='shoot': sway=-2*math.sin(i/count*math.pi)\n if state=='evade': bob=8*math.sin(i/count*math.pi);sway=12*math.sin(i/count*math.pi)\n if state=='hurt':")
source=source.replace("if state=='cast':arm=", "if state=='shoot':arm=(-48 if sgn==(-1 if direction=='left' else 1) else 35)*math.sin(i/count*math.pi)\n  elif state=='evade':arm=-40*sgn\n  elif state=='cast':arm=")
source=source.replace("'#337fbc'", "'#247eab'").replace("'#8bcce1'", "'#9ce3df'")
# Add layered seams, engraved metal, face detail, cloak embroidery, knees and arm cuffs.
source=source.replace(" # Neck, ear and face features;", ''' # Engraved pauldrons, segmented torso, embroidered tabard and polished rivets.
 for x in [39,88]:
  a.path(f'M{x-2},66 l6,-4 l5,4 l-5,4 Z','#f4d384','#735645',.8)
  a.ellipse(x+3,66,1.3,1.3,'#f9ffef')
 for x,y in [(50,71),(78,72),(50,81),(76,82),(49,99),(77,99)]:
  a.ellipse(x,y,1.2,1.2,'#fff0bc','#5f756b',.5)
 a.path('M53,72 Q58,68 62,72 L61,80 L55,84 M73,71 l-4,3 l1,7 l4,3','none','#c0fff0',1)
 a.path('M51,102 l4,5 l4,-2 M69,107 l5,-2 l4,-5','none','#f0cc7c',1.4)
 a.path('M56,68 l3,0 M70,68 l4,0','none','#fff5d8',1)
 for x in [47,80]:
  a.path(f'M{x},78 l3,0 l0,8 l-3,0','none','#deaa65',1)
 a.path(f'M{39+sway:.1f},119 l4,6 l5,-4 M{82+sway:.1f},122 l5,3 l3,-5','none','#e5cf89',1.4)
 # Neck, ear and face features;''')
source=source.replace(" # Neck, ear and face features;", """ if direction=='back':
  a.path(f'M47,60 Q64,55 81,60 L{89+sway:.1f},123 Q65,134 {38+sway:.1f},122 Z','#294a94','#182f59',1.5)
  a.path(f'M49,66 L{44+sway:.1f},119 Q65,127 {83+sway:.1f},120 L79,66','none','#efd38d',1.5)
  for x in [53,64,76]: a.path(f'M{x},69 Q{x-4},91 {x+sway*.5},119','none','#587cc7',1)
  a.path('M64,76 L74,86 L64,103 L54,86 Z','#e8c677','#735541',1)
  a.path('M64,81 l5,5 l-5,9 l-5,-9 Z','#66dfd5','#316c90',1)
 # Neck, ear and face features;""")
source=source.replace("  a.path('M77,46", "  a.path('M54,49 l2,1 M71,49 l2,1','none','#d18b70',.8)\n  a.path('M59,55 l4,1 l5,-1','none','#c39067',.8)\n  a.path('M77,46")
namespace={'math':math};exec(source,namespace);hero=namespace['hero']
def build():
 OUT.mkdir(parents=True,exist_ok=True);base.OUT=OUT
 for direction in ['front','back','left','right']:
  for state,count in STATES.items():
   a=Art(128*count,160)
   for i in range(count):
    a.parts.append(f'<g transform="translate({i*128} 0)">')
    hero(a,direction,state,i,count);a.parts.append('</g>')
   a.save(f'hero_{direction}_{state}')
 manifest={'version':'0.28','status':'MODELED_PENDING_GATE','directions':4,'states':STATES,'frames':sum(STATES.values())*4,'files':[{'file':p.name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(OUT.glob('*.svg'))]}
 (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print('Built 32 original hero sheets, 240 frames')
if __name__=='__main__':build()
