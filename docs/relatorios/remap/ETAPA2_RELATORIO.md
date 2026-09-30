# Remapeamento — Etapa 2: cidades, vilas e muralhas

Referência estrutural: Kenney Sketch Town Expansion. As soluções da referência foram reconstruídas no padrão Valedouro, sem a estética sketch:
- muralha nos eixos isométricos;
- torre em cada vértice;
- **a muralha termina na água com torre de ponta, em vez de atravessá-la**.

## Valedouro
- **Anel de muralha novo** (`tools/reg001/remap_city.py`), gerado pelo contorno orgânico da cidade (Etapa 1) em "dentes" isométricos. Segue a skill `valedouro-asset-quality`: passos exatos da peça e torre em todo vértice.
  - Antes, as muralhas norte e sul **atravessavam o rio**, com peças dentro d'água e uma torre na margem leste.
  - Agora o anel fecha só a margem oeste e **termina nas duas margens do rio** com torres. O rio é a defesa leste, e o bairro da margem leste fica fora das muralhas, junto ao cais.
  - Checagem automática: 0 peças de muralha na água.
- **Portão Norte (Lote 1) preservado**, com seus estados (brecha/reparada após o Alfa), barricadas e sentinelas. O anel continua a partir dele.
- **Portão Oeste (Porta da Fronteira)**, novo: torres de portão nos fins dos dois braços, com vão de 212 px por onde passa a Av. Oeste rumo à estrada de fronteira (saída do Ato I para a Floresta).
- **Portão Sul** mantido (x≈1950), agora flanqueado por torres de junção.
- A **"loja decorativa"** de `main.gd`, que ficava sobre o rio (x≈2220), foi removida, junto com seu colisor.
- A Av. Sul termina num **largo com poço e banco** junto à muralha, em vez de bater nela.
- **Quarteirões:** preenchimento guloso dos lotes livres mais próximos das ruas.
  - As casas são inteiras em 3/4 e têm a **porta voltada para a rua** (espelhadas conforme o lado).
  - Cada casa recebe **anexos variados** (barris, caixotes, banco, floreira, feno, lampião, poço, placa) e, às vezes, um canteiro. Isso quebra a repetição.
  - A cidade existente já estava densa, então entraram só 4 casas novas nos lotes que sobravam.
- **Vilas:** o mesmo método, em volta do centro da vila e voltado para estrada ou trilha. Entraram 3 casas novas entre a Vila dos Campos e a Aldeia do Vale.
- Nenhum colisor de construção sobre as vias.

## Validação (Godot 4.7.2 real)
- Suíte 17/17 PASS: portões e rotas (`world_travel`), vertical slice, guardião, gameplay.
- `validate_reg001`, `validate_v0_6` e `validate_v0_6_1` PASS.
- `audit_logic`: 35 construções, 0 falhas.
- 237 APPROVED intactos.

**Novo teste de captura** `tests/qa_capture_mosaic.gd`: percorre a câmera real do jogo em blocos, esconde a HUD e costura o **mapa inteiro em captura real do Godot**. Ele está em `docs/visual_qa/remap/etapa2/MOSAICO_REAL_mapa_inteiro.jpg`, junto com as capturas por ponto.

## Pendências
- **Etapa 3:** ecótono neve/relva (a borda ainda é dura no chão), vegetação Karsiori e um pinheiro encostado na borda da Estrada Norte.
- Ainda falta, na cidade, variedade de tipologias: taverna, ferraria e mercado com silhuetas próprias, além de torres de castelo à la Sketch Town. Isso exige modelar assets novos e fica como sugestão para um lote dedicado.
