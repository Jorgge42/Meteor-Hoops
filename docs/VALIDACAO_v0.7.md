# Validação estrutural v0.7

Data de fechamento: 2026-09-20.

## Verificações executadas

- delimitadores de scripts GDScript balanceados;
- ausência de funções top-level duplicadas nos scripts;
- referências `res://` verificadas contra arquivos do projeto;
- XML dos SVGs validado;
- resources do capítulo 5 presentes;
- Jogo 5 marcado como jogável no catálogo;
- save atualizado para versão 4;
- controles do lob registrados no `InputMap` em runtime;
- documentação de teste e progressão adicionada;
- arquivo ZIP testado após empacotamento.

## Limitação

Não existe executável do Godot disponível neste ambiente. Portanto, esta validação é estática e estrutural. O primeiro boot no Godot 4.7.x continua sendo o smoke test de runtime obrigatório.
