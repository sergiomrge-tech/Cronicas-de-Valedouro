# CRÔNICAS DE VALEDOURO — AUDITORIA DE CONSISTÊNCIA DA HISTÓRIA PRINCIPAL

**Data:** 2026-09-29  
**Branch:** `ccr-bb54cda9-tvw178`  
**Fontes auditadas:** `game/data/main_story_v1.json` e `game/data/story_locations_v1.json`.

## Resultado

**APROVADO — 0 erros e 0 avisos na estrutura canônica atual.**

- 8 atos.
- 49 quests na campanha principal.
- 47 locais canônicos.
- Cadeia principal com 49 quests alcançáveis.
- Início: `Q_MS01_ARRIVAL`.
- Final: `Q_MS08_CHOICE`.
- Nenhum loop na cadeia `next`.
- Nenhuma quest aponta para local inexistente.
- Nenhum local referencia quest inexistente.
- Todos os backlinks local ↔ missão são coerentes.
- Nenhuma quest principal ficou fora da cadeia.

## Quests por ato

| Ato | Quantidade |
|---|---:|
| I | 8 |
| II | 6 |
| III | 6 |
| IV | 6 |
| V | 6 |
| VI | 5 |
| VII | 5 |
| VIII | 7 |

## Gates para futuras alterações

Qualquer modificação em `main_story_v1.json` ou `story_locations_v1.json` deve preservar:

1. IDs únicos de quests e locais;
2. toda quest com `loc` existente;
3. todo `next` apontando para quest existente ou vazio somente no final;
4. cadeia iniciando em `start_quest` e terminando em `final_quest`;
5. ausência de loops;
6. backlinks `locations[].missions[]` coerentes com `quests[].loc`;
7. nenhuma quest principal inalcançável.

## Observação de produção

A consistência dos dados narrativos está pronta para orientar a modelagem e implantação dos locais. Isso não significa que os 47 locais já existam fisicamente no runtime: vários continuam `TO_BUILD` por definição do plano de construções.

A implantação deve seguir `docs/planning/MAIN_STORY_WORLD_TOPOLOGY_v1.md` e, para o Ato II, `docs/planning/LOTE02_ATO2_STORY_TO_MAP_v1.md`.
