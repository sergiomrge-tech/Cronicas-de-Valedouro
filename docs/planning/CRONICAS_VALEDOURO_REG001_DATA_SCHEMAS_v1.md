# CRÔNICAS DE VALEDOURO — REG_001 DATA SCHEMAS v1

## Objetivo
Padronizar dados antes da implementação.

---

# NPC

```json
{
  "npc_id": "NPC_REG001_EXAMPLE_001",
  "region_id": "REG_001",
  "role": "blacksmith",
  "dialogue_profile_id": "DIALOGUE_EXAMPLE",
  "quest_giver_ids": [],
  "shop_id": null
}
```

---

# ENCOUNTER

```json
{
  "encounter_id": "ENC_REG001_FIELD_001",
  "subzone_id": "SUB_REG001_FIELDS",
  "enemy_group_id": "EGRP_REG001_WOLF_001",
  "respawn_policy": "rest",
  "activation_radius": 260,
  "leash_radius": 420
}
```

---

# CHUNK

```json
{
  "chunk_id": "CHUNK_REG001_FIELD_001",
  "region_id": "REG_001",
  "biome_id": "BIOME_VALLEY",
  "procedural_rule_set_id": "PROC_VALLEY_FIELD_001",
  "landmark_ids": [],
  "encounter_ids": []
}
```

---

# PROCEDURAL PROP

```json
{
  "asset_id": "ENV_TREE_GREEN_LARGE_001",
  "biome_tags": ["vale", "floresta"],
  "spawn_weight": 0.45,
  "min_spacing": 180,
  "can_rotate": false,
  "can_mirror": true,
  "terrain_affinity": ["grass", "dirt"],
  "collision_profile": "tree_large"
}
```

---

# RECIPE

```json
{
  "recipe_id": "RECIPE_WPN_GUARDIAN_BLADE_001",
  "output_def_id": "ITEM_WPN_SWORD_GUARDIAN_001",
  "station_id": "STATION_BLACKSMITH",
  "ingredients": [],
  "gold_cost": 0,
  "unlock_condition": "boss_defeated:BOSS_REG001_GUARDIAN_001"
}
```

---

# QUEST

```json
{
  "quest_id": "QUEST_A01_REG001_003",
  "region_id": "REG_001",
  "objectives": [
    {
      "type": "kill",
      "target_ids": ["MON_REG001_WOLF_001"],
      "required_count": 3
    }
  ]
}
```

---

# WORLD FLAG

Formato:
`namespace:key`

Exemplos:
- `boss_defeated:BOSS_REG001_GUARDIAN_001`
- `quest_complete:QUEST_A01_REG001_007`
- `landmark_discovered:LANDMARK_REG001_RUINS_001`

---

# REGRAS

- IDs nunca dependem do nome exibido;
- JSON inválido falha no import;
- referência inexistente falha no validador;
- alias não pode formar ciclo.