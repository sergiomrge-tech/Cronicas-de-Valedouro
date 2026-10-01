# Candidata v0.30 — três magias na interface

Pedido do Diretor: Brasa, Cristal e Arcana devem aparecer juntas na interface
e não compartilhar recarga.

Cada magia tem um botão próprio, borda na cor do elemento, nome e estado
PRONTA ou contagem em segundos. A antiga ação TROCAR sai do HUD. Teclas
1/2/3 conjuram diretamente; Q conjura a seleção atual e R continua alternando
para compatibilidade com os comandos anteriores.

O herói mantém três temporizadores separados. Conjurar Brasa gasta somente a
recarga de Brasa: Cristal e Arcana continuam disponíveis. Repetir a mesma
magia durante sua recarga é bloqueado. Cada recarga continua sendo de 3 s,
reduzida pelo talento Foco até 2,2 s, sem alteração dos efeitos elementais,
dano, alcance, bloqueios da campanha ou caminho de recompensas.
Os temporizadores são transitórios, como antes; o formato do save permanece v6.

O HUD usa uma linha com as três magias. Em telas compactas, ela fica acima
da barra de ferramentas; em telas largas, acima dos comandos de combate.
Esquiva e mensagens foram reposicionadas para evitar sobreposição. Menus,
interiores, pausa, morte e esquiva mantêm as proteções de conjuração.

32 testes Cartoon passaram localmente no Godot 4.6.3. O teste novo percorre
as oito regiões, aciona os três botões por touch nativo, verifica os tipos de
projétil, recargas independentes, repetição bloqueada, retorno individual à
prontidão, quatro tamanhos de tela e bloqueios de combate. Testes existentes
de efeitos, foco/classes, layout, história e recompensas também passaram.
A CI inclui 49 testes nativos no Godot oficial 4.7.2 e oito capturas reais
adicionais. [Revisão visual](visual_qa/cartoon_v030/review.html).

Mecânica candidata **PROPOSED**. Não há assets novos: cores e efeitos existentes
são reutilizados. Não gerar APK nesta atualização; a preferência de exportar
somente mediante pedido explícito e entregar ZIP anexado permanece válida.
