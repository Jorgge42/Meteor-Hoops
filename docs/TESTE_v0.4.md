# PLAYTEST — METEOR HOOPS v0.4

Faça os testes abaixo antes de alterar números em `data/game_tuning.gd`.

## 1. Pontuação 2/3
- Faça 10 arremessos claramente dentro da distância de 3 pontos e confirme 2 pontos.
- Faça 10 arremessos claramente fora e confirme 3 pontos.
- Observe se a transição é previsível visualmente mesmo sem linha final de quadra.

## 2. Finalizações
- Teste K perto do aro com Kiro, Luma, Bato e Mako.
- Confirme que jogadores fortes/altos têm maior tendência a enterradas.
- Verifique se K longe do aro recusa a ação sem perder a posse.

## 3. Tocos
- Tente 20 tocos em arremessos rivais.
- Registre quantos ocorreram cedo, dentro da janela e atrasados.
- Meta inicial: toco deve ser poderoso, mas não uma ação automática.

## 4. Proteção de bola
- Segure E com bola enquanto um defensor pressiona.
- Confirme redução de velocidade e consumo de stamina.
- Compare pelo menos 20 tentativas de roubo com proteção e 20 sem proteção.

## 5. Instinto Meteoro
- Encha o medidor com ações variadas.
- Ative com F.
- Confirme duração aproximada de 6 s, reset do medidor e bônus perceptível sem virar invencibilidade.
- Observe a frequência: em uma partida de 6 minutos, o ideal inicial é 1–3 ativações por equipe, não uma ativação por posse.

## 6. Espécies
- Kiro: compare velocidade em transição longe da cesta.
- Luma: faça arremessos livres e contestados para perceber a passiva.
- Bato: compare rebotes e tocos.
- Nilo: coloque-o no intervalo e compare deslocamento.
- Mako: coloque-o no intervalo e teste proteção/finalizações.

## 7. Jogo 2
- Jogue Quartz Academy e depois Canopy Institute.
- A pergunta central é: **sem olhar o nome do time, você sente que o adversário está se comportando de maneira diferente?**
- Se não, aumente a personalidade tática antes de criar o Jogo 3.

## 8. Rota e save
- Vença o Jogo 1 e confirme desbloqueio do Jogo 2.
- Feche e reabra o projeto; confirme persistência.
- Vença o Jogo 2 e confirme que o Jogo 3 aparece desbloqueado, porém marcado como em desenvolvimento.
- Rejogue partidas concluídas e confirme que o progresso não regride.

## Critérios para aprovar v0.4
A build pode avançar quando:
1. uma partida completa não entra em estado impossível;
2. 2/3 pontos são consistentes;
3. bandeja, enterrada e toco são compreensíveis;
4. Instinto Meteoro é raro o suficiente para parecer especial;
5. Quartz e Canopy têm leitura tática diferente;
6. save e mapa de campanha funcionam em reinicialização.
