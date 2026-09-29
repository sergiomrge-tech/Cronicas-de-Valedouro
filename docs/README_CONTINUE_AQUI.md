# CONTINUE AQUI — Crônicas de Valedouro

**Diretor:** Sergio  
**Mundo:** Elyndor  
**Engine:** Godot 4.7.2  
**Build atual de trabalho:** v0.6.2 refinamento de mapa.

## Cânone essencial
Elyndor vive a Guerra da Coroa Oca há 23 anos. O protagonista é um humano da Terra e o Segundo Viajante. Ele precisa reunir os Sete Sigilos, apoiar as Seis Coroas, derrotar Azharel e usar o Coração do Limiar para voltar à Terra. Azharel foi Adrian Vale, o Primeiro Viajante.

## Direção atual
- Um protagonista flexível, sem classes rígidas.
- Progressão nível 1–100 no jogo completo.
- Mundo aberto por regiões, bosses, materiais e crafting por IDs.
- Visual inspirado conceitualmente no nível de coesão/detalhe de RPGs pixel-art modernos, sem copiar conteúdo protegido.
- REG_001: mapa híbrido, vegetação procedural controlada e pontos narrativos manuais.
- Árvores: refinadas, sombreadas, com sombra de contato e boa leitura mobile.

## Estado REG_001 (Etapa 1 concluída)
- Mundo manual em dados: `game/data/reg001_world.json` (fonte: `game/tools/reg001/build_world.py`); runtime em `game/scripts/reg001_*.gd`.
- Assets modelados: `game/assets/modeled` + `game/data/modeled_assets_manifest.json` (fonte: `game/tools/modeling`). **Pendentes de gate visual do Diretor.**
- Catálogo APPROVED/INTEGRATED/MISSING/NOT_USED: `docs/catalog/REG001_ASSET_CATALOG.md`; IDs: `docs/planning/CRONICAS_VALEDOURO_REG001_WORLD_IDS_v1.md`.
- Relatório e gate: `docs/checkpoints/CHECKPOINT_REG001_ETAPA1.md`; capturas: `docs/visual_qa/reg001/`.

## Próximo marco
Primeira build jogável: cidade, área externa, 2 inimigos, loot, inventário/equipamento, dungeon curta, Guardião e save/load.
