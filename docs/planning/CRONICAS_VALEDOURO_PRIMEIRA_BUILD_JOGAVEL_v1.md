# CRÔNICAS DE VALEDOURO — PRIMEIRA BUILD JOGÁVEL v1

## Objetivo
Definir o primeiro momento em que o usuário deve voltar a testar o jogo.

O usuário NÃO precisa testar galerias técnicas ou lotes de assets antes disso.

---

# CRITÉRIO MÍNIMO

A build deve permitir:

1. abrir no Godot 4.7.2;
2. entrar no jogo;
3. controlar o herói;
4. caminhar pela cidade;
5. sair para uma área externa;
6. combater ao menos 2 tipos de inimigo;
7. receber dano;
8. derrotar inimigo;
9. receber loot;
10. abrir inventário;
11. equipar item;
12. ver mudança visual básica;
13. entrar numa pequena dungeon;
14. derrotar uma elite ou boss simples;
15. salvar e carregar.

---

# NÃO É OBRIGATÓRIO NESTA BUILD

- nível 100;
- todas as regiões;
- crafting profundo;
- hierarquia demoníaca;
- invasões;
- múltiplos bosses;
- áudio final;
- monetização;
- Android export final.

---

# CENÁRIO DA BUILD

Usar:
- parte da cidade;
- campos;
- bosque curto;
- entrada da dungeon;
- dungeon curta.

---

# PLAYER

Mínimo:
- idle;
- walk;
- attack;
- hurt;
- death;
- dodge recomendada.

---

# COMBATE

Mínimo:
- ataque básico;
- cooldown/recovery;
- hitbox;
- hurtbox;
- morte;
- loot.

---

# INIMIGOS

Mínimo:
- Lobo;
- Javali ou Aranha;
- Elite;
- Guardião simplificado com 2 padrões.

---

# UI

Mínimo:
- HP;
- ataque;
- interação;
- inventário;
- loot feedback;
- objetivo.

---

# SAVE

Salvar:
- posição segura;
- nível;
- HP;
- equipamento;
- inventário;
- quest flag;
- boss flag.

---

# GATE

Só chamar de "jogável" se o loop completo:
Cidade → Campo → Combate → Loot → Equipar → Dungeon → Boss/Elite → Save
funcionar sem erro fatal.
