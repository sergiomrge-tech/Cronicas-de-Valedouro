# CRÔNICAS DE VALEDOURO — REG_001 QUEST FLOW v1

## Objetivo
Transformar o Vertical Slice em uma sequência clara e curta de objetivos.

---

# QUEST 01 — CHEGADA

ID PROPOSED:
`QUEST_A01_REG001_001`

Objetivo:
- entrar no hub;
- falar com NPC principal;
- conhecer serviços.

Recompensa:
- arma inicial;
- poção;
- XP pequena.

---

# QUEST 02 — ARREDORES

ID:
`QUEST_A01_REG001_002`

Objetivo:
- sair da cidade;
- alcançar landmark nos campos;
- derrotar primeiro encontro.

Ensina:
- movimento;
- combate;
- loot.

---

# QUEST 03 — CONTRATO DOS LOBOS

ID:
`QUEST_A01_REG001_003`

Objetivo:
- derrotar 3 Lobos APÓS aceitar.

Critério:
contador próprio da quest.

Recompensa:
- moedas;
- material;
- XP.

---

# QUEST 04 — SINAIS NO BOSQUE

ID:
`QUEST_A01_REG001_004`

Objetivo:
- investigar área corrompida;
- derrotar Aranha/Flor;
- coletar evidência.

---

# QUEST 05 — ELITE DO BOSQUE

ID:
`QUEST_A01_REG001_005`

Objetivo:
- localizar elite opcional;
- derrotar.

Recompensa:
- material incomum;
- item raro controlado.

Pode ser secundária, mas recomendada.

---

# QUEST 06 — RUÍNAS ANTIGAS

ID:
`QUEST_A01_REG001_006`

Objetivo:
- alcançar ruínas;
- ativar mecanismo;
- liberar acesso à dungeon.

---

# QUEST 07 — O GUARDIÃO

ID:
`QUEST_A01_REG001_007`

Objetivo:
- entrar na dungeon;
- atravessar salas;
- derrotar Guardião.

Recompensa:
- Núcleo do Guardião;
- XP;
- receita.

---

# QUEST 08 — RETORNO

ID:
`QUEST_A01_REG001_008`

Objetivo:
- retornar ao hub;
- entregar material;
- desbloquear crafting.

Final:
gancho para próximo arco.

---

# REGRAS

- recompensas únicas;
- save por quest_id;
- sem integers mágicos;
- sem título como chave;
- sem duplicação de recompensa;
- reload preserva progresso.

---

# TESTES

1. iniciar quest;
2. avançar objetivo;
3. salvar;
4. recarregar;
5. completar;
6. impedir recompensa duplicada;
7. kill anterior não conta.
