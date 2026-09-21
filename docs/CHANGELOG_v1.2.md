# Changelog v1.2 — O Meteoro

## Campanha

- Jogo 10 contra a Tyrant Crown Academy liberado como final jogável.
- Elenco completo: Drax, Regalia, Colossus, Vanta e Sovereign.
- HQ de entrada “O Meteoro” e epílogo “Depois da Coroa”, com três páginas SVG cada.
- Vitória final marca a campanha como concluída e mantém todos os jogos disponíveis.
- Menu, mapa, resultado, créditos e temporada atualizados para v1.2.

## IA e gameplay

- Nova `TyrantCrownMetaAI`, que combina ameaças de garrafão, passe, sequência, relógio, bloqueio e rebote.
- Quatro decretos visíveis: Trono de Ferro, Caçada Noturna, Destino Escrito e Comando Real.
- Novo `CrownLegacyTracker`, com progresso somente por contrajogo verificável.
- Três decretos distintos quebrados ativam sete segundos de Coroa Partida.
- Formações defensivas, espaçamento ofensivo, decisão por valor esperado e rebote mudam conforme o decreto.
- Condição de quebra, previsão e tempo restante aparecem no HUD.
- Contrato explícito proíbe bônus ocultos, input futuro, alteração de acerto, alcance e física.

## Persistência e qualidade

- Save v9 com migração tolerante, `final_profile` e `campaign_completed`.
- Resumo da partida inclui decretos quebrados, Coroas Partidas e desempenho das previsões.
- Testes cobrem escolha dos decretos, reação mínima, justiça, Legado, persistência e recursos da final.
- Validador estático cobre scripts, recursos e as seis páginas SVG do capítulo 10.
- Metadados do projeto atualizados para Prototype v1.2.
