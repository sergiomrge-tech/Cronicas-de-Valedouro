# Retomada automática — Crônicas de Valedouro

Solicitação do Diretor em 02/10/2026: registrar o trabalho, retomar às 02:24 e
voltar após cinco horas caso a franquia impeça a continuidade. Horário pessoal
já registrado nas automações: `America/Sao_Paulo` (Brasília).

## Ponto de partida confirmado

- Fonte ativa: `sergiomrge-tech/Cronicas-de-Valedouro`, branch `main`.
- v0.41 concluída no commit `b0a34a1cf54d70f2c43d13a63146434f469719d5`.
- Godot Gate oficial 4.7.2 aprovado, run `36953786483`: 59 testes nativos,
  208 poses do herói, fundações e QA da área piloto.
- Ler `CLAUDE.md`, `docs/README_CONTINUE_AQUI.md` e `docs/CARTOON_PILOT_V0_41.md`.
- A tarefa anterior está concluída; continuar o passe visual seguinte a partir
  do estado real mais recente do GitHub, sem repetir o que já foi integrado.

## Fidelidade visual obrigatória

O Diretor pediu comparação contínua com as imagens apresentadas. Ler
`docs/CRITERIO_FIDELIDADE_VISUAL.md` antes de criar ou integrar arte. Corrigir
as diferenças de desenho, proporção, paleta, detalhe e animação antes de
concluir cada etapa. PASS técnico não substitui a comparação visual na cena
real. Herói e decoração dos três interiores foram verificados no passe v0.42; ver conclusão abaixo.

## Trabalho a concluir nas retomadas

1. Refinar herói e efeitos de combate para acompanhar a nova referência
   ilustrada de Valedouro. Preservar animações, apoio no chão, classes,
   equipamentos, arco e três magias com recargas independentes.
2. Refinar a decoração dos interiores importantes existentes: taverna,
   ferreiro e guilda. Preservar portas, circulação, serviços, quadro de
   contratos e missões canônicas.
3. Comparar capturas reais com a referência v0.41, verificar legibilidade,
   animação, colisões e orçamento de desenho; corrigir regressões e salvar
   código, assets e registro de progresso no GitHub.

Manter Godot, base 2D Cartoon, HUD radial opção 3 e save v8. Não gerar APK;
nenhum pedido novo de APK foi feito. Não prometer FPS em Android sem medir
em aparelho. Não substituir a campanha por um mapa procedural novo.

## Forma de retomar

- Primeira tentativa: 02/10/2026 às 02:24, horário de Brasília.
- Tentativas seguintes: a cada cinco horas enquanto este passe estiver pendente.
- Consultar o checkpoint atual antes de cada execução e continuar apenas o que
  estiver pendente. Não sobrescrever alterações de outras sessões.
- Ao concluir uma etapa, registrar commit, testes executados, resultado do CI
  e pendências concretas abaixo. Ao concluir as três etapas, desativar a
  automação de retomada para evitar execuções sem trabalho.
- As tentativas dependem da disponibilidade da conta, das ferramentas e do
  ambiente. Não há mecanismo disponível para garantir recuperação da franquia
  nem para executar código enquanto a plataforma estiver bloqueada.

Agendamento concluído e desativado: **Continuar Crônicas de Valedouro**.
A regra registrada é `FREQ=HOURLY;INTERVAL=5`, com início local às 02:24.

## Progresso

- [x] Herói e efeitos refinados e verificados.
- [x] Decoração dos três interiores refinada e verificada.
- [x] QA final, GitHub atualizado e automação desativada após a conclusão.


## Conclusão verificada — v0.42 (02/10/2026)

Passe concluído: herói/armas/efeitos ilustrados e decoração/paredes/piso dos
interiores de taverna, ferreiro e guilda. Originais v0.41/v0.40 intactos.
Código/assets: `740f06d66790e9bfb3e6fd7df8781ee0bbf6f893`.
Ajuste de artifact compacto: `665fbf13626060de4c7b9448389ba600613f78ab`, com a
mesma árvore `game` do runtime. Godot Gate oficial **4.7.2**:
[run 36979976422](https://github.com/sergiomrge-tech/Cronicas-de-Valedouro/actions/runs/36979976422)
**SUCCESS**, 60 testes nativos, 240 apoios de poses e 155 capturas. Gate anterior
36978863902 também aprovado. Local: 43 testes, captura final e pacote de recursos PASS.

Comparação visual executada com originais e cenas reais em 960×540/640×360,
zoom70/150 e oito estados de animação. Diferenças concretas e correções no
relatório; não foi encerrado só por PASS técnico. Revisão compacta oficial
baixada (83 arquivos, 27.793.888 bytes) e conferida; amostras oficiais e hashes
salvos em `docs/visual_qa/cartoon_v042`. Max draw calls 492. Pequenas diferenças
de antialiasing de linhas entre 4.6.3/4.7.2 não alteraram a integração da pintura.

Mantidos campanha/IDs, colisões, nível/dificuldade, classes/equipamentos/arco,
HUD radial opção 3, save v8 e três recargas independentes. Nenhum APK.
Automação **Continuar Crônicas de Valedouro desativada**, retorno da ferramenta
confirmado por consulta. Não há pendência deste passe. Teste físico Android e
aprovação pessoal do Diretor não foram alegados; próximo desenvolvimento deve
seguir um novo pedido, sem repetir v0.41/v0.42.
