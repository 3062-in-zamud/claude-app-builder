---
name: security-hardening
description: |
  What: AI生成コード特有の脆弱性を検査・修正する（セキュリティ強化フェーズ）
  When: Phase 5.5（実装完了直後）。必須・スキップ不可
  How: CRITICAL → HIGH の順にチェック → 問題があれば修正してから次フェーズへ
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

$ARGUMENTS を security-hardening スキルに渡して実行してください。
~/.claude/skills/security-hardening/SKILL.md の手順に従い、
claude-opus-4-6 モデルを使用してセキュリティ強化を実行してください。
