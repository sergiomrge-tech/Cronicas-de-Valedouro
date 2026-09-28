# Crônicas de Valedouro

Repositório oficial de desenvolvimento do jogo **Crônicas de Valedouro**.

- Engine: **Godot 4.7.2**
- Alvo principal: **Android / mobile-first**
- Direção: Action RPG 2D top-down, pixel art detalhada e coesa
- Estado atual: base v0.6.x em estabilização e evolução para o primeiro Vertical Slice jogável

## Para ChatGPT e Claude
Leia primeiro **CLAUDE.md** e **docs/README_CONTINUE_AQUI.md**. O repositório contém as regras canônicas, planejamento, checkpoints, código, geradores de assets e testes.

## CI
O workflow **Godot 4.7.2 Gate + Visual QA**:
1. reconstrói a fonte;
2. gera assets reproduzíveis;
3. roda validação estática;
4. baixa o Godot 4.7.2 oficial;
5. roda parser/import e testes nativos;
6. captura várias regiões do mapa para auditoria visual;
7. publica as capturas como artifact;
8. grava a árvore expandida do projeto no repositório quando o Gate passa.
