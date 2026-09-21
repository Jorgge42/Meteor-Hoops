# Save e campanha — v1.2

## Arquivo
`user://meteor_hoops_save.json`

## Schema atual
Versão **9**.

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
- perfil da final com partidas disputadas, melhor quantidade de decretos quebrados e Coroas Partidas.
- conclusão da campanha após a vitória no Jogo 10.

## Migração
O carregamento completa campos ausentes em saves antigos. A migração v9 preserva todas as garantias da v8 e cria `final_profile` e `campaign_completed` quando necessário. Estruturas malformadas de frequência ou sequência são substituídas por dicionários vazios; contadores de semifinal e final e pesos dos modelos são limitados antes do uso.

## Rota implementada
- Jogos 1–10 jogáveis.
- HQ pré-final e epílogo registrados no save como capítulos independentes.

Ao vencer o Jogo 9, a final contra a Tyrant Crown Academy é desbloqueada. Ao vencer o Jogo 10, `campaign_completed` passa a `true`; todas as partidas continuam disponíveis para revanche.
