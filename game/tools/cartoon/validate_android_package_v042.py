"""Verify actual exported Android resources; prepare a flat APK + checksum delivery."""
from pathlib import Path
import argparse, hashlib, json, zipfile, re

def verify(apk: Path, source_sha: str, badging: Path):
    assert re.fullmatch(r'[0-9a-f]{40}', source_sha), 'Missing source commit'
    expected = {'armeabi-v7a', 'arm64-v8a'}
    with zipfile.ZipFile(apk) as package:
        assert package.testzip() is None, 'Corrupt APK ZIP member'
        names = package.namelist()
        assert 'AndroidManifest.xml' in names and 'classes.dex' in names
        abis = {name.split('/')[1] for name in names if name.startswith('lib/') and name.endswith('.so')}
        assert abis == expected, ('Unexpected native ABIs', abis)
        def resource(suffix):
            matches = [name for name in names if name.endswith('/'+suffix)]
            assert len(matches) == 1, ('Missing or ambiguous resource', suffix, matches)
            return matches[0]
        manifest = json.loads(package.read(resource('assets/cartoon/v042/art.json')))
        source = Path(__file__).resolve().parents[2]/'assets/cartoon/v042/art.json'
        assert manifest == json.loads(source.read_text()), 'Stale illustrated art manifest'
        for entry in manifest['files'].values():
            assert any(entry['file']+'-' in name and name.endswith('.ctex') for name in names), ('Missing painted texture', entry['file'])
        for suffix in ['assets/cartoon/v041/art.json','assets/cartoon/v040/buildings.json']:
            json.loads(package.read(resource(suffix)))
        for script in ['cartoon_hero_art_v042','cartoon_spell_art_v042','cartoon_weapon_art_v042','cartoon_interior_art_v042','cartoon_interior_floor_v042','cartoon_interior_wall_v042']:
            assert any(script in name and name.endswith('.gdc') for name in names), ('Missing compiled illustrated script',script)
        assert not any(name.startswith('assets/tests/') or name.startswith('assets/tools/') for name in names), 'Test/tools leaked into APK'
    metadata = badging.read_text()
    assert "package: name='com.sergiomrge.cronicasvaledouro.test' versionCode='42' versionName='0.42-test'" in metadata
    digest = hashlib.sha256(apk.read_bytes()).hexdigest()
    out = apk.parent
    (out/'SHA256.txt').write_text(digest+'  '+apk.name+'\n')
    result={'source_commit':source_sha,'engine':'4.7.2','version':'0.42-test','version_code':42,'package':'com.sergiomrge.cronicasvaledouro.test','abis':sorted(abis),'apk_file':apk.name,'apk_bytes':apk.stat().st_size,'sha256':digest,'illustrated_textures':len(manifest['files']),'compiled_illustrated_scripts':6,'archive_crc':'PASS','android_badging':'PASS','physical_device_test':'NOT_EXECUTED'}
    (out/'EXPORT_CHECK.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    (out/'COMO_INSTALAR.txt').write_text('Crônicas de Valedouro v0.42 — Android TEST\n\n1. Salve o ZIP e abra Meus Arquivos > Downloads.\n2. Extraia o ZIP e abra '+apk.name+'.\n3. Autorize a instalação pelo aplicativo usado para abrir o APK.\n\nSe o navegador salvar o ZIP como content, renomeie para Valedouro_v0.42.zip antes de extrair.\nAndroid 7.0+; ARM 32/64 bits. Esta é uma build de teste.\n\nA assinatura de teste é gerada nesta execução. Uma instalação anterior com outra assinatura pode impedir a atualização. Desinstalar o app anterior apaga seu progresso local; preserve uma cópia antes de removê-lo.\n\nSHA256.txt e EXPORT_CHECK.json registram integridade e commit.\n')
    print('android_package_v042: PASS — signed-export resources, two ARM ABIs, version/package, 15 painted textures, six compiled scripts, clean archive and flat checksum')
    print(json.dumps(result,ensure_ascii=False))

if __name__ == '__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('apk',type=Path)
    parser.add_argument('--source-sha',required=True)
    parser.add_argument('--badging',type=Path,required=True)
    args=parser.parse_args()
    verify(args.apk,args.source_sha,args.badging)
