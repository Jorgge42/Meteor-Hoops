# Validação v1.2 — O Meteoro

Data: 21 de setembro de 2026.

## Escopo

- metadados Prototype v1.2 e versão `v1.2`;
- referências `res://`, recursos narrativos e seis SVGs do capítulo 10;
- parser GDScript em todos os scripts;
- Jogo 10, elenco e HQs registrados no catálogo;
- save padrão v9, migração e perfil agregado da final;
- contratos de decreto, Legado, reação mínima, persistência e justiça;
- importação, testes e boot da cena principal no Godot 4.7.2.

## Validação estática local

Comandos concluídos sem erro:

```bash
python3 tools/validate_project.py
python3 -m gdtoolkit.parser $(rg --files -g '*.gd' | sort)
git diff --check
```

Resultado: recursos e SVGs válidos, parser GDScript limpo e diff sem erros de whitespace.

## GitHub Actions

Execução: [Godot validation #21](https://github.com/Jorgge42/Meteor-Hoops/actions/runs/35591024454)

Job `Import, contracts and boot`: **sucesso**.

| Etapa | Resultado |
|---|---|
| Setup Godot 4.7.2 | sucesso |
| Validate repository resources | sucesso |
| Import project | sucesso, sem `SCRIPT ERROR` |
| Run AI contracts | 88 checks aprovados |
| Boot main scene | sucesso, sem erro de script |

O workflow agora captura a saída de importação, contratos e boot e falha explicitamente se o Godot registrar `SCRIPT ERROR` ou não conseguir carregar um script, mesmo que o processo retorne código zero.

## Integridade da publicação

A árvore remota validada (`eeeb83d605d88e5da6756abac80465066b77f613`) coincide com a árvore local do commit publicado. Os 27 arquivos da implementação e o endurecimento do workflow chegaram completos ao PR.

## Playtest

Os contratos automatizados verificam estrutura e justiça. A v1.2 está tecnicamente pronta para integração. O roteiro em `docs/TESTE_v1.2.md` continua recomendado para calibrar ritmo, clareza e diversão da final em hardware real.
