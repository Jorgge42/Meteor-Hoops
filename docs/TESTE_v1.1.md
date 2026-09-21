# Playtest v1.1 — O Rugido

## 1. Smoke e migração

1. Inicie o projeto no Godot 4.7.2.
2. Confirme `vertical slice v1.1` no menu e Jogos 1–9 jogáveis no mapa.
3. Abra um save v7, se disponível, e confirme progresso, temporada, opções, trio e perfis anteriores.
4. Termine uma partida e confirme save v8 com `adaptive_profile`, `sequence_profile` e `semifinal_profile`.
5. Rode os testes headless e confirme todos os contratos.

## 2. Entrada narrativa

1. Vença ou carregue progresso após o Jogo 8.
2. Abra o Jogo 9 e leia as três páginas de “O Rugido”.
3. Confirme elenco Apex Dominion e identidade dourada no mapa e na quadra.
4. Após a vitória, leia “Depois do Rugido” e confirme o nó 10 desbloqueado.

## 3. Planos e transparência

1. Ataque sem corta-luz e confirme `BASE EQUILIBRADA` ou outro plano coerente no HUD.
2. Chame um corta-luz e confirme transição para `TROCA TOTAL` após o atraso de reação.
3. Ameace o aro e confirme `PAREDE NO GARRAFÃO`.
4. Observe posse da Apex e confirme alternância entre Quadra Aberta, Bloqueio de Potência, Eixo no Poste e Ataque ao Rebote.
5. Verifique que mudanças de plano são anunciadas com uma contrajogada.

## 4. Rugido da Dominion

1. Permita bloqueio, post, rebote ofensivo, toco, turnover e cesta no garrafão em tentativas separadas.
2. Confirme que cada evento real aumenta a barra e que tentativa sem sucesso não aumenta.
3. Complete 100% e confirme 6,5 segundos de **RUGIDO DA DOMINION**.
4. Durante o Rugido, confirme trocas de plano mais rápidas.
5. Verifique que jogadores não ganham velocidade, acerto, força ou física especial.

## 5. Compostura

1. Encadeie três ações distintas, como finta, passe e drive; confirme sequência x3.
2. Repita uma ação ainda presente na janela e confirme quebra da sequência e perda de carga.
3. Marque uma cesta segura e capture um rebote defensivo; confirme ganhos de Compostura.
4. Cometa um turnover e confirme perda de carga.
5. Complete 100% e confirme seis segundos de **SILÊNCIO DA VALE**.
6. Se o Rugido estiver ativo, confirme cancelamento imediato; durante o Silêncio, confirme ausência de nova carga do Rugido.

## 6. Dificuldade e justiça

Teste AVENTURA, LIGA e METEORO:

- a dificuldade reduz atraso, mas nunca abaixo de 0,34 s;
- o plano continua visível em todas as dificuldades;
- não há teleporte, velocidade oculta ou alteração da física da bola;
- o mesmo timing e regras de arremesso permanecem ativos;
- Silêncio aumenta atraso em vez de conceder acerto ao jogador.

## 7. Regressão

- Jogos 1–6 não exibem painéis Nightclaw, Fossil Tech ou Apex.
- Jogo 7 mantém tendência, finta, transição e Eclipse Defensivo.
- Jogo 8 mantém previsão, disrupção e Modelo Quebrado.
- Corta-luz, post, falta, lance livre, lob, alley-oop e rebote continuam funcionais.
- Intervalo, substituições, prorrogação, box score e progressão permanecem funcionais.
- Opções de feedback, FX reduzidos e alto contraste continuam respeitadas.

## Critério de aceite

A v1.1 está pronta quando o jogador identifica o plano da Apex, encontra uma resposta diferente para cada ameaça e transforma decisões variadas em Silêncio da Vale — sem perceber manipulação de resultado.
