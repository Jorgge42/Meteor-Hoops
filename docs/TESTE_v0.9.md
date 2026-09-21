# Playtest v0.9 — Luzes Apagadas

## Preparação

- Use Godot 4.7.2.
- Faça uma cópia de `user://meteor_hoops_save.json` se quiser preservar o progresso.
- Para acesso normal ao Jogo 7, vença o Jogo 6.
- Teste ao menos uma vez em ADVENTURE e uma vez em METEOR.

## Roteiro principal

### 1. Campanha e história

- Confirme que o mapa anuncia Jogos 1–7 jogáveis.
- Abra o Jogo 7 e avance pelas três páginas da HQ pré-jogo.
- Após uma vitória, confira a HQ pós-jogo e o desbloqueio narrativo do Jogo 8.

### 2. Linha de passe

- Faça passes curtos livres e observe risco baixo.
- Tente um passe longo atravessando um defensor e observe risco maior.
- Confirme que uma interceptação soma turnover ao passador e inicia transição.

### 3. Finta

- Pressione V apontando para um companheiro.
- Observe defensores próximos deslocarem-se para a linha falsa.
- Passe logo depois para outro alvo e confirme a janela de segurança.
- Tente repetir imediatamente e confirme o cooldown.

### 4. Adaptação e contrajogo

- Repita três drives e confira a leitura no HUD.
- Mude para corta-luz e passe; a defesa não deve continuar presa ao drive para sempre.
- Repita passes cruzados e confirme negação de linha.
- Use finta ou passe curto e confirme que existe saída jogável.

### 5. Pressão e trap

- Segure a bola perto de dois defensores.
- Confirme aproximação da ajuda sem teleporte.
- Proteja a bola com E e solte antes do fechamento.
- Observe se faltas ainda seguem as regras da v0.8.

### 6. Transição

- Cometa um turnover e observe a Nightclaw ocupar três corredores.
- Confirme que ela procura companheiro à frente ou finaliza perto do aro.
- Verifique “pontos após TO” no box score.

### 7. Eclipse Defensivo

- Permita roubos, tocos e violações até completar a barra.
- Confirme feedback visual, duração aproximada de 6 s e reação nunca instantânea.
- Faça uma cesta antes da ativação e confirme a redução da barra.

### 8. Save e migração

- Abra um save v5 e confirme carregamento sem perda de campanha ou upgrades.
- Termine uma partida e confira save v6, turnovers de temporada e `adaptive_profile`.
- Feche e abra o jogo; a Nightclaw deve começar com memória agregada, não com um estado quebrado da posse anterior.

### 9. Regressão

- Inicie os Jogos 1–6 e confirme que nenhuma interface Nightclaw aparece.
- Teste passe, lob, arremesso, finalização, troca, Instinto, corta-luz, post, falta e lance livre.
- Confirme que Treino Livre continua funcionando e que V não remove a bola do portador.

## Falha crítica

Marque como bloqueadora qualquer ocorrência de: erro de parser, posse sem bola, pontuação para a cesta errada, save ilegível, defensor teleportando, reação abaixo do piso, atributo alterado silenciosamente ou campanha que não desbloqueia o Jogo 8.
