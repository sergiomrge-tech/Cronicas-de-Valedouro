# Crônicas de Valedouro — Política de animação e VFX

## Regra obrigatória
Assets estáticos de herói, inimigo ou monstro NÃO são candidatos a runtime.
Eles podem servir somente para conceito, silhueta, equipamento ou modelagem.

## Herói
O personagem jogável deve ter, no mínimo:
- idle;
- walk/run;
- ataque leve;
- ataque pesado ou combo;
- ataque/ranged quando a arma exigir;
- cast de magia/skill;
- hurt/hit reaction;
- dodge/roll;
- death;
- transições coerentes por direção.

Quatro direções são o piso técnico. Oito direções são preferidas quando a câmera/perspectiva justificar.
Para o herói e bosses, priorizar animações ricas: ataques e casts com sequência suficiente para anticipation, action e recovery.
Não criar frames duplicados apenas para inflar a contagem.

## Mobs e bosses
Todo inimigo usado em gameplay precisa de movimento animado e reação de combate.
Mínimo recomendado:
- idle;
- move;
- attack;
- hurt;
- death.
Elites e bosses também devem ter wind-up/telegraph, ataques especiais e recuperação.

## VFX
Skills e magias devem possuir:
- cast/charge quando aplicável;
- projectile/travel quando aplicável;
- impact;
- AoE/ground effect quando aplicável;
- dissipação;
- variações elementais coerentes com a biblioteca oficial de skills.

## Direção artística
Todos os packs externos são REFERÊNCIA / matéria-prima.
Claude/Opus deve adaptar paleta, escala, perspectiva, iluminação, silhueta, leitura e acabamento ao estilo oficial aprovado de Crônicas de Valedouro.
Não promover automaticamente um asset externo a APPROVED.

## Performance mobile
Preferir sprite atlases, AnimationLibrary/SpriteFrames reutilizáveis e pools de VFX.
Evitar overdraw excessivo, partículas caras e efeitos em resolução maior do que o necessário.
