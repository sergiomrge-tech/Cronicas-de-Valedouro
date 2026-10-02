# v0.41 — área piloto viva e ilustrada

A partir de `f37719cd` (v0.40), o Diretor aceitou a recomendação de manter Godot
com uma direção Cartoon ilustrada e desenvolver primeiro uma praça, uma rua e
a saída da cidade. Esta versão estabelece essa referência, restaura vegetação
junto ao limite da cidade e distribui encontros normais pela região REG001.

## Arte e movimento

Cinco PNGs originais, preservados sem edição de pixels por scripts: grama,
pedra, atlas de oito elementos de natureza (carvalho, bétula, árvore dourada,
pinheiro, arbusto, rocha com musgo, tufo de grama e flores), 16 poses humanas
em seis papéis e 18 poses de seis criaturas (lobo, gosma, goblin, coelho, cervo
e javali). Recortes personalizados em `assets/cartoon/v041/art.json` seguem os
espaços reais dos atlas; uma grade uniforme cortaria raízes, galhadas e patas.
O manifesto contém SHA256 dos originais e âncoras medidas por pose.

Oito moradores na cidade: sete caminham em rotas curtas e o comerciante fica
no mercado. SpriteFrames compartilhados, sequência 0/1/0/2, pausa nos menus e
interiores. Moradores dos interiores também usam o atlas. Pés permanecem
ancorados, sem oscilação vertical. Criaturas comuns da REG001 usam poses de
caminhada ao se mover; a animação não altera alcance, colisão, níveis ou dano.
Chefes e herói preservam a apresentação existente.

Grama e pedra têm UVs consistentes por coordenada mundial. Repetição espelhada
reduz a emenda da textura; tintas distinguem bosques, floresta e terras altas.
O piso da cidade/jardins permanece em cache 2048², agora em `v041/city_ground.png`.
Os cinco atlas/fontes ilustrados usam compressão S3TC/ETC2 e mipmaps; tufos são
comandos de desenho estáticos, sem criar nós animados por folha.

## Vegetação e encontros

O gerador descartava um chunk inteiro de 1024² se ele tocasse a cidade, mesmo
quando quase toda a área estivesse fora dela. Agora a reserva é verificada
por posição. Estradas, jardins reais, marcos e clareiras de missões continuam
livres. Os centros de props gerados respeitam 68 unidades no mesmo chunk e
margens de 85 unidades nos lados, evitando aglomeração nas fronteiras.

Encontros adicionais têm semente própria, IDs `ENCOUNTER_REG001_x_y_j`,
acampamentos numa grade de 680 unidades com variação determinística, pares
separados por aproximadamente 137 unidades, níveis 1–8 por distância da cidade.
Pontos canônicos de missão são reservados. Os 17 inimigos fixos e seis demônios
existentes continuam com seus IDs e regras. Novos inimigos não aparecem no
núcleo urbano ou jardins reais e não perseguem/atingem o herói nesses lugares.

Pool de 24 atores, limite de 18 ativos, raio de criação 1150, retirada 1500,
atualização a cada 0,6 s e máximo de quatro ativações por atualização. Vida
ferida fica em memória durante a visita, para evitar cura ao descarregar e
recarregar um chunk. Derrotas usam o caminho canônico de dano, XP, loot e
contratos uma única vez. Retorno em cinco minutos, salvo no dicionário de
cooldowns existente com prefixo próprio: formato de save permanece v8.
Vida ferida não é persistida entre encerramentos de sessão, como nos inimigos
comuns anteriores. Flechas, magias e ecos registram a geração do alvo para
não atingir um ator reutilizado. Queimadura é cancelada ao devolver ao pool.

## Medições e limites

Mesmo método antes/depois, Godot 4.6.3, llvmpipe por software, 960×540,
VSync desligado, 40 quadros de aquecimento e 160 amostras por ponto, cena real
com HUD, minimapa e atores ativos. Não é medição em um aparelho Android.

| Local | Chamadas de desenho (mediana) | Tempo por quadro (mediana) |
|---|---|---|
| Praça | 308 → 268 | 20.05 → 21.29 ms |
| Rua residencial | 248 → 197 | 18.55 → 21.75 ms |
| Castelo | 362 → 361 | 21.63 → 24.97 ms |

A quantidade de chamadas caiu na praça e na rua; o custo por quadro desta
medição aumentou com o novo visual e a variabilidade do renderizador por
software. Não há evidência para prometer aumento de FPS no celular. A praça
mantém a redução de aproximadamente 25 mil chamadas obtida na v0.40. Memória
reportada na praça: 66,2 → 69,8 MiB, aproximadamente. Orçamento renderizado da
cidade: máximo 874 chamadas na verificação local, abaixo do limite 2000.

## Verificação e continuidade

42 testes Cartoon locais, verificação de checksums/recortes, 74 amostras de
contato de vegetação/moradores/criaturas, 12 fundações e 208 poses do herói nos
gates de regressão. A revisão contém 11 capturas novas e cinco comparações com
v0.40. O pacote de recursos exportado é carregado de um diretório vazio para
conferir JSON, atlas e animações; isso não gera APK. CI oficial 4.7.2 executa
59 testes nativos e QA ao publicar o commit. Arte permanece
`MODELED_PENDING_VISUAL_APPROVAL`, sem alegar aprovação artística do Diretor.

HUD radial 3, magias independentes, equipamentos, classes, missões e save v8
preservados. APK só sob solicitação explícita. A nova família de natureza e
criaturas foi integrada à REG001; expandir para os outros biomas exige um
passe de direção artística próprio. Próximo refinamento visual deve priorizar
herói/efeitos e decoração de interiores para acompanhar esta referência.

## Regenerar o piso ativo

```sh
godot --headless --editor --path game --import
godot --path game --rendering-method gl_compatibility --audio-driver Dummy \
  --script res://tools/cartoon/bake_city_ground_v040.gd -- \
  "$PWD/game/assets/cartoon/v041/city_ground.png"
godot --headless --editor --path game --import
python3 game/tools/cartoon/validate_pilot_art_v041.py
```

O verificador v0.40 agora resolve o piso ativo pelo preload do ambiente,
preservando a integridade do atlas de construções v0.40 e detectando fonte de
piso desatualizada por SHA256. Os arquivos de piso v0.40 são históricos.

## Skills consultadas e adaptadas

Repositório `thedivergentai/GD-Agentic-Skills`, revisão fixa
`4c4d0ff5c4597938cc9257d99d9e35f7692c9c06`:

- [godot-2d-animation](https://github.com/thedivergentai/GD-Agentic-Skills/blob/4c4d0ff5c4597938cc9257d99d9e35f7692c9c06/skills/godot-2d-animation/SKILL.md): scripts de sincronização e memória lidos; SpriteFrames compartilhados e atualização por frame. `AnimatedSprite2D` não possui `advance(0)` nesta API; foi usado `set_frame_and_progress`, com âncora atualizada pelos sinais. O exemplo correto de `advance(0)` é para AnimationPlayer.
- [godot-performance-optimization](https://github.com/thedivergentai/GD-Agentic-Skills/blob/4c4d0ff5c4597938cc9257d99d9e35f7692c9c06/skills/godot-performance-optimization/SKILL.md): scripts de pooling/culling/foliage lidos; pool adaptado para ciclo de vida, status e geração de alvo, atlas/limites espaciais e medição. O exemplo de MultiMesh é 3D; o terreno 2D usa batching de atlas e cache.
- [godot-tilemap-mastery](https://github.com/thedivergentai/GD-Agentic-Skills/blob/4c4d0ff5c4597938cc9257d99d9e35f7692c9c06/skills/godot-tilemap-mastery/SKILL.md): lida para avaliar composição/navegação. Não aplicada como migração para TileMap; manter o renderizador atual evita reescrever colisões e locais da campanha.

Nenhuma skill externa instalada globalmente. A pesquisa procedural anterior
permanece em `PROCEDURAL_2D_SKILL_RESEARCH.md`.
