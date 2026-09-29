# CRÔNICAS DE VALEDOURO — LOTE 03 / ATO III — EDRAVAR: HISTÓRIA → MAPA → ESTADOS v1

**Ato:** ACT_MAIN_03 — Cinzas de Edravar  
**Região:** deserto_ruinas  
**Níveis:** 24–36  
**Boss:** `BOSS_GENERAL_CINZA_001`  
**Fonte canônica:** `game/data/main_story_v1.json`, `game/data/story_locations_v1.json`, `docs/canon/MAIN_STORY_CANON_v1.md`, `docs/canon/MAIN_STORY_CONSTRUCTION_PLAN_v1.md` e `docs/planning/MAIN_STORY_WORLD_TOPOLOGY_v1.md`.

## 1. Objetivo do Ato III

Edravar precisa mostrar ao jogador, visualmente, que a Guerra da Coroa Oca não é uma abstração distante.

O Ato III deve contar três histórias simultâneas:

1. **uma civilização derrotada militarmente, mas ainda viva;**
2. **uma população que mantém resistência e rotas subterrâneas;**
3. **uma máquina de guerra que transforma calor, morte, medo e ruína em Eco.**

O deserto NÃO deve ser apenas "areia + ruínas".
A região precisa conter infraestrutura real, memória urbana, ocupação militar e rotas de sobrevivência.

Fluxo canônico:

`Q_MS03_CARAVAN`
→ `Q_MS03_AMBER_POST`
→ `Q_MS03_EDRAVAR`
→ `Q_MS03_CISTERN`
→ `Q_MS03_OBSERVATORY`
→ `Q_MS03_GENERAL_ASH`
→ `Q_MS04_STILTS`.

## 2. Entrada na região

A transição do Ato II para o Ato III deve acontecer gradualmente:

Floresta Ancestral
→ vegetação mais seca
→ solo pedregoso
→ pradaria árida
→ dunas / ruínas de estrada
→ rota de caravanas
→ `LOC_AMBER_CARAVAN`.

A primeira leitura do deserto deve ser de distância, vento e exposição.

A Caravana de Âmbar serve como introdução humana à região antes do jogador ver Edravar.

## 3. Topologia macro obrigatória

### Camada A — Rota das caravanas

`LOC_AMBER_CARAVAN`

- estrada comercial antiga;
- pegadas, marcas de roda e pedras de orientação;
- carroças e animais de carga, se compatíveis com o sistema;
- acampamento modular;
- pontos de sombra;
- vestígios de emboscadas antigas;
- silhueta distante do Posto de Âmbar.

A caravana é móvel narrativamente, mas sua representação na primeira passagem deve ocupar um ponto lógico da rota.

### Camada B — Posto de Âmbar

`LOC_AMBER_POST`

É o primeiro hub funcional do Ato III.

Deve ficar:
- em cruzamento de rotas;
- perto de água controlável: poço, cisterna superficial ou reservatório;
- antes da zona militarmente ocupada;
- em terreno defensável, mas não em fortaleza monumental.

Funções:
- comércio;
- descanso;
- informação;
- fast travel;
- ligação clandestina com refugiados e resistência.

### Camada C — Periferia de Edravar

A aproximação de `LOC_EDRAVAR_OCCUPIED_CITY` precisa mostrar a queda antes da entrada:

- campos secos;
- aqueduto interrompido;
- casas abandonadas;
- carroças queimadas;
- torres quebradas;
- postos da Coroa Oca;
- valas ou barricadas;
- partes da antiga estrada enterradas pela areia.

O jogador deve enxergar Edravar antes de entrar.

### Camada D — Edravar Ocupada

`LOC_EDRAVAR_OCCUPIED_CITY`

A cidade deve possuir pelo menos quatro zonas legíveis:

1. **Portão / Distrito Exterior**
   - muralha danificada;
   - ocupação militar;
   - circulação controlada;
   - marcas de cerco.

2. **Distrito Civil**
   - residências parcialmente ocupadas;
   - lojas fechadas;
   - pequenos grupos de sobreviventes;
   - sinais discretos de resistência.

3. **Centro Cívico em Ruínas**
   - arquitetura antiga de Edravar;
   - praça ou avenida principal;
   - monumentos danificados;
   - presença pesada da Coroa Oca.

4. **Zona de acesso subterrâneo**
   - entradas discretas para cisternas;
   - drenagens;
   - porões;
   - poços;
   - passagens de manutenção.

A cidade não pode parecer completamente morta.
A missão é infiltrar uma cidade ocupada, não visitar uma cidade vazia.

### Camada E — Cisterna da Resistência

`LOC_EDRAVAR_RESISTANCE_CISTERN`

Fica fisicamente sob Edravar.

Estrutura:
- grandes reservatórios antigos;
- pilares;
- canais;
- passarelas;
- escadas de serviço;
- salas reaproveitadas;
- esconderijos;
- arquivo protegido da resistência.

Função narrativa:
aqui o jogador encontra registros que provam que Adrian Vale já lutou ao lado de Edravar.

A arquitetura da cisterna precisa mostrar duas épocas:
- infraestrutura original da cidade;
- adaptações improvisadas da resistência.

### Camada F — Caminho do Observatório

A saída subterrânea ou rota secreta da resistência deve permitir alcançar `LOC_ASH_OBSERVATORY` evitando o caminho militar principal.

Progressão visual:
cidade densa
→ ruínas periféricas
→ terreno alto
→ estruturas técnicas/rituais
→ Observatório.

### Camada G — Observatório de Cinzas

`LOC_ASH_OBSERVATORY`

É dungeon principal e máquina de conversão de Eco.

Local:
- elevação natural ou platô;
- horizonte livre;
- visibilidade para Edravar e áreas destruídas;
- arquitetura de observação antiga modificada pela Coroa Oca.

Estrutura:
- pátio exterior;
- salas de instrumentos;
- galerias técnicas;
- câmaras de coleta;
- mecanismos de Eco;
- núcleo de conversão.

O jogador deve compreender visualmente a tese do ato:
**a guerra está sendo transformada em energia.**

### Camada H — Cidadela da Cinza

`LOC_ASH_CITADEL`

É a fortaleza do `BOSS_GENERAL_CINZA_001`.

Deve dominar uma rota estratégica depois do Observatório.

Silhueta:
- fortificação vertical;
- torres assimétricas;
- pedra escurecida;
- bandeiras ou símbolos da Coroa Oca;
- fornalhas / chaminés / brasas controladas;
- muralhas sobre terreno elevado.

A Cidadela não é apenas arena.
Ela precisa parecer o centro militar da ocupação regional.

## 4. Identidade visual de Edravar

A arquitetura precisa parecer anterior à ocupação.

Base de Edravar:
- arenito;
- pedra clara;
- arcos;
- pátios;
- terraços;
- canais;
- mosaicos geométricos;
- sombra arquitetônica profunda;
- tecidos e madeira em pontos civis.

Camada de ocupação:
- metal escuro;
- reforços improvisados;
- estandartes da Coroa Oca;
- barricadas;
- grades;
- estruturas rituais;
- cinza e fuligem;
- iluminação quente hostil.

Resultado desejado:
o jogador deve conseguir distinguir visualmente:
**"isso era Edravar"** de **"isso foi colocado pela Coroa Oca"**.

## 5. LOC_AMBER_CARAVAN — Caravana de Âmbar

Quest:
`Q_MS03_CARAVAN` — escoltar Sahir ao Posto de Âmbar.

Elementos:
- 3–5 unidades visuais de caravana;
- tendas pequenas;
- caixas de mercadoria;
- recipientes de água;
- fogueira;
- lona de sombra;
- sinais de rota;
- mercadorias de âmbar.

Durante a escolta:
- ataques devem ocorrer em trechos onde o terreno comporta combate;
- evitar combate preso entre carroças;
- pontos de emboscada podem usar rochas, ruínas de estrada e dunas.

Pós-quest:
- a caravana continua existindo como comerciante itinerante/contratos;
- não desaparecer completamente após cumprir a missão.

## 6. LOC_AMBER_POST — Posto de Âmbar

Quest:
`Q_MS03_AMBER_POST`.

Construção:
- muralha baixa;
- portão simples;
- pátio;
- estábulo/carga;
- poço ou reservatório;
- área de comércio;
- pousada ou abrigo;
- torre pequena de observação.

Camada clandestina:
- passagem para refugiados;
- símbolo discreto da resistência;
- fundo falso, alçapão ou depósito funcional.

Estados:
- chegada: ambiente tenso, comerciantes cautelosos;
- após contato: rota clandestina é revelada;
- pós-Ato III: mais refugiados/mercadores podem circular, sem transformar o posto em cidade.

## 7. LOC_EDRAVAR_OCCUPIED_CITY — Edravar Ocupada

Quest:
`Q_MS03_EDRAVAR`.

Escala:
é a primeira grande cidade arruinada/ocupada da campanha.
Precisa superar visualmente os hubs pequenos anteriores em área e complexidade.

Obrigatório:
- muralha ou limite urbano;
- portão controlado;
- ruas parcialmente bloqueadas;
- linhas alternativas;
- telhados/varandas/ruínas que criem profundidade;
- pelo menos uma praça;
- pelo menos um eixo cívico;
- acessos subterrâneos;
- zonas onde civis ainda vivem.

Ocupação:
- patrulhas;
- postos;
- estandartes;
- fogueiras militares;
- jaulas ou áreas de detenção somente se coerentes com a classificação etária/direção do jogo;
- bloqueios.

Resistência:
- símbolos discretos;
- portas falsas;
- mensageiros;
- rotas entre edifícios;
- sinais que o jogador aprende a reconhecer.

Estados:
- pré-infiltração: patrulhamento forte;
- após contato com resistência: atalhos e acessos secretos;
- pós-General: presença militar reduzida, alguns bloqueios removidos, civis reaparecem gradualmente;
- não reconstruir a cidade instantaneamente.

## 8. LOC_EDRAVAR_RESISTANCE_CISTERN — Cisterna da Resistência

Quest:
`Q_MS03_CISTERN`.

Layout:
- entrada discreta;
- corredor estreito;
- abertura para salão monumental da cisterna;
- passarelas laterais;
- água parcialmente acumulada;
- base da resistência;
- sala de arquivo.

Props:
- mapas;
- documentos;
- lanternas;
- mesas;
- camas improvisadas;
- suprimentos;
- caixas escondidas;
- marcas antigas nas paredes.

Momento Adrian Vale:
a área que contém os registros deve ter composição própria.
Não colocar a revelação importante em uma mesa aleatória no canto.

Pós-quest:
- base continua acessível;
- fornece missões secundárias/apoio;
- registros podem ir para codex.

## 9. LOC_ASH_OBSERVATORY — Observatório de Cinzas

Quest:
`Q_MS03_OBSERVATORY`.

Dungeon com leitura vertical.

Exterior:
- base do platô;
- caminho em espiral ou rampa;
- restos de instrumentos;
- torres de observação;
- coletores de Eco.

Interior:
1. entrada administrativa/antiga;
2. salas de cálculo;
3. mecanismo adulterado;
4. galerias de conversão;
5. núcleo.

A máquina da Coroa:
- canais de Eco;
- calor;
- vibração;
- partículas;
- estruturas que apontam para regiões destruídas;
- feedback ambiental quando partes são desativadas.

Estado:
- antes: sistema completamente ativo;
- durante dungeon: setores desligam progressivamente;
- após desativação: brilho reduzido, mecanismos imóveis/dormentes;
- persistir após save/load.

Pós-quest:
Dungeon repetível pode reativar ameaças temporárias, mas não deve restaurar o estado narrativo de drenagem regional.

## 10. LOC_ASH_CITADEL — Cidadela da Cinza

Quest:
`Q_MS03_GENERAL_ASH`.

Boss:
`BOSS_GENERAL_CINZA_001`.

Aproximação:
- estrada militar;
- ruínas queimadas;
- checkpoints;
- muralhas escalonadas;
- sinais de que o General controla Edravar daqui.

Arena:
- pátio ou salão grande construído especificamente para padrões do boss;
- linhas de visão claras;
- zonas de risco legíveis;
- decoração nas bordas, não no espaço crítico de movimentação.

Estado pré-boss:
- fornalhas;
- fumaça;
- estandartes;
- tropas;
- mecanismo ativo.

Primeira derrota:
- flag persistente do boss;
- estandarte principal cai ou muda de estado;
- fornalhas reduzem;
- presença militar regional diminui;
- acesso de retorno continua disponível;
- materiais do General habilitam crafting/recompensas conforme sistemas futuros.

Revanche:
- boss e efeitos de arena podem reativar temporariamente;
- estado político/narrativo de Edravar não volta à ocupação máxima.

## 11. Estados persistentes do Ato III

### E0 — Região ocupada
- Edravar militarizada;
- Observatório drenando Eco;
- Cidadela ativa.

### E1 — Rede da resistência conhecida
- atalhos clandestinos revelados;
- acesso à cisterna persistente.

### E2 — Verdade sobre Adrian recuperada
- registros entram no codex;
- diálogo ambiental/NPCs pode reconhecer a descoberta.

### E3 — Observatório desligado
- máquina dormente;
- redução visual de drenagem;
- céu/partículas podem melhorar discretamente.

### E4 — General da Cinza derrotado
- presença militar reduzida;
- algumas barricadas removidas;
- civis retomam zonas específicas;
- Cidadela marcada pela derrota.

### E5 — Pós-Ato III
- Edravar continua danificada;
- resistência permanece ativa;
- rota para o Pântano é liberada;
- região mantém conteúdo repetível.

## 12. Transição Ato III → Ato IV

A rota para os Pântanos Sombrios deve nascer de uma necessidade física plausível.

Sugestão de implantação:
- antiga rota de drenagem/refugiados;
- terreno desce;
- areia dá lugar a solo argiloso;
- surgem canais;
- vegetação seca vira junco;
- névoa aumenta;
- finalmente aparecem as primeiras lanternas da `LOC_MARSH_STILT_VILLAGE`.

Evitar teleporte visual abrupto entre deserto e pântano.

## 13. Regras de performance mobile

Edravar será visualmente densa.
Para Android:

- usar modularidade e instancing;
- limitar partículas longas;
- occlusion/culling quando aplicável;
- dividir cidade em setores;
- não manter interiores distantes ativos;
- usar estados de ocupação para desativar elementos desnecessários;
- manter colisores simples onde o detalhe visual não exige precisão física.

A densidade visual não pode comprometer estabilidade.

## 14. Ordem de produção do Lote 3

### Parte 3A
Caravana + Posto de Âmbar + rota de chegada.

### Parte 3B
Periferia de Edravar + muralha + distritos-base.

### Parte 3C
Cisterna da Resistência + rotas subterrâneas.

### Parte 3D
Observatório de Cinzas completo + estados ativo/dormente.

### Parte 3E
Cidadela da Cinza + arena do General + estados pré/pós/revanche.

### Parte 3F
Passagem ambiental para Pântanos + revisão geral de continuidade.

Cada parte deve:
1. validar IDs;
2. validar navegação;
3. validar estados;
4. gerar capturas reais quando houver ambiente com tela;
5. commitar separadamente;
6. não promover assets a APPROVED sem decisão do Diretor.

## 15. Gate final do Ato III

Ato III só pode ser considerado pronto quando:

- todos os 6 locais canônicos existem;
- Edravar parece cidade ocupada, não ruína vazia;
- a Cisterna está fisicamente sob/ligada à cidade;
- Observatório demonstra visualmente a conversão da guerra em Eco;
- Cidadela domina militarmente a região;
- derrota do General altera o mundo de forma persistente;
- revanche não desfaz história;
- rota ao Ato IV é legível;
- todos os testes anteriores continuam passando;
- nenhuma referência quebrada;
- nenhuma captura falsa;
- visual permanece coerente com a direção oficial do projeto.
