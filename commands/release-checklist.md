---
name: release-checklist
description: |
  What: リリース前の36項目チェックリストを実行する
  When: Phase 6（monitoring-setup 後、deploy-setup 前）
  How: 全項目を順次確認 → 未完了項目を修正 → 全 ✅ でリリース許可
allowed-tools:
  - Read
  - Write
  - Bash
---

$ARGUMENTS を release-checklist スキルに渡して実行してください。
~/.claude/skills/release-checklist/SKILL.md の手順に従い、
claude-sonnet-4-6 モデルを使用してリリース前チェックを実行してください。
