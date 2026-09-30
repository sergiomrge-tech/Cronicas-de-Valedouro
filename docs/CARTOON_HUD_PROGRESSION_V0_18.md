# Crônicas de Valedouro — HUD e Progressão v0.18

## HUD mobile
A v0.18 substitui o bloco de texto de status por um HUD compacto comum a todas as regiões.

Exibe:
- região atual;
- nível real do personagem;
- barra de vida;
- barra de XP;
- ouro;
- leitura de nível máximo.

O HUD ocupa o canto superior esquerdo e preserva a faixa central para Mapa, Forja e Bolsa, mantendo os botões de ação no canto inferior direito.

## Progressão real 1–100
O `CartoonPlayerState` agora possui progressão funcional:
- nível mínimo 1;
- teto 100;
- curva de XP crescente;
- XP persistente;
- level up automático;
- +4 de HP máximo por nível;
- recuperação parcial ao subir de nível;
- nível/XP integrados ao save v0.16.

Ao entrar em uma região avançada, o nível definido pela campanha funciona como piso de progressão, sem reduzir níveis já obtidos.

## XP de combate
Cada região concede XP em uma cadência própria. Chefes concedem multiplicador de XP. O Cerco de Valedouro usa a escala do nível atual.

## Integração
O HUD compartilhado está em:
`game/scripts/cartoon/cartoon_hud_status.gd`

Ele foi integrado em:
- Valedouro;
- Floresta Ancestral;
- Deserto de Edravar;
- Pântanos Sombrios;
- Montanhas Nevadas;
- Cerco de Valedouro;
- Costas e Ilhas Perdidas;
- Terras Corrompidas;
- Coração Abissal.

## Teste
`game/tests/hud_progression_v018.gd` valida:
- curva de XP;
- subida de nível;
- aumento de HP;
- progressão parcial;
- teto 100;
- atualização das barras e textos do HUD.
