---
name: valedouro-asset-quality
description: Padrão de qualidade APROVADO pelo Diretor para construções, casas, muros, muralhas, cercas e módulos arquitetônicos de Crônicas de Valedouro. Use SEMPRE que criar, modelar, posicionar ou revisar casas, prédios, muros, muralhas, cercas, paliçadas, torres, portões ou qualquer módulo estrutural, e antes de declarar uma cena pronta.
---

# Padrão de qualidade de assets e construções (aprovado pelo Diretor)

Referências aprovadas ("bem melhor"): `val_town_house_*`, `val_guild_hall` e `val_archive_hall` em 3/4, muralhas `iso_wall` com `val_wall_tower`.
Capturas: `docs/visual_qa/story/estrutural_catA/`.

## 1. Construções são UMA peça modelada inteira
- Casa/prédio = corpo, portas, janelas, madeiramento e telhado no MESMO modelo Blender. Nunca montar casa com peças soltas (porta + janela + telhado): o telhado flutua.
- **Vista 3/4 obrigatória**: modelar sem `geo.rotate_all(45)`, fachada principal em +x e lateral em +y, duas faces visíveis. Fachada "de frente" (cartão) é reprovada.
- Colisão de prédio em 3/4: `coll=(profundidade, largura)` (footprint no mundo), não `fpr()`.
- Detalhe mínimo de uma casa: soco de pedra com cunhais, andar em enxaimel ou alvenaria com textura, porta com moldura/dobradiça/degrau, janelas com caixilho, venezianas ou peitoril, floreira ou lanterna, chaminé, e props de vida ao redor (barril, caixotes, lenha, hera).
- Variar: pelo menos 3 variações de telhado (ardósia azul, barro vermelho, ripas de madeira) e de posição e seed.

## 2. Telhados
- Usar `roof_gable_tiled()` (tools/art_pipeline/ato1_common.py) ou `_shingle_slope()`: telhas em FIADAS com relevo, base contínua por baixo (sem vãos), cumeeira e EMPENAS FECHADAS no material da parede.
- O beiral apoia na parede ou no frechal; nada flutua. Nunca usar uma placa lisa (`geo.roof_gable` sozinho) em telhado final.

## 3. Muros, muralhas, cercas, muretas: ângulo e conexão
- Módulos lineares correm SÓ pelos dois eixos isométricos (±26,6° na tela). Usar `iso_wall(kit, início, [(dir, n), ...])` em `tools/reg001/build_world.py` (kits em `ISO_KITS`).
- Passo EXATO = comprimento real da peça na tela (`data/orient_kit.json`), sem fresta e sem sobreposição visível.
- Toda mudança de direção recebe junção (`val_wall_tower` em muralha). Muralha longa usa `teeth()` (dentes) ou recintos com cantos, nunca uma linha reta frontal.
- Direções variadas numa mesma cena: não repetir a mesma diagonal em tudo.
- Curvas orgânicas (paliçada, raízes, muro de ruína) usam `krun()` / `Comp.run()` com o kit de 8 ângulos (`pro_orient.py`), com peças sobrepostas para não abrir frestas.
- Nunca espelhar sprite para obter outra direção (inverte luz e sombra): renderizar a variante no Blender.

## 4. Integração no mundo
- Nada flutua: peças assentam no chão (foot anchor = base real); núcleos, estátuas e altares no centro do piso deles.
- Sombra projetada e sombra de contato presentes (`cast_shadow.gd`).
- Colisões não bloqueiam rotas: rodar `tests/world_travel.gd` e `tools/reg001/audit_logic.py` após mexer em construções.
- Peças APPROVED antigas frontais (`APP:city_house_*`, `APP:city_roof_*`, `APP:city_wall*`, `APP:city_store`, `APP:city_gate`) não devem voltar ao mundo.

## 5. Prova
- Validar sempre com captura REAL do Godot (`tests/qa_capture_reg001.gd` / `tests/qa_capture_act02.gd`), olhando o resultado antes de declarar pronto.
- Rodar a suíte Godot completa, QC (`asset_qc.py`: 0 FAIL), `validate_reg001.py` e `audit_logic.py`.
- Assets novos ficam `MODELED_PENDING_GATE` até o gate visual do Diretor.
