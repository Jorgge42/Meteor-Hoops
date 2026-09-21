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

A execução final do Godot 4.7.2 e a integridade da árvore remota serão registradas aqui antes da integração em `main`.
