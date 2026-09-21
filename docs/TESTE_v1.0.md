# Playtest v1.0 — O Jogo dos Dados

## 1. Smoke e migração

1. Inicie o projeto no Godot 4.7.2.
2. Confirme `vertical slice v1.0` no menu e Jogos 1–8 jogáveis no mapa.
3. Abra um save v6, se disponível, e confirme progresso, temporada, opções e trio.
4. Termine uma partida e confirme save v7 com `adaptive_profile` e `sequence_profile`.
5. Rode os testes headless e confirme todos os contratos.

## 2. Entrada narrativa

1. Vença ou carregue progresso após o Jogo 7.
2. Abra o Jogo 8 e leia as três páginas de “O Jogo dos Dados”.
3. Confirme elenco Fossil Tech e cor verde no mapa e na quadra.
4. Após a vitória, leia “Fora da Curva” e confirme o nó 9 desbloqueado.

## 3. Evidência e transparência

1. Comece o Jogo 8 com perfil de sequência vazio.
2. Confirme `MODELO: COLETANDO SEQUÊNCIAS` no HUD.
3. Repita uma abertura, por exemplo `corta-luz → drive`, por pelo menos três posses.
4. Confirme que a previsão só aparece depois da evidência mínima.
5. Verifique ação prevista, confiança, barra de disrupção e precisão acumulada.

## 4. Contrajogo

1. Quando o HUD projetar drive após corta-luz, use passe ou arremesso.
2. Confirme `PREVISÃO QUEBRADA` com ação esperada e ação real.
3. Observe a parede defensiva manter o compromisso por um instante antes do recálculo.
4. Use **V** contra uma previsão de passe e ataque o espaço abandonado.
5. Force erros até 100% e confirme 6 segundos de **MODELO QUEBRADO**.
6. Durante a janela, confirme marcação base e ausência de rotação preditiva.

## 5. Ataque da Fossil Tech

1. Deixe um arremessador aberto e confirme preferência por arremesso de alto valor.
2. Conteste o portador e deixe um companheiro livre; confirme circulação de bola.
3. Feche o perímetro e deixe o aro vulnerável; confirme finalização quando disponível.
4. Verifique que resultados de arremesso continuam usando as regras normais.

## 6. Dificuldade e justiça

Teste AVENTURA, LIGA e METEORO:

- a dificuldade reduz atraso, mas nunca abaixo de 0,36 s;
- a previsão continua visível em todas as dificuldades;
- não há teleporte, velocidade oculta ou alteração da física da bola;
- Modelo Quebrado aumenta o atraso, em vez de dar bônus secretos ao jogador.

## 7. Regressão

- Jogos 1–6 não exibem painéis Nightclaw ou Fossil Tech.
- Jogo 7 mantém tendência, finta, transição e Eclipse Defensivo.
- Corta-luz, post, falta, lance livre, lob e alley-oop continuam funcionais.
- Intervalo, substituições, prorrogação, box score e progressão permanecem funcionais.
- Opções de feedback, FX reduzidos e alto contraste continuam respeitadas.

## Critério de aceite

A v1.0 está pronta quando o jogador consegue explicar qual ação foi prevista, escolher uma resposta deliberada, provocar uma rotação errada e transformar o Modelo Quebrado em uma boa chance — sem perceber manipulação de resultado.
