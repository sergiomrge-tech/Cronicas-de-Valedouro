# CONTINUE AQUI — Crônicas de Valedouro 2D Cartoon

## APK v0.42 solicitado — 02/10/2026

O Diretor pediu explicitamente gerar APK após a conclusão da v0.42. Runtime
permanece o validado; não há novo passe de arte neste pedido. Workflow Android
passa a incluir o teste v0.42 e verifica recursos reais do APK, versão 42,
assinatura, ARM32/64, CRC e checksum. Entrega prevista: artifact ZIP plano com
APK, SHA256, metadados e instruções. Build ainda não executada neste checkpoint.
Automação anterior continua desativada; gerar APK apenas por pedido explícito.


## Conclusão verificada — v0.42 (02/10/2026)

Passe concluído: herói/armas/efeitos ilustrados e decoração/paredes/piso dos
interiores de taverna, ferreiro e guilda. Originais v0.41/v0.40 intactos.
Código/assets: `740f06d66790e9bfb3e6fd7df8781ee0bbf6f893`.
Ajuste de artifact compacto: `665fbf13626060de4c7b9448389ba600613f78ab`, com a
mesma árvore `game` do runtime. Godot Gate oficial **4.7.2**:
[run 36979976422](https://github.com/sergiomrge-tech/Cronicas-de-Valedouro/actions/runs/36979976422)
**SUCCESS**, 60 testes nativos, 240 apoios de poses e 155 capturas. Gate anterior
36978863902 também aprovado. Local: 43 testes, captura final e pacote de recursos PASS.

Comparação visual executada com originais e cenas reais em 960×540/640×360,
zoom70/150 e oito estados de animação. Diferenças concretas e correções no
relatório; não foi encerrado só por PASS técnico. Revisão compacta oficial
baixada (83 arquivos, 27.793.888 bytes) e conferida; amostras oficiais e hashes
salvos em `docs/visual_qa/cartoon_v042`. Max draw calls 492. Pequenas diferenças
de antialiasing de linhas entre 4.6.3/4.7.2 não alteraram a integração da pintura.

Mantidos campanha/IDs, colisões, nível/dificuldade, classes/equipamentos/arco,
HUD radial opção 3, save v8 e três recargas independentes. Nenhum APK.
Automação **Continuar Crônicas de Valedouro desativada**, retorno da ferramenta
confirmado por consulta. Não há pendência deste passe. Teste físico Android e
aprovação pessoal do Diretor não foram alegados; próximo desenvolvimento deve
seguir um novo pedido, sem repetir v0.41/v0.42.



**Diretor:** Sergio  
**Mundo:** Elyndor  
**Engine:** Godot 4.7.2  
**Base oficial validada:** 2D Cartoon v0.42<br>
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


## Continuidade — candidata v0.29: missões e desafio

A pedido do Diretor: aba MISSÕES/J com Ativas, Disponíveis e Concluídas,
escolha persistente do objetivo no HUD/mapa, 48 demônios de três visuais,
avisos de magia e retorno de 600 s. Inimigos e fauna com níveis regionais
fixos e penalidade forte contra níveis superiores. Combate e XP mais
exigentes; viagens não concedem níveis/cura. Save v6 preserva a campanha.
31 testes Cartoon locais passaram; CI acrescenta três testes e 21 capturas
no Godot oficial 4.7.2. Leia `docs/CARTOON_MISSIONS_CHALLENGE_V0_29.md` e
`docs/visual_qa/cartoon_v029/review.html`. Arte MODELED_PENDING_GATE;
balanceamento PROPOSED. Não gerar APK sem pedido explícito.


## Preferência de entrega de APK — 01/10/2026

Gerar APK somente mediante pedido explícito. Quando solicitado, entregar um
ZIP com APK atualizado e SHA256 como anexo nativo na conversa, para baixar
neste ambiente. O link externo do GitHub não é a entrega principal: o download
do APK ficou travado em 100% no navegador do celular. Salvar apenas em
`/workspace` não envia o arquivo ao usuário. Só afirmar entrega depois de
disponibilizar o anexo real; se a ferramenta de anexo estiver indisponível,
informar a limitação. Instrução breve ao usuário: Meus Arquivos → Downloads →
extrair ZIP → abrir APK.

Neste ambiente, a ferramenta GitHub `download_workflow_artifact` baixa o
artefato ZIP da build e retorna uma referência de arquivo nativa (`file_id`).
Usar a referência retornada para o anexo; nunca inventar IDs nem reutilizar
URLs temporárias expiradas. O artefato Android já inclui APK e SHA256.


## Continuidade — candidata v0.30: três magias independentes

A pedido do Diretor: Brasa, Cristal e Arcana juntas no HUD, três botões
coloridos, três recargas independentes (3 s, Foco reduz até 2,2 s), teclas
1/2/3 e compatibilidade Q/R. HUD touch sem sobreposição. Save v6 e efeitos
elementais preservados. 32 testes Cartoon locais passaram; CI inclui
49 testes oficiais e oito capturas novas. Ler
`docs/CARTOON_SPELL_SLOTS_V0_30.md` e
`docs/visual_qa/cartoon_v030/review.html`. Mecânica PROPOSED. Sem novo APK;
exportação somente mediante pedido, entrega em ZIP anexado à conversa.


## APK solicitado — v0.30

O Diretor pediu explicitamente a exportação da candidata v0.30, com três
magias simultâneas no HUD e recargas independentes. Preset Android versão
30 / 0.30-test; pipeline valida 32 testes Cartoon, assinatura e SHA256.
Entregar o ZIP do artefato como anexo nativo. Se o navegador salvar o anexo
como `content` sem extensão, orientar renomear para `Valedouro.zip` antes
de extrair e abrir o APK. Isso foi observado no celular do Diretor.
Continua proibido gerar APK automaticamente a cada alteração.


## Continuidade — candidata v0.31: loot cadenciado e consumíveis

A evolução atual parte da candidata v0.30. A v0.31 conecta loot controlado às
oito regiões e aos demônios de elite, adiciona Frasco de Cura e Elixir
Restaurador, aba ITENS na Bolsa, drops raros de equipamento e pity persistente.
Save v7 migra a campanha anterior. Leia `docs/CARTOON_LOOT_V0_31.md`.
A candidata deve passar pelo Godot 4.7.2 Gate antes de ser tratada como
validada. Não gerar APK automaticamente.


## Continuidade — v0.32 validada: progressão e interface RPG

A regra da v0.30 de três magias disponíveis desde o início foi **substituída**
por decisão do Diretor: Brasa no nível 1, Cristal no nível 10 e Arcana no
nível 25. Não restaurar as três magias iniciais.

A Bolsa passa a exibir ouro e paper-doll do mesmo herói Cartoon, com slots de
arma, elmo, peitoral, luvas, capa, calças e botas. O HUD e os avisos foram
compactados. O Diário de Missões deve permitir rolagem vertical por toque e
mostrar barra de scroll quando houver conteúdo abaixo.

A v0.32 inclui a v0.31 de loot/consumíveis. Ler
`CARTOON_UI_PROGRESSION_V0_32.md` e `CARTOON_LOOT_V0_31.md`.
Validada no Godot 4.7.2 oficial no commit `26108ab8`, run `36868571315`, com parser/import, 51 testes nativos e QA visual. APK continua sob demanda.


## Retomada — v0.32 validada, sem APK

Retomada solicitada pelo Diretor a partir do GitHub, commit `f69405c`.
Sincronizadas as v0.31/v0.32 já implementadas: loot e poções, save v7,
magias em níveis 1/10/25, ouro e personagem na bolsa, missões roláveis.
Corrigida a sobreposição de avisos com magias em 800×450 e com interação
em textos de loot longos. 34 testes Cartoon locais passaram; CI verifica
51 testes e QA oficial. Ler `docs/CARTOON_UI_PROGRESSION_V0_32.md` e
`docs/visual_qa/cartoon_v032/review.html`. Não gerar APK nesta retomada.


## Continuidade — v0.33 validada: cura rápida e equipamentos por nível

A v0.33 adiciona botão CURA no HUD mobile, uso inteligente de Frasco/Elixir e
requisitos de nível para equipamentos dos oito tiers (1/8/18/28/40/55/70/85).
Itens raros podem ser obtidos antes do nível, mas ficam bloqueados na Bolsa;
a Forja também respeita o requisito. Save permanece v7. Ler
`docs/CARTOON_RPG_PROGRESSION_V0_33.md`. Validada no Godot 4.7.2 oficial no commit `4cb032e2`, run `36878325954`, com 52 testes nativos e QA visual. APK continua sob demanda.


## Continuidade — v0.34 validada: coleta de materiais no mapa

A v0.34 adiciona 48 novos pontos renováveis de coleta, seis por região, e
converte os 7 pontos especiais de recurso já existentes para a mesma lógica,
totalizando 55 pontos coletáveis. A interação usa o botão USAR e mostra
COLETAR no HUD. O recurso entra diretamente na Bolsa/Forja e reaparece em
5 minutos. O cooldown persiste no **save v8**. Ler
`docs/CARTOON_GATHERING_V0_34.md`. Validada no Godot 4.7.2 oficial no commit `ed2b1173`, run `36883480977`, com 53 testes nativos e QA visual. APK continua sob demanda.


## Continuidade — v0.35 validada: level up e desbloqueios compactos

A v0.35 adiciona banner curto de subida de nível, aviso automático de magia/tier
liberado e contador de pontos de habilidade no retrato do herói. Não usa modal
e não interrompe o combate. O save permanece v8. Ler
`docs/CARTOON_LEVELUP_FEEDBACK_V0_35.md`. Validada no Godot 4.7.2 oficial no commit `e90330ba`, run `36885539172`, com 54 testes nativos e QA visual. APK continua sob demanda.


## Continuidade — v0.36 validada: troféus e crafts de chefes

A v0.36 adiciona 11 materiais exclusivos de chefes e 11 receitas especiais que
só aparecem após a primeira obtenção do troféu correspondente. Itens de boss
não entram no DROP RARO comum, respeitam os níveis regionais e recebem paleta,
brilho/emblema próprios no herói. Save permanece v8. Ler
`docs/CARTOON_BOSS_CRAFTING_V0_36.md`. Validada no Godot 4.7.2 oficial no commit `5bca6333`, run `36887979521`, com 55 testes nativos e QA visual. APK continua sob demanda.


## Continuidade — v0.37 validada: combate de chefes em fases

A v0.37 adiciona barra dedicada de boss no HUD, três fases automáticas por HP e
golpes especiais periódicos com telegráfico ampliado e dano escalonado nas
Fases II/III. Monstros comuns preservam o comportamento anterior. Save
permanece v8. Ler `docs/CARTOON_BOSS_COMBAT_V0_37.md`. Validada no Godot 4.7.2 oficial no commit `4fb27216`, run `36891829409`, com 56 testes nativos e QA visual. APK continua sob demanda.

## Continuidade — candidata v0.38: opção 3, Combate Radial

Diretor escolheu o HUD 3, pediu comparação com a imagem e extensão do visual a
todas as interfaces. Implementação e validação em
[CARTOON_RADIAL_UI_V0_38.md](CARTOON_RADIAL_UI_V0_38.md); referência e capturas reais
em [revisão visual](visual_qa/cartoon_v038/review.html).

40 testes Cartoon locais passaram. CI executa 57 testes e 30 novas capturas;
Android executa os 40 testes e exporta v0.38. A geração deste APK foi autorizada
explicitamente. Entregar ZIP nativo contendo APK+SHA256, com a orientação de
renomear `content` para `Valedouro.zip` caso o Android omita o nome do arquivo.

## Continuidade — v0.39: correção de flutuação

Diretor relatou herói e algumas casas flutuando. Apoio das botas compensado
por quadro, sombra no contato com o terreno, fundações e sombras das casas
alinhadas. Ler `docs/CARTOON_GROUNDING_V0_39.md`; seis capturas em
`docs/visual_qa/cartoon_v039/review.html`. Verificação renderizada de 208 poses
em pé aprovada localmente; CI repete em 4.7.2. Não gerar APK neste pedido.

## Continuidade — v0.40: arquitetura e cidade otimizada

Diretor pediu construções variadas e melhor desempenho na cidade. Atlas de 12
modelos com fundações ancoradas, piso estático em cache e retrato da Bolsa
suspenso quando fechado. Ler `docs/CARTOON_CITY_V0_40.md`; galeria e capturas
em `docs/visual_qa/cartoon_v040/review.html`. Medição local na praça: 24910 → 308
chamadas e 189,4 → 19,2 ms por quadro (Godot 4.6.3 / llvmpipe, não celular).
CI executa 58 testes oficiais, 12 contatos renderizados e orçamento de desenho.
Android futuro v0.40 sob demanda; não gerar APK neste pedido. Save permanece v8.
Pesquisa de skills procedurais em `docs/PROCEDURAL_2D_SKILL_RESEARCH.md`: recomendar
`godot-procedural-generation`, com `godot-procedural-worlds` como complemento;
nenhuma skill externa instalada e nenhuma migração do mapa nesta pesquisa.

## Continuidade — v0.41: área piloto viva e ilustrada

Diretor aceitou manter Godot e começar por praça, rua e saída norte. Novo
terreno, oito elementos de natureza, oito moradores, 16 poses humanas e 18
poses de criaturas. Vegetação restaurada nos chunks junto à cidade. Encontros
determinísticos nos arredores (18 ativos, pool 24, retorno de cinco minutos
persistido em save v8), preservando missões, dificuldade e HUD radial 3.
Ler `docs/CARTOON_PILOT_V0_41.md`; comparação real em
`docs/visual_qa/cartoon_v041/review.html`. 42 testes Cartoon locais e pacote de
recursos verificados; CI oficial executa 59 testes e QA ao publicar. Não gerar
APK neste pedido. Próximo passe visual: herói/efeitos e interiores.
