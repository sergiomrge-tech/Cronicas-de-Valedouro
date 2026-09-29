# CRÔNICAS DE VALEDOURO — LOTE 04 / ATO IV — PÂNTANOS SOMBRIOS: HISTÓRIA → MAPA → ESTADOS v1

**Ato:** ACT_MAIN_04 — As Lanternas Afundadas  
**Região:** pantanos_sombrios  
**Níveis:** 36–48  
**Boss:** `BOSS_DAMA_JUNCOS_001`  
**Fonte canônica:** `game/data/main_story_v1.json`, `game/data/story_locations_v1.json`, `docs/canon/MAIN_STORY_CANON_v1.md`, `docs/canon/MAIN_STORY_CONSTRUCTION_PLAN_v1.md` e `docs/planning/MAIN_STORY_WORLD_TOPOLOGY_v1.md`.

## 1. Objetivo do Ato IV

O Pântano precisa contar visualmente que a Coroa Oca não consome apenas vidas: ela drena **identidade, memória e vínculos**.

A água é a infraestrutura central do mapa.
Estradas convencionais deixam de ser dominantes e são substituídas por:
- passarelas;
- palafitas;
- ilhotas;
- canais;
- barcos rasos;
- raízes;
- troncos;
- diques e comportas.

Fluxo canônico:

`Q_MS04_STILTS`
→ `Q_MS04_BELL`
→ `Q_MS04_MONASTERY`
→ `Q_MS04_REED_SANCTUM`
→ `Q_MS04_LADY_REEDS`
→ `Q_MS04_SLICE_GATE`
→ `Q_MS05_FROST_REST`.

## 2. Entrada no pântano

A transição do deserto deve ser gradual:
- areia compacta;
- argila;
- salinas ou leitos secos;
- canais rasos;
- vegetação resistente;
- junco;
- água escura;
- névoa.

A primeira visão importante é a **Vila das Lanternas** à distância.

As lanternas devem funcionar como linguagem de navegação: luzes marcam segurança, caminho, casas habitadas e memória preservada.

## 3. Topologia macro

### Camada A — Vila das Lanternas
`LOC_MARSH_STILT_VILLAGE`

Hub do pântano, construído sobre palafitas e ilhotas.

### Camada B — canais da névoa
Rede navegável em torno da vila, com lanternas apagando gradualmente.

### Camada C — Torre do Sino Afogado
`LOC_DROWNED_BELL_TOWER`

Landmark vertical visível da vila e de canais distantes.

### Camada D — Mosteiro Inundado
`LOC_FLOODED_MONASTERY`

Dungeon ligada aos canais revelados pelo sino.

### Camada E — Santuário dos Juncos
`LOC_REED_SANCTUM`

Zona mais antiga, profunda e ritualística.

### Camada F — Trono dos Juncos
`LOC_REED_THRONE`

Arena da Dama dos Juncos.

### Camada G — Comporta dos Ecos
`LOC_MARSH_ECHO_SLICE`

Grande estrutura hidráulica/ritual que regula o fluxo de água e Eco.

## 4. Identidade visual

Elementos-base:
- água escura porém legível;
- reflexos de lanternas;
- madeira úmida;
- cordas;
- pilares;
- palafitas;
- musgo;
- raízes;
- juncos altos;
- árvores parcialmente submersas;
- névoa localizada;
- pequenos brilhos naturais.

Evitar:
- água preta sem leitura;
- névoa cobrindo toda a tela;
- excesso de verde homogêneo;
- passarelas em grade perfeita;
- lanternas distribuídas como decoração aleatória.

A região deve parecer habitada e adaptada ao ambiente.

## 5. LOC_MARSH_STILT_VILLAGE — Vila das Lanternas

Quest:
`Q_MS04_STILTS`.

Estrutura:
- casas sobre palafitas;
- passarelas irregulares;
- cais pequenos;
- praça/plataforma comunal;
- mercado reduzido;
- curandeiro/serviço compatível;
- área de barcos;
- torre de observação baixa;
- lanternas suspensas.

Estados:
- chegada: várias lanternas apagadas; moradores confusos; casas fechadas;
- progresso: lanternas-chave podem reacender conforme memórias retornam;
- pós-ato: vila estabilizada, mais NPCs reconhecem o jogador, mas marcas do evento permanecem.

A vila não deve ficar totalmente vazia no começo.
A perda de memória deve ser percebida em comportamento e ambiente, não apenas ausência de NPC.

## 6. LOC_DROWNED_BELL_TOWER — Torre do Sino Afogado

Quest:
`Q_MS04_BELL`.

Posição:
- parcialmente submersa;
- visível de vários canais;
- antiga estrutura religiosa/cívica tomada pela água.

Construção:
- base afundada;
- torre inclinada ou danificada;
- acesso por passarela quebrada/barco;
- sino parcialmente submerso;
- mecanismo antigo.

Função visual:
antes de tocar o sino:
- névoa mais densa;
- canais secundários difíceis de ler;
- lanternas distantes enfraquecidas.

Ao tocar:
- onda sonora/visual controlada;
- névoa se abre por corredores;
- marcas aquáticas ou lanternas revelam o caminho do Mosteiro.

Pós-quest:
a torre continua landmark e puzzle/navegação.

## 7. LOC_FLOODED_MONASTERY — Mosteiro Inundado

Quest:
`Q_MS04_MONASTERY`.

O mosteiro deve parecer construído antes da inundação.

Exterior:
- pátio parcialmente submerso;
- claustro;
- sinos menores;
- jardim tomado por água;
- túmulos ou memoriais, se coerentes;
- acesso revelado pelo Sino.

Interior:
- corredores com diferentes níveis de água;
- biblioteca/arquivo;
- dormitórios;
- capela;
- passagens colapsadas;
- áreas acessíveis por passarelas improvisadas.

Objetivo:
recuperar o registro dos habitantes desaparecidos.

A sala do registro precisa ser um espaço de narrativa dedicado.

Estados:
- antes: névoa/corrupção forte;
- após recuperar registros: elementos do arquivo ficam disponíveis para codex;
- pós-boss: parte da água/iluminação pode clarear, mas o mosteiro continua inundado.

## 8. LOC_REED_SANCTUM — Santuário dos Juncos

Quest:
`Q_MS04_REED_SANCTUM`.

Local:
- coração natural do pântano;
- círculo de terra/raízes cercado por água;
- acesso ritual através de canais estreitos;
- pedras antigas e juncos monumentais.

Função:
revelar que a antiga guardiã virou hospedeira do General dos Juncos Mortos.

Estados:
- bloqueado por raízes/juncos/canais antes da missão;
- aberto após eventos do Mosteiro;
- corrupção visual aumenta perto do Trono.

Não transformar o santuário em prédio de pedra convencional.
A arquitetura deve parecer integrada ao pântano.

## 9. LOC_REED_THRONE — Trono dos Juncos

Quest:
`Q_MS04_LADY_REEDS`.

Boss:
`BOSS_DAMA_JUNCOS_001`.

Arena:
- plataforma natural/ritual;
- água ao redor ou zonas rasas;
- juncos e raízes delimitando bordas;
- espaço central limpo para combate;
- elementos laterais que respondem às fases do boss.

Telegráficos:
o ambiente deve ajudar leitura dos ataques, não escondê-los.

Estados:
- pré-boss: drenagem de memória ativa; luzes/lanternas distantes enfraquecem;
- boss ativo: efeitos temporários;
- primeira derrota: vínculo rompido, memória liberada;
- pós-boss: luz natural volta parcialmente, partículas hostis diminuem;
- revanche: efeitos podem reativar só na arena; estado narrativo externo permanece pós-derrota.

## 10. LOC_MARSH_ECHO_SLICE — Comporta dos Ecos

Quest:
`Q_MS04_SLICE_GATE`.

É a peça de infraestrutura mais importante do ato.

Conceito:
uma grande comporta construída originalmente para controlar água, depois adulterada para canalizar Eco.

Posição:
- estreitamento de grande canal;
- conexão entre zonas mais baixas e rota ao norte;
- fundações de pedra;
- passarelas de manutenção.

Estrutura:
- portões;
- engrenagens/contrapesos;
- canais laterais;
- plataforma de operação;
- runas/mecanismos de Eco adicionados depois.

Estado inicial:
- fluxo de Eco ativo;
- água/partículas puxadas em direção errada ou artificial;
- vegetação próxima degradada.

Ao fechar:
- fluxo de Eco interrompido;
- água retoma comportamento natural;
- iluminação muda discretamente;
- caminho para norte se torna navegável/legível;
- sinal do próximo destino aparece sem precisar de teleporte.

Persistência:
estado fechado deve sobreviver a save/load.

## 11. Sistema visual de memória

O Ato IV precisa de uma linguagem visual consistente para memória roubada.

Usar combinações como:
- lanternas apagadas;
- objetos pessoais abandonados;
- placas sem inscrições legíveis;
- retratos/memoriais com detalhes ausentes;
- NPCs repetindo rotinas;
- ecos visuais breves em pontos específicos.

Ao devolver memórias:
- lanternas reacendem;
- alguns objetos voltam ao uso;
- diálogos/rotinas mudam;
- detalhes de ambientes retornam.

Evitar efeitos que pareçam bug de textura ou objeto desaparecendo sem explicação.

## 12. Estados persistentes do Ato IV

### P0 — Memórias sendo drenadas
Vila instável, lanternas apagando, névoa forte.

### P1 — Sino restaurado
Canais ocultos revelados, navegação melhora.

### P2 — Registro recuperado
Verdade sobre desaparecidos e drenagem preservada no codex.

### P3 — Santuário aberto
Caminho para Dama dos Juncos disponível.

### P4 — Dama derrotada
Memórias retornam; lanternas e NPCs mudam estado.

### P5 — Comporta fechada
Fluxo de Eco cessado; rota norte liberada.

## 13. Exploração secundária

A região deve conter:
- pequenos cais;
- casas isoladas;
- barcos abandonados;
- ilhotas secretas;
- recursos de pântano;
- pelo menos um mirante elevado incomum para a região;
- atalhos por passarelas reparáveis;
- rotas circulares após o Sino.

Segredos nunca podem bloquear a campanha.

## 14. Transição Ato IV → Ato V

A mudança para Montanhas Nevadas deve acontecer por elevação progressiva:

pântano profundo
→ terras úmidas altas
→ bosque frio
→ pedra exposta
→ neve esparsa
→ garganta
→ `LOC_FROST_REST`.

A Comporta dos Ecos deve justificar a abertura/estabilização dessa rota.

## 15. Performance mobile

- água animada deve usar solução barata e consistente;
- limitar partículas por área;
- névoa por zonas, não fullscreen pesada;
- casas e passarelas modularizadas;
- interiores descarregados quando distantes;
- reflexos simplificados;
- culling por setores/canais.

## 16. Ordem de produção do Lote 4

### Parte 4A
Vila + canais iniciais + sistema de lanternas.

### Parte 4B
Torre do Sino + estado antes/depois + revelação de navegação.

### Parte 4C
Mosteiro Inundado completo.

### Parte 4D
Santuário dos Juncos + aproximação.

### Parte 4E
Trono dos Juncos + boss + estados persistentes/revanche.

### Parte 4F
Comporta dos Ecos + transição ambiental para Montanhas Nevadas.

## 17. Gate final

O Ato IV só está pronto quando:
- 6 locais canônicos existem;
- água realmente organiza a navegação;
- lanternas têm função visual;
- Sino altera leitura dos canais;
- Mosteiro não é dungeon genérica;
- Dama possui arena própria;
- Comporta altera ambiente persistentemente;
- pós-boss não é revertido por revanche;
- transição ao norte é coerente;
- testes anteriores passam;
- capturas são reais;
- direção visual oficial foi preservada.
