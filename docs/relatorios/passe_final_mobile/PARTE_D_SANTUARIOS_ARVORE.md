# Passe visual final mobile — Parte D: Santuários de Raiz + Árvore-Memória (exterior)

## Santuários (os mesmos IDs, remodelados; continuam MODELED_PENDING_GATE)
- **Raiz da Água:** nascente natural. Uma bacia de rochas de tamanhos variados, aberta na frente para o transbordo, substitui a plataforma e a bacia circulares. A lâmina d'água tem contorno orgânico. Uma pedra-altar bruta fica abraçada por quatro raízes que sobem da água. A corrupção mantém água escura e veios.
- **Raiz da Pedra:**
  - Um afloramento em blocos irregulares substitui a laje quadrada.
  - O monólito ficou cravado no afloramento.
  - A ruína ganhou **soco comum aos pilares**: um pilar em pé, um quebrado e a verga caída apoiada no entulho (lógica de desabamento). Nada ficou solto.
- **Raiz do Vento:**
  - O cubo virou um afloramento rochoso em terraços, com **degraus talhados na rocha**.
  - O anel/disco rúnico virou três pedras eretas com runas.
  - Na composição saíram o platô e a rampa de terra. O mirante-caixa virou rocha natural.

## Árvore-Memória — exterior (os mesmos IDs, remodelados)
- **Cavidade real:** corte booleano no tronco em arco ogival orgânico. Paredes, teto, fundo e nervuras internas são de madeira viva, com piso de raízes.
  - Estado fechado: penumbra quente atrás da trama de raízes.
  - Estado aberto: interior iluminado de dentro pela luz de memória, com cogumelos marcando a entrada.
  - O retângulo preto recortado foi eliminado.
- As raízes frontais foram afastadas da abertura, que agora é o foco da árvore.
- O disco d'água (`flo_memory_pool`) saiu da cena. Em seu lugar entrou um **espelho d'água orgânico assado no chão**, que as raízes da árvore invadem.
- **Trilhas convergentes orgânicas:** oeste, leste e uma picada do sul que se junta à oeste.
- **Escala sagrada:** a árvore subiu no quadro com escala 0,68, e as ancestrais vizinhas foram reduzidas (0,42–0,45) para dar contraste. Há pedras memoriais em torno do espelho.
- **Partículas leves** de memória no estado aberto: 18 pontos animados por seno no palco, sem sistema de partículas.

## Validação (Godot 4.7.2 real)
- As capturas estão em `docs/visual_qa/passe_final_mobile/D_santuarios_arvore/`: 6 estados dos santuários, a árvore fechada e aberta, e o detalhe da cavidade.
- Asset QC: 8/8 PASS.
- Suíte: 17/17 PASS. `act02_compositions` dá PASS (362 objetos). `validate_reg001`, `validate_v0_6` e `validate_v0_6_1` dão PASS.
- Nenhum APPROVED foi tocado (continuam 237).
