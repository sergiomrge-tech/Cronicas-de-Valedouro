# CRÔNICAS DE VALEDOURO — GATE DA PRIMEIRA BUILD JOGÁVEL v1

## Objetivo
Definir o checklist obrigatório antes de chamar o usuário para testar.

---

# A. BOOT
- project.godot abre no Godot 4.7.2
- cena inicial carrega
- zero erro fatal

# B. PLAYER
- movimento 8 direções
- idle
- walk
- attack
- hurt
- death
- dodge se pronta

# C. MOBILE
- joystick touch
- atacar enquanto move
- interação
- poção
- texto legível

# D. MUNDO
- hub parcial
- campo
- bosque curto
- entrada dungeon
- dungeon curta

# E. COMBATE
- Lobo
- segundo inimigo
- elite
- Guardião simplificado

# F. LOOT
- ouro
- material
- equipamento
- inventário
- equipar

# G. VISUAL
- equipamento aparece no personagem
- Y-sort básico
- assets transparentes
- sem fundo escuro

# H. QUEST
- quest inicial
- kill counter correto
- dungeon unlock
- boss flag

# I. SAVE
- save
- load
- posição segura
- inventário
- equipamentos
- quests
- boss flag

# J. PERFORMANCE
- sem travamentos óbvios
- FPS medido no aparelho quando chegar o teste
- memória observada

# K. PACOTE
- ZIP extraído em pasta independente
- CRC OK
- parser
- testes
- execução
- SHA-256

---

# REGRA

Só pedir teste ao usuário quando o loop:

Cidade → Campo → Combate → Loot → Equipar → Dungeon → Elite/Boss → Save/Load

estiver funcional.