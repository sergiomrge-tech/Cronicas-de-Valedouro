---
name: valedouro-map-logic
description: Lógica espacial de construções e assentamentos para o mapa de Crônicas de Valedouro. Use ao posicionar, mover ou criar casas, vilas, torres, moinhos, cais, fazendas, santuários, ruínas, entradas de dungeon e qualquer construção que a história/quests exijam; ao revisar se o mapa "faz sentido"; ou ao ligar missões a lugares do mapa.
---

# Valedouro — lógica de construções no mapa

Skill adaptada (em português, para o projeto) de material público sobre design de assentamentos e mapas de fantasia:
- jwynia/agent-skills — *settlement-design* (10 princípios, parâmetros de sítio/morfologia/função/infraestrutura, tipologias, anti‑padrões) — https://github.com/jwynia/agent-skills
- Worldographer (manual de mapas de assentamento: moinhos, cais e orlas ficam encostados na água) — https://worldographer.com/manual/05-creating-settlement-city-village-maps/
- Azgaar (rotas: custo por elevação, rios, cidades existentes; assentamentos em margens de rio) — https://azgaar.wordpress.com/2017/11/21/settlements/
- H. M. Turnbull, *Making a Fantasy Map: Settlements* (cidades em foz de rio, terras altas defensáveis, cruzamentos de rotas; muito mais vilas do que cidades).
Não copiar texto dessas fontes; aqui só ficam as regras destiladas + as regras do projeto.

## 0. Ordem de autoridade (não inventar lore)
1. Decisões do Diretor → 2. `docs/canon/CANON_SOURCE_OF_TRUTH.md` → 3. docs de `docs/planning/` (QUEST_FLOW, LEVEL_DESIGN, LANDMARKS_SEGREDOS, NPCS_SERVICOS) → 4. lore em `game/tools/reg001/build_world.py` (`REG001_LORE_*`).
Conteúdo novo é `PROPOSED`. Nunca completar lacunas de lore por conta própria; quando faltar informação, registrar a dúvida em `docs/planning/REG001_STORY_TO_MAP.md`.

## 1. Os dez princípios (versão jogo)
1. **Determinismo geográfico** — água, relevo e rota decidem onde algo nasce.
2. **Necessidade funcional** — toda construção existe para uma função econômica, defensiva, religiosa ou de história.
3. **Rede** — nada existe isolado: liga‑se a estrada, trilha, vau, ponte ou rio.
4. **Camadas** — o lugar cresceu aos poucos (casa velha, puxadinho, ruína, remendo de muro); evitar simetria perfeita.
5. **Poder** — quem manda ocupa o centro/ponto alto (guilda, praça); a periferia é mais pobre/rústica.
6. **Restrição de recursos** — material local: pedra onde há rocha, madeira na floresta, adobe/arenito no deserto, troncos e gelo no norte.
7. **Expressão cultural** — cores/brasões do reino (azul/dourado) só onde o reino manda; fora, arquitetura própria da região.
8. **Reuso** — ruínas viram abrigos, altares viram marcos; mostrar reaproveitamento.
9. **Resposta a desastre/guerra** — 23 anos de Guerra da Coroa Oca: torres nas aproximações, muros, campos abandonados, refugiados, casas vazias com bilhete.
10. **Estratificação** — centro mais denso/rico, bordas mais esparsas; ao menos 3 zonas distintas por hub.

## 2. Teste "Por que aqui?" (obrigatório por construção)
Cada construção nova/movida precisa responder, em uma linha, **por que está exatamente ali** com pelo menos **dois** motivos de: água · estrada/cruzamento · recurso · defesa/altura · sagrado/história · mercado. Se só há motivo de "ficou bonito no mapa", mover.

## 3. Regras por tipo de construção
| Tipo | Regra de posição | Entorno obrigatório |
|---|---|---|
| Moinho | vento aberto ou beira de água; na borda da vila, junto de estrada | campos de trigo/celeiro/fardos ao redor; nunca dentro de mata fechada |
| Cais / barco | encostado na água, em ponto de travessia (ponte/vau) ou porto da cidade | trapiche ligado a estrada; caixotes, redes, barris; barcos amarrados, não no meio do rio |
| Ponte / vau | onde a rota cruza o rio; margens rasas | lampiões/marco; estrada de cada lado |
| Ferreiro | perto da água (têmpera) e da rua principal; a favor do vento em relação às casas | fornalha, bigorna, carvão, lenha |
| Guilda | na praça ou junto ao portão de entrada da cidade (é onde o aventureiro chega) | quadro de contratos, banco, movimento de NPCs |
| Loja/mercado | cruzamento de ruas ou perto do porto/portão | barracas, carroças, barris |
| Alquimista | rua lateral mais calma, perto de horta/ervas | ervas, frascos, chaminé |
| Taverna/pousada | praça ou cruzamento de estradas (também fora da cidade: postos de estrada) | placa pendurada, barris, bancos, fogueira; ponto de descanso |
| Templo/santuário | ponto alto, nascente, ou local de evento sagrado (chegada dos Viajantes) | escadas, pilares, luz; caminho cerimonial |
| Torre de vigia | ponto elevado ou cruzamento de rotas, com linha de visada sobre a estrada | base de pedra, sinal/bandeira, pequeno posto; nunca no fundo de um vale sem visão |
| Casa isolada / cabana | perto de água e de trilha; porta voltada para a trilha | cerca, lenha, horta, poço |
| Fazenda/celeiro | solo plano e fértil, perto de água | cercas, lavouras, espantalho, feno, poço; celeiro encostado nas lavouras |
| Acampamento | clareira com lenha e água a poucos passos; fora da linha de estrada principal | fogueira, tenda, tronco, provisões |
| Posto/estação de estrada | cruzamento de rotas, vau ou passo de montanha | barracas/estábulo/carroça, poço/água, bandeira |
| Ruína | terreno alto ou cruzamento antigo; a causa da queda aparece (parede partida, coluna caída, erosão) | vegetação retomando, entulho, marcas rúnicas |
| Entrada de dungeon | **encaixada** na rocha/colina/ruína (nunca um portal solto no meio da cidade); visível **antes** de chegar | arco de pedra, tochas, vegetação, água ou queda d'água próxima, estátuas/sinal de perigo, relevo emoldurando |
| Cripta / gruta secreta | flanco de colina ou parede de gelo; discreta mas com pista visual | rocha em volta, entrada estreita |
| Oásis | depressão do deserto, com água | palmeiras, juncos, pegadas de fauna |

## 4. Rotas e circulação
- Rota principal da história é contínua e legível: **Cidade → Campos → Bosque → Ruínas → Dungeon** (LEVEL_DESIGN v1). Landmarks visíveis antes de chegar a eles.
- Trilhas evitam relevo alto; cruzam rios por vau/ponte; ligam cada assentamento à rede. Sem construção "ilha".
- Muito mais aldeias/acampamentos do que cidades. Um hub pequeno só tem os serviços que a população sustenta (ver `NPCS_SERVICOS`).
- Segredos nunca bloqueiam a história principal; ficam a um desvio curto da rota, com pista visual.

## 5. Ligação missão ↔ lugar
Para cada beat de história/quest: (a) qual construção/lugar ele exige; (b) onde ele fica na rota; (c) o que o jogador vê ao chegar (silhueta, cor, luz); (d) o que o lugar diz sobre a história (lore); (e) que ID persistente o representa (POI/quest). Manter a matriz em `docs/planning/REG001_STORY_TO_MAP.md`.

## 6. Anti‑padrões
1. **Mapa de designer** — grades perfeitas, tudo simétrico: adicionar ao menos uma camada de desordem (muro remendado, casa torta, ruína).
2. **Perfeição funcional** — tudo serve ao jogador. Incluir construções que servem à vila (celeiro, poço, lenha) e não à quest.
3. **Escala impossível** — vila de 6 casas com guilda + templo + ferreiro + mercado. Ajustar serviços à população.
4. **Sem infraestrutura** — cidade sem água, vila sem estrada, moinho sem lavoura, cais sem estrada.
5. **Homogeneidade** — todo bairro igual; criar contraste centro/borda, rico/humilde, velho/novo.
6. **Portal solto** — entrada de dungeon ou marco de história sem ligação com o relevo/estrutura ao redor.
7. **Distância incoerente** — casa "do lenhador" a 300 px do próprio acampamento; estrutura de um POI longe do POI.

## 7. Verificação (antes de commitar)
1. `python3 game/tools/reg001/audit_logic.py` — checa distâncias a estrada/água/POI e relevo para cada construção declarada; deve terminar sem `FALHA`.
2. `tests/reg001_world.gd` (BFS de conectividade) e demais testes Godot.
3. Capturas reais (Godot) dos lugares alterados, ANTES/DEPOIS, em `docs/visual_qa/`.
4. Atualizar `docs/planning/REG001_STORY_TO_MAP.md` (matriz) e o checkpoint.
5. Nunca promover asset a APPROVED; usar somente APPROVED + MODELED_PENDING_GATE.
