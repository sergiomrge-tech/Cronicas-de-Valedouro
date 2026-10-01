"""Three original Cartoon elite demon designs, six animated frames each."""
from pathlib import Path
import math,json,hashlib
import build_visual_assets as base
import build_combat_assets as combat
from build_visual_assets import Art
OUT=Path(__file__).resolve().parents[2]/'assets/cartoon/v029'
def build():
 OUT.mkdir(parents=True,exist_ok=True);base.OUT=OUT
 for kind,colors in {'ember':('#702443','#e56e57','#ffd172'),'void':('#4f276e','#af70dc','#ff8beb'),'ruin':('#245a69','#73bcbc','#9dfff0')}.items():
  combat.PALETTES['void_general']=colors
  a=Art(144*6,160)
  for i in range(6):
   a.parts.append(f'<g transform="translate({i*144} 0)">')
   combat.mob(a,'void_general',i,6)
   sway=math.sin(i/6*math.tau)*3
   a.path(f'M51,30 Q{31+sway},18 34,2 L45,14 L55,24 M94,29 Q{117-sway},15 114,1 L105,13 L89,24',colors[1],'#28233d',1.8)
   a.path('M56,54 l4,10 l5,-9 m15,-1 l4,9 l4,-10','none','#fff2ce',2)
   a.path('M37,83 l-8,13 l7,-2 l-6,13 l13,-5 M110,80 l8,13 l-7,-1 l8,13 l-13,-3',colors[1],'#2c253b',1.2)
   if kind=='ember':
    for x,y in [(36,70),(108,74),(64,21)]:a.path(f'M{x},{y} q-6,-12 2,-21 q-1,12 7,15 q0,7 -9,6',colors[2],'none')
   elif kind=='void':
    a.path('M49,75 L72,62 L98,74 L87,91 L72,110 L54,90 Z','#522b72','#f7a5f3',1)
    a.ellipse(72,81,7,13,colors[2],'#29233b',1);a.ellipse(72,81,2,9,'#24263a')
   else:
    a.path('M50,78 L65,70 L79,71 L94,79 L85,99 L63,105 Z',colors[1],'#233e4d',1)
    for x,y in [(61,81),(79,76),(73,95)]:a.path(f'M{x},{y} l5,4 l-4,5','none',colors[2],1.7)
   a.parts.append('</g>')
  a.save('demon_'+kind)
 manifest={'version':'0.29','status':'MODELED_PENDING_GATE','frames':18,'files':[{'file':p.name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(OUT.glob('*.svg'))]}
 (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print('Built 3 elite demon sheets / 18 animated frames')
if __name__=='__main__':build()
