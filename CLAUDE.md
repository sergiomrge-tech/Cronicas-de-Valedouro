# CLAUDE.md — Crônicas de Valedouro 2D Cartoon

Este repositório é a fonte técnica colaborativa de **Crônicas de Valedouro**.

## Regra principal
A versão oficial e única base ativa de desenvolvimento é a **2D Cartoon**. A antiga direção visual/pixel-art foi descontinuada como base de trabalho. Não iniciar novas alterações a partir de cenas, scripts ou checkpoints antigos quando existir equivalente Cartoon.

## Regras obrigatórias
- Engine oficial: Godot 4.7.2; manter compatibilidade Godot 4.x quando possível.
- Android/mobile-first, orientação horizontal, alvo de 60 FPS.
- Não gerar APK a cada atualização: atualizar código/GitHub e executar validações; gerar/exportar/publicar APK somente quando o Diretor pedir explicitamente. Preferência registrada em 01/10/2026, após a build v0.27.
- Entrega de APK solicitada pelo Diretor: anexar à conversa um ZIP com o APK atualizado e seu SHA256, com download nativo neste ambiente; não usar link externo do GitHub como entrega principal. Disponibilizar o anexo real antes de afirmar que está entregue; salvar apenas no filesystem não transfere o arquivo para o celular. Orientar brevemente: Meus Arquivos → Downloads → extrair ZIP → abrir APK. Preferência registrada em 01/10/2026 após download externo travar em 100%. Se não for possível anexar, informar a limitação sem afirmar entrega.
- Cena inicial oficial: `res://scenes/cartoon/CartoonMainMenu.tscn`.
- Código principal novo: `game/scripts/cartoon/`.
- Cenas principais novas: `game/scenes/cartoon/`.
- Visual oficial: **2D Cartoon**, estilizado, coeso e legível em celular.
- Nunca voltar à direção pixel-art antiga sem ordem explícita do Diretor.
- Nunca afirmar PASS de runtime sem executar validação real.
- Um único protagonista com classes trocáveis (Guerreiro, Mago e Caçador), habilidades evolutivas e builds por equipamentos; mudança solicitada explicitamente pelo Diretor em 01/10/2026.
- Progressão, história, missões, bosses, crafting e IDs persistentes continuam canônicos quando já definidos.
- Áreas da missão principal devem existir e ser coerentes com o mapa.
- Mapas devem ser grandes o suficiente para exploração real e construídos considerando as missões.
- Antes de liberar ZIP/APK/AAB: validar referências, parser/runtime Godot 4.7.2, fluxo crítico e higiene do pacote.

## Estado atual — 30/09/2026
- Base ativa: 2D Cartoon.
- Entrada do projeto: `CartoonMainMenu.tscn`.
- Estado persistente: `CartoonPlayerState`.
- Sistemas Cartoon já presentes incluem regiões, exploração, crafting, inventário, menu, mapa/story runtime e controles de zoom.
- Base oficial validada: **v0.32 — progressão de magias, loot/consumíveis, paper-doll, ouro na Bolsa, HUD compacto e Diário rolável**.
- Prioridade atual: continuar exclusivamente sobre a v0.32 Cartoon validada; preservar as decisões de progressão e ergonomia mobile.
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


## Candidata v0.24 — herói, criaturas e magias

152 quadros do herói, 13 tipos de criaturas animadas, três magias coloridas,
luzes, impactos, recarga e controles mobile. 24 testes locais passaram em
Godot 4.6.3. Build Android executa gates 4.7.2 e publica APK de teste v0.24.
Registro: `docs/CARTOON_COMBAT_V0_24.md`; GIFs/capturas:
`docs/visual_qa/cartoon_v024/review.html`. Arte MODELED_PENDING_GATE;
magias PROPOSED. Aprovação visual e testes no celular ainda pendentes.
A base oficial documentada permanece v0.19, com candidatos até v0.24 em revisão.

## Continuidade — candidata v0.25: combate elemental

Projéteis com impacto real nas oito regiões; Brasa com três pulsos de queimadura,
Cristal com lentidão e Arcana com um salto para outro monstro próximo. Mantém
bloqueios da história, XP, loot e caça. Barra de vida acima do sprite e dicas de
magia atualizadas. Leia `docs/CARTOON_ELEMENTAL_V0_25.md`; capturas reais e GIFs
em `docs/visual_qa/cartoon_v025/review.html`. 25 testes passaram localmente no
Godot 4.6.3; workflow Android executa a suíte em 4.7.2 e publica v0.25-test.
Arte MODELED_PENDING_GATE; mecânicas PROPOSED; teste em aparelho real e
aprovação visual pendentes. A base oficial documentada continua v0.19.

## Continuidade — candidata v0.26: esquiva e avisos de ataque

O herói ganha esquiva de 120 unidades com rastro azul, proteção curta e recarga.
Monstros das oito regiões avisam antes de atacar; chefes têm aviso mais longo
e área maior. Movimento respeita a geometria existente. HUD touch sem
sobreposição, incluindo painel de missão expandido. Leia
`docs/CARTOON_REACTIVE_V0_26.md`; GIFs/capturas reais em
`docs/visual_qa/cartoon_v026/review.html`. 26 testes passaram em Godot 4.6.3;
workflow Android executa a suíte oficial 4.7.2 e publica v0.26-test. Arte
MODELED_PENDING_GATE, novas mecânicas PROPOSED; aprovação visual e teste em
aparelho real pendentes. Base oficial documentada continua v0.19.

## Continuidade — candidata v0.27: classes e habilidades

Pedido explícito do Diretor: trocar de classe e evoluir habilidades. Substitui
a restrição anterior de não utilizar classes. Um protagonista, três
especializações trocáveis (Guerreiro, Mago, Caçador), nove habilidades de dez
graus, um ponto inicial +1 por nível, requisitos de nível e reembolso por
classe. Toque no retrato do herói ou pressione C. Save v4 migra os anteriores
sem perder campanha; só a classe ativa aplica bônus. Leia
`docs/CARTOON_CLASSES_V0_27.md`; revisão em
`docs/visual_qa/cartoon_v027/review.html`. 27 testes passaram em Godot 4.6.3;
workflow oficial 4.7.2 executa testes e novas capturas, e Android publica
v0.27-test. Balanceamento PROPOSED, arte MODELED_PENDING_GATE e teste em
aparelho real pendente; base oficial documentada continua v0.19.

## Continuidade — 01/10/2026: candidata v0.28, itens/arco/herói

A pedido do Diretor: 64 receitas, oito conjuntos de seis peças, sete posições
persistentes, arco com flechas em voo nas oito regiões e na caça, forja rolável
com compra de material e 32 folhas originais/240 quadros do herói. Save v5
preserva progresso e IDs anteriores. Ler `docs/CARTOON_EQUIPMENT_V0_28.md` e
`docs/visual_qa/cartoon_v028/review.html`. 28 testes Cartoon locais passaram;
CI verifica engine oficial e captura UI/animações reais. Arte
MODELED_PENDING_GATE, mecânicas PROPOSED. Não criar APK nesta atualização.


## Continuidade — candidata v0.29: missões e desafio

A pedido do Diretor: aba MISSÕES/J com Ativas, Disponíveis e Concluídas,
escolha persistente do objetivo no HUD/mapa, 48 demônios de três visuais,
avisos de magia e retorno de 600 s. Inimigos e fauna com níveis regionais
fixos e penalidade forte contra níveis superiores. Combate e XP mais
exigentes; viagens não concedem níveis/cura. Save v6 preserva a campanha.
31 testes Cartoon locais passaram; CI acrescenta três testes e 21 capturas
no Godot oficial 4.7.2. Leia `docs/CARTOON_MISSIONS_CHALLENGE_V0_29.md` e
`docs/visual_qa/cartoon_v029/review.html`. Arte MODELED_PENDING_GATE;
balanceamento PROPOSED. Não gerar APK sem pedido explícito.


## Continuidade — candidata v0.30: três magias independentes

A pedido do Diretor: Brasa, Cristal e Arcana juntas no HUD, três botões
coloridos, três recargas independentes (3 s, Foco reduz até 2,2 s), teclas
1/2/3 e compatibilidade Q/R. HUD touch sem sobreposição. Save v6 e efeitos
elementais preservados. 32 testes Cartoon locais passaram; CI inclui
49 testes oficiais e oito capturas novas. Ler
`docs/CARTOON_SPELL_SLOTS_V0_30.md` e
`docs/visual_qa/cartoon_v030/review.html`. Mecânica PROPOSED. Sem novo APK;
exportação somente mediante pedido, entrega em ZIP anexado à conversa.


## Retomada — candidata v0.32, sem APK

Retomada solicitada pelo Diretor a partir do GitHub, commit `f69405c`.
Sincronizadas as v0.31/v0.32 já implementadas: loot e poções, save v7,
magias em níveis 1/10/25, ouro e personagem na bolsa, missões roláveis.
Corrigida a sobreposição de avisos com magias em 800×450 e com interação
em textos de loot longos. 34 testes Cartoon locais passaram; CI verifica
51 testes e QA oficial. Ler `docs/CARTOON_UI_PROGRESSION_V0_32.md` e
`docs/visual_qa/cartoon_v032/review.html`. Não gerar APK nesta retomada.


## Estado validado — v0.32

Commit validado: `26108ab8bfc4d6376044852001aca0c6f11554bb`.
Godot Gate oficial 4.7.2: run `36868571315`, conclusão success.
Inclui parser/import, 51 testes nativos e QA visual completo.

Regras que não devem regredir:
- Brasa no nível 1, Cristal no 10 e Arcana no 25;
- loot e consumíveis persistentes no save v7;
- ouro explícito e paper-doll na Bolsa;
- slots de arma, elmo, peitoral, luvas, capa, calças e botas;
- Diário de Missões com rolagem vertical touch;
- textos/HUD compactos e avisos sem cobrir controles mobile.


## Continuidade — candidata v0.33: cura rápida e equipamentos por nível

A v0.33 adiciona botão CURA no HUD mobile, uso inteligente de Frasco/Elixir e
requisitos de nível para equipamentos dos oito tiers (1/8/18/28/40/55/70/85).
Itens raros podem ser obtidos antes do nível, mas ficam bloqueados na Bolsa;
a Forja também respeita o requisito. Save permanece v7. Ler
`docs/CARTOON_RPG_PROGRESSION_V0_33.md`. Só promover após o Godot Gate 4.7.2.
APK continua sob demanda.
