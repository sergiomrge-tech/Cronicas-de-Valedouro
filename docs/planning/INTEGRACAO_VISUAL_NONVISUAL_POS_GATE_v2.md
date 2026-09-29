# INTEGRAÇÃO VISUAL + NÃO VISUAL — PLANO PÓS-GATE v2

## Estado em 29/09/2026

Fonte visual atual:
- branch: `ccr-bb54cda9-tvw178`
- head no momento desta revisão: `9b1905296402aa8d77d81e72bb8ce63d7ba85b61`

Fonte sistêmica:
- branch: `gpt-nonvisual-etapa2`

Branch de integração antiga:
- `integracao-visual-nonvisual-20260929`
- base: `4954274...`

A branch de integração antiga está **54 commits visuais atrás** da fonte visual atual e não deve receber o merge final.

## Regra

NÃO fazer merge direto de `gpt-nonvisual-etapa2` sobre a branch visual atual.

A branch não visual divergiu fortemente:
- +101 commits próprios;
- a branch visual avançou +104 commits desde o ancestral comum;
- `game/scripts/main.gd` possui mais de mil linhas de mudanças não visuais e, ao mesmo tempo, a branch visual recebeu integração de arte, sombras, vida/NPC, Arquivo, Ato I/II e novos estados.

Sobrescrever `main.gd` causaria regressão visual e perda de integração recente.

## O que preservar da branch VISUAL como fonte de verdade

Sempre priorizar a versão atual de:
- `game/scripts/main.gd` como base do merge manual;
- REG_001 world/render/gameplay;
- `cast_shadow.gd`;
- `life_art.gd`;
- `character_art.gd`;
- ranges/zonas novas, incluindo Arquivo;
- pipeline de modeled assets;
- manifests e catálogo visual;
- assets APPROVED;
- world states e correções do Guardião;
- mapas e composições dos Atos I–II;
- skills de qualidade visual/map logic;
- capturas QA e documentação visual.

## O que aproveitar da branch NÃO VISUAL

Candidato a portar/cherry-pick por grupo, com revisão:

### Grupo A — sistemas isolados
- combat_rules.gd
- status_effects.gd
- enemy_ai_rules.gd
- enemy_balance.gd
- progression_rules.gd
- balance_rules.gd
- economy_rules.gd
- ability_system.gd
- passive_system.gd
- player_build_runtime.gd
- build_progression.gd
- equipment_system.gd
- crafting_system.gd

### Grupo B — campanha e persistência
- campaign_rules/state
- main_story_runtime
- quest_event_system
- canonical_* systems
- save_schema
- world_progression
- campaign_world_bridge

### Grupo C — bosses/dungeons
- boss_registry
- boss_phase_system
- story_boss_encounter
- dungeon_system
- dungeon_reward_system

### Grupo D — mundo/serviços
- city_service_system
- guild_contract_system
- fast_travel_system
- world_event_system
- demon_hierarchy

### Grupo E — testes
Portar os testes correspondentes somente depois de cada grupo, sem simplesmente copiar o workflow inteiro.

## Arquivos com alto risco

### game/scripts/main.gd
NÃO substituir.

Processo:
1. partir do `main.gd` visual mais novo;
2. adicionar preloads sistêmicos em blocos;
3. adicionar estados novos sem remover estados visuais;
4. portar funções por domínio;
5. resolver nomes/IDs usando o canon atual;
6. compilar/testar a cada grupo.

### .github/workflows/godot-gate.yml
Fazer união manual das suítes.

### game/scripts/save_schema.gd
Trazer a versão sistêmica e reconciliar qualquer flag/world-state criada após a divergência.

### documentos e JSONs canônicos
Comparar conteúdo antes de escolher. Ambas as branches evoluíram história em paralelo.

## Risco detectado

A branch não visual foi criada antes de grande parte do passe estrutural/visual atual.

Portanto:
- não usar sua renderização como referência;
- não reintroduzir assets removidos do catálogo;
- não reativar módulos antigos só porque paths físicos ainda existem;
- não sobrescrever o pipeline de sombras/grounding;
- não trocar cenas de Ato I/II por versões sistêmicas antigas.

## Nova estratégia de integração

Somente APÓS o Opus fechar o gate visual:

1. congelar o head visual aprovado;
2. criar nova branch de integração a partir desse head;
3. portar Grupo A;
4. Godot Gate;
5. portar Grupo B;
6. Godot Gate + migração de save;
7. portar Grupo C;
8. Godot Gate + boss/dungeon;
9. portar Grupo D;
10. Godot Gate + world events/serviços;
11. portar testes E2E;
12. executar vertical slice real;
13. capturas reais;
14. só então considerar merge para main.

## Gate de integração

Obrigatório:
- parser/import Godot 4.7.2;
- todas as suítes visuais existentes;
- todas as suítes sistêmicas portadas;
- zero referência quebrada;
- zero reintrodução de asset removido;
- save antigo migrando;
- Guardião e revanche preservados;
- Ato I/II preservados;
- vertical slice Cidade → missão → exploração → combate → loot → equipar → dungeon → boss → world state → save/load;
- 60 FPS como alvo no Android.

## Decisão

Enquanto o Opus trabalha no passe visual final:
- avançar especificações, contratos e auditoria;
- NÃO fundir gameplay pesado no branch visual;
- NÃO usar a branch de integração antiga como base final.

Isso reduz o risco de perder o avanço visual que o Diretor acabou de aprovar.
