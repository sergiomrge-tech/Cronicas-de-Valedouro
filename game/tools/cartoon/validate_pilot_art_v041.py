"""Check original art integrity, isolated atlas frames, and mobile texture imports."""
from pathlib import Path
from hashlib import sha256
import json
from PIL import Image
from validate_city_art_v040 import check as check_city
GAME=Path(__file__).resolve().parents[2]
ART=GAME/'assets/cartoon/v041'

def check():
    data=json.loads((ART/'art.json').read_text())
    for key,source in data['files'].items():
        file=ART/source['file']
        assert sha256(file.read_bytes()).hexdigest()==source['sha256'], f'Changed original: {key}'
        with Image.open(file) as image:
            assert list(image.size)==source['size']
        settings=file.with_suffix('.png.import').read_text()
        assert 'compress/mode=2' in settings and 'mipmaps/generate=true' in settings, key
    for family,file in [('nature','foliage.png'),('people','people.png'),('creatures','creatures.png')]:
        with Image.open(ART/file) as image:
            assert image.mode=='RGBA'
            regions=[]
            for name,entry in data[family].items():
                frames=entry.get('frames',[entry])
                for frame in frames:
                    x,y,w,h=frame['region']
                    assert min(x,y)>=0 and w>0 and h>0 and x+w<=image.width and y+h<=image.height
                    for ox,oy,ow,oh in regions:
                        assert x>=ox+ow or ox>=x+w or y>=oy+oh or oy>=y+h, f'Overlapping {family} frames: {name}'
                    regions.append((x,y,w,h))
                    alpha=image.getchannel('A').crop((x,y,x+w,y+h))
                    bbox=alpha.point(lambda a:255 if a>51 else 0).getbbox()
                    assert bbox and bbox[0]>0 and bbox[1]>0 and bbox[2]<w and bbox[3]<h, f'Clipped frame: {name}'
                    anchor=frame['anchor']
                    assert 0<=anchor[0]<=w and 0<=anchor[1]<=h
    check_city()
    print('pilot_art_v041: PASS — original checksums, isolated grounded atlas frames, ETC2/S3TC mipmaps and current floor provenance')

if __name__=='__main__': check()
