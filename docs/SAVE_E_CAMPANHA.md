# Save e campanha — v1.0

## Arquivo
`user://meteor_hoops_save.json`

## Schema atual
Versão **7**.

## Estado persistente
- introdução e capítulos vistos;
- tutorial;
- Treino Livre;
- maior jogo desbloqueado;
- partidas concluídas e melhores placares;
- trio preferido;
- dificuldade e acessibilidade;
- histórico recente;
- XP, nível e MVPs;
- pontos de evolução e upgrades escolhidos;
- temporada com PTS/AST/REB/STL/BLK, FG, 3PT, FT, faltas e turnovers;
- perfil adaptativo local com contagens agregadas de ações de gameplay.
- perfil de sequências com transições agregadas, sem trajetória, texto livre ou dado pessoal.

## Migração
O carregamento completa campos ausentes em saves antigos. A migração v7 preserva todas as garantias da v6 e cria `sequence_profile` quando necessário. Estruturas malformadas de frequência ou sequência são substituídas por dicionários vazios, e pesos são limitados novamente ao entrar no modelo.

## Rota implementada
- Jogos 1–8 jogáveis.
- Jogos 9–10 visíveis no mapa e ainda não jogáveis.

Ao vencer o Jogo 8, a semifinal contra a Apex Dominion é desbloqueada como o próximo nó narrativo.
