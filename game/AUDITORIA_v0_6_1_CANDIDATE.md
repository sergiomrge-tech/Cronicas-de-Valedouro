# Crônicas de Valedouro — Auditoria v0.6.1 CANDIDATE

**Data:** 2026-09-28  
**Base:** `Cronicas_de_Valedouro_v0_6_0.zip`  
**Alvo nativo:** Godot 4.7.2  
**Estado:** candidato técnico; ainda NÃO é release jogável aprovada.

## Objetivo desta estabilização

Preparar a v0.6 para o Godot Gate estrito sem alterar gameplay, arte, mapa, balanceamento ou formato do save.

## Mudanças realizadas

### Tipagem / warnings-as-errors
- `scripts/main.gd`: removida inferência `:=`; estado, UI, matemática, save/load e desenho receberam tipos explícitos onde necessário.
- `scripts/world_map.gd`: constantes e locais tipados; `abs()` em cálculos `float` trocado por `absf()`.
- `scripts/loot_system.gd`: constantes e locais tipados sem alterar probabilidades/tabelas.
- testes existentes tiveram apenas tipagem explícita nos locais com `:=`.
- nenhum GDScript deste candidato contém `:=`.

### Save/load
- o formato continua em `version: 4`.
- JSON agora é estreitado de `Variant` para `Dictionary` somente após validação.
- `kills` malformado deixa de poder contaminar diretamente um `Dictionary` tipado.

### Catálogo persistente de assets
- criado `data/asset_catalog.json`.
- 122 arquivos catalogados: 121 PNG + `PixelifySans.ttf`.
- 119 estão marcados `LEGACY_RUNTIME`.
- 3 originais de `assets/world_sources/` estão marcados `SOURCE_ONLY`.
- todos recebem IDs persistentes `AST_V06_*`.
- nenhum asset do Lote 01 do Claude foi integrado.

### Loader de catálogo
- criado `scripts/asset_catalog.gd`.
- criado teste nativo `tests/asset_catalog.gd`.
- criado gerador reproduzível `tools/build_asset_catalog.py`.

## Integridade em relação à v0.6 original

Comparação SHA-256 arquivo a arquivo contra extração independente da base:
- 7 arquivos existentes alterados, todos GDScript e somente para tipagem/robustez;
- 5 arquivos funcionais novos antes desta auditoria;
- 0 arquivos removidos;
- **0 arquivos em `assets/` alterados**.

Arquivos existentes alterados:
- `scripts/main.gd`
- `scripts/world_map.gd`
- `scripts/loot_system.gd`
- `tests/loot_progression.gd`
- `tests/monster_animation.gd`
- `tests/smoke.gd`
- `tests/world_travel.gd`

Arquivos funcionais novos:
- `data/asset_catalog.json`
- `scripts/asset_catalog.gd`
- `tests/asset_catalog.gd`
- `tools/build_asset_catalog.py`
- `tools/validate_v0_6_1.py`

## Gates executados neste ambiente

### PASS — validador legado
`python3 tools/validate_v0_6.py`

Resultado esperado confirmado:
`STATIC PASS v0.6`

### PASS — gate estático v0.6.1
`python3 tools/validate_v0_6_1.py`

Resultado confirmado antes do empacotamento:
`STRICT STATIC PASS v0.6.1-candidate`

O gate checa:
- invariantes da v0.6;
- main scene;
- ausência de `:=` em runtime/testes;
- referências literais `res://`;
- catálogo completo e IDs únicos;
- paths de assets;
- loader/teste do catálogo;
- temporários e resíduos de edição.

## Gate ainda obrigatório

**NÃO VALIDADO NO GODOT 4.7.2 NESTE AMBIENTE.**

O binário oficial foi localizado, mas a transferência do executável foi bloqueada pela rede do ambiente. Portanto ainda faltam:
1. importar projeto no Godot 4.7.2;
2. parser sem erros/warnings tratados como erro;
3. iniciar `res://scenes/Main.tscn`;
4. executar `tests/smoke.gd`;
5. executar `tests/world_travel.gd`;
6. executar `tests/monster_animation.gd`;
7. executar `tests/hero_animation.gd`;
8. executar `tests/loot_progression.gd`;
9. executar `tests/asset_catalog.gd`.

Somente após isso o candidato pode virar **v0.6.1 estável/jogável**.
