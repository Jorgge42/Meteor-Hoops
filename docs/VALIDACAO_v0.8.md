# Validação estrutural v0.8

Validação estática concluída antes de empacotar a build.

## Inventário
- 97 arquivos de projeto;
- 11 scripts GDScript;
- 12 resources `.tres`;
- 36 páginas/recursos SVG;
- 4 efeitos WAV provisórios.

## Resultado
- 0 referências `res://` ausentes detectadas;
- 0 SVGs inválidos;
- 0 funções duplicadas detectadas;
- 0 chamadas locais `_metodo()` sem definição no próprio script detectadas;
- 0 desequilíbrios básicos de `()`, `[]` ou `{}` detectados;
- save v5, capítulo 6 e nome interno v0.8 conferidos;
- seis partidas marcadas como jogáveis.

## Escopo da checagem
A validação cobre estrutura de arquivos, referências, XML das HQs, consistência básica dos scripts e integridade do pacote.

## Limitação
O executável do Godot não está instalado neste ambiente, portanto esta validação **não substitui o primeiro boot no Godot 4.7.x**. O playtest de runtime deve seguir `TESTE_v0.8.md`.
