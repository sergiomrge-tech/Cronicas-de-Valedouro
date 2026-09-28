# Roadmap diário — Crônicas de Valedouro

**Versão:** 1.0  
**Regra:** cada linha representa uma sessão de trabalho, não uma data fixa. Se um dia não houver trabalho, a numeração não muda.  
**Fonte de verdade:** `FILA_ATUAL.md` aponta a próxima sessão. Ao concluir, marque `[x]`, registre o checkpoint e avance uma linha.

## Como usar todo dia
1. Ler `production/checkpoints/CHECKPOINT_CURRENT.md`.
2. Ler `production/roadmap/FILA_ATUAL.md`.
3. Executar somente a sessão ativa e correções indispensáveis relacionadas.
4. Se houver tarefa para Cloud Code, gerar um handoff em `production/handoffs/to_cloud_code/` usando o template oficial.
5. Integrar retornos somente após revisão, teste e Godot Gate.
6. Atualizar checkpoint e mover a fila para a próxima sessão.

## Convenção de responsáveis
- **ChatGPT:** arquitetura, banco/IDs, gameplay, narrativa, integração, QA, checkpoints e release.
- **Cloud Code:** especialista colaborador para produção/refinamento visual, UI/HUD, shaders/VFX, composição de cenas, level dressing e animação quando o pacote definir isso.
- **Ambos:** tarefas podem ser divididas, mas nunca editam o mesmo arquivo simultaneamente; a integração final é um trabalho separado.

## P0 — Fundação e estabilização

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [x] | 001 | Congelar snapshot da v0.6 e hashes | ChatGPT | Base técnica preservada + inventário inicial confirmado | Nenhum arquivo de jogo alterado sem cópia e hash. |
| [ ] | 002 | Corrigir tipagem de main.gd | ChatGPT | main.gd sem inferência Variant nos erros conhecidos | Parser passa neste arquivo com warnings como erro. |
| [ ] | 003 | Corrigir tipagem de world_map.gd | ChatGPT | world_map.gd tipado explicitamente | Parser passa neste arquivo com warnings como erro. |
| [ ] | 004 | Abrir projeto no Godot e limpar parser | ChatGPT | Projeto abre no Godot sem erro de parser | Godot inicia a cena principal. |
| [ ] | 005 | Smoke test da v0.6 | ChatGPT | Relatório de movimento, combate, mapa, HUD e colisões | Fluxos críticos executados sem crash. |
| [ ] | 006 | Catalogar assets existentes por ID | ChatGPT | Catálogo atual auditado | Todo asset usado possui ID/status. |
| [ ] | 007 | Exportar catálogo mestre para JSON Godot | ChatGPT | JSONs versionados por categoria | Godot consegue carregar catálogos sem hard-code novo. |
| [ ] | 008 | Fechar v0.6.1 estável | ChatGPT | Build-base estável + checkpoint | Gate Godot + varredura + ZIP íntegro. |

## P1 — Sistemas centrais do Action RPG

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [ ] | 009 | Refinar movimentação do protagonista | ChatGPT | Movimento 8 direções, aceleração e colisão | Controle consistente em touch/teclado de teste. |
| [ ] | 010 | Esquiva e stamina | ChatGPT | Dodge com invulnerabilidade configurável | Sem spam infinito; feedback visual claro. |
| [ ] | 011 | Combate base e hitboxes | ChatGPT | Ataque, dano, knockback e stagger | Hit/hurt boxes previsíveis. |
| [ ] | 012 | Espada + escudo | ChatGPT | Primeiro estilo completo | Combo, defesa e contra-ataque funcionais. |
| [ ] | 013 | Espadão | ChatGPT | Segundo estilo completo | Ataque pesado e stagger diferenciados. |
| [ ] | 014 | Magia/cajado | ChatGPT | Terceiro estilo completo | Mana, projétil e AoE base funcionais. |
| [ ] | 015 | Framework de skills | ChatGPT | 4 slots + ultimate + cooldowns | Skills lidas por IDs do catálogo. |
| [ ] | 016 | Framework de passivas | ChatGPT | Árvore/efeitos desacoplados | Passivas modificam stats sem hard-code por item. |
| [ ] | 017 | Inventário e equipamentos | ChatGPT | Slots, comparação e equipar/desequipar | Save preserva loadout. |
| [ ] | 018 | Loot tables e materiais | ChatGPT | Drops por ID/raridade/origem | Monstros não inventam drops fora do catálogo. |
| [ ] | 019 | Crafting e receitas | ChatGPT | Produção por materiais e estações | Receita valida estoque e resultado. |
| [ ] | 020 | Framework de bosses | ChatGPT | Fases, telegraphs, arena, loot condicional | Bosses reutilizam máquina de estados base. |
| [ ] | 021 | Quest system | ChatGPT | Objetivos, estados e recompensas | Quest persiste no save. |
| [ ] | 022 | Diálogo e NPCs | ChatGPT | Diálogo ramificado básico | Quest pode iniciar/avançar por diálogo. |
| [ ] | 023 | Marcos de teletransporte | ChatGPT | Descoberta + viagem entre marcos | Somente marcos descobertos aparecem. |
| [ ] | 024 | Montarias | ChatGPT | Montar/desmontar + velocidade + restrições | Save registra montaria desbloqueada. |
| [ ] | 025 | Save versionado | ChatGPT | Save migrável com versão de schema | Carregar save antigo não quebra sessão. |
| [ ] | 026 | HUD de combate — conceito visual | Cloud Code | Proposta visual aplicada à identidade oficial | Sem alterar regras de gameplay nem IDs. |
| [ ] | 027 | HUD de combate — integração | ChatGPT | HUD visual integrado ao build | Godot gate + legibilidade mobile. |

## P2 — Vertical Slice: O Estrangeiro / Valedouro

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [ ] | 028 | Macro level design de Valedouro inicial | ChatGPT | Mapa macro com rotas, POIs e limites | Fluxo 1–15 sem gargalos involuntários. |
| [ ] | 029 | Floresta da Queda | Cloud Code | Dressing visual da área inicial | Usa apenas assets/IDs aprovados. |
| [ ] | 030 | Estrada dos Peregrinos | Cloud Code | Estrada, transições, sinalização ambiental | Leitura clara sem setas artificiais. |
| [ ] | 031 | Vila de Brumavale | Cloud Code | Vila viva com arquitetura coerente | NPCs e colisões preservados. |
| [ ] | 032 | Campos de Valedouro | Cloud Code | Terreno ampliado, fazendas e ruínas | Densidade visual sem poluir combate. |
| [ ] | 033 | Rios, margens e pontes | Cloud Code | Água refinada e pontes integradas | Travessias e colisões testadas. |
| [ ] | 034 | Família de monstros região 1 | ChatGPT | Roster, stats, drops e IDs | Cada criatura tem função ecológica/combatente. |
| [ ] | 035 | Monstros região 1 — animação visual | Cloud Code | Sprites/animações refinados | Sets completos e nomenclatura registrada. |
| [ ] | 036 | Ruínas do Primeiro Limiar | ChatGPT | Dungeon 01 jogável | Entrada, atalhos, puzzle leve e boss. |
| [ ] | 037 | Boss 01 — design de combate | ChatGPT | Boss com 2 fases e drops condicionais | Luta completa sem placeholder lógico. |
| [ ] | 038 | Boss 01 — produção visual | Cloud Code | Sprite/VFX/arena do boss | Identidade própria e leitura de telegraph. |
| [ ] | 039 | Quests principais 001–005 | ChatGPT | Primeiro arco narrativo implementado | Objetivo de voltar à Terra estabelecido. |
| [ ] | 040 | Quests principais 006–010 | ChatGPT | Fechamento do vertical slice | Primeira prova concreta de portal entre mundos. |
| [ ] | 041 | Crafting inicial e ferreiro | ChatGPT | Receitas nível 1–15 | Loop matar→material→craft→upgrade fecha. |
| [ ] | 042 | Primeira montaria + primeiro marco | ChatGPT | Viagem regional completa | Desbloqueios narrativamente integrados. |
| [ ] | 043 | Passe visual completo da vertical slice | Cloud Code | Coesão de iluminação, VFX, HUD e cenário | Sem divergência do estilo oficial. |
| [ ] | 044 | QA da vertical slice | ChatGPT | Relatório de bugs/performance/progressão | Vertical slice aprovada como padrão. |

## P3 — Região 2: Mata de Elarin

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [ ] | 045 | Macro layout e rotas de Elarin | ChatGPT | Região separada fisicamente de Valedouro | Viagem longa, transições e marcos definidos. |
| [ ] | 046 | Floresta profunda e pântanos | Cloud Code | Dressing visual regional | Silhueta visual distinta de Valedouro. |
| [ ] | 047 | Cidade/hub de Elarin | Cloud Code | Hub funcional e memorável | Serviços/NPCs com áreas legíveis. |
| [ ] | 048 | Monstros de Elarin | ChatGPT | Roster + loot + materiais | Sem recolor como substituto de espécie nova. |
| [ ] | 049 | Animações/VFX monstros Elarin | Cloud Code | Pacotes visuais completos | Telegraphs legíveis. |
| [ ] | 050 | Dungeons 02–03 | ChatGPT | Duas dungeons com identidade própria | Boss e loot exclusivos. |
| [ ] | 051 | Bosses/Lenda de Elarin | ChatGPT | 1 boss mundo + 1 Lenda | Crafts exclusivos registrados. |
| [ ] | 052 | Quests e checkpoint Elarin | ChatGPT | Arco regional fechado | Gate Godot e checkpoint. |

## P4 — Região 3: Desfiladeiros de Khar

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [ ] | 053 | Macro layout de Khar | ChatGPT | Vales, altura visual e rotas | Bioma afastado e conectado organicamente. |
| [ ] | 054 | Vales, cânions e pontes | Cloud Code | Level dressing vertical | Leitura de profundidade consistente. |
| [ ] | 055 | Assentamento/fortaleza de Khar | Cloud Code | Hub regional | Arquitetura exclusiva. |
| [ ] | 056 | Monstros e elites de Khar | ChatGPT | Roster regional | Novas ameaças mecânicas. |
| [ ] | 057 | Dungeons 04–05 | ChatGPT | Minas/fortaleza ou equivalentes | Exploração + atalhos + bosses. |
| [ ] | 058 | Bosses de Khar | ChatGPT | Boss mundo + boss dungeon | Materiais e recipes únicos. |
| [ ] | 059 | Passe visual regional | Cloud Code | Cenário, VFX e sinalização | Coerência visual total. |
| [ ] | 060 | Quests e checkpoint Khar | ChatGPT | Arco fechado | Progressão ~nível 38 consistente. |

## P5 — Região 4: Dunas de Aradesh

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [ ] | 061 | Macro layout de Aradesh | ChatGPT | Deserto, oásis, cânions e ruínas | Distância e navegação por marcos naturais. |
| [ ] | 062 | Dunas e tempestades visuais | Cloud Code | Identidade ambiental do deserto | Efeito não prejudica leitura mobile. |
| [ ] | 063 | Cidade/oásis de Aradesh | Cloud Code | Hub regional | Vida urbana + arquitetura própria. |
| [ ] | 064 | Monstros de Aradesh | ChatGPT | Roster e materiais | Ecologia/desafios únicos. |
| [ ] | 065 | Dungeons 06–07 | ChatGPT | Ruína soterrada + dungeon profunda | Bosses e puzzles próprios. |
| [ ] | 066 | Bosses e crafting Aradesh | ChatGPT | Materiais raros + recipes | Progressão de gear 35–50. |
| [ ] | 067 | Passe visual Aradesh | Cloud Code | Polimento regional | Sem asset improvisado. |
| [ ] | 068 | Quests e checkpoint Aradesh | ChatGPT | Arco fechado | Gate e checkpoint. |

## P6 — Região 5: Terras Glaciais de Nivora

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [ ] | 069 | Macro layout de Nivora | ChatGPT | Montanhas, gelo e cavernas | Rotas longas e clima legível. |
| [ ] | 070 | Gelo, neve e cavernas | Cloud Code | Dressing e VFX ambientais | Performance mobile preservada. |
| [ ] | 071 | Fortaleza/hub de Nivora | Cloud Code | Hub regional | Silhueta arquitetônica exclusiva. |
| [ ] | 072 | Monstros glaciais | ChatGPT | Roster + materiais | Combate introduz congelamento/controle. |
| [ ] | 073 | Dungeons 08–09 | ChatGPT | Duas dungeons completas | Bosses multi-fase iniciais. |
| [ ] | 074 | Bosses/Lenda de Nivora | ChatGPT | Conteúdo opcional forte | Crafting épico inicial. |
| [ ] | 075 | Passe visual Nivora | Cloud Code | Polimento de região | Contraste e legibilidade revisados. |
| [ ] | 076 | Quests e checkpoint Nivora | ChatGPT | Arco fechado | Progressão ~nível 62. |

## P7 — Região 6: Edravar, o Reino Arruinado

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [ ] | 077 | Macro layout de Edravar | ChatGPT | Cidade/região em guerra | Estado do mundo reage à campanha. |
| [ ] | 078 | Cidade infestada — distrito 1 | Cloud Code | Ruas, casas e ocupação inimiga | Exploração urbana legível. |
| [ ] | 079 | Cidade infestada — distrito 2 | Cloud Code | Praças, esgotos e telhados | Rotas alternativas e segredos. |
| [ ] | 080 | Sistema de mundo em transformação | ChatGPT | Estados de cidade por ato | Save persiste alterações. |
| [ ] | 081 | Monstros/cultistas de Edravar | ChatGPT | Roster regional | Combate mais tático. |
| [ ] | 082 | Dungeons 10–12 | ChatGPT | Três conteúdos urbanos/fortaleza | Bosses e loot próprios. |
| [ ] | 083 | Cerco e boss regional | ChatGPT | Set piece narrativo | Cena jogável estável. |
| [ ] | 084 | Passe visual do cerco | Cloud Code | VFX, ambientação e UI contextual | Performance validada. |
| [ ] | 085 | Quests e checkpoint Edravar | ChatGPT | Arco fechado | Progressão ~nível 75. |

## P8 — Região 7: Fronteira do Éter

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [ ] | 086 | Macro layout da Fronteira | ChatGPT | Região sobrenatural aberta | Navegação ainda compreensível. |
| [ ] | 087 | Visual do Éter | Cloud Code | Tiles/VFX/shaders próprios | Visual extraordinário sem ruído excessivo. |
| [ ] | 088 | Hub/refúgio do Éter | Cloud Code | Último grande hub seguro | Identidade única. |
| [ ] | 089 | Monstros do Éter | ChatGPT | Roster + resistências + materiais | Mecânicas avançadas. |
| [ ] | 090 | Dungeons 13–14 | ChatGPT | Duas dungeons avançadas | Bosses multi-fase. |
| [ ] | 091 | Sigilos restantes | ChatGPT | Progressão dos 7 Sigilos | Lore e gameplay convergem. |
| [ ] | 092 | Lendas do Éter | ChatGPT | Bosses secretos/endgame | Recompensas míticas. |
| [ ] | 093 | Passe visual Fronteira | Cloud Code | Polimento completo | Coesão com estilo base. |
| [ ] | 094 | Quests e checkpoint Éter | ChatGPT | Arco fechado | Entrada no nível 90 preparada. |

## P9 — Região 8: Domínio da Coroa Oca

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [ ] | 095 | Macro layout do domínio final | ChatGPT | Região final + caminhos de invasão | Progressão 90–100. |
| [ ] | 096 | Paisagem demoníaca final | Cloud Code | Visual do domínio final | Escala épica sem descaracterizar pixel art. |
| [ ] | 097 | Fortaleza do Rei Demônio | ChatGPT | Level design final | Atalhos, elites, narrativa ambiental. |
| [ ] | 098 | Fortaleza — produção visual | Cloud Code | Arquitetura/VFX finais | Identidade máxima e legibilidade. |
| [ ] | 099 | Elites finais | ChatGPT | Roster de elite | Combate exige domínio das builds. |
| [ ] | 100 | Dungeons 15–16 | ChatGPT | Conteúdo final opcional/principal | Recompensas endgame. |
| [ ] | 101 | Azharel — design fase 1–2 | ChatGPT | Boss final funcional | Mecânicas narrativas e combate. |
| [ ] | 102 | Azharel — design fase 3/final | ChatGPT | Conclusão completa | Vitória gera Coração do Limiar. |
| [ ] | 103 | Azharel — produção visual | Cloud Code | Boss/VFX/arena cinematográficos | Telegraphs claros e visual único. |
| [ ] | 104 | Retorno à Terra | ChatGPT | Sequência final e epílogo | Objetivo central da campanha concluído. |
| [ ] | 105 | Passe visual do final | Cloud Code | Polimento final narrativo | Consistência visual. |
| [ ] | 106 | QA do final | ChatGPT | Campanha concluível 1–100 | Sem bloqueadores. |

## P10 — Polimento, conteúdo opcional e publicação

| Feito | Sessão | Objetivo | Responsável padrão | Entrega | Gate de conclusão |
|---|---:|---|---|---|---|
| [ ] | 107 | Revisar 120+ quests secundárias planejadas | ChatGPT | Priorização e lacunas | Nenhuma região vazia. |
| [ ] | 108 | Contratos e caçadas | ChatGPT | Loop repetível controlado | Recompensas balanceadas. |
| [ ] | 109 | Lendas de Valedouro — lote 1 | ChatGPT | Bosses opcionais 1–4 | Loot/crafts únicos. |
| [ ] | 110 | Lendas de Valedouro — lote 1 visual | Cloud Code | Bosses/arenas refinados | Padrão visual mantido. |
| [ ] | 111 | Lendas de Valedouro — lote 2 | ChatGPT | Bosses opcionais 5–8 | Endgame ampliado. |
| [ ] | 112 | Lendas de Valedouro — lote 2 visual | Cloud Code | Visual refinado | Sem duplicação estética. |
| [ ] | 113 | Sets/armas míticas e balanceamento | ChatGPT | Endgame de builds | Sem opção universalmente dominante. |
| [ ] | 114 | UI/UX mobile final | Cloud Code | HUD, menus e feedback finais | Legibilidade em telas pequenas. |
| [ ] | 115 | Performance e streaming de mundo | ChatGPT | Profiling/otimização | Meta móvel definida e medida. |
| [ ] | 116 | Acessibilidade e controles | ChatGPT | Opções e touch refinado | Fluxos principais acessíveis. |
| [ ] | 117 | Áudio e feedback final | ChatGPT | Mapa de áudio/SFX/music cues | Eventos críticos têm feedback. |
| [ ] | 118 | QA campanha completa | ChatGPT | Teste 1–100 | Sem blockers de progressão. |
| [ ] | 119 | APK/AAB candidato | ChatGPT | Build Android candidata | Instala/abre/save em aparelho real. |
| [ ] | 120 | Release candidate + checkpoint mestre | ChatGPT | RC documentado e reproduzível | Godot gate, CRC, manifestos e documentação atualizados. |

## Depois da sessão 120
O projeto entra em **roadmap rolante**. Novas expansões, NG+, conteúdo pós-lançamento ou correções recebem blocos de 10–20 sessões usando `TEMPLATE_BLOCO_ROADMAP.md`. Nunca inserir trabalho novo no meio de uma fase ativa sem registrar a mudança no checkpoint.

## Regra de escopo diário
Uma sessão deve produzir **um resultado verificável**. Se o trabalho for maior que uma sessão, ele deve ser quebrado antes de começar. Se surgir um bloqueador, a sessão passa a ter como entrega a correção/documentação desse bloqueador e não avança a fila até o gate correspondente passar.