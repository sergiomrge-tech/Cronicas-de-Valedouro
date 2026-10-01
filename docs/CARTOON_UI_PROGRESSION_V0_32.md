# Candidata v0.32 — progressão de magia e interface RPG

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

A v0.32 só deve ser tratada como validada após o Godot Gate 4.7.2 concluir
com sucesso. APK continua sob demanda.
