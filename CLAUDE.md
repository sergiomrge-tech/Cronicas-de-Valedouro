# CLAUDE.md — Crônicas de Valedouro

Este repositório é a fonte técnica colaborativa de **Crônicas de Valedouro**.

## Regras obrigatórias
- Engine oficial: **Godot 4.7.2**; manter compatibilidade Godot 4.x quando possível.
- Android/mobile-first, orientação horizontal, alvo de 60 FPS.
- Nunca afirmar PASS de runtime sem executar o Godot Gate.
- Preservar a direção visual aprovada: pixel art detalhada/coesa, HUD fantasia/madeira, animações ricas e cenários densos.
- Um único protagonista, sem classes rígidas; builds por armas, equipamentos, skills e passivas.
- Conteúdo por IDs persistentes; evitar nomes exibidos ou inteiros mágicos como chaves.
- REG_001 usa mapa híbrido: cidade, rotas, landmarks, quests, dungeons e bosses manuais; vegetação/props naturais procedural controlados por seed.
- Vegetação procedural não pode bloquear estradas, portas, pontes, NPCs, triggers, arenas ou caminhos mínimos.
- Árvores finais precisam ter volume de copa, luz/sombra e sombra de contato no chão. Não usar árvores chapadas/genéricas.
- Assets Claude marcados REWORKED/HOLD não entram em produção sem novo gate visual. APPROVED é candidato à integração.
- Antes de ZIP jogável: parser/runtime Godot 4.7.2, smoke test, referências, higiene e fluxo crítico.

## Estado atual
- Base: v0.6.x, com refinamento de mapa e vegetação procedural.
- Execução real já confirmada no Godot 4.7.2 Android do Diretor.
- O mapa precisa de auditoria visual ampla para aproximar arredores do nível de detalhe da vila.
- Próximo marco: Vertical Slice realmente jogável.

## Loop mínimo para chamar de jogável
Cidade → Campo → Combate → Loot → Equipar → Dungeon → Elite/Boss → Save/Load.

## Antes de editar
Leia este arquivo, `docs/README_CONTINUE_AQUI.md` e os documentos em `docs/planning/`. Rode o CI. Não altere cânone/direção visual sem registrar proposta.
