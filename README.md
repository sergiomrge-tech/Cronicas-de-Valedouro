# Crônicas de Valedouro — 2D Cartoon

Repositório oficial de desenvolvimento do jogo **Crônicas de Valedouro**.

- Engine: **Godot 4.7.2**
- Alvo principal: **Android / mobile-first**
- Versão oficial atual: **2D Cartoon**
- Cena inicial oficial: `res://scenes/cartoon/CartoonMainMenu.tscn`
- Estado atual: **v0.19**, com save/menu de campanha, inventário RPG, HUD/XP 1–100 e polimento estrutural dos painéis mobile validado por capturas reais.

## Regra de continuidade
A antiga versão visual/pixel-art não é mais a base de desenvolvimento e não deve ser usada para novas alterações. Toda evolução do jogo deve partir da implementação em `game/scenes/cartoon/` e `game/scripts/cartoon/`, preservando história, missões e mecânicas canônicas quando compatíveis.

## Estado da sessão de 30/09/2026
A base 2D Cartoon está na **v0.19**. A v0.16 consolidou save/menu; a v0.17 trouxe o inventário RPG; a v0.18 adicionou HUD e progressão 1–100; e a v0.19 corrige a estrutura visual de menu, opções, confirmação, inventário, forja e zoom com QA visual dedicado.

## Para agentes
Leia primeiro **CLAUDE.md** e **docs/README_CONTINUE_AQUI.md**. Antes de editar, confirme que a cena principal do `project.godot` continua apontando para `CartoonMainMenu.tscn`.

## Validação
Nunca declarar parser/runtime/Android como aprovado sem executar os gates correspondentes no Godot 4.7.2.
