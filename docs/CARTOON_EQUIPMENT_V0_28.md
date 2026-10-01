# Candidata v0.28 — itens, conjuntos completos e arco

Pedido do Diretor: sistema de itens, criação de armas/armaduras com conjunto
completo, troca para arco e refinamento do herói e suas animações.

## Implementação

- 64 receitas nas oito regiões: espada, arco, peitoral, elmo, luvas, calças,
  botas e capa por região. Os 16 IDs de receitas anteriores permanecem iguais.
- Bolsa com sete posições, filtro de todas as armaduras, comparação com a
  peça da mesma posição e indicador do conjunto. A coleção comporta as
  64 peças fabricáveis e os dois equipamentos iniciais (66 itens únicos).
- Seis peças do mesmo conjunto ativam bônus de ATQ e DEF de `tier + 2`.
  Misturar peças desativa o bônus completo; a defesa de cada peça continua.
- Forja com receitas roláveis, custo/estoque explícitos e botões de criar ou
  equipar. Peças já fabricadas não gastam materiais novamente. A compra de
  uma unidade do material do peitoral por 10 de ouro permite completar os
  conjuntos mesmo após consumir as recompensas únicas de exploração.
  Em Valedouro, ossos para armas continuam disponíveis na caça renovável.
- Arco selecionável pela bolsa ou pela forja; funciona nas oito regiões e na
  caça. Alcance 300 (+ talento Alcance), intervalo 0,65 s, flechas a 560 u/s,
  até 24 projéteis. Flechas ilimitadas nesta candidata; não há consumo de
  munição escondido. Materiais são consumidos ao criar o arco.
- Flecha guarda o dano do disparo; trocar arma durante o voo não o altera.
  Dano ocorre no impacto pelo caminho canônico da região, respeitando as
  travas de história, morte, recompensas, construções e painéis abertos.
- 32 spritesheets Cartoon originais, 240 quadros em quatro direções: repouso,
  caminhada, ataque, magia, ferimento, queda, disparo e esquiva. Novos detalhes
  de rosto, cabelo, costura, bordados, metais, capa traseira e aljava. As peças
  equipadas acrescentam elementos visíveis, e o arco acompanha a direção.
- Save versão 5: preserva IDs antigos, história, materiais, classes, talentos,
  campanha e equipamentos; adiciona as cinco posições extras persistentes.

## Validação e limites

28 testes da campanha Cartoon passaram no Godot 4.6.3 local. O teste novo
verifica receitas únicas, custos, fabricação idempotente, bônus completo,
mistura de conjuntos, migração/persistência, compra sem ouro e sincronização
com a região, alcance, troca para espada, voo, pausa por painel, dano guardado,
construções e proteção da história no impacto.

Capturas e GIFs foram feitos pelo Godot em execução, incluindo bolsa/forja
em 640×360 e herói em quatro direções. Revisão:
[visual_qa/cartoon_v028/review.html](visual_qa/cartoon_v028/review.html).
A CI acrescenta o teste e as capturas no engine oficial Godot 4.7.2.

Arte: **MODELED_PENDING_GATE**. Novas regras de conjunto/economia:
**PROPOSED**, candidatas à avaliação do Diretor. Aprovação visual e medição
em aparelho Android físico continuam pendentes. Nenhum APK é gerado nesta
atualização; exportação Android somente mediante pedido explícito.
