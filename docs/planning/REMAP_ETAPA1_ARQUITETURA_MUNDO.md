# Remapeamento — Etapa 1: arquitetura geral do mundo (REG_001, Berço de Valedouro)

Brief: `docs/CLAUDE_REMAP_COMPLETO_MUNDO_ASSETS_CURADOS.md`. Topologia de campanha: `docs/planning/MAIN_STORY_WORLD_TOPOLOGY_v1.md`.

## 1. Fonte única do traçado
Antes, estradas, cidade e biomas eram retângulos e faixas retas **duplicados em três lugares**, com números diferentes:
- `world_map.gd`;
- `geo.py`;
- `bake_ground.py`, onde o chão ainda recebia um warp próprio, de modo que a borda desenhada ≠ a borda lógica.

Agora tudo vem de uma fonte só:

```
data/reg001_layout.json  ──►  tools/reg001/layout.py  ──►  geo.py (gerador de conteúdo)
                                                   ├──►  tools/terrain/bake_ground.py (chão assado)
                                                   └──►  data/reg001_layout_grid.json (16 px) ──► scripts/world_map.gd (runtime)
```
- **Estradas:** splines Catmull-Rom com meia-largura levemente variável. As junções são em Y ou via praça, sem cruz de 90°. Cada estrada traz um campo `why` com a justificativa narrativa.
- **Praça da Fonte:** blob orgânico no encontro das avenidas; a fonte fica no centro.
- **Cidade:** superelipse deformada, sem retângulo. Dentro dela, **calçamento só nas ruas e na praça**. Os lotes ficam com terra batida e relva, e o piso APPROVED é aplicado apenas nas ruas.
- **Biomas:** mesma topologia regional de antes (os testes de bioma continuam válidos), avaliada em coordenadas deformadas por soma de senos. A borda é a mesma na lógica, no chão e no runtime.
- **Trilhas secundárias** (`reg001_world.json`): viram spline com serpenteio lateral, sem quinas.
- **Runtime:** a grade inclui estradas, praças e trilhas. `path_at`, `town_area` e `biome` são consultas O(1) em `PackedByteArray`, e `path_at` ficou cerca de 3× mais rápido que o original.

## 2. História → lugar (por que aqui?)
| Elemento | Por que aqui | Conexão |
|---|---|---|
| Portão Norte (`LOC_VAL_GATE`) | quem chega do Bosque/Estrada Norte entra por aqui; a guerra fica do lado de fora | Estrada Norte ↔ Av. Norte ↔ Praça |
| Guilda (`LOC_VAL_GUILD`) e Arquivo (`LOC_SIX_CROWNS_ARCHIVE`) | ficam na Av. Oeste, entre a praça e a saída para a Floresta | beco entre os dois; lago-jardim contornado pela avenida |
| Estrada de Fronteira Oeste | saída física do Ato I: Arquivo → estrada de fronteira → Ponte de Pedra (`LOC_FOREST_STONE_BRIDGE`, Ato II) | registrada em `exits` do layout |
| Estrada Norte (`LOC_VAL_NORTH_ROAD`) | lavouras → Viajante → vão da paliçada quebrada → matilha/Ruínas do Primeiro Vento | ramal da Geada sai por cima das lavouras, fora das barricadas do portão |
| Portão Sul e Estrada do Vale | Aldeia do Vale → Mina do Eco (`LOC_ECHO_MINE`) | a Rua Sul contorna o quarteirão sudeste até o portão (x≈1950) |
| Ponte mercante (y=1250) | a praça e o cais ligam-se às colinas do leste (Estação/Caravana de Âmbar, Ato III) | Av. Leste → ponte → Estrada Leste |
| Ponte norte (y=760) | Pouso da Geada (Ato V), pela passagem estreita | Ramal da Geada → entroncamento NE |
| Ponte sul (y=1840) | Dunas e Posto de Âmbar | o Ramal das Dunas **contorna** o Posto (antes passava por dentro) |
| Passagem Estreita (gelo) | garganta de gelo | a estrada estreita ali (meia-largura 22) |

## 3. Conflitos corrigidos pelo novo traçado
O traçado antigo tinha estes conflitos:
- a Av. Oeste atravessava o lago-jardim do Arquivo;
- a viela norte passava sob a Guilda;
- a rua sudeste passava sob uma casa de interior;
- a estrada sul batia na muralha;
- o ramal leste atravessava o Posto de Âmbar.

Todos foram rerroteados. O relevo procedural agora respeita a mesma folga das trilhas em relação às estradas.

## 4. Pendências para as próximas etapas (não resolvidas na Etapa 1)
- **Etapa 2 (cidade):**
  - As muralhas norte e sul **atravessam o rio**: há peças dentro d'água e uma torre na margem leste. É preciso refazer o anel pelo contorno orgânico, com portão d'água ou margens.
  - A "loja decorativa" desenhada em `main.gd` fica sobre o rio.
  - A Av. Sul termina junto à muralha (postigo previsto).
  - Os quarteirões ainda estão em fileiras retas.
  - `STRUCTURES` e as casas de interior continuam fixas em `main.gd`.
- **Etapa 3 (biomas):** o contato neve/relva ainda é duro no chão. Faltam o ecótono gradual (coníferas, rocha, manchas de neve) e a vegetação Karsiori.
- **Topologia macro:** este mapa é o hub do Ato I. Gelo e deserto aparecem como bordas das regiões dos Atos III e V. As regiões dos atos seguintes são mapas próprios, posicionados pelo Gerente.
