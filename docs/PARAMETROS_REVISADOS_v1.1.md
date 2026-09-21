# Meteor Hoops — parâmetros revisados v1.1

Esta revisão congela as decisões que devem ser usadas antes de expandir o conteúdo.

## Correções críticas

- Nome oficial do projeto: **METEOR HOOPS: ROTA DO METEORO**. “Dino Hoops” deixa de ser usado como título.
- Engine alvo: **Godot 4.7.2 stable**. Não migrar para 4.8-dev durante o vertical slice.
- Primeiro alvo: PC/Windows. Mobile só depois do vertical slice estável.
- Formato: 3x3 full court; elenco de campanha com 5 atletas.
- Substituições no MVP: somente no intervalo. Isso permite que todos os 5 participem sem criar UI complexa de substituição durante bola viva.
- Escala das espécies é **estilizada e normalizada**. Altura jogável entre 1,55 m e 2,35 m. Um Brachiosaurus não terá escala paleontológica real.
- Caudas, chifres, cristas e pescoços não ampliam o collider principal. Gameplay usa cápsulas normalizadas; partes especiais só ganham hitbox quando uma habilidade explicitamente pede isso.
- Campanha exige vitória para avançar. Derrota abre **Repetir / Treino / Voltar ao mapa** e não apaga objetivos de tutorial já concluídos.

## Movimento

| Parâmetro | Base v1.1 |
|---|---:|
| velocidade base | 6,8 m/s |
| multiplicador por atributo | 0,82–1,16 |
| sprint | x1,18 |
| aceleração | 22 m/s² |
| desaceleração | 28 m/s² |
| stamina | 100 |
| custo sprint | 22/s |
| regeneração | 16/s |
| atraso para regenerar | 0,65 s |

A velocidade máxima de um Raptor 92 fica perto de 9,1 m/s em sprint. É rápida, mas ainda permite reação defensiva.

## Bola e cesta

| Parâmetro | Base v1.1 |
|---|---:|
| raio da bola | 0,12 m |
| massa | 0,62 kg |
| aro | 3,05 m |
| raio útil do aro | 0,23 m |
| passe normal | 14 m/s |
| passe forte | 17 m/s |
| voo de arremesso | 0,82–1,06 s |

A posse continua híbrida: **HELD / PASS / SHOT / LOOSE**. A bola não fica fisicamente quicando na mão do atleta.

## Arremesso

A fórmula antiga multiplicava todos os fatores e poderia derrubar a chance de acerto rápido demais. A versão recomendada para o jogo completo passa a ser ponderada:

`shot_quality = skill*0.45 + timing*0.35 + openness*0.20 - fatigue_penalty`

Depois, uma curva converte qualidade em chance final. O protótipo v0.1 ainda usa apenas timing para facilitar diagnóstico.

Janelas iniciais:

- Aventura: ±110 ms
- Liga: ±80 ms
- Meteoro: ±55 ms

Contest sugerido para a próxima versão:

- até 0,75 m + defensor de frente: pesado
- 0,75–1,50 m: médio
- 1,50–2,40 m: leve
- acima de 2,40 m: aberto

## Instinto Meteoro

Medidor 0–100. Base inicial para playtests:

- assistência: +12
- roubo limpo: +15
- toco: +15
- rebote disputado: +8
- arremesso perfeito: +10
- turnover: -12
- falta: -8

Ações repetidas em sequência recebem retorno decrescente. Ativação padrão: 5 s; medidor volta a zero.

## Estrutura do Jogo 1

1. HQ pré-jogo — 3 páginas.
2. Tutorial de movimento, passe e arremesso.
3. Partida Quartz Academy 3x3.
4. Resultado.
5. HQ pós-jogo.
6. Desbloqueio de Treino Livre.

O protótipo v0.1 implementa os itens 1 e 2 como fundação técnica. O 3x3 entra no v0.2.

## Regras de produção

- Nada de arte final antes de uma posse ser divertida.
- IA não recebe bônus escondido de velocidade ou acerto.
- Toda mecânica deve ser testável separadamente no Treino.
- Cada escola rival introduz no máximo uma mecânica principal nova.
- Novos personagens devem reutilizar o mesmo rig sempre que a anatomia permitir.
