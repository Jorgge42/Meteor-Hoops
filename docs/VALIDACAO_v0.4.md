# VALIDAÇÃO TÉCNICA — v0.4

## Conferido nesta build
- Estrutura `res://` dos scripts, cenas, HQs e recursos.
- Ausência de classes `class_name` duplicadas.
- Balanceamento estrutural de parênteses, colchetes e chaves nos scripts/resources.
- Existência das quatro HQs referenciadas pelos Jogos 1 e 2.
- Catálogo com 10 partidas e dois elencos rivais implementados.
- Save retrocompatível com o perfil criado na v0.3.
- APIs centrais usadas na física/input verificadas contra a documentação da linha Godot 4.x/4.7.

## Limitação do ambiente de montagem
O executável do Godot não está disponível neste ambiente, portanto a build não passou por boot real do editor/engine aqui. O primeiro teste obrigatório no computador de desenvolvimento é abrir `project.godot` no Godot 4.7.2 e observar o painel Output/Debugger.

## Smoke test recomendado ao abrir
1. Abrir `project.godot`.
2. Executar o projeto.
3. Abrir Modo História e confirmar os 10 cards.
4. Entrar no Jogo 1.
5. Testar movimento, passe, J, K, E, F e Q.
6. Concluir/forçar uma vitória e abrir o Jogo 2.
7. Fechar e reabrir para validar o save.
