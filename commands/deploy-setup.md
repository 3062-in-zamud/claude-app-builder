---
name: deploy-setup
description: |
  What: Supabase + Vercel への本番デプロイを実行し、ローンチ素材を生成する（ロールバック戦略・ステージング検証・スモークテスト付き）
  When: Phase 7（release-checklist 全項目完了後）
  How: デプロイ前チェック → ログイン確認 → 環境変数設定 → DB マイグレーション（Expand-Contract） → ステージング検証 → vercel --prod → スモークテスト → 素材生成
allowed-tools:
  - Read
  - Write
  - Bash
---

$ARGUMENTS を deploy-setup スキルに渡して実行してください。
~/.claude/skills/deploy-setup/SKILL.md の手順に従い、
claude-sonnet-4-6 モデルを使用してデプロイを実行してください。
