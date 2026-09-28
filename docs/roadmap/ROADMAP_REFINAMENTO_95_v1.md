# ROADMAP DE REFINAMENTO 95 — Crônicas de Valedouro v1

**Base:** Run 10 aprovado no GitHub Actions com Godot 4.7.2  
**Meta:** primeiro Vertical Slice jogável, visualmente coerente e pronto para teste do Diretor  
**Região:** REG_001 — Berço de Valedouro  
**Regra:** não avançar para expansão massiva das 8 regiões antes de fechar este gate.

## Estado confirmado

Já passa:
- Godot 4.7.2 import/parser;
- validação estática;
- rotas principais e 3 pontes;
- movimento/colisão;
- controles touch;
- animação do herói;
- 10 criaturas;
- combate, dano e morte;
- loot e materiais;
- inventário/equipamento;
- progressão da guilda;
- cidade -> bosque;
- dungeon;
- Guardião;
- save/load;
- auditoria visual automatizada;
- vegetação procedural determinística;
- fauna e ambientação por bioma.

Ainda precisa de refinamento forte:
- coerência visual vila/arredores;
- interiores;
- dungeon;
- vilarejos secundários;
- gelo/deserto;
- transições de terreno;
- paperdoll/equipamento final;
- quest system por IDs;
- save v5;
- arquitetura modular do Player;
- combate responsivo;
- performance/culling Android;
- polishing visual final.

# Fase R95-A — Coerência visual do mundo

## R95-01 — Vila principal
- equalizar nível de detalhe entre pintura da vila e tiles externos;
- revisar chão, muros, água, pontes e bordas;
- aumentar variedade arquitetônica;
- inserir props funcionais: barris, caixas, placas, bancos, postes e vegetação urbana;
- reduzir áreas visualmente vazias;
- garantir sombras de contato em árvores, casas e props.

Gate:
- captura 01_vila sem elementos claramente placeholder;
- nenhuma transição vila/campo visualmente abrupta.

## R95-02 — Vegetação procedural refinada
- manter seed fixa;
- criar variação de escala/tom dentro de limites;
- usar clusters naturais em vez de grade;
- áreas abertas próximas a caminhos;
- densidade alta no bosque, média nos campos, baixa em vilas;
- sombras refinadas com direção de luz consistente;
- árvores grandes com colisão; pequenos detalhes sem colisão.

Gate:
- grade procedural não perceptível em captura;
- estrada/entrada/ponte nunca bloqueada;
- árvore não aparenta flutuar.

## R95-03 — Transições de bioma
- suavizar floresta -> campos -> vale;
- borda de neve gradual;
- areia com transição por pedras e vegetação seca;
- margem de rio com lama/pedra/juncos;
- usar tiles intermediários quando necessário.

Gate:
- nenhuma borda 32x32 óbvia em visão normal.

## R95-04 — Gelo
- ampliar rochas, cristais, neve acumulada, coníferas e vento/neve;
- criar micro-landmarks visuais;
- preservar legibilidade da rota.

## R95-05 — Deserto
- dunas visuais, pedras, arbustos secos, cactos, areia movida pelo vento;
- enriquecer caravana e outpost;
- adicionar leitura ambiental sem poluir combate.

## R95-06 — Assentamentos secundários
- substituir casas geométricas simples;
- poço, cercas, jardins, depósitos, bandeiras e pequenos serviços;
- identidade própria por subregião.

# Fase R95-B — Mundo vivo

## R95-07 — Fauna regional
- manter cervo, raposa, lebre, cabra, camelo, pássaros e peixes;
- adicionar comportamento simples: fugir, vagar, pousar e voltar ao território;
- não permitir fauna atravessar obstáculos.

## R95-08 — Ambientação dinâmica
- borboletas/luzes em áreas verdes;
- neve em Nivora/protótipo de gelo;
- poeira no deserto;
- partículas leves perto da água;
- limite estrito para Android.

## R95-09 — NPCs de mundo
- NPC principal, ferreiro, comerciante, alquimista e guilda;
- estados visuais idle;
- pequenas rotas dentro do hub;
- nunca bloquear portas;
- diálogo por ID, não texto hard-coded no main.

## R95-10 — Eventos ambientais
- pequenos eventos sem grind territorial;
- patrulha, viajante, comerciante, animal assustado, criatura incomum;
- seed/flags para não repetir excessivamente;
- nenhum evento crítico procedural.

# Fase R95-C — Combate e protagonista

## R95-11 — Player modular
Criar Player.tscn:
- CharacterBody2D;
- VisualRoot;
- Body;
- Armor;
- Weapon;
- VFX;
- CollisionShape2D;
- Hurtbox;
- InteractionArea;
- CombatOrigin;
- HealthComponent;
- StatsComponent;
- EquipmentComponent;
- AnimationController.

Gate:
- main.gd deixa de ser proprietário das responsabilidades internas do herói.

## R95-12 — Movimento e esquiva
- aceleração/desaceleração;
- dodge;
- stamina curta;
- i-frames configuráveis;
- joystick + ataque simultâneos.

## R95-13 — Feedback de combate
- hit-stop curto;
- knockback;
- flash;
- poeira;
- números;
- som preparado por hooks;
- telegraph claro.

## R95-14 — Inimigos REG_001
- Lobo;
- Aranha Sombria;
- Javali Musgoso como expansão;
- leash;
- aggro;
- retorno à origem;
- diferenças reais de comportamento.

## R95-15 — Guardião final do slice
- carga;
- onda circular;
- telegraphs;
- janela de vulnerabilidade;
- arena refinada;
- material garantido;
- flag persistente;
- não respawn durante progressão normal.

# Fase R95-D — Progressão e dados

## R95-16 — Quest IDs
Migrar o protótipo de integer quest para:
- QUEST_A01_REG001_001;
- QUEST_A01_REG001_002;
- QUEST_A01_REG001_003;
- QUEST_A01_REG001_006;
- QUEST_A01_REG001_007;
- QUEST_A01_REG001_008.

Regras:
- kills anteriores não contam;
- recompensa única;
- save por quest_id;
- nenhuma lógica baseada em título.

## R95-17 — Loot e crafting inicial
- loot tables por ID;
- baixa chance de equipamento;
- materiais frequentes;
- boss material garantido;
- crafting inicial do item do Guardião;
- upgrades limitados +2/+3 no slice.

## R95-18 — Save v5
Salvar:
- safe position;
- região/zona;
- HP;
- nível/XP;
- ouro;
- inventário;
- loadout;
- materiais;
- quests;
- boss flags;
- world flags;
- seed procedural;
- schema version.

Migrar saves antigos sem crash.

# Fase R95-E — Interface e conteúdo interno

## R95-19 — HUD e inventário
- manter identidade madeira/RPG;
- melhorar legibilidade em Android;
- comparação equipado vs item;
- botões grandes;
- inventário não cobrir informações críticas;
- feedback de loot;
- objetivo de quest.

## R95-20 — Interiores e dungeon
Guilda:
- quadro de contratos;
- mapa;
- troféus;
- NPCs.

Ferreiro:
- forja;
- bigorna;
- armas;
- luz quente.

Alquimia:
- ervas;
- frascos;
- bancada;
- brilho sutil.

Dungeon:
- paredes/piso variados;
- corredor;
- sala;
- ruína;
- cristais/tochas;
- arena;
- entrada/saída;
- menos repetição de Tile.

# Fase R95-F — Android/performance

## R95-21 — Chunks e culling
- mundo externo dividido em chunks;
- gerar/ativar vegetação apenas perto da câmera;
- pooling para fauna/monstros;
- não instanciar milhares de nós invisíveis.

## R95-22 — Orçamento móvel
Metas iniciais:
- 60 FPS em aparelho-alvo quando possível;
- física a 60 Hz;
- partículas limitadas;
- sem shaders pesados;
- texturas compactas;
- sem overdraw excessivo.

## R95-23 — Touch final
- joystick multitouch;
- atacar enquanto move;
- interação;
- poção;
- inventário;
- mapa;
- dodge;
- zonas seguras para telas 16:9/20:9.

# Fase R95-G — Gate de entrega

## R95-24 — Auditoria visual automatizada
Capturas reais do Godot:
1. vila;
2. floresta oeste;
3. campos;
4. vale;
5. rio/ponte;
6. gelo;
7. deserto;
8. bosque;
9. dungeon/boss;
10. guilda;
11. ferreiro;
12. alquimia;
13. combate;
14. inventário.

Adicionar posteriormente:
15. loot no chão/feedback;
16. equipamento alterado;
17. boss telegraph carga;
18. boss telegraph onda;
19. morte/respawn;
20. save carregado.

## R95-25 — Critério de 95%
O slice só recebe status CANDIDATO JOGÁVEL quando:
- 19/20 critérios do QUALITY_GATE_95 estiverem verdes;
- Godot 4.7.2 PASS;
- nenhum parser/runtime fatal;
- loop cidade -> campo -> combate -> loot -> equipar -> dungeon -> Guardião -> save/load PASS;
- visual não apresentar placeholders gritantes;
- performance aceitável no Android;
- captura real revisada.

## Ordem operacional atual

1. R95-20 — interiors/dungeon refinement.
2. R95-01 — vila e integração com arredores.
3. R95-02/R95-03 — vegetação e transições.
4. R95-04/R95-05/R95-06 — gelo, deserto e assentamentos.
5. R95-11/R95-12/R95-13 — Player modular e combate.
6. R95-14/R95-15 — inimigos/boss.
7. R95-16/R95-17/R95-18 — quests/loot/save.
8. R95-19 — UI.
9. R95-21/R95-22/R95-23 — Android.
10. R95-24/R95-25 — gate final.

## Regra de capturas para o Diretor

Enviar capturas ao Diretor apenas quando houver mudança visual comparável e significativa. Sempre usar screenshots reais do Godot 4.7.2 provenientes do CI ou do aparelho; nunca mockup apresentado como execução.
