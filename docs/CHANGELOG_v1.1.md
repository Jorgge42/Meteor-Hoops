# Changelog v1.1 — O Rugido

## Campanha

- Jogo 9 contra a Apex Dominion liberado e jogável como semifinal.
- Elenco adversário completo: Rexon, Stride, Maul, Ram e Bastion.
- HQs SVG pré-jogo e pós-jogo do capítulo 9.
- Vitória desbloqueia o nó 10, a final contra a Tyrant Crown Academy.
- Mapa, menu, créditos e tela de temporada atualizados para v1.1.

## IA e gameplay

- Nova `ApexCoordinationAI` com quatro planos defensivos, quatro ofensivos e base equilibrada.
- Plano coletivo e contrajogada sempre visíveis no HUD.
- Novo medidor **Rugido da Dominion**, alimentado apenas por eventos físicos reais.
- Novo `ComposureTracker`, que recompensa variedade, posses seguras e paradas defensivas.
- Estado **Silêncio da Vale** cancela o Rugido e retarda a reorganização da Apex.
- Posicionamento específico para pressão, troca, parede, box-out, espaçamento, post e rebote ofensivo.
- Contrato explícito proíbe bônus ocultos de atributo, velocidade, acerto ou física.

## Persistência e qualidade

- Save v8 com migração tolerante e `semifinal_profile` agregado.
- Resumo de partida inclui plano final, melhor sequência e Rugidos silenciados.
- Testes de contrato ampliados para variedade, repetição, planos, reação mínima e justiça.
- Validador estático cobre scripts, recursos e as seis páginas SVG do capítulo 9.
- Metadados do projeto atualizados para Prototype v1.1.
