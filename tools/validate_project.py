#!/usr/bin/env python3
"""Fast repository checks that do not require the Godot executable."""

from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEXT_SUFFIXES = {".gd", ".godot", ".tres", ".tscn"}
RESOURCE_PATTERN = re.compile(r'res://[^"\')\s]+')


def fail(message: str, failures: list[str]) -> None:
    failures.append(message)


def validate_metadata(failures: list[str]) -> None:
    version = (ROOT / "VERSION.txt").read_text(encoding="utf-8").strip()
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    if version != "v1.1":
        fail(f"VERSION.txt inesperado: {version}", failures)
    if "Prototype v1.1" not in project:
        fail("project.godot não anuncia a v1.1", failures)
    if "Prototype v1.1" not in readme:
        fail("README não anuncia a v1.1", failures)


def validate_resource_references(failures: list[str]) -> None:
    checked: set[str] = set()
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix not in TEXT_SUFFIXES:
            continue
        text = path.read_text(encoding="utf-8")
        for reference in RESOURCE_PATTERN.findall(text):
            if reference in checked:
                continue
            checked.add(reference)
            target = ROOT / reference.removeprefix("res://")
            if not target.exists():
                fail(f"Recurso ausente: {reference}", failures)


def validate_story_svg(failures: list[str]) -> None:
    story_roots = [
        ROOT / "content/story/comics/chapter_07",
        ROOT / "content/story/comics/chapter_07_post",
        ROOT / "content/story/comics/chapter_08",
        ROOT / "content/story/comics/chapter_08_post",
        ROOT / "content/story/comics/chapter_09",
        ROOT / "content/story/comics/chapter_09_post",
    ]
    for story_root in story_roots:
        pages = sorted(story_root.glob("page_*.svg"))
        if len(pages) != 3:
            fail(f"{story_root.relative_to(ROOT)} deve conter 3 páginas", failures)
        for page in pages:
            try:
                ET.parse(page)
            except ET.ParseError as error:
                fail(f"SVG inválido em {page.relative_to(ROOT)}: {error}", failures)


def validate_required_files(failures: list[str]) -> None:
    required = [
        "systems/ai/player_tendency_model.gd",
        "systems/ai/passing_lane_analyzer.gd",
        "systems/ai/nightclaw_utility_ai.gd",
        "systems/ai/fair_match_director.gd",
        "systems/ai/sequence_prediction_model.gd",
        "systems/ai/fossil_tech_predictive_ai.gd",
        "systems/ai/apex_coordination_ai.gd",
        "systems/ai/composure_tracker.gd",
        "data/chapter_07.tres",
        "data/chapter_07_post.tres",
        "data/chapter_08.tres",
        "data/chapter_08_post.tres",
        "data/chapter_09.tres",
        "data/chapter_09_post.tres",
        "tests/test_ai_contracts.gd",
    ]
    for relative in required:
        if not (ROOT / relative).is_file():
            fail(f"Arquivo obrigatório ausente: {relative}", failures)


def main() -> int:
    failures: list[str] = []
    validate_metadata(failures)
    validate_resource_references(failures)
    validate_story_svg(failures)
    validate_required_files(failures)
    if failures:
        for message in failures:
            print(f"ERROR: {message}", file=sys.stderr)
        return 1
    print("Static validation passed: metadata, resources, SVGs and v1.1 files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
