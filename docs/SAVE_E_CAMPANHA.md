# Save e campanha — v1.1

## Arquivo
`user://meteor_hoops_save.json`

## Schema atual
Versão **8**.

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
- perfil da semifinal com partidas disputadas, melhor sequência de Compostura e Rugidos silenciados.

## Migração
O carregamento completa campos ausentes em saves antigos. A migração v8 preserva todas as garantias da v7 e cria `semifinal_profile` quando necessário. Estruturas malformadas de frequência ou sequência são substituídas por dicionários vazios; contadores da semifinal e pesos dos modelos são limitados antes do uso.

## Rota implementada
- Jogos 1–9 jogáveis.
- Jogo 10 visível no mapa e ainda não jogável.

Ao vencer o Jogo 9, a final contra a Tyrant Crown Academy é desbloqueada como o próximo nó narrativo.
