# v0.38 — Combate Radial

Direção escolhida pelo Diretor: opção 3 da prancha de HUDs, vermelho e dourado,
com retrato destacado, atalhos verticais e magias em arco à direita. O pedido
abrange todas as interfaces, especialmente o inventário. O Diretor também
solicitou explicitamente a geração de APK e a comparação visual antes da entrega.

## Implementação

- HUD compartilhado pelas oito regiões: retrato, vida vermelha, XP azul, bolsa,
  mapa, missões e menu na coluna esquerda; objetivo no alto; minimapa circular.
- Brasa acima à esquerda do ataque, Cristal acima à direita e Arcana à direita.
  Ícones, rótulos e indicadores de recarga independentes. Espada/arco alteram o
  ícone de ataque; cada botão conserva seu hitbox nativo e bloqueios de combate.
- Minimap renderiza o mundo real em SubViewport de 128×128, atualizado a 10 Hz
  apenas quando visível, com marcadores da missão e dos inimigos.
- Menu, opções, confirmação de exclusão, inventário, consumíveis, forja, missões,
  guilda, classes, habilidades, mapa, pausa e escolha final usam a mesma skin.
- Forja e zoom acessíveis em MENU. Abrir a forja encerra a pausa corretamente.
- Sete posições de equipamento e ação de equipar/usar com áreas maiores para
  toque; personagem, comparação, ouro, filtros e rolagem preservados na bolsa.
- Save v8, campanha, progressão 1/10/25 das magias, equipamentos e dificuldade
  preservados. O mockup foi usado como direção da interface; cenário e conteúdo
  do jogo continuam sendo renderizados pelo mundo e pelos sistemas reais.

## Validação e comparação

40 testes Cartoon passaram localmente no Godot 4.6.3. O teste novo percorre as
8 regiões em 5 resoluções (640×360 a 1024×768), verifica áreas de toque, ausência
de interseção entre controles, minimapa, inventário e transição pausa→forja.
Os testes de combate verificam recargas independentes e toque nas três magias.
As verificações anteriores de sobreposição agora desconsideram controles que
ficam ocultos dentro da pausa; as posições desses controles são verificadas
quando a pausa está aberta.

`qa_capture_radial_v038.gd` produz 30 capturas reais, incluindo todas as telas
principais em desktop e celular. A revisão inclui a prancha original e as
capturas, sem substituir screenshots reais por imagens geradas. A proporção
ultralarga da prancha é adaptada às telas de celular; não se declara igualdade
pixel a pixel de uma ilustração estática com o jogo interativo.

CI executa 57 testes no Godot oficial 4.7.2 e todas as capturas. O workflow Android
executa os 40 testes Cartoon e gera v0.38 somente por acionamento explícito.
Desempenho e instalação em aparelho físico não foram medidos neste ambiente.

## Arte e entrega

Molduras, orbes, retrato e glifos vetoriais em `game/assets/ui/radial/`; emblemas
mágicos gerados a partir da referência. Fonte DejaVu Sans Condensed Bold com
licença incluída no repositório e no export. Arte de UI: candidata visual.

Entrega solicitada: ZIP nativo nesta conversa com APK e SHA256. Se o Android
salvar o ZIP com nome `content`, renomear para `Valedouro.zip` antes de extrair.
A chave de teste do workflow é gerada a cada execução: uma instalação anterior
com outra assinatura pode precisar ser removida, o que apaga o save local.

Integração sobre `6982159` (v0.37): coleta, cura rápida, níveis de equipamento,
feedback de level up, troféus e fases de chefes preservados.

Revisão final: informações longas de equipamentos têm rolagem própria;
barra e legenda do chefe não se sobrepõem. Mais quatro capturas de chefe
foram incluídas na revisão da integração.
