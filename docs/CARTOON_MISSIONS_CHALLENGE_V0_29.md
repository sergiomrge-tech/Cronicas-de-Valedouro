# Candidata v0.29 — missões, demônios e dificuldade por nível

Pedidos do Diretor: selecionar uma missão para seguir, povoar os mapas com
demônios poderosos, tornar a evolução exigente e fazer inimigos acima do nível
do herói extremamente difíceis.

## Missões

Botão MISSÕES no painel de objetivo ou tecla J. Abas Ativas, Disponíveis e
Concluídas, rolagem e controles adaptados a 640×360. Acompanhamento selecionável
para história ou contrato aceito; HUD mostra progresso e direção/distância,
e o mapa marca a área de caça ou a guilda quando a entrega está pronta.
Contratos disponíveis continuam sendo aceitos/recompensados no quadro da
guilda. A seleção não avança a história nem entrega recompensas. Ao concluir
o contrato acompanhado, o foco retorna à história. Save v6 preserva a seleção,
IDs, inventário, classes, talentos e todo o progresso anterior.

## Níveis e desafio

Níveis fixos por região; não sobem automaticamente com o herói. A fauna usa o
nível base, monstros comuns base +0 a +2, chefes base +6 e demônios base +8.
O nível aparece acima dos inimigos: branco no nível do herói ou abaixo,
amarelo acima, vermelho com diferença maior que quatro.

| Região | Monstros comuns | Chefes | Demônios |
| --- | --- | --- | --- |
| Valedouro | 1–3 | 7 | 9 |
| Floresta | 8–10 | 14 | 16 |
| Deserto | 18–20 | 24 | 26 |
| Pântanos | 28–30 | 34 | 36 |
| Montanhas | 40–42 | 46 | 48 |
| Costas | 55–57 | 61 | 63 |
| Terras Corrompidas | 70–72 | 76 | 78 |
| Coração Abissal | 85–87 | 91 | 93 |

Invasores do cerco usam níveis 45–47. Os demônios selvagens de Valedouro
continuam presentes durante o cerco, com seus níveis e recompensas próprios.

Para diferença positiva `d = nível do inimigo − nível do herói`:

- Dano causado: multiplicador `max(0,035; 1 / (1 + 0,30d + 0,05d²))`.
- Dano recebido: multiplicador `min(5; 1 + 0,12d + 0,018d²)`, antes da defesa.
- Mesmos níveis ou inimigos mais fracos: multiplicador 1. Dano mínimo 1.

Com +5 níveis, o herói causa aproximadamente 27% e recebe 2,05× o dano.
Com +10, causa aproximadamente 11% e recebe 4×. A regra vale para ataques,
flechas, impacto elemental, queimadura, caça, contato e magia dos demônios.

Monstros comuns têm 60% mais vida, 35% mais dano e 8% mais velocidade;
chefes recebem 25% mais vida e 20% mais dano. Caça: coelho 36 HP, cervo 64,
javali 98 e contato 14. Ataques físicos com espada têm intervalo de 0,38 s.

XP para o próximo nível: `120 + 60L + 8L²`, máximo 100. O primeiro nível agora
exige 188 XP (antes 63). XP de combate depende do inimigo, não do nível do
herói: base regional +2 por nível acima de 1, multiplicado por três para
chefes. Trocar de mapa não concede nível, vida máxima ou cura gratuitos.
Níveis e XP já conquistados em saves anteriores permanecem preservados.

## Demônios

Seis posições persistentes em cada uma das oito regiões, 48 no total, longe
da cidade, pontos de interesse e entrada. Carrasco Rubro, Devorador Abissal e
Sentinela da Ruína usam três folhas originais, seis quadros cada, cores,
chamas, runas, armaduras e olhos distintos. Triângulos rosa identificam os
vivos no mapa.

Vida `220 + 105t`, contato `24 + 8t`, com `t` de 0 a 7 por região. Ataque
mágico marca o local do herói por 1,05 s antes da explosão, sem perseguir
sua nova posição; esquiva ou sair da área evita dano. Recarga de 4 s.
Contato avisa por 0,75 s. Resistência maior a lentidão, limite de perseguição
e recuperação total após 5 s de afastamento evitam arrastá-los pela cidade.

Recompensa única por morte: `35 + 8t` ouro e `80 + 30t + 10 × nível` XP.
Retorno após 600 s, persistido no save; não reaparecem sobre o herói.
Não contam como chefes canônicos, objetivos de história ou caça de lobos.

## Validação

31 testes Cartoon locais passaram no Godot 4.6.3. Três testes novos cobrem
seleção, persistência/migração, HUD/mapa, entrega sem duplicação, interface
touch em quatro tamanhos, os 48 demônios, locais seguros, magia anunciada,
esquiva, pausa, recuperação, recompensas e retorno persistente, níveis
regionais e do cerco, dano físico/mágico/fauna e diferença de níveis.
A CI executa os 48 testes nativos no engine oficial Godot 4.7.2 e captura
21 telas reais adicionais. [Revisão visual](visual_qa/cartoon_v029/review.html).

Arte **MODELED_PENDING_GATE**; balanceamento **PROPOSED**, candidato à
avaliação do Diretor. Teste em celular físico e aprovação visual pendentes.
Nenhum APK foi criado; exportação Android somente mediante pedido explícito.
