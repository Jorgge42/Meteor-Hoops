# Tyrant Crown — design da final

## Fantasia

Drax é o exame final da campanha, não um adversário com atributos secretos. A Tyrant Crown observa as soluções usadas contra Nightclaw, Fossil Tech e Apex Dominion e escolhe uma ordem tática capaz de contestar o padrão mais valioso naquele momento.

## Ciclo do chefe

1. A meta-IA espera o atraso definido pela dificuldade.
2. Lê somente estado já ocorrido ou visível: posição, relógio, bloqueio, rebote, turnovers e modelos agregados.
3. Exibe o decreto, o tempo restante e a condição de quebra.
4. Reposiciona os três atletas sem mudar atributos, acerto, bola ou alcance padrão.
5. Uma resposta correta quebra o decreto e concede 34% de Legado.
6. Três decretos distintos ativam Coroa Partida por sete segundos.

## Decretos

| Decreto | Resposta da Coroa | Como quebrar |
|---|---|---|
| Trono de Ferro | Proteção do aro, post e box-out | Converter jumper ou 3PT |
| Caçada Noturna | Pressão e ocupação da linha de passe | Finta de passe e passe completo |
| Destino Escrito | Rotação para a continuação prevista | Escolher ação diferente da previsão mostrada |
| Comando Real | Trocas, pressão e ajuda sincronizadas | Usar três ações distintas e pontuar na posse |

Um decreto já quebrado não pode carregar novamente o mesmo ciclo. Isso impede farm de uma única resposta e faz a vitória exigir domínio do vocabulário aprendido durante a Rota.

## Dados e persistência

`TyrantCrownMetaAI` recebe um contexto efêmero e não grava trajetórias. `CrownLegacyTracker` persiste apenas `games`, `best_edicts_broken` e `crowns_shattered`, com limites defensivos na leitura do save v9.

## Contrato de justiça

- decreto e contrajogada sempre visíveis;
- previsão declarada antes da ação real;
- piso de reação de 0,32 s;
- nenhuma leitura de input futuro;
- nenhum bônus oculto de velocidade, força, defesa, passe ou arremesso;
- nenhum ajuste secreto de probabilidade, trajetória ou física da bola;
- Coroa Partida enfraquece a estratégia adversária, não aumenta o acerto do jogador.
