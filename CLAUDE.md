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

## Estado atual — 02/10/2026
- Base ativa: 2D Cartoon.
- Entrada do projeto: `CartoonMainMenu.tscn`.
- Estado persistente: `CartoonPlayerState`.
- Sistemas Cartoon já presentes incluem regiões, exploração, crafting, inventário, menu, mapa/story runtime e controles de zoom.
- Último checkpoint oficial validado antes deste passe: **v0.40 — arquitetura e cidade otimizada**, commit `f37719cd`, Godot Gate 4.7.2 run `36948283483`. Último APK: v0.38-test; v0.39/v0.40 não geraram APK.
- Trabalho atual: **v0.41 — área piloto viva e ilustrada**, em `docs/CARTOON_PILOT_V0_41.md`. Validar o gate oficial antes de promover; preservar a interface Combate Radial (opção 3), progressão e save v8.
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


## Continuidade — v0.33 validada: cura rápida e equipamentos por nível

A v0.33 adiciona botão CURA no HUD mobile, uso inteligente de Frasco/Elixir e
requisitos de nível para equipamentos dos oito tiers (1/8/18/28/40/55/70/85).
Itens raros podem ser obtidos antes do nível, mas ficam bloqueados na Bolsa;
a Forja também respeita o requisito. Save permanece v7. Ler
`docs/CARTOON_RPG_PROGRESSION_V0_33.md`. Só promover após o Godot Gate 4.7.2.
APK continua sob demanda.


## Estado validado — v0.33

Commit de runtime validado: `4cb032e2012ecfeeb2f0477fe0a158d4b51bb961`.
Godot Gate oficial 4.7.2: run `36878325954`, conclusão success.
A suíte contém 52 testes nativos e QA visual dedicado v0.33.

Regras adicionais que não devem regredir:
- botão CURA mobile usando consumíveis da Bolsa;
- escolha de Elixir quando falta 50% ou mais da vida e Frasco em dano moderado;
- tiers de equipamento exigem níveis 1/8/18/28/40/55/70/85;
- item raro pode existir no inventário antes do nível, mas não pode ser equipado;
- Forja e Bolsa exibem/bloqueiam corretamente o requisito de nível.


## Continuidade — v0.34 validada: coleta de materiais no mapa

A v0.34 adiciona 48 novos pontos renováveis de coleta, seis por região, e
converte os 7 pontos especiais de recurso já existentes para a mesma lógica,
totalizando 55 pontos coletáveis. A interação usa o botão USAR e mostra
COLETAR no HUD. O recurso entra diretamente na Bolsa/Forja e reaparece em
5 minutos. O cooldown persiste no **save v8**. Ler
`docs/CARTOON_GATHERING_V0_34.md`. Só promover após o Godot Gate 4.7.2.
APK continua sob demanda.


## Estado validado — v0.34

Commit validado: `ed2b1173ec8645a1165d12a0b595588da89f65bd`.
Godot Gate oficial 4.7.2: run `36883480977`, conclusão success.
A suíte contém 53 testes nativos e QA visual dedicado de coleta.

Regras que não devem regredir:
- 48 novos pontos renováveis de coleta, seis por região;
- 7 pontos especiais de recurso anteriores também usam respawn renovável;
- total de 55 pontos coletáveis de material;
- interação COLETAR pelo mesmo botão USAR;
- materiais entram diretamente na Bolsa/Forja;
- respawn de 5 minutos persistente no save v8;
- recursos coletados somem temporariamente e reaparecem quando o cooldown expira.


## Continuidade — v0.35 validada: level up e desbloqueios compactos

A v0.35 adiciona banner curto de subida de nível, aviso automático de magia/tier
liberado e contador de pontos de habilidade no retrato do herói. Não usa modal
e não interrompe o combate. O save permanece v8. Ler
`docs/CARTOON_LEVELUP_FEEDBACK_V0_35.md`. Só promover após o Godot Gate 4.7.2.
APK continua sob demanda.


## Estado validado — v0.35

Commit validado: `e90330ba708d5c5402158ffae5b346ff6c47f49f`.
Godot Gate oficial 4.7.2: run `36885539172`, conclusão success.
A suíte contém 54 testes nativos e QA visual dedicado v0.35.

Regras adicionais que não devem regredir:
- level up usa banner compacto, sem modal;
- o aviso mostra pontos ganhos e magia/tier liberado;
- nível 10 libera Cristal e nível 25 libera Arcana;
- tiers regionais são informados quando o nível correspondente é atingido;
- retrato do herói mostra `+N PT` quando há pontos de habilidade disponíveis;
- gain_xp retorna previous_level, unlocks e skill_points;
- save permanece v8.


## Continuidade — v0.36 validada: troféus e crafts de chefes

A v0.36 adiciona 11 materiais exclusivos de chefes e 11 receitas especiais que
só aparecem após a primeira obtenção do troféu correspondente. Itens de boss
não entram no DROP RARO comum, respeitam os níveis regionais e recebem paleta,
brilho/emblema próprios no herói. Save permanece v8. Ler
`docs/CARTOON_BOSS_CRAFTING_V0_36.md`. Só promover após o Godot Gate 4.7.2.
APK continua sob demanda.


## Estado validado — v0.36

Commit validado: `5bca63331caf227e4e66ba9432ab75c7852075f5`.
Godot Gate oficial 4.7.2: run `36887979521`, conclusão success.
A suíte contém 55 testes nativos e QA visual dedicado v0.36.

Regras adicionais que não devem regredir:
- 11 chefes da campanha possuem material exclusivo e receita própria;
- receita de chefe só aparece depois que o troféu/material correspondente foi obtido;
- item de chefe nunca entra no DROP RARO comum;
- receitas especiais permanecem conhecidas depois do craft;
- itens de chefe respeitam os níveis regionais existentes;
- armas e peças de boss possuem paleta/acento/emblema próprios no herói;
- save permanece v8.


## Continuidade — v0.37 validada: combate de chefes em fases

A v0.37 adiciona barra dedicada de boss no HUD, três fases automáticas por HP e
golpes especiais periódicos com telegráfico ampliado e dano escalonado nas
Fases II/III. Monstros comuns preservam o comportamento anterior. Save
permanece v8. Ler `docs/CARTOON_BOSS_COMBAT_V0_37.md`. Só promover após o
Godot Gate 4.7.2. APK continua sob demanda.


## Estado validado — v0.37

Commit validado: `4fb27216fb82b8c3defc79c457b069985e0d2ac1`.
Godot Gate oficial 4.7.2: run `36891829409`, conclusão success.
A suíte contém 56 testes nativos e QA visual dedicado v0.37.

Regras adicionais que não devem regredir:
- chefes exibem barra própria com nome, nível, HP e fase;
- Fase I acima de 66%, Fase II entre 34–66%, Fase III em 33% ou menos;
- Fase II intercala golpe especial a cada terceiro ataque;
- Fase III intercala golpe especial a cada segundo ataque;
- golpes especiais usam telegráfico maior e dano escalonado;
- monstros comuns preservam windup, raio e dano anteriores;
- em 640×360 a barra de boss não sobrepõe o HUD do herói; o cartão de objetivo cede espaço apenas durante a luta;
- save permanece v8.

## Continuidade — candidata v0.38: Combate Radial

O Diretor escolheu a opção 3 da prancha de HUDs e pediu fidelidade visual em
todas as interfaces, incluindo inventário. Ler `docs/CARTOON_RADIAL_UI_V0_38.md`
e `docs/visual_qa/cartoon_v038/review.html`. HUD radial nas oito regiões,
retratos/barras, minimapa do mundo real, skin vermelho/dourado em todas as telas,
forja/zoom no MENU e inventário com controles maiores. 40 testes locais passaram;
CI verifica 57 testes oficiais e 30 novas capturas. APK v0.38 explicitamente
solicitado nesta sessão; gerar e entregar em ZIP nativo com SHA256 após os gates.
A preferência geral continua sendo não gerar APK sem pedido explícito.

## Continuidade — v0.39: correção de flutuação

Diretor relatou herói e algumas casas flutuando. Apoio das botas compensado
por quadro, sombra no contato com o terreno, fundações e sombras das casas
alinhadas. Ler `docs/CARTOON_GROUNDING_V0_39.md`; seis capturas em
`docs/visual_qa/cartoon_v039/review.html`. Verificação renderizada de 208 poses
em pé aprovada localmente; CI repete em 4.7.2. Não gerar APK neste pedido.

## Continuidade — v0.40: arquitetura e cidade otimizada

Diretor pediu construções variadas e melhor desempenho na cidade. Atlas de 12
modelos com fundações ancoradas, piso estático em cache e retrato da Bolsa
suspenso quando fechado. Ler `docs/CARTOON_CITY_V0_40.md`; galeria e capturas
em `docs/visual_qa/cartoon_v040/review.html`. Medição local na praça: 24910 → 308
chamadas e 189,4 → 19,2 ms por quadro (Godot 4.6.3 / llvmpipe, não celular).
CI executa 58 testes oficiais, 12 contatos renderizados e orçamento de desenho.
Android futuro v0.40 sob demanda; não gerar APK neste pedido. Save permanece v8.
Pesquisa de skills procedurais em `docs/PROCEDURAL_2D_SKILL_RESEARCH.md`: recomendar
`godot-procedural-generation`, com `godot-procedural-worlds` como complemento;
nenhuma skill externa instalada e nenhuma migração do mapa nesta pesquisa.

## Continuidade — v0.41: área piloto viva e ilustrada

Diretor aceitou manter Godot e começar por praça, rua e saída norte. Novo
terreno, oito elementos de natureza, oito moradores, 16 poses humanas e 18
poses de criaturas. Vegetação restaurada nos chunks junto à cidade. Encontros
determinísticos nos arredores (18 ativos, pool 24, retorno de cinco minutos
persistido em save v8), preservando missões, dificuldade e HUD radial 3.
Ler `docs/CARTOON_PILOT_V0_41.md`; comparação real em
`docs/visual_qa/cartoon_v041/review.html`. 42 testes Cartoon locais e pacote de
recursos verificados; CI oficial executa 59 testes e QA ao publicar. Não gerar
APK neste pedido. Próximo passe visual: herói/efeitos e interiores.

## Retomada automática solicitada pelo Diretor

Ler `docs/TAREFA_RETOMADA_AUTOMATICA.md` antes de uma execução agendada.
A v0.41 passou no Godot Gate oficial run `36953786483`, commit `b0a34a1`.
Continuar herói/efeitos e decoração dos interiores, registrar checkpoints,
preservar HUD 3 e save v8 e não gerar APK. Ao concluir o passe descrito,
desativar a automação de retomada.
