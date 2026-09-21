# Validação v1.1 — O Rugido

Data: 21 de setembro de 2026.

## Escopo

- metadados Prototype v1.1 e versão `v1.1`;
- referências `res://` e recursos narrativos;
- seis SVGs válidos do capítulo 9;
- parser GDScript em todos os scripts;
- Jogo 9, elenco e HQs registrados no catálogo;
- save padrão v8 com perfil agregado da semifinal;
- contratos de Compostura, planos, reação mínima e justiça;
- importação, testes e boot da cena principal no Godot 4.7.2.

## Validação local

Comandos concluídos sem erro:

```bash
python3 tools/validate_project.py
PYTHONPATH=/workspace/scratch/f5d107aded6a/tooling/gdtoolkit python3 -m gdtoolkit.parser $(rg --files -g '*.gd' | sort)
git diff --check
```

Resultado estático: metadados, referências, recursos, parser GDScript e SVGs válidos.

## GitHub Actions

Execução: [Godot validation #14](https://github.com/Jorgge42/Meteor-Hoops/actions/runs/35587449980)

Job `Import, contracts and boot`: **sucesso**.

| Etapa | Resultado |
|---|---|
| Setup Godot 4.7.2 | sucesso |
| Validate repository resources | sucesso |
| Import project | sucesso |
| Run AI contracts | sucesso |
| Boot main scene | sucesso |

## Integridade da publicação

A árvore remota da implementação (`ce1a35179fb544631da3a9031e927fa46d56f609`) coincide exatamente com a árvore do commit local validado. Isso confirma que os 27 arquivos alterados, inclusive o controlador principal, chegaram completos ao PR.

## Resultado

A v1.1 atende aos contratos automatizados e está pronta para integração. O playtest humano descrito em `docs/TESTE_v1.1.md` continua recomendado para balancear o ritmo do Rugido, a clareza dos planos e a velocidade de preenchimento da Compostura.
