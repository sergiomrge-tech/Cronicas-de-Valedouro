# Mapa aberto — Valedouro v0.6

Mapa único de 3072 × 2304 pixels, com Valedouro no centro e cinco regiões externas conectadas. A v0.6 mantém as rotas da base v0.5, mas amplia a leitura geográfica com vale, margens de rio, três pontes e arquitetura regional.

| Região | Localização aproximada | Conteúdo v0.6 |
|---|---:|---|
| Valedouro | x 650–2424, y 680–1567 | Guilda, ferreiro, loja, alquimista, ruínas, praça e fauna urbana. |
| Bosque do Primeiro Vento | oeste/norte | Floresta densa, torres de vigia, arco antigo, lobos, aranhas e javalis conforme nível. |
| Campos de Lírio | sudoeste | Prado claro, vila dos campos, flores, fauna e limos. |
| Vale dos Lírios | sul central | Gramado próprio, moinho, santuário, pedras, flores, javalis e Flor Voraz em progressão. |
| Cascata da Aurora / rio | eixo leste | Largura variável, água profunda, água rasa, margem, juncos, peixes, cascata e três pontes. |
| Picos de Gelo | nordeste | Neve, cristais, rochas, coníferas, pouso/abrigo, lobo de gelo e Golem de Geada em nível avançado. |
| Dunas de Âmbar | sudeste | Areia com dunas, cactos, vegetação seca, caravana, posto, ruínas, escorpiões e Escaravelho Âmbar. |

A vegetação e os obstáculos continuam determinísticos: renderer e colisão consultam a mesma geografia. Água profunda e rasa bloqueiam fora das pontes; as três travessias são reconhecidas pela colisão. Construções externas têm colisão de base para evitar que o herói atravesse a arquitetura.

A estrada é guia visual, não corredor obrigatório. O jogador pode caminhar por gramados, clareiras, campos, vale, gelo e dunas sempre que não houver água, tronco, rocha ou construção ocupando o espaço.
