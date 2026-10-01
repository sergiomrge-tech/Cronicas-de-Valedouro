# Cartoon v0.24 — herói, criaturas e magias

## Visual e animação

37 folhas originais SVG e um ícone próprio, gerados deterministicamente por `game/tools/cartoon/build_combat_assets.py`. O manifest registra SHA-256 e status MODELED_PENDING_GATE.

Herói: 152 quadros em quatro direções, com parada (4), caminhada (8), ataque (6), conjuração (8), dano (4) e queda/resgate (8) por direção. Armadura azul com placas, detalhes dourados, gema, capa bordada, manoplas, botas, bolsa, rosto e cabelo. Equipamento continua determinando dano, defesa e cor da espada. A recuperação da derrota permanece a existente; a queda é uma camada visual.

Criaturas: 78 quadros distribuídos em 13 tipos; lobos, goblins, slimes, guardiões e nove criaturas/chefes regionais, com cores, coroas, raízes, vestido, machado, tridente, asas, livro e cajado conforme o tipo. Ataques têm impulso e trilha; impactos mostram partículas, números de dano e clarão; derrotas usam silhueta transitória que se dissolve.

## Magias adicionais — PROPOSED

Brasa, Cristal e Arcana possuem apresentações diferentes: chama/cometa âmbar; cristal e floco azul; anéis, runas e fragmentos violeta. Compartilham alcance de 220 unidades, recarga de três segundos e dano de 125% do ataque equipado. Não adicionam classes, alteram lore ou redefinem IDs existentes. São propostas de combate disponíveis nesta versão de teste.

O lançamento reutiliza o ataque de cada região, incluindo seus bloqueios por missão, recompensas, XP, contratos de caça e registro de chefes. Não há dano direto que contorne essas regras. A espada conserva seu alcance anterior. Seleção de magia é temporária e não muda a versão do save.

Celular: MAGIA conjura; TROCAR alterna. Computador: Q conjura; R alterna. Botões são bloqueados com modais, pausa e interiores de construções. Há contagem regressiva de recarga e botão de conjuração desativado durante a espera. Botões possuem alvos de pelo menos 44 px de altura.

## Efeitos e iluminação

Camada aditiva com partículas, círculos e arcos, gradiente radial compartilhado e PointLight2D transitórias. Limites globais de 48 efeitos e oito luzes; todos expiram em até 0,9 s e são liberados ao trocar de cena. O efeito de derrota mantém uma textura compartilhada, não o inimigo nem suas referências de missão.

## Provas e APK

24 testes locais passaram em Godot 4.6.3, sem erros de script/assertion. `cartoon_combat_v024.gd` verifica recursos/quadros, espada versus alcance mágico, recarga, recompensas, locks de missão, pausa, layout em três resoluções, limites e limpeza de FX. A suíte inclui as oito regiões, campanha, inventário, crafting, save e interiores/castelo.

GIFs reais do Godot: caminhada, ataque e três magias; galeria dos monstros; HUD em 960×540 e 640×360. Revisão autossuficiente: `docs/visual_qa/cartoon_v024/review.html`.

APK de teste: versionCode 24, versionName 0.24-test, pacote `com.sergiomrge.cronicasvaledouro.test`, ARM 32/64 bits, Android 7.0+. O workflow Android valida Godot 4.7.2, 24 testes, exportação e assinatura, e publica o APK em uma pré-versão v0.24-test para download direto. Aprovação visual e desempenho/ergonomia em aparelho real continuam pendentes.
