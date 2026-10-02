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
real. Herói e decoração dos interiores permanecem pendentes nesse critério.

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

Agendamento criado e habilitado: **Continuar Crônicas de Valedouro**.
A regra registrada é `FREQ=HOURLY;INTERVAL=5`, com início local às 02:24.

## Progresso

- [ ] Herói e efeitos refinados e verificados.
- [ ] Decoração dos três interiores refinada e verificada.
- [ ] QA final, GitHub atualizado e automação desativada após a conclusão.
