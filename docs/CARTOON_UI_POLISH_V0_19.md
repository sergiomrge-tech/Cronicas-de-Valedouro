# Crônicas de Valedouro — Polimento de Interface v0.19

## Problema encontrado em QA real
As capturas reais do Godot 4.7.2 mostraram que controles adicionados diretamente a `PanelContainer` podiam ser reorganizados pelo sistema de containers. No painel de zoom isso comprimia os botões e deixava praticamente apenas o controle “1:1” visível.

## Correção estrutural
A v0.19 introduz uma camada `Control` interna nos painéis que precisam de posicionamento livre:

- Menu principal → `MenuContent`;
- Opções → `OptionsContent`;
- confirmação Novo/Excluir → `ConfirmationContent`;
- Inventário → `InventoryContent`;
- Forja → `CraftingContent`;
- Zoom → `ZoomContent`.

O `PanelContainer` fica responsável apenas por moldura/fundo, enquanto o `Control` interno preserva posição e tamanho dos elementos.

## QA visual dedicado
Novo script:
`game/tests/qa_capture_cartoon_ui.gd`

Gera 8 capturas reais:
1. menu sem save;
2. menu com save;
3. opções;
4. confirmação de exclusão;
5. inventário aberto no menu;
6. HUD + zoom durante o jogo;
7. inventário durante o jogo;
8. forja durante o jogo.

Artifact do CI:
`valedouro-cartoon-ui-v019`

## Teste estrutural
`game/tests/ui_layout_v019.gd` verifica a existência dos containers internos e o estado correto dos botões do menu.

## Versão
APK de teste e export preset passam a usar **0.19-test**.
