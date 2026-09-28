# Crônicas de Valedouro — Revisão do pacote Claude — Lote 01

Data: 2026-09-28

## Resultado da revisão independente

O pacote `Cronicas_de_Valedouro_Claude_Handoff_Lote01_Completo.zip` foi extraído e inspecionado independentemente.

### Validação técnica confirmada
- 111 PNGs RGBA únicos;
- 2 atlas 2048×2048;
- 13 cenas;
- referências `res://` resolvidas;
- margens e pivôs válidos segundo os validadores do lote;
- zero pixels semitransparentes após endurecimento de alpha;
- zero arquivos temporários detectados pelos validadores;
- showcase com 338 tiles conectados, 122 objetos e 12 zonas;
- memória estimada dos atlas em RGBA8: 32 MiB;
- `tools/validate_lote01.py`: PASS;
- `tools/refine_claude/validate_refinado.py`: PASS.

### Gate visual
- APPROVED: 28
- REWORKED: 61
- HOLD: 22

O gate permanece PARCIAL. O lote não deve ser integrado integralmente ao projeto principal.

## Regra de continuidade adotada
1. Os 28 assets APPROVED podem ser considerados candidatos seguros para futura integração.
2. Os 61 REWORKED permanecem em quarentena artística até novo passe/refinamento e aprovação visual.
3. Os 22 HOLD ficam bloqueados para produção.
4. O pacote permanece isolado do build principal v0.6.
5. Nenhum screenshot foi tratado como captura real do Godot; as prévias do pacote são composições estáticas.
6. Godot 4.7.2 ainda não foi executado neste pacote.

## HOLD IDs
- city/blacksmith
- city/canal
- city/corner_inside
- city/corner_outside
- city/facade_medium
- city/facade_simple
- city/gate_small
- city/guild
- city/house_double_window
- city/market
- city/residence
- city/tavern
- city/wall_low
- dungeon/branch
- dungeon/corner_outside
- dungeon/crossing
- dungeon/curve
- dungeon/entrance
- dungeon/exit
- dungeon/narrow
- dungeon/secret_passage
- dungeon/wall_irregular

## Próximo uso recomendado
Usar o pacote como biblioteca de produção isolada. Quando houver integração no build v0.6, importar primeiro apenas os 28 APPROVED por IDs persistentes e manter REWORKED/HOLD fora do runtime até aprovação.
