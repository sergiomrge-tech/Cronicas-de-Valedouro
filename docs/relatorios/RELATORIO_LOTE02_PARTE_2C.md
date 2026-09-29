# Lote 2 / Ato II — Parte 2C: Árvore-Memória (`LOC_MEMORY_TREE`, `Q_MS02_MEMORY_TREE`)

Segue §3-D e §5.4 de `LOTE02_ATO2_STORY_TO_MAP_v1.md`. Estados F3 (três raízes purificadas → árvore "acorda") e F4 (memória revelada), sem lógica dentro do asset.

## Assets (9 novos, `MODELED_PENDING_GATE`, QC 9/9 PASS)
- `flo_memory_tree_sealed` / `flo_memory_tree_open`: tronco colossal (~876×926 px de jogo, maior objeto do jogo), contrafortes que descem como arcos, plataformas naturais, inscrições quase engolidas pela casca, cavidade/coração. **Fechada** = cavidade tomada por emaranhado de raízes (antes das três raízes); **aberta** = raízes recolhidas, luz suave dourado-esverdeada do coração e faixa de luz no chão (nunca o azul do Eco nem o roxo da corrupção).
- Área externa: `flo_memory_root_arch` (arco monumental), `flo_memory_stone` (pedra memorial com inscrição de luz suave), `flo_memory_pool` (espelho d'água parcial, piso).
- Coração (interior): `flo_heart_floor` (piso de raízes com anel de luz), `flo_heart_wall` (parede viva modular de 4 u com raízes em relevo, inscrições e vinhas), `flo_heart_seed` (semente dormente) e `flo_heart_seed_active` (durante a cena de memória, com anéis e fios de luz).

## Composições e estados (`act02_compositions.json`)
- **Exterior** (`FLO_2C_ARVORE_FECHADA/ABERTA`): clareira central com espelho d'água, quatro pedras memoriais, dois arcos de raiz, árvores ancestrais laterais, trilha de aproximação; `quest:Q_MS02_ROOTS` (três raízes purificadas) troca sealed→open.
- **Coração** (`FLO_2C_CORACAO_DORMENTE/MEMORIA_ATIVA`): parede viva em arco, piso com anel, pedras de inscrição, semente central; `quest:Q_MS02_MEMORY_TREE:active` ativa a semente e a luz **temporariamente** (durante a memória). Após a cena, volta ao dormente: a árvore permanece como codex, sem repetir a cena sozinha (regra 4 do §8).

## Capturas reais do Godot — `docs/visual_qa/story/act02/`
`FLO_2C_ARVORE_FECHADA`, `FLO_2C_ARVORE_ABERTA`, `FLO_2C_CORACAO_DORMENTE`, `FLO_2C_CORACAO_MEMORIA_ATIVA` e comparação de render Blender fechada×aberta.

## Testes
`act02_compositions` valida as 7 composições (LOC canônico, região, assets, flags por quests canônicas). Suíte completa: **17/17 PASS**.

## Limitações
- Landmark visível "à distância em múltiplos pontos" depende da posição final no mapa (Gerente); o asset já tem silhueta legível e tamanho dominante, e o mirante da Parte 2B foi pensado para enquadrá-lo.
- As "memórias visuais de Adrian" (cenas) são runtime/cinemática e não foram feitas; o coração tem espaço livre e ponto de foco (semente) para elas.
- Partículas e feixes de luz do exterior são pós-efeitos do palco; runtime fica na integração.
