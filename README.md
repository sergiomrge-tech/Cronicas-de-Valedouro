# Crônicas de Valedouro — 2D Cartoon

Repositório oficial de desenvolvimento do jogo **Crônicas de Valedouro**.

- Engine: **Godot 4.7.2**
- Alvo principal: **Android / mobile-first**
- Versão oficial atual: **2D Cartoon**
- Cena inicial oficial: `res://scenes/cartoon/CartoonMainMenu.tscn`
- Estado atual: **v0.19**, com save/menu de campanha, inventário RPG, HUD/XP 1–100 e polimento estrutural dos painéis mobile validado por capturas reais.

## Regra de continuidade
A antiga versão visual/pixel-art não é mais a base de desenvolvimento e não deve ser usada para novas alterações. Toda evolução do jogo deve partir da implementação em `game/scenes/cartoon/` e `game/scripts/cartoon/`, preservando história, missões e mecânicas canônicas quando compatíveis.

## Estado da sessão de 30/09/2026
A base 2D Cartoon está na **v0.19**. A v0.16 consolidou save/menu; a v0.17 trouxe o inventário RPG; a v0.18 adicionou HUD e progressão 1–100; e a v0.19 corrige a estrutura visual de menu, opções, confirmação, inventário, forja e zoom com QA visual dedicado.

## Para agentes

Passe visual em revisão: **Cartoon v0.20 candidata**, com 44 sprites originais,
terreno e composição de Valedouro/Ato I. Veja
[o relatório](docs/CARTOON_VISUAL_V0_20.md) e
[o comparador antes/depois](docs/visual_qa/cartoon_v020/review.html).
Validação disponível em Godot 4.6.3; gates 4.7.2/Android ainda pendentes.

Leia primeiro **CLAUDE.md** e **docs/README_CONTINUE_AQUI.md**. Antes de editar, confirme que a cena principal do `project.godot` continua apontando para `CartoonMainMenu.tscn`.

## Validação
Nunca declarar parser/runtime/Android como aprovado sem executar os gates correspondentes no Godot 4.7.2.

Passe de interface em revisão: **v0.21 candidata**, com HUD unificado nas oito regiões,
menu, bolsa, forja, mapas e pausa responsivos. Veja [o relatório](docs/CARTOON_UI_V0_21.md)
e [a comparação visual](docs/visual_qa/cartoon_ui_v021/review.html).

## Continuidade — candidata v0.22: interiores e caça

Solicitação mais recente do Diretor: visual mais rico, interiores da taverna,
ferreiro e guilda, quadro de várias missões e animais de caça. A v0.22 implementa
três interiores jogáveis, sete contratos, duas receitas iniciais, moradores,
33 sprites originais e fauna persistente em seis regiões naturais.
Veja [o relatório](docs/CARTOON_LIVING_WORLD_V0_22.md) e
[a revisão visual](docs/visual_qa/cartoon_v022/review.html).
22 testes passaram no Godot 4.6.3. Godot 4.7.2/Android e aprovação visual
ainda pendentes. Arte MODELED_PENDING_GATE; contratos adicionais PROPOSED.
A base oficial permanece v0.19; os passes v0.20–v0.22 são candidatos locais.

## Continuidade — 01/10/2026: candidata v0.23, Castelo Real

O Diretor pediu um castelo gigantesco, com interior de luxo. A v0.23 substitui
o exterior pequeno por um complexo monumental a nordeste, ligado à cidade e
sem bloquear a estrada da campanha. Possui oito alas exploráveis, rei,
24 sprites originais e mais de 100 elementos decorativos.
Leia [o relatório](docs/CARTOON_ROYAL_CASTLE_V0_23.md) e
[abra a revisão visual](docs/visual_qa/cartoon_v023/review.html).
23 testes passaram em Godot 4.6.3; gates 4.7.2/Android e aprovação visual
permanecem pendentes. Arte MODELED_PENDING_GATE; conteúdo adicional PROPOSED.
Base oficial v0.19; passes v0.20–v0.23 são candidatos em revisão, incluídos no salvamento do código no GitHub solicitado pelo usuário.


## Candidata v0.24 — herói, criaturas e magias

152 quadros do herói, 13 tipos de criaturas animadas, três magias coloridas,
luzes, impactos, recarga e controles mobile. 24 testes locais passaram em
Godot 4.6.3. Build Android executa gates 4.7.2 e publica APK de teste v0.24.
Registro: `docs/CARTOON_COMBAT_V0_24.md`; GIFs/capturas:
`docs/visual_qa/cartoon_v024/review.html`. Arte MODELED_PENDING_GATE;
magias PROPOSED. Aprovação visual e testes no celular ainda pendentes.
A base oficial documentada permanece v0.19, com candidatos até v0.24 em revisão.

## Continuidade — candidata v0.25: combate elemental

Projéteis com impacto real nas oito regiões; Brasa com três pulsos de queimadura,
Cristal com lentidão e Arcana com um salto para outro monstro próximo. Mantém
bloqueios da história, XP, loot e caça. Barra de vida acima do sprite e dicas de
magia atualizadas. Leia `docs/CARTOON_ELEMENTAL_V0_25.md`; capturas reais e GIFs
em `docs/visual_qa/cartoon_v025/review.html`. 25 testes passaram localmente no
Godot 4.6.3; workflow Android executa a suíte em 4.7.2 e publica v0.25-test.
Arte MODELED_PENDING_GATE; mecânicas PROPOSED; teste em aparelho real e
aprovação visual pendentes. A base oficial documentada continua v0.19.

## Continuidade — candidata v0.26: esquiva e avisos de ataque

O herói ganha esquiva de 120 unidades com rastro azul, proteção curta e recarga.
Monstros das oito regiões avisam antes de atacar; chefes têm aviso mais longo
e área maior. Movimento respeita a geometria existente. HUD touch sem
sobreposição, incluindo painel de missão expandido. Leia
`docs/CARTOON_REACTIVE_V0_26.md`; GIFs/capturas reais em
`docs/visual_qa/cartoon_v026/review.html`. 26 testes passaram em Godot 4.6.3;
workflow Android executa a suíte oficial 4.7.2 e publica v0.26-test. Arte
MODELED_PENDING_GATE, novas mecânicas PROPOSED; aprovação visual e teste em
aparelho real pendentes. Base oficial documentada continua v0.19.

## Continuidade — candidata v0.27: classes e habilidades

Pedido explícito do Diretor: trocar de classe e evoluir habilidades. Substitui
a restrição anterior de não utilizar classes. Um protagonista, três
especializações trocáveis (Guerreiro, Mago, Caçador), nove habilidades de dez
graus, um ponto inicial +1 por nível, requisitos de nível e reembolso por
classe. Toque no retrato do herói ou pressione C. Save v4 migra os anteriores
sem perder campanha; só a classe ativa aplica bônus. Leia
`docs/CARTOON_CLASSES_V0_27.md`; revisão em
`docs/visual_qa/cartoon_v027/review.html`. 27 testes passaram em Godot 4.6.3;
workflow oficial 4.7.2 executa testes e novas capturas, e Android publica
v0.27-test. Balanceamento PROPOSED, arte MODELED_PENDING_GATE e teste em
aparelho real pendente; base oficial documentada continua v0.19.


## Continuidade — candidata v0.31: loot e consumíveis

Loot cadenciado nas oito regiões, dois consumíveis de cura, drops raros de
equipamento por região e contador de piedade persistente para evitar azar
extremo sem acelerar o power curve. Save v7 preserva a v0.30. A Bolsa recebe
a aba ITENS. Teste e QA visual dedicados entram no Godot Gate 4.7.2.
Leia `docs/CARTOON_LOOT_V0_31.md`. Nenhum APK automático.
