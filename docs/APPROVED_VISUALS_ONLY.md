# POLÍTICA VISUAL — SOMENTE APPROVED

Decisão do Diretor: **somente assets visualmente aprovados podem entrar no jogo principal.**

## Lote integrado
Foram integrados exatamente **28 assets** classificados como `APPROVED` no QA visual do Lote 01:
- 15 Cidade/Hub;
- 13 Dungeon.

Os 61 `REWORKED` e os 22 `HOLD` permanecem fora do renderer final.

## Atualização REG_001 Etapa 1
- Foram modelados 149 assets (Natureza, Cidade, Dungeon, Interiores) no mesmo ângulo/paleta dos APPROVED. **Não são APPROVED**: têm status `MODELED_PENDING_GATE`
  e só permanecem no renderer enquanto o Diretor não os recusar (mudar `status` no `modeled_assets_manifest.json` os remove).
- A arte v0.6 gerada por código (chão, fauna, herói, UI, marcos) é `LEGACY_BASELINE`: inalterada e fora do lote APPROVED.
- Onde faltava arte aprovada nada foi pintado por código: ver `MISSING_APPROVED_ASSET` em `docs/catalog/REG001_ASSET_CATALOG.md`.
- REWORKED (61) e HOLD (22) continuam fora do renderer; o teste `modeled_assets` varre `scripts/` contra referências a esses conjuntos.

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
