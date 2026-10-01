# Castelo Real Cartoon v0.23 — candidata

Solicitação do Diretor: criar o castelo do rei, gigantesco, com interior luxuoso e decorado. Implementado na base Cartoon em 01/10/2026.

## Exterior monumental

O antigo prédio pequeno é substituído por um castelo integrado de 1640×1180 unidades visuais, com sete torres, torre central elevada, telhados de ardósia azul em fiadas, alas laterais, fachada clara, escadaria, portão, brasões e bandeiras. O protagonista permanece em sua escala: a construção ocupa mais de uma tela de celular.

O complexo fica a **nordeste da cidade**, ligado à avenida norte por um ramal pavimentado. Inclui pátio cerimonial, jardins, vasos, bandeiras, estátuas e guardas. A mudança de sítio evita que o novo edifício bloqueie a Estrada Norte, seus lobos e os marcos da campanha. O local do portão da história é preservado. O mapa sinaliza o Castelo Real, e o menu inicial usa sua nova silhueta.

Dados espaciais: `CASTLE_ANCHOR = (2500,-350)` e `CASTLE_DOOR = (2500,-280)` em coordenadas locais do hub. Terrenos reais são reservados em `ROYAL_GROUNDS`. Colisão exterior vale também fora do retângulo da cidade original; vegetação procedural e animais de caça não são criados sobre o complexo. Nenhum ID de missão principal foi alterado.

## Oito alas exploráveis

| Ala | Decoração e função |
|---|---|
| Grande Vestíbulo | Entrada, longo tapete, colunas, estátuas, lustre e guardas. |
| Salão do Trono | Trono dourado com veludo, rei, guardas, seis colunas, estátuas, grandes bandeiras e passadeira cerimonial. |
| Salão de Banquetes | Seis mesas com louça e taças, assentos de veludo, flores e lustre. |
| Biblioteca Real | Estantes entalhadas, livros, mesas de leitura e escrita. |
| Aposentos Reais | Cama com dossel, sofás, retrato, escrivaninha e tapete; descanso restaura vida e salva. |
| Galeria Real | Retratos emoldurados, esculturas de mármore e assentos. |
| Câmara do Conselho | Mesas cerimoniais, documentos e estantes. |
| Galeria de Honra | Estatuária, passadeira, brasões e iluminação. |

A planta ocupa uma área delimitada de **4220×3700 unidades** e possui mais de 100 elementos de mobiliário/decoração. Oito passagens conectam as alas; placas indicam os destinos. Os pisos de mármore têm veios, bordas douradas, medalhões e painéis nas paredes. Móveis têm colisão; corredores e espaços centrais ficam livres.

Aproxime-se do portão exterior e toque **USAR** (E). Dentro, mova-se com joystick ou WASD/setas. O HUD identifica a ala atual. Use o rei para uma saudação, os livros/obras para observação, ou os aposentos para descansar. O botão **SAIR** e o portão do vestíbulo retornam ao mesmo ponto externo. Não há nova missão obrigatória nem recompensas de campanha associadas à audiência. O personagem é apresentado como Rei de Valedouro, sem inventar nome ou biografia.

A visita mantém o save exterior: continuar uma partida salva no castelo reaparece diante do portão, preservando vida, equipamento, materiais e contratos. Pausar, consultar inventário e voltar ao menu continuam funcionando.

## Arte e integração

24 SVGs originais em `game/assets/cartoon/v023`, gerados de forma determinística por `game/tools/cartoon/build_royal_castle_assets.py`. Manifesto com hashes SHA256, todos **MODELED_PENDING_GATE**. Detalhes do palácio e interações adicionais permanecem **PROPOSED**.

`cartoon_royal_palace.gd` define salas, passagens, objetos e áreas de circulação. O controlador de interiores v0.22 é reutilizado para câmera, controles, pausa, retorno e save. `cartoon_royal_assets.gd` compartilha texturas importadas. Taverna, forja, guilda e caça continuam presentes.

## Verificação executada

**23 testes Cartoon passaram em Godot 4.6.3.stable.official.7d41c59c4.** Incluem os oito atos, campanha, saves, crafting, inventário, HUD, layouts v0.21, interiores/caça v0.22 e o novo `cartoon_royal_castle_v023.gd`.

O teste novo verifica escala exterior, caminho contínuo da chegada ao portão real, estrada norte e marco canônico acessíveis, ausência de fauna no complexo, oito alas conectadas com busca de caminho no piso real, sobreposição contínua dos corredores nas salas, acesso a todas as interações, paredes/móveis, rei, descanso, saída, save/load, retorno ao menu e HUD em 640×360, 960×540 e 1024×768. O teste de acesso v0.20 foi expandido para cobrir o novo sítio real, sem reduzir suas verificações.

16 capturas reais em Godot/OpenGL Compatibility/Mesa llvmpipe: exterior completo, jardins, planta total, oito alas, trono, aposentos, HUD mobile e mapa. Panoramas ocultam o HUD somente para inspeção; a planta usa zoom reduzido de QA, não uma opção nova do jogador. [Abrir revisão interativa](visual_qa/cartoon_v023/review.html).

**Pendentes:** runtime oficial Godot 4.7.2, exportação APK/AAB, ergonomia/desempenho em Android e aprovação visual do Diretor. Candidata em revisão, incluída no salvamento do código no GitHub solicitado pelo usuário. A versão oficial documentada permanece v0.19.
