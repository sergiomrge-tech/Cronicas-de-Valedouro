# Crônicas de Valedouro — PC Full HD v0.40

Data: 01/10/2026  
Engine alvo: Godot 4.7.2  
Branch: `pc-fullhd-v040`

## Objetivo

Transformar a base Cartoon atual em uma edição para PC Windows sem remover nem descaracterizar a edição Android.

## Resolução

- Saída padrão Windows: **1920×1080 (Full HD, 16:9)**.
- Base lógica preservada em 960×540.
- Escala inicial exata de 2× para manter proporções, HUD e arte consistentes.
- F11 alterna entre janela e tela cheia.

## Controles PC

- WASD ou setas: mover.
- Clique esquerdo ou Espaço: atacar/disparar.
- E: interagir/coletar.
- Shift: esquiva.
- 1 / 2 / 3: magias.
- Q: magia selecionada.
- R: alternar magia selecionada.
- I: inventário.
- M: mapa.
- J: missões.
- C: classe/habilidades.
- F: forja.
- H: cura rápida.
- Roda do mouse: zoom.
- Esc: menu/voltar.
- F11: tela cheia.

## Interface

No desktop, os grandes controles touch de combate e o joystick virtual são ocultados. HUD de status, missão, minimapa, menus, inventário, mapa e demais interfaces continuam disponíveis.

## Renderização Windows

- API principal: **DirectX 12 / Direct3D 12**.
- Método de renderização no Windows: `mobile` (RenderingDevice), escolhido para reduzir overhead neste RPG 2D.
- Driver Windows: `d3d12`.
- Vulkan permanece habilitado como fallback.
- OpenGL 3 permanece habilitado como fallback final para compatibilidade.
- Android continua usando `gl_compatibility`; a mudança de DirectX 12 é exclusiva do Windows.
- O jogo pode consultar em runtime `RenderingServer.get_current_rendering_driver_name()` para confirmar o driver efetivamente usado.

## Exportação

Preset: `Windows Desktop Full HD`  
Arquitetura: Windows x86_64  
Saída: `build/windows/Cronicas_de_Valedouro_PC_v0.40.exe`

O workflow `.github/workflows/windows-pc-fullhd.yml` valida parser/import, executa testes nativos essenciais, exporta um ZIP portátil contendo EXE+SHA256 e executa um gate adicional em runner Windows para confirmar em runtime `driver=d3d12` e `method=mobile`.

## Estado

A edição PC é uma candidata separada da linha Android. Só deve ser mesclada à linha principal depois de o gate Godot 4.7.2 e a exportação Windows concluírem sem erros.
