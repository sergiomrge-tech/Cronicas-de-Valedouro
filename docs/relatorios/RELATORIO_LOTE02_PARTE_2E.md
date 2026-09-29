# Lote 2 / Ato II — Parte 2E: Santuário dos Cartógrafos e saída (`LOC_FOREST_CARTOGRAPHER_SHRINE`, `Q_MS02_VEIL_SHRINE`)

Segue §3-F e §5.6. Fecha o Ato II: revelação (Selo Verde, segunda linha rumo a Edravar) e saída para o Ato III.

## Assets (8 novos, `MODELED_PENDING_GATE`, QC PASS)
`flo_cart_ring_inert` / `flo_cart_ring_lit` (anel de pedra com oito linhas radiais, oito pedras de referência e pedestal para o Selo Verde; aceso = selo assentado + a **segunda linha** de luz que sai do anel rente ao chão rumo à saída), `flo_cart_pillar` (pilar com sigilo de oito raios), `flo_cart_ruin_wall` (muro com inscrições horizontais + rosa de oito raios: ecoa as Ruínas do Primeiro Vento sem copiá-las), `flo_cart_path_covered` / `flo_cart_path_open` (caminho encoberto × aberto), `flo_cart_terrace` (clareira elevada com vista), `flo_exit_marker` (marco de saída com estrela de oito pontas e faixa ocre — ponte visual com o deserto). Pedra dos Cartógrafos mais clara e lisa que a dos Guardas: sinaliza antiguidade anterior à ocupação.

## Estados (chaves canônicas, sem sistema paralelo)
- **Inerte** (padrão): caminho encoberto por raízes e mato, anel apagado.
- **Caminho aberto:** `elites:BOSS_RAIZ_OCA_001` (primeira derrota da Raiz Oca, persistente) → trilha visível, lajes reaparecem, marco de saída.
- **Selo ativo:** `quest:Q_MS02_VEIL_SHRINE` → anel aceso e segunda linha projetada; o santuário continua acessível como atualização de mapa/lore.
- Ecótono à direita: solo seco (arbustos secos, grama seca, duna baixa) orienta para o deserto (Ato III).

## Capturas reais do Godot — `docs/visual_qa/story/act02/`
`FLO_2E_CARTOGRAFOS_INERTE`, `FLO_2E_CARTOGRAFOS_CAMINHO_ABERTO`, `FLO_2E_CARTOGRAFOS_SELO_ATIVO` + folha do kit.

## Testes
`act02_compositions` (10 composições). Suíte completa: **17/17 PASS**.

## Limitações
- Rota física real até o deserto e a conexão com `LOC_*` do Ato III são do Gerente (o marco e o ecótono já existem como kit).
- Segredos com retorno aos Cartógrafos (1–2, §6) e os 2–3 atalhos completos dependem do traçado final; o kit tem atalho, mirante e pedras-guia.
