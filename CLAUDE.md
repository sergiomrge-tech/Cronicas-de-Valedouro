# CLAUDE.md — Crônicas de Valedouro 2D Cartoon

Este repositório é a fonte técnica colaborativa de **Crônicas de Valedouro**.

## Regra principal
A versão oficial e única base ativa de desenvolvimento é a **2D Cartoon**. A antiga direção visual/pixel-art foi descontinuada como base de trabalho. Não iniciar novas alterações a partir de cenas, scripts ou checkpoints antigos quando existir equivalente Cartoon.

## Regras obrigatórias
- Engine oficial: Godot 4.7.2; manter compatibilidade Godot 4.x quando possível.
- Android/mobile-first, orientação horizontal, alvo de 60 FPS.
- Cena inicial oficial: `res://scenes/cartoon/CartoonMainMenu.tscn`.
- Código principal novo: `game/scripts/cartoon/`.
- Cenas principais novas: `game/scenes/cartoon/`.
- Visual oficial: **2D Cartoon**, estilizado, coeso e legível em celular.
- Nunca voltar à direção pixel-art antiga sem ordem explícita do Diretor.
- Nunca afirmar PASS de runtime sem executar validação real.
- Um único protagonista, sem classes rígidas; builds por armas, equipamentos, skills e passivas.
- Progressão, história, missões, bosses, crafting e IDs persistentes continuam canônicos quando já definidos.
- Áreas da missão principal devem existir e ser coerentes com o mapa.
- Mapas devem ser grandes o suficiente para exploração real e construídos considerando as missões.
- Antes de liberar ZIP/APK/AAB: validar referências, parser/runtime Godot 4.7.2, fluxo crítico e higiene do pacote.

## Estado atual — 30/09/2026
- Base ativa: 2D Cartoon.
- Entrada do projeto: `CartoonMainMenu.tscn`.
- Estado persistente: `CartoonPlayerState`.
- Sistemas Cartoon já presentes incluem regiões, exploração, crafting, inventário, menu, mapa/story runtime e controles de zoom.
- Base oficial: **v0.19 — polimento estrutural dos painéis mobile**.
- Prioridade atual do Diretor: melhorar assets, sprites, mapa e level design.
- Candidata visual **v0.20**: ler `docs/CARTOON_VISUAL_V0_20.md`; arte permanece
  MODELED_PENDING_GATE e os gates 4.7.2/Android estão pendentes.

## Colaboração
Antes de editar:
1. confirme que está trabalhando sobre a versão Cartoon;
2. leia `docs/README_CONTINUE_AQUI.md`;
3. não reative a implementação antiga por conveniência;
4. preserve história e mecânicas aprovadas;
5. valide no Godot antes de declarar uma build como pronta.

## Continuidade — candidata de interface v0.21

O Diretor também pediu o ajuste completo do layout e HUD. A v0.21 unifica a
interface nas oito regiões Cartoon e reformula menu, inventário, forja, mapas,
pausa e escolha final. Leia `docs/CARTOON_UI_V0_21.md`; QA em
`docs/visual_qa/cartoon_ui_v021/review.html`. Os 21 testes passaram em Godot
4.6.3; validação oficial 4.7.2 e testes Android continuam pendentes.
A base oficial continua v0.19, com arte v0.20 e interface v0.21 candidatas.

## Continuidade — candidata v0.22: interiores e caça

Solicitação mais recente do Diretor: visual mais rico, interiores da taverna,
ferreiro e guilda, quadro de várias missões e animais de caça. A v0.22 implementa
três interiores jogáveis, sete contratos, duas receitas iniciais, moradores,
33 sprites originais e fauna persistente em seis regiões naturais.
Veja [o relatório](docs/CARTOON_LIVING_WORLD_V0_22.md) e
[a revisão visual](docs/visual_qa/cartoon_v022/review.html).
22 testes passaram no Godot 4.6.3. Godot 4.7.2/Android e aprovação visual
ainda pendentes. Arte MODELED_PENDING_GATE; contratos adicionais PROPOSED.
A base oficial permanece v0.19; os passes v0.20–v0.22 são candidatos locais.

## Continuidade — 01/10/2026: candidata v0.23, Castelo Real

O Diretor pediu um castelo gigantesco, com interior de luxo. A v0.23 substitui
o exterior pequeno por um complexo monumental a nordeste, ligado à cidade e
sem bloquear a estrada da campanha. Possui oito alas exploráveis, rei,
24 sprites originais e mais de 100 elementos decorativos.
Leia [o relatório](docs/CARTOON_ROYAL_CASTLE_V0_23.md) e
[abra a revisão visual](docs/visual_qa/cartoon_v023/review.html).
23 testes passaram em Godot 4.6.3; gates 4.7.2/Android e aprovação visual
permanecem pendentes. Arte MODELED_PENDING_GATE; conteúdo adicional PROPOSED.
Base oficial v0.19; passes v0.20–v0.23 são candidatos em revisão, incluídos no salvamento do código no GitHub solicitado pelo usuário.
