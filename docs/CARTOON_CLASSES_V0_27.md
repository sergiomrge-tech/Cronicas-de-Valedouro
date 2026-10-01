# Cartoon v0.27 — classes trocáveis e evolução de habilidades

Solicitação explícita do Diretor em 01/10/2026: permitir trocar de classe e evoluir habilidades. Essa direção substitui a restrição anterior de não usar classes; permanece um único protagonista, com identidade, equipamentos, quests e campanha preservados. Nomes/balanceamento adicionais **PROPOSED**; arte reutilizada **MODELED_PENDING_GATE**.

## Acesso e troca

Toque no retrato do herói no HUD ou pressione C. A tela possui abas CLASSES e HABILIDADES, rolagem touch, pontos disponíveis e ações de evolução. ESC/C/× fecha. O mundo e ataques param enquanto ela está aberta. Funciona nas oito regiões, inclusive com acesso pelo HUD em interiores; outros modais precisam ser fechados primeiro.

Guerreiro (padrão), Mago e Caçador podem ser alternados gratuitamente. Só as habilidades da classe ativa concedem bônus. Vida, XP, ouro, equipamentos, missão e recargas em andamento não são reiniciados. Graus de cada classe permanecem salvos, mesmo quando inativa. O HUD mostra região/classe; um anel sutil no herói usa dourado, violeta ou verde conforme a classe.

## Evolução

Um ponto inicial e mais um por nível ganho: o total disponível é o nível atual menos os graus aprendidos em todas as classes. Derivar esse valor impede duplicar pontos ao trocar classe, recarregar ou reembolsar. Jogadores antigos recebem automaticamente os pontos correspondentes ao nível salvo.

Cada uma das nove habilidades tem dez graus; cada evolução custa um ponto. Níveis mínimos por grau: **1, 3, 5, 8, 12, 18, 25, 35, 50, 70**. Botões mostram EVOLUIR, NÍVEL exigido, SEM PONTOS ou MÁXIMO. Barras mostram o grau aprendido. REEMBOLSAR devolve somente os pontos da classe ativa; repetir não gera pontos extras. As outras classes mantêm seus graus.

| Classe | Habilidade | Efeito por grau |
| --- | --- | --- |
| Guerreiro | Lâmina treinada | +4% de dano da espada |
| Guerreiro | Guarda firme | -2% de dano recebido depois da defesa do equipamento; mínimo de um ponto de dano |
| Guerreiro | Passos de batalha | -0,06 s na recarga da esquiva; mínimo de 1,6 s |
| Mago | Afinidade mágica | +4% de dano mágico |
| Mago | Concentração | -0,08 s na recarga das magias; mínimo de 2,2 s |
| Mago | Domínio elemental | +1 ponto percentual do dano equipado mágico por pulso de Brasa, +0,1 s de lentidão de Cristal, +5 unidades no salto de Arcana |
| Caçador | Caça precisa | +6% de dano contra animais de caça |
| Caçador | Instinto ágil | +4 unidades de distância da esquiva; até 160 unidades |
| Caçador | Olhar atento | +4 unidades de alcance mágico; até 260 unidades |

Danos são arredondados para inteiros; limites de equipamentos e recompensas continuam os existentes. Sem habilidades treinadas, todas as classes preservam os valores anteriores. Não adiciona um arco, arma exclusiva ou nova animação de arma: Caçador especializa a caça e mobilidade com o equipamento existente.

Projéteis capturam dano, elemento, duração de lentidão e alcance do salto no lançamento; mudar a classe durante o voo não reescreve seus efeitos. A distância da esquiva também é capturada ao iniciar. Mantém uma única cadeia de Arcana, três pulsos de Brasa, os bloqueios por missão e a entrega única de XP/loot/caça.

## Save e compatibilidade

Save v4, no mesmo arquivo da campanha, com `active_class` e `skill_ranks`. Saves v1–v3 mantêm os demais campos e começam como Guerreiro sem graus treinados. Dados inválidos são normalizados: IDs desconhecidos ignorados, classe inválida volta a Guerreiro, graus negativos/não numéricos ignorados, cap de dez, requisitos de nível e orçamento global aplicados em ordem determinística. Novo jogo limpa classe e graus.

## Provas e APK

27 testes locais passaram em Godot 4.6.3. `cartoon_classes_v027.gd` cobre classe ativa/inativa, XP e pontos, requisitos, limites, reembolso idempotente, save/reload, migração v3, dados inválidos, bônus reais de combate, efeitos capturados no projétil, toque nativo no retrato e painel sem clipping em quatro resoluções. A suíte mantém campanha, oito regiões, inventário, crafting, caça, magia, esquiva, interiores e castelo. O teste antigo de HUD foi atualizado para exigir o novo nome de classe no cabeçalho.

Capturas reais e revisão interativa autossuficiente em `docs/visual_qa/cartoon_v027/review.html`. O script `qa_capture_classes_v027.gd` também é executado no workflow oficial 4.7.2, publicando oito capturas como artifact. Perfis de nível 20 com graus de exemplo são configurações de QA, sem alteração da campanha.

APK configurado: `v0.27-test`, versionCode 27, versionName 0.27-test, Android 7.0+, ARM 32/64 bits, pacote `com.sergiomrge.cronicasvaledouro.test`. Workflow Android executa os 27 testes, exporta e verifica a assinatura antes de publicar o download direto. Resultados efetivos permanecem nos runs do GitHub Actions. Aprovação visual, balanceamento e desempenho/ergonomia em celular real ainda pendentes. Base oficial documentada permanece v0.19; candidata executável atual v0.27.
