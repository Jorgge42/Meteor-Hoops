# Estratégia de IA — v1.1

## Princípio

A IA de Meteor Hoops deve criar decisões legíveis e contrajogo. O objetivo não é simular inteligência por dificuldade artificial, mas fazer cada escola observar informações reais, escolher uma intenção e expor uma fraqueza.

## Arquitetura atual

| Camada | Responsabilidade |
|---|---|
| Percepção | Posições, portador, linha de passe, pressão, ajuda e transição |
| Memória | Frequência, sucesso, repetição recente, confiança e decaimento |
| Sequência | Transições agregadas entre ações e previsão contextual da próxima decisão |
| Decisão | Pontuação utilitária com pequena variação determinística por partida |
| Valor esperado | Comparação ofensiva entre passe, arremesso e finalização observáveis |
| Coordenação | Plano compartilhado que reposiciona os três atletas da Apex |
| Contrajogo | Compostura por variedade, posse segura e parada defensiva |
| Execução | Alvos de movimento, contenção, negação, trap e contra-ataque |
| Direção | Dicas contextuais e mudanças limitadas de pesos estratégicos |
| Explicação | Tendência detectada, takeover e mensagem de contrajogada no HUD |

## Contratos de justiça

- Reação mínima: **0,30 s**, inclusive durante takeover.
- Tendência só aparece após evidência mínima.
- Memória perde peso a cada posse e é reduzida no intervalo.
- Variação aleatória só desempata decisões próximas.
- O diretor pode mudar dicas, comentário e pesos estratégicos.
- O diretor não pode mudar chance de acerto, física da bola ou atributos ocultos.
- Toda ação defensiva especial possui ao menos uma resposta disponível ao jogador.
- A Fossil Tech só usa uma previsão depois de três evidências no mesmo contexto.
- A previsão, a confiança e o estado vulnerável ficam visíveis antes do compromisso defensivo.
- Uma previsão errada é preservada como erro; o sistema não a reclassifica depois da ação.
- O estado Modelo Quebrado suspende antecipação e aumenta o atraso de reação.
- Todo plano da Apex é nomeado no HUD antes de coordenar o posicionamento.
- Rugido e Silêncio alteram somente o tempo de troca do plano coletivo.
- Rugido não modifica velocidade, atributos, chance de acerto ou física da bola.
- A reação da Apex respeita piso de **0,34 s**, inclusive durante o Rugido.
- A Compostura recompensa ações distintas e pune repetição dentro da janela recente.

Esses contratos são executados por `tests/test_ai_contracts.gd` no CI.

## Privacidade e operação

O sistema roda offline. Nenhum prompt, conta, voz, imagem ou telemetria pessoal sai do dispositivo. O save guarda somente contagens limitadas de ações do jogo. Isso evita latência, custo de API, indisponibilidade de rede e comportamento imprevisível em uma partida em tempo real.

Modelos generativos continuam úteis no pipeline de produção — concept art, variações de diálogo, testes e protótipos — desde que o conteúdo final seja revisado e versionado no repositório. Eles não ficam no caminho crítico do gameplay.

## Próximas evoluções

1. Separar `prototype_match.gd` em controladores de posse, arbitragem, estatísticas e IA.
2. Extrair planos coletivos para recursos configuráveis, permitindo novas escolas sem aumentar o controlador principal.
3. Registrar eventos de playtest em arquivo local opt-in e gerar relatório de balanceamento.
4. Criar replay fantasma determinístico para reproduzir turnovers e bugs.
5. Criar um técnico contextual que explique uma alternativa após duas falhas semelhantes, sem interromper a posse.
6. Comparar previsões por formação e zona da quadra sem armazenar trajetórias individuais.
7. Separar o avaliador de valor esperado em dados configuráveis por escola.

## Métricas de balanceamento

- turnovers por 20 posses;
- pontos após turnover;
- uso e sucesso da finta;
- distribuição de ações ofensivas;
- tempo entre leitura mostrada e mudança de comportamento;
- frequência e duração do Eclipse Defensivo;
- diferença entre dificuldades causada por decisão, não por atributos escondidos.
- taxa de acerto da previsão por contexto;
- previsões quebradas por posse;
- tempo até o jogador provocar o primeiro Modelo Quebrado;
- distribuição das escolhas de maior valor da Fossil Tech.
- distribuição e duração dos planos da Apex;
- ações que carregam o Rugido por posse;
- sequência média de Compostura e Silêncios ativados por partida.
