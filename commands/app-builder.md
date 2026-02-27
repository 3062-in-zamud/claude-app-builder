---
name: app-builder
description: |
  What: アイデアを0からMVPリリースまで全自動で実現するオーケストレーター
  When: 新しいアプリを作りたい時。/app-builder "アイデア" で起動
  How: 8フェーズを自動実行。要件定義後に1回ユーザー承認を求める
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
