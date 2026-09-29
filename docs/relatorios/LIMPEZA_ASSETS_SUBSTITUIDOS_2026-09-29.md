# Limpeza de assets substituídos — 29/09/2026

## Decisão do Diretor

Assets antigos substituídos pela revisão estrutural do Opus foram removidos do banco ativo para impedir reintrodução acidental.

## Registros removidos

### Bundle visual antigo
- city/wall_straight
- city/wall_vegetation
- city/gate_large
- city/house_door
- city/house_window
- city/roof_blue
- city/roof_red
- city/roof_wood
- city/store

### Intermediário estrutural
- val_house_body

`val_house_body` era um remendo intermediário anterior às casas completas em 3/4 e não deve voltar ao manifesto.

## Fontes atualizadas
- game/data/approved_visual_manifest.json
- game/data/modeled_parts/pro.json
- game/data/modeled_assets_manifest.json
- game/data/reg001_asset_catalog.json
- docs/catalog/REG001_ASSET_CATALOG.md

## Estado após limpeza
- bundle aprovado antigo vigente: 19 assets;
- modeled manifest: 700 assets;
- modeled APPROVED: 237;
- modeled MODELED_PENDING_GATE: 463;
- catálogo REG_001 APPROVED total: 256.

## Escopo da remoção

Esta limpeza remove os registros do banco/catálogos ativos. Arquivos físicos antigos podem permanecer no repositório temporariamente até uma varredura específica de referências provar que podem ser apagados sem quebrar cenas legadas, imports ou ferramentas.

Nenhum asset novo aprovado da revisão estrutural final foi removido.
