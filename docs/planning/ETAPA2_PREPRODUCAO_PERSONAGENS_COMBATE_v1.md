# ETAPA 2 — PRÉ-PRODUÇÃO DE PERSONAGENS E COMBATE — v1

## Status

Pré-produção autorizada enquanto o passe visual do mundo é fechado.
NÃO integrar o protagonista definitivo às cenas principais antes do gate visual do Diretor.

## Objetivo

Deixar pronta a especificação técnica/artística da Etapa 2 para iniciar imediatamente após o gate visual, sem improviso e sem descaracterizar a direção aprovada.

## 1. Protagonista único

Crônicas de Valedouro usa um único protagonista, sem classes rígidas.

A build muda por:
- arma;
- escudo/off-hand;
- armadura;
- acessórios;
- skills;
- passivas.

O visual do personagem deve continuar reconhecível em todas as builds.

## 2. Direção visual

Referência obrigatória:
- pixel art detalhada e coesa aprovada no projeto;
- leitura clara em tela de celular;
- proporção compatível com Valedouro atual;
- mais detalhe e animação que o placeholder;
- silhouette primeiro;
- sem regressar ao boneco simples/geométrico.

A câmera e o grounding devem permanecer coerentes com o mundo atual.

## 3. Direções

Meta: 8 direções quando viável.

Prioridade:
1. N, S, E, W;
2. diagonais reais;
3. espelhamento somente quando não quebrar iluminação, mão dominante, arma, escudo ou leitura do equipamento.

Para ataques importantes, preferir frames dedicados a espelhamento artificial quando o custo de produção permitir.

## 4. Contrato mínimo de animação do protagonista

Por direção necessária:

- idle: 6–8 frames;
- walk: 8 frames;
- run: 8 frames;
- dodge/roll: 6–8 frames;
- light attack 1: 10–12 frames;
- light attack 2: 10–12 frames;
- light attack 3/finisher: 12–14 frames;
- heavy attack: 12–16 frames;
- block enter: 4–6 frames;
- block hold: loop curto;
- block impact/parry: 5–8 frames;
- hurt leve: 4–6 frames;
- hurt pesado/knockback: 6–10 frames;
- death: 10–14 frames;
- interact/use: 6–8 frames;
- cast/channel base: 8–12 frames.

Esses números são alvo de fluidez, não obrigação cega. A qualidade do timing e poses-chave é mais importante que inflar frames repetidos.

## 5. Armas iniciais

O pipeline deve nascer preparado para:
- espada + escudo;
- arma pesada;
- arco;
- foco/cajado mágico;
- lâminas duplas/híbridas.

Primeiro conjunto jogável: espada + escudo.

Não criar classes separadas. A mesma base deve trocar moveset conforme equipamento.

## 6. Equipamento visual

Separar lógica de aparência de lógica de stats.

Slots visuais:
- corpo/armadura;
- cabeça quando aplicável;
- arma principal;
- off-hand/escudo;
- acessório de costas quando aplicável;
- VFX de encantamento.

Usar âncoras/sockets persistentes por frame e direção:
- hand_main;
- hand_off;
- back;
- head_fx;
- feet;
- center_mass.

As âncoras devem ser exportáveis/testáveis para impedir arma ou escudo “flutuando”.

## 7. Hitboxes e hurtboxes

Nunca derivar combate diretamente do sprite inteiro.

Separar:
- hurtbox corporal;
- hitbox por ataque;
- parry/block cone;
- área de interação;
- área de pickup.

Cada ataque precisa de timeline:
windup → active → recovery.

Telegraph visual deve antecipar ataques perigosos.

## 8. Combate mobile

Controles devem permanecer legíveis com polegares.

Base:
- joystick esquerdo;
- ataque principal;
- skill contextual;
- dodge;
- defesa quando build suportar;
- interação separada ou contextual.

Evitar excesso de botões permanentes. Skills adicionais podem usar radial/slot contextual conforme teste de UX.

## 9. Feedback

Todo hit importante precisa combinar:
- hit stop curto;
- reação do alvo;
- pequeno deslocamento quando apropriado;
- flash/material ou tint controlado;
- partícula;
- som;
- número de dano opcional/configurável.

Bosses e elites:
- telegraphs claros;
- ataques de alto dano nunca instantâneos sem leitura;
- efeitos devem respeitar performance mobile.

## 10. VFX

VFX deve usar:
- atlas;
- pooling;
- partículas limitadas;
- additive/alpha com parcimônia;
- fake light em vez de iluminação dinâmica pesada.

Magias devem preservar identidade por família:
- arcana;
- elemental;
- natural;
- sombria.

## 11. NPCs

Após o protagonista:
- cidadãos de Valedouro;
- Guardas Verdes;
- mercadores/serviços;
- NPCs narrativos.

Cada família deve ter:
- idle;
- caminhada;
- interação/fala;
- 1–2 gestos contextuais.

Rotinas usam LOD de simulação; NPC distante não precisa IA completa.

## 12. Mobs e bosses Atos I–II

Produção após NPCs básicos:
- matilha/lobo;
- Alfa;
- criaturas regionais;
- família da Mina do Eco;
- Guardião;
- famílias da Floresta;
- Raiz Oca.

Cada família:
- silhouette distinta;
- locomoção;
- idle;
- ataque(s);
- hurt;
- death;
- telegraph quando necessário;
- colisões independentes de sprite.

Boss não deve ser apenas “mob maior”.

## 13. Persistência por IDs

Tudo novo entra por IDs persistentes.

Nenhum mapa deve referenciar asset crítico por nome exibido.

Registrar:
- character_id;
- animation_set_id;
- weapon_moveset_id;
- skill_id;
- passive_id;
- vfx_id;
- sfx_id;
- equipment_visual_id.

## 14. Gate técnico antes de integração

Antes de colocar o protagonista definitivo no mundo:
- spritesheet/atlas validado;
- pivôs e sockets testados;
- animações sem frame faltando;
- grounding consistente;
- hitbox timeline validada;
- troca de arma não desloca o personagem;
- 60 FPS alvo em aparelho;
- parser/runtime Godot 4.7.2 sem erro;
- teste de memória/atlas em Android.

## 15. Ordem pós-gate visual

1. protagonista base + espada/escudo;
2. movimento/dodge/block/combos;
3. hit reactions + dummy de teste;
4. equipamento visual;
5. NPCs vivos;
6. mobs Ato I;
7. boss Alfa;
8. Mina/Guardião;
9. Floresta/Raiz Oca;
10. VFX/magias;
11. vertical slice completo.

## 16. Critério de sucesso da Etapa 2

Um trecho real do jogo deve permitir:
Cidade → missão → exploração → combate → loot → equipar → dungeon → boss → mudança de estado → save/load,
com protagonista definitivo, animações ricas, feedback de combate e performance mobile estável.
