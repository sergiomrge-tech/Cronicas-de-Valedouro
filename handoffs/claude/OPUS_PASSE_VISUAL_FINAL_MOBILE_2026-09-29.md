# OPUS — PASSE VISUAL FINAL MOBILE — 29/09/2026

## Missão

Fechar o gate visual atual de Crônicas de Valedouro no MOBILE antes de iniciar personagens, NPCs, mobs, combate ou Ato III.

Trabalhe na branch `ccr-bb54cda9-tvw178`.

Leia obrigatoriamente:
- `CLAUDE.md`
- `docs/planning/REVISAO_VISUAL_PRE_OPUS_2026-09-29.md`
- `docs/planning/OPUS_NEXT_VISUAL_PASS_v1.md`
- `docs/relatorios/APROVACAO_VISUAL_LOTE_ESTRUTURAL_OPUS_2026-09-29.md`
- `docs/relatorios/LIMPEZA_ASSETS_SUBSTITUIDOS_2026-09-29.md`
- `.claude/skills/valedouro-asset-quality/SKILL.md`
- `.claude/skills/valedouro-map-logic/SKILL.md`

## Regra máxima

Os 238 assets estruturais já aprovados pelo Diretor são base congelada. NÃO voltar aos módulos antigos removidos do catálogo. NÃO recriar parede frontal solta, janela solta, telhado solto, peça flutuante, muro sem ângulo ou construção montada como colagem.

O problema restante não é apenas detalhe fino. É COMPOSIÇÃO ESPACIAL + INTEGRAÇÃO.

## Evidência visual que você deve usar

Revise as capturas reais do Godot, especialmente:

- `docs/visual_qa/story/estrutural_catA/A01_01_portao_visao_geral.jpg`
- `docs/visual_qa/story/act02/FLO_2A_PONTE_DEPOIS.jpg`
- `docs/visual_qa/story/act02/FLO_2A_CASA_POS.jpg`
- `docs/visual_qa/story/act02/FLO_2C_ARVORE_ABERTA.jpg`
- `docs/visual_qa/story/act02/FLO_2C_CORACAO_MEMORIA_ATIVA.jpg`
- `docs/visual_qa/story/act02/FLO_2D_ARENA_PRE_BOSS.jpg`
- `docs/visual_qa/story/act02/FLO_2E_CARTOGRAFOS_SELO_ATIVO.jpg`
- `docs/visual_qa/story/act01/A01_09_ruinas_visao.jpg`
- `docs/visual_qa/story/act01/A01_15_mina_interior_zona1.jpg`
- `docs/visual_qa/story/act01/A01_17_nucleo_arena.jpg`

## Diagnóstico obrigatório a corrigir

### 1. Ponte de Pedra
Hoje ainda lê como:
- rio quase vertical com largura constante;
- estrada quase horizontal/cartesiana;
- ponte como laje retangular larga;
- cabeceiras pouco fundidas ao terreno.

Refaça a composição sem perder a função narrativa:
- rio sinuoso e largura variável;
- margens orgânicas;
- pedras parcialmente submersas;
- corrente/espuma visual leve;
- ponte com espessura, arco/apoio e sombra de contato;
- cabeceiras encaixadas no solo;
- estrada chegando em curva;
- vegetação de margem e erosão;
- sem objetos aparentemente pousados sobre a ponte.

### 2. Posto dos Guardas Verdes
Hoje o prédio e a torre ainda leem frontais/planos e a estrada forma cruzamentos artificiais.

Refazer o conjunto como UMA instalação coerente:
- edifício principal completo em 3/4;
- telhado assentado e volumétrico;
- varanda/passarela se fizer sentido;
- torre de vigia com profundidade real;
- cerca multiângulo preservada, mas fundida à vegetação;
- anexos funcionais;
- fogueira, estoque, sinalização e mobiliário com grounding;
- caminhos de chegada irregulares;
- terreno modificado pela ocupação;
- identidade própria dos Guardas Verdes.

### 3. Árvore-Memória exterior
Preservar o conceito, mas remover:
- entrada como buraco preto recortado;
- lago/base circular plana;
- caminhos em T/90°;
- leitura de árvore comum ampliada.

Criar escala sagrada:
- tronco e raízes com volume;
- cavidade com profundidade interna;
- raízes invadindo solo e água;
- base natural, não um disco;
- pedras, vegetação antiga e partículas leves;
- trilhas convergentes orgânicas;
- composição que deixe claro que é um landmark único.

### 4. Coração da Árvore-Memória
Hoje ainda lê como:
- círculo verde perfeito;
- raios radiais geométricos;
- parede montada por segmentos repetidos;
- centro colocado sobre um disco;
- vazio preto sem profundidade.

Transformar em câmara orgânica:
- piso feito de raiz/madeira viva irregular;
- múltiplas alturas;
- parede interna com cavidades, fibras, seiva, raízes e reentrâncias;
- iluminação localizada;
- centro integrado à anatomia da árvore;
- bordas físicas no lugar de vazio preto;
- assimetria controlada.

### 5. Raiz Oca
O kit angular melhorou, mas o recinto ainda denuncia módulos e um círculo ritual perfeito.

Corrigir:
- segunda camada de raízes;
- parede/piso conectados;
- arena irregular;
- centro corrompido fundido ao solo;
- profundidade e silhueta orgânica;
- reduzir repetição visível dos segmentos;
- manter leitura clara para combate mobile.

### 6. Santuário dos Cartógrafos
Hoje ainda lê como peças isoladas sobre gramado:
- quatro direções cartesianas;
- placas/pilares sem fundação;
- disco central;
- sombras longas e elementos sem arquitetura unificadora.

Reconstruir como sítio antigo coerente:
- fundação/plataforma quebrada;
- ruína parcial assimétrica;
- mapa/selo integrado;
- pedras conectadas;
- níveis de piso;
- vegetação invadindo;
- caminho principal e acessos secundários orgânicos;
- backdrop para profundidade;
- nada flutuando.

### 7. Mina do Eco — prioridade máxima junto com Floresta
As capturas atuais ainda têm a leitura mais forte de protótipo:
- piso repetido em padrão de tabuleiro;
- círculo rúnico perfeito e enorme;
- paredes idênticas repetidas;
- salas quase retangulares;
- pouco relevo;
- pouca transição entre caverna e estrutura de mina.

Refazer sem quebrar gameplay:
- piso irregular com zonas;
- trilhos, poeira, minério, rachaduras e desgaste;
- rocha irregular;
- pilares e suportes;
- nichos/recessos;
- transição madeira/pedra/caverna;
- arena do Núcleo integrada ao solo;
- runas incorporadas à geologia/estrutura, não um decalque circular gigante;
- luz falsa/localizada e partículas baratas;
- manter navegação, colisões e boss room legíveis no mobile.

### 8. Ruínas do Primeiro Vento
Recapturar após as correções estruturais e revisar:
- nenhum fragmento deve parecer janela, parede ou telhado solto;
- criar fundações e lógica de desabamento;
- integrar mecanismo central ao sítio;
- pedras/raízes/vegetação devem amarrar a composição;
- preservar conexão narrativa do Primeiro Viajante.

### 9. Valedouro
PRESERVAR. É a referência de maturidade atual.

Apenas:
- integrar melhor o portão norte/gatehouse;
- revisar sombra de contato;
- quebrar repetição de casas com anexos/props/vegetação sem substituir as famílias aprovadas;
- corrigir clipping.

## Caminhos, água e terreno — regra global

Não aceitar:
- cruzamentos em T perfeitos;
- estradas em eixos 90°;
- rios de largura constante;
- círculos perfeitos como solução para qualquer POI;
- plataformas sem fundação;
- props sem sombra/contato;
- estruturas “pousadas” no terreno.

Usar:
- largura variável;
- erosão;
- vegetação invadindo borda;
- raízes;
- pedras;
- pequenas ramificações;
- transições de material;
- composição por função e história.

## Restrição mobile

Alvo: 60 FPS Android.

Antes de simplificar arte:
- culling/chunks;
- pooling;
- fake lighting;
- partículas limitadas;
- LOD visual/AI distante;
- atlas e batching quando possível.

Não aumentar custo por pixel sem medir.

## Processo obrigatório por partes

Não tente fazer tudo em uma sessão gigante.

### Parte A — auditoria e recaptura
Recapture o estado atual e confirme o baseline.

### Parte B — terreno, caminhos e água
Corrija a linguagem espacial do Ato II.

### Parte C — Ponte + Posto dos Guardas
Finalize e recapture.

### Parte D — Santuários + Árvore-Memória exterior
Finalize e recapture.

### Parte E — Coração + Raiz Oca + Cartógrafos
Finalize e recapture.

### Parte F — Mina do Eco
Finalize e recapture.

### Parte G — Valedouro polish + Ruínas do Primeiro Vento
Somente polish e integração.

### Parte H — QA final
Executar Godot 4.7.2 real, testes existentes, auditorias, capturas e relatório.

Após CADA parte:
1. commit;
2. capturas reais;
3. relatório curto;
4. pare e informe o que foi concluído antes de seguir, para evitar sessão longa.

## Gate final

Não declarar o passe encerrado até demonstrar por capturas reais:
- zero módulos arquitetônicos flutuando;
- zero janela/telhado/parede solta;
- zero regressão para módulos frontais;
- zero círculo gigante usado como solução visual óbvia;
- zero estrada/curso d'água artificialmente cartesiano nos POIs principais;
- Mina sem piso-tabuleiro;
- Floresta com densidade e estratificação;
- construções e landmarks fundidos ao terreno;
- Valedouro preservado;
- parser/runtime sem erro;
- testes existentes aprovados;
- auditoria de referências aprovada.

NÃO iniciar personagens nesta tarefa. A Etapa 2 já está sendo preparada separadamente e só começa após o Diretor fechar este gate visual.
