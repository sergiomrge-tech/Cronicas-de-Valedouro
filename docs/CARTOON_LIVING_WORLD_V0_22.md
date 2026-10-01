# Mundo vivo Cartoon v0.22 — candidata

A pedido do Diretor: refinar o visual, construir os interiores da taverna, ferreiro e guilda, oferecer várias missões no quadro e povoar o mapa com animais de caça.

## Conteúdo jogável

| Construção | Interior e serviço |
|---|---|
| Taverna de Valedouro | Piso de madeira, mesas com refeições, cadeiras, barris, balcão, lareira, cama e personagens. Descansar restaura toda a vida e salva; o caçador explica a fauna. |
| Oficina do ferreiro | Piso de pedra, fornalha com brilho, bigorna, bancadas, carvão, caixotes, suportes de armas e ferreiro. Fabrica Lâmina de Caçador (+2 ATQ, 3 Ossos de caça) e Colete de Couro do Vale (+1 DEF, 3 Couros do Vale). |
| Salão da guilda | Quadro físico com papéis, escrivão, balcão, estantes, mapa, bandeira, mesa e aventureiro. Sete contratos opcionais, com até três ativos. |

Aproxime-se da construção e toque **USAR** (E no teclado). Dentro, mova-se pelo salão e use o serviço próximo. A porta ao sul ou o botão **SAIR** retorna ao mesmo ponto de Valedouro. A pausa e o inventário continuam disponíveis. WASD/setas movem; J/espaço atacam ao ar livre.

Os interiores têm colisão no mobiliário e passagem livre até cada serviço. São espaços dentro da cena do hub, com terreno, câmera e streaming externos suspensos durante a visita. O save registra o ponto externo: ao continuar uma partida salva dentro de uma construção, o herói reaparece na entrada, preservando vida, materiais, equipamentos e contratos. Sair ao menu pela pausa também mantém essa regra.

## Quadro da guilda

| Contrato | Objetivo | Recompensa |
|---|---|---|
| Provisões para a estrada | 3 coelhos após aceitar | 25 ouro + 20 XP |
| Rastros no bosque | 2 cervos após aceitar | 40 ouro + 30 XP |
| Javalis nas lavouras | 3 javalis após aceitar | 55 ouro + 40 XP |
| Expedição de caça | 6 animais após aceitar | 65 ouro + 45 XP |
| Despensa da taverna | Entregar 5 Carnes de caça | 30 ouro + 25 XP |
| Lobos nos Campos do Vale | 3 lobos comuns do hub; alvos da história não contam | 30 ouro + 25 XP |
| Couro para a oficina | Entregar 4 Couros do Vale | 45 ouro + 35 XP |

Aceitar inicia a contagem de abates. As entregas podem usar materiais já coletados e consomem a quantidade indicada. Recompensas são recebidas no quadro, uma vez por contrato. O HUD mostra a quantidade ativa, contratos prontos e o progresso do primeiro; o quadro permite consultar todos. O antigo contrato opcional de lobos migra do save mantendo seu progresso. Os lobos da história continuam separados.

## Fauna e visual

33 SVGs originais: três pisos de salão, mobiliário e acessórios, cinco personagens e coelhos/cervos/javalis com duas poses por espécie. Gerador determinístico: `game/tools/cartoon/build_living_world_assets.py`; catálogo com hashes em `game/assets/cartoon/v022/manifest.json`. Arte **MODELED_PENDING_GATE**, conteúdo adicional **PROPOSED**.

Valedouro ganhou moradores caminhando por rotas seguras, luz nas entradas, fumaça da forja e bandeira na guilda. As construções mantêm as posições e as vias do passe v0.20.

A fauna é distribuída em grupos determinísticos por seis regiões naturais: Valedouro, Floresta Ancestral, Deserto, Pântanos, Montanhas e Costas. Cada região possui mais de 250 posições de população, com até 40 animais instanciados perto do jogador. A cidade fica livre de animais selvagens. Coelhos e cervos fogem; javalis se defendem quando provocados. Todos deixam carne e osso; cervos deixam um couro, javalis dois. Caçar concede XP e atualiza contratos ativos. Os slots abatidos retornam após 180 segundos de relógio real, inclusive durante tempo fora do jogo. Esse intervalo é salvo para impedir reposição imediata ao recarregar.

Pântanos e Costas compartilham a geometria das manchas de água entre renderização e fauna. Não se criam animais terrestres sobre essas manchas. As regiões corrompidas e abissais mantêm os encontros sobrenaturais existentes.

## Validação

22 testes Cartoon executados com **Godot 4.6.3.stable.official.7d41c59c4**: campanha, oito atos, saves, inventário, crafting, progressão, zoom, layout v0.21 e novo teste `cartoon_living_world_v022.gd`.

O teste novo verifica as três portas, movimento interno, conectividade até cada serviço, descanso, forja, quadro em 640×360/960×540/1024×768, saída, avanço canônico na guilda, combate real contra fauna, fuga, defesa, pausa, loot sem duplicação, contratos e pagamentos, entregas de materiais, migração do contrato antigo, save/load, reposição, streaming e retorno ao menu a partir da taverna. O teste de UI v0.21 continua verificando oito regiões e cinco tamanhos.

16 capturas reais de Godot/Mesa llvmpipe, incluindo panoramas com HUD oculto apenas para inspeção da arte, telas jogáveis, quadro no celular, fabricação e fauna. A imagem de detalhe da fauna reúne atores para inspeção; a imagem dos campos registra a população normal. [Abrir revisão](visual_qa/cartoon_v022/review.html).

O audit espacial histórico terminou com 35 construções e zero regras com falha; ele se refere à base antiga. A conectividade dos novos interiores Cartoon é validada pelo teste dedicado.

**Pendentes:** runtime oficial Godot 4.7.2, ergonomia/desempenho em Android real, exportação APK/AAB e aprovação visual. Este passe permanece uma candidata local. Nenhuma alteração foi enviada ao GitHub nesta sessão.
