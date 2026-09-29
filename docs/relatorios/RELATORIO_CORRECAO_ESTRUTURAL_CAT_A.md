# Correção estrutural — Categoria A: módulos presos a um único ângulo

Branch `ccr-bb54cda9-tvw178`. Ato 3 **não** iniciado. Categorias B, C e D aguardam o texto do Diretor.

## Diagnóstico
Os módulos lineares (muros, muralhas, paliçadas, barricadas, cercas, paredes vivas, muros de ruína) eram modelados de frente e girados 45° uma única vez (`geo.rotate_all(45)`), logo existiam numa só direção na tela. Para fechar espaços eu vinha criando variantes ad hoc (`_diag`, `_diagb`), o que não escala. O espelhamento de sprite não resolve: inverte luz e sombra projetada.

## Correção do pipeline
`game/tools/art_pipeline/pro_orient.py` (novo) gera, a partir de QUALQUER módulo linear registrado, um **kit multi-ângulo renderizado de verdade no Blender** (sem espelhar):
- `<id>_a1 … <id>_a7`: a peça girada em passos de **22,5°** → retas em 8 direções na tela; encadeadas fazem curvas suaves.
- `<id>_c0 … <id>_c3`: **peça de canto em L** (dois segmentos que se encontram na âncora), nos 4 quadrantes.
- Colisão recalculada da geometria girada (círculos ao longo do eixo de corrida, projeção 2:1 do jogo); famílias sem colisão no original continuam sem colisão.
- `orient_analyze.py` mede cada variante e grava `game/data/orient_kit.json` (direção de corrida na tela, comprimento, profundidade).
- `pro_landmarks.py`: colisão "preguiçosa" (calculada durante a construção).
- Bug corrigido no caminho: as rotações por operador do Blender não eram aplicadas a malhas compartilhadas; passou a transformar a malha diretamente.

## Famílias cobertas (21)
`val_wall_segment/_repaired/_breach`, `val_palisade_broken`, `flo_palisade_organic/_broken`, `val_barricade_a/_b`, `flo_barricade_improvised`, `nat_fence_wood_a/_b`, `nat_fence_broken_a/_b`, `nat_wall_low_a/_b`, `flo_hollow_wall_active/_dormant`, `flo_heart_wall`, `val_ruin_inscription_wall`, `flo_cart_ruin_wall`, `nat_ruin_wall` → 231 novas peças.

## Composição
`Comp.run(familia, polilinha)` em `tools/act02/build_compositions.py` encadeia peças ao longo de uma polilinha escolhendo a variante de ângulo mais próximo (a partir de `orient_kit.json`). Aplicado a: muro curvo da arena da Raiz Oca (ativo/dormente), parede viva curva do coração da Árvore-Memória, arcos de paliçada e barricadas da Casa dos Guardas (quebrada/reparada).

## Resultado
- 231 peças novas (21 famílias × 7 ângulos + 4 cantos), QC: **0 falhas**, 17 avisos leves (sombra encostando na borda do quadro), manifesto e SHA atualizados, 64 cores.
- **Mundo do Ato I** (`build_world.py`, helper `krun`): barricadas do portão em curva (deixando a estrada livre), paliçadas da estrada norte em arcos e cerca da lavoura acompanhando o campo.
- **Ato II:** arena da Raiz Oca com muro curvo (ativo/dormente), parede viva curva no coração da Árvore-Memória, arcos de paliçada e barricadas da Casa dos Guardas (quebrada/reparada).
- Capturas reais do Godot em `docs/visual_qa/story/estrutural_catA/`; folhas do kit (render Blender) de paliçada e muralha.
- Suíte Godot completa: **17/17 PASS**; `audit_logic.py`: 0 falhas; `validate_reg001.py`: PASS.

## Observação do Diretor ("só mudou a sombra")
A primeira versão do kit existia como assets, mas as cenas ainda usavam as peças antigas: só a sombra projetada divergia. As cenas agora usam o kit (ver capturas).

## Pendências desta categoria
- Muralha principal do portão (`val_wall_*` e torres) e paredes de interior seguem retas/frontais; falta usar o kit em recintos maiores (muralha da cidade) e criar variantes para torres/portões/arcos (peças pontuais, não lineares).
- Peça T e curva de raio fixo (hoje curva = encadeamento de segmentos de 22,5°).
- Prefixos dos assets legados (`nat_fence_*` na fazenda/moinho/estação/casa abandonada) ainda usam `iso_run` retilíneo; migrar para `krun`.
- 17 avisos de sombra na borda: aceitos.

## Correção adicional: casas inteiras modeladas (telhado não flutua mais)
Diagnóstico: as casas eram três peças APPROVED soltas (porta, janela, telhado) desenhadas de frente, e o telhado ficava sem apoio. O primeiro remendo (parede atrás) foi rejeitado pelo Diretor.
Correção: casa **original modelada inteira** (`val_town_house_blue/_red/_wood`), vista em 3/4 com duas fachadas reais:
- térreo de pedra com cunhais, andar em enxaimel com balanço e cachorros;
- porta em arco com dobradiças, degraus e lanterna; janelas com venezianas, montantes e floreiras;
- telhado em fiadas de telhas com relevo real, apoiado nas paredes, com cumeeira, empena com óculo, água-furtada e chaminé;
- barril, caixotes, lenha e hera ao redor;
- três telhados diferentes: ardósia azul, telha de barro e ripas de madeira.
Aplicada em **todas as 21 casas do mapa**: cidade, vila dos campos, aldeia do vale, estação, fazenda e casa abandonada (via `W.house()`), e nas casas legadas de `main.gd`. Colisão ajustada à planta, sem bloquear rotas. `audit_logic.py`: 0 falhas.

## Correção adicional: muralha sul sem ângulo
As peças APPROVED retas e frontais da muralha sul foram trocadas pelo **kit modelado `val_wall_segment`** em traçado de dentes nos eixos isométricos (±26,6°), com baluartes (`val_gate_tower`) nos cantos, peças levemente sobrepostas (sem frestas) e o vão do portão sul mantido. Rotas: `world_travel` PASS.
Suíte Godot: **17/17 PASS**. Capturas: `CASAS_modeladas_cidade.jpg`, `CASA_abandonada_modelada.jpg`, `MURALHA_SUL_angulada.jpg`, `KIT_casa_3_telhados_render.jpg`.

## Revisão 3 — muros conectados em eixos isométricos, todos os prédios em 3/4
- **Desconexão diagnosticada:** as cercas legadas avançavam 32 px por peça sem relação com o tamanho real, e a muralha sul tinha torre só em metade dos vértices.
- **Novo padrão `iso_wall()`:** peças só nos dois eixos isométricos, passo exato do comprimento real e junção em cada vértice. A junção é a nova `val_wall_tower`, uma torre quadrada alinhada aos eixos do mundo.
- **Aplicado em todo o mapa:**
  - muralha norte (dentes para fora, com estados reparada/rompida junto ao portão) e muralha sul (dentes, portão sul modelado);
  - cercado da fazenda (losango fechado com vão do portão), casa abandonada, estação, moinho, lavoura da estrada norte, cercas junto ao portão;
  - mureta da aldeia.
- **Retiradas do mundo e do desenho legado:** muralha norte APPROVED frontal, `APP:city_store` e `APP:city_gate`. A loja virou casa modelada.
- **Guilda e Arquivo:** re-renderizados em vista 3/4, com `roof_gable_tiled()` (telhas em fiadas e empenas fechadas).
- **Padrão salvo:** `.claude/skills/valedouro-asset-quality/SKILL.md`, referenciado no `CLAUDE.md`.
- **Validação:** suíte Godot 17/17, `audit_logic` com 0 falhas e `world_travel` PASS.
- **Pendentes:**
  - o portão norte (`val_gate_main`) e suas duas torres seguem frontais, como gatehouse;
  - as paredes internas da Mina do Eco seguem frontais (zona de dungeon).
