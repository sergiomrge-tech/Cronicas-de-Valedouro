# Interface Cartoon v0.21 — candidata

Solicitação: ajustar o layout e HUD de todo o jogo. A implementação usa exclusivamente a base Cartoon e mantém a entrada `CartoonMainMenu.tscn`.

## Resultado

- HUD compartilhado pelos oito atos: retrato, vida, XP, nível, ouro e região em cartão compacto; objetivo com botão de expansão para consultar a instrução completa.
- Paleta jade, creme e dourado, bordas e estados de foco/seleção consistentes em todos os painéis.
- Joystick visível, ações de ataque/uso, mapa, forja, bolsa, pausa e zoom reposicionados conforme a área disponível.
- Pausa real, continuar e salvar/voltar ao menu. Escape fecha o painel ativo ou abre a pausa. A posição do herói é preservada ao voltar ao menu.
- Menu inicial com composição Cartoon, opções e confirmação de exclusão centralizadas; exclusão fica nas opções.
- Bolsa com filtros e seleção coerentes, detalhes e comparação; forja com materiais e receitas existentes; overlays com fundo escurecido e bloqueio de interação atrás do painel.
- Mapas das oito regiões e escolha final usam o mesmo acabamento. Os dois destinos finais canônicos continuam disponíveis.

## Implementação e continuidade

`cartoon_game_layout.gd` substitui oito construções duplicadas de HUD. `cartoon_ui_theme.gd` concentra o tema e `cartoon_ui_placement.gd` posiciona componentes e ajusta painéis à área útil. Em telas estreitas, atalhos passam para a faixa inferior; ao expandir um objetivo que ocuparia essa faixa, os atalhos ficam ocultos até recolher. Painéis grandes são reduzidos proporcionalmente para caber. A área segura reportada por Android/iOS é considerada, mas ainda requer teste em aparelho.

A bolsa e a forja continuam usando os sistemas persistentes existentes. História, IDs, missões, crafting, equipamento, dano e escolhas finais foram preservados. A arte v0.20 continua candidata `MODELED_PENDING_GATE`.

## Validação executada

Engine disponível: Godot **4.6.3.stable.official.7d41c59c4**. Todos os **21 testes Cartoon** passaram, incluindo campanha, saves, inventário, crafting, zoom, progressão e novos testes visuais/UI. Após os ajustes finais de retrato e filtros, os seis testes diretamente afetados foram repetidos.

`cartoon_ui_v021.gd` verifica as oito regiões e cinco dimensões lógicas: 640×360, 800×450, 960×540, 1200×540 e 1024×768. Verifica limites de painéis e controles, exclusão mútua de modais, toque nativo simulado, arraste/liberação fora do joystick, pausa, retorno ao menu com posição salva, menu e escolha final.

Capturas reais em Godot/OpenGL Compatibility com Mesa llvmpipe: oito comparações antes/depois e dezessete imagens de regiões, formatos de tela e painéis. Veja [o comparador](visual_qa/cartoon_ui_v021/review.html).

**Pendentes:** gates oficiais Godot 4.7.2, exportação e ergonomia em Android real, desempenho no dispositivo e aprovação visual do Diretor. Este pacote é uma candidata de código/arte para revisão, não uma build Android aprovada. Nenhuma alteração foi enviada ao GitHub nesta sessão.
