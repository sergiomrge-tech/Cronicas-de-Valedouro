# Cartoon v0.26 — esquiva e avisos de ataque

Evolução da candidata v0.25. Novas mecânicas **PROPOSED**; arte reutilizada **MODELED_PENDING_GATE**. Preserva cânone, IDs, quests e formato do save. Não cria classes, chefes ou missões novos.

## Combate

As oito regiões Cartoon usam ataques de contato com preparação visível. Inimigos comuns avisam por 0,45 s; chefes por 0,8 s. O círculo permanece centrado no atacante, que para de perseguir durante a preparação; o arco preenche a contagem e uma seta registra a direção. Cor âmbar em criaturas comuns, vermelha em chefes. O raio é o alcance de contato existente da região +12 unidades em criaturas comuns ou +42 em chefes. A escala do sprite não altera a área indicada.

Ao terminar o aviso, o golpe só acerta se o herói estiver dentro da área e fora da proteção da esquiva. O atacante entra na recuperação original de 0,9 s mesmo se errar. Continua usando dano de contato, defesa do equipamento e fluxo de resgate existentes. Inimigo derrotado não conclui o golpe; preparação não avança com pausa ou painéis modais. Chefes passam pelo mesmo mecanismo de aviso, sem novas fases de história.

Esquiva: Shift no computador ou ESQUIVA no HUD. Usa direção do teclado/joystick, movimento atual ou direção em que o herói olha. Percorre até 120 unidades em 0,22 s, recarga de 2,2 s, proteção contra os golpes de contato dos monstros e javalis por 0,16 s. A proteção não cobre a esquiva inteira e não redefine o dano de outros sistemas. Rastro azul, partículas e imagens transitórias do herói usam arte compartilhada e os limites de FX existentes.

A trajetória testa a geometria de movimento da região em passos de até seis unidades: colisões de Valedouro e limites das demais regiões. Não introduz novas colisões onde a região não possui geometria sólida. Não soma caminhada normal ao deslocamento da esquiva; não permite espada/conjuração durante o movimento rápido. Abrir um modal, entrar em interior ou cair cancela o movimento restante. Pause da árvore congela a ação. Construções não permitem iniciar esquiva.

## Interface

Novo botão com alvo de 62×50 px, recarga visível e bloqueio em interiores/painéis. Mantém espaço entre toolbar, magia, interação e ataque em 640×360, 800×450, 960×540 e 1024×768. Não captura o dedo como joystick. Mensagens transitórias ficam abaixo do objetivo e acima da toolbar em telas compactas; avisos de interação não cobrem as mensagens. Ao expandir a missão, ações que seriam sobrepostas são ocultadas até recolher o painel. Movimento/combate da região também param ao abrir guilda ou escolha final.

## Validação e Android

26 testes passaram no Godot 4.6.3 local. Novo teste `cartoon_reactive_v026.gd`: oito regiões, ausência de dano antes do aviso, área comprometida, recuperação, evasão curta, distância/recarga, colisão real da forja, pausa, modais, inimigo morto, resgate, sobreposição de HUD e toque nativo no botão. Mantém a suíte de campanha, combate elemental, caça, save, inventário, crafting, interiores e castelo.

Capturas reais e GIFs em `docs/visual_qa/cartoon_v026/review.html`, gerados por `game/tests/qa_capture_reactive_v026.gd`. Alvos de QA são posicionados para comparação, incluindo um goblin com flag de chefe somente no script de captura; nenhuma nova criatura é adicionada ao jogo. Passos de 25 ms e GIFs com 30 ms por quadro; capturas não são um benchmark de desempenho.

Workflow Android configurado para Godot 4.7.2, 26 testes, exportação e assinatura, publicando `v0.26-test`: versionCode 26, versionName 0.26-test, pacote `com.sergiomrge.cronicasvaledouro.test`, Android 7.0+, ARM 32/64 bits. Resultados efetivos ficam nos runs do GitHub Actions. Aprovação visual e teste de desempenho/ergonomia em aparelho real permanecem pendentes.
