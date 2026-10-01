# v0.39 — herói e casas apoiados no chão

Solicitação: corrigir o herói e algumas casas que pareciam flutuar.

O herói aplicava elevação vertical sobre uma animação que já elevava o corpo,
e sua sombra ficava nove unidades abaixo do ponto de apoio. O desenho agora
usa a sola da bota como origem: compensa a elevação interna de cada quadro,
mantém uma bota plantada na caminhada e usa uma sombra de contato curta no
chão. As poses, a esquiva, armas e equipamentos continuam animados. A pose de
queda conserva sua rotação original e não faz parte do teste de poses em pé.

As casas e os serviços da cidade usavam a borda da imagem como apoio. Agora o
vértice da fundação do SVG corresponde à origem do objeto e à ordenação por Y.
Uma sombra curta acompanha a aresta inferior da fundação. Aplica-se às três
variantes de casa, ferreiro, taverna, guilda, alquimista e arquivo. As posições
no mapa, os bloqueios e as entradas continuam iguais.

`qa_capture_grounding_v039.gd` renderiza 208 quadros em quatro direções, sem
sombra, e verifica que o último pixel opaco está no nível do chão, com tolerância
de dois pixels de antialiasing. Também verifica o apoio da fundação e gera seis
capturas reais do herói parado/caminhando, casas da cidade e casa da fazenda.
Teste local aprovado no Godot 4.6.3; CI repete a verificação no Godot 4.7.2, além
dos 57 testes anteriores. Revisão: `visual_qa/cartoon_v039/review.html`.

Nenhum APK solicitado nesta correção. Preset e workflow preparados para a
próxima v0.39, exportada apenas quando o Diretor pedir. Save permanece v8.
