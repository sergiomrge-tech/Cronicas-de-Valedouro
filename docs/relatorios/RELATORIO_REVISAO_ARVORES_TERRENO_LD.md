# Revisão visual — árvores, terreno e level design

Branch `ccr-bb54cda9-tvw178`. Método: capturas reais do Godot de 8 locais (floresta/acampamento, vila dos campos, aldeia do vale, transições, gelo, deserto, bosque, campos), antes e depois — `docs/visual_qa/story/revisao_arvores_terreno/` (`ANTES_*`, `DEPOIS_*`, `KIT_arvores_render.jpg`).

## Diagnóstico
- **Árvores:** copas APPROVED pequenas e redondas, repetidas, fora de escala ao lado das casas novas de dois andares; pinheiros finos.
- **Terreno:** trilhas e terra nua dominadas por rachaduras de lama seca (densidade alta), manchas marrons grandes.
- **Level design:** relevo (platôs de rocha) colado em casas e na mureta da aldeia; moinho encostado nas casas; torre do mirante oeste em cima da trilha do Lenhador.

## Correções
- **9 árvores novas** (`pro_trees.py`, QC 9/9): três carvalhos verdes, carvalho de outono, carvalho dourado, dois pinheiros altos, pinheiro com neve e bétula dupla. Copa em volume com três camadas de luz, raízes, sombra de contato, escala das casas. Aplicadas na vegetação procedural (`asset_for`), no bosque, nas alamedas da cidade e na borda desenhada em `main.gd`.
- **Terreno:** trilha vira chão batido (terra nua em 18% em vez de 40%); rachaduras 5× mais raras; mais seixos, relva seca e tufos nas trilhas e terra.
- **Level design:** relevo com folga de pátio de construções, muros, cercas e POIs; torre do mirante oeste movida para fora da trilha (POI, bandeira e trilha de acesso acompanham); moinho afastado das casas, junto à lavoura (regra de lógica mantida).
- Padrão salvo em `.claude/skills/valedouro-asset-quality/SKILL.md` (seções 6 e 7).

## Validação
Suíte Godot **17/17 PASS**, `audit_logic.py` 0 falhas, `validate_reg001.py` PASS, `world_travel` PASS.

## Próximos passos sugeridos
- **Peças de relevo** (platôs/cristas de rocha empilhada): ainda leem como "panquecas" cinza. Merecem remodelagem com massa rochosa contínua, grama que desce pelas bordas e base integrada ao chão.
- Gelo e deserto: excesso de blocos repetidos (lajes de gelo, platôs de areia); rever densidade e variedade.
- Largura das estradas principais no vale.
