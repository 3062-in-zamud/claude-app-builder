---
name: app-builder
description: |
  What: アイデアを0からMVPリリースまで全自動で実現するオーケストレーター（growth-engine連携対応）
  When: 新しいアプリを作りたい時。/app-builder "アイデア" で起動
  How: 8フェーズを自動実行。G3品質ゲートとセキュリティチェックを経てデプロイ。リリース後は /growth-engine で収益化
argument-hint: "\"アプリのアイデアを日本語または英語で説明\""
allowed-tools:
  - Task
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

$ARGUMENTS を app-builder スキルに渡して実行してください。
~/.claude/skills/app-builder/SKILL.md の手順に従い、
リーダーとして claude-opus-4-6 モデルを使用して全フェーズを統括してください。
