# CONTINUE AQUI — Crônicas de Valedouro 2D Cartoon

**Diretor:** Sergio  
**Mundo:** Elyndor  
**Engine:** Godot 4.7.2  
**Base oficial atual:** 2D Cartoon v0.18  
**Cena inicial:** `res://scenes/cartoon/CartoonMainMenu.tscn`

## ATENÇÃO
A antiga versão visual/pixel-art não é mais a versão de trabalho. Não continuar desenvolvimento a partir dela. Use exclusivamente a arquitetura Cartoon como base das próximas alterações.

## Cânone essencial
Elyndor vive a Guerra da Coroa Oca há 23 anos. O protagonista é um humano da Terra e o Segundo Viajante. Ele precisa reunir os Sete Sigilos, apoiar as Seis Coroas, derrotar Azharel e usar o Coração do Limiar para voltar à Terra. Azharel foi Adrian Vale, o Primeiro Viajante.

## Direção atual
- Action RPG 2D Cartoon top-down para Android/celular.
- Um protagonista flexível, sem classes rígidas.
- Progressão planejada do nível 1 ao 100.
- Mundo aberto por regiões, com exploração, bosses, materiais, loot e crafting.
- Áreas e construções do mapa devem corresponder às missões da história.
- Regiões devem ter escala de exploração real, evitando mapas curtos demais.
- Interface deve ser adequada para touch e manter boa leitura em tela pequena.

## Estrutura Cartoon
- Cenas: `game/scenes/cartoon/`
- Scripts: `game/scripts/cartoon/`
- Menu: `CartoonMainMenu.tscn` + `cartoon_main_menu.gd`
- Estado/save: `cartoon_player_state.gd`
- Inventário: `cartoon_inventory_ui.gd`
- Crafting: `cartoon_crafting_ui.gd`
- Zoom: `cartoon_zoom_controls.gd`
- Story runtime/mapa principal: scripts `cartoon_*` correspondentes.

## Checkpoint da sessão — 30/09/2026
A versão Cartoon é a única base ativa. A **v0.16** adicionou save/menu; a **v0.17** adicionou inventário RPG visual; a **v0.18** adicionou HUD mobile compartilhado e progressão real nível 1–100. Próxima prioridade: refinar loot/consumíveis, melhorar feedback de combate e consolidar o layout final antes do próximo APK de teste.

## Regra para agentes
Se encontrar documentação antiga falando em “v0.6.x pixel art”, “REG_001 como versão atual” ou equivalente, trate-a como histórico e não como estado corrente. Não ressuscitar a implementação antiga.
