# Lote 2 / Ato II — Parte 2D: Coração da Raiz Oca (`LOC_HOLLOW_ROOT_ARENA`, `Q_MS02_HOLLOW_ROOT`, boss `BOSS_RAIZ_OCA_001`)

Segue §3-E e §5.5 do documento do Gerente. **Mesmo princípio do Guardião da Mina:** primeira derrota = progresso persistente; revanche = estado temporário.

## Estado (sem sistema paralelo)
- Persistente: `elites:BOSS_RAIZ_OCA_001` (seção `elites` do estado do mundo, padrão idêntico a `elites:BOSS_GUARDIAO_PEDRA_001`). O ID canônico do boss vem de `main_story_v1.json` (`Q_MS02_HOLLOW_ROOT`); nenhum ID novo.
- Temporário: `rematch:BOSS_RAIZ_OCA_001` — faz a **leitura visual** de `elites:<ID>` valer como falsa durante a luta (igual a `REG.rematch_boss`), sem apagar a flag. Ao terminar/sair da revanche a apresentação volta a dormente.
- O palco (`act02_stage.gd`) implementa exatamente essa semântica para revisão; o teste `act02_compositions` valida que só existem chaves `quest:`/`elites:`/`rematch:` com IDs canônicos.
- **Não implementado em runtime** (é o Gerente quem liga o boss/combate): spawn do boss, gravação da flag, revanche. Nada de lógica de combate foi tocado.

## Assets (11 novos, `MODELED_PENDING_GATE`, QC 11/11 PASS)
- Núcleo: `flo_hollow_core_active` (nó de raízes-mestras em espiral, espinhos, coração oco pulsando) / `flo_hollow_core_dormant` (raízes naturais com musgo, coração tênue, samambaias).
- Piso da arena: `flo_hollow_floor_active/_dormant` — anéis e **oito cunhas radiais + marcadores de canto** para telegráficos, raízes/veios no chão (ativo) ou musgo e cogumelos retornando (dormente).
- Campo delimitado por raízes gigantes: `flo_hollow_wall_active/_dormant` (segmento modular de 4,2 u).
- Acesso — a ferida aberta: `flo_hollow_wound_open` / `flo_hollow_wound_healing`.
- Corrupção progressiva na aproximação: `flo_corrupt_ground_light` (nível 1), `flo_corrupt_ground_heavy` (nível 2), `flo_corrupt_root_spike` (espinho).

## Composições (`act02_compositions.json`)
- **Arena:** parede de raízes em arco ao fundo, piso com telegráficos, núcleo ao fundo; **campo livre de props** (exclusão circular de 250 px; espinhos só nas bordas e só no estado ativo). Capturas: PRE_BOSS, POS_PRIMEIRA_DERROTA (dormente/purificada), REVANCHE_ATIVA (reativa sem apagar `elites:`).
- **Aproximação e ferida:** trilha que atravessa solo cada vez mais escuro (nível 1→2), espinhos e árvores secas; a ferida se abre sob/atrás da Árvore-Memória. Depois da derrota: ferida cicatriza, corrupção sai, árvores secas somem (F5 — não vira paraíso instantâneo: a ferida cicatrizada, o musgo e as raízes velhas permanecem).
- A rota para o Santuário dos Cartógrafos "torna-se visível" no pós-boss (chave `elites:BOSS_RAIZ_OCA_001` — será usada na Parte 2E).

## Capturas reais do Godot — `docs/visual_qa/story/act02/`
`FLO_2D_ARENA_PRE_BOSS`, `FLO_2D_ARENA_POS_PRIMEIRA_DERROTA`, `FLO_2D_ARENA_REVANCHE_ATIVA`, `FLO_2D_FERIDA_PRE_BOSS`, `FLO_2D_FERIDA_POS_PRIMEIRA_DERROTA` + folha do kit (render Blender).

## Testes
`act02_compositions` (9 composições, 300 objetos). Suíte completa: **17/17 PASS** (validada no commit da parte).

## Limitações
- O boss em si (sprite/animação de `BOSS_RAIZ_OCA_001`) e seus telegráficos animados são do pipeline de criaturas/combate, fora desta parte; a arena já traz as marcas de leitura no piso.
- Aproximação "abaixo, atrás ou dentro" da árvore: aqui foi resolvida como ferida ao lado da clareira; a conexão física final (túnel/descida) depende do mapa.

## Correções após revisão do Diretor
- **Núcleo flutuando:** o núcleo estava 100 px acima do centro do piso; agora assenta no centro do piso da arena (y do piso = y do núcleo), nos estados ativo e dormente.
- **Paredes sem angulação:** as paredes eram desenhadas de frente (rotação de 45° aplicada e alinhadas no eixo da tela). Criadas variantes que correm pelos **eixos isométricos** (`flo_hollow_wall_{active,dormant}_diag` ↘ e `_diagb` ↙, sem espelhar sprite) e a arena passou a fechar em **V angulado** com a frente aberta para a câmera. O coração da Árvore-Memória recebeu o mesmo tratamento (`flo_heart_wall_diag/_diagb`). Assets modulares originais permanecem para outros usos.
