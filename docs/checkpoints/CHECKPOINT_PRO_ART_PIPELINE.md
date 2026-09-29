# CHECKPOINT — Professional Art Pipeline

**Projeto:** Crônicas de Valedouro  
**Branch:** `art/pro-pixel-modeling-pipeline`  
**Base:** `ccr-bb54cda9-tvw178`  
**Objetivo:** elevar a produção visual de REG_001 sem alterar a identidade aprovada.

## Estado

A branch substitui a mentalidade "primitiva procedural = arte final" por um pipeline profissional:

`referência APPROVED -> silhueta -> blockout -> modelagem detalhada -> câmera dimétrica fixa -> render -> pixel finish -> limpeza manual -> QA -> Godot -> gate visual`

O antigo `game/tools/modeling` continua válido para blockout, colisão, escala e elementos simples, mas não é suficiente por si só para landmarks/personagens/terreno hero-facing.

## Implementado

### Skill artística
- `docs/art/VALEDOURO_PRO_ART_MODELING_SKILL.md`
- regras de silhueta, materiais, paleta, iluminação, escala, animação, terreno, NPCs/fauna e definição de pronto.

### Rig de render
- `game/tools/art_pipeline/blender_valedouro_setup.py`
- câmera ortográfica;
- projeção alinhada ao modelador atual: AZ 45° / elevação 30°;
- referência de escala/projeção;
- PNG transparente;
- iluminação global controlada.

### Landmarks REG_001
- `game/tools/art_pipeline/blender_landmarks_reg001.py`
- torre de vigia;
- moinho;
- entrada de caverna;
- cachoeira/penhasco.

Os geradores usam estruturas em camadas, vigas, fundações, degraus, rubble, pás construídas, massas rochosas assimétricas e props de escala.

### Terreno/elevacão
- `game/tools/art_pipeline/blender_terrain_modules_reg001.py`
- falésia reta;
- canto externo;
- canto interno;
- degraus naturais;
- paredes de cânion;
- variantes conceituais para grama, neve e areia.

Objetivo: eliminar o aspecto plano/quadriculado e introduzir volume real no mapa.

### Pixel finish
- `game/tools/art_pipeline/pixel_finish.py`
- nearest-neighbor;
- hard alpha;
- limpeza RGB em transparência;
- limite opcional de paleta.

### Technical QA
- `game/tools/art_pipeline/asset_qc.py`
- clipping;
- alpha suave/halo;
- background/transparência;
- palette explosion;
- dimensões;
- frame sheet;
- foot anchor.

### Paleta
- `game/tools/art_pipeline/extract_approved_palette.py`
- extrai uma paleta controlada diretamente dos PNGs APPROVED;
- ignora transparência;
- pesa cores por frequência;
- produz JSON ordenado por luminância.

### Comparação visual
- `game/tools/art_pipeline/make_visual_comparison.py`
- folha BEFORE / AFTER / APPROVED REF;
- inclui preview em escala de gameplay.

### Fila de substituição
- `game/data/reg001_professional_art_queue.json`
- P0: terreno/água, elevações, NPCs e fauna;
- P1: torre, moinho, caverna, cachoeira;
- P2: postos, santuário, crops, dock/boats, interiores;
- P3: FX de interação.

## Regras para integração

1. Não marcar automaticamente nada como APPROVED.
2. Novos candidatos entram como `MODELED_PENDING_GATE`.
3. REWORKED/HOLD continuam fora do renderer.
4. Não remover LEGACY_BASELINE antes de existir substituição integrada.
5. Comparar escala/perspectiva com assets APPROVED reais.
6. Capturas de aprovação precisam vir do Godot 4.7.2.
7. Esta branch não deve sobrescrever o lote paralelo do Claude; incorporar por merge/rebase seletivo após revisar as mudanças mais novas.

## Limite desta branch

O ambiente atual não possui Blender executável disponível e o acesso direto de shell ao GitHub falhou por DNS. Por isso, os scripts Blender foram escritos e versionados, mas ainda precisam ser executados em um ambiente com Blender para gerar os PNGs candidatos.

O GitHub conectado continua acessível e a branch está versionada corretamente.

## Próximo trabalho artístico

1. Executar os quatro landmarks no Blender usando o rig fixo.
2. Renderizar módulos de elevação.
3. Gerar paleta oficial a partir dos APPROVED.
4. Fazer pixel cleanup.
5. Produzir comparação BEFORE/AFTER.
6. Colocar candidatos no Godot 4.7.2.
7. Gerar capturas reais.
8. Gate visual do Diretor.
