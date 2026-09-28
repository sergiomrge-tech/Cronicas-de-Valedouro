# Auditoria v0.6 — antes do empacotamento

Data: 28/09/2026.

## Aprovado no ambiente atual

- 121 PNGs abertos e verificados sem erro de integridade.
- 86 texturas declaradas em `main.gd` existem em `assets/`.
- Todos os `load/preload("res://...")` literais apontam para arquivos existentes.
- 8 arquivos GDScript sem funções duplicadas e com balanço básico de parênteses/colchetes/chaves aprovado.
- 8 scripts Python analisados por AST sem erro de sintaxe.
- Nenhum `.pyc`, `__pycache__`, `.tmp`, `.log` ou `.bak` incluído no projeto.
- `tools/validate_v0_6.py`: PASS.
- Simulação estática de conectividade em grade: 5.518 células alcançáveis; amostras de floresta, gelo, deserto, vale e as três pontes permaneceram conectadas.
- Dez folhas de monstros validadas em grade 5×8 = 40 quadros por criatura.

## Limite da auditoria

O ambiente desta sessão não contém executável Godot. Portanto os testes `tests/*.gd`, parsing real pelo engine, renderização, toque, FPS, APK e AAB não foram executados. A v0.6 deve ser aberta no Godot 4.3+ antes de ser marcada como build aprovada.
