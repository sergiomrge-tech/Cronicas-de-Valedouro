# Crônicas de Valedouro — Escala de exploração v0.3

## Regra de escala aprovada

A reconstrução 2D cartoon deixa de tratar cada região como uma tela curta.

- Cidade / Hub: alvo linear de **7x** em relação ao protótipo-base.
- Regiões abertas: alvo linear de **15x**.
- Regiões de exploração pesada: até **20x**.
- Dungeons: **3x a 8x**, priorizando densidade.

O núcleo atual do Berço de Valedouro usa uma região de **16100 x 16450** unidades de mundo. O antigo núcleo de 2300 x 2350 foi preservado como distrito central autorado e reposicionado no centro da região.

## Arquitetura

- chunks de 1024 x 1024;
- raio ativo de 2 chunks ao redor do jogador (janela máxima 5 x 5);
- chunks fora do raio são descarregados;
- geração determinística por coordenada;
- o distrito central continua manualmente autorado;
- cinturões externos usam streaming e recebem conteúdo específico conforme avançamos;
- câmera limitada aos limites reais da região;
- colisão/andabilidade do distrito central preservada;
- áreas externas são preparadas para receber bloqueios locais, encontros e POIs.

## Densidade de exploração

O aumento de tamanho não deve produzir terreno vazio. O padrão de produção é:

- estrada principal com marcos frequentes;
- desvios opcionais;
- acampamentos;
- recursos;
- monstros e elites;
- pequenos eventos;
- ruínas, baús e segredos;
- transições naturais entre cidade, campos e regiões seguintes.

## Próximo anel

O próximo conteúdo do Berço de Valedouro deve preencher o corredor Cidade -> Campos do Vale -> cinturão rural -> estrada sul, antes de abrir a transição para a Floresta Ancestral.
