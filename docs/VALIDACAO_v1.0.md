# Validação v1.0 — O Jogo dos Dados

Data: 21 de setembro de 2026.

## Escopo verificado

- metadados Prototype v1.0 e versão `v1.0`;
- referências `res://` e recursos narrativos;
- seis SVGs válidos do capítulo 8;
- parser GDScript em todos os scripts;
- Jogo 8, elenco e HQs registrados no catálogo;
- save padrão v7 com perfil agregado de sequências;
- contratos de tendência, sequência, valor esperado, reação e justiça;
- importação e boot da cena principal no engine alvo.

## Validação local

Comandos concluídos sem erro:

```bash
python3 tools/validate_project.py
PYTHONPATH=/workspace/scratch/f5d107aded6a/tooling/gdtoolkit python3 -m gdtoolkit.parser $(rg --files -g '*.gd' | sort)
git diff --check
```

## GitHub Actions

Execução: [Godot validation #8](https://github.com/Jorgge42/Meteor-Hoops/actions/runs/35549421513)

Job `Import, contracts and boot`: **sucesso**.

| Etapa | Resultado |
|---|---|
| Setup Godot 4.7.2 | sucesso |
| Validate repository resources | sucesso |
| Import project | sucesso |
| Run AI contracts | sucesso |
| Boot main scene | sucesso |

## Integridade da publicação

A árvore remota validada (`e3982d9988b748459410cb75e5983cf70d6767fa`) coincide exatamente com a árvore do commit local de implementação. Isso confirma que scripts grandes, recursos e documentação chegaram completos ao PR.

## Resultado

A v1.0 atende aos contratos automatizados e está pronta para integração. O playtest humano descrito em `docs/TESTE_v1.0.md` continua recomendado para balancear ritmo, clareza do HUD e velocidade de preenchimento da barra Modelo Quebrado.
