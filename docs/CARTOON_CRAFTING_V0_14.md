# Crônicas de Valedouro — Crafting e Equipamentos v0.14

A exploração agora alimenta uma progressão de equipamentos persistente.

## Sistema implementado

- estado global persistente entre regiões e reinícios do aplicativo;
- materiais coletados deixam de ser locais da cena e passam a integrar o perfil do jogador;
- 14 receitas de fabricação: 7 armas e 7 armaduras;
- cada região dos Atos II–VIII possui um conjunto temático;
- fabricação consome exatamente os materiais obtidos ao explorar;
- item fabricado é equipado automaticamente se for superior ao atual;
- botão **FORJA** disponível no HUD mobile;
- painel mostra arma, armadura, bônus e materiais carregados;
- arma aumenta dano real dos ataques;
- armadura reduz dano real recebido;
- aparência do herói muda conforme o tier da arma e da armadura;
- equipamento e materiais são salvos em `user://valedouro_cartoon_profile_v1.json`.

## Progressão

| Região | Arma | ATQ | Armadura | DEF |
|---|---|---:|---|---:|
| Floresta Ancestral | Lâmina de Carvalho Vivo | +4 | Couraça dos Guardas Verdes | +2 |
| Edravar | Sabre de Âmbar Negro | +7 | Armadura das Dunas | +3 |
| Pântanos Sombrios | Espada dos Juncos | +10 | Manto do Brejo | +4 |
| Montanhas Nevadas | Lâmina de Geada | +14 | Cota da Vigília Branca | +5 |
| Costas e Ilhas | Espada da Maré Azul | +18 | Armadura do Navegante | +6 |
| Terras Corrompidas | Quebra-Obelisco | +23 | Placas das Seis Coroas | +8 |
| Coração Abissal | Lâmina do Último Mapa | +30 | Armadura Entre Mundos | +10 |

A estrutura mantém a cadência: explorar integralmente cada região fornece material suficiente para fabricar arma e armadura daquele estágio, evitando salto de poder antecipado.
