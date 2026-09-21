# Changelog v1.0 — O Jogo dos Dados

## Campanha

- Jogo 8 contra a Fossil Tech liberado e jogável.
- Elenco adversário completo: Axiom, Vector, Matrix, Delta e Lemma.
- HQs SVG pré-jogo e pós-jogo do capítulo 8.
- Vitória desbloqueia o nó 9, Apex Dominion.
- Mapa, menu, créditos e tela de temporada atualizados para v1.0.

## IA e gameplay

- Novo `SequencePredictionModel` com evidência mínima, confiança, entropia, limites, decaimento e serialização.
- Nova `FossilTechPredictiveAI` com quatro rotações preditivas e marcação base.
- Previsão e confiança visíveis no HUD.
- Barra **Quebrar o Modelo**, erro explícito e janela temporária sem antecipação.
- Reação mínima por dificuldade e recálculo somente depois de cada atraso.
- Finta de passe também desloca defensores da Fossil Tech.
- Ataque rival seleciona passe, arremesso ou finalização por valor esperado observável.
- Proteção de bola passa a ser observada uma vez por posse, evitando amostragem por frame.

## Persistência e qualidade

- Save v7 com migração tolerante e `sequence_profile` agregado.
- Resumo de partida inclui acertos e previsões evitadas.
- Testes de contrato ampliados para sequência, persistência, reação, contrajogo e valor esperado.
- Validador estático cobre os scripts e as seis páginas SVG do capítulo 8.
- Metadados do projeto atualizados para Prototype v1.0.
