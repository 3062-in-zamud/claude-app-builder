---
name: data-deletion
description: |
  What: 30日猶予付きデータ削除パイプライン（論理削除→物理削除）を設計・実装する
  When: Phase 11.5（コンプライアンス強化フェーズ）
  How: 削除フロー設計 → DB設計 → Stripe連携 → 削除ジョブ → 監査ログ実装
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

$ARGUMENTS を data-deletion スキルに渡して実行してください。
~/.claude/skills/data-deletion/SKILL.md の手順に従い、
claude-sonnet-4-6 モデルを使用してデータ削除パイプラインを構築してください。
