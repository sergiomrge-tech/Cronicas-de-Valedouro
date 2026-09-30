# Crônicas de Valedouro — 2D Cartoon

Repositório oficial de desenvolvimento do jogo **Crônicas de Valedouro**.

- Engine: **Godot 4.7.2**
- Alvo principal: **Android / mobile-first**
- Versão oficial atual: **2D Cartoon**
- Cena inicial oficial: `res://scenes/cartoon/CartoonMainMenu.tscn`
- Estado atual: evolução da interface, menu, inventário, HUD/layout, exploração e conteúdo da versão Cartoon.

## Regra de continuidade
A antiga versão visual/pixel-art não é mais a base de desenvolvimento e não deve ser usada para novas alterações. Toda evolução do jogo deve partir da implementação em `game/scenes/cartoon/` e `game/scripts/cartoon/`, preservando história, missões e mecânicas canônicas quando compatíveis.

## Estado da sessão de 30/09/2026
A base 2D Cartoon inclui menu inicial próprio, estado persistente do jogador, regiões Cartoon, zoom mobile e a atualização de UI/inventário identificada no histórico como **UI v0.15**.

## Para agentes
Leia primeiro **CLAUDE.md** e **docs/README_CONTINUE_AQUI.md**. Antes de editar, confirme que a cena principal do `project.godot` continua apontando para `CartoonMainMenu.tscn`.

## Validação
Nunca declarar parser/runtime/Android como aprovado sem executar os gates correspondentes no Godot 4.7.2.
