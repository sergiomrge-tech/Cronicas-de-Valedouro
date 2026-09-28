# CHECKPOINT — Crônicas de Valedouro v0.6.1 CANDIDATE

**Data:** 2026-09-28

## Estado
A v0.6 foi estabilizada estaticamente sem alterar assets ou gameplay. O pacote permanece candidato até Godot Gate 4.7.2.

## Roadmap técnico
- Sessão 002 — correção de `main.gd`: **IMPLEMENTADA; PASS estático; parser nativo pendente**.
- Sessão 003 — correção de `world_map.gd`: **IMPLEMENTADA; PASS estático; parser nativo pendente**.
- Sessão 004 — abrir/limpar parser no Godot: **PENDENTE do Godot Gate**.
- Sessão 005 — smoke test: **PENDENTE do Godot Gate**.
- Sessão 006 — catalogar assets existentes: **CONCLUÍDA**, 122 IDs persistentes.
- Sessão 007 — exportar/carregar catálogo JSON: **IMPLEMENTADA; teste nativo pendente**.
- Sessão 008 — fechar v0.6.1 estável: **BLOQUEADA somente pelo Godot Gate nativo**.

## Regra visual
O Lote 01 do Claude continua isolado. Os 28 APPROVED são candidatos futuros; 61 REWORKED e 22 HOLD não entram neste build.

## Próxima ação técnica
Executar o pacote candidato no Godot 4.7.2 e rodar as 6 suítes nativas. Se todas passarem, promover sem mudanças de gameplay para v0.6.1 estável.
