"""Read-only integrity and cutout checks. Visual approval additionally needs real renders."""
from pathlib import Path
from hashlib import sha256
import json
from PIL import Image
GAME=Path(__file__).resolve().parents[2]
ROOT=GAME.parent
ART=GAME/'assets/cartoon/v042'
def check():
    d=json.loads((ART/'art.json').read_text())
    for name,entry in d['files'].items():
        path=ART/entry['file']
        assert sha256(path.read_bytes()).hexdigest()==entry['sha256'],name
        with Image.open(path) as im: assert list(im.size)==entry['size']
        settings=path.with_suffix('.png.import').read_text()
        assert 'compress/mode=2' in settings and 'mipmaps/generate=true' in settings,name
    lock=json.loads((ROOT/'docs/visual_qa/cartoon_v041/reference_lock.json').read_text())
    for path,digest in lock['files'].items(): assert sha256((ROOT/path).read_bytes()).hexdigest()==digest,path
    families=[]
    for name,entry in d['walls'].items():families.append((name,"walls",[entry]))
    for name,entry in d['furniture'].items():families.append((name,entry['texture'],[entry]))
    for name,entry in d['hero'].items():families.append((name,'hero_'+name,entry['frames']))
    for name,entry in d['spells'].items():families.append((name,name,entry['frames']))
    for name,entry in d['weapons'].items():families.append((name,"weapons",[entry]))
    for name,texture,frames in families:
        for frame in frames:
            with Image.open(ART/(frame.get("texture",texture)+'.png')) as im:
                assert im.mode=='RGBA'
                x,y,w,h=frame['region']
                assert min(x,y)>=0 and w>0 and h>0 and x+w<=im.width and y+h<=im.height,(name,frame)
                assert 0<=frame['anchor'][0]<=w and 0<=frame['anchor'][1]<=h,name
                bbox=im.getchannel('A').crop((x,y,x+w,y+h)).point(lambda a:255 if a>51 else 0).getbbox()
                assert bbox and bbox[0]>0 and bbox[1]>0 and bbox[2]<w and bbox[3]<h,('Clipped opaque shape',name,bbox,[w,h])
    print('illustrated_art_v042: PASS — originals, locked references, complete cutouts, measured anchors, S3TC/ETC2 mipmaps')
if __name__=='__main__':check()
