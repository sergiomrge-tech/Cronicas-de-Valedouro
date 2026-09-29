# REG_001 — Level design por região, relevo e transições de bioma

Status: implementação técnica (não altera arte APPROVED). Gerado por `game/tools/reg001/build_world.py` (formações) e `game/tools/terrain/bake_ground.py` (chão + grade de bioma).

## Princípios
1. **Cada região tem um foco, massas de apoio, pequenos props e espaço negativo** (respiro para circulação).
2. **Relevo é composição, não espalhamento**: cristas e paredões em linha (com vãos), mesas com colinas de pé, terraços em degraus, anfiteatros ao redor de elites, gargantas ao lado das rotas.
3. **Nada bloqueia trilha, POI, vau, ponte ou zona de exclusão** (`_elev_ok`); a peça que bateria numa passagem some, o que abre vãos naturais. O BFS de `tests/reg001_world.gd` garante conectividade (4975 células).
4. **Transição de bioma é gradiente**: cor (harmonização de baixa frequência no chão assado) + vegetação (ecótono via `reg001_biome_grid.json`); nunca linha reta.
5. Jogabilidade permanece plana; peças elevadas são sprites com colisores compostos.

## Transições (chão + vegetação)
- Chão: fronteiras com campo de aviso largo (`warpL` ±115 px) → `blend_regions` (blobs) → `harmonize` (mistura a cor de baixa frequência entre famílias, sigma 60 px, faixa de proximidade 90 px, preserva grão/tufos).
- Vegetação: `world_map.veg_biome(x, y)` usa a família dominante da grade de 32 px e mistura a família vizinha com probabilidade `(4 − d)/8` (d = distância em células até a fronteira; 50% na linha, 0% a 4 células). Props, tipos de asset e `obstacle_at` usam o mesmo bioma visual do piso.
- Decalques por terreno (`WORLD_RULES`: relva seca na areia, relva gelada na neve, musgo, pedrinhas) entram sobre o piso já harmonizado; decalques específicos de ecótono ficam como próximo passo.

## Regiões
| Região | Foco | Massas de apoio (relevo) | Espaço negativo / circulação | Segredos e vistas |
|---|---|---|---|---|
| Bosque (floresta) | Clareira do Ancião, Ruínas do Primeiro Vento | Cristas de pedra ao sul e ao norte da estrada, mesa rochosa, árvores densas em maciços | Trilhas largas até acampamento, casa e mirante da torre | Passagem na mata fechada, baú do lenhador |
| Campos | Vila dos Campos, Fazenda | Colinas suaves e terraço baixo entre cercas | Campo aberto ao redor da fazenda, estrada leste-oeste | Baú da fazenda, celeiro |
| Vale | Aldeia, Santuário, Cripta | Crista norte, anel de colinas em volta do santuário, patamares rochosos ao sul, colinas a leste | Planície central da aldeia, vau do rio | Entrada da cripta ao sul, Jardim da Flor Ancião |
| Pradaria / Colinas leste | Estação das Colinas | Cordilheira baixa ao norte, dois terraços em degraus, colinas ao sul | Estrada mercantil e ponte central livres | Vista para o gelo e para o deserto |
| Gelo | Círculo de Gelo (elite), Pouso da Geada | Muralha glacial a oeste (divisa com o Bosque), anfiteatro de paredões ao norte do Círculo, garganta a leste da Passagem Estreita, muralha norte com vãos | Rota N‑S pela garganta, planície do Pouso | Gruta Congelada (nordeste), Mirante das Geadas sobre mesa de gelo |
| Deserto | Caravana de Âmbar, Ruínas das Dunas, Oásis | Serra ao sul, cânion (duas paredes com corredor) a leste da caravana, três mesas | Dunas abertas entre a caravana e as ruínas | Duna Móvel (leste), baú enterrado, arco natural |

## Peças de relevo (`build_world.py`)
`poly` (cadeia de cristas/paredões + colinas de pé + tampas), `mesa`, `terraces`, `arc`, `scatter`, todas por `best(region, fn, ...)`: testa deslocamentos ≤ 90 px, mantém o que coloca mais peças e prefere o menor deslocamento (âncoras são sugestões). Total atual: 104 peças (antes 45).

## Pendências propostas (aguardam ordem do Diretor)
- Assets de relevo dedicados (colinas amplas que casem com a cor do piso, tampas/cantos de penhasco, rampas) — hoje reaproveita o kit MODELED_PENDING_GATE.
- Camada de altura real (sombras projetadas do relevo no chão) — hoje só `macro_shade` no bake.
