# Fidelidade às referências visuais — regra do Diretor

Em 02/10/2026, o Diretor considerou bonitas as imagens apresentadas e pediu que
o jogo seja fiel a elas: conferir sempre a referência e refinar as diferenças
antes de entregar. A aprovação é da direção visual das referências; não é
aprovação automática de todos os elementos do jogo.

## Referências que devem acompanhar o trabalho

- Natureza: `game/assets/cartoon/v041/foliage.png`.
- Moradores: `game/assets/cartoon/v041/people.png`.
- Criaturas: `game/assets/cartoon/v041/creatures.png`.
- Grama e pedra: `game/assets/cartoon/v041/grass.png` e `stone.png`.
- Construções: `game/assets/cartoon/v040/buildings.png`.
- Composição real da área piloto: `docs/visual_qa/cartoon_v041/plaza.png`,
  `street.png`, `north_exit.png`, `west_edge.png` e `fields.png`.
- Recortes, âncoras e SHA256: manifestos `art.json` (v041) e
  `buildings.json` (v040).

Originais fixados por SHA256 em
`docs/visual_qa/cartoon_v041/reference_lock.json`. Não sobrescrever essas
referências ao fazer um passe novo; criar assets em uma versão nova e manter
os originais disponíveis para comparação. Trocar a direção visual exige
uma nova instrução do Diretor.

[Comparador de referência e render](visual_qa/cartoon_v041/reference_review.html).
As capturas de praça, floresta e campos são renders reais do Godot. Os atlas
originais são usados diretamente no jogo, sem reinterpretação em formas
simplificadas. A galeria deve ser inspecionada também na escala do mapa.

## Critério para considerar uma etapa concluída

1. Abrir a referência e capturar o elemento na cena real, com HUD, câmera,
   iluminação, sobreposição e escala de uso. Conferir também em 960×540 e
   640×360, e nos extremos de zoom suportados.
2. Comparar silhueta, proporções, perspectiva, paleta, textura e detalhes.
   Conferir recortes/transparência, sombras, apoio dos pés/fundações, ordem
   por Y e tamanho relativo entre herói, criaturas, moradores e construções.
3. Conferir poses de movimento e ação no jogo. Uma imagem estática bonita
   não aprova animações que mudem rosto, figurino, tamanho ou posição dos pés.
4. Registrar diferenças observadas e corrigi-las na integração ou nos assets;
   repetir captura e comparação depois das correções. Otimizações não podem
   trocar a arte por desenhos simplificados nem remover os detalhes que
   definem a referência. Se houver um limite técnico concreto, registrá-lo
   como pendência, sem declarar fidelidade completa.
5. Executar os testes pertinentes e verificar o pacote exportado. PASS técnico,
   identidade de arquivo ou checksum não substituem a revisão visual dentro
   do jogo; tamanho reduzido, filtro, compressão e iluminação podem alterar
   a aparência mesmo usando o arquivo correto.
6. Mostrar capturas reais do resultado e manter o registro no GitHub. Desativar
   a tarefa de refinamento somente depois de verificar também estes critérios.

Fidelidade exige o mesmo desenho e sua linguagem visual, sem exigir igualdade
pixel a pixel entre um atlas ampliado e uma cena com escala, animação e
iluminação. Não prometer correspondência verificada em Android sem executar
uma verificação no dispositivo ou numa build Android.

## Conferência realizada em 02/10/2026

A partir da v0.41 (`b0a34a1`, Godot Gate oficial `36953786483`), foram abertos
lado a lado o atlas de criaturas, sua galeria renderizada e a cena dos
arredores a oeste. O código utiliza os originais PNG em AtlasTexture, com
âncoras por pose. O gate existente verifica checksums, limites dos recortes,
compressão, apoio no chão e orçamento de desenho. As capturas oficiais do
Godot 4.7.2 confirmam árvores e criaturas integradas com a referência.

Pendências visuais conhecidas para a tarefa de retomada:

- Herói ainda usa a apresentação anterior, com menos detalhe que a nova
  família ilustrada; refinar mantendo identidade, classes e equipamentos.
- A mobília e parte da decoração dos interiores ainda usam a linguagem
  anterior; refinar para acompanhar construções e moradores.
- Esses pontos não estão aprovados como resultado visual final apenas porque
  a v0.41 passou nos testes. As outras regiões exigem revisão própria quando
  receberem novos assets; não afirmar fidelidade do jogo inteiro pelo piloto.

Nenhum APK foi solicitado neste pedido. Preservar HUD radial opção 3, história,
missões, dificuldade, save v8 e magias com recargas independentes.

## Comparação executada no passe v0.42

Veja `CARTOON_ILLUSTRATED_V0_42.md` para as diferenças e correções concretas e
`visual_qa/cartoon_v042/review.html` para originais, capturas e sequências reais.
Pessoas/vegetação v0.41 e construções v0.40 permanecem bloqueadas por SHA256.
Verificados corpo, rosto, capa, placas, perspectiva de arco, foco na palma,
cor dos núcleos das magias, sombras, pés, móveis completos e paredes próprias
das três salas, em 960×540/640×360 e zoom70/150. PASS técnico não foi usado como
substituto para essa inspeção; gate oficial e suas capturas ainda pendentes no
checkpoint inicial. Aprovação do Diretor não é presumida.
