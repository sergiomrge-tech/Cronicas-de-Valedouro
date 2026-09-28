# Crônicas de Valedouro — Godot v0.6.0 experimental

Projeto Godot 4.x original para Android horizontal. Esta versão parte diretamente da v0.5 parcial e concentra o trabalho no enriquecimento do mapa e dos monstros, mantendo a identidade visual já aprovada.

## O que mudou na v0.6

O mundo externo continua com 3072×2304 px, mas agora possui rio com largura variável, água rasa e margens, três pontes, Vale dos Lírios, dunas mais variadas, cristais de gelo, juncos e vegetação seca. Oito marcos arquitetônicos foram adicionados e usam a mesma escala, contorno, sombra e paleta da base: torres de vigia, arco antigo, moinho, santuário, posto de âmbar, ruína das dunas e abrigo da geada.

A população hostil também foi expandida. Além de Lobo, Limo, Escorpião, Lobo de Gelo e Guardião, existem Aranha Sombria, Javali Musgoso, Flor Voraz, Escaravelho Âmbar e Golem de Geada. As dez criaturas usam folhas completas de 40 quadros, organizadas em cinco estados de oito frames: repouso, caminhada, ataque, dano e morte. Os pools variam por bioma e nível para evitar que monstros e loot avançados acelerem demais o começo da campanha.

## Controles e fluxo atual

Importe `project.godot` no Godot 4.3+ e execute `scenes/Main.tscn`. A base continua mobile-first: joystick à esquerda, ataque/interação/poção à direita, inventário e mapa no topo. Teclado de teste: WASD/setas, J/espaço para atacar e E para interagir.

A guilda mantém o primeiro contrato de três lobos e o fluxo para o Guardião. O mapa aberto pode ser explorado fora da estrada; água e obstáculos visíveis bloqueiam a passagem, enquanto as pontes são transitáveis.

## Arquivos importantes

- `scripts/world_map.gd`: biomas, rio, margens, três pontes, construções, props e colisão determinística.
- `scripts/main.gd`: render, IA, pools regionais, animações de 40 quadros, combate e interface.
- `scripts/loot_system.gd`: materiais, requisitos e chances baixas de equipamento por espécie.
- `tools/generate_enrichment.py`: reproduz terrenos, props, construções e as dez folhas 5×8.
- `tools/validate_v0_6.py`: validação estática sem Godot.
- `tests/monster_animation.gd`: teste nativo das folhas completas e das novas espécies.
- `CHECKPOINT_v0_6.md`: estado exato desta entrega e próximos testes obrigatórios.

## Estado de validação

A geração dos assets e a validação estática passaram neste ambiente. Não há executável Godot disponível aqui, então esta versão ainda precisa ser importada e executada no Godot antes de ser tratada como build aprovada. Não foi criado screenshot falso nem foi afirmado teste Android/FPS que não ocorreu.
