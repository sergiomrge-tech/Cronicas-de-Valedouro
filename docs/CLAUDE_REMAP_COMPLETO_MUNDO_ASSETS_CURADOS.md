# CLAUDE/OPUS — REMAPEAMENTO COMPLETO DO MUNDO COM ASSETS CURADOS

## Contexto
Projeto: Crônicas de Valedouro
Engine de validação: Godot 4.7.2
Branch de trabalho: ccr-bb54cda9-tvw178
Foco atual: MOBILE
Direção visual oficial: a já aprovada no projeto. Os assets externos são referência/matéria-prima e NÃO devem substituir o estilo oficial bruto.

## Objetivo
Refazer o mapa completo de Crônicas de Valedouro usando as melhores famílias de assets gratuitos já baixadas no repositório, corrigindo os problemas atuais de:
- módulos retos e sem angulação;
- paredes, janelas e telhados soltos;
- peças flutuando;
- construções sem integração com terreno;
- repetição visual;
- biomas com transições artificiais;
- ambientação pobre ao redor de construções;
- falta de coerência entre cenário, história e missões.

O resultado deve parecer um mundo construído de forma orgânica e intencional, não um mosaico de módulos.

---

# 1. FONTES OBRIGATÓRIAS POR CATEGORIA

## A. Árvores e vegetação — referência principal
Usar prioritariamente:

external_assets/free_reference_library/karsiori/tree_pack/
external_assets/free_reference_library/karsiori/bush_pack/
external_assets/free_reference_library/karsiori/flower_pack/
external_assets/free_reference_library/karsiori/rock_pile_pack/
external_assets/free_reference_library/karsiori/spruce_tree_animated/
external_assets/free_reference_library/karsiori/woods_tileset/

Complemento:
external_assets/free_reference_library/nature/kenney_foliage_pack/

Regra:
Karsiori é a referência visual principal para árvores e vegetação.
Kenney Foliage serve para variedade de formas e composição, mas deve ser remodelado para o padrão de Valedouro.

Aplicar por bioma:
- Berço/Campos: verdes vivos, flores, arbustos, vegetação agrícola e bordas naturais.
- Floresta Ancestral: árvores grandes, copas densas, raízes, troncos caídos, samambaias, musgo.
- Montanhas Nevadas: spruce/coníferas, vegetação baixa, rochas, neve acumulada.
- Deserto/Ruínas: vegetação seca esparsa, arbustos resistentes, rochas e restos secos.
- Pântanos: raízes, árvores tortas, vegetação úmida, fungos, plantas de margem.
- Costas/Ilhas: vegetação costeira, arbustos, árvores moldadas pelo vento, pedras.
- Terras Corrompidas: versões remodeladas em tons escuros/avermelhados/roxos, com transição gradual.
- Coração Abissal: vegetação mínima, anômala e sobrenatural; não usar floresta comum.

Não fazer recoloração automática simples. Cada bioma precisa de variações próprias.

## B. Casas, cidades, muralhas, castelos e torres — referência principal
Usar prioritariamente:

external_assets/free_reference_library/buildings/kenney_sketch_town_expansion/

Complementos:
external_assets/free_reference_library/buildings/kenney_medieval_rts/
external_assets/free_reference_library/buildings/kenney_tiny_town/

Prioridade de uso:
1. Sketch Town Expansion = referência modular principal para:
   - telhados;
   - cantos;
   - paredes;
   - torres;
   - muralhas;
   - castelos;
   - cercas;
   - poços;
   - estruturas em diferentes ângulos.
2. Medieval RTS = referência de massa, fortificação e composição de cidade/fortaleza.
3. Tiny Town = referência de leitura de vila e distribuição de edifícios, nunca como arte final.

Regra:
Não copiar o estilo sketch bruto.
Reconstruir as formas no padrão oficial de Valedouro.

Obrigatório:
- toda construção deve possuir base integrada ao chão;
- sombra de contato coerente;
- quinas e mudanças de direção reais;
- telhado conectado à parede;
- janela inserida na parede;
- nenhuma parede/telhado/janela solta;
- nenhuma peça flutuante;
- módulos em ângulos coerentes com a perspectiva;
- ruas e caminhos devem se adaptar às construções, não atravessá-las.

## C. Dungeons e interiores
Base estrutural:
external_assets/free_reference_library/dungeons/kenney_tiny_dungeon/

Usar apenas para:
- lógica modular;
- salas;
- corredores;
- portas;
- arenas;
- leitura de dungeon.

A arte final deve seguir o kit modular oficial de Cavernas/Dungeons já aprovado em Crônicas de Valedouro.

## D. Herói e humanoides — referência de ANIMAÇÃO
Principal:
external_assets/free_reference_library/animated_characters/foozle_lucifer_warrior/

Referência de cast:
external_assets/free_reference_library/animated_characters/foozle_lucifer_necromancer/
external_assets/free_reference_library/animated_characters/foozle_lucifer_sorceress/

Referência 8 direções:
external_assets/free_reference_library/animated_characters/rgs_8dir_characters/

Regra:
Não substituir o design oficial do protagonista.
Usar esses packs para timing, pose, cobertura de estados e fluidez.

Herói final precisa ter:
- idle;
- walk/run;
- ataque leve;
- combo/ataque pesado;
- ataques específicos por arma;
- cast;
- hurt;
- dodge/roll;
- death;
- transições coerentes.

## E. Mobs e monstros — referência animada principal
Usar esta família como base de animação/coerência:

external_assets/free_reference_library/animated_monsters/foozle_goblin_slinger/
external_assets/free_reference_library/animated_monsters/foozle_goblin_berserker/
external_assets/free_reference_library/animated_monsters/foozle_skeleton_grunt/
external_assets/free_reference_library/animated_monsters/foozle_skeleton_hunter/
external_assets/free_reference_library/animated_monsters/foozle_cultist/
external_assets/free_reference_library/animated_monsters/foozle_possessed/

Complemento:
external_assets/free_reference_library/animated_monsters/stealthix_animated_monsters/
external_assets/free_reference_library/animated_monsters/oga_animated_monsters/

Regra obrigatória:
Nenhum mob estático entra no gameplay final.

Todo mob deve possuir no mínimo:
- idle;
- move;
- attack;
- hurt;
- death.

## F. Bosses
Principais referências:
external_assets/free_reference_library/animated_monsters/foozle_goblin_beast_boss/
external_assets/free_reference_library/animated_monsters/foozle_skeleton_king_boss/

Usar para:
- timing;
- telegraph;
- wind-up;
- ataque especial;
- recovery;
- hit reaction;
- death.

Não usar o design bruto como boss oficial.
Remodelar para os bosses definidos na história e no banco oficial.

## G. Skills, magias e VFX
Base principal:
external_assets/free_reference_library/vfx/foozle_lucifer_effects/

Magias:
external_assets/free_reference_library/vfx/oga_basic_animated_spells/
external_assets/free_reference_library/vfx/oga_2d_spell_effects/
external_assets/free_reference_library/vfx/oga_gothicvania_magic_9/

Combate físico:
external_assets/free_reference_library/vfx/oga_slash_effect_collection/
external_assets/free_reference_library/vfx/oga_weapon_slash_effects/
external_assets/free_reference_library/vfx/oga_pixel_sword_slash/

Explosões/fogo:
external_assets/free_reference_library/vfx/oga_lpc_explosions_2/
external_assets/free_reference_library/vfx/oga_explosion_animation/
external_assets/free_reference_library/vfx/oga_animated_fire/

Toda skill deve ser pensada como sequência:
cast/charge -> travel/projétil -> impact -> AoE/ground effect quando aplicável -> dissipação.

## H. Armas, armaduras, escudos e loot
Usar prioritariamente:
external_assets/free_reference_library/equipment/oga_osare_weapon_icons/
external_assets/free_reference_library/equipment/kenney_roguelike_rpg/
external_assets/free_reference_library/equipment/oga_rpg_item_set/
external_assets/free_reference_library/equipment/oga_rpg_sheet/

Complemento:
external_assets/free_reference_library/equipment/oga_various_melee_weapons/

Uso:
- referência de silhueta;
- categorias de arma;
- legibilidade de inventário;
- variedade de loot;
- base para remodelagem dos equipamentos oficiais.

Não promover diretamente para arte final sem adaptação.

---

# 2. REMAPEAMENTO COMPLETO DO MUNDO

Leia antes:
- documentos de lore;
- história principal;
- quests;
- banco de IDs;
- regiões;
- POIs;
- bosses;
- materiais;
- receitas;
- construções ligadas a missões.

Depois reconstrua a distribuição do mundo.

## Regras de mundo

### História antes da decoração
Toda construção importante deve existir por motivo narrativo ou funcional.
A localização precisa coincidir com missões, NPCs, bosses, dungeons e progressão.

### Biomas conectados
Não fazer cortes bruscos.
Criar zonas de transição com mistura gradual de:
- terreno;
- vegetação;
- pedras;
- altitude;
- arquitetura;
- clima;
- corrupção.

### Construções
Cada vila/cidade/ruína deve possuir:
- acesso lógico;
- estrada/caminho;
- entorno detalhado;
- vegetação coerente;
- props funcionais;
- áreas de serviço;
- entradas legíveis;
- conexões com quests.

### Verticalidade visual
Usar:
- aclives;
- desníveis;
- penhascos;
- pontes;
- escadas;
- terraços;
- muralhas;
- torres;
- vales;
- rios;
- passagens naturais.

Não deixar todo o mundo plano e ortogonal.

### Densidade
Evitar tanto vazio quanto excesso.
Usar composição em camadas:
1. massas grandes — construções, árvores grandes, rochas;
2. elementos médios — arbustos, cercas, pequenos edifícios, ruínas;
3. elementos pequenos — flores, grama, folhas, cogumelos, detritos;
4. microdetalhes — somente onde ajudam leitura.

### Exploração
Criar:
- caminhos principais;
- caminhos secundários;
- atalhos;
- clareiras;
- segredos;
- passagens parcialmente escondidas;
- mirantes;
- arenas;
- áreas de recurso;
- encontros opcionais.

### Gameplay mobile
Manter:
- leitura limpa;
- espaço para combate;
- caminhos com largura adequada;
- câmera sem bloqueios constantes;
- vegetação não escondendo o herói o tempo todo;
- baixo overdraw;
- atlas e reutilização inteligente de texturas;
- ausência de objetos decorativos que causem queda de FPS.

---

# 3. REGIÕES E IDENTIDADE

Preservar as regiões oficiais do projeto e a direção visual já aprovada.

Para cada região:
1. definir paleta;
2. definir família vegetal;
3. definir arquitetura;
4. definir inimigos;
5. definir boss/elite;
6. definir materiais de craft;
7. definir POIs;
8. definir construções ligadas à história;
9. definir transições para regiões vizinhas;
10. definir uma ou mais landmarks reconhecíveis.

Nunca criar um bioma só pela cor do chão.

---

# 4. SUBSTITUIÇÃO DOS ELEMENTOS RUINS ATUAIS

Localizar e substituir:
- muros sem angulação;
- paredes soltas;
- janelas soltas;
- telhados desconectados;
- peças flutuantes;
- árvores repetidas em padrão artificial;
- objetos sem sombra de contato;
- estruturas que não respeitam terreno;
- props que bloqueiam passagem;
- módulos antigos que contradizem o novo padrão.

Se um asset antigo for substituído:
1. localizar todas as referências;
2. migrar para o novo ID;
3. validar;
4. somente então retirar o asset obsoleto do catálogo/runtime.

Não quebrar saves, referências ou manifestos.

---

# 5. NÃO MISTURAR ESTILOS

A biblioteca externa contém estilos diferentes.

É proibido simplesmente colocar todos os packs crus juntos.

Fluxo obrigatório:
referência externa -> remodelagem Valedouro -> ajuste de perspectiva/paleta/luz/sombra -> transparência -> QA -> ID oficial -> integração.

O visual oficial atual de Crônicas de Valedouro sempre vence qualquer pack externo.

---

# 6. EXECUÇÃO EM ETAPAS

Não fazer tudo em uma única sessão longa.

## ETAPA A — arquitetura do mapa
- auditar mapa atual;
- definir novo layout;
- corrigir estradas, rios, elevação, conexões e posições das construções principais;
- gerar relatório antes/depois.

## ETAPA B — cidades, vilas, castelos e locais de missão
- reconstruir com módulos angulados e coerentes;
- integrar construções ao terreno;
- remover elementos flutuantes/soltos.

## ETAPA C — natureza e biomas
- aplicar árvores/vegetação Karsiori;
- criar variações regionais;
- transições naturais;
- densidade controlada.

## ETAPA D — dungeons, ruínas e pontos de exploração
- reconstruir áreas de dungeon;
- integrar entradas ao mundo;
- criar segredos, atalhos e arenas.

## ETAPA E — mobs, elites e bosses
- posicionar famílias coerentes com cada região;
- somente usar versões animadas em gameplay;
- integrar spawns com história/progressão.

## ETAPA F — VFX e ambientação
- aplicar VFX ambientais e de combate necessários;
- não poluir visual;
- preservar desempenho mobile.

## ETAPA G — QA completo
Validar no Godot 4.7.2:
- parser/import;
- referências;
- colisões;
- caminhos;
- spawn;
- missões;
- câmera;
- animações;
- FPS;
- draw calls quando mensurável;
- assets órfãos;
- IDs duplicados;
- conteúdo REWORKED/HOLD indevidamente ativo.

---

# 7. CAPTURAS E ENTREGA

Após cada etapa relevante:
- gerar capturas REAIS do jogo no Godot;
- mostrar visão ampla e detalhes;
- nunca usar mockup como screenshot do jogo.

Ao final entregar:
- mapa remapeado;
- manifestos atualizados;
- lista de assets substituídos;
- lista de assets adicionados;
- IDs novos;
- referências migradas;
- relatório de QA;
- capturas reais;
- commits claros;
- árvore limpa.

Não iniciar uma direção visual nova.
Não simplificar o visual aprovado.
Não avançar para conteúdo desconectado do remapeamento enquanto esta tarefa não estiver consistente.
