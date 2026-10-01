# v0.33 validada — cura rápida e progressão de equipamentos

A v0.33 continua diretamente da v0.32 validada e aprofunda a progressão RPG
sem aumentar artificialmente o poder do personagem.

## Cura rápida no HUD

O HUD recebe o botão **CURA**, pensado para celular.

- mostra a quantidade total de itens de cura disponíveis;
- fica desabilitado com vida cheia, sem consumíveis ou com o herói derrotado;
- prioriza o **Elixir Restaurador** quando falta 50% ou mais da vida;
- usa o **Frasco de Cura** em dano moderado;
- se só existir um tipo de cura, usa o disponível;
- atualiza vida, quantidade e feedback imediatamente;
- o botão participa das regras de touch e não pode iniciar o joystick.

Os consumíveis continuam escassos e vindos do loot cadenciado da v0.31.

## Equipamentos por nível

Equipamentos passam a respeitar a progressão das oito regiões:

- Tier 0 / Valedouro: nível 1;
- Tier 1 / Floresta: nível 8;
- Tier 2 / Deserto: nível 18;
- Tier 3 / Pântano: nível 28;
- Tier 4 / Montanhas: nível 40;
- Tier 5 / Costas: nível 55;
- Tier 6 / Terras Corrompidas: nível 70;
- Tier 7 / Abismo: nível 85.

Itens raros podem continuar aparecendo no inventário como recompensa, mas só
podem ser equipados ao atingir o nível correspondente.

A Forja também mostra e respeita o requisito de nível, evitando gastar
materiais em uma peça que ainda não pode ser usada.

## Bolsa

A lista e o painel de detalhes passam a mostrar:

- tier;
- nível exigido;
- estado **BLOQUEADO** quando aplicável;
- botão **NÍVEL X** em vez de EQUIPAR enquanto o requisito não for atendido.

O paper-doll da v0.32 e seus sete slots continuam preservados.

## Save

Nenhuma mudança de schema foi necessária. O save permanece **v7** e preserva
loot, consumíveis, campanha, classes, equipamentos e missões.

## Teste nativo

Novo teste:

`game/tests/cartoon_rpg_progression_v033.gd`

Cobre:
- requisitos de nível dos oito tiers;
- bloqueio de crafting antecipado;
- item raro obtido antes do nível;
- desbloqueio e equip após atingir o nível;
- escolha inteligente entre os dois consumíveis;
- botão CURA em 640×360;
- ausência de sobreposição com combate;
- estado bloqueado visível na Bolsa.

## QA visual

`game/tests/qa_capture_rpg_progression_v033.gd`

Gera quatro capturas reais do Godot:

1. HUD mobile com CURA;
2. equipamento Tier 1 bloqueado no nível 1;
3. mesmo equipamento desbloqueado no nível 8;
4. HUD após uso rápido da cura.

## Validação oficial

A v0.33 foi validada no **Godot 4.7.2 oficial** sobre o commit
`4cb032e2012ecfeeb2f0477fe0a158d4b51bb961`.

O Gate oficial concluiu com sucesso no run `36878325954`, incluindo:
- importação/parser;
- **52 testes nativos**;
- QA visual geral;
- QA das oito regiões;
- QA de interiores, castelo, classes, equipamentos, missões, magias e loot;
- QA v0.33 com quatro capturas reais de cura rápida e equipamento bloqueado/desbloqueado.

Artefato visual v0.33: `valedouro-rpg-v033-visual-qa`.

APK continua sob demanda.
