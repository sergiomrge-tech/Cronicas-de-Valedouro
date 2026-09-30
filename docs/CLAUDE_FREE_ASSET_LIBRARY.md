# Handoff para Claude/Opus — Biblioteca gratuita de assets

A biblioteca de referência está em:
external_assets/free_reference_library/

Prioridade de consulta:
1. karsiori/tree_pack, bush_pack, flower_pack e spruce_tree_animated para linguagem de árvores/vegetação;
2. nature/kenney_foliage_pack para variedade vegetal;
3. buildings/kenney_tiny_town, kenney_medieval_rts e kenney_sketch_town_expansion para casas, castelos, telhados, muralhas, torres e composição modular;
4. animated_characters/ para HERÓI/NPCs com animações reais; Foozle Lucifer Warrior, Necromancer e Sorceress são referências de cobertura de estados;
5. animated_monsters/ para mobs, elites e bosses com movimento/ataque/reação/morte;
6. vfx/ para skills, magias, slash, impacto, fogo, explosões, projéteis e efeitos de área;
7. characters/ e monsters/ antigos podem servir como conceito/silhueta, mas NÃO como runtime quando forem estáticos;
8. equipment/ para armas, armaduras, escudos, itens e leitura de loot;
9. dungeons/kenney_tiny_dungeon para interiores e masmorras.

## Regra nova e obrigatória — animação

Nenhum herói, mob, monstro, elite ou boss estático deve ser integrado ao gameplay final.
Imagem estática pode servir para conceito/modelagem, mas o asset final de gameplay precisa de animações.

Herói: idle, walk/run, ataque(s), cast, hurt, dodge/roll e death; ranged/bow quando aplicável.
Mobs: idle, move, attack, hurt e death.
Elites/bosses: adicionar telegraph/wind-up, ataques especiais, recuperação e fases quando pertinente.

Quatro direções são o mínimo técnico. Oito direções são preferidas quando a perspectiva justificar.
Para herói e bosses, criar animações com anticipation/action/recovery e número de frames suficiente para leitura suave; não duplicar frames artificialmente.

Consulte também:
external_assets/free_reference_library/ANIMATION_AND_VFX_POLICY.md
external_assets/free_reference_library/ANIMATED_ASSET_SOURCES.md

Não copiar o estilo bruto dos pacotes quando ele conflitar com o padrão oficial de Crônicas de Valedouro.
Use-os como fonte de peças, proporções, silhuetas, temporização e variedade, remodelando para a identidade visual aprovada.

Para o mundo:
- substituir módulos flutuantes ou sem contato com o solo;
- corrigir paredes/tetos/janelas soltos;
- usar variações anguladas e encaixes coerentes;
- integrar construções à história e às missões;
- criar transições naturais entre biomas;
- manter caminhos legíveis para gameplay;
- aplicar vegetação por ecologia, umidade, altitude, corrupção e ocupação humana;
- manter foco mobile e orçamento de renderização.

Para combate/VFX:
- skills devem ter cast/charge, travel/projétil quando aplicável, impacto, AoE quando aplicável e dissipação;
- sincronizar VFX, hitbox e janela de dano;
- preservar leitura do personagem e inimigos;
- usar atlas/pooling e evitar overdraw excessivo em mobile.
