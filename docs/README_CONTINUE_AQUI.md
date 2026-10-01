# CONTINUE AQUI — Crônicas de Valedouro 2D Cartoon

**Diretor:** Sergio  
**Mundo:** Elyndor  
**Engine:** Godot 4.7.2  
**Base oficial atual:** 2D Cartoon v0.19  
**Cena inicial:** `res://scenes/cartoon/CartoonMainMenu.tscn`

## ATENÇÃO
A antiga versão visual/pixel-art não é mais a versão de trabalho. Não continuar desenvolvimento a partir dela. Use exclusivamente a arquitetura Cartoon como base das próximas alterações.

## Cânone essencial
Elyndor vive a Guerra da Coroa Oca há 23 anos. O protagonista é um humano da Terra e o Segundo Viajante. Ele precisa reunir os Sete Sigilos, apoiar as Seis Coroas, derrotar Azharel e usar o Coração do Limiar para voltar à Terra. Azharel foi Adrian Vale, o Primeiro Viajante.

## Direção atual
- Action RPG 2D Cartoon top-down para Android/celular.
- Um protagonista com classes trocáveis e habilidades evolutivas, conforme pedido do Diretor em 01/10/2026.
- Progressão planejada do nível 1 ao 100.
- Mundo aberto por regiões, com exploração, bosses, materiais, loot e crafting.
- Áreas e construções do mapa devem corresponder às missões da história.
- Regiões devem ter escala de exploração real, evitando mapas curtos demais.
- Interface deve ser adequada para touch e manter boa leitura em tela pequena.
- Não criar APK a cada atualização. Continuar desenvolvimento e salvamento no GitHub com validações; gerar APK apenas mediante pedido explícito do Diretor (orientação de 01/10/2026, após a v0.27).

## Estrutura Cartoon
- Cenas: `game/scenes/cartoon/`
- Scripts: `game/scripts/cartoon/`
- Menu: `CartoonMainMenu.tscn` + `cartoon_main_menu.gd`
- Estado/save: `cartoon_player_state.gd`
- Inventário: `cartoon_inventory_ui.gd`
- Crafting: `cartoon_crafting_ui.gd`
- Zoom: `cartoon_zoom_controls.gd`
- Story runtime/mapa principal: scripts `cartoon_*` correspondentes.

## Checkpoint da sessão — 30/09/2026
A versão Cartoon é a única base ativa. A **v0.16** adicionou save/menu; a **v0.17** adicionou inventário RPG; a **v0.18** adicionou HUD e progressão 1–100; a **v0.19** corrige estruturalmente os painéis mobile e adiciona QA visual específico de interface. Próxima prioridade: loot/consumíveis, feedback de combate e refinamento de ergonomia touch.

## Regra para agentes
Se encontrar documentação antiga falando em “v0.6.x pixel art”, “REG_001 como versão atual” ou equivalente, trate-a como histórico e não como estado corrente. Não ressuscitar a implementação antiga.

## Trabalho atual — candidata visual v0.20

A pedido do Diretor, a prioridade mudou para assets, sprites, terreno e level
design. A candidata v0.20 integra 44 sprites Cartoon originais, nova composição
da cidade e dos marcos do Ato I, acessos viários e ordenação de vegetação por Y.
Leia `docs/CARTOON_VISUAL_V0_20.md` e abra o comparador
`docs/visual_qa/cartoon_v020/review.html`. Os 20 testes da campanha passaram no
Godot 4.6.3 disponível; Godot 4.7.2/Android e aprovação visual estão pendentes.
Arte permanece **MODELED_PENDING_GATE**; não apresentar como release aprovada.

## Continuidade — candidata de interface v0.21

O Diretor também pediu o ajuste completo do layout e HUD. A v0.21 unifica a
interface nas oito regiões Cartoon e reformula menu, inventário, forja, mapas,
pausa e escolha final. Leia `docs/CARTOON_UI_V0_21.md`; QA em
`docs/visual_qa/cartoon_ui_v021/review.html`. Os 21 testes passaram em Godot
4.6.3; validação oficial 4.7.2 e testes Android continuam pendentes.
A base oficial continua v0.19, com arte v0.20 e interface v0.21 candidatas.

## Continuidade — candidata v0.22: interiores e caça

Solicitação mais recente do Diretor: visual mais rico, interiores da taverna,
ferreiro e guilda, quadro de várias missões e animais de caça. A v0.22 implementa
três interiores jogáveis, sete contratos, duas receitas iniciais, moradores,
33 sprites originais e fauna persistente em seis regiões naturais.
Veja [o relatório](CARTOON_LIVING_WORLD_V0_22.md) e
[a revisão visual](visual_qa/cartoon_v022/review.html).
22 testes passaram no Godot 4.6.3. Godot 4.7.2/Android e aprovação visual
ainda pendentes. Arte MODELED_PENDING_GATE; contratos adicionais PROPOSED.
A base oficial permanece v0.19; os passes v0.20–v0.22 são candidatos locais.

## Continuidade — 01/10/2026: candidata v0.23, Castelo Real

O Diretor pediu um castelo gigantesco, com interior de luxo. A v0.23 substitui
o exterior pequeno por um complexo monumental a nordeste, ligado à cidade e
sem bloquear a estrada da campanha. Possui oito alas exploráveis, rei,
24 sprites originais e mais de 100 elementos decorativos.
Leia [o relatório](CARTOON_ROYAL_CASTLE_V0_23.md) e
[abra a revisão visual](visual_qa/cartoon_v023/review.html).
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

## Continuidade — 01/10/2026: candidata v0.28, equipamentos e herói

64 receitas (espada/arco + seis peças nas oito regiões), conjuntos completos
com bônus, sete posições na bolsa, comparação por peça, forja rolável e compra
de material. Arco com flechas em voo e combate/caça nas oito regiões. Save v5
migra o progresso anterior. Herói com 32 folhas/240 quadros originais, disparo,
esquiva, rosto/metais/roupas refinados e equipamento visível. 28 testes Cartoon
passaram localmente; CI inclui teste e QA no engine oficial.
Leia [o relatório](CARTOON_EQUIPMENT_V0_28.md) e
[a revisão visual](visual_qa/cartoon_v028/review.html).
Arte MODELED_PENDING_GATE; mecânicas adicionais PROPOSED.
Não gerar APK sem pedido explícito do Diretor.
