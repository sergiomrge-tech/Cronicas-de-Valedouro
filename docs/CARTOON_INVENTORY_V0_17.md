# Crônicas de Valedouro — Inventário RPG v0.17

## Objetivo
Transformar o inventário da versão 2D Cartoon em uma tela própria de RPG, adequada para celular e integrada ao equipamento persistente.

## Interface
- painel ampliado para leitura mobile;
- slots visuais separados para **arma** e **armadura** equipadas;
- grade rolável de itens;
- capacidade visual de **30 equipamentos**;
- filtros **Todos**, **Armas**, **Armaduras** e **Materiais**;
- painel lateral de detalhes;
- raridades por tier: Comum, Incomum, Raro, Épico e Lendário;
- comparação direta do atributo do item selecionado com o item equipado;
- botão **Equipar**;
- estado **Equipado** quando o item já está em uso;
- materiais apresentados em grade com quantidade e descrição de uso na Forja.

## Integração
O sistema continua usando `CartoonPlayerState`, portanto:
- itens fabricados permanecem no save;
- trocar arma/armadura altera os bônus reais de combate;
- o visual do herói continua sendo atualizado após equipar;
- o inventário funciona tanto no menu inicial quanto dentro das regiões;
- abrir a Bolsa pausa movimentação/combate como já ocorria na v0.15.

## Compatibilidade
A função `_equip(item_id)` foi mantida como compatibilidade com integrações da v0.15.

## Teste
Novo teste: `game/tests/inventory_v017.gd`.

Cobre slots equipados, grade, capacidade, filtros, seleção, comparação, equipar e materiais.
