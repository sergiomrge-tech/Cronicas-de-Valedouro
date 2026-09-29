# Passe visual final mobile — Parte B: terreno, caminhos e água do Ato II

## O que mudou
- **Chão assado por cena** (`game/tools/act02/bake_act02_ground.py`). Cada cena externa ganha uma textura 960×540 em `assets/modeled/terrain/act02/<slug>.png`, com paleta fechada de 160 cores. No runtime isso custa **um `draw_texture` por cena**, sem shader novo e sem custo por pixel.
  - Solo próprio da Floresta Ancestral: serapilheira, relva, musgo e manchas úmidas raras, misturados por ruído com dither. As transições são de pixel art, sem grade.
  - Relevo macro sombreado com luz vindo do alto-esquerdo.
  - **Sombra salpicada de copa** sob as árvores grandes, com buracos de luz.
  - **Sombra de contato** assada sob todo objeto com base.
- **Trilhas por spline (Catmull-Rom)** com largura variável, borda erodida, relva invadindo e rebaixo sombreado.
  - Nenhum cruzamento em T nem curva de 90°: os ramais saem em Y ou em ângulo agudo.
  - As exclusões de vegetação seguem a curva da trilha (círculos encadeados), não retângulos.
- **Rios sinuosos** (`Comp.river`) com largura variável, parte funda e parte rasa assimétricas, margem de lama e leito, pedras submersas irregulares, espuma a jusante, sombra do barranco e reflexo na margem oposta.
  - A Ponte deixou de ter um retângulo de água: agora o rio estreita sob a ponte e alarga nas curvas.
  - O Santuário da Água ganhou um riacho que desce da queda.
  - Os brilhos da água são animados no palco com ~40 retângulos por quadro.
- **Ecótono dos Cartógrafos:** o solo seca progressivamente (grama seca/terra) rumo à saída do Ato III.
- **Trilhas com estado** (a dos Cartógrafos, liberada após o boss) viram overlays RGBA ligados pelo mesmo `show_when` da composição.
- `tests/act02_stage.gd` passou a usar o chão assado. As texturas são carregadas fora do `_draw`: no renderer Compatibility/mobile, carregar dentro do draw desenha um placeholder branco. A água retangular e as trilhas desenhadas em runtime ficaram só como fallback.
- Interiores (Coração, Arena) marcados `terrain: 'none'`; eles são tratados na Parte E.

## Validação (Godot 4.7.2 real)
- As capturas foram regeneradas com `tests/qa_capture_act02.gd` (23 estados). Estão em `docs/visual_qa/passe_final_mobile/B_terreno_agua/` (10 selecionadas).
- A suíte (17) e `act02_compositions` dão PASS (361 objetos). `validate_reg001`, `validate_v0_6` e `validate_v0_6_1` dão PASS. `audit_logic` dá 0 falhas.
- Nenhum asset APPROVED foi alterado.

## Pendências passadas para as próximas partes
- A Ponte e o Posto (conjunto, fundações, laje retangular) ficam para a Parte C.
- O espelho d'água em disco da Árvore-Memória fica para a Parte D.
- O disco da arena e o anel dos Cartógrafos ficam para a Parte E.
