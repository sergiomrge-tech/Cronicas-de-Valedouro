# v0.40 — arquiteturas distintas e cidade otimizada

Pedido do Diretor: mais variedade nas construções e melhor desempenho na cidade.
A mudança parte do commit `3907624b` (v0.39, correção de flutuação).

## Construções

Atlas original transparente de 1448×1086, com 12 modelos: casa de palha,
sobrado com varanda, casa circular de pescador, mansão com telhado vermelho,
casa/fazenda com celeiro, chalé florido, ferreiro com duas chaminés e forno aberto,
taverna de dois andares, guilda com torres e brasões, alquimista com estufa,
arquivo com cúpula e mercado com toldo e mercadorias.

`cartoon_building_assets_v040.gd` compartilha uma única textura entre todos os
AtlasTextures. `buildings.json` registra recortes personalizados, dimensões e
âncoras das fundações. Recortar em uma grade uniforme cortaria torres/chaminés;
os 12 recortes foram revistos, testados e renderizados. A arte foi gerada para o
projeto e está marcada `MODELED_PENDING_VISUAL_APPROVAL`: o resultado está pronto
para avaliação do Diretor, sem alegar aprovação visual prévia.

As oito casas da cidade alternam seis modelos; a fazenda recebe o celeiro e a
casa do campo recebe o chalé. Serviços, mercado e arquivo usam modelos próprios.
Os interiores existentes, posições de portas, bloqueadores e IDs de missão
continuam ligados aos locais canônicos. O castelo mantém a arquitetura real.

## Desempenho

O piso da cidade e jardins reais emitia aproximadamente 25 mil chamadas de
desenho por quadro, incluindo pedras dos caminhos, plantações e detalhes das
margens do rio. O CanvasItem cobria uma grande área e os comandos também eram
submetidos pelo minimapa. O piso estático agora usa `city_ground.png`: textura
2048×2048, cobrindo 4096×4096 unidades, com transparência fora do terreno
planejado. A fonte procedural foi preservada para edição/regeneração; rios,
pontes, bloqueadores e consultas de navegação continuam na geometria original.

O retrato da Bolsa inicia com o viewport desabilitado e o herói sem processar.
Abrir a Bolsa reativa ambos, incluindo animação e atualização de equipamento;
fechar volta a suspender o retrato. O HUD evita reaplicar a mesma skin/ícone de
ataque em todos os quadros; mudanças de texto/cooldown continuam atualizando.

Medição antes/depois no mesmo ambiente, Godot 4.6.3, renderizador por software
Mesa llvmpipe, 960×540, VSync desabilitado, 40 quadros de aquecimento e 160 amostras
por ponto. Cena real com HUD, minimapa, cidade, fauna e streaming, sem congelar
os atores. Números não representam um benchmark em celular Android.

| Local | Chamadas de desenho | Mediana por quadro | Redução da mediana |
|---|---|---|---|
| Praça | 24910 → 308 | 189.4 → 19.2 ms | 89.9% |
| Residencial | 24583 → 248 | 164.1 → 19.2 ms | 88.3% |
| Castelo | 24761 → 362 | 176.9 → 23.1 ms | 86.9% |

JSONs brutos em `visual_qa/cartoon_v040/benchmark_before.json` e
`benchmark_after.json`; percentis, primitivas e memória permanecem disponíveis.
Na praça, memória de vídeo reportada caiu de aproximadamente 82,0 para 66,2 MiB,
mesmo com a nova arte, pela remoção das grandes listas de comandos do piso.
O objetivo mobile de 60 FPS ainda precisa ser medido em aparelho real.

## Regenerar o piso

Com Godot importado e um display OpenGL disponível:

```sh
godot --headless --path game --import
godot --path game --rendering-method gl_compatibility --audio-driver Dummy \
  --script res://tools/cartoon/bake_city_ground_v040.gd -- \
  "$PWD/game/assets/cartoon/v040/city_ground.png"
godot --headless --path game --import
python3 game/tools/cartoon/validate_city_art_v040.py
```

O bake usa a fonte procedural (`use_baked_ground=false`) e grava
`ground_provenance.json` com semente, bounds, versão/renderizador e SHA256 dos
inputs. O validador rejeita alteração de código/grama sem regenerar o piso.
Isso impede publicar uma textura antiga sobre rios, caminhos ou jardins novos.
2048² foi escolhido para limitar memória em Android; zoom alto pode mostrar
menos definição no chão que o desenho vetorial original.

## Verificação e continuidade

Validação local concluída: 41 testes Cartoon aprovados, 208 poses em pé do
herói e 12 fundações verificadas por renderização. Capturas v0.40 passaram com
máximo de 904 chamadas de desenho entre os pontos visitados. Um ZIP de recursos
exportado foi carregado em diretório vazio: manifesto e ambos os atlases
funcionam sem a árvore de fontes; tests/tools ficaram fora do pacote. Esse
pacote é uma verificação de recursos, não um APK ou aplicativo entregue.


- `cartoon_city_v040.gd`: 12 regiões dentro do atlas sem sobreposição, bordas
  transparentes sem corte, seis modelos de casa, contato das fundações, ponte,
  colisão do ferreiro e ciclo abrir/fechar/reabrir do retrato da Bolsa.
- `qa_capture_city_v040.gd`: contato renderizado das 12 fundações; galeria e
  dez capturas de mundo/Bag; orçamento abaixo de 2000 chamadas em cada vista,
  cobrindo câmera principal e minimapa. FPS não é usado como gate de CI.
- `qa_capture_grounding_v039.gd` mantém o teste de 208 poses em pé do herói.
- Workflow oficial inclui o novo teste (58 nativos no total), capturas e
  benchmark. Android sob demanda inclui 41 testes; exportação futura v0.40.

Save permanece v8. Nenhum APK foi solicitado ou gerado nesta alteração.
A validação local usa Godot 4.6.3; confirmar o run oficial 4.7.2 antes de tratar
o checkpoint como validado. A revisão está em
[visual_qa/cartoon_v040/review.html](visual_qa/cartoon_v040/review.html).

O Diretor também pediu uma skill para mapas procedurais 2D. Fontes e recomendação
em [PROCEDURAL_2D_SKILL_RESEARCH.md](PROCEDURAL_2D_SKILL_RESEARCH.md).
A pesquisa não instalou a skill nem substituiu o gerador/cidades atuais.
