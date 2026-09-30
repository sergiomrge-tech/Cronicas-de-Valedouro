# Crônicas de Valedouro — reconstrução 2D cartoon v0.1

Primeiro núcleo da reconstrução visual inspirada no protótipo Castle Fight, mantendo o conteúdo/cânone de Crônicas de Valedouro.

## Implementado neste lote
- cena Godot real `ValedouroCartoonHub.tscn`;
- centro de REG_001 / Berço de Valedouro;
- Castelo, Praça Central, fonte, Ferreiro, Taverna, Guilda, Alquimista, mercado, casas, poço, pontes e decoração;
- terreno, estradas e rios desenhados vetorialmente no Godot;
- linguagem visual com contorno escuro, cores vivas, volumes simples e sombras suaves, derivada do sistema de desenho de Castle Fight;
- herói vetorial animado (idle/caminhada/ataque simples);
- movimento teclado + joystick touch;
- câmera mobile;
- bloqueios básicos e rios não atravessáveis fora das pontes;
- POIs com IDs persistentes;
- interação básica com serviços;
- objetivo inicial `QUEST_A01_REG001_001 — Chegada` representado no HUD;
- teste nativo `cartoon_hub.gd`.

## Próximo anel
Expandir do hub para Portão Sul → Campos do Vale → primeiro encontro → loot, preservando exatamente a mesma linguagem visual.
