# Cartoon v0.25 — combate elemental

Evolução da candidata v0.24. Mecânicas adicionais **PROPOSED**, arte reutilizada **MODELED_PENDING_GATE**; a base oficial documentada permanece v0.19. Preserva cânone, IDs, quests e versão do save.

## Magias

| Magia | Impacto | Efeito adicional |
| --- | --- | --- |
| Brasa | 100% do ataque equipado | Três pulsos de 10%, a cada 0,6 s; mínimo de um ponto por pulso |
| Cristal | 100% | Lentidão por 2,5 s: 45% em criaturas comuns, 20% em chefes |
| Arcana | 125% | Um projétil secundário com 50% do dano primário, para um monstro elegível em até 110 unidades |

Valores arredondados para inteiros. Alcance primário de 220 unidades; velocidade de 420 unidades/s; recarga compartilhada de 3 s. Brasa renova a queimadura sem empilhar seus pulsos; Cristal renova a duração e restaura a velocidade original ao expirar. Arcana nunca gera uma cadeia recursiva. Trocar a seleção durante o voo preserva o elemento e dano capturados no lançamento.

O dano acontece quando o projétil chega ao alvo. Nas oito regiões, impacto e queimadura percorrem o mesmo método de dano, bloqueios por missão, XP, loot e recompensas da espada. Caça mantém materiais, contratos e cooldowns persistentes. Alvos mortos não concedem recompensa novamente.

Construções e obstáculos sólidos de Valedouro bloqueiam a linha de visão; água aberta não bloqueia. O voo reavalia obstáculos até o impacto. Regiões sem a geometria `blocks_spell` mantêm seu comportamento anterior, sem uma nova colisão artificial.

## Apresentação e limites

Projéteis carregam as luzes e partículas até o alvo; impacto colorido, chamas e flocos mostram o efeito ativo. A barra de vida fica acima do sprite do monstro. Tooltips e seleção explicam o efeito de cada magia. Q/MAGIA conjura; R/TROCAR alterna.

Até 16 projéteis/queimaduras simultâneos, com referências fracas a região e alvo. Voo expira em 1,4 s; queimadura em 1,8 s após impacto. Mantém o limite de 48 FX e oito luzes. Modais suspendem voo/efeitos de estado; pausa suspende a árvore; entrar em construção, derrota, alvo removido e mudança de região cancelam os projéteis pendentes.

## Validação

25 testes executados com sucesso no Godot 4.6.3 local. O novo `cartoon_elemental_v025.gd` verifica impacto atrasado, elemento capturado, recompensa única por queimadura, restauração de velocidade, resistência de chefes, salto único, obstáculo real da forja, pausa, entrada em interiores, caça e bloqueios da história. A suíte cobre oito regiões, campanha, save, inventário, crafting, HUD e interiores/castelo.

GIFs e PNGs foram capturados diretamente na região jogável, com passos determinísticos de 50 ms e alvos posicionados para revisão; não representam uma medida de desempenho. Revisão autossuficiente em `docs/visual_qa/cartoon_v025/review.html`; script `game/tests/qa_capture_elemental_v025.gd`.

Exportação Android configurada para Godot 4.7.2, 25 testes nativos, assinatura e publicação da pré-versão `v0.25-test`: versionCode 25, versionName 0.25-test, Android 7.0+, ARM 32/64 bits, pacote `com.sergiomrge.cronicasvaledouro.test`. Os resultados efetivos do workflow ficam registrados no GitHub Actions. Aprovação visual e teste de desempenho/ergonomia em aparelho real permanecem pendentes.
