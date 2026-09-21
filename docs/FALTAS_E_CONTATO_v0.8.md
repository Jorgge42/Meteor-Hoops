# Faltas e contato — v0.8

## Objetivo
Adicionar risco ao contato sem transformar o protótipo em um simulador de arbitragem.

## Eventos implementados

### Roubo
Uma tentativa de roubo que falha pode virar falta defensiva. Defesa baixa aumenta levemente o risco.

### Toco
Se a tentativa de toco falha durante um arremesso, pode ocorrer falta. O número de lances livres é baseado no valor do arremesso em curso.

### Finalização
Contato próximo durante bandeja/enterrada pode interromper a jogada e gerar dois lances livres.

### Poste
O backdown pode resultar em:
- ganho de espaço;
- falta defensiva;
- falta de ataque/charge.

## Lance livre
- ideal: 0,56 s;
- green: ±65 ms;
- timing e shooting entram na chance;
- cada conversão vale 1 ponto;
- FTA/FTM entram no box score.

## Simplificações atuais
- sem and-one;
- sem bônus por faltas coletivas;
- sem foul-out;
- último FT errado não gera rebote vivo na v0.8;
- faltas sem bola ainda não são arbitradas.

Essas simplificações são intencionais para permitir playtest do núcleo antes de aumentar o número de estados de jogo.
