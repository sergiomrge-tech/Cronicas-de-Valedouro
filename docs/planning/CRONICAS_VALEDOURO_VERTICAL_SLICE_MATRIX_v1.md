# CRÔNICAS DE VALEDOURO — MATRIZ DE PRODUÇÃO DO PRIMEIRO VERTICAL SLICE v1

**Data:** 2026-09-28  
**Região:** `REG_001` — Berço de Valedouro  
**Estado:** planejamento implementável. IDs novos abaixo permanecem `PROPOSED` até validação no banco/cânone.  
**Regra de teste:** Sergio só volta a testar quando o loop Cidade → Campo → Combate → Loot → Equipar → Dungeon → Boss → Save/Load estiver funcional.

## 1. Objetivo da primeira build testável

Provar, em uma única sessão curta:
1. boot limpo no Godot 4.7.2;
2. herói modular e controle mobile;
3. trecho navegável de Valedouro;
4. saída para Campos do Vale e Bosque Inicial;
5. combate contra dois arquétipos;
6. loot, inventário e equipamento visual;
7. progressão de quest por ID;
8. dungeon curta;
9. Guardião com dois padrões e telegraph;
10. save/load completo do loop.

Não bloquear esta build por crafting profundo, oito regiões, nível 100 completo, áudio final, guerra demoníaca completa ou Android release final.

## 2. Zonas mínimas

| Prioridade | ID | Conteúdo mínimo | Regra |
|---|---|---|---|
| MUST | `SUB_REG001_HUB` | praça/rua, saída, NPC principal, serviço simples | layout manual |
| MUST | `SUB_REG001_FIELDS` | rota de saída + encontros de Lobo | macro manual + decoração controlada |
| MUST | `SUB_REG001_WOODS` | clareira + segundo arquétipo | rotas manuais |
| MUST | `SUB_REG001_DUNGEON_ENTRY` | arco/porta/telegraph visual | manual |
| MUST | `SUB_REG001_GUARDIAN_DUNGEON` | corredor, sala de combate, checkpoint e arena | 100% manual |
| VSLICE+ | `SUB_REG001_RUINS` | mecanismo e lore | manual |
| VSLICE+ | `SUB_REG001_ELITE_GROVE` | elite opcional + baú | manual |

## 3. Player e sistemas

| Prioridade | ID PROPOSED | Entrega |
|---|---|---|
| MUST | `SYS_PLAYER_MODULAR_001` | `Player.tscn` CharacterBody2D; corpo/armadura/arma/VFX separados |
| MUST | `SYS_PLAYER_MOVEMENT_001` | 8 direções, câmera, colisão, aceleração consistente |
| MUST | `SYS_MOBILE_INPUT_001` | joystick + ataque + interação + poção com multitouch |
| MUST | `SYS_COMBAT_BASE_001` | hitbox/hurtbox, damage, recovery, knockback/stagger básico |
| MUST | `SYS_INVENTORY_001` | bolsa, equipar/desequipar, comparação mínima |
| MUST | `SYS_EQUIPMENT_VISUAL_001` | paperdoll básico refletindo arma/armadura |
| MUST | `SYS_LOOT_001` | moeda/material/equipamento por loot table ID |
| MUST | `SYS_QUEST_001` | estados/objetivos por quest_id, sem integer mágico |
| MUST | `SYS_SAVE_V5_001` | posição segura, HP, ouro, inventário, equipamento, quest e boss flag |
| MUST | `SYS_DIALOGUE_001` | diálogo por perfil/estado e gatilho de quest |
| RECOMMENDED | `SKILL_DODGE_001` | esquiva com stamina/invulnerabilidade configurável |

## 4. Inimigos mínimos

| Prioridade | ID | Papel | Comportamento mínimo |
|---|---|---|---|
| MUST | `MON_REG001_WOLF_001` | melee perseguidor | aggro, chase, bite, hurt, death, leash |
| MUST | `MON_REG001_SPIDER_001` | segundo arquétipo | aproximação/emboscada, ataque diferente, leash |
| VSLICE+ | `ELITE_REG001_FOREST_001` | elite opcional | telegraph mais forte, material incomum |
| MUST | `BOSS_REG001_GUARDIAN_001` | boss da build | 2 padrões, telegraph, janela de vulnerabilidade, flag persistente |

**Decisão de escopo:** usar Aranha como segundo inimigo da primeira build em vez de Javali, pois cria comportamento mais distinto e também serve ao Bosque/Dungeon. Javali permanece para a expansão da REG_001.

## 5. Encontros mínimos

- `ENC_REG001_FIELD_001` → `EGRP_REG001_WOLF_001` → 1 Lobo.
- `ENC_REG001_FIELD_002` → `EGRP_REG001_WOLF_002` → 2 Lobos.
- `ENC_REG001_WOODS_001` → `EGRP_REG001_SPIDER_001` → 1 Aranha.
- `ENC_REG001_WOODS_002` → `EGRP_REG001_MIX_001` → 1 Lobo + 1 Aranha.
- `ENC_REG001_DUNGEON_001` → grupo manual, sem spawn procedural.
- `ENC_REG001_GUARDIAN_001` → boss único; sem respawn durante progressão normal.

Todos os encontros comuns usam leash. Kill de quest só conta após ativação da quest correspondente.

## 6. Quest flow da primeira build

### MUST para o primeiro teste
- `QUEST_A01_REG001_001` — Chegada.
- `QUEST_A01_REG001_002` — Arredores.
- `QUEST_A01_REG001_003` — Contrato dos Lobos.
- `QUEST_A01_REG001_006` — Ruínas/abertura de acesso; pode ser reduzida a um gatilho funcional na primeira build.
- `QUEST_A01_REG001_007` — O Guardião.
- `QUEST_A01_REG001_008` — Retorno/pós-boss.

### VSLICE+
- `QUEST_A01_REG001_004` — Sinais no Bosque.
- `QUEST_A01_REG001_005` — Elite do Bosque opcional.

Regras obrigatórias: progresso persistente; recompensa única; kills anteriores à quest não contam; títulos nunca são chave de dados.

## 7. NPCs/serviços mínimos

| Prioridade | ID PROPOSED | Função |
|---|---|---|
| MUST | `NPC_REG001_GUIDE_001` | NPC principal do hub / início e avanço de quest |
| MUST | `NPC_REG001_BLACKSMITH_001` | equipamento/upgrade e pós-boss básico |
| MUST | `NPC_REG001_GUILD_001` | contrato dos Lobos / quadro simples |
| VSLICE+ | `NPC_REG001_MERCHANT_001` | comprar/vender/consumíveis |
| VSLICE+ | `NPC_REG001_ALCHEMIST_001` | poção/consumíveis |
| VSLICE+ | `NPC_REG001_TAVERN_001` | descanso/save/rumor |

Nenhum nome de exibição novo foi definido aqui; preservar lore e aguardar os nomes canônicos existentes/validados.

## 8. Itens, materiais e loot mínimos

| Prioridade | ID PROPOSED | Uso |
|---|---|---|
| MUST | `ITEM_WPN_SWORD_STARTER_001` | arma inicial |
| MUST | `ITEM_CONS_HEALTH_POTION_001` | cura |
| MUST | `MAT_REG001_WOLF_LEATHER_001` | material frequente de Lobo |
| MUST | `MAT_REG001_SPIDER_SILK_001` | material da Aranha |
| MUST | `MAT_REG001_GUARDIAN_CORE_001` | drop garantido do Guardião |
| MUST | `ITEM_WPN_SWORD_GUARDIAN_001` | recompensa/crafting pós-boss |
| VSLICE+ | `ITEM_ARMOR_FOREST_001` | equipamento regional controlado |
| VSLICE+ | `RECIPE_WPN_GUARDIAN_BLADE_001` | receita desbloqueada pelo boss |

Equipamento aleatório raro continua cadenciado; nenhum lendário aleatório no início.

## 9. Assets Claude liberados para futura integração nesta build

Usar **somente** estes IDs do Lote 01 que já estão `APPROVED`, e apenas depois do Godot Gate da base:

### Cidade/Hub
- `city/floor_stone_clean`
- `city/floor_stone_worn`
- `city/floor_stone_moss`
- `city/water_edge`
- `city/wall_straight`
- `city/wall_vegetation`
- `city/gate_large`
- `city/house_door`
- `city/house_window`
- `city/roof_blue`
- `city/roof_red`
- `city/roof_wood`
- `city/store`
- `city/tree_green`
- `city/tree_autumn`

### Dungeon
- `dungeon/floor_stone`
- `dungeon/floor_broken`
- `dungeon/wall_straight`
- `dungeon/corner_inside`
- `dungeon/arch`
- `dungeon/door`
- `dungeon/rail_straight`
- `dungeon/crystal_blue`
- `dungeon/crystal_purple`
- `dungeon/torch`
- `dungeon/emissive_crystal`
- `dungeon/spikes`
- `dungeon/corridor_straight`

### Regra de composição para evitar HOLD
A primeira dungeon pode ser montada com corredor reto + salas usando piso/parede/arch/door aprovados. **Não depender** de `dungeon/entrance`, `branch`, `curve`, `crossing` ou `secret_passage`, que continuam HOLD. A entrada externa pode ser composta manualmente com `dungeon/arch` + `dungeon/door` + vegetação aprovada, sem usar o asset HOLD `dungeon/entrance`.

Da mesma forma, a primeira área urbana não deve depender de `city/blacksmith`, `city/guild`, `city/tavern` ou módulos de canto HOLD. Serviços podem funcionar em um trecho de hub menor até o refinamento artístico desses prédios.

## 10. Ordem de implementação após o Godot Gate

1. Promover v0.6.1 estável sem adicionar gameplay novo.
2. J2 — extrair Player de `main.gd` para `Player.tscn`.
3. J3 — separar input mobile e validar multitouch.
4. J4 — construir trecho de hub/campos/bosque, importando apenas assets APPROVED necessários.
5. J5 — `MON_REG001_WOLF_001` modular.
6. J6 — loot/inventário/equipamento por ID.
7. J7 — `MON_REG001_SPIDER_001`.
8. J8 — quests 001–003 por ID.
9. J9 — dungeon curta com peças APPROVED.
10. J10 — `BOSS_REG001_GUARDIAN_001` com 2 padrões.
11. J11 — save/load completo e boss flag.
12. J12 — UI, legibilidade mobile, colisões, Y-sort, performance e QA final.

## 11. Gate para chamar Sergio para testar

Não entregar lote técnico. Só pedir teste quando todos os itens abaixo passarem:
- Godot 4.7.2 abre sem erro fatal;
- mover + atacar simultaneamente no touch;
- dois inimigos combatíveis;
- dano/morte/loot funcionam;
- inventário e equipar funcionam;
- equipamento muda visual básico;
- dungeon abre e fecha corretamente;
- Guardião derrotável;
- quest/boss flag persistem;
- fechar/reabrir preserva progresso;
- ZIP passa extração independente, CRC, testes e SHA-256.