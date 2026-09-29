# Lote 2 / Ato II — Parte 2B: Sistema das três raízes (`LOC_FOREST_ROOT_SHRINES`, `Q_MS02_ROOTS`)

Segue o §3-C e §5.3 de `LOTE02_ATO2_STORY_TO_MAP_v1.md`. Sem novos nomes canônicos: "Raiz da Água/Pedra/Vento" são descrições de produção (chaves internas `water`/`stone`/`wind`), como o documento do Gerente pede.

## Assets (10 novos, `MODELED_PENDING_GATE`, QC 10/10 PASS)
- Santuários, um por braço, cada um com variante corrompida e purificada (6): `flo_shrine_{water,stone,wind}_{corrupt,pure}`. Mesma cultura (pedra musgosa pré-guerra, núcleo/runa integrado às raízes, glifo), composição própria por terreno:
  - **Água:** bacia de pedra com espelho d'água sustentado por quatro raízes; pedras musgosas e pequenas quedas.
  - **Pedra:** monólito abraçado por raízes em espiral, meio arco de ruína, entulho.
  - **Vento:** patamar elevado com degraus, pórtico de duas árvores inclinadas, sinos de folhas.
  - Corrompido = raízes quase pretas, runa roxa contida, veios no chão, mato murcho, água escura parada. Purificado = raízes naturais, runa verde-azulada estável, água/folhas vivas, sem brilho exagerado de "quest concluída".
- Rotas: `flo_root_shortcut_blocked/_open` (atalho destravável), `flo_lookout_rock` (mirante), `flo_shrine_path_marker` (pedra-guia com glifo de raiz que liga os três braços ao mesmo sistema).

## Composições (`game/data/act02_compositions.json`) e estados
Três microáreas (uma por braço) com trilha de aproximação, pedras-guia, ruínas/queda d'água/patamar conforme o braço, árvores ancestrais e exclusões respeitadas. Estados por sub-objetivo da mesma quest: `quest:Q_MS02_ROOTS:water|stone|wind` (purificado) e `quest:Q_MS02_ROOTS:stone` também destrava o atalho da Raiz da Pedra. Nenhum sistema paralelo: o Gerente liga estas chaves ao estado da quest existente.
Mudança física ao purificar: variante do santuário, arbustos secos→floridos, teias somem, cogumelos e samambaias aparecem; no braço do vento as árvores secas desaparecem.

## Capturas reais do Godot — `docs/visual_qa/story/act02/`
`FLO_2B_{WATER,STONE,WIND}_{CORROMPIDA,PURIFICADA}` (6 imagens) + folha de assets (render Blender).

## Testes
`act02_compositions` cobre os 5 blocos (2 da Parte 2A + 3 braços): LOC canônico na região `floresta_ancestral`, assets carregáveis, estados só por quests canônicas. Suíte completa: **17/17 PASS**.

## Limitações
- Convergência dos três braços para o centro e o número de atalhos/segredos (2–3, 1–2) dependem do traçado macro que o Gerente fará no mapa; aqui existem o kit e uma composição de cada braço, mais o atalho e o mirante.
- Sons e partículas dos estados (água/folhas em movimento) ficam para a integração de runtime.
- Um segredo com retorno visual aos Cartógrafos será entregue junto do Santuário dos Cartógrafos (Parte 2E).
