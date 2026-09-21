# Meteor Hoops v0.3 — roteiro de playtest

Não ajuste dez números ao mesmo tempo. Faça cada bloco e anote o resultado.

## 1. Fluxo completo
1. Apague o save se quiser simular primeira execução.
2. Abra Modo História.
3. Passe pelas 3 páginas da HQ.
4. Complete as 4 tarefas do tutorial.
5. Jogue até o intervalo.
6. Faça pelo menos uma substituição.
7. Termine a partida.
8. Em derrota, teste Retry.
9. Em vitória, leia a HQ pós-jogo.
10. Volte ao menu e confirme Treino Livre desbloqueado.

## 2. Cronômetros
- Confirme 3:00 no 1º tempo.
- Confirme 18 s por posse.
- Deixe o relógio zerar sem arremessar: a posse deve trocar.
- Faça um arremesso antes de 0: o relógio não deve gerar violação enquanto a bola estiver no ar.
- Pegue rebote ofensivo: relógio deve voltar para 14 s.
- Roube a bola: nova equipe deve receber 18 s.

## 3. Intervalo
- Troque Luma por Nilo.
- Troque Bato por Mako.
- Troque novamente para confirmar que o banco é realmente intercambiável.
- Confirme que o jogador que entra tem stamina cheia.
- Inicie o 2º tempo e confirme Quartz com a primeira posse.

## 4. Overtime
Para testar rapidamente, temporariamente reduza `STORY_PERIOD_SECONDS` em `game_tuning.gd`.
- Termine empatado.
- Confirme OT de 1:00.
- Se empatar de novo, deve surgir outra OT.

## 5. Sensação de jogo
Registre de 1 a 5:
- Movimento
- Sprint
- Passe
- Leitura do alvo de passe
- Defesa
- Roubo
- Arremesso
- Timing
- Contest
- Rebote
- Câmera
- Clareza do HUD

## 6. Critério para v0.4
Só avance para arte/personagens mais detalhados se:
- for possível terminar uma partida sem erro fatal;
- posse e pontuação não travarem;
- 80%+ dos passes forem para o alvo que o jogador esperava;
- arremesso aberto parecer claramente melhor que arremesso contestado;
- IA conseguir criar arremessos sem ficar presa;
- intervalo, vitória, derrota, retry e save funcionarem em sequência.
