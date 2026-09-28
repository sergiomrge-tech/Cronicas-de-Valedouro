# Crônicas de Valedouro — planejamento completo v2

**Documento de produção • 27/09/2026 (horário de Brasília)**  
**Plataforma:** Android, celular primeiro; PC como plataforma de teste.  
**Engine:** Godot 4.x/GDScript.  
**Orientação visual:** horizontal, câmera 2D exatamente de cima, pixel art de fantasia rica em vegetação e detalhes.  
**Escopo deste documento:** visão do jogo completo, regras de progressão e ordem de construção. A presença de um recurso aqui não significa que ele já esteja pronto no projeto.

## 1. Visão do jogo

O jogador chega como aventureiro novato a **Valedouro**, uma cidade construída na fronteira de florestas, campos, ruínas, desertos e montanhas geladas. Ele aceita contratos na guilda, explora livremente o mundo, enfrenta criaturas, coleta recursos, retorna para melhorar seus equipamentos e sobe de posição entre os exploradores. Uma capacidade rara, chamada **Cartografia dos Ecos**, permite interpretar lembranças deixadas nos lugares e desvendar quem está alterando as rotas das masmorras.

A sensação narrativa buscada em *Solo Leveling* é a ascensão marcante de alguém inicialmente subestimado: missões aparentemente simples se tornam perigosas; preparação, luta, sobrevivência e vitórias difíceis mudam como o mundo reage ao protagonista. A história, os poderes, os personagens, a estrutura da guilda e as cenas de Valedouro são originais. O crescimento depende de exploração, companheiros, equipamento e escolhas; não há cópia de caçadores, sistema sobrenatural exclusivo ou exército de sombras.

**Pilares de experiência**

1. **Um mundo percorrido de verdade:** sair da trilha, encontrar animais, ruínas, riachos e atalhos; obstáculos físicos claros, sem corredores invisíveis.
2. **Força conquistada no ritmo da campanha:** equipamento poderoso só surge de inimigos, regiões e missões adequados ao momento da história.
3. **Mudança visível no herói:** uma espada, arco, armadura, capa ou efeito mágico novo aparece no personagem e altera como ele luta.
4. **Retorno à cidade com propósito:** entregar contratos, vender achados, fabricar poções, forjar, guardar materiais e ouvir novos diálogos.
5. **Fantasia anime com cenário pixel art:** cenas e retratos anime nos momentos importantes, mundo detalhado em perspectiva 2D de cima.

## 2. Direção visual aprovada

A referência principal para o exterior é a imagem da **floresta iluminada, com copas densas, troncos, sombras no chão, clareiras floridas e caminhos de areia clara** enviada pelo usuário. A referência de interior é a **sala do ferreiro vista de cima, com tábuas, armaduras, espadas, escudos e bancadas cheias de objetos**. Foram produzidas novas artes originais de floresta, cidade e ferreiro seguindo essa direção; elas definem o patamar visual para toda nova cena. A composição de referência não deve ser copiada literalmente.

- Gramados com microvariação de verde, manchas naturais, raízes, pedras e flores. Árvores com copa em camadas, tronco reconhecível e sombra coerente. Caminhos irregulares de areia, terra e paralelepípedos.
- Interior da forja com piso de madeira marcado, armaduras em suportes, variedade real de armas, ferramenta sobre bancada e luz quente da fornalha. Guilda, loja, alquimia e estalagem exigem o mesmo nível de cuidado; paredes e objetos não podem parecer retângulos provisórios.
- Protagonista de silhueta anime adaptada a sprite pixel art. O tamanho da figura deve combinar com portas e árvores; a escala visual não muda arbitrariamente ao trocar de cena. O equipamento aparece no mesmo ângulo e acompanha cada quadro da animação.
- Cores por região: cidade acolhedora em madeira, pedra e verde; floresta verde vibrante e creme; campos dourado e verde claro; deserto âmbar e areia; gelo branco azulado com sombras ciano; ruínas em pedra azul/violeta.
- Interface compacta e legível em celular horizontal: vida/recursos em cima, minimapa opcional, joystick à esquerda e ações à direita. Evitar cobrir o personagem ou a porta com caixas gigantes. Texto em PT-BR, escala ajustável.
- **Portão de fidelidade visual:** capturar a execução real do Godot para cidade, floresta e ferreiro. Comparar câmera, densidade, texturas, escala do herói, sombras e leitura dos objetos com as duas referências aprovadas. Refazer a arte até que o resultado tenha o mesmo nível de detalhamento e coerência. Uma arte isolada ou mockup não prova como a cena ficou no jogo.

### Pacotes de assets a produzir

| Pacote | Conteúdo mínimo | Validação |
|---|---|---|
| Terrenos | Gramado, floresta, areia, gelo, pedra, madeira, água, margens, pontes, elevações e transições orgânicas. | Sem costura óbvia, repetição excessiva ou colisão invisível. |
| Natureza | Árvores de espécies e tamanhos diferentes, arbustos, flores, plantas altas, raízes, rochas, cristais, água e espuma da cachoeira. | Sombra no solo; objetos não obscurecem entradas nem HUD. |
| Arquitetura | Cidade principal, guilda, ferreiro, alquimia, loja, estalagem, casa comum, vila dos campos, postos de deserto e gelo. | Cada porta reconhecível; interiores compatíveis com o exterior. |
| Herói | Base com andar, repouso, ataque, dano, esquiva, arco e conjuração; camadas de cabelo, torso, ombros, arma, escudo, capa e magia. | Equipamentos sincronizados em todas as direções e animações. |
| Criaturas | Mobs de cada bioma, elites e chefes com ataques e telegráficos próprios; fauna pacífica separada. | Escala e qualidade compatíveis com cenário; movimentação não parece deslizar. |
| Itens e efeitos | Ícones de espada, arco, cajado, armaduras, poções e materiais; projéteis, cortes, impactos, aura e coleta. | Ícone, sprite equipado e efeito compartilham forma/paleta. |

**Convenção das folhas de animação:** 8 direções para o herói quando a leitura exigir, com 6–8 quadros de caminhada e 6–10 de ataque por direção; sprites de equipamento seguem a mesma matriz e o mesmo ponto de ancoragem. Os inimigos comuns recebem marcha, ataque, dano e morte distintos. Chefes recebem animações maiores e fases reconhecíveis. A quantidade de quadros será determinada pelo movimento e validada em velocidade real; não inflar folhas com quadros duplicados.

## 3. Geografia e exploração livre

O primeiro grande mapa integra **Valedouro, Bosque do Primeiro Vento, Campos de Lírio, rio e Cascata da Aurora, Dunas de Âmbar e Picos de Gelo**. Há caminhos como orientação e para viagem rápida depois de descobertos, mas o personagem anda pelos gramados, clareiras e áreas abertas. Água funda, troncos, paredes, rochas, penhascos e construções possuem colisão visualmente coerente; flores, grama baixa e objetos decorativos deixam passar. Pontes e passagens ligam margens. Não haverá barreiras artificiais apenas para obrigar o jogador a seguir a estrada.

| Área | Encontros e atmosfera | Função na campanha |
|---|---|---|
| Valedouro | NPCs, aves, mercado, fonte e oficinas. Zona segura. | Guilda, preparação, comércio, armazenamento e consequências da história. |
| Bosque e clareiras | Lobos, pequenos limos, veados, raposas, lebres, riachos e plantas. | Tutorial, caçada de Cobre/Bronze e primeiras pistas dos Ecos. |
| Campos de Lírio | Plantas, fauna e monstros dispersos com espaços amplos. | Coleta, contratos e acesso à vila agrícola. |
| Rio e cascata | Peixes, corredeiras, espuma, rochas, ponte e margens transitáveis. | Navegação, pistas e travessia entre zonas. |
| Dunas de Âmbar | Cactos, ruínas expostas, camelos pacíficos e inimigos de areia. | Aventura posterior, materiais próprios e equipamentos intermediários. |
| Picos de Gelo | Neve, coníferas geladas, cabras, cavernas e inimigos resistentes. | Região avançada e materiais da campanha tardia. |
| Masmorras | Salas conectadas, armadilhas, atalhos, tesouro e chefe. | Picos narrativos, provas da guilda e recompensas específicas. |

A fauna pacífica passeia, descansa e foge de perigo; não existe para ser tratada como mob de XP. Inimigos aparecem em seus habitats, com limite de quantidade por tela, zonas de patrulha, telegráfico e possibilidade de evitar alguns combates. A cidade tem área segura visível. O mapa registra regiões descobertas, pontes, entradas, missão ativa e nível recomendado; os segredos continuam sem marcador automático.

## 4. Estrutura de campanha

O personagem começa como aprendiz pouco reconhecido. Seu dom de **ler Ecos** aparece quando ele encontra marcas de uma expedição apagada dos arquivos. Os Ecos mostram trajetos, avisos e fragmentos de memória; o jogador precisa investigar, não recebe automaticamente uma lista de respostas.

| Capítulo | Níveis sugeridos | Eventos, missões e clímax | Transformação do mundo |
|---|---:|---|---|
| I — O contrato de Cobre | 1–8 | Conhecer Liora, aceitar caça de lobos, coletar ervas para Elara, resgatar batedor, encontrar Eco no bosque e vencer o Alfa da Matilha. | Abre primeira técnica de cartografia; Borin oferece forja; guilda concede Bronze. |
| II — A mina que recorda | 8–16 | Desaparecimentos na Mina do Eco, preparação, escolta de Kael, exploração em equipe, ruína reconfigurável e Guardião de Pedra. | Cidade comenta o feito; primeiras alterações nos mapas oficiais aparecem. |
| III — As lanternas se apagam | 16–27 | Pântano e estrada das dunas, antídoto, caravana, expedição perdida, decisão de resgate e Dama dos Juncos. | Moradores resgatados passam a circular na cidade; patente Prata. |
| IV — A expedição sem nome | 27–38 | Montanhas geladas, minério rúnico, registros omitidos, cerco a Valedouro e confronto com o capitão desaparecido. | Praça, portões e diálogos mudam; verdade sobre o Cartógrafo Vazio. |
| V — O último mapa | 38–50 | Reunir aliados, estabilizar âncoras, atravessar Torre da Aurora, recuperar parte das memórias e encerrar a crise. | Final completo com opção de operação de resgate se o jogador preparou aliados. |

Liora (guilda), Borin (ferreiro), Elara (alquimista), Kael (batedor) e Maelis (arquivista) têm cenas curtas e missões encadeadas. O antagonista, Cartógrafo Vazio, altera caminhos para tentar recuperar pessoas presas entre mundos. Decisões alteram quem ajuda no final e a vida cotidiana da cidade, sem bloquear o término da campanha por uma escolha de diálogo obscura.

**Estrutura de missão:** objetivo, localização, nível sugerido, quantidade, recompensa e consequência aparecem antes da aceitação; o diário acompanha contadores a partir daquele momento. Missões principais não dependem de item aleatório raro. Contratos repetíveis ajudam no treino, mas não substituem a história.

## 5. Combate e papéis de equipamento

Começar com espadachim bem feito; ampliar para arqueiro, arcanista e guardião depois de movimento, colisão, telegráficos e salvamento estarem estáveis. Ataque básico, até três habilidades ativas, esquiva com recarga, poção e interação têm botões distintos. Espada é curta e frontal; arco dispara projétil com alcance e linha de visão; cajado lança magia que consome mana e deixa efeito diferente; armadura altera defesa e agilidade. Inimigos têm detecção, patrulha, aproximação, ataque anunciado, recuo, dano e morte. Chefes possuem fases e resposta à posição do jogador.

A dificuldade cresce com legibilidade: criaturas mais fortes apresentam novas ações além de só aumentar HP. Dano considera arma, nível, habilidade, defesa e resistência. Valores são limitados para impedir que uma combinação elimine um chefe antes de mostrar sua mecânica. O jogador pode derrotar criatura forte com preparo e habilidade, mas uma região posterior não será a maneira mais rápida de obter poder no início.

## 6. Loot cadenciado, materiais e economia

**Objetivo de ritmo:** nos primeiros contratos, o ganho principal é XP, ouro, materiais e aprendizado. Equipamento completo não deve cair em meia hora de combate. Uma melhoria relevante acontece depois de esforço reconhecível, e trocar de região muda a faixa de poder disponível.

### Tabela inicial de balanceamento — sujeita a playtest

| Fonte | Materiais | Equipamento comum/incomum | Raro ou acima |
|---|---:|---:|---:|
| Mob comum de bosque/campos | 25–45% | 1–2% | 0% até o capítulo II. |
| Mob comum de deserto/gelo | 30–50% | 2–3% do tier local | até 0,5%, apenas com capítulo e nível exigidos. |
| Elite | material específico garantido | 4–7% | 1–2%, respeitando progressão. |
| Chefe de capítulo | material ou fragmento garantido | recompensa de história garantida, predefinida | sorteio pequeno adicional, nunca necessário à campanha. |

As chances são por criatura derrotada, verificadas em simulação antes do balanceamento final. **Não há punição por azar na missão principal:** a recompensa narrativa garantida dá o poder mínimo para a próxima etapa. A raridade alta é surpresa, não requisito. Sem caixas pagas, compras de poder ou anúncios para conseguir drop.

**Tiers por história:** I Bosque (níveis 1–8, Cobre/Bronze), II Mina (8–16), III Dunas/Pântano (16–27), IV Gelo (27–38), V Torre (38–50). Cada item tem tier de origem, nível exigido, categoria, atributos e aparência. Um mob inicial continua oferecendo tier inicial, mesmo se o jogador retornar no capítulo V. Um mob avançado pode ser enfrentado cedo, mas seu item exige o avanço narrativo e nível apropriados para equipar; acesso a materiais de forja superiores também depende da região e da história.

**Inventário separado:** equipamentos com 30 espaços iniciais, pilha de materiais por tipo, consumíveis em outra seção e baú na cidade. A tela mostra silhueta do herói, slots (arma, cabeça, peito, mãos, botas, acessório e capa visual), item equipado ao lado do item selecionado, dano/defesa, requisito, raridade, origem e ação equipar/guardar/vender. Lista tem filtros, paginação e tamanho de toque adequado. O primeiro item é preservado automaticamente; vender raro/lendário exige confirmação.

**Materiais e ofícios:** couro de lobo, núcleos de limo, ervas, minério, escamas de deserto e cristais de gelo têm finalidade concreta em receitas. Borin forja, repara e melhora equipamento dentro do teto do capítulo; Elara fabrica poções e antídotos. Custos são apresentados antes de gastar. O ouro médio dos contratos cobre suprimentos e ao menos uma melhoria antes do chefe seguinte. Ferreiro não permite subir indefinidamente apenas repetindo inimigos fracos.

## 7. Equipamento aparece no personagem

O herói é composto por camadas sincronizadas: corpo e cabelo → roupa base → peitoral/ombros → luvas/botas → arma/escudo/arco/cajado → capa → efeito de habilidade. O mesmo `item_id` referencia dados, ícone, sprite equipado, animação, projétil e material de melhoria. Ao equipar, a cena atualiza o sprite imediatamente; ao salvar e reabrir, mantém a aparência.

**Primeiro lote de conjuntos para validar a tecnologia:** roupa de aprendiz, gibão de couro do Bosque, armadura de ferro da Mina, vestimenta das Dunas, armadura rúnica de Gelo; espada de treino, espada reforçada, arco de caça, arco rúnico, cajado de Ecos e efeito de magia correspondente. Todos terão ícone no inventário e versão animada no personagem. Só ampliar para dezenas de itens depois que a primeira troca funcione em repouso, caminhada, ataque, dano e nas direções visíveis.

O sistema nunca substitui a arma do herói por texto de status sem alterar o desenho. Itens cosméticos podem manter visual anterior por escolha do jogador, mas o padrão é mostrar o equipamento atual.

## 8. Interface e fluxo no celular

Abrir → Continuar/Novo jogo → cidade → guilda → escolher missão → preparar-se → explorar livremente → combater/coletar → voltar → entregar → equipar/forjar → novo destino. Movimento por joystick móvel; botões grandes de ataque, habilidade, esquiva, poção e interação. Câmera mantém o herói visível e não esconde inimigo prestes a atacar sob o HUD. Inventário, diário, mapa e menu de pausa abrem sem perder um toque de combate. Fonte escalável, contraste, vibração opcional, apoio a controle físico e pausa ao trocar de aplicativo. Novo jogo não apaga o save ativo sem confirmação.

## 9. Implementação Godot

**Cenas:** `WorldMap`, `TownInterior`, `Dungeon`, `Player`, `Monster`, `Wildlife`, `LootPickup` e camadas UI. **Sistemas:** `GameState`, `SaveManager`, `QuestManager`, `Inventory`, `EquipmentRenderer`, `LootTable`, `Crafting`, `Combat`, `EnemyAI`, `Dialogue`, `Audio`. `WorldMap` decide bioma, travessia e objetos; `EquipmentRenderer` mantém quadros e âncoras das camadas; `LootTable` recebe espécie, elite/chefe, capítulo e nível antes de sortear.

Mapas maiores carregam/cortam apenas células próximas da câmera; objetos repetidos e partículas usam pooling. Fauna distante atualiza menos vezes. A colisão usa a base do obstáculo visível, com largura menor que a copa da árvore para deixar o herói passar por clareiras. Saves versionados preservam quest, inventário, equipamentos, atributos, regiões abertas e posição segura; versões antigas migram para a praça sem perder progresso.

**Alvo de desempenho:** física 60 Hz, alvo 60 FPS em Android intermediário; perfis de partículas, luz e resolução ajustáveis. Medir FPS e memória no telefone do usuário após a construção de cada bioma relevante. Exportação Web pode servir a demonstrações, mas Android APK é o teste principal e AAB fica para publicação. A compilação por si só não prova legibilidade ou desempenho touch.

## 10. Entregas e critérios objetivos

| Marco | Entrega concreta | Condição para avançar |
|---|---|---|
| A — Referência fiel | Cenas originais de cidade, floresta e ferreiro com herói e UI nas proporções da referência. | Captura **real do Godot** comparada às referências; portas, sombras, cenário e avatar convincentes. |
| B — Mundo livre | Biomas navegáveis, rio/cachoeira, ponte, assentamentos, animais e monstros regionais. | Pode caminhar fora da trilha; água, rocha, tronco e edifícios bloqueiam onde a arte indica; todas as áreas acessíveis. |
| C — Equipamento e loot | Inventário, material, chances por tier, requisitos, quatro tipos de arma/armadura e camadas visuais. | Drop raro, material comum; equipar muda sprite em movimento e ataque; save mantém tudo. |
| D — Combate completo | Espada, arco, magia, esquiva, IA, elites, chefes com telegráfico e efeitos. | Vitória/derrota, colisão, hitbox e poções testados no touch; sem poder excessivo no início. |
| E — Campanha | Cinco capítulos, guilda, NPCs, regiões, decisões, diálogos e dungeons. | Jogo concluível do primeiro contrato ao final, com recompensas e progressão corretas. |
| F — Android e polimento | Retratos, áudio, controles, acessibilidade, desempenho, backups, APK de teste e AAB. | Instala, abre, mantém save entre atualizações e atinge metas medidas em aparelho real. |

### Verificações obrigatórias em cada pacote

- Importação do projeto e execução da cena principal no Godot sem erro de script ou função nativa conflitante.
- Testes automatizados de rota do mapa, entrada/saída, guilda, combate, loot, requisitos e migração de save pertinentes à alteração.
- Para mudança visual: captura real de cidade, floresta, ferreiro e bioma alterado, seguida de comparação com a direção aprovada. Não apresentar arte conceitual como print da execução.
- Inspeção de toques, escala, estabilidade e FPS em Android real antes de chamar uma versão de pronta para celular.
- Varredura do ZIP por referências ausentes, caches, arquivos temporários e integridade CRC antes de entregar.

## 11. Estado e próxima decisão de produção

O protótipo anterior já continha cidade, guilda, bosque, ruínas, lojas, combate inicial e save. O mapa ampliado e novas artes originais foram iniciados, mas **esta revisão de planejamento não atesta que todos os sistemas acima estejam implementados ou capturados no Android**. A prioridade é terminar o marco A no Godot, caminhar livremente no marco B e então adicionar loot/equipamentos visíveis no marco C. Nenhum drop de tier alto ou novas missões deve ser incluído sem as regras de cadência e requisitos acima.
