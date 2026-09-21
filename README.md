# METEOR HOOPS: ROTA DO METEORO — Prototype v0.9

Vertical slice de basquete arcade 3D para **Godot 4.7.2**. A v0.9 adiciona o sétimo jogo da campanha, a Nightclaw Academy, e uma defesa adaptativa que reconhece hábitos do jogador sem alterar secretamente atributos, física ou chance de acerto.

## Destaques da v0.9

- Jogos 1–7 jogáveis, cada escola com identidade tática própria.
- Jogo 7: **Vale Fóssil x Nightclaw Academy — Luzes Apagadas**.
- IA utilitária avalia contenção, pressão na bola, negação de passe, trap e recuo.
- Modelo local de tendências aprende passes cruzados, drives, arremessos, jogo de costas, proteção de bola e fintas.
- **V** executa uma finta de passe: defensores próximos reagem e uma janela curta torna o passe seguinte mais seguro.
- Linhas de passe possuem análise geométrica, risco visível e interceptações com tempo mínimo de reação.
- Turnovers geram transição, contra-ataques em três corredores e pontos após erro registrados no box score.
- **Eclipse Defensivo** é o takeover coletivo da Nightclaw, carregado por roubos, tocos e violações.
- Diretor de partida pode oferecer dicas e variar pesos estratégicos, mas nunca manipula a bola, o arremesso ou atributos ocultos.
- Save v6 preserva campanha, evolução, temporada, turnovers e o perfil adaptativo.
- HQ pré e pós-jogo do capítulo 7.
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

## Sistemas de IA

| Sistema | Papel | Limite de justiça |
|---|---|---|
| `PlayerTendencyModel` | Memória com decaimento e confiança mínima | Precisa de evidência; esquece gradualmente |
| `PassingLaneAnalyzer` | Risco geométrico de passe | Usa posições reais e atributo visível de passe |
| `NightclawUtilityAI` | Escolha contextual da defesa | Reação mínima de 0,30 s e variação pequena |
| `FairMatchDirector` | Dicas e mudança de estratégia | Proíbe alterar acerto, física ou atributos ocultos |

Tudo roda localmente, sem enviar telemetria ou dados pessoais para serviços externos. O save armazena somente contagens agregadas de ações de gameplay.

## Campanha

1. Primeiro Quique — Quartz Academy — jogável.
2. Raízes em Movimento — Canopy Institute — jogável.
3. Pressão Vulcânica — Ember Ridge — jogável.
4. Maré Alta — Tidefang School — jogável.
5. Acima do Aro — Skycrest Academy — jogável.
6. Parede de Chifres — Ironhorn Institute — jogável.
7. **Luzes Apagadas — Nightclaw Academy — jogável.**
8. O Jogo dos Dados — Fossil Tech — planejado.
9. O Rugido — Apex Dominion — semifinal planejada.
10. O Meteoro — Tyrant Crown Academy — final planejada.

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

- `systems/ai/` — memória de tendências, linhas de passe, utility AI e diretor justo.
- `data/match_catalog.gd` — campanha, elencos e atributos.
- `data/game_tuning.gd` — parâmetros centralizados de gameplay.
- `scenes/prototype_match.gd` — regras e integração da partida.
- `systems/save_manager.gd` — save v6, progressão e temporada.
- `content/story/comics/chapter_07/` — HQ pré-Nightclaw.
- `content/story/comics/chapter_07_post/` — HQ pós-Nightclaw.
- `docs/NIGHTCLAW_DESIGN.md` — intenção e contrajogo do Jogo 7.
- `docs/AI_STRATEGY.md` — arquitetura, justiça e próximos passos da IA.
- `docs/TESTE_v0.9.md` — roteiro de playtest.

## Estado do protótipo

O jogo permanece em graybox. Modelos 3D, rig, animações, VFX, UI artística e áudio final ainda são placeholders. A prioridade continua sendo provar que o basquete, a progressão e as identidades táticas são divertidos antes da produção visual definitiva.
