# Apex Dominion — design da semifinal

## Fantasia

A Apex Dominion é o primeiro rival que joga como uma unidade completa. Seus atletas são fisicamente fortes, mas a identidade da escola nasce da coordenação: todos recebem o mesmo plano, ocupam espaços complementares e deixam a intenção visível antes de executá-la.

## Planos defensivos

| Plano | Leitura | Execução | Contrajogo |
|---|---|---|---|
| Base Equilibrada | Nenhuma ameaça domina | Contenção individual normal | Encadear ações diferentes |
| Pressão na Bola | Relógio e posse sob pressão | Portador encurtado e linhas sombreadas | Proteção e passe de segurança |
| Troca Total | Corta-luz ativo | Marcadores trocam portador e bloqueador | Recusar bloqueio ou atacar mismatch |
| Parede no Garrafão | Drive ou post ameaçador | Trio recua para proteger o aro | Abrir quadra e aceitar arremesso livre |
| Controle do Rebote | Arremesso em curso | Posição e box-out antes da bola cair | Voltar para defender e disputar seletivamente |

## Planos ofensivos

| Plano | Organização | Resposta defensiva |
|---|---|---|
| Quadra Aberta | Alas largos e leitura da ajuda | Ajuda curta com recuperação no passe |
| Bloqueio de Potência | Bloqueador forte e roll | Antecipar troca e impedir o roll |
| Eixo no Poste | Pivô ocupa posição profunda | Negar posição antes do contato |
| Ataque ao Rebote | Dois atletas próximos da área | Box-out e captura com timing |

## Rugido da Dominion

O Rugido vai de 0 a 100 e recebe carga somente por eventos físicos resolvidos pelas regras normais:

- bloqueio que realmente atinge o defensor: +12;
- avanço bem-sucedido no post: +10;
- rebote ofensivo: +20;
- toco: +18;
- turnover da Vale: +16;
- cesta de bandeja ou enterrada: +12.

Ao completar a barra, o Rugido dura 6,5 segundos. Nesse período a IA reavalia o plano coletivo mais cedo. Não há bônus em corrida, contato, atributos, qualidade do arremesso ou física da bola.

## Compostura e Silêncio da Vale

A Compostura recompensa decisões que tornam a Vale menos previsível:

- cada ação nova na janela recente aumenta a sequência e concede carga progressiva;
- repetir uma ação entre as quatro recentes quebra a sequência e remove 10 pontos;
- cesta segura concede 16 pontos;
- rebote defensivo ou turnover recuperado concede 18 pontos;
- turnover da Vale remove 24 pontos.

Ao chegar a 100, a barra zera e ativa seis segundos de Silêncio da Vale. O Silêncio cancela um Rugido ativo, impede nova carga do Rugido e aumenta o atraso antes da próxima troca de plano.

## Contrato de justiça

- O plano atual aparece no HUD.
- A menor reação possível é 0,34 s.
- O estado recebe somente dados já observáveis no mundo da partida.
- Aleatoriedade de ±0,015 serve apenas para desempatar utilidades próximas.
- Rugido e Silêncio afetam somente a cadência de planejamento.
- Chance de acerto, física da bola, velocidade e atributos ocultos permanecem inalterados.
- O save guarda apenas partidas, melhor sequência e total de Rugidos silenciados.

## Objetivo de playtest

O jogador deve conseguir nomear o plano atual, escolher uma resposta deliberada e perceber que a arena foi silenciada pela qualidade das decisões — não por um bônus invisível. Se o HUD for ignorado ou se uma única ação resolver todos os planos, a identidade ainda precisa de balanceamento.
