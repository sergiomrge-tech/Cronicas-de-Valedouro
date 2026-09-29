# Aprovação visual — lote estrutural Opus — 29/09/2026

## Decisão do Diretor

O Diretor aprovou visualmente o lote estrutural produzido/revisado pelo Opus após o Ato II.

## Escopo aprovado

Foram promovidos **238 assets** de `MODELED_PENDING_GATE` para `APPROVED`.

Origem da comparação:
- base anterior à revisão estrutural: `a971b43b36665fddce9c88c95b3fc0cea10ef805`;
- revisão estrutural analisada: `77bbeca704729f06d32c7dbbbdca001a67be4f49`.

O escopo corresponde a todos os PNGs modelados novos ou alterados nesse intervalo.

### Distribuição por grupo

- nature: 176
- city: 62

## Conteúdo incluído

A aprovação inclui, entre outros:
- kits multiângulo de muralhas, paliçadas, cercas, muretas e paredes orgânicas;
- variantes de cantos;
- muralha intacta/reparada/rompida;
- barricadas;
- paredes vivas e estruturas da Floresta Ancestral;
- casas completas modeladas em 3/4;
- Guilda e Arquivo refeitos em 3/4;
- torre de junção de muralha;
- demais assets estruturais novos/alterados da revisão.

## Persistência

A fonte de verdade é `game/data/modeled_assets_manifest.json`.

Cada item aprovado contém:
- `status: APPROVED`;
- `approved_by: Director`;
- `approval_date: 2026-09-29`;
- motivo da aprovação.

`game/tools/modeling/manifest_lib.py` foi atualizado para preservar esses metadados quando o manifesto for regenerado.

## Catálogo

Após a promoção:
- APPROVED totais no catálogo REG_001: **266**;
- MODELED_PENDING_GATE restantes: **463**.

Os 463 restantes **não** foram aprovados por esta decisão.

## Regra futura

Novos assets continuam nascendo como `MODELED_PENDING_GATE` e só podem ser promovidos após nova decisão explícita do Diretor.
