# CLAUDE.md — Crônicas de Valedouro

Este repositório é a fonte técnica colaborativa de **Crônicas de Valedouro**.

## Regras obrigatórias
- Engine oficial: Godot 4.7.2; manter compatibilidade Godot 4.x quando possível.
- Android/mobile-first, orientação horizontal, alvo de 60 FPS.
- Nunca afirmar PASS de runtime sem executar o Godot Gate.
- Nunca substituir a direção visual aprovada sem autorização do Diretor.
- Visual: pixel art detalhada e coesa, HUD fantasia/madeira, personagens com animações ricas, cenários densos e integrados.
- Um único protagonista, sem classes rígidas; builds por armas, equipamentos, skills e passivas.
- Conteúdo por IDs persistentes; nada crítico deve depender de nomes exibidos ou inteiros mágicos.
- Mapa REG_001 usa abordagem híbrida: cidade, rotas, landmarks, quests, dungeons e bosses manuais; vegetação/props naturais procedural controlados por seed.
- Vegetação procedural deve respeitar exclusões de estradas, portas, pontes, NPCs, triggers, arenas e caminhos mínimos.
- Árvores finais precisam ser refinadas, com volume de copa, luz/sombra e sombra de contato no chão; não aceitar árvores chapadas ou genéricas.
- Não usar os assets Claude `REWORKED`/`HOLD` em produção sem novo gate visual. Apenas `APPROVED` pode ser candidato à integração.
- Ao posicionar/mover construções, vilas, marcos e entradas de dungeon: seguir `.claude/skills/valedouro-map-logic/SKILL.md` (teste "por que aqui?", ligação missão ↔ lugar) e rodar `game/tools/reg001/audit_logic.py`.
- Ao criar/modelar/posicionar casas, prédios, muros, muralhas, cercas ou qualquer módulo estrutural: seguir `.claude/skills/valedouro-asset-quality/SKILL.md` (casa inteira em 3/4, telhado em fiadas sem flutuar, muros nos eixos isométricos conectados por junções, prova com captura real do Godot).
- Antes de liberar ZIP jogável: parser/runtime Godot 4.7.2, smoke test, referências, higiene, CRC/SHA e fluxo crítico.

## Estado atual
- Base técnica: v0.6.2 de refinamento de mapa, derivada da v0.6.1 candidate.
- O projeto abre e executa no Godot 4.7.2 no Android do Diretor.
- Problema visual identificado: arredores ainda precisam ganhar densidade e coerência com a vila.
- Vegetação procedural e árvores sombreadas/refinadas são prioridade.
- Próximo objetivo de gameplay: primeiro Vertical Slice realmente jogável.

## Loop mínimo para chamar de jogável
Cidade → Campo → Combate → Loot → Equipar → Dungeon → Elite/Boss → Save/Load.

## Colaboração
Antes de editar:
1. leia este arquivo;
2. leia `docs/README_CONTINUE_AQUI.md` e documentos em `docs/planning/`;
3. rode o CI/Godot Gate;
4. evite alterar arquivos fora da tarefa;
5. documente mudanças em `docs/checkpoints/` ou no PR.
