# Cartoon v0.20 — candidata de arte e level design

Base: `598f8b6` / Cartoon v0.19. Data: 30/09/2026.
Estado: **MODELED_PENDING_GATE**. A versão oficial continua v0.19 até revisão
visual do Diretor e validação nos gates da engine oficial.

## O que mudou

- 44 SVGs originais, importados como texturas compartilhadas: 3 árvores, pinheiro,
  arbusto, rocha, 3 casas, forja, taverna, guilda, alquimista, arquivo, castelo,
  fonte, mercado, ruína, mina, barril, grama, lobo, guardião, poste, banco, poço,
  ponte, santuário, moinho, feno, baú, cerca e 12 poses do protagonista.
- Construções inteiras em perspectiva, fundações, madeiramento, telhados com
  fiadas, janelas, floreiras, chaminés, placas e objetos de trabalho.
- Vegetação com copas assimétricas, camadas de luz/sombra, raízes e variação
  cromática. Paleta de verdes mais controlada, pedra quente e telhados frios.
- Personagem com quatro direções e duas poses de caminhada por direção.
  Espada e indicação de equipamento continuam refletindo os tiers persistentes.
- Valedouro: praça pavimentada, pátios dos serviços, acessos residenciais,
  pequenos agrupamentos de vegetação, barris, jardins e lavouras com espigas.
- Ato I: clareiras com bordas irregulares, fundações partidas nas ruínas,
  formação rochosa atrás da mina e pátio/jardins no arquivo.
- Um grafo de estradas serve ao desenho dos chunks e à exclusão de vegetação.
  Acessos ligam os sete pontos de exploração existentes e a Câmara do Guardião.
- Árvores dos chunks compartilham a ordenação por Y do protagonista. Os sprites
  são retirados quando o chunk é descarregado; sprites estáticos não executam
  `_process` a cada frame.

## Escopo e continuidade

O passe de terreno e composição concentra-se em **Valedouro / Ato I**. Os sprites
comuns também são usados nas demais regiões, mas os terrenos, monumentos próprios,
interiores e bosses exclusivos dos Atos II–VIII ainda precisam de passes dedicados.
A cena inicial continua `CartoonMainMenu.tscn`. IDs, missões, saves, encontros e
posições dos lugares canônicos foram preservados. Não foram criadas novas quests
ou fatos de lore. O código visual antigo de props sem substituto permanece como
fallback Cartoon.

## Reproduzir

```bash
python3 game/tools/cartoon/build_visual_assets.py
godot --headless --path game --editor --import --quit
godot --headless --path game --script res://tests/cartoon_visual_v020.gd
godot --headless --path game --script res://tests/cartoon_hub.gd
godot --path game --rendering-method gl_compatibility \
  --script res://tests/qa_capture_cartoon_hub.gd -- /tmp/cartoon-v020
```

O gerador usa apenas a biblioteca padrão Python. Os SVGs são a arte fonte;
o Godot os rasteriza no import. Nenhum pacote da base pixel-art foi reativado.
`cartoon_visual_v020` foi adicionado aos dois workflows de validação existentes.

## Evidências executadas neste ambiente

**Engine disponível: Godot 4.6.3.stable.official.7d41c59c4.**

- Importação/editor e execução sem erros de parser nos scripts alterados.
- 20 testes Cartoon/campanha passaram: `cartoon_hub`, `cartoon_visual_v020`,
  `forest_act2`, `desert_act3`, `marsh_act4`, `frost_act5`, `siege_act5`,
  `coast_act6`, `corrupted_act7`, `abyss_act8`, `campaign_world`,
  `exploration_layer`, `exploration_v013`, `crafting_v014`, `zoom_controls`,
  `menu_inventory_layout`, `save_menu_v016`, `inventory_v017`,
  `hud_progression_v018`, `ui_layout_v019`.
- O novo gate faz flood fill nas colisões da cidade, verifica alcance dos POIs,
  travessia nas pontes, acesso viário dos marcos, carregamento dos 44 sprites e
  ausência de sprites órfãos após viagens e descarregamento do streaming.
- 16 capturas reais de gameplay em 960×540, OpenGL Compatibility / software
  renderer, com HUD visível. Quatro baselines v0.19 foram preservadas.
- Comparador independente: [review.html](visual_qa/cartoon_v020/review.html).
  Capturas: [antes/depois](visual_qa/cartoon_v020/).

**Pendentes:** parser/runtime no Godot 4.7.2, APK/Android, medição de desempenho
no aparelho alvo, revisão visual do Diretor e acabamento específico das outras
regiões. As verificações legadas `reg001_world`/`audit_logic.py` descrevem o mundo
anterior; este passe usa os gates da arquitetura Cartoon ativa.

## Próximos passes de arte

1. Castelo e portões com aproximações e enquadramentos dedicados; NPCs visíveis
   nos espaços de trabalho e descanso.
2. Floresta Ancestral: chão, raízes e santuários com variações próprias.
3. Famílias por bioma: deserto, pântano, neve, costa, corrupção e abismo.
4. Animações completas de criaturas, armas e efeitos, com revisão em celular.
