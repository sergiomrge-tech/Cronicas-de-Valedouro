# Crônicas de Valedouro — Mundo Cartoon Mission-First v0.11

## Estado

A campanha principal completa está agora reservada e representada fisicamente na reconstrução 2D cartoon. O mapa não é mais expandido por terreno vazio: cada região nasce da topologia de suas missões, dungeons, bosses, hubs, retornos e transições.

## Escala e cenas

| Ato | Região | Escala linear | Cena |
|---|---|---:|---|
| I | Berço de Valedouro | 7x | `ValedouroCartoonHub.tscn` |
| II | Floresta Ancestral | 20x | `ForestAncientCartoon.tscn` |
| III | Deserto e Ruínas de Edravar | 15x | `DesertEdravarCartoon.tscn` |
| IV | Pântanos Sombrios | 15x | `MarshDarkCartoon.tscn` |
| V | Montanhas Nevadas | 15x | `FrostMountainsCartoon.tscn` |
| V retorno | Cerco de Valedouro | localização real do Portão | `ValedouroSiegeCartoon.tscn` |
| VI | Costas e Ilhas Perdidas | 20x | `CoastLostIslandsCartoon.tscn` |
| VII | Terras Corrompidas | 20x | `CorruptedLandsCartoon.tscn` |
| VIII | Coração Abissal | 8x | `AbyssHeartCartoon.tscn` |

## Cobertura de missão

- 49 missões principais canônicas;
- 47 locais canônicos;
- todas as missões possuem referência de mapa;
- regiões grandes usam chunks de 1024 e janela ativa ao redor do jogador;
- cada Ato possui navegação até o objetivo;
- cada região possui mapa interno com os locais da campanha;
- transições entre Atos são físicas;
- bosses principais das áreas implementadas têm arena/local próprio;
- o Ato VIII inclui a escolha final entre retornar à Terra ou permanecer em Elyndor.

## Regra permanente

Qualquer expansão futura — missão secundária, contrato, boss opcional, dungeon, vila, ruína ou evento — deve primeiro ser registrada no mapa/quest graph e só depois receber terreno e decoração.

## Limite atual

A arte é deliberadamente simples. A estrutura do mundo, missões e navegação está sendo priorizada antes do refinamento visual de alta fidelidade à referência cartoon aprovada.
