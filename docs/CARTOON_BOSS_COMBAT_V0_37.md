# Candidata v0.37 — combate de chefes em fases

A v0.37 continua diretamente da v0.36 validada e melhora o combate dos chefes
sem alterar a história, os IDs ou as recompensas exclusivas já aprovadas.

## Barra de boss

Ao se aproximar de um chefe, o HUD passa a mostrar uma faixa dedicada no topo:

- nome do chefe;
- nível;
- HP atual/máximo;
- barra de vida;
- fase atual.

A barra só aparece quando o boss está próximo ou já foi engajado/danificado.
Ao abrir Bolsa, Forja, Mapa, Missões, Classes ou Pausa, ela é ocultada junto
com o restante do HUD de combate.

## Três fases

Todos os bosses que usam o runtime Cartoon passam a ter três fases automáticas:

- **Fase I — Vigília:** acima de 66% de HP;
- **Fase II — Fúria:** entre 34% e 66%;
- **Fase III — Ruptura:** 33% ou menos.

A fase é calculada diretamente pelo HP real do monstro e não depende de script
específico da região.

## Golpes especiais

A partir da Fase II, os bosses intercalam ataques normais com golpes especiais.

Fase II:
- golpe especial a cada terceiro ataque;
- telegráfico mais longo;
- área muito maior;
- dano especial = 1,45× o dano base.

Fase III:
- golpe especial a cada segundo ataque;
- área ainda maior;
- telegráfico continua visível, porém mais rápido;
- dano especial = 1,65× o dano base.

Ataques normais também ficam mais agressivos nas fases avançadas, mas o golpe
especial permanece claramente distinguível.

## Leitura visual

O golpe especial possui:
- círculo de perigo rosa/vermelho;
- segundo arco dourado animado;
- texto **ATAQUE ESPECIAL**;
- pulso visual diferenciado quando executado.

O próprio boss também mostra um pequeno indicador F1/F2/F3 em mundo aberto.

## Compatibilidade

Monstros comuns mantêm:
- windup de 0,45 s;
- raio de contato original;
- dano original;
- nenhum golpe especial;
- nenhuma barra de boss.

Assim, a v0.37 não transforma inimigos normais em mini-chefes por acidente.

## Integração com v0.36

Os troféus e crafts exclusivos continuam intactos. A v0.37 altera apenas a
experiência da luta; a recompensa segue:

boss → troféu único → receita revelada → craft exclusivo.

## Save

Nenhuma mudança de schema. O save permanece **v8**.

## Teste nativo

`game/tests/cartoon_boss_combat_v037.gd`

Valida:
- barra de boss em cena real 640×360;
- Fase I, II e III;
- transições por HP;
- golpe especial da Fase II;
- dano 1,45×;
- golpe especial da Fase III;
- dano 1,65×;
- raio ampliado;
- restauração do dano base após o golpe;
- isolamento do comportamento dos monstros comuns;
- ocultação da barra para boss não engajado e distante.

## QA visual

`game/tests/qa_capture_boss_combat_v037.gd`

Gera quatro capturas reais:
1. Fase I com barra de boss;
2. Fase II;
3. telegráfico de ataque especial da Fase II;
4. Fase III — Ruptura.

A v0.37 só deve ser promovida após o Godot Gate 4.7.2 concluir com sucesso.
APK continua sob demanda.
