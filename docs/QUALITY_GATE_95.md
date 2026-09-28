# QUALITY GATE 95 — Crônicas de Valedouro

Este gate substitui a ideia subjetiva de "95% pronto" por 20 critérios verificáveis, cada um valendo 5 pontos.

## Critérios
1. Godot 4.7.2 importa o projeto sem parser error.
2. Validação estática passa.
3. Rotas principais do mundo permanecem conectadas.
4. Três pontes atravessáveis.
5. Movimento e colisão do herói válidos.
6. Controles touch permanecem presentes.
7. 8 direções e animação do herói válidas.
8. 10 criaturas com folhas de animação válidas.
9. Combate causa e recebe dano.
10. Loot/material funciona.
11. Inventário abre e pagina.
12. Equipamento altera estado/visual.
13. Guilda e progressão de missão funcionam.
14. Cidade -> bosque funciona.
15. Entrada/saída da dungeon funciona.
16. Guardião possui dois padrões especiais: carga e onda.
17. Boss drop/material e avanço funcionam.
18. Save/load preserva progresso e equipamento.
19. Auditoria visual cobre 14 cenas/estados.
20. Mundo vivo: fauna + partículas ambientais + vegetação procedural determinística.

**Gate 95:** pelo menos 19/20 critérios verdes, sem falha fatal.

O CI não substitui revisão artística humana. Capturas do artifact `valedouro-visual-qa` devem ser inspecionadas após cada alteração visual relevante.
