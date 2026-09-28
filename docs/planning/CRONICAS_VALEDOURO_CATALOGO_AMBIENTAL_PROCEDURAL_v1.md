# CRÔNICAS DE VALEDOURO — CATÁLOGO AMBIENTAL PROCEDURAL v1

## Objetivo
Definir quais assets podem ser usados em distribuição procedural controlada.

---

# ÁRVORES
Categorias:
- árvore verde grande;
- árvore verde média;
- árvore jovem;
- árvore seca;
- árvore outonal;
- árvore caída;
- tronco morto.

Tags:
- floresta;
- campo;
- margem;
- ruína.

---

# ARBUSTOS
- verde;
- flores brancas;
- flores rosas;
- frutos;
- seco;
- espinhoso.

---

# GRAMA
- baixa;
- alta;
- tufos;
- flores pequenas;
- borda de caminho;
- margem de pedra.

---

# PEDRAS
- pequena;
- média;
- agrupamento;
- penhasco baixo;
- rocha com musgo;
- rocha quebrada.

---

# MADEIRA
- troncos;
- pilha de lenha;
- tora;
- tábua;
- cerca;
- estaca;
- ponte;
- suporte.

---

# RUÍNAS
Uso procedural apenas em áreas pré-autorizadas:
- coluna quebrada;
- bloco;
- arco pequeno;
- entulho.

Nunca gerar ruínas narrativas importantes proceduralmente.

---

# PESOS SUGERIDOS

Comum:
- grama;
- pedra pequena;
- arbusto simples.

Moderado:
- árvore média;
- tronco;
- flor.

Raro:
- árvore seca;
- rocha grande;
- ruína pequena.

Muito raro:
- composição especial.

---

# REGRAS

1. Manter caminho principal legível.
2. Nunca bloquear entrada.
3. Não encostar árvore grande em ponte/porta.
4. Controlar repetição do mesmo sprite.
5. Alternar orientação quando permitido.
6. Usar clusters naturais em vez de distribuição uniforme.
7. Respeitar min_spacing.

---

# METADADOS

Exemplo:

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

# ANTI-REPETIÇÃO

Sistema deve:
- limitar repetição consecutiva;
- variar escala levemente;
- variar espelhamento quando seguro;
- usar clusters;
- manter landmarks limpos.

---

# PERFORMANCE

Não usar centenas de Node2D pesados se MultiMesh/TileMapLayer puder resolver decoração sem interação.

Objetos interativos e com colisão continuam como nodes próprios.