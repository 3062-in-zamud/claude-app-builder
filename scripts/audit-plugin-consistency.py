#!/usr/bin/env python3
"""Core skill consistency audit for claude-app-builder plugin."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_SNIPPETS = {
    "skills/stack-selector/SKILL.md": [
        "deployment_provider",
        "cloudflare_pages_project",
        "cloudflare_build_command",
        "cloudflare_build_dir",
    ],
    "skills/app-builder/SKILL.md": [
        "DEPLOYMENT_PROVIDER",
        "deployment_provider が未定義です",
        "cloudflare_pages_project",
    ],
    "skills/deploy-setup/SKILL.md": [
        "deployment_provider",
        "cloudflare_build_command",
        "cloudflare_build_dir",
    ],
    "skills/monitoring-setup/SKILL.md": [
        "provider",
        "Analytics",
    ],
    "skills/release-checklist/references/checklist-50items.md": [
        "deployment_provider",
        "cloudflare_pages_project",
    ],
}

FORBIDDEN_PATTERNS = {
    "skills/feedback-loop/SKILL.md": [
        r"Vercel Analytics で",
    ],
    "skills/idea-to-spec/references/non-functional-requirements-checklist.md": [
        r"HTTPS（Vercel 標準）",
        r"Vercel 環境変数",
    ],
    "skills/scaling-strategy/SKILL.md": [
        r"一般的なVercel \+ Supabaseスタック",
    ],
    "skills/incident-response/SKILL.md": [
        r"一般的なVercel \+ Supabaseスタック",
    ],
    "skills/app-builder/references/quality-dashboard-template.md": [
        r"\| Vercel プラン \|",
    ],
}


def read_text(rel_path: str) -> str | None:
    path = ROOT / rel_path
    if not path.exists():
        print(f"[FAIL] missing file: {rel_path}")
        return None
    return path.read_text(encoding="utf-8")


def main() -> int:
    failures = 0

    print("=== plugin consistency audit ===")

    for rel_path, snippets in REQUIRED_SNIPPETS.items():
        content = read_text(rel_path)
        if content is None:
            failures += 1
            continue
        for snippet in snippets:
            if snippet not in content:
                print(f"[FAIL] {rel_path}: missing snippet -> {snippet}")
                failures += 1

    for rel_path, patterns in FORBIDDEN_PATTERNS.items():
        content = read_text(rel_path)
        if content is None:
            failures += 1
            continue
        for pattern in patterns:
            if re.search(pattern, content):
                print(f"[FAIL] {rel_path}: forbidden pattern matched -> {pattern}")
                failures += 1

    if failures:
        print(f"=== NG: {failures} issue(s) ===")
        return 1

    print("=== OK: all checks passed ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())
