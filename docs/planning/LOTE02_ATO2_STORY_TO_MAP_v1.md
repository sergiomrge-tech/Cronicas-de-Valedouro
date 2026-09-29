# CRÔNICAS DE VALEDOURO — LOTE 02 / ATO II — HISTÓRIA → MAPA → ESTADOS v1

**Ato:** ACT_MAIN_02 — A Floresta que Lembra  
**Região:** floresta_ancestral  
**Níveis:** 12–24  
**Fonte canônica:** `game/data/main_story_v1.json`, `game/data/story_locations_v1.json`, `docs/canon/MAIN_STORY_CANON_v1.md` e `docs/canon/MAIN_STORY_CONSTRUCTION_PLAN_v1.md`.  
**Regra:** este documento não cria lore paralela. Ele define implantação espacial, estados visuais e função jogável dos locais já canônicos.

## 1. Objetivo do lote

Construir a Floresta Ancestral como uma região completa, coerente e navegável, em que a própria paisagem conta a história de Adrian Vale antes de Azharel.

A região deve parecer antiga, viva e capaz de recordar. O jogador deve perceber, sem depender apenas de texto, três camadas:

1. **floresta protetora** — natureza antiga que reage ao Segundo Viajante;
2. **memória preservada** — pedras, raízes e árvores registram acontecimentos;
3. **corrupção externa** — a Raiz Oca não nasceu ali; ela invade e drena a memória do lugar.

A progressão espacial deve acompanhar exatamente a progressão das quests:

`Q_MS02_BORDER`
→ `Q_MS02_RANGERS`
→ `Q_MS02_ROOTS`
→ `Q_MS02_MEMORY_TREE`
→ `Q_MS02_HOLLOW_ROOT`
→ `Q_MS02_VEIL_SHRINE`
→ saída narrativa para `Q_MS03_CARAVAN`.

## 2. Regra de ligação com o Ato I

A Floresta Ancestral é uma REGIÃO nova. Não transformar o bosque local do REG_001 na região inteira do Ato II.

O bosque do Berço de Valedouro continua sendo o ecossistema inicial ligado às Ruínas do Primeiro Vento e aos contratos do Ato I.

A passagem entre os atos deve ser clara:

**Valedouro / Arquivo das Seis Coroas**
→ estrada de saída
→ ecótono de floresta comum para floresta ancestral
→ **Ponte de Pedra da Fronteira**
→ Floresta Ancestral.

A Ponte de Pedra é o marco visual que diz ao jogador: “você entrou em outra região”.

Evitar teleporte abrupto sempre que o mapa permitir conexão física.

## 3. Topologia macro obrigatória

A região deve seguir esta composição topológica, preservando liberdade de exploração entre os nós:

### Camada A — Fronteira
- `LOC_FOREST_STONE_BRIDGE`
- estrada antiga parcialmente tomada por raízes;
- rio, garganta ou curso d'água sob a ponte;
- pedras limítrofes e sinais de antigas patrulhas;
- vegetação ainda semelhante ao Berço na margem de entrada;
- vegetação mais alta, antiga e luminosa depois da ponte.

### Camada B — Zona dos Guardas
- `LOC_FOREST_RANGER_LODGE`
- pequena clareira funcional;
- torre/estrado de observação baixo, depósito, fogueira, bancada de ervas e alvos de treino;
- trilhas de patrulha;
- sinais físicos do ataque de criaturas corrompidas.

A Casa dos Guardas Verdes é o hub leve da região e NÃO uma cidade.

### Camada C — Três braços das raízes
- `LOC_FOREST_ROOT_SHRINES`
- três santuários distintos ligados ao mesmo sistema radicular;
- cada santuário deve estar em uma microárea própria;
- os três braços devem voltar a convergir para o centro da floresta;
- purificar os três não pode exigir backtracking artificial excessivo.

Sugestão de leitura espacial:
1. Raiz da Água — terreno úmido, pedras cobertas de musgo, pequenas quedas d'água;
2. Raiz da Pedra — afloramentos antigos, raízes abraçando rocha e ruínas;
3. Raiz do Vento — terreno elevado, árvores inclinadas e folhas em movimento.

Os nomes acima são somente descrições de produção; não criar novos nomes canônicos ou lore sem aprovação.

### Camada D — Coração preservado
- `LOC_MEMORY_TREE`
- landmark visual dominante do Ato II;
- deve ser reconhecível à distância em múltiplos pontos da região;
- raízes monumentais formam caminhos, arcos e níveis;
- interior/coração acessível na missão;
- espaço para sequências de memória sem transformar o local em sala vazia.

### Camada E — Profundezas corrompidas
- `LOC_HOLLOW_ROOT_ARENA`
- situada abaixo, atrás ou dentro do sistema radicular da Árvore-Memória;
- acesso deve parecer uma ferida aberta na floresta;
- corrupção aumenta progressivamente no caminho;
- arena desenhada especificamente para o boss `BOSS_RAIZ_OCA_001`;
- não reutilizar clareira genérica.

### Camada F — Revelação e saída
- `LOC_FOREST_CARTOGRAPHER_SHRINE`
- ruína mais antiga que a ocupação dos Guardas;
- arquitetura deve conectar visualmente os Cartógrafos do Véu às Ruínas do Primeiro Vento sem ser cópia;
- após a derrota da Raiz Oca, o caminho até este santuário se torna claramente legível;
- o Selo Verde e a segunda linha do mapa apontam para Edravar;
- a rota de saída deve orientar naturalmente o jogador para a futura conexão com Deserto e Ruínas.

## 4. Silhueta e identidade visual

Preservar a direção visual oficial atual de Crônicas de Valedouro.

A Floresta Ancestral precisa ter identidade própria em relação ao bosque do Ato I:

- árvores muito mais antigas e largas;
- copas sobrepostas formando teto natural;
- raízes acima do solo usadas como composição;
- pedras pré-guerra parcialmente engolidas pela vegetação;
- água rasa, musgo, fungos e folhas;
- pontos de bioluminescência discretos, nunca neon excessivo;
- feixes de luz atravessando a copa;
- sombras profundas, mas com leitura clara de navegação;
- pequenos vestígios humanos incorporados pela natureza;
- áreas de corrupção com perda progressiva de cor natural, veios escuros e brilho de Eco controlado.

Não usar árvores repetidas em grade.
Não preencher todo espaço com props.
Criar massas, clareiras e corredores visuais.

## 5. Construções e ambiente ao redor

### 5.1 LOC_FOREST_STONE_BRIDGE — Ponte de Pedra da Fronteira

**Função de história:** `Q_MS02_BORDER` — entrada da região.

Construção:
- ponte de pedra antiga, larga o bastante para circulação de patrulha;
- arco(s) estruturais visíveis;
- guarda-corpo parcialmente quebrado;
- pedras com musgo e raízes;
- marcos de fronteira de ambos os lados;
- pequena plataforma/descanso na margem da floresta.

Ambiente:
- rio ou garganta real sob a ponte;
- pedras molhadas;
- árvores mudando gradualmente de escala;
- trilha antiga;
- galhos formando uma “porta natural” depois da ponte.

Estado narrativo:
- antes da chegada: trilhas interiores fechadas visualmente por raízes/vegetação;
- ao Segundo Viajante atravessar: abertura visual suave de uma rota, sem parecer mecanismo artificial;
- depois: ponte funciona como fast travel e conexão persistente.

### 5.2 LOC_FOREST_RANGER_LODGE — Casa dos Guardas Verdes

**Função:** `Q_MS02_RANGERS`.

Construção:
- casa de madeira e pedra construída ao redor de árvores, não derrubando o bosque inteiro;
- telhado envelhecido;
- varanda;
- pequeno depósito;
- posto de observação;
- mesa de mapas;
- ervas secando;
- alvos de treino;
- racks de arco/lança;
- abrigo para montaria ou carga, se existir sistema compatível.

Ambiente:
- clareira defendida;
- paliçada parcial e orgânica;
- trilhas de patrulha;
- fogueira;
- marcas de ataque;
- árvores arranhadas e partes de cerca quebradas.

Estados:
- pré-quest: sinais de ataque, barricadas improvisadas, NPCs em alerta;
- durante defesa: pontos claros de entrada das criaturas;
- pós-defesa: reparos visuais leves, fogueira estável, guardas retomam rotina;
- pós-ato: contratos e suporte permanecem disponíveis.

### 5.3 LOC_FOREST_ROOT_SHRINES — Três Santuários de Raiz

**Função:** `Q_MS02_ROOTS`.

Cada santuário deve:
- ser reconhecível como parte da mesma cultura;
- ter variação própria de terreno e composição;
- possuir núcleo/runa/altar integrado às raízes;
- permitir leitura clara de estado corrompido vs purificado.

Estado corrompido:
- raízes escurecidas;
- partículas/veios de Eco;
- vegetação próxima murcha;
- pequenas criaturas corrompidas;
- som/iluminação mais hostil.

Estado purificado:
- runa estável;
- cor natural retorna;
- plantas e partículas leves;
- água/folhas retomam movimento normal;
- nenhum brilho exagerado de “quest concluída”.

Persistência:
- usar a fonte de verdade da quest/estado de mundo já existente;
- não criar um segundo sistema de flags visual separado.

### 5.4 LOC_MEMORY_TREE — Árvore-Memória

**Função:** `Q_MS02_MEMORY_TREE`.

É o principal landmark do Ato II.

Estrutura:
- tronco colossal;
- raízes formando passagens;
- cavidade/coração interno;
- plataformas naturais;
- inscrições antigas quase engolidas pela casca;
- espaço para memórias visuais de Adrian.

Ambiente:
- grande clareira central;
- água rasa ou espelho d'água parcial;
- pedras memoriais;
- folhas em movimento lento;
- partículas discretas;
- visibilidade parcial do topo da árvore em vários trechos da região.

Estados:
- antes dos três santuários: árvore silenciosa, acesso ao coração bloqueado organicamente;
- após purificação: raízes se afastam/abrem a passagem;
- durante memória: iluminação e partículas podem mudar temporariamente;
- depois: árvore permanece ativa como codex/memória, sem repetir automaticamente a cena principal.

### 5.5 LOC_HOLLOW_ROOT_ARENA — Coração da Raiz Oca

**Função:** `Q_MS02_HOLLOW_ROOT`.  
**Boss:** `BOSS_RAIZ_OCA_001`.

Arena:
- espaço criado pelo rompimento das raízes profundas;
- raízes gigantes delimitam o campo;
- zonas de corrupção visuais;
- pontos claros para telegráficos de ataques;
- circulação sem obstáculos decorativos que prejudiquem combate;
- fundo/parede vegetal mostrando que o jogador está abaixo ou dentro do sistema da Árvore-Memória.

Estados:
- pré-boss: corrupção máxima, núcleo ativo;
- boss ativo: efeitos temporários podem intensificar;
- primeira derrota: estado narrativo persistente de núcleo dormente/purificado;
- revanche, se implementada: efeitos de combate podem reativar temporariamente sem desfazer o estado narrativo;
- pós-boss: rota para o Santuário dos Cartógrafos torna-se visível/acessível.

Aplicar o mesmo princípio definido para o Guardião da Mina: primeira derrota é progresso persistente; revanche é estado temporário.

### 5.6 LOC_FOREST_CARTOGRAPHER_SHRINE — Santuário dos Cartógrafos

**Função:** `Q_MS02_VEIL_SHRINE`.

Construção:
- ruínas de pedra antigas;
- geometria/runa que remeta ao sistema do Primeiro Vento;
- mesa/cartografia/anel de pedra capaz de receber o Selo Verde;
- oito referências radiais ou outro motivo coerente com as oito linhas, sem transformar o local em interface moderna.

Ambiente:
- clareira elevada ou borda de formação natural;
- vista parcial para a direção da próxima região;
- vegetação recuperada após a derrota da Raiz Oca;
- elementos sutis que indiquem antiguidade anterior à guerra.

Estado:
- antes: caminho parcialmente encoberto e mecanismo inerte;
- após boss: caminho aberto;
- ao obter Selo Verde: mecanismo acende e projeta/indica a segunda linha;
- depois: continua acessível como atualização de mapa/lore.

## 6. Rotas secundárias e exploração

A rota principal não pode ser um corredor.

Entre os seis locais principais, criar:
- 2–3 atalhos destraváveis;
- pequenas clareiras de combate;
- recursos naturais;
- pelo menos um mirante;
- 1–2 segredos com retorno visual à história dos Cartógrafos;
- conexões circulares que reduzam caminhada após abrir a região;
- trilhas que permitam enxergar um landmark antes de alcançá-lo.

Nenhuma estrutura grande extra deve ser criada sem função.

Pequenos props e ruínas ambientais podem existir para dar contexto, desde que não pareçam POIs principais sem conteúdo.

## 7. Progressão visual do ato

### Estado F0 — Entrada
Floresta protegida, fechada, desconfiada. A corrupção é localizada.

### Estado F1 — Guardas defendidos
O hub leve estabiliza; trilhas para os santuários ficam mais legíveis.

### Estado F2 — Santuários em processo
Cada raiz purificada deve modificar localmente a área correspondente.

### Estado F3 — Três raízes purificadas
A Árvore-Memória “acorda”; acesso ao coração é aberto.

### Estado F4 — Memória revelada
A corrupção profunda é identificada e a rota à Raiz Oca se abre.

### Estado F5 — Raiz Oca derrotada
A floresta recupera parte da vitalidade. Não transformar instantaneamente tudo em paraíso: marcas da corrupção permanecem.

### Estado F6 — Selo Verde recuperado
Santuário dos Cartógrafos ativo, segunda linha revelada, rota para o Ato III destacada.

## 8. Regras de implementação de estado

1. Quest/state manager é fonte de verdade.
2. Renderer só lê o estado e escolhe variante visual.
3. Assets não devem conter lógica de missão.
4. Revanche não pode desfazer conclusão narrativa.
5. Saves anteriores precisam de default seguro.
6. Alteração visual persistente deve ser determinística após save/load.
7. Não criar nomes/IDs substitutos para `LOC_*`, `Q_MS02_*` ou `BOSS_RAIZ_OCA_001`.

## 9. Ordem de produção recomendada para o Lote 2

### Parte 2A — Fronteira e hub
- Ponte de Pedra;
- ecótono;
- Casa dos Guardas;
- clareira e rotas próximas;
- estados pré/pós defesa.

### Parte 2B — Sistema das três raízes
- três microáreas;
- santuários;
- variantes corrompido/purificado;
- caminhos e atalhos.

### Parte 2C — Landmark central
- Árvore-Memória;
- área externa;
- interior/coração;
- estado bloqueado/ativo;
- suporte às cenas de memória.

### Parte 2D — Boss
- aproximação corrompida;
- Coração da Raiz Oca;
- arena;
- estados ativo/dormente/revanche.

### Parte 2E — Revelação e saída
- Santuário dos Cartógrafos;
- estado inerte/ativo;
- rota de saída para Edravar;
- revisão geral de continuidade.

Cada parte deve ser validada antes da seguinte.

## 10. Gates obrigatórios

Antes de declarar o Ato II pronto:

- todos os locais canônicos existem;
- todas as quests do Ato II apontam para local físico correto;
- rotas principais e retornos são navegáveis;
- nenhuma construção principal está sem função;
- estados pré/pós missão sobrevivem a save/load;
- boss arena não é genérica;
- visual segue o padrão aprovado;
- sem assets REWORKED/HOLD no renderer;
- testes Godot existentes continuam passando;
- novos testes cobrem os estados persistentes;
- capturas usadas como prova devem ser reais do Godot;
- nenhuma captura mockada pode ser apresentada como jogo.

## 11. Gate de integração do Gerente GPT

O Gerente GPT fará a implantação final no mapa quando os assets do Lote 2 estiverem prontos e validados.

A implantação deve preservar:
- IDs canônicos;
- ordem das missões;
- função pós-missão;
- navegabilidade;
- leitura de landmarks;
- densidade ambiental;
- performance mobile;
- compatibilidade com Godot 4.7.2.

O lote artístico não deve escolher posições finais irreversíveis sem respeitar esta topologia e os dados canônicos.
