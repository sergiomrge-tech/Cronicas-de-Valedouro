# CRÔNICAS DE VALEDOURO — IMPLEMENTAÇÃO DA PRIMEIRA BUILD JOGÁVEL v1

## Objetivo
Definir a ordem de implementação para chegar ao primeiro teste do usuário sem retrabalho.

---

# FASE J1 — BOOT E FUNDAÇÃO

Pré-requisitos:
- ContentDB
- GameState
- SaveService
- IDs persistentes
- parser limpo

Aceite:
projeto inicia sem erro.

---

# FASE J2 — PLAYER

Criar:
- Player.tscn
- movimento
- câmera
- colisão
- paperdoll inicial

Aceite:
andar pela cena sem `main.gd` controlar tudo.

---

# FASE J3 — CONTROLES MOBILE

Implementar:
- joystick touch;
- ataque;
- interação;
- poção;
- multitouch real.

Aceite:
mover + atacar simultaneamente.

---

# FASE J4 — ÁREA EXTERNA

Montar:
- trecho do hub;
- saída;
- campos;
- bosque curto.

Aceite:
transição contínua e navegável.

---

# FASE J5 — INIMIGO BASE

Implementar:
- Lobo;
- HP;
- aggro;
- chase;
- attack;
- hurt;
- death.

Aceite:
combate completo.

---

# FASE J6 — LOOT E INVENTÁRIO

Implementar:
- moeda;
- material;
- item;
- inventário;
- equipar.

Aceite:
drop entra no inventário e persiste.

---

# FASE J7 — SEGUNDO INIMIGO

Adicionar:
- Javali OU Aranha.

Aceite:
segundo arquétipo exige comportamento diferente.

---

# FASE J8 — QUEST

Implementar:
- Chegada;
- Arredores;
- Contrato dos Lobos.

Aceite:
save/load preserva progresso.

---

# FASE J9 — DUNGEON CURTA

Montar:
- entrada;
- corredor;
- sala;
- elite;
- checkpoint;
- arena.

Aceite:
entrar e sair sem erro.

---

# FASE J10 — GUARDIÃO

Versão inicial:
- 2 padrões;
- telegraph;
- fase simples;
- loot garantido.

Aceite:
boss derrotável e flag persistente.

---

# FASE J11 — SAVE/LOAD COMPLETO

Persistir:
- posição segura;
- HP;
- inventário;
- equipamento;
- quest;
- boss;
- ouro.

Aceite:
fechar/reabrir e continuar.

---

# FASE J12 — POLIMENTO PARA TESTE

- corrigir erros;
- ajustar UI;
- garantir texto legível;
- verificar Y-sort;
- remover placeholders grosseiros;
- validar colisão.

---

# GATE DE ENTREGA AO USUÁRIO

Somente quando:
Cidade → Campo → Combate → Loot → Equipar → Dungeon → Boss → Save/Load
funcionar do início ao fim.

---

# NÃO BLOQUEAR O PRIMEIRO TESTE POR

- áudio final;
- crafting profundo;
- 8 regiões;
- nível 100;
- guerra demoníaca;
- dezenas de skills.

Esses vêm depois.
