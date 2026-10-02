# Pesquisa de skill — mapas procedurais 2D no Godot

Pedido do Diretor em 02/10/2026: encontrar uma skill para geração de mapas
procedurais com distâncias controladas entre vegetação, construções, pedras,
animais e monstros, além de água, rios e montanhas.

## Recomendada: godot-procedural-generation

Fonte primária, versão lida e revisada:
[SKILL.md — thedivergentai/GD-Agentic-Skills](https://github.com/thedivergentai/GD-Agentic-Skills/blob/4c4d0ff5c4597938cc9257d99d9e35f7692c9c06/skills/godot-procedural-generation/SKILL.md).

A skill cobre Godot/GDScript, FastNoiseLite para mapas de altitude e biomas,
sementes por gerador, geração de dados em WorkerThreadPool, Poisson Disk Sampling
para distâncias mínimas, caminhos, cavernas, salas BSP e WFC para adjacência de
peças. Os exemplos `poisson_disk_sampling_2d.gd` e
`multi_threaded_chunk_gen.gd` foram lidos na mesma revisão. Poisson Disk corresponde
especialmente ao pedido de controlar distâncias entre árvores, pedras e spawns.

Os exemplos são referências; não foram executados nem integrados no jogo.
O exemplo de Poisson compara cada candidato a todos os pontos existentes:
para regiões grandes, adaptar para uma grade espacial, validar parâmetros e
limitar tentativas. Chunks vizinhos precisam considerar pontos de uma faixa
comum para não violarem as distâncias na fronteira. Dados de geração devem ser
produzidos fora da SceneTree; criação de nós e colisões deve seguir o fluxo do
motor no thread principal. A skill também tem recomendações de navegação 3D que
não devem substituir automaticamente a lógica de colisões 2D atual.

## Complementar: godot-procedural-worlds

[SKILL.md — TheMarco/godot-game-skills](https://github.com/TheMarco/godot-game-skills/blob/06c2366a90ed6f5a286583e069c8358a351696d8/skills/godot-procedural-worlds/SKILL.md).

Mais focada em determinismo por coordenadas/domínio, fronteiras compartilhadas,
ordem independente de carregamento, persistência de alterações em objetos
coletáveis e troca segura de chunks. Útil para o streaming e os saves existentes.
Não fornece um gerador completo pronto de rios/cidades para Valedouro.

## Encaixe no projeto

O jogo já tem chunks determinísticos em `cartoon_chunk.gd`, streaming em
`cartoon_world_stream.gd`, reservas para locais da campanha e caça com IDs
persistentes. A cidade e o castelo são planejados. A recomendação é ampliar a
natureza procedural preservando esses locais, entradas e estradas canônicas.

Uma implementação futura deve compartilhar uma configuração de regras:

- semente e versão do gerador, separando terreno, decoração e encontros;
- distância por par de categorias, raio de colisão e densidade por bioma;
- altura/umidade para água, montanhas e vegetação;
- largura de rios, margens livres e travessias acessíveis;
- áreas reservadas para missão, cidade, portais e pontos de coleta;
- distância de animais/monstros das áreas seguras e dificuldade por região;
- geração antecipada dos dados, carregamento limitado ao entorno e cache;
- validação de fronteiras, rotas, sementes e persistência após revisitar chunks.

Busca concluída: nenhuma skill específica estava instalada. O catálogo de
plugins retornou ferramentas de design/pesquisa, sem gerador específico de
mapas Godot; a pesquisa de código no GitHub encontrou as duas skills acima.
Este documento registra as fontes para continuidade. Nenhuma skill externa
foi instalada e nenhuma posição do mundo foi alterada por essa pesquisa.
