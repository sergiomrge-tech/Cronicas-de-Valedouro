# Passe ilustrado v0.42 — herói, magias e interiores

Checkpoint de 02/10/2026. Base remota preservada: `8c98f75d451a23fb21d1f16bfdf3f00ef5295521`.
A v0.41 no commit `b0a34a1cf54d70f2c43d13a63146434f469719d5` já estava concluída;
nenhuma reimplementação de sua área piloto foi feita.

## Resultado integrado

15 PNGs originais em `game/assets/cartoon/v042`, com SHA256, regiões e âncoras
medidas em `art.json`. As referências v0.41 e `v040/buildings.png` permanecem
inalteradas e verificadas pelo lock existente. Corpo pintado com cabelo loiro,
capa azul, couro, placas de prata e ornamentos dourados, seguindo a riqueza e
perspectiva das pessoas v0.41. Três vistas-base de 16 poses; quatro poses extras
de arco frontal/traseiro; esquerda espelha a direita. Os 240 quadros lógicos
mantêm os temporizadores e oito estados existentes. Isso não representa 240
desenhos únicos: quadros reutilizam poses, com respiração sutil no repouso.

Espada, arco e aljava pintados; corda acompanha a mão que puxa, flecha aparece
antes da soltura. Paleta seletiva conserva o sombreado das placas para tiers
existentes; detalhes de equipamento acompanham cabeça/corpo. Não foram criadas
roupas completas distintas para cada classe. Magias Brasa, Cristal e Arcana
usam quatro fases pintadas cada, foco na palma e luzes existentes. Permanecem
os limites de 48 efeitos e oito luzes, projéteis, dano e recargas independentes.

Taverna: mobiliário de carvalho, tapeçaria, mesas servidas e janelas quentes.
Ferreiro: pedra, forno, bigorna, bancada independente com ferramentas e armas.
Guilda: estantes, brasões, mesa de mapas, balcão com documentos e quadro de
sete avisos. Paredes distintas e piso pintado completam as salas. Mantidos
serviços, NPCs, portas, posições e colisores: 18/12/11 bloqueadores respectivamente.
Castelo e campanha não foram redesenhados neste passe. HUD radial opção 3,
IDs, classes, crafting, dificuldade por nível e save v8 foram preservados.

## Comparação visual executada e correções

Abra [o comparador com originais e cenas reais](visual_qa/cartoon_v042/review.html).
As 155 imagens foram renderizadas no Godot, não são propostas geradas. Incluem
960×540 e 640×360, zoom 70/150, 60 imagens da sequência de animações com quatro
vistas e espada/arco, 64 estados na cena com HUD, três salas e as três magias.
Os estados são forçados pelo diagnóstico para comparação; não são gravação de
uma partida normal nem prova de desbloqueio de habilidades no nível 1.

Diferenças concretas encontradas e corrigidas antes deste checkpoint:

- Espelhamento deslocava o herói lateralmente: retângulo negativo corrigido.
- Botas/cabelo de poses vizinhas vazavam no atlas traseiro: original regenerado
  com espaços maiores; regiões medidas novamente e apoio conferido.
- Capacete e marcas antigas flutuavam sobre o novo desenho: ajustados à cabeça,
  corpo e pés; arma recolhida durante magia, dano, morte e esquiva.
- Arco frontal/traseiro apontava de lado: quatro novas poses com perspectiva
  correspondente; corda medida entre pontas e mão, soltura alinhada.
- Luz aditiva lavava os núcleos das magias: textura pintada usa mistura normal
  sem iluminação, enquanto o brilho externo conserva o efeito luminoso.
- Foco da magia não seguia a palma: nó próprio atualizado com a mesma pose.
- Bancada cortada e chama de mesa recortada: bancada original independente e
  região da mesa ampliada. Lanterna completa substitui cadeia cortada do atlas.
- Guilda herdava bebidas e comida: balcão de contratos e mesa de planejamento
  próprios. Janelas planas antigas: três faixas de parede pintadas distintas.
- Aljava antiga geométrica destoava: nova aljava pintada com couro e penas.
- Em 640×360/zoom150 o HUD cobria a cabeça: câmera ganha compensação vertical
  limitada, sem trocar o layout nem a faixa de zoom.

Regiões de atlas não cortam formas opacas; sombras e âncoras dos pés foram
conferidas. O quadro de missões foi fotografado também perto da parede norte.
Móveis grandes podem sair do enquadramento em 640×360/zoom150; isso é corte da
câmera, não corte da arte. O quadro inteiro aparece no comparador a 960×540 e
na galeria de móveis. A leitura de detalhes diminui naturalmente no zoom70;
a arte não foi simplificada para produzir essas imagens.

## Evidência e limites

Ambiente executado: Godot 4.6.3, OpenGL Compatibility, Mesa llvmpipe, Linux.
Validador readonly de SHA/recortes/âncoras/importação S3TC/ETC2+mipmaps: PASS.
Captura final: PASS, 240 apoios de poses, 155 PNGs, máximo 492 chamadas de desenho.
Benchmark real da cidade: praça 263 chamadas/21,474 ms medianos; residencial
192/22,842 ms; castelo 356/25,852 ms. VRAM ~98,9 MiB neste driver contra ~69,8 MiB
no passe anterior; a arte tem custo de textura e está comprimida. Essa medição
Linux com software rendering não demonstra FPS nem memória de um celular.

43/43 testes nativos locais passaram após as alterações finais, incluindo
classes/equipamentos, campanha, save v8, três recargas, colisões e novo teste
de integração. Exportação de pacote de recursos ZIP: exit 0; carga em pasta
vazia: PASS para JSON, atlas, shader e cache v0.41, sem o código-fonte. Esse
pacote de recursos não é um APK nem valida a instalação Android. Gate oficial 4.7.2 e revisão de suas capturas pendentes neste
checkpoint. Nenhum APK foi gerado. Aprovação pessoal do Diretor e teste em
aparelho não foram alegados. O escopo ilustrado do herói e das três salas foi
comparado; o restante das regiões não recebe uma aprovação visual nova aqui.

## Checkpoint após o primeiro gate oficial

Código/assets: `740f06d66790e9bfb3e6fd7df8781ee0bbf6f893`. Godot Gate
`36978863902`: SUCCESS, engine executada `4.7.2.stable.official.ed1daf0bf`,
60 testes nativos, 240 apoios e 155 capturas aprovados. O download direto do
artifact foi recusado (403); o conector retornou o arquivo de 91 MB, mas a
transferência ao executor limita arquivos a 32 MiB. Não foi alegada inspeção
dessas imagens oficiais. Capturas locais reais já foram comparadas.

Próxima ação: workflow publica também revisão compacta (<31 MiB), conservando
a completa. Código/assets do jogo não mudaram nesta correção de entrega de QA.
Comparar as imagens oficiais compactas e registrar conclusão. Automação ativa.
