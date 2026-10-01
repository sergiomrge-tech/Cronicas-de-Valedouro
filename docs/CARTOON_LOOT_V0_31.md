# Candidata v0.31 — loot cadenciado e consumíveis

A v0.31 continua diretamente da v0.30 e adiciona uma camada de recompensa de
combate sem acelerar demais o poder do personagem.

## Loot de monstros

Monstros comuns, chefes e demônios de elite passam a usar o mesmo catálogo de
loot da campanha Cartoon.

- monstros comuns: 22% de chance de material, 8% de chance de Frasco de Cura e
  1,5% de chance inicial de equipamento;
- chefes: material garantido, 35% de consumível e 18% de equipamento;
- demônios de elite: 45% de material, 20% de consumível e 6% de equipamento;
- equipamentos nunca aparecem fora do catálogo fabricável da própria região;
- itens já obtidos não são duplicados como novos equipamentos raros.

Para evitar sequências extremas de azar, o save mantém um contador de
**piedade de loot**. Depois de 35 derrotas sem equipamento raro, a chance sobe
gradualmente; na 50ª derrota elegível o drop é garantido. Um equipamento raro
obtido zera o contador. Chefes e elites não apagam progresso do contador se
não entregarem equipamento.

## Consumíveis

Dois consumíveis persistentes entram no save:

- **Frasco de Cura** — restaura 35% da vida máxima;
- **Elixir Restaurador** — restaura 70% da vida máxima.

A Bolsa recebe a aba **ITENS**, com quantidade, descrição e botão **USAR**.
Consumíveis não podem ser desperdiçados quando a vida já está cheia.

## Save

O schema sobe para **v7** preservando os saves anteriores. Campos adicionados:

- `consumables`;
- `loot_pity`.

Campanha, missões, demônios, classes, habilidades, equipamentos, materiais e
demais dados da v0.30 continuam sendo migrados.

## Integração regional

Drops foram conectados às oito regiões Cartoon e aos demônios de elite.
As mensagens de combate mostram o loot obtido sem substituir o feedback de
história, ouro ou objetivo.

## Validação

Novo teste:
`game/tests/cartoon_loot_v031.gd`

Cobre:
- material, consumível e equipamento forçados;
- cura e bloqueio em vida cheia;
- pity garantido;
- recompensa de chefe;
- persistência no save v7;
- aba ITENS e uso pela Bolsa.

QA visual:
`game/tests/qa_capture_loot_v031.gd`

Gera cinco capturas reais de Godot com Bolsa desktop/mobile, uso de cura,
feedback de drop e equipamento raro na Bolsa.

A candidata só deve ser tratada como validada após o Godot Gate 4.7.2 concluir
com sucesso. Nenhum APK deve ser gerado automaticamente; exportação somente
mediante pedido explícito do Diretor.
