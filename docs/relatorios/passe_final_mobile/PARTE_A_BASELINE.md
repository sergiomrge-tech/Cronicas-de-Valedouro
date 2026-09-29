# Passe visual final mobile — Parte A: auditoria e baseline

Handoff: `handoffs/claude/OPUS_PASSE_VISUAL_FINAL_MOBILE_2026-09-29.md`. Branch `ccr-bb54cda9-tvw178`.

## Sincronização
- Rebase sobre `b258c8a` (gate de CI do Gerente, manifesto ativo com 19 APPROVED do bundle, IDs arquitetônicos aposentados).
- Conflitos só em arquivos gerados. **Aprovações preservadas:** manifesto restaurado do Gerente e regenerado com `manifest_lib.merge()`. Resultado: 237 APPROVED e 472 pendentes. Os 9 novos são as árvores `nat_oak_*`, `nat_pine_tall_*` e `nat_birch_tall`, e seguem pendentes. `val_house_body` continua fora do banco.
- `tests/cast_shadow.gd` citava IDs aposentados (`APP:city_house_door`, `APP:city_roof_red`, `APP:city_wall`) e passou a usar os ativos (`val_town_house_red`, `val_wall_segment_a6`, `val_wall_tower`, `nat_oak_a`, `nat_pine_tall_a`).

## Validação do baseline
- `validate_v0_6`, `validate_v0_6_1` e `validate_reg001`: PASS.
- Suíte Godot 4.7.2 (headless): 17/17 PASS.

## Capturas reais (Godot 4.7.2 + xvfb) — `docs/visual_qa/passe_final_mobile/A_baseline/`
São 10 capturas: portão de Valedouro, Ruínas do Primeiro Vento, Mina zona 1, Núcleo, Ponte, Posto dos Guardas, Árvore-Memória, Coração, Raiz Oca e Cartógrafos.

## Leitura do baseline (confirma o diagnóstico do handoff)
- **Valedouro:** maduro. Faltam gatehouse, repetição de casas e contato.
- **Ruínas:** densas, mas com peças de ruína sem fundação.
- **Mina:** piso em tabuleiro, círculo rúnico gigante e paredes idênticas. Prioridade máxima.
- **Ponte:** rio reto de largura constante, estrada horizontal e laje retangular.
- **Posto dos Guardas:** trilhas em T e em 90°, conjunto plano.
- **Árvore-Memória:** disco d'água, trilhas em T e entrada preta recortada.
- **Coração:** disco verde com raios radiais e parede em segmentos repetidos.
- **Raiz Oca:** arena sobre disco perfeito e segmentos de parede visíveis.
- **Cartógrafos:** peças isoladas nas quatro direções, disco central e sem fundação.
