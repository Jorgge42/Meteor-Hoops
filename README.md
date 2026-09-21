# METEOR HOOPS: ROTA DO METEORO — Prototype v1.2

Vertical slice de basquete arcade 3D para **Godot 4.7.2**. A v1.2 completa a campanha com a final contra a Tyrant Crown: Drax combina tendências, sequências e coordenação coletiva em decretos visíveis, cada um com uma condição explícita de quebra. A IA adapta decisões, nunca resultados, atributos ou física.

## Destaques da v1.2

- Jogos 1–10 jogáveis e campanha completa, da Quartz Academy à Tyrant Crown.
- Jogo 10: **Vale Fóssil x Tyrant Crown Academy — O Meteoro**.
- Meta-IA local escolhe entre Trono de Ferro, Caçada Noturna, Destino Escrito e Comando Real a partir do estado observável e dos padrões agregados do jogador.
- O HUD revela decreto, duração, previsão quando aplicável e a contrajogada necessária.
- Quebrar três decretos diferentes carrega **Legado** e ativa **Coroa Partida** por sete segundos, suspendendo formações especiais.
- A Coroa não recebe bônus de arremesso, corrida, contato, alcance de interceptação ou física da bola.
- Save v9 preserva campanha, evolução, temporada e perfis agregados das quatro escolas de IA.
- HQ pré e pós-jogo do capítulo 10 e encerramento próprio para a campanha.
- Testes de contrato cobrem escolha dos decretos, reação mínima, persistência, quebra da Coroa e justiça.

Também permanecem disponíveis os sistemas das versões anteriores:

- Jogo 7: **Vale Fóssil x Nightclaw Academy — Luzes Apagadas**.
- IA utilitária avalia contenção, pressão na bola, negação de passe, trap e recuo.
- Modelo local de tendências aprende passes cruzados, drives, arremessos, jogo de costas, proteção de bola e fintas.
- **V** executa uma finta de passe: defensores próximos reagem e uma janela curta torna o passe seguinte mais seguro.
- Linhas de passe possuem análise geométrica, risco visível e interceptações com tempo mínimo de reação.
- Turnovers geram transição, contra-ataques em três corredores e pontos após erro registrados no box score.
- **Eclipse Defensivo** é o takeover coletivo da Nightclaw, carregado por roubos, tocos e violações.
- Diretor de partida pode oferecer dicas e variar pesos estratégicos, mas nunca manipula a bola, o arremesso ou atributos ocultos.
- Testes de contrato da IA e validação headless automatizada no GitHub Actions.

## Controles

| Ação | Teclado | Controle |
|---|---|---|
| Mover | WASD / setas | Analógico esquerdo |
| Sprint | Shift | R1 / RB |
| Passe / roubo / bola solta | Espaço | A / Cross |
| **Finta de passe** | **V** | **D-pad ↓** |
| Lob / alley-oop | L | D-pad ↑ |
| Arremesso | segurar e soltar J | X / Square |
| Bandeja / enterrada | K com a bola | B / Circle |
| Toco / rebote com timing | K sem bola | B / Circle |
| Proteger bola / box-out | E | L1 / LB |
| Chamar corta-luz | G com a bola | D-pad → |
| Jogo de costas | H perto do aro | D-pad ← |
| Instinto Meteoro | F | teclado nesta build |
| Chamar / trocar jogada | C | teclado nesta build |
| Trocar jogador | Q / Tab | Y / Triangle |
| Reset de posse | R, no Treino | — |
| Menu | Esc | — |

## Nightclaw Academy

A Nightclaw não recebe velocidade ou precisão escondidas. Sua vantagem vem de informação observável: posição da bola, linhas de passe, contexto da transição e ações que o jogador repete.

Elenco:

- **Nyx — Troodon / Armadora — Visão Noturna:** capitã que reconhece padrões e fecha recepções.
- **Shade — Dromaeosaurus / Ala — Garra Fantasma:** especialista em negação e interceptação.
- **Onyx — Megaraptor / Pivô — Sombra Longa:** protege o aro sem abandonar linhas curtas.
- **Whisper — Compsognathus / Ala — Passo Silencioso:** reserva de pressão e velocidade.
- **Eclipse — Dilophosaurus / Ala — Dupla Sombra:** arremessador que pune colapsos na transição.

### Como vencer a leitura

- Alterne passe curto, drive, corta-luz, post e arremesso.
- Use **V** antes de um passe previsível para deslocar a defesa.
- Contra pressão, proteja a bola e ataque a lateral livre.
- Contra trap, solte a bola antes da segunda marcação fechar.
- Contra recuo, pare e aceite o arremesso aberto.

O painel do Jogo 7 informa a tendência detectada e a carga do Eclipse Defensivo. Essa transparência transforma adaptação em contrajogo, não em trapaça.

## Fossil Tech

A Fossil Tech modela **qual ação costuma vir depois da ação atual**. O modelo começa cada posse sem certeza, só libera uma previsão após evidência suficiente e perde peso gradualmente. A interface expõe o palpite e sua confiança antes da defesa se comprometer.

Elenco:

- **Axiom — Troodon / Armador — Hipótese Viva:** capitão que encadeia padrões com disciplina.
- **Vector — Velociraptor / Ala — Linha Ótima:** procura o espaço de maior valor.
- **Matrix — Iguanodon / Pivô — Matriz de Ajuda:** organiza paredes e trocas defensivas.
- **Delta — Ornithomimus / Ala — Erro Positivo:** reserva que aumenta a variação ofensiva.
- **Lemma — Pachycephalosaurus / Pivô — Prova por Contato:** transforma posição e rebote em decisões seguras.

### Como quebrar o modelo

- Leia no HUD a ação prevista e a confiança atual.
- Depois de um corta-luz repetido, recuse o bloqueio, passe ou pare para arremessar.
- Contra uma previsão de passe, use **V** como isca e ataque o espaço abandonado.
- Contra parede no garrafão, encontre o lado fraco ou aceite o arremesso livre.
- Contra closeout antecipado, use a finta e infiltre.

Previsões erradas enchem **Quebrar o Modelo**. Ao chegar a 100%, a Fossil Tech volta temporariamente à marcação base e reage mais devagar. O sistema não lê teclas futuras, não muda resultados e não chama serviços externos.

## Apex Dominion

A Apex atua como um time coordenado. A cada leitura, escolhe um plano coletivo usando apenas estado observável da partida: posse, relógio, bloqueio ativo, ameaça ao aro, força no post, ocupação do garrafão e prioridade de rebote. O plano atual aparece no HUD antes de reorganizar os três jogadores em quadra.

Elenco:

- **Rexon — Tyrannosaurus / Armador — Comando Alfa:** capitão que convoca o plano coletivo.
- **Stride — Allosaurus / Ala — Passo Soberano:** troca marcações e ocupa o lado fraco.
- **Maul — Giganotosaurus / Pivô — Peso do Trono:** organiza bloqueios, selos e rebotes.
- **Ram — Carnotaurus / Ala — Investida Real:** reserva que acelera a pressão na bola.
- **Bastion — Ankylosaurus / Pivô — Fortaleza Dourada:** reserva defensivo para garrafão e box-out.

### Como silenciar o Rugido

- Leia o plano no HUD e responda: passe de segurança contra pressão, recusa ou mismatch contra troca, espaçamento contra parede e box-out contra rebote.
- Alterne passe, finta, proteção, corta-luz, jogo de costas, infiltração e arremesso dentro da mesma posse.
- Evite repetir a mesma solução nas quatro ações recentes.
- Termine a defesa com rebote ou turnover e proteja a bola no ataque.
- Ao completar Compostura, use os seis segundos de Silêncio da Vale antes que a Apex consiga reorganizar rapidamente.

Rugido e Silêncio alteram somente o intervalo de decisão dos planos. Corrida, contato, arremesso e física continuam usando as regras normais da partida.

## Tyrant Crown

Drax funciona como um chefe tático. A cada janela de leitura, a meta-IA combina distância do aro, força no post, frequência de passes e infiltrações, risco recente de linha de passe, relógio, rebote, bloqueios e uma previsão de sequência. A ordem escolhida é anunciada antes de reorganizar a equipe.

- **Trono de Ferro:** fecha o garrafão e prioriza posição e rebote. Quebre convertendo um jumper ou uma bola de três.
- **Caçada Noturna:** pressiona a bola e ocupa linhas de passe. Quebre usando `V` e completando o passe seguinte.
- **Destino Escrito:** mostra no HUD a próxima ação prevista e antecipa essa continuação. Quebre escolhendo outra ação.
- **Comando Real:** sincroniza troca, pressão e cobertura. Quebre usando três ações diferentes na posse antes de pontuar.

Cada decreto distinto quebrado concede 34% de **Legado**. Ao dominar três, a **Coroa Partida** suspende todas as formações especiais por sete segundos. Depois disso, Drax pode reconstruir sua estratégia, mas os dados continuam locais, agregados e limitados no save.

## Sistemas de IA

| Sistema | Papel | Limite de justiça |
|---|---|---|
| `PlayerTendencyModel` | Memória com decaimento e confiança mínima | Precisa de evidência; esquece gradualmente |
| `PassingLaneAnalyzer` | Risco geométrico de passe | Usa posições reais e atributo visível de passe |
| `NightclawUtilityAI` | Escolha contextual da defesa | Reação mínima de 0,30 s e variação pequena |
| `FairMatchDirector` | Dicas e mudança de estratégia | Proíbe alterar acerto, física ou atributos ocultos |
| `SequencePredictionModel` | Próxima ação por contexto e transições agregadas | Evidência mínima, confiança limitada e decaimento |
| `FossilTechPredictiveAI` | Rotação preditiva e escolha ofensiva por valor | Previsão visível, reação mínima e estado vulnerável |
| `ApexCoordinationAI` | Seleção de planos coletivos ofensivos e defensivos | Plano visível, reação mínima e nenhuma alteração de resultado |
| `ComposureTracker` | Recompensa variedade, posse segura e parada defensiva | Guarda somente totais agregados e pune repetição |
| `TyrantCrownMetaAI` | Combina leituras anteriores e seleciona decretos da final | Decreto e quebra visíveis, reação mínima e sem leitura de input futuro |
| `CrownLegacyTracker` | Registra contrajogo e abre a janela Coroa Partida | Exige três decretos distintos e persiste apenas totais agregados |

Tudo roda localmente, sem enviar telemetria ou dados pessoais para serviços externos. O save armazena somente contagens agregadas de ações de gameplay.

## Campanha

1. Primeiro Quique — Quartz Academy — jogável.
2. Raízes em Movimento — Canopy Institute — jogável.
3. Pressão Vulcânica — Ember Ridge — jogável.
4. Maré Alta — Tidefang School — jogável.
5. Acima do Aro — Skycrest Academy — jogável.
6. Parede de Chifres — Ironhorn Institute — jogável.
7. **Luzes Apagadas — Nightclaw Academy — jogável.**
8. **O Jogo dos Dados — Fossil Tech — jogável.**
9. **O Rugido — Apex Dominion — semifinal jogável.**
10. **O Meteoro — Tyrant Crown Academy — final jogável.**

## Executar

1. Instale o Godot 4.7.2.
2. Importe `project.godot`.
3. Abra o projeto e pressione F5.

Validação headless:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/test_ai_contracts.gd
```

## Estrutura

- `systems/ai/` — tendências, sequências, linhas de passe, planos coletivos, Compostura, utility AI e diretor justo.
- `data/match_catalog.gd` — campanha, elencos e atributos.
- `data/game_tuning.gd` — parâmetros centralizados de gameplay.
- `scenes/prototype_match.gd` — regras e integração da partida.
- `systems/save_manager.gd` — save v9, migrações, progressão e temporada.
- `content/story/comics/chapter_07/` — HQ pré-Nightclaw.
- `content/story/comics/chapter_07_post/` — HQ pós-Nightclaw.
- `content/story/comics/chapter_08/` — HQ pré-Fossil Tech.
- `content/story/comics/chapter_08_post/` — HQ pós-Fossil Tech.
- `content/story/comics/chapter_09/` — HQ pré-Apex Dominion.
- `content/story/comics/chapter_09_post/` — HQ pós-Apex Dominion.
- `content/story/comics/chapter_10/` — HQ pré-Tyrant Crown.
- `content/story/comics/chapter_10_post/` — epílogo da campanha.
- `docs/NIGHTCLAW_DESIGN.md` — intenção e contrajogo do Jogo 7.
- `docs/FOSSIL_TECH_DESIGN.md` — previsão, falsa certeza e contrajogo do Jogo 8.
- `docs/APEX_DOMINION_DESIGN.md` — planos, Rugido, Compostura e justiça do Jogo 9.
- `docs/TYRANT_CROWN_DESIGN.md` — meta-IA, decretos, Legado e justiça do Jogo 10.
- `docs/AI_STRATEGY.md` — arquitetura, justiça e próximos passos da IA.
- `docs/TESTE_v1.2.md` — roteiro de playtest.
- `docs/VALIDACAO_v1.2.md` — evidências automatizadas da versão.

## Estado do protótipo

O jogo permanece em graybox. Modelos 3D, rig, animações, VFX, UI artística e áudio final ainda são placeholders. A prioridade continua sendo provar que o basquete, a progressão e as identidades táticas são divertidos antes da produção visual definitiva.
