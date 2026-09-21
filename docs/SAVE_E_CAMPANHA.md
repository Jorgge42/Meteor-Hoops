# Save e campanha — v0.9

## Arquivo
`user://meteor_hoops_save.json`

## Schema atual
Versão **6**.

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

## Migração
O carregamento completa campos ausentes em saves antigos. A migração v6 mantém a compensação de pontos de evolução da v5, acrescenta turnovers às linhas de temporada e cria um perfil adaptativo vazio quando necessário. Dados adaptativos malformados são descartados com segurança.

## Rota implementada
- Jogos 1–7 jogáveis.
- Jogos 8–10 visíveis no mapa e ainda não jogáveis.

Ao vencer o Jogo 7, o nó 8 é desbloqueado narrativamente, embora Fossil Tech ainda seja conteúdo em desenvolvimento.
