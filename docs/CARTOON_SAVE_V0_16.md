# Crônicas de Valedouro — Save de Campanha v0.16

## Objetivo
A versão 2D Cartoon passa a ter um save de campanha real, usado pelo menu inicial e por todas as regiões.

## Menu
- **Novo Jogo**: inicia uma campanha limpa; se já existir save, exige confirmação.
- **Continuar**: abre a última cena salva e fica desabilitado quando não existe campanha.
- **Inventário**: continua disponível no menu.
- **Opções**: mantém a preferência de zoom.
- **Excluir Progresso**: exige confirmação e remove save, equipamentos fabricados e materiais.

## Estado persistido
O arquivo `user://valedouro_cartoon_profile_v1.json` foi migrado internamente para schema **version 2** sem mudar o caminho, permitindo migração de perfis anteriores.

Persistência incluída:
- cena/região atual;
- posição do herói;
- HP e HP máximo;
- ouro;
- nível e XP reservados para a progressão 1–100;
- materiais;
- equipamentos fabricados;
- arma e armadura equipadas;
- zoom da câmera;
- progresso da história por região;
- estados auxiliares de missões locais;
- progresso do Cerco de Valedouro.

## Autosave
O `CartoonPlayerState` mantém vínculo com a cena ativa e grava automaticamente o estado aproximadamente a cada 2,5 segundos. Trocas de região geram checkpoint antes da mudança de cena.

## Regiões integradas
1. Berço de Valedouro / Hub
2. Floresta Ancestral
3. Deserto de Edravar
4. Pântanos Sombrios
5. Montanhas Nevadas
6. Cerco de Valedouro
7. Costas e Ilhas Perdidas
8. Terras Corrompidas
9. Coração Abissal

## Validação
Teste nativo adicionado: `game/tests/save_menu_v016.gd`.

Ele cobre:
- criação de novo save;
- gravação e restauração de posição;
- HP, ouro, nível e XP;
- missão principal;
- missão local;
- troca de região;
- estado dos botões Continuar/Excluir;
- confirmação de exclusão;
- remoção efetiva do save.

O Godot Gate 4.7.2 deve passar antes de considerar a v0.16 validada.
