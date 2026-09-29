# Passe visual final mobile — Parte C: Ponte de Pedra + Posto dos Guardas Verdes

## Ponte de Pedra da Fronteira
- A ponte agora é uma peça única: **`flo_stone_bridge_arch`** (MODELED_PENDING_GATE). Ela substitui a montagem rampa + laje + rampa, que lia como laje retangular.
  - Não tem rotação: corre na diagonal isométrica. O rio passa na outra diagonal, e nada fica em eixo cartesiano.
  - Tabuleiro com leve corcova, arco com aduelas e fecho, e muros de testa com espessura real.
  - Talha-mares nos apoios, dentro d'água.
  - Guarda-corpo com trecho caído, cujo entulho parcialmente submerso fica no rio.
  - As cabeceiras descem em rampa e somem em **aterros de terra com relva e samambaia**, com muros-ala abertos. Nada fica pousado.
  - Raízes da floresta antiga atravessam a cabeceira leste. Há heras pendentes no arco.
- Composição:
  - O rio sinuoso (Parte B) foi reorientado para passar sob o arco.
  - A estrada chega **em curva** às duas cabeceiras.
  - O Berço fica na margem noroeste; a floresta ancestral, na margem sudeste.
  - Juncos na margem. Uma pedra que caía dentro d'água foi removida.

## Posto dos Guardas Verdes — uma instalação só, em 3/4
- **`flo_ranger_hall`**:
  - Casa de toras com cantos encaixados sobre soco de pedra, com pedras na base.
  - Telhado de telhas de madeira com musgo em fiadas e empenas fechadas.
  - Varanda coberta com esteios sobre sapatas, degraus de pedra e estandarte da folha.
  - Anexo-telheiro de lenha e chaminé de pedra.
  - Frente +x e lateral +y visíveis; não é mais frontal.
- **`flo_ranger_tower`**: quatro esteios sobre sapatas, contraventamento em X, plataforma com parapeito nos quatro lados, telhado piramidal, escada, pano verde e tocha. Tem profundidade real.
- **`flo_ranger_store`**: depósito de toras em 3/4 com meia-água, porta aberta com sacas, e barris e caixotes encostados.
- Composição:
  - **Chão batido de ocupação**: `Comp.yard`, assado no chão.
  - Trilhas irregulares: a patrulha é curva, o acesso chega aos degraus da varanda e a picada norte passa entre a casa e a torre. Nenhuma trilha forma T ou 90°.
  - As árvores ancestrais abraçam a casa.
  - A cerca multiângulo foi preservada e some na vegetação, com moitas e samambaias do lado de fora.
  - Os props do posto (fogueira, bancada de ervas, mesa de mapas, alvos, arsenal) ficam sobre o pátio, com sombra de contato assada.
- Os IDs antigos (`flo_bridge_*`, `flo_ranger_lodge/watch/shed`) continuam no banco, mas não são mais usados nestas cenas. Nenhum APPROVED foi alterado (continuam 237).

## Validação (Godot 4.7.2 real)
- As capturas estão em `docs/visual_qa/passe_final_mobile/C_ponte_posto/`: Ponte antes/depois, Casa pré/durante/pós e prancha dos modelos.
- Asset QC: 4/4 PASS.
- Suíte: 17/17 PASS. Os validadores `reg001`, `v0_6` e `v0_6_1` dão PASS (o catálogo foi regenerado). `audit_logic` dá 0 falhas.
- Custo mobile: são quatro sprites a mais, sem shader nem partícula nova.
