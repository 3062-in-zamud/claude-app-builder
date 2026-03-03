---
name: growth-engine
description: |
  What: 成長エンジン - Alpha→有料化→Beta→GA までを統括するオーケストレーター
  When: app-builder完了後に /growth-engine で起動。Stage D〜Fを自動実行
  How: 価格設計→決済→オンボーディング→メール→A/Bテスト→GDPR→リテンション→スケーリングを順次/並列実行
argument-hint: "\"成長フェーズの開始（app-builder完了後に実行）\""
allowed-tools:
  - Task
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

$ARGUMENTS を growth-engine スキルに渡して実行してください。
~/.claude/skills/growth-engine/SKILL.md の手順に従い、
リーダーとして claude-opus-4-6 モデルを使用して全ステージを統括してください。
