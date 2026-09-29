# VK — pipeline Blender executável de Valedouro

Implementação **executada e validada** do pipeline descrito em `docs/art/VALEDOURO_PRO_ART_MODELING_SKILL.md`
(os scripts `blender_*.py` da branch `art/pro-pixel-modeling-pipeline` são o rig de referência para uso interativo no Blender;
o VK roda **headless** com o módulo `bpy`).

## Ambiente
```
python3 -m venv /tmp/bpyenv --system-site-packages
/tmp/bpyenv/bin/pip install bpy==5.0.1 "numpy<2" pillow      # Python 3.11
/tmp/bpyenv/bin/python game/tools/art_pipeline/build_pro.py <prefixo_de_id ...> [--preview DIR] [--nowrite]
```
Cycles em CPU; sem GPU/OCIO (view transform "Standard" + exposição -0.55 EV; a grade final é feita em `vk/post.py`).

## Projeção e calibração (travadas)
* Câmera ortográfica, AZ 45° / EL 30° (2:1), `60 px por unidade de mundo`, `draw_scale 0.5` — mesma convenção dos assets APPROVED
  (porta APPROVED ≈ 4 u; herói ≈ 1.75 u ≈ 56 px de jogo).
* Âncora do pé: `shift_x/shift_y` da câmera fazem (0,0,0) cair exatamente no pixel `origin` (verificado por marcadores RGB nos eixos).
* Luz principal (sol) vinda de cima/esquerda da tela; preenchimento de céu frio; sombra de contato em passada própria
  (captador de sombra com sol alto → sombra compacta, pontilhada em Bayer, alpha único).
* Frentes voltadas ao jogador (cachoeira, caverna, paredes internas): modeladas em +X e giradas 45° (`geo.rotate_all(45)`).

## Módulos
| arquivo | função |
|---|---|
| `vk/core.py` | rig, câmera, luz, render em 2 passadas, aplicação de modificadores |
| `vk/mats.py` | materiais procedurais de nós: alvenaria em fiadas (junta, sombra por fiada, musgo), tábuas, telhas por UV, rocha em estratos (musgo/neve), terreno, cachoeira periódica, casca, tecido, foliagem… |
| `vk/geo.py` | caixas/cilindros com bevel, vigas, telhados com beiral e UV, booleana, rotação de conjunto |
| `vk/parts.py` | peças construtivas (fuste em talude, cantoneiras, entulho, plataforma, corrimão, escada, corda, bandeira com dobras, cachos de folhas, hera, tufos, flores, massas rochosas por ruído, tampas de terreno, dunas orientadas, tecido com caimento) |
| `vk/rig.py` | humanoides e quadrúpedes articulados (FK: caminhada/idle) |
| `vk/post.py` | alpha duro, preenchimento de furos, grade de cor, paleta, remoção de ruído de cor, contorno, sombra pontilhada |
| `vk/asset.py` | orquestra quadros/linhas → PNG + entrada de manifesto (`data/modeled_parts/pro.json`) |
| `pro_landmarks.py` `pro_terrain.py` `pro_structures.py` `pro_nature.py` `pro_life.py` `pro_interiors.py` | definições dos assets (IDs persistentes) |
| `pro_fx.py` | FX de interação (simulação de partículas em pixel art, sem Blender) |

## Regras de qualidade aplicadas
* Três níveis de leitura por asset (silhueta → formas secundárias → detalhes que reforçam a forma).
* Sem prisma/cilindro "puro" visível: bevel, talude, irregularidade (`rock_mass`, `jitter`), entulho e vegetação de contato.
* Alpha 100% duro (0 px de alpha parcial nos sprites; apenas a sombra usa um único valor de alpha).
* Status de tudo o que sai daqui: `MODELED_PENDING_GATE` (nunca `APPROVED`).
