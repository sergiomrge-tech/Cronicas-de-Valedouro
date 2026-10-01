# v0.36 validada — troféus e crafts exclusivos de chefes

A v0.36 continua diretamente da v0.35 validada e transforma chefes principais
em fontes de crafting único.

## Fluxo

A recompensa de chefe passa a seguir este ciclo:

1. derrotar o chefe;
2. receber um material exclusivo daquele boss;
3. a receita correspondente aparece na Forja da região;
4. fabricar a peça usando 1 unidade do troféu;
5. o equipamento permanece no inventário e no save;
6. a receita continua conhecida depois do craft.

Antes da primeira vitória, a receita não aparece na Forja.

## Chefes e materiais

Foram cadastrados 11 chefes da campanha Cartoon:

- Alfa da Matilha — **Presa do Alfa**;
- Guardião de Pedra — **Núcleo do Guardião**;
- Raiz Oca — **Cerne da Raiz Oca**;
- General da Cinza — **Coração de Cinza**;
- Dama dos Juncos — **Coroa de Junco**;
- Capitão do Gelo — **Insígnia do Capitão de Gelo**;
- General da Geada Negra — **Caco de Geada Negra**;
- General da Maré Oca — **Olho da Maré Oca**;
- General do Eco Vazio — **Eco Condensado do Vazio**;
- Cartógrafo do Vazio — **Fragmento Cartográfico**;
- Azharel — **Fragmento de Azharel**.

## Equipamentos exclusivos

Cada material libera uma peça específica. Há armas, elmos, capas, luvas e
botas distribuídos pelos bosses.

Os itens respeitam o requisito de nível do tier regional já introduzido na
v0.33. Portanto, derrotar um boss não remove a cadência de progressão.

Itens de chefe possuem a flag `boss_unique` e **não entram no sorteio de
DROP RARO de monstros comuns**. O único caminho é obter o troféu do boss e
fabricar a receita.

## Identidade visual

As peças de chefe não reutilizam apenas a cor padrão do tier.

O herói aplica:
- paleta própria por item/boss;
- brilho adicional em armas únicas;
- gema/acento no punho das armas de chefe;
- emblema visual em elmos, capas, luvas e botas especiais.

A silhueta-base do slot continua coerente com o personagem Cartoon, mas a
assinatura visual diferencia o item regional comum do item de boss.

## Forja

A Forja sincroniza receitas dinamicamente. Se o jogador derrotar o chefe com
a interface já criada naquela região, a nova receita aparece ao abrir/atualizar
a Forja sem trocar de mapa.

Receitas especiais são marcadas com o prefixo **CHEFE** e informam no tooltip
qual boss originou o material.

## Save

Nenhuma mudança de schema foi necessária. O save permanece **v8** porque os
troféus usam o mesmo dicionário persistente de materiais e os crafts usam o
catálogo já persistido de equipamentos.

## Teste nativo

`game/tests/cartoon_boss_crafting_v036.gd`

Valida:
- 11 boss IDs e 11 recipe IDs únicos;
- hooks de recompensa nas oito regiões;
- receita oculta antes da vitória;
- troféu entregue pela recompensa real de boss;
- receita surgindo dinamicamente na Forja;
- craft e equip;
- item de chefe excluído do drop raro comum;
- persistência de craft/equipamento no save.

## QA visual

`game/tests/qa_capture_boss_crafting_v036.gd`

Gera quatro capturas reais do Godot em 640×360:
1. feedback do troféu de chefe;
2. receita CHEFE revelada na Forja;
3. item especial no paper-doll da Bolsa;
4. item equipado no herói em mundo aberto.

## Validação oficial

A v0.36 foi validada no **Godot 4.7.2 oficial** no commit
`5bca63331caf227e4e66ba9432ab75c7852075f5`.

O Gate oficial concluiu com sucesso no run `36887979521`, incluindo:
- validação estática;
- importação/parser;
- **55 testes nativos**;
- regressões completas das versões anteriores;
- QA visual geral de todas as regiões;
- QA v0.36 com quatro capturas reais do ciclo troféu → Forja → paper-doll → mundo.

Artefato visual: `valedouro-boss-v036-visual-qa`.

APK continua sob demanda.
