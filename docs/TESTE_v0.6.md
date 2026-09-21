# PLAYTEST — v0.6

## 1. Seleção de trio
1. Abra qualquer jogo liberado.
2. Tente marcar quatro atletas: o quarto deve ser recusado.
3. Deixe apenas dois: o botão de iniciar deve ficar desativado.
4. Escolha exatamente três e inicie.
5. Volte ao menu e abra outro jogo: a última escalação deve reaparecer.

Critério: a seleção precisa ser impossível de quebrar e o trio em quadra deve corresponder ao menu.

## 2. Dificuldade
Faça 20 arremessos em cada modo.

- Aventura: green release deve ser perceptivelmente mais permissivo.
- Liga: referência de equilíbrio.
- Meteoro: timing mais rígido e IA adversária mais rápida para decidir.

Critério: a diferença deve ser sentida sem mudar os atributos básicos dos personagens.

## 3. Acessibilidade
- Desative feedback detalhado e confirme que o jogo não mostra contest/Q no arremesso.
- Ative redução de VFX e use o Instinto Meteoro.
- Ative alto contraste e confirme linhas mais legíveis na quadra.

## 4. Box score
Durante uma partida, force ações fáceis de conferir:
- faça 2 cestas com o mesmo jogador;
- dê 1 assistência;
- pegue 1 rebote;
- tente 1 roubo bem-sucedido;
- tente 1 toco bem-sucedido.

Compare com a tela final.

Critério: não pode existir ponto convertido sem FGM nem assistência atribuída ao próprio cestinha.

## 5. Linha de três
- Arremesse imediatamente antes e depois da linha.
- Compare o feedback 2PT / 3PT.

Critério: a marcação visual deve ser coerente com `THREE_POINT_DISTANCE`.

## 6. Tidefang
Jogue 15 posses contra a Tidefang.

Observe:
- inversões frequentes sob pressão;
- alas mudando de lado fraco;
- passes mais rápidos;
- defesa ligeiramente rotativa.

Pergunta principal: sem olhar o nome do time, o comportamento parece diferente de Quartz, Canopy e Ember?

## 7. Animações placeholder
Confira corrida, arremesso, bandeja, enterrada e toco.

Critério: a animação deve melhorar leitura sem alterar collider ou quebrar a física.

## Critério de aprovação da v0.6
A build pode avançar quando seleção, save, box score e configurações estiverem confiáveis e a Tidefang ensinar claramente o conceito de inversão de lado.
