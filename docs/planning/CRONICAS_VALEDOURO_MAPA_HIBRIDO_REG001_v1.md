# CRÔNICAS DE VALEDOURO — MAPA HÍBRIDO REG_001 v1

## Objetivo
Definir a arquitetura do primeiro mapa jogável de Crônicas de Valedouro combinando level design manual e distribuição procedural controlada.

## Princípio central
O mundo NÃO será totalmente procedural.

Usar:
- layout manual para cidade, dungeons, bosses, quests, landmarks e rotas narrativas;
- procedural controlada para árvores, pedras, grama, arbustos, troncos, flores, detritos, pequenas variações de terreno e fauna ambiente.

Assim preservamos:
- direção artística;
- ritmo narrativo;
- leitura de combate;
- segredos;
- landmarks;
- variedade visual.

---

# REG_001 — BERÇO DE VALEDOURO

## Zonas principais
1. Cidade/Hub de Valedouro
2. Estrada Norte
3. Campos do Vale
4. Bosque Inicial
5. Ruínas Antigas
6. Entrada da Dungeon
7. Dungeon do Guardião
8. Área opcional de elite
9. Pequenos segredos e desvios
10. Pontes e cursos d'água

---

# ESTRUTURA ESPACIAL

## Hub
Totalmente manual.

Contém:
- praça;
- ferreiro;
- loja;
- taverna;
- guilda;
- alquimista;
- ponto de descanso;
- NPCs;
- entrada/saída da cidade.

## Estrada principal
Manual como spline/corredor navegável.
Vegetação lateral pode ser procedural.

## Campos
Macro layout manual.
Distribuição procedural:
- pedras;
- arbustos;
- árvores isoladas;
- flores;
- madeira caída;
- cercas quebradas;
- pequenos props.

## Bosque
Rotas principais manuais.
Densidade de vegetação procedural com regras de espaçamento e exclusão.

## Ruínas
Totalmente manuais nas áreas de interação.
Detritos e vegetação secundária podem ser procedurais.

## Dungeon
100% manual.
Nada de procedural na geometria principal do primeiro Vertical Slice.

---

# SEEDS

Usar seed persistente por região.

Exemplo:
`world_seed`
`region_seed`

O jogador deve ver a mesma composição ambiental ao recarregar save, salvo eventos narrativos.

---

# ZONAS DE EXCLUSÃO

Nunca spawnar proceduralmente em:
- portas;
- pontes;
- NPCs;
- entradas;
- boss arenas;
- triggers;
- caminhos mínimos;
- locais de quest;
- pontos de câmera;
- checkpoints;
- colisões críticas.

---

# BIOME TAGS

Cada prop procedural deve declarar:
- biome_tags
- spawn_weight
- min_spacing
- scale_range
- can_rotate
- can_mirror
- terrain_affinity
- max_slope
- collision_profile
- nav_blocking

Exemplos de tags:
- vale
- campo
- floresta
- margem_agua
- ruina
- dungeon_entrada

---

# CAMADAS DE DISTRIBUIÇÃO

## Camada 1 — cobertura
- grama;
- flores;
- pequenas folhas;
- pedras pequenas.

## Camada 2 — props médios
- arbustos;
- troncos;
- caixas abandonadas;
- cercas.

## Camada 3 — elementos grandes
- árvores;
- rochas grandes;
- ruínas menores.

## Camada 4 — pontos especiais
Manual apenas.

---

# DENSIDADE

Não usar ruído puro sem regra.

A densidade depende de:
- distância da estrada;
- distância da cidade;
- bioma;
- proximidade de água;
- proximidade de landmark;
- clareiras;
- zonas de combate.

---

# LEITURA DE COMBATE

Criar clareiras manuais em áreas com inimigos.

Regras:
- inimigo melee precisa de espaço;
- arqueiro precisa de linha de tiro;
- elite precisa de arena mínima;
- vegetação não pode esconder telegraph importante.

---

# STREAMING

Dividir REG_001 em células/chunks.

Sugestão inicial:
- chunk lógico de 512×512 ou 768×768 px, a validar;
- carregar vizinhança próxima;
- descarregar chunks distantes.

Não travar dimensão definitiva antes de teste real.

---

# SAVE

Salvar:
- seed;
- world flags;
- objetos destruídos relevantes;
- baús abertos;
- bosses derrotados;
- recursos únicos coletados.

Não salvar cada tufo de grama individual se puder ser regenerado por seed.

---

# GODOT 4.7.2

Arquitetura futura:
- RegionController
- ChunkManager
- ProceduralDecorSpawner
- BiomeRuleSet
- LandmarkRegistry
- WorldState

Não implementar antes de terminar a fundação técnica.