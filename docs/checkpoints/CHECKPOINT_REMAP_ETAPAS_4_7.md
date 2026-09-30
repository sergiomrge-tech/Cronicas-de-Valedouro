# Checkpoint — Remapeamento Etapas 4–7 + assets gratuitos integrados

- Branch: `ccr-bb54cda9-tvw178` (base validada `afd56ba`).
- Relatório completo com a tabela por asset: `docs/relatorios/remap/ETAPA4_7_RELATORIO_FINAL.md`.
- Evidências reais (Godot 4.7.2): `docs/visual_qa/remap/etapa4/`, `etapa5_6/`, `icones/`, `etapa7/`.
- Estado: 17/17 suítes PASS; validadores e `audit_logic` PASS; 237 APPROVED preservados; 113 derivados gratuitos em
  `MODELED_PENDING_GATE`, aguardando o gate visual do Diretor.
- Regerar tudo: `game/tools/external/build_*.py` → `tools/modeling` merge → `tools/reg001/build_world.py` →
  `tools/terrain/bake_ground.py` → `tools/build_reg001_catalog.py` → validadores.
- Capturas: `tests/qa_capture_mosaic.gd`, `qa_capture_reg001.gd`, `qa_capture_dungeons.gd`, `qa_capture_combat.gd`, `qa_capture_icons.gd`.
- Próximo: gate visual do Diretor nos derivados gratuitos; teste de 60 FPS no Android; herói com arco/cajado sem a espada da base.
