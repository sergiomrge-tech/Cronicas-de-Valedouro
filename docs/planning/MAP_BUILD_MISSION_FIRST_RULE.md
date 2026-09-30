# REGRA OBRIGATÓRIA — MAPA GUIADO POR TODAS AS MISSÕES

Esta regra vale para toda construção, expansão, remapeamento ou refinamento de regiões de **Crônicas de Valedouro**.

Antes de desenhar terreno, estradas, bairros, ruínas, dungeons, arenas, vilas ou decoração, consultar as fontes de missão vigentes e reservar fisicamente no mundo tudo que a campanha precisa.

## Fontes mínimas obrigatórias
- `game/data/main_story_v1.json`
- `game/data/story_locations_v1.json`
- `game/data/cartoon_map_mission_coverage_v1.json`
- documentos de quest flow da região em `docs/planning/`
- documentos canônicos em `docs/canon/`

## Ordem de trabalho obrigatória
1. listar todas as missões que atravessam a região;
2. listar seus locais, NPCs, bosses, dungeons, entradas, saídas e estados pré/pós-missão;
3. definir a rota física entre esses beats;
4. reservar footprints e zonas de combate/interação;
5. reservar conexões com missões futuras e retornos narrativos;
6. só depois preencher exploração opcional, vegetação, props e decoração.

## Gate
Nenhuma região pode ser considerada pronta se:
- uma missão canônica não tiver local físico ou instância definida;
- uma dungeon ou boss arena obrigatória tiver sido substituída por decoração genérica;
- a rota entre beats não for navegável;
- uma construção grande existir apenas para preencher espaço;
- o layout impedir um estado futuro exigido por missão.

O CI executa `game/tools/validate_map_mission_coverage.py` para impedir perda de cobertura.

## Escala
O tamanho maior das regiões deve ser preenchido pela combinação de:
- campanha principal;
- missões secundárias;
- contratos e eventos;
- exploração opcional;
- serviços;
- segredos e lore;
- caminhos e transições coerentes.

Nunca aumentar o mapa apenas multiplicando terreno vazio.
