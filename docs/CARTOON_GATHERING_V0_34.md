# v0.34 validada — coleta de materiais no mapa

A v0.34 transforma materiais de crafting em parte real da exploração do mundo.

## Rede de coleta

Foram adicionados **48 novos pontos renováveis**, seis em cada uma das oito
regiões principais. Os sete pontos especiais de recurso que já existiam nas
regiões 2–8 passam a usar a mesma lógica renovável.

Total atual: **55 pontos coletáveis de material**.

### Materiais por região

- Berço de Valedouro — Osso de caça e Couro do Vale;
- Floresta Ancestral — Seiva Ancestral;
- Deserto e Ruínas — Âmbar Negro;
- Pântanos Sombrios — Fibra de Junco;
- Montanhas Nevadas — Cristal de Geada;
- Costas e Ilhas Perdidas — Coral Luminoso;
- Terras Corrompidas — Fragmento de Obelisco;
- Coração Abissal — Fragmento do Último Mapa.

## Interação

Ao se aproximar de um recurso, o HUD mostra:

`✦ <recurso> • COLETAR`

O mesmo botão **USAR** já existente faz a coleta. Não foi criado um segundo
controle de interação para não poluir a interface mobile.

Após a coleta:
- o recurso entra diretamente na Bolsa;
- a Forja usa o mesmo material sem conversão;
- aparece um aviso curto `Coletado: +N <material>`;
- o ponto some temporariamente do mapa.

## Respawn

Cada ponto renasce após **5 minutos**.

O tempo restante persiste no save, portanto sair da região, fechar o jogo ou
trocar de mapa não reinicia o recurso imediatamente.

## Save v8

O schema sobe de v7 para **v8** com:

`gathering_cooldowns`

Saves anteriores continuam válidos porque o novo campo possui fallback vazio.

## Distribuição

Os pontos foram posicionados fora da cidade central e em áreas de exploração,
próximos a rotas, clareiras, ruínas, pedreiras, margens e zonas secundárias.
A intenção é recompensar deslocamento e exploração, sem transformar o mapa em
uma fazenda de recursos concentrada em um único local.

## Validação

Novo teste nativo:

`game/tests/cartoon_gathering_v034.gd`

Cobre:
- 48 novos pontos e IDs únicos;
- seis pontos por região;
- materiais corretos por bioma;
- interação real em Valedouro e Floresta;
- bloqueio durante cooldown;
- persistência do cooldown no save v8;
- reaparecimento após expiração.

QA visual:

`game/tests/qa_capture_gathering_v034.gd`

Gera capturas reais do Godot do recurso disponível, recurso coletado,
materiais na Bolsa e coleta na Floresta Ancestral.

## Validação oficial

A v0.34 foi validada no **Godot 4.7.2 oficial** no commit
`ed2b1173ec8645a1165d12a0b595588da89f65bd`.

O Gate oficial concluiu com sucesso no run `36883480977`, incluindo:
- importação/parser;
- **53 testes nativos**;
- regressões de exploração, crafting, inventário, missões, combate e save;
- QA visual completo das regiões;
- QA v0.34 com quatro capturas reais da coleta no mapa.

Artefato visual: `valedouro-gathering-v034-visual-qa`.

APK continua sob demanda.
