# v0.32 validada — progressão de magia e interface RPG

A v0.32 continua sobre a v0.31 e incorpora decisões explícitas do Diretor
após o teste da v0.30 no celular.

## Magias por progressão

A regra da v0.30 de exibir as três magias desde o início foi substituída.

- nível 1: **Brasa**;
- nível 10: **Cristal**;
- nível 25: **Arcana**.

Magias bloqueadas não aparecem no HUD e não podem ser conjuradas por toque ou
atalho. Quando o personagem cruza um nível de desbloqueio, o HUD se reorganiza
imediatamente sem exigir troca de cena. As recargas continuam independentes.

## Bolsa / paper-doll do personagem

A área de equipamentos deixa de ser apenas uma lista. A Bolsa agora possui uma
prévia real do mesmo herói Cartoon do jogo, renderizada no centro, com slots ao
redor para:

- arma;
- elmo;
- peitoral;
- luvas;
- capa;
- calças;
- botas.

A prévia usa o equipamento atual do save e atualiza ao equipar uma peça. Os
slots continuam permitindo toque para selecionar/comparar.

O cabeçalho da Bolsa passa a exibir explicitamente o **ouro atual** além de
equipamentos, materiais e consumíveis.

## Textos mais compactos

O HUD normal prioriza informação curta:

- objetivo principal recolhido para uma linha no modo compacto;
- painel de missão menor;
- aviso temporário menor;
- resumo da Guilda em uma única linha;
- cards do Diário de Missões mais baixos.

O modo expandido do objetivo continua disponível para leitura detalhada.

## Diário de Missões rolável

O `ScrollContainer` agora possui barra vertical sempre disponível quando há
overflow, deadzone de toque e tratamento explícito de arrasto vertical.

Cards e textos não interativos deixam o gesto chegar ao scroll. Em tela pequena,
o jogador pode arrastar a lista e acessar todas as missões abaixo.

## Testes

- `cartoon_spell_slots_v030.gd` foi atualizado para a nova regra 1/10/25,
  mantendo a regressão de recargas independentes;
- `cartoon_missions_v029.gd` agora testa barra e gesto de rolagem em 640×360;
- `cartoon_ui_progression_v032.gd` cobre progressão das magias, ouro na Bolsa,
  paper-doll, slots e rolagem do Diário.

## QA visual

`qa_capture_ui_progression_v032.gd` gera capturas reais do Godot com:

1. paper-doll e equipamentos em 960×540;
2. paper-doll em 640×360;
3. lista de missões no topo;
4. lista de missões rolada até o fim;
5. início da campanha com apenas uma magia.

## Validação oficial

A v0.32 foi validada no **Godot 4.7.2 oficial** no commit
`26108ab8bfc4d6376044852001aca0c6f11554bb`.

O Godot Gate concluiu com sucesso:
- validação estática;
- importação/parser;
- **51 testes nativos**;
- QA visual geral e das oito regiões;
- QA de interiores, castelo, classes, equipamentos, missões e magias;
- QA v0.31 de loot/consumíveis;
- QA v0.32 de progressão, paper-doll e rolagem das missões.

Run oficial: `36868571315`.
APK permanece sob demanda e exige pipeline Android próprio antes de ser
declarado instalável.


## Retomada a partir do GitHub — 01/10/2026

O trabalho interrompido estava no commit `f69405c`. O gate falhava no teste
`cartoon_spell_slots_v030`: em 800×450, o aviso de combate cobria um botão
de magia. A retomada preserva loot/consumíveis v0.31, save v7, paper-doll,
rolagem touch e a progressão de magias 1/10/25 da v0.32.

Avisos agora ficam na área livre à esquerda em telas compactas, usam até
duas linhas e preservam o texto completo no tooltip. O layout calcula a
altura real da fonte para separar loot e indicação de interação. O resumo
da guilda ocupa uma linha, sem sobrepor os avisos. Mudanças no texto
reorganizam o espaço automaticamente.

34 testes Cartoon locais passaram no Godot 4.6.3. A regressão v0.32 também
verifica avisos longos, contrato ativo e três magias nos tamanhos 640×360,
800×450, 960×540 e 1280×720. A CI executa 51 testes nativos em Godot 4.7.2;
a captura v0.32 acrescenta as duas cenas que reproduzem a sobreposição,
sete imagens ao todo, além das cinco capturas de loot v0.31.

[Revisão visual real](visual_qa/cartoon_v032/review.html).
O Godot Gate 4.7.2 da retomada concluiu com sucesso no commit `26108ab8`.
Balanceamento continua PROPOSED; avaliação visual do Diretor e medição em
aparelho físico continuam pendentes.
