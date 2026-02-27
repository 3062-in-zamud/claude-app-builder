---
name: deploy-setup
description: |
  What: Supabase + Vercel への本番デプロイを実行し、ローンチ素材を生成する
  When: Phase 7（release-checklist 全項目完了後）
  How: ログイン確認 → 環境変数設定 → DB マイグレーション → vercel --prod → 素材生成
allowed-tools:
  - Read
  - Write
  - Bash
---

$ARGUMENTS を deploy-setup スキルに渡して実行してください。
~/.claude/skills/deploy-setup/SKILL.md の手順に従い、
claude-haiku-4-5-20251001 モデルを使用してデプロイを実行してください。
