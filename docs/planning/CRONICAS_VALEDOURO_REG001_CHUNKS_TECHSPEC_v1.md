# CRÔNICAS DE VALEDOURO — REG_001 CHUNKS TECH SPEC v1

## Objetivo
Preparar o mapa híbrido para bom desempenho no Godot 4.7.2 e Android.

---

# 1. ESTRUTURA

REG_001 dividida em células/chunks lógicos.

Tamanho inicial sugerido para protótipo:
- 512×512 px OU
- 768×768 px

Não travar valor final antes de benchmark.

---

# 2. CATEGORIAS DE CHUNK

- HUB
- FIELD
- FOREST
- RUINS
- DUNGEON_ENTRANCE
- INTERIOR
- DUNGEON

Cada chunk possui:
```text
chunk_id
region_id
biome_id
bounds
landmark_ids[]
encounter_ids[]
procedural_rule_set_id
neighbor_ids[]
```

---

# 3. CARREGAMENTO

Carregar:
- chunk atual;
- vizinhos imediatos;
- pré-carregamento de direção provável.

Descarregar:
- chunks distantes sem entidades persistentes ativas.

---

# 4. CONTEÚDO MANUAL

Nunca procedural:
- cidade;
- NPCs;
- quest triggers;
- portas;
- pontes críticas;
- boss arena;
- loot único;
- landmarks principais;
- dungeon principal.

---

# 5. CONTEÚDO PROCEDURAL

Permitido:
- árvores;
- pedras;
- grama;
- flores;
- pequenos troncos;
- arbustos;
- detritos;
- fauna ambiente.

---

# 6. ZONAS DE EXCLUSÃO

Cada chunk pode declarar polygons/rects onde procedural não entra.

Tipos:
- road_clearance
- combat_clearance
- quest_clearance
- landmark_clearance
- door_clearance
- bridge_clearance

---

# 7. DETERMINISMO

Seed:
`hash(world_seed, region_id, chunk_id, layer_id)`

Mesmo save = mesma decoração.

---

# 8. CULLING

Props decorativos:
- culling por distância;
- sem `_process()` individual;
- evitar centenas de scripts em objetos estáticos.

---

# 9. COLISÃO

Árvores/rochas grandes:
colisão simples.

Grama/flores:
sem colisão.

Props médios:
colisão somente se necessário.

---

# 10. NAVIGAÇÃO

Nunca criar obstáculo invisível sem correspondência visual.

Nav/movimento deve refletir:
- muros;
- água profunda;
- rochas;
- prédios;
- árvores grandes.

---

# 11. DEBUG

Modo debug:
- exibir bounds de chunk;
- IDs;
- spawn points;
- exclusion zones;
- seed;
- objetos gerados.

---

# 12. SAVE

Persistir apenas o que muda:
- baú aberto;
- objeto único coletado;
- quest object;
- boss state;
- mudança narrativa.

Decoração regenerável volta pela seed.