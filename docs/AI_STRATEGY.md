# Estratégia de IA — v0.9

## Princípio

A IA de Meteor Hoops deve criar decisões legíveis e contrajogo. O objetivo não é simular inteligência por dificuldade artificial, mas fazer cada escola observar informações reais, escolher uma intenção e expor uma fraqueza.

## Arquitetura atual

| Camada | Responsabilidade |
|---|---|
| Percepção | Posições, portador, linha de passe, pressão, ajuda e transição |
| Memória | Frequência, sucesso, repetição recente, confiança e decaimento |
| Decisão | Pontuação utilitária com pequena variação determinística por partida |
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

Esses contratos são executados por `tests/test_ai_contracts.gd` no CI.

## Privacidade e operação

O sistema roda offline. Nenhum prompt, conta, voz, imagem ou telemetria pessoal sai do dispositivo. O save guarda somente contagens limitadas de ações do jogo. Isso evita latência, custo de API, indisponibilidade de rede e comportamento imprevisível em uma partida em tempo real.

Modelos generativos continuam úteis no pipeline de produção — concept art, variações de diálogo, testes e protótipos — desde que o conteúdo final seja revisado e versionado no repositório. Eles não ficam no caminho crítico do gameplay.

## Próximas evoluções

1. Separar `prototype_match.gd` em controladores de posse, arbitragem, estatísticas e IA.
2. Adicionar intenção compartilhada para companheiros, evitando dois atletas ocuparem o mesmo espaço.
3. Registrar eventos de playtest em arquivo local opt-in e gerar relatório de balanceamento.
4. Criar replay fantasma determinístico para reproduzir turnovers e bugs.
5. Usar a Fossil Tech para introduzir previsão de jogadas com falsa certeza e exploração do lado fraco.
6. Criar um técnico contextual que explique uma alternativa após duas falhas semelhantes, sem interromper a posse.

## Métricas de balanceamento

- turnovers por 20 posses;
- pontos após turnover;
- uso e sucesso da finta;
- distribuição de ações ofensivas;
- tempo entre leitura mostrada e mudança de comportamento;
- frequência e duração do Eclipse Defensivo;
- diferença entre dificuldades causada por decisão, não por atributos escondidos.
