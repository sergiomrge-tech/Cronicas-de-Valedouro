# Remapeamento — Etapa 3: vegetação e biomas

Referência aprovada: **Karsiori** (tree/spruce/bush/rock). A linguagem foi traduzida para o pipeline Blender de Valedouro (mesma câmera, escala, luz alto-esquerda, contorno e quantização) — **não é cópia do pacote**.

## Árvores (`tools/art_pipeline/pro_trees.py`) — 9 IDs remodelados + 5 novos (MODELED_PENDING_GATE)
- **Copa em tufos** com relevo de folhagem (couve-flor), miolo escuro visível entre eles, franja de tufinhos na borda inferior.
  - A iteração anterior tinha bolas lisas e poeira de folhinhas. Agora os tufos leem como massas grandes, como no Karsiori.
  - O tronco é curvo, com forquilhas visíveis. Na base há raízes que abrem, relva e pedrinhas, para o contato com o chão.
- **Spruce** em saias de ramos pendentes alongados, com pontas de agulha. A variante fria é azul-acinzentada, com neve no topo dos ramos (`nat_pine_tall_snow`, `nat_spruce_cold`).
- **Silhuetas por ecologia** (novas):
  - `nat_tree_umbrella`: guarda-chuva, colinas secas e borda do deserto.
  - `nat_tree_tiered`: em andares, para o vale.
  - `nat_tree_lollipop`: pirulito, para o bosque claro.
  - `nat_spruce_cold`: transição para o gelo.
  - `nat_spruce_small`: spruce jovem.
- IDs existentes mantidos: nenhuma referência migrada, nenhum save quebrado.
- `reg001_procedural.gd` escolhe a silhueta pela ecologia do bioma:
  - frio: spruce;
  - seco: guarda-chuva;
  - vale: andares;
  - floresta: carvalhos e pirulitos;
  - pinhais: spruces jovens misturados.

## Ecótonos no chão (`bake_ground.py`)
- Numa faixa larga junto à borda, o bioma vizinho entra em **línguas e manchas intercaladas**, com material próprio por par:
  - **verde ↔ gelo:** terra, cascalho e neve rala (relva → chão pedregoso → neve);
  - **verde ↔ deserto:** terra seca, areia e vale;
  - **verde ↔ verde:** mistura natural.
- A lógica do runtime (bioma por célula) continua igual; o que mudou foi o visual.

## Validação (Godot 4.7.2 real)
- Suíte 17/17 PASS. `validate_reg001`, `validate_v0_6` e `validate_v0_6_1` PASS.
- 237 APPROVED intactos. Manifesto com 718 assets.
- QC: as 14 árvores da etapa passam. Há 5 avisos de margem nas árvores legadas `nat_tree_*`, que foram re-renderizadas sem mudança de código e são pré-existentes.
- Custo mobile: a mesma quantidade de sprites por célula (1 por árvore), sem shader novo.
- Evidência em `docs/visual_qa/remap/etapa3/`: **mosaico REAL** do mapa inteiro e recortes (floresta noroeste, ecótono do gelo), capturas por ponto e modelos.

## Pendências
- Arbustos, flores e rochas no estilo Karsiori continuam com os assets anteriores. É o próximo lote da vegetação.
