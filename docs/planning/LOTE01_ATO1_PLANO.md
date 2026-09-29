# LOTE 1 — Ato I · O Segundo Viajante · Berço de Valedouro (plano artístico)

Fontes: `docs/canon/MAIN_STORY_CANON_v1.md`, `MAIN_STORY_SCENES_v1.md`, `MAIN_STORY_CONSTRUCTION_PLAN_v1.md`, `game/data/main_story_v1.json`, `game/data/story_locations_v1.json` (copiados de `origin/gpt-nonvisual-etapa2`, somente leitura). Skills: `.claude/skills/valedouro-map-logic`, `docs/art/VALEDOURO_PRO_ART_MODELING_SKILL.md`. Status de tudo o que sai daqui: `MODELED_PENDING_GATE` (nada vira APPROVED sem o Diretor).

## 1. Leitura e resumo
Ato I (níveis 1–12): o herói cai fora das muralhas durante um ataque menor da Coroa Oca (Cena 1), é abrigado pela Guilda como "estrangeiro sem reino", faz um contrato de lobos ao norte, vê as Ruínas do Primeiro Vento reagirem a ele ("Se você consegue ler isto, então eu não fui o único" — assinatura "A. Vale", Cena 2), derrota o Alfa da Matilha (que carrega o mesmo padrão de Eco), desce à Mina do Eco, derrota o Guardião do Eco, recebe o Fragmento do Primeiro Mapa e o leva ao Arquivo das Seis Coroas, onde surge o nome Adrian Vale (Cena 3). Virada: o protagonista não é o primeiro humano em Elyndor.

Visual do ato: terra de guerra "cotidiana" — segura, calorosa e usada (azul/dourado do reino, madeira e pedra), mas com marcas de ameaça crescente do portão para fora (barricadas, sinais de ataque, rastros), e um subsolo antigo com Eco (azul-ciano) que contradiz a rotina.

Decisões de reconciliação com o mapa atual (registradas para o Diretor):
1. **Mina do Eco = entrada no Vale sul** (`existing_poi = REG001_POI_CRIPTA_ENTRADA`, "abaixo de Valedouro") e o interior é a masmorra do Guardião (`LOC_ECHO_MINE_CORE ← REG001_POI_DG_CHECKPOINT`). O portão de dungeon que eu havia posto nas Ruínas (sessão anterior, baseado no LEVEL_DESIGN v1) é **removido**: o canon novo faz das Ruínas um local de investigação, não de dungeon.
2. A antiga **Cripta Esquecida** continua como galeria lateral opcional selada da própria mina (mesmo complexo, grade de pedra), sem perder o conteúdo e o lore 12.
3. **Clareira do Alfa** = adaptação da Clareira do Ancião (elite Lobo Ancião → "Alfa da Matilha", mesmo padrão de Eco das ruínas).
4. **Portão de Valedouro** = portão norte da muralha (por onde chega quem vem da Floresta da Queda), `existing_poi` vazio → novo POI de marco.
5. **Arquivo das Seis Coroas** = `TO_BUILD`: construção nobre nova ao lado da praça do monumento + interior próprio.

## 2. Plano artístico por local

### LOC_VAL_GATE — Portão de Valedouro (`fortification`, Q_MS01_ARRIVAL, Q_MS05_SIEGE)
- **Função narrativa:** chegada do protagonista; fronteira entre segurança relativa e mundo em guerra; marco de retorno e palco do cerco no Ato V. **Gameplay:** entrada da cidade, ponto de fast travel futuro, zona de segurança.
- **Bioma/clima:** cidade/campo aberto, fim de tarde de guerra, fumaça leve. **Paleta:** pedra ocre + azul real + dourado; madeira escura; laranja de tocha.
- **Leitura:** pórtico fortificado (gate APPROVED) ladeado por torre de vigia de madeira e pedra, barricadas de estacas em ziguezague deixando passagem, bandeiras altas rasgadas, pilhas de suprimentos, trecho de muralha danificado por ataque anterior.
- **Estados:** pré-missão = barricadas e sinais de ataque; pós = torre e bandeiras íntegras + suprimentos organizados (variação `val_barricade_*` intacta/quebrada).
- **Entorno:** antepátio pavimentado (zona civil) → estrada de terra batida (zona externa) com sulcos de carroça, cercas baixas, moitas, lampiões.

### LOC_VAL_GUILD — Guilda dos Aventureiros (`service_building`, Q_MS01_GUILD)
- **Função:** hub e registro do herói; contratos/rank. **Gameplay:** interior com balcão, quadro de contratos, mestre da guilda.
- **Clima:** acolhedor, robusto, usado. **Paleta:** madeira quente, pedra clara, telhado azul, dourado do emblema.
- **Leitura:** salão de dois pavimentos em madeira sobre base de pedra, placa pendurada com espada e bússola, toldo, porta dupla, quadro de contratos externo.
- **Entorno:** pátio com suporte de armas, boneco de treino, bancos, barris, poço, canteiros; trilha à praça.
- **Estados:** pré = contratos abertos; pós = mais papéis/troféus (variação de props).

### LOC_VAL_NORTH_ROAD — Estrada Norte (`road`, Q_MS01_WOLVES)
- **Função:** primeira zona de risco (contrato de lobos), apresentação do Eco na fauna. **Gameplay:** trilha com clareiras, moitas e pontos de emboscada.
- **Clima:** tenso, mata mais fechada. **Paleta:** verdes escuros, terra úmida, vermelho sangue seco pontual.
- **Leitura:** carroça tombada, cerca/paliçada quebrada com arranhões, placas de aviso com trapos vermelhos, ossadas, acampamento abandonado, rastros de patas.
- **Estados:** pré = ameaça visível; pós = rastros/ossadas reduzidos (variações de decalques).

### LOC_FIRST_WIND_RUINS — Ruínas do Primeiro Vento (`ruins`, Q_MS01_FIRST_WIND, Cena 2)
- **Função:** primeira pista do Primeiro Viajante. **Gameplay:** examinar o mecanismo/altar, lore, âncora de exploração.
- **Clima:** antigo, estranho, musgo e raízes. **Paleta:** pedra cinza-violeta, verde musgo, ciano-Eco das runas.
- **Leitura:** arco quebrado com raízes, obeliscos, **mecanismo de pedra com placa rúnica**, **parede de inscrições** que acende ("A. Vale" danificado), piso circular rachado, altar.
- **Estados:** pré = runas apagadas; missão = runas acesas (emissão); pós = mantém brilho tênue.
- **Entorno:** clareira tomada pela natureza, pedras caídas, monólitos menores.

### LOC_ALPHA_CLEARING — Clareira do Alfa (`arena`, Q_MS01_ALPHA)
- **Função:** primeiro boss (Alfa da Matilha), padrão de Eco igual ao das ruínas. **Gameplay:** arena natural ampla (raio ≈170 px), múltiplas entradas, cobertura leve.
- **Clima:** território de predador. **Paleta:** verdes pisoteados, terra, ossos claros, ciano tênue no círculo de pedras.
- **Leitura:** círculo de pedras rúnico (já existente) no centro, **toca da matilha** (fenda de rocha com ossos), pilhas de ossos e crânios, solo pisoteado com rastros, anel de árvores e pedras.
- **Estados:** pré = território marcado; pós = revanche/caçada (mesma arena).

### LOC_ECHO_MINE — Mina do Eco (`dungeon_entrance` + interior, Q_MS01_MINE)
- **Função:** dungeon do Ato I; inscrições sobre "homem de outro céu". **Gameplay:** entrada + percurso (galeria de entrada → câmara de bombas → bifurcação → câmara do elite → arena).
- **Exterior:** talude de rocha no Vale sul, **portal de madeira e pedra com suportes**, trilhos, vagonete, guincho, pilhas de minério com veios de Eco, lampiões, galeria lateral selada (cripta opcional).
- **Interior:** piso de cascalho/terra, paredes de rocha com vigas, arcos de madeira, trilhos, maquinário antigo, veios brilhantes, lanternas.
- **Paleta:** marrom-terra, madeira envelhecida, ferro, **ciano-Eco** como única luz mágica.

### LOC_ECHO_MINE_CORE — Câmara do Guardião (`boss_arena`, Q_MS01_GUARDIAN)
- **Função:** clímax do ato; Fragmento do Primeiro Mapa. **Gameplay:** arena aberta, pilares como cobertura, telegraph legível.
- **Leitura:** **núcleo de Eco** (cristal alto com anéis) no centro do fundo, anel rúnico no piso, plataformas/pilares, fissuras luminosas, detritos de mineração, símbolos antigos.
- **Estados:** pré = núcleo dormente; luta = fissuras acesas; pós = revanche + crafting.

### LOC_SIX_CROWNS_ARCHIVE — Arquivo das Seis Coroas (`archive`, Q_MS01_ARCHIVE, Cena 3)
- **Função:** primeira grande revelação histórica (Adrian Vale). **Gameplay:** interior para exibir o Fragmento do Primeiro Mapa e ler o registro; depois codex.
- **Clima:** solene, intelectual, político. **Paleta:** pedra nobre clara, madeira escura, azul real e dourado, luz de lamparinas.
- **Exterior:** fachada com colunas, **seis emblemas de coroa**, escadaria, lâmpadas ornamentais, pátio junto ao monumento.
- **Interior:** estantes altas com rolos, mesa de mapas, atril com livro, pedestal do Fragmento do Primeiro Mapa, arquivista.

## 3. Lista de produção
Ver `docs/art/LOTE01_ATO1_MANIFESTO.md` (gerada ao final do lote): IDs, tipo (modular/landmark/prop/decalque), novo × reaproveitado, local de uso.
