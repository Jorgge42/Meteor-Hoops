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

## Validação local

Comandos previstos:

```bash
python3 tools/validate_project.py
python3 -m gdtoolkit.parser $(rg --files -g '*.gd' | sort)
git diff --check
godot --headless --path . --import
godot --headless --path . --script res://tests/test_ai_contracts.gd
```

## GitHub Actions

A execução e o resultado do workflow serão registrados aqui após a publicação do branch.

## Playtest

Os contratos automatizados verificam estrutura e justiça. O roteiro em `docs/TESTE_v1.2.md` continua necessário para calibrar ritmo, clareza e diversão da final em hardware real.
