# VALIDAÇÃO TÉCNICA — v0.5

## Verificação estática executada
- referências literais `res://` existentes;
- classes `class_name` sem duplicidade;
- funções sem duplicidade no mesmo script;
- delimitadores estruturais balanceados em `.gd`, `.tres` e `.tscn`;
- 18 SVGs de HQ parseados como XML válido;
- 4 WAVs provisórios lidos como PCM mono 44.1 kHz;
- catálogo com Jogos 1–3 marcados como jogáveis;
- recursos dos capítulos 1–3 presentes.

## Limitação
O executável do Godot não está instalado neste ambiente. Portanto esta validação **não substitui o boot real no Godot 4.7.x**.

## Smoke test obrigatório
1. Abrir `project.godot`.
2. Executar e abrir Personagens.
3. Abrir Rota do Meteoro e confirmar Jogos 1–3 jogáveis.
4. Entrar no Treino/Jogo 1 e testar C, F, J, K, E, Q e passe.
5. Confirmar os quatro SFX.
6. Vencer Jogo 2 e iniciar capítulo/Jogo 3.
7. Jogar Ember Ridge e observar se a pressão é mais intensa.
8. Fechar e reabrir para validar save.
