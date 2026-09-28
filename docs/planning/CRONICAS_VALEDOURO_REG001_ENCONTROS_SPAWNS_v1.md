# CRÔNICAS DE VALEDOURO — REG_001 ENCONTROS E SPAWNS v1

## Objetivo
Definir como inimigos, elites, fauna e ambientação entram na primeira região sem gerar caos ou grind excessivo.

---

# 1. PRINCÍPIO

Spawns de combate NÃO serão totalmente aleatórios.

Usar:
- pontos de encontro manuais;
- grupos de inimigos pré-definidos;
- pequenas variações por seed;
- limites por subzona;
- respawn controlado.

Ambiente decorativo pode ser procedural.
Combate relevante deve ser dirigido.

---

# 2. SUBZONAS

## Cidade
Combate normal: nenhum.
Exceções futuras: eventos roteirizados.

## Campos do Vale
Inimigos:
- Lobo
- Javali Musgoso

Densidade:
baixa a média.

Função:
aprendizado de combate.

## Bosque Inicial
Inimigos:
- Lobo
- Aranha Sombria
- Flor Voraz

Densidade:
média.

Função:
movimento, emboscada, controle de espaço.

## Ruínas Antigas
Inimigos:
- Aranha Sombria
- Flor Voraz
- Elite do Bosque

Densidade:
média e encontros mais definidos.

## Dungeon
Inimigos:
grupos manuais.

Nada de spawn procedural no primeiro Vertical Slice.

---

# 3. PONTOS DE ENCONTRO

Cada EncounterPoint deve declarar:

```text
encounter_id
region_id
subzone_id
enemy_group_id
respawn_policy
activation_radius
leash_radius
world_flags[]
quest_conditions[]
```

---

# 4. GRUPOS DO INÍCIO

## Grupo A — Campo leve
- 1 Lobo

## Grupo B — Campo
- 2 Lobos

## Grupo C — Javali
- 1 Javali Musgoso

## Grupo D — Bosque leve
- 1 Aranha Sombria
- 1 Lobo

## Grupo E — Bosque
- 1 Flor Voraz
- 1 Aranha Sombria

## Grupo F — Ruínas
- 2 Aranhas
- 1 Flor

## Elite
- Elite do Bosque
- sem adds no primeiro encontro

---

# 5. RESPAWN

Inimigos comuns:
- podem reaparecer após descanso/retorno à região.

Elites:
- respawn controlado;
- nunca reaparecer imediatamente.

Boss:
- não reaparece na progressão normal.

---

# 6. LEASH

Todo inimigo comum deve abandonar perseguição após sair da área.

Evitar:
- puxar inimigo por metade do mapa;
- levar inimigo para dentro da cidade.

---

# 7. QUESTS

Objetivos de kill devem contar apenas inimigos derrotados depois da quest estar ativa.

Nunca usar contador global sem baseline.

---

# 8. DROP

Monstro comum:
- material frequente;
- moeda;
- equipamento raro.

Elite:
- material incomum;
- equipamento controlado.

Boss:
- material exclusivo garantido.

---

# 9. FAUNA

Fauna decorativa:
- pássaros;
- pequenos animais;
- insetos;
- peixes.

Procedural por bioma.
Sem colisão pesada.
Sem loot no Vertical Slice.

---

# 10. PERFORMANCE

Limite inicial recomendado por chunk:
- poucos inimigos ativos;
- decoração sem lógica pesada;
- pooling para VFX futuros.

Medir depois no Android.