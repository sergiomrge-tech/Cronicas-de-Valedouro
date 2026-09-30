# Remapeamento — Etapa 1: relatório

**Entregue:** fonte única do traçado (`data/reg001_layout.json` + `tools/reg001/layout.py` + grade `data/reg001_layout_grid.json`).
- Estradas por spline, com praça no lugar da cruz e junções em Y.
- Cidade com contorno orgânico, calçamento só em ruas e praça, lotes de terra batida e relva.
- Trilhas em spline.
- Bordas de bioma deformadas e iguais na lógica, no chão e no runtime.
- 7 conflitos estrada × construção rerroteados.
- Relevo com folga das estradas.
- Moldura retangular de árvores em volta da cidade removida.
- Detalhes em `docs/planning/REMAP_ETAPA1_ARQUITETURA_MUNDO.md`.

**Validação (Godot 4.7.2 real):**
- Suíte 17/17 PASS, incluindo `world_travel` com 5092 células conectadas (antes 5039).
- `validate_reg001`, `validate_v0_6` e `validate_v0_6_1` PASS.
- `audit_logic`: 35 construções, 0 falhas.
- 237 APPROVED intactos.

**Mobile:**
- Construção dos 30 chunks em 148 ms (antes 124 ms), com +3,6% de itens e bordas de bioma mais longas.
- `path_at` 3× mais rápido (grade O(1)). Pico visível: 214 itens.

**Capturas** em `docs/visual_qa/remap/etapa1/`:
- 12 capturas reais do Godot.
- `mapa_dados_ANTES/DEPOIS.jpg`: **composição de dados**, montada com as texturas reais do chão assado e os POIs. **Não é screenshot do jogo**; serve para ler o traçado inteiro.

**Bloqueadores críticos:** nenhum. As pendências (muralhas cruzando o rio, loja sobre o rio, ecótono neve/relva) estão listadas no documento de arquitetura e entram nas Etapas 2 e 3.
