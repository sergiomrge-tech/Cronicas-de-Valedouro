# POLÍTICA VISUAL — SOMENTE APPROVED

Decisão do Diretor: **somente assets visualmente aprovados podem entrar no jogo principal.**

## Lote integrado
Foram integrados exatamente **28 assets** classificados como `APPROVED` no QA visual do Lote 01:
- 15 Cidade/Hub;
- 13 Dungeon.

Os 61 `REWORKED` e os 22 `HOLD` permanecem fora do renderer final.

## Regras
- `REWORKED` não significa aprovado.
- `HOLD` nunca entra no jogo.
- Não criar placeholder pintado por código para substituir asset final ausente.
- Vegetação procedural pode distribuir assets, mas o sprite usado precisa estar APPROVED.
- Se um bioma/serviço ainda não tem asset APPROVED, ele permanece visualmente incompleto até receber arte aprovada.
- Screenshots de aprovação devem vir de execução real no Godot 4.7.2.

## Renderer atual
A cidade usa os pisos, paredes, portão, módulos de casa, telhados, loja e árvores APPROVED.
A dungeon usa piso, paredes, esquina, arco, porta, trilho, cristais, tochas, spikes e corredor APPROVED.
Interiores sem kit aprovado específico usam somente os módulos arquitetônicos APPROVED já disponíveis; props não aprovados foram removidos da renderização.
