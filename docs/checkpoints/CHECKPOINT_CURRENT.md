# CHECKPOINT ATUAL — Vertical Slice / Refinamento 95

**Data:** 2026-09-28  
**Diretor:** Sergio  
**Engine:** Godot 4.7.2  
**Repositório:** sergiomrge-tech/Cronicas-de-Valedouro  
**Estado:** primeiro loop jogável técnico validado; refinamento visual/sistêmico em andamento.

## Confirmado no GitHub/Godot

O Run 10 do workflow `Godot 4.7.2 Gate + Visual QA` concluiu com sucesso.

Passam atualmente:
- import/parser Godot 4.7.2;
- static validators;
- smoke;
- world travel;
- hero animation;
- monster animation;
- loot progression;
- asset catalog;
- vertical slice gate;
- 14 capturas visuais reais.

O loop técnico já cobre:
Cidade -> Guilda -> Bosque -> Combate -> Loot -> Equipamento -> Dungeon -> Guardião -> Save/Load.

## Evolução visual atual

Implementado:
- vegetação procedural determinística;
- árvores com maior volume e sombra de contato;
- jitter visual para reduzir grade procedural;
- fauna por região;
- partículas ambientais por bioma;
- assentamentos secundários enriquecidos;
- dungeon com arena/runa/tochas;
- guilda, ferreiro e alquimia com dressing adicional;
- Guardião com carga e onda circular.

Ainda abaixo do padrão final:
- interiores ainda precisam de arte mais refinada;
- dungeon precisa de modularidade visual real;
- vila/arredores precisam de equalização artística;
- gelo/deserto precisam de maior densidade;
- vilarejos secundários ainda precisam de assets próprios;
- Player continua concentrado em main.gd;
- quest prototype ainda usa integer;
- save ainda precisa migrar para schema v5/IDs;
- performance Android ainda precisa de profiling/chunks.

## Fonte de verdade operacional

Ler nesta ordem:
1. CLAUDE.md
2. docs/README_CONTINUE_AQUI.md
3. docs/checkpoints/CHECKPOINT_CURRENT.md
4. docs/QUALITY_GATE_95.md
5. docs/roadmap/ROADMAP_REFINAMENTO_95_v1.md
6. docs/planning/CRONICAS_VALEDOURO_VERTICAL_SLICE_MATRIX_v1.md

## Próxima execução

Prioridade imediata:
- R95-20 interiors/dungeon;
- R95-01 vila/arredores;
- R95-02/R95-03 vegetação/transições.

Depois:
- modularização do Player;
- quest IDs;
- save v5;
- performance Android;
- novo Visual QA.

## Regra de teste do Diretor

Não pedir teste manual a cada lote. Enviar screenshots reais quando houver evolução visual significativa. Entregar novo ZIP apenas quando o candidato estiver substancialmente mais refinado e após Godot Gate + varredura + integridade do pacote.
