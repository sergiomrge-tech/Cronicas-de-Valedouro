# v0.35 validada — level up e desbloqueios compactos

A v0.35 continua diretamente da v0.34 validada e melhora a sensação de
progressão sem abrir modais ou cobrir a ação no celular.

## Banner de level up

Quando o personagem sobe de nível, aparece um aviso curto no topo central:

`NÍVEL X • +N ponto(s)`

A segunda linha mostra o desbloqueio mais importante daquele salto. Se não
houver novo conteúdo, informa que existe habilidade pronta para evoluir.

O banner dura cerca de 4 segundos, não captura toque e substitui
temporariamente o resumo da Guilda naquela faixa para evitar sobreposição.

## Desbloqueios informados

O sistema reconhece automaticamente:

- nível 8 — equipamentos da Floresta Ancestral;
- nível 10 — magia Cristal;
- nível 18 — equipamentos do Deserto e Ruínas;
- nível 25 — magia Arcana;
- níveis 28/40/55/70/85 — tiers seguintes de equipamento.

Se um ganho de XP atravessar vários níveis, o aviso resume o salto e mantém
todos os desbloqueios disponíveis no tooltip.

## Pontos de habilidade

O retrato do herói no HUD agora mostra um pequeno contador:

`+N PT`

quando existem pontos de habilidade não gastos. Com zero pontos, volta a
mostrar `HERÓI`.

Tocar no retrato continua abrindo Classes e Habilidades.

## API de progressão

`gain_xp()` passa a retornar também:

- `previous_level`;
- `unlocks`;
- `skill_points`.

Isso permite que outras telas futuras usem a mesma fonte de verdade.

## Save

Nenhuma mudança de schema nesta etapa. O save permanece **v8**, incluindo os
cooldowns da coleta de materiais da v0.34.

## Teste nativo

`game/tests/cartoon_levelup_feedback_v035.gd`

Valida:
- nível 7 → 8 e tier da Floresta;
- nível 8 → 10 e magia Cristal;
- nível 10 → 25 e magia Arcana;
- retorno de desbloqueios pelo sistema de XP;
- contador de pontos no retrato;
- desaparecimento automático do banner.

## QA visual

`game/tests/qa_capture_levelup_feedback_v035.gd`

Gera quatro capturas reais do Godot em 640×360:
1. nível 7 antes do desbloqueio;
2. nível 8 com tier da Floresta;
3. nível 10 com Cristal;
4. nível 25 com Arcana.

## Validação oficial

A v0.35 foi validada no **Godot 4.7.2 oficial** no commit
`e90330ba708d5c5402158ffae5b346ff6c47f49f`.

O Gate oficial concluiu com sucesso no run `36885539172`, incluindo:
- importação/parser;
- **54 testes nativos**;
- regressões completas das versões anteriores;
- QA visual geral de todas as regiões;
- QA v0.35 com quatro capturas reais de level up e desbloqueios.

Artefato visual: `valedouro-levelup-v035-visual-qa`.

APK continua sob demanda.
