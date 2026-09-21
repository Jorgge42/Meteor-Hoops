# Nightclaw Academy — Design do Jogo 7

## Fantasia

“Luzes Apagadas” deve parecer uma partida contra uma equipe que vê a jogada meio segundo antes. A Nightclaw vence por leitura, negação de linhas e velocidade após recuperar a bola — nunca por bônus invisíveis.

## Objetivos da partida

O Jogo 7 ensina:

- reconhecer quando um passe está atravessando uma linha ocupada;
- variar decisões para não se tornar previsível;
- usar finta de passe como ferramenta de manipulação;
- proteger a bola contra pressão e soltar antes do trap;
- reagir imediatamente após um turnover.

## Ciclo adaptativo

1. O jogador executa uma ação ofensiva.
2. O modelo soma evidência e aplica decaimento ao fim da posse.
3. A IA utilitária combina tendência, posição, transição, ajuda e risco de falta.
4. O defensor mantém a decisão por um intervalo mínimo de reação.
5. A interface informa a leitura e oferece uma contrajogada.

A memória curta é reduzida no intervalo. A memória persistente é agregada e limitada, então nunca guarda uma sequência detalhada da partida.

## Ações defensivas

| Ação | Quando ganha valor | Resposta do jogador |
|---|---|---|
| Conter | Drives e post repetidos | Corta-luz, passe e mudança de ritmo |
| Negar linha | Passe longo ou repetido | Finta, backdoor ou passe curto |
| Pressionar bola | Portador vulnerável | Proteger e atacar o lado exposto |
| Trap | Ajuda próxima e baixo risco de falta | Passe antecipado para o homem livre |
| Recuar | Ameaça de transição | Parar e arremessar livre |

## Finta de passe

**V / D-pad ↓** cria uma direção falsa. Defensores Nightclaw próximos da linha reagem durante uma janela curta. Se o jogador passa logo depois, recebe redução explícita no risco daquela linha. A ação tem cooldown para preservar decisão e timing.

## Eclipse Defensivo

Roubos, interceptações, tocos e violações carregam o takeover coletivo. Ao completar a barra:

- decisões e rotações ficam mais rápidas, respeitando o piso de 0,30 s;
- a área de interceptação cresce pouco e por tempo limitado;
- todos os defensores recebem feedback visual;
- uma cesta da Vale Fóssil reduz a barra antes da ativação.

O takeover não altera velocidade base, chance de arremesso nem física da bola.

## Critério de sucesso

A partida funciona quando o jogador inicialmente sente pressão, identifica o próprio padrão, usa uma resposta consciente e percebe a defesa reagir de novo. Se a solução for repetir V antes de todo passe, o custo, a duração ou a reação dos defensores precisam de ajuste.
