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
- Última atualização identificada antes desta limpeza: **UI v0.15 — inventário e reorganização do HUD**.
- Prioridade atual: evoluir menu, inventário e layout/HUD da versão 2D Cartoon.

## Colaboração
Antes de editar:
1. confirme que está trabalhando sobre a versão Cartoon;
2. leia `docs/README_CONTINUE_AQUI.md`;
3. não reative a implementação antiga por conveniência;
4. preserve história e mecânicas aprovadas;
5. valide no Godot antes de declarar uma build como pronta.
