# CRÔNICAS DE VALEDOURO — REG_001 NPCs E SERVIÇOS v1

## Objetivo
Definir o conjunto mínimo de NPCs e serviços necessários para o primeiro loop jogável.

---

# 1. NPC PRINCIPAL DO HUB

Função:
- introduzir o jogador à cidade;
- entregar a primeira missão;
- servir de elo narrativo para o Ato I.

Requisitos:
- ID persistente;
- estado de diálogo por quest;
- posição fixa inicial;
- sem rotina complexa no primeiro Vertical Slice.

Campos:
```text
npc_id
display_name
role
region_id
district_id
dialogue_profile_id
quest_giver_ids[]
shop_id opcional
schedule_id futuro
```

---

# 2. FERREIRO

Funções:
- upgrade inicial de armas/armaduras;
- crafting básico;
- desbloqueio de receita pós-boss.

No primeiro slice:
- limite de upgrade +2/+3;
- sem reforja avançada;
- sem reroll de afixos.

---

# 3. COMERCIANTE

Funções:
- comprar/vender;
- oferecer consumíveis;
- oferecer equipamento simples.

Regras:
- não vender item raro melhor que o conteúdo da região;
- estoque por faixa de progresso;
- preços definidos por dados.

---

# 4. ALQUIMISTA

Funções:
- poções;
- consumíveis;
- pequenos buffs temporários futuros.

No slice:
- poção de vida;
- antídoto apenas se status correspondente existir;
- sem árvore complexa de alquimia.

---

# 5. GUILDA / QUADRO DE CONTRATOS

Funções:
- contratos;
- missão dos lobos;
- futuros desafios.

No slice:
- 1 contrato principal;
- 1 contrato opcional.

---

# 6. TAVERNA

Funções:
- ambientação;
- NPCs secundários;
- descanso;
- rumor/lore.

No primeiro slice:
- descanso e save opcional;
- sem sistema social complexo.

---

# 7. PONTO DE DESCANSO

Funções:
- recuperar HP;
- salvar;
- resetar spawns comuns;
- atualizar alguns estados.

Nunca:
- resetar boss narrativo derrotado;
- apagar progresso de quest.

---

# 8. DIÁLOGO

Estados mínimos:
- default
- quest_available
- quest_active
- quest_complete
- post_boss

Não codificar texto inteiro em `main.gd`.
Usar IDs de diálogo.

---

# 9. VISUAL

NPCs importantes:
- silhueta distinta;
- roupa coerente com função;
- leitura boa em mobile;
- paleta compatível com o hub.

---

# 10. TESTES

- NPC entrega quest uma vez;
- diálogo muda com estado;
- loja abre;
- upgrade respeita limite;
- descanso salva;
- pós-boss altera diálogo.