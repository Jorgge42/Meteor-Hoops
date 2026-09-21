# Fossil Tech — Design do Jogo 8

## Fantasia

“O Jogo dos Dados” deve parecer uma partida contra uma equipe que transforma hábitos em probabilidades. A Fossil Tech não lê o próximo input: ela mostra uma hipótese, espera o tempo mínimo de reação e compromete sua defesa. O jogador vence ao entender essa hipótese e escolher conscientemente uma resposta que sai do padrão.

## Objetivos da partida

O Jogo 8 ensina:

- pensar em sequências, não apenas em frequência de ações;
- ler confiança e evidência antes de atacar uma rotação;
- usar passe, finta, corta-luz, drive, post e arremesso como ações-isca;
- reconhecer a fraqueza criada por uma defesa que se compromete cedo;
- comparar decisões por valor esperado sem confundir probabilidade com certeza.

## Modelo de sequência

O `SequencePredictionModel` usa uma cadeia de primeira ordem. Cada contexto guarda apenas pesos agregados para a ação seguinte. O início da posse também é um contexto.

Exemplo: após observar três vezes `corta-luz → drive`, o modelo pode projetar **ATAQUE AO ARO** quando um novo corta-luz começa. Se o jogador passa ou arremessa, o HUD preserva o erro e a nova observação reduz gradualmente a certeza antiga.

Regras:

- mínimo de 3 evidências por contexto;
- confiança limitada entre 0% e 100%;
- peso máximo por transição;
- decaimento ao fim de cada posse;
- redução adicional no intervalo;
- nenhuma sequência bruta, posição ou input é salva.

## Rotações preditivas

| Previsão | Resposta Fossil Tech | Contrajogo |
|---|---|---|
| Passe | Saltar a linha prevista | Finta e ataque ao espaço abandonado |
| Drive ou post | Formar parede no garrafão | Arremesso, lado fraco ou passe antecipado |
| Arremesso | Closeout adiantado | Finta de arremesso e infiltração |
| Corta-luz | Troca antecipada | Recusar o bloqueio ou explorar mismatch |
| Sem confiança | Marcação base | Criar uma nova sequência sem punição artificial |

Cada defensor mantém a intenção anterior até passar o atraso de reação. Assim, uma previsão errada produz uma janela real de vantagem.

## Quebrar o Modelo

Quando uma ação com previsão disponível termina diferente do palpite:

1. o jogo registra uma previsão evitada;
2. a barra recebe disrupção proporcional à confiança e à surpresa;
3. o HUD informa o previsto e o realizado;
4. ao atingir 100%, o **Modelo Quebrado** dura 6 segundos.

Durante o Modelo Quebrado, rotações preditivas são suspensas e a reação fica mais lenta. Cestas, física, velocidade e atributos continuam intactos.

## Ataque por valor esperado

A Fossil Tech avalia três alternativas em cada janela de decisão:

- finalização: distância, contestação, arremesso e força;
- arremesso: valor de 2/3 pontos, distância, contestação e atributo;
- passe: abertura do recebedor, progresso até o aro e qualidade do passador.

O cálculo escolhe intenção; ele não altera a probabilidade que resolve o arremesso. Uma pequena variação determinística evita empates robóticos sem esconder bônus.

## Persistência e privacidade

O save v7 armazena somente um dicionário de contagens agregadas por transição. Tudo roda offline. Não há chamada de modelo remoto, telemetria pessoal, voz, texto livre ou identificação do jogador.

## Critério de sucesso

A partida funciona quando o jogador:

1. percebe a previsão no HUD;
2. reconhece qual espaço a rotação abriu;
3. muda deliberadamente a próxima ação;
4. vê a previsão falhar e a barra avançar;
5. usa a janela Modelo Quebrado para criar um bom arremesso.

Se o melhor caminho for apertar ações aleatórias, a recompensa por surpresa está alta demais. Se o HUD nunca cria uma decisão consciente, a evidência mínima ou o atraso precisam de ajuste.
